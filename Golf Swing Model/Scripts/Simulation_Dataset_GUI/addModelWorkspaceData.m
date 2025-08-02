function data_table = addModelWorkspaceData(data_table, simOut, num_rows)
    % External function for adding model workspace data - can be used in parallel processing
    % This function doesn't rely on config.verbosity
    
    try
        % Extract workspace outputs if available
        workspace_data = extractWorkspaceOutputs(simOut);
        
        if ~isempty(workspace_data)
            % Add workspace variables to the data table
            workspace_fields = fieldnames(workspace_data);
            
            for i = 1:length(workspace_fields)
                field_name = workspace_fields{i};
                field_value = workspace_data.(field_name);
                
                % Handle different data types
                if isnumeric(field_value)
                    if isscalar(field_value)
                        % Scalar value - replicate for all rows
                        data_table.(field_name) = repmat(field_value, num_rows, 1);
                    elseif isvector(field_value)
                        % Vector value - replicate for all rows
                        data_table.(field_name) = repmat(field_value(:)', num_rows, 1);
                    elseif ismatrix(field_value)
                        % Matrix value - flatten and replicate
                        flat_value = field_value(:)';
                        data_table.(field_name) = repmat(flat_value, num_rows, 1);
                    end
                elseif ischar(field_value)
                    % String value - replicate for all rows
                    data_table.(field_name) = repmat({field_value}, num_rows, 1);
                end
            end
        end
        
    catch ME
        fprintf('Error adding model workspace data: %s\n', ME.message);
    end
end 