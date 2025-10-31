function data_table = addModelWorkspaceData(data_table, simOut, num_rows)
% Extract model workspace variables and add as constant columns
% These include segment lengths, masses, inertias, and other model parameters

try
    % Get model workspace from simulation output
    model_name = simOut.SimulationMetadata.ModelInfo.ModelName;

    % Check if model is loaded
    if ~bdIsLoaded(model_name)
        fprintf('Warning: Model %s not loaded, skipping workspace data\n', model_name);
        return;
    end

    model_workspace = get_param(model_name, 'ModelWorkspace');
    try
        variables = model_workspace.getVariableNames;
    catch
        % For older MATLAB versions, try alternative method
        try
            variables = model_workspace.whos;
            variables = {variables.name};
        catch
            fprintf('Warning: Could not retrieve model workspace variable names\n');
            return;
        end
    end

    if length(variables) > 0
        fprintf('Adding %d model workspace variables to CSV...\n', length(variables));
    else
        fprintf('No model workspace variables found\n');
        return;
    end

    for i = 1:length(variables)
        var_name = variables{i};

        try
            var_value = model_workspace.getVariable(var_name);

            % Use the specialized extractConstantMatrixData function for proper handling
            % of inertia matrices (9-column vectors) and other matrix data
            if isnumeric(var_value)
                % Use extractConstantMatrixData for proper matrix handling
                [constant_signals] = extractConstantMatrixData(var_value, var_name, []);

                if ~isempty(constant_signals)
                    % Add each extracted signal to the data table
                    addSignalsToTable(data_table, constant_signals, num_rows, var_name);
                end

            elseif isa(var_value, 'Simulink.Parameter')
                % Handle Simulink Parameters
                param_val = var_value.Value;
                if isnumeric(param_val)
                    % Use extractConstantMatrixData for Simulink parameters too
                    [constant_signals] = extractConstantMatrixData(param_val, var_name, []);

                    if ~isempty(constant_signals)
                        addSignalsToTable(data_table, constant_signals, num_rows, var_name);
                    end
                end
            end

        catch ME
            % Skip variables that can't be extracted
            fprintf('Warning: Could not extract variable %s: %s\n', var_name, ME.message);
        end
    end

catch ME
    fprintf('Warning: Could not access model workspace: %s\n', ME.message);
end
end

function addSignalsToTable(data_table, constant_signals, num_rows, var_name)
% Helper function to add extracted signals to the data table
for j = 1:length(constant_signals)
    signal = constant_signals{j};
    column_name = sprintf('model_%s', signal.name);

    % Ensure the data has the right length
    if length(signal.data) == num_rows
        data_table.(column_name) = signal.data;
    elseif length(signal.data) == 1
        % Replicate single value to match table length
        data_table.(column_name) = repmat(signal.data, num_rows, 1);
    else
        % Resize data to match table length (interpolation if needed)
        indices = round(linspace(1, length(signal.data), num_rows));
        data_table.(column_name) = signal.data(indices);
    end
end
fprintf('  Added %d columns for %s\n', length(constant_signals), var_name);
end
