function logsout_data = extractLogsoutDataFixed(logsout)
    % External function for extracting logsout data - can be used in parallel processing
    % This function doesn't rely on config.verbosity
    
    logsout_data = table();
    
    try
        if isempty(logsout)
            fprintf('Logsout is empty\n');
            return;
        end
        
        % Initialize data arrays
        all_data = {};
        var_names = {};
        
        % Get all signal names
        signal_names = logsout.getElementNames();
        
        if isempty(signal_names)
            fprintf('No signals found in logsout\n');
            return;
        end
        
        % Get time data from the first signal
        first_signal = logsout.getElement(signal_names{1});
        if isprop(first_signal, 'Values') && isprop(first_signal.Values, 'Time')
            time_data = first_signal.Values.Time;
            expected_length = length(time_data);
        else
            fprintf('Could not determine time data from logsout\n');
            return;
        end
        
        % Add time column
        all_data{end+1} = time_data;
        var_names{end+1} = 'time';
        
        % Process each signal
        for i = 1:length(signal_names)
            signal_name = signal_names{i};
            
            try
                signal = logsout.getElement(signal_name);
                
                if isprop(signal, 'Values') && isprop(signal.Values, 'Data')
                    signal_data = signal.Values.Data;
                    
                    % Handle different data types
                    if isnumeric(signal_data)
                        if isvector(signal_data) && length(signal_data) == expected_length
                            all_data{end+1} = signal_data(:);
                            var_names{end+1} = signal_name;
                        elseif ismatrix(signal_data) && size(signal_data, 1) == expected_length
                            % Matrix data - create separate columns
                            num_cols = size(signal_data, 2);
                            for col = 1:num_cols
                                all_data{end+1} = signal_data(:, col);
                                var_names{end+1} = sprintf('%s_col_%d', signal_name, col);
                            end
                        end
                    end
                end
                
            catch ME
                fprintf('Error processing signal %s: %s\n', signal_name, ME.message);
            end
        end
        
        % Create table
        if ~isempty(all_data)
            logsout_data = table(all_data{:}, 'VariableNames', var_names);
        end
        
    catch ME
        fprintf('Error extracting logsout data: %s\n', ME.message);
    end
end