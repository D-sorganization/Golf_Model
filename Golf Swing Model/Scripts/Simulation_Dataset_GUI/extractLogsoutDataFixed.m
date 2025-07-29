function logsout_data = extractLogsoutDataFixed(logsout)
    logsout_data = [];
    
    try
        fprintf('Debug: Extracting logsout data, type: %s\n', class(logsout));
        
        % Handle modern Simulink.SimulationData.Dataset format
        if isa(logsout, 'Simulink.SimulationData.Dataset')
            fprintf('Debug: Processing Dataset format with %d elements\n', logsout.numElements);
            
            if logsout.numElements == 0
                fprintf('Debug: Dataset is empty\n');
                return;
            end
            
            % Get time from first element
            first_element = logsout.getElement(1);  % Use getElement instead of {}
            
            % Handle Signal objects properly
            if isa(first_element, 'Simulink.SimulationData.Signal')
                time = first_element.Values.Time;
                fprintf('Debug: Using time from Signal object, length: %d\n', length(time));
            elseif isa(first_element, 'timeseries')
                time = first_element.Time;
                fprintf('Debug: Using time from timeseries, length: %d\n', length(time));
            else
                fprintf('Debug: Unknown first element type: %s\n', class(first_element));
                return;
            end
            
            data_cells = {time};
            var_names = {'time'};
            expected_length = length(time);
            used_names = {'time'}; % Track used names to avoid duplicates
            
            % Process each element in the dataset
            for i = 1:logsout.numElements
                element = logsout.getElement(i);  % Use getElement
                
                if isa(element, 'Simulink.SimulationData.Signal')
                    signalName = element.Name;
                    if isempty(signalName)
                        signalName = sprintf('Signal_%d', i);
                    end
                    
                    % Extract data from Signal object
                    data = element.Values.Data;
                    signal_time = element.Values.Time;
                    
                    % Ensure data matches time length and is valid
                    if isnumeric(data) && length(signal_time) == expected_length && ~isempty(data)
                        % Check if data has the right dimensions
                        if size(data, 1) == expected_length
                            if size(data, 2) > 1
                                % Multi-dimensional signal
                                for col = 1:size(data, 2)
                                    col_data = data(:, col);
                                    % Ensure the column data is the right length
                                    if length(col_data) == expected_length
                                        % Create unique column name
                                        base_name = sprintf('%s_%d', signalName, col);
                                        unique_name = makeUniqueName(base_name, used_names);
                                        used_names{end+1} = unique_name;
                                        
                                        data_cells{end+1} = col_data;
                                        var_names{end+1} = unique_name;
                                        fprintf('Debug: Added multi-dim signal %s (length: %d)\n', unique_name, length(col_data));
                                    else
                                        fprintf('Debug: Skipping column %d of signal %s (length mismatch: %d vs %d)\n', col, signalName, length(col_data), expected_length);
                                    end
                                end
                            else
                                % Single column signal
                                flat_data = data(:);
                                if length(flat_data) == expected_length
                                    % Create unique signal name
                                    unique_name = makeUniqueName(signalName, used_names);
                                    used_names{end+1} = unique_name;
                                    
                                    data_cells{end+1} = flat_data;
                                    var_names{end+1} = unique_name;
                                    fprintf('Debug: Added signal %s (length: %d)\n', unique_name, length(flat_data));
                                else
                                    fprintf('Debug: Skipping signal %s (flattened length mismatch: %d vs %d)\n', signalName, length(flat_data), expected_length);
                                end
                            end
                        else
                            fprintf('Debug: Skipping signal %s (row dimension mismatch: %d vs %d)\n', signalName, size(data, 1), expected_length);
                        end
                    else
                        fprintf('Debug: Skipping signal %s (time length mismatch: %d vs %d, or empty data)\n', signalName, length(signal_time), expected_length);
                    end
                    
                elseif isa(element, 'timeseries')
                    signalName = element.Name;
                    data = element.Data;
                    if isnumeric(data) && length(data) == expected_length && ~isempty(data)
                        flat_data = data(:);
                        if length(flat_data) == expected_length
                            % Create unique signal name
                            unique_name = makeUniqueName(signalName, used_names);
                            used_names{end+1} = unique_name;
                            
                            data_cells{end+1} = flat_data;
                            var_names{end+1} = unique_name;
                            fprintf('Debug: Added timeseries %s (length: %d)\n', unique_name, length(flat_data));
                        else
                            fprintf('Debug: Skipping timeseries %s (flattened length mismatch: %d vs %d)\n', signalName, length(flat_data), expected_length);
                        end
                    else
                        fprintf('Debug: Skipping timeseries %s (length mismatch: %d vs %d, or empty data)\n', signalName, length(data), expected_length);
                    end
                else
                    fprintf('Debug: Element %d is type: %s\n', i, class(element));
                end
            end
            
            % Validate all data vectors have the same length before creating table
            if length(data_cells) > 1
                % Check that all vectors have the same length
                lengths = cellfun(@length, data_cells);
                if all(lengths == expected_length)
                    logsout_data = table(data_cells{:}, 'VariableNames', var_names);
                    fprintf('Debug: Created logsout table with %d columns, all vectors length %d\n', width(logsout_data), expected_length);
                else
                    fprintf('Debug: Cannot create table - vector length mismatch. Lengths: ');
                    fprintf('%d ', lengths);
                    fprintf('\n');
                    % Try to create table with only vectors of the correct length
                    valid_indices = find(lengths == expected_length);
                    if length(valid_indices) > 1
                        valid_cells = data_cells(valid_indices);
                        valid_names = var_names(valid_indices);
                        logsout_data = table(valid_cells{:}, 'VariableNames', valid_names);
                        fprintf('Debug: Created logsout table with %d valid columns (length %d)\n', width(logsout_data), expected_length);
                    else
                        fprintf('Debug: Not enough valid vectors to create table\n');
                    end
                end
            else
                fprintf('Debug: No valid data found in logsout Dataset\n');
            end
            
        else
            fprintf('Debug: Logsout format not supported: %s\n', class(logsout));
        end
        
    catch ME
        fprintf('Error extracting logsout data: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function unique_name = makeUniqueName(base_name, used_names)
    % Helper function to create unique variable names
    unique_name = base_name;
    counter = 1;
    
    while ismember(unique_name, used_names)
        unique_name = sprintf('%s_dup%d', base_name, counter);
        counter = counter + 1;
    end
end