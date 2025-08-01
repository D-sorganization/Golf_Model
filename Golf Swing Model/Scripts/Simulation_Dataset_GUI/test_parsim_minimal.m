function test_parsim_minimal()
    % Minimal test to isolate parsim issue
    
    fprintf('=== Minimal Parsim Test ===\n');
    
    % Create config like main GUI
    config = struct();
    config.model_name = 'GolfSwing3D_Kinetic';
    config.model_path = fullfile(pwd, '..', '..', 'Model', 'GolfSwing3D_Kinetic.slx');
    config.simulation_time = 0.1;
    config.enable_animation = false;
    config.input_file = '';
    config.use_signal_bus = true;
    config.use_logsout = true;
    config.use_simscape = true;
    
    % Create minimal coefficients (just 7 for one joint)
    config.coefficient_values = rand(1, 7) * 10 - 5;
    config.num_simulations = 1;
    
    fprintf('Testing with minimal configuration:\n');
    fprintf('  Model: %s\n', config.model_name);
    fprintf('  Coefficients: %d\n', length(config.coefficient_values));
    
    try
        % Test 1: Create SimulationInput exactly like main GUI
        fprintf('\n--- Test 1: Create SimulationInput like main GUI ---\n');
        
        % Add model directory to path (like main GUI)
        [model_dir, ~, ~] = fileparts(config.model_path);
        if ~isempty(model_dir)
            addpath(model_dir);
            fprintf('Added model directory to path: %s\n', model_dir);
        end
        
        % Create SimulationInput exactly like main GUI
        simIn = Simulink.SimulationInput(config.model_name);
        
        % Set simulation parameters
        simIn = setModelParameters(simIn, config);
        
        % Set polynomial coefficients
        simIn = setPolynomialCoefficients(simIn, config.coefficient_values, config);
        
        fprintf('✓ SimulationInput created successfully\n');
        fprintf('  ModelName: %s\n', simIn.ModelName);
        fprintf('  ModelParameters: %d parameters\n', length(simIn.ModelParameters));
        fprintf('  Variables: %d variables\n', length(simIn.Variables));
        
        % Test 2: Test parsim with single SimulationInput
        fprintf('\n--- Test 2: Parsim with single SimulationInput ---\n');
        
        simOut = parsim(simIn, ...
                       'TransferBaseWorkspaceVariables', 'on', ...
                       'AttachedFiles', {config.model_path}, ...
                       'ShowProgress', true, ...
                       'StopOnError', 'off');
        
        fprintf('✓ Parsim with single SimulationInput successful\n');
        
        % Test 3: Test parsim with array of SimulationInput objects
        fprintf('\n--- Test 3: Parsim with array of SimulationInput objects ---\n');
        
        % Create array like robust method
        simInputs = Simulink.SimulationInput.empty(0, 1);
        simInputs(1) = simIn;
        
        fprintf('Created array with %d SimulationInput objects\n', length(simInputs));
        
        simOuts = parsim(simInputs, ...
                        'TransferBaseWorkspaceVariables', 'on', ...
                        'AttachedFiles', {config.model_path}, ...
                        'ShowProgress', true, ...
                        'StopOnError', 'off');
        
        fprintf('✓ Parsim with array of SimulationInput objects successful\n');
        fprintf('  Results: %d simulation outputs\n', length(simOuts));
        
        fprintf('\n=== All Tests PASSED ===\n');
        
    catch ME
        fprintf('\n=== Test FAILED ===\n');
        fprintf('Error: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end 