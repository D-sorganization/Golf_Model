function test_robust_array_method()
    % Test the exact array creation method used in robust method
    
    fprintf('=== Testing Robust Method Array Creation ===\n');
    
    % Create config like robust method
    config = struct();
    config.model_name = 'GolfSwing3D_Kinetic';
    config.model_path = fullfile(pwd, '..', '..', 'Model', 'GolfSwing3D_Kinetic.slx');
    config.simulation_time = 0.1;
    config.enable_animation = false;
    config.input_file = '';
    config.use_signal_bus = true;
    config.use_logsout = true;
    config.use_simscape = true;
    
    % Create coefficients like robust method (70 coefficients)
    config.coefficient_values = rand(1, 70) * 10 - 5;
    config.num_simulations = 1;
    
    fprintf('Testing with 70 coefficients (like robust method)\n');
    
    try
        % Add model directory to path (like robust method)
        [model_dir, ~, ~] = fileparts(config.model_path);
        if ~isempty(model_dir)
            addpath(model_dir);
            fprintf('Added model directory to path: %s\n', model_dir);
        end
        
        % Create array exactly like robust method
        simInputs = Simulink.SimulationInput.empty(0, 1);
        
        for i = 1:1  % Just one trial like robust method
            trial = i;
            
            % Get coefficients for this trial (like robust method)
            if trial <= size(config.coefficient_values, 1)
                trial_coefficients = config.coefficient_values(trial, :);
            else
                trial_coefficients = config.coefficient_values(end, :);
            end
            
            % Ensure coefficients are numeric (like robust method)
            if iscell(trial_coefficients)
                trial_coefficients = cell2mat(trial_coefficients);
            end
            if ~isnumeric(trial_coefficients)
                trial_coefficients = double(trial_coefficients);
            end
            trial_coefficients = double(trial_coefficients);
            
            % Create SimulationInput object with proper error handling (like robust method)
            try
                simIn = Simulink.SimulationInput(config.model_name);
                
                % Set simulation parameters
                simIn = setModelParameters(simIn, config);
                simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);
                
                % Load input file if specified
                if isfield(config, 'input_file') && ~isempty(config.input_file) && exist(config.input_file, 'file')
                    simIn = loadInputFile(simIn, config.input_file);
                end
                
                % Validate the SimulationInput before adding to array (like robust method)
                if isa(simIn, 'Simulink.SimulationInput')
                    simInputs(i) = simIn;
                else
                    fprintf('Warning: Invalid SimulationInput created for trial %d\n', trial);
                    simInputs(i) = Simulink.SimulationInput(config.model_name);
                end
                
            catch ME
                fprintf('Error creating SimulationInput for trial %d: %s\n', trial, ME.message);
                simInputs(i) = Simulink.SimulationInput(config.model_name);
            end
        end
        
        % Validate the entire array (like robust method)
        if isempty(simInputs)
            error('No valid SimulationInput objects created');
        end
        
        fprintf('DEBUG: Created %d SimulationInput objects for parsim\n', length(simInputs));
        fprintf('DEBUG: simInputs class: %s\n', class(simInputs));
        fprintf('DEBUG: simInputs size: %s\n', mat2str(size(simInputs)));
        
        % Test parsim with the array (like robust method)
        fprintf('DEBUG: About to run parsim with %d simulation inputs\n', length(simInputs));
        fprintf('DEBUG: First simInput model: %s\n', simInputs(1).ModelName);
        
        simOuts = parsim(simInputs, ...
                       'TransferBaseWorkspaceVariables', 'on', ...
                       'AttachedFiles', {config.model_path}, ...
                       'ShowProgress', true, ...
                       'StopOnError', 'off');
        
        fprintf('✓ Parsim successful with robust method array creation!\n');
        
    catch ME
        fprintf('✗ Parsim FAILED with robust method array creation: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end 