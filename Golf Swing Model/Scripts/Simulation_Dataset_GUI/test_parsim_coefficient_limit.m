function test_parsim_coefficient_limit()
    % Test to find the coefficient limit where parsim fails
    
    fprintf('=== Testing Parsim Coefficient Limits ===\n');
    
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
    
    % Test different coefficient counts
    coefficient_counts = [7, 14, 21, 35, 49, 70, 105, 140, 189];
    
    for i = 1:length(coefficient_counts)
        num_coeffs = coefficient_counts(i);
        fprintf('\n--- Test %d: %d coefficients (%d joints) ---\n', i, num_coeffs, ceil(num_coeffs/7));
        
        % Create coefficients
        config.coefficient_values = rand(1, num_coeffs) * 10 - 5;
        config.num_simulations = 1;
        
        try
            % Add model directory to path
            [model_dir, ~, ~] = fileparts(config.model_path);
            if ~isempty(model_dir)
                addpath(model_dir);
            end
            
            % Create SimulationInput
            simIn = Simulink.SimulationInput(config.model_name);
            simIn = setModelParameters(simIn, config);
            simIn = setPolynomialCoefficients(simIn, config.coefficient_values, config);
            
            fprintf('  Created SimulationInput with %d variables\n', length(simIn.Variables));
            
            % Test parsim
            simOut = parsim(simIn, ...
                           'TransferBaseWorkspaceVariables', 'on', ...
                           'AttachedFiles', {config.model_path}, ...
                           'ShowProgress', false, ...
                           'StopOnError', 'off');
            
            fprintf('  ✓ Parsim successful with %d coefficients\n', num_coeffs);
            
        catch ME
            fprintf('  ✗ Parsim FAILED with %d coefficients: %s\n', num_coeffs, ME.message);
            fprintf('  This appears to be the breaking point!\n');
            break;
        end
    end
    
    fprintf('\n=== Coefficient Limit Test Complete ===\n');
end 