function resampled_table = resampleDataToFrequency(data_table, target_freq, sim_time)
    % External function for resampling data to a specific frequency - can be used in parallel processing
    % This function doesn't rely on config.verbosity
    
    resampled_table = data_table;
    
    try
        if isempty(data_table) || height(data_table) == 0
            return;
        end
        
        % Check if time column exists
        if ~ismember('time', data_table.Properties.VariableNames)
            fprintf('No time column found for resampling\n');
            return;
        end
        
        % Get original time data
        original_time = data_table.time;
        
        if isempty(original_time)
            fprintf('Time column is empty\n');
            return;
        end
        
        % Calculate target time vector
        target_time = (0:1/target_freq:sim_time)';
        
        % Remove any time points beyond simulation time
        target_time = target_time(target_time <= sim_time);
        
        % Initialize resampled data
        resampled_data = {};
        resampled_names = {};
        
        % Resample each column
        for i = 1:width(data_table)
            col_name = data_table.Properties.VariableNames{i};
            col_data = data_table.(col_name);
            
            if strcmp(col_name, 'time')
                % Use target time for time column
                resampled_data{end+1} = target_time;
                resampled_names{end+1} = col_name;
            elseif isnumeric(col_data)
                try
                    % Interpolate numeric data
                    if length(col_data) == length(original_time)
                        resampled_col = interp1(original_time, col_data, target_time, 'linear', 'extrap');
                        resampled_data{end+1} = resampled_col;
                        resampled_names{end+1} = col_name;
                    else
                        % Data length doesn't match time - replicate or truncate
                        if length(col_data) == 1
                            % Scalar value - replicate
                            resampled_data{end+1} = repmat(col_data, length(target_time), 1);
                            resampled_names{end+1} = col_name;
                        else
                            % Vector with wrong length - truncate or pad
                            if length(col_data) > length(target_time)
                                resampled_data{end+1} = col_data(1:length(target_time));
                            else
                                resampled_data{end+1} = [col_data; repmat(col_data(end), length(target_time) - length(col_data), 1)];
                            end
                            resampled_names{end+1} = col_name;
                        end
                    end
                catch ME
                    fprintf('Error resampling column %s: %s\n', col_name, ME.message);
                    % Use original data if resampling fails
                    resampled_data{end+1} = col_data;
                    resampled_names{end+1} = col_name;
                end
            else
                % Non-numeric data - replicate for all time points
                resampled_data{end+1} = repmat({col_data}, length(target_time), 1);
                resampled_names{end+1} = col_name;
            end
        end
        
        % Create resampled table
        if ~isempty(resampled_data)
            resampled_table = table(resampled_data{:}, 'VariableNames', resampled_names);
        end
        
    catch ME
        fprintf('Error resampling data: %s\n', ME.message);
    end
end 