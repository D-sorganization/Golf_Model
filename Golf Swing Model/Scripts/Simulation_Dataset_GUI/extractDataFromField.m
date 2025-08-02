function field_data = extractDataFromField(field_value, expected_length)
    % External function for extracting data from a field - can be used in parallel processing
    % This function handles 3x3xN matrices by flattening them into 9 columns
    
    field_data = struct('data_cells', {}, 'var_names', {});
    
    try
        if isempty(field_value)
            return;
        end
        
        % Initialize arrays
        data_cells = {};
        var_names = {};
        
        % Handle different data types
        if isstruct(field_value)
            % Nested structure - extract from nested struct
            nested_data = extractFromNestedStruct(field_value, '', []);
            if ~isempty(nested_data)
                data_cells = [data_cells, nested_data.data_cells];
                var_names = [var_names, nested_data.var_names];
            end
        elseif isnumeric(field_value)
            % Numeric data - handle different dimensions
            numeric_data = field_value;
            num_elements = numel(numeric_data);
            
            if isvector(numeric_data)
                % Vector data
                if length(numeric_data) == expected_length
                    data_cells{end+1} = numeric_data(:);
                    var_names{end+1} = 'data';
                end
            elseif ismatrix(numeric_data) && size(numeric_data, 1) == expected_length
                % Matrix data with correct number of rows
                num_cols = size(numeric_data, 2);
                for col = 1:num_cols
                    data_cells{end+1} = numeric_data(:, col);
                    var_names{end+1} = sprintf('col_%d', col);
                end
            elseif ndims(numeric_data) == 3 && all(size(numeric_data,1:2) == [3 3])
                % 3x3xN time series (e.g., inertia over time)
                n_steps = size(numeric_data, 3);
                if n_steps == expected_length
                    % Flatten each 3x3 matrix at each timestep into 9 columns
                    flat_matrix = reshape(permute(numeric_data, [3 1 2]), n_steps, 9);
                    for idx = 1:9
                        [row, col] = ind2sub([3,3], idx);
                        data_cells{end+1} = flat_matrix(:,idx);
                        var_names{end+1} = sprintf('I%d%d', row, col);
                    end
                end
            elseif num_elements == 6
                % 6 ELEMENT DATA (e.g., 6DOF pose/twist)
                vector_data = numeric_data(:);  % Ensure column vector
                if length(vector_data) == 6
                    % Replicate for all time steps
                    replicated_data = repmat(vector_data, expected_length, 1);
                    data_cells{end+1} = replicated_data;
                    var_names{end+1} = 'pose_twist';
                end
            elseif num_elements == 3
                % 3 ELEMENT DATA (e.g., 3D vector)
                vector_data = numeric_data(:);  % Ensure column vector
                if length(vector_data) == 3
                    % Replicate for all time steps
                    replicated_data = repmat(vector_data, expected_length, 1);
                    data_cells{end+1} = replicated_data;
                    var_names{end+1} = 'vector_3d';
                end
            elseif num_elements == 9
                % 9 ELEMENT DATA (e.g., 3x3 matrix)
                matrix_data = numeric_data(:);  % Flatten to vector
                if length(matrix_data) == 9
                    % Replicate for all time steps
                    replicated_data = repmat(matrix_data, expected_length, 1);
                    data_cells{end+1} = replicated_data;
                    var_names{end+1} = 'matrix_3x3';
                end
            else
                % Other numeric data - try to handle
                if num_elements == expected_length
                    data_cells{end+1} = numeric_data(:);
                    var_names{end+1} = 'numeric_data';
                elseif num_elements > expected_length
                    % Truncate to expected length
                    data_cells{end+1} = numeric_data(1:expected_length);
                    var_names{end+1} = 'numeric_data_truncated';
                end
            end
        end
        
        % Return extracted data
        field_data.data_cells = data_cells;
        field_data.var_names = var_names;
        
    catch ME
        fprintf('Error extracting data from field: %s\n', ME.message);
    end
end 