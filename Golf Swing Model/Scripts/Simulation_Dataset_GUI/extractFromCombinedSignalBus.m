% FIXED: Extract from CombinedSignalBus
function data_table = extractFromCombinedSignalBus(combinedBus)
    data_table = [];
    
    try
        % CombinedSignalBus should be a struct with time and signals
        if ~isstruct(combinedBus)
            return;
        end
        
        % Look for time field
        bus_fields = fieldnames(combinedBus);
        
        time_field = '';
        time_data = [];
        
        % Find time data - check common time field patterns
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);
            
            % Check if this field contains time data
            if isstruct(field_value) && isfield(field_value, 'time')
                time_field = field_name;
                time_data = field_value.time(:);  % Extract time from struct
                fprintf('Debug: Found time in %s.time (length: %d)\n', field_name, length(time_data));
                break;
            elseif isstruct(field_value) && isfield(field_value, 'Time')
                time_field = field_name;
                time_data = field_value.Time(:);  % Extract Time from struct
                fprintf('Debug: Found time in %s.Time (length: %d)\n', field_name, length(time_data));
                break;
            elseif contains(lower(field_name), 'time') && isnumeric(field_value)
                time_field = field_name;
                time_data = field_value(:);  % Ensure column vector
                fprintf('Debug: Found time field: %s (length: %d)\n', field_name, length(time_data));
                break;
            end
        end
        
        % If still no time found, try the first field that looks like it has time data
        if isempty(time_data)
            for i = 1:length(bus_fields)
                field_name = bus_fields{i};
                field_value = combinedBus.(field_name);
                
                if isstruct(field_value)
                    sub_fields = fieldnames(field_value);
                    for j = 1:length(sub_fields)
                        if contains(lower(sub_fields{j}), 'time')
                            time_field = field_name;
                            time_data = field_value.(sub_fields{j})(:);
                            fprintf('Debug: Found time in %s.%s (length: %d)\n', field_name, sub_fields{j}, length(time_data));
                            break;
                        end
                    end
                    if ~isempty(time_data)
                        break;
                    end
                end
            end
        end
        
        % First, try to find time data by examining the signal structures
        for i = 1:length(bus_fields)
            if ~isempty(time_data)
                break;
            end
            
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);
            
            if isstruct(field_value)
                % This field contains sub-signals
                sub_fields = fieldnames(field_value);
                
                % Try to get time from the first valid signal
                for j = 1:length(sub_fields)
                    sub_field_name = sub_fields{j};
                    signal_data = field_value.(sub_field_name);
                    
                    % Check if this is a timeseries or signal structure with time
                    if isa(signal_data, 'timeseries')
                        time_data = signal_data.Time(:);
                        fprintf('Debug: Found time in %s.%s (timeseries), length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    elseif isstruct(signal_data) && isfield(signal_data, 'time')
                        time_data = signal_data.time(:);
                        fprintf('Debug: Found time in %s.%s.time, length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    elseif isstruct(signal_data) && isfield(signal_data, 'Time')
                        time_data = signal_data.Time(:);
                        fprintf('Debug: Found time in %s.%s.Time, length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    elseif isstruct(signal_data) && isfield(signal_data, 'Values')
                        % Could be a Simulink.SimulationData.Signal format
                        if isnumeric(signal_data.Values) && size(signal_data.Values, 1) > 1
                            % Assume first column is time if it exists
                            time_data = (0:size(signal_data.Values, 1)-1)' * 0.001; % Default 1ms sampling
                            fprintf('Debug: Generated time vector for %s.%s, length: %d\n', field_name, sub_field_name, length(time_data));
                            break;
                        end
                    end
                end
            end
        end
        
        % If we still don't have time data, try to generate it from the first signal
        if isempty(time_data)
            for i = 1:length(bus_fields)
                field_name = bus_fields{i};
                field_value = combinedBus.(field_name);
                
                if isstruct(field_value)
                    sub_fields = fieldnames(field_value);
                    for j = 1:length(sub_fields)
                        sub_field_name = sub_fields{j};
                        signal_data = field_value.(sub_field_name);
                        
                        if isnumeric(signal_data) && ~isempty(signal_data)
                            % Generate time vector based on signal length
                            time_data = (0:length(signal_data)-1)' * 0.001; % Default 1ms sampling
                            fprintf('Debug: Generated time vector from %s.%s, length: %d\n', field_name, sub_field_name, length(time_data));
                            break;
                        end
                    end
                    if ~isempty(time_data)
                        break;
                    end
                elseif isnumeric(field_value) && ~isempty(field_value)
                    % Direct numeric field
                    time_data = (0:length(field_value)-1)' * 0.001; % Default 1ms sampling
                    fprintf('Debug: Generated time vector from %s, length: %d\n', field_name, length(time_data));
                    break;
                end
            end
        end
        
        % If we still don't have time data, we can't proceed
        if isempty(time_data)
            fprintf('Debug: Could not find or generate time data from CombinedSignalBus\n');
            return;
        end
        
        fprintf('Debug: Starting data extraction with time vector length: %d\n', length(time_data));
        
        % Now extract all signal data
        all_signals = {};
        signal_names = {};
        
        % Add time as the first column
        all_signals{end+1} = time_data;
        signal_names{end+1} = 'time';
        
        % Process each field in the bus
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);
            
            % Extract data from this field
            extracted_data = extractDataFromField(field_value, length(time_data));
            
            if ~isempty(extracted_data)
                all_signals = [all_signals, extracted_data];
                signal_names = [signal_names, field_name];
            end
        end
        
        % Create the data table
        if length(all_signals) > 1  % At least time + one signal
            data_table = table(all_signals{:}, 'VariableNames', signal_names);
            fprintf('Debug: Created table with %d columns and %d rows\n', width(data_table), height(data_table));
        else
            fprintf('Debug: No valid signals found in CombinedSignalBus\n');
        end
        
    catch ME
        fprintf('Error extracting CombinedSignalBus data: %s\n', ME.message);
    end
end 