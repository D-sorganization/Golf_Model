function simscape_data = extractSimscapeDataRecursive(simlog)
    % External function for extracting Simscape data recursively - can be used in parallel processing
    % This function doesn't rely on handles
    
    simscape_data = table();
    
    try
        if isempty(simlog)
            fprintf('Simlog is empty\n');
            return;
        end
        
        % Recursively collect all series data using primary traversal method
        [time_data, all_signals] = traverseSimlogNode(simlog, '');
        
        if isempty(time_data) || isempty(all_signals)
            fprintf('No data found in Simscape logs\n');
            return;
        end
        
        % Create table from collected signals
        if ~isempty(all_signals)
            % Initialize data arrays
            all_data = {time_data};
            var_names = {'time'};
            
            % Add each signal
            for i = 1:length(all_signals)
                signal = all_signals{i};
                all_data{end+1} = signal.data;
                var_names{end+1} = signal.name;
            end
            
            % Create table
            simscape_data = table(all_data{:}, 'VariableNames', var_names);
        end
        
    catch ME
        fprintf('Error extracting Simscape data recursively: %s\n', ME.message);
    end
end 