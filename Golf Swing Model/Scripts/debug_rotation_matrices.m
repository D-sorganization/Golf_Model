function debug_rotation_matrices()
% debug_rotation_matrices.m
% Debug script to investigate rotation matrix extraction issues

fprintf('=== Debugging Rotation Matrix Extraction ===\n\n');

try
    % Test configuration
    config = struct();
    config.num_simulations = 1;
    config.simulation_time = 0.1;
    config.sample_rate = 5;
    config.model_name = 'GolfSwing3D_Kinetic';
    
    % Generate random polynomial coefficients
    polynomial_coeffs = generateRandomPolynomialCoefficients();
    
    % Create simulation input
    simInput = Simulink.SimulationInput(config.model_name);
    simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));
    simInput = setPolynomialVariables(simInput, polynomial_coeffs);
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    % Run simulation
    fprintf('Running test simulation...\n');
    simOut = sim(simInput);
    
    fprintf('✓ Simulation completed\n\n');
    
    % Analyze simulation output structure
    fprintf('=== Simulation Output Analysis ===\n');
    fprintf('Fields in simOut:\n');
    fields = fieldnames(simOut);
    for i = 1:length(fields)
        fprintf('  %s\n', fields{i});
    end
    fprintf('\n');
    
    % Check for logsout
    if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
        fprintf('=== Logsout Analysis ===\n');
        logsout = simOut.logsout;
        fprintf('Number of logsout elements: %d\n', logsout.numElements);
        
        for i = 1:min(10, logsout.numElements) % Check first 10 elements
            try
                element = logsout.getElement(i);
                name = element.Name;
                data = element.Values.Data;
                time = element.Values.Time;
                
                fprintf('  Element %d: %s\n', i, name);
                fprintf('    Data size: %s\n', mat2str(size(data)));
                fprintf('    Time size: %s\n', mat2str(size(time)));
                
                % Check if this looks like a rotation matrix
                if ismatrix(data) && size(data, 2) == 3 && size(data, 1) > 1
                    fprintf('    *** Potential rotation matrix detected! ***\n');
                    fprintf('    First few values: %s\n', mat2str(data(1:min(3,size(data,1)), :), 3));
                end
                
            catch ME
                fprintf('    Error processing element %d: %s\n', i, ME.message);
            end
        end
    else
        fprintf('No logsout data found\n');
    end
    
    % Check for signal log structs
    fprintf('\n=== Signal Log Structs Analysis ===\n');
    for i = 1:length(fields)
        field = fields{i};
        if endsWith(field, 'Logs') && isstruct(simOut.(field))
            fprintf('Found log struct: %s\n', field);
            log_struct = simOut.(field);
            struct_fields = fieldnames(log_struct);
            
            % Look for rotation-related fields
            rotation_fields = {};
            for j = 1:length(struct_fields)
                subfield = struct_fields{j};
                if contains(lower(subfield), 'rotation') || contains(lower(subfield), 'transform')
                    rotation_fields{end+1} = subfield;
                end
            end
            
            if ~isempty(rotation_fields)
                fprintf('  Rotation-related fields found:\n');
                for j = 1:length(rotation_fields)
                    subfield = rotation_fields{j};
                    val = log_struct.(subfield);
                    fprintf('    %s: size %s\n', subfield, mat2str(size(val)));
                    
                    if isnumeric(val) && ismatrix(val) && size(val, 2) == 3 && size(val, 1) > 1
                        fprintf('      *** Potential rotation matrix! ***\n');
                        fprintf('      First few values: %s\n', mat2str(val(1:min(3,size(val,1)), :), 3));
                    end
                end
            else
                fprintf('  No rotation-related fields found\n');
            end
        end
    end
    
    % Check Simscape Results Explorer
    fprintf('\n=== Simscape Results Explorer Analysis ===\n');
    try
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run_id = runIDs(end);
            run_obj = Simulink.sdi.getRun(latest_run_id);
            all_signals = run_obj.getAllSignals;
            
            fprintf('Number of Simscape signals: %d\n', length(all_signals));
            
            % Look for rotation matrices more thoroughly
            rotation_signals = 0;
            matrix_signals = 0;
            
            fprintf('\nSearching for rotation matrices and 3x3 matrices...\n');
            
            for i = 1:length(all_signals)
                sig = all_signals(i);
                name = sig.Name;
                data = sig.Values.Data;
                
                % Check for 3x3 matrices (potential rotation matrices)
                if ismatrix(data) && size(data, 2) == 3 && size(data, 1) > 1
                    matrix_signals = matrix_signals + 1;
                    
                    % Check if this looks like a rotation matrix (orthogonal, det ≈ 1)
                    if size(data, 1) >= 3
                        sample_matrix = data(1:3, :);
                        det_val = det(sample_matrix);
                        orthogonality_error = norm(sample_matrix' * sample_matrix - eye(3), 'fro');
                        
                        if abs(det_val - 1) < 0.1 && orthogonality_error < 0.1
                            rotation_signals = rotation_signals + 1;
                            fprintf('  *** ROTATION MATRIX FOUND! *** Signal %d: %s\n', i, name);
                            fprintf('    Size: %s, Det: %.4f, Orthogonality error: %.4f\n', ...
                                mat2str(size(data)), det_val, orthogonality_error);
                            fprintf('    Sample matrix:\n');
                            fprintf('      %s\n', mat2str(sample_matrix, 4));
                        else
                            fprintf('  3x3 Matrix (not rotation): %s (size: %s, det: %.4f)\n', ...
                                name, mat2str(size(data)), det_val);
                        end
                    else
                        fprintf('  3x3 Matrix (short): %s (size: %s)\n', name, mat2str(size(data)));
                    end
                    
                    % Limit output to first 20 matrix signals
                    if matrix_signals >= 20
                        fprintf('  ... (showing first 20 matrix signals)\n');
                        break;
                    end
                end
                
                % Also check for signals with rotation-related keywords
                if contains(lower(name), 'rotation') || contains(lower(name), 'transform') || ...
                   contains(lower(name), 'orient') || contains(lower(name), 'pose')
                    fprintf('  Rotation-related signal: %s (size: %s)\n', name, mat2str(size(data)));
                end
            end
            
            fprintf('\nSummary:\n');
            fprintf('  Total signals: %d\n', length(all_signals));
            fprintf('  3x3 matrices found: %d\n', matrix_signals);
            fprintf('  Rotation matrices found: %d\n', rotation_signals);
            
            if rotation_signals == 0
                fprintf('\nNo rotation matrices found. Checking for alternative formats...\n');
                
                % Look for quaternions or other rotation representations
                quaternion_signals = 0;
                for i = 1:min(50, length(all_signals))
                    sig = all_signals(i);
                    name = sig.Name;
                    data = sig.Values.Data;
                    
                    if contains(lower(name), 'quat') || contains(lower(name), 'q_') || ...
                       (isvector(data) && length(data) == 4)
                        quaternion_signals = quaternion_signals + 1;
                        fprintf('  Quaternion signal: %s (size: %s)\n', name, mat2str(size(data)));
                    end
                end
                
                fprintf('  Quaternion signals found: %d\n', quaternion_signals);
            end
        else
            fprintf('No Simscape runs found\n');
        end
    catch ME
        fprintf('Error accessing Simscape Results Explorer: %s\n', ME.message);
    end
    
catch ME
    fprintf('✗ Debug error: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== Debug Complete ===\n');

end

function coeffs = generateRandomPolynomialCoefficients()
    % Generate random polynomial coefficients for different joints
    coeffs = struct();
    
    % Define joints that use polynomial inputs
    joints = {'Hip', 'Spine', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW'};
    
    for i = 1:length(joints)
        joint = joints{i};
        
        % Generate random coefficients for 3rd order polynomial (4 coefficients)
        % Range: -100 to 100 for reasonable torque values
        coeffs.([joint '_coeffs']) = (rand(1, 4) - 0.5) * 200;
    end
end

function simInput = setPolynomialVariables(simInput, coeffs)
    % Set polynomial coefficients as variables in the simulation input
    
    fields = fieldnames(coeffs);
    for i = 1:length(fields)
        field_name = fields{i};
        coeff_values = coeffs.(field_name);
        
        % Set as variable in simulation input
        simInput = simInput.setVariable(field_name, coeff_values);
    end
end 