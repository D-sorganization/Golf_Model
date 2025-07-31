function simIn = loadInputFile(simIn, input_file)
    % Load input file data into simulation
    try
        if ~exist(input_file, 'file')
            fprintf('Warning: Input file %s not found\n', input_file);
            return;
        end
        
        % Load the input file
        input_data = load(input_file);
        
        % Set variables from input file
        field_names = fieldnames(input_data);
        for i = 1:length(field_names)
            field_name = field_names{i};
            field_value = input_data.(field_name);
            
            try
                simIn = simIn.setVariable(field_name, field_value);
                fprintf('Loaded variable %s from input file\n', field_name);
            catch ME
                fprintf('Warning: Could not set variable %s: %s\n', field_name, ME.message);
            end
        end
        
    catch ME
        fprintf('ERROR: Failed to load input file %s: %s\n', input_file, ME.message);
        rethrow(ME);
    end
end 