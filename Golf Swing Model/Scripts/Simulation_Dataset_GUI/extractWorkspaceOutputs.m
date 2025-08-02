function workspace_data = extractWorkspaceOutputs(simOut)
    % External function for extracting workspace outputs - can be used in parallel processing
    % This function doesn't rely on config.verbosity
    
    workspace_data = struct();
    
    try
        % Check if workspace outputs are available
        if isprop(simOut, 'yout') && ~isempty(simOut.yout)
            % Extract from yout structure
            yout = simOut.yout;
            yout_fields = fieldnames(yout);
            
            for i = 1:length(yout_fields)
                field_name = yout_fields{i};
                field_value = yout.(field_name);
                
                % Only include numeric data
                if isnumeric(field_value)
                    workspace_data.(field_name) = field_value;
                end
            end
        end
        
        % Check for other workspace variables
        if isprop(simOut, 'xout') && ~isempty(simOut.xout)
            workspace_data.xout = simOut.xout;
        end
        
        % Check for custom workspace variables
        if isprop(simOut, 'CustomWorkspaceVariables')
            custom_vars = simOut.CustomWorkspaceVariables;
            if ~isempty(custom_vars)
                custom_fields = fieldnames(custom_vars);
                for i = 1:length(custom_fields)
                    field_name = custom_fields{i};
                    field_value = custom_vars.(field_name);
                    
                    % Only include numeric data
                    if isnumeric(field_value)
                        workspace_data.(field_name) = field_value;
                    end
                end
            end
        end
        
    catch ME
        fprintf('Error extracting workspace outputs: %s\n', ME.message);
    end
end