function checkSimulationOutput(model_name)
    % Check what's actually in the simulation output
    fprintf('=== Simulation Output Check ===\n');
    fprintf('Model: %s\n\n', model_name);
    
    % Load model if needed
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end
    
    % Set minimal simulation parameters
    set_param(model_name, 'StopTime', '0.05');
    set_param(model_name, 'Solver', 'ode23t');
    set_param(model_name, 'RelTol', '1e-2');
    set_param(model_name, 'AbsTol', '1e-3');
    
    fprintf('Running very short simulation (0.05s)...\n');
    tic;
    simOut = sim(model_name);
    sim_time = toc;
    
    fprintf('Simulation completed in %.3f seconds\n\n', sim_time);
    
    % Examine the simulation output structure
    fprintf('Simulation output fields:\n');
    fprintf('------------------------\n');
    
    if isstruct(simOut)
        fields = fieldnames(simOut);
        fprintf('Total fields: %d\n', length(fields));
        for i = 1:length(fields)
            field_name = fields{i};
            field_value = simOut.(field_name);
            
            if isempty(field_value)
                fprintf('  %s: [empty]\n', field_name);
            elseif isnumeric(field_value)
                if isscalar(field_value)
                    fprintf('  %s: %g\n', field_name, field_value);
                else
                    fprintf('  %s: [%s] - %s\n', field_name, mat2str(size(field_value)), class(field_value));
                end
            elseif ischar(field_value)
                fprintf('  %s: "%s"\n', field_name, field_value);
            elseif iscell(field_value)
                fprintf('  %s: cell array [%s]\n', field_name, mat2str(size(field_value)));
            elseif isa(field_value, 'Simulink.SimulationData.Dataset')
                fprintf('  %s: Dataset with %d elements\n', field_name, field_value.numElements);
            else
                fprintf('  %s: %s [%s]\n', field_name, class(field_value), mat2str(size(field_value)));
            end
        end
    else
        fprintf('simOut is not a struct, it is: %s\n', class(simOut));
    end
    
    % Check for specific expected fields
    fprintf('\nChecking for expected fields:\n');
    fprintf('-----------------------------\n');
    
    expected_fields = {'tout', 'yout', 'logsout', 'xout', 'xFinal', 'yFinal'};
    for field = expected_fields
        if isfield(simOut, field{1})
            fprintf('✓ %s: found\n', field{1});
        else
            fprintf('✗ %s: not found\n', field{1});
        end
    end
    
    % Check for any dataset-like objects
    fprintf('\nChecking for dataset objects:\n');
    fprintf('-----------------------------\n');
    
    if isstruct(simOut)
        fields = fieldnames(simOut);
        for i = 1:length(fields)
            field_name = fields{i};
            field_value = simOut.(field_name);
            
            if isa(field_value, 'Simulink.SimulationData.Dataset')
                fprintf('✓ Dataset found: %s with %d elements\n', field_name, field_value.numElements);
                
                % List first few elements
                for j = 1:min(5, field_value.numElements)
                    element = field_value{j};
                    if isprop(element, 'Name')
                        fprintf('    - %s\n', element.Name);
                    else
                        fprintf('    - Element %d\n', j);
                    end
                end
                if field_value.numElements > 5
                    fprintf('    ... and %d more\n', field_value.numElements - 5);
                end
            end
        end
    end
    
    fprintf('\n=== Output Check Complete ===\n');
end 