function data_table = extractFromCombinedSignalBus(combinedBus)
    % External function for extracting data from CombinedSignalBus - can be used in parallel processing
    % This function doesn't rely on config.verbosity
    
    data_table = table();
    
    try
        if isempty(combinedBus)
            fprintf('CombinedSignalBus is empty\n');
            return;
        end
        
        % Get all field names from the combined bus
        field_names = fieldnames(combinedBus);
        
        if isempty(field_names)
            fprintf('No fields found in CombinedSignalBus\n');
            return;
        end
        
        % Initialize data arrays
        all_data = {};
        var_names = {};
        
        % Get time data from the first field to determine expected length
        first_field = combinedBus.(field_names{1});
        if isstruct(first_field) && isfield(first_field, 'time')
            time_data = first_field.time;
            expected_length = length(time_data);
        else
            fprintf('Could not determine time data length from CombinedSignalBus\n');
            return;
        end
        
        % Add time column
        all_data{end+1} = time_data;
        var_names{end+1} = 'time';
        
        % Process each field
        for i = 1:length(field_names)
            field_name = field_names{i};
            field_value = combinedBus.(field_name);
            
            % Extract data from this field
            field_data = extractDataFromField(field_value, expected_length);
            
            if ~isempty(field_data)
                all_data = [all_data, field_data.data_cells];
                var_names = [var_names, field_data.var_names];
            end
        end
        
        % Create table
        if ~isempty(all_data)
            data_table = table(all_data{:}, 'VariableNames', var_names);
        end
        
    catch ME
        fprintf('Error extracting CombinedSignalBus data: %s\n', ME.message);
    end
end 