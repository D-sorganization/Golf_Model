function test_parsim_input()
    % Diagnostic script to test parsim input creation
    % This will help identify what's causing the "Input matrix must be a numeric array" error
    
    fprintf('=== Testing Parsim Input Creation ===\n');
    
    % Create a minimal test configuration
    config = struct();
    config.model_name = 'GolfSwing3D_Kinetic';
    config.model_path = fullfile(pwd, '..', '..', 'Model', 'GolfSwing3D_Kinetic.slx');
    config.simulation_time = 0.1;  % Very short for testing
    config.coefficient_values = rand(1, 189) * 100 - 50;  % Single trial
    
    fprintf('Configuration:\n');
    fprintf('  Model: %s\n', config.model_name);
    fprintf('  Model path: %s\n', config.model_path);
    fprintf('  Coefficients: %d values\n', length(config.coefficient_values));
    
    % Check if model exists
    if ~exist(config.model_path, 'file')
        fprintf('ERROR: Model file not found: %s\n', config.model_path);
        return;
    end
    
    % Test 1: Create a single SimulationInput
    fprintf('\n--- Test 1: Single SimulationInput Creation ---\n');
    try
        simIn = Simulink.SimulationInput(config.model_name);
        fprintf('✅ Successfully created SimulationInput with model name\n');
        fprintf('  ModelName: %s\n', simIn.ModelName);
        
        % Test setting parameters
        simIn = setModelParameters(simIn, config);
        fprintf('✅ Successfully set model parameters\n');
        
        % Test setting coefficients
        simIn = setPolynomialCoefficients(simIn, config.coefficient_values, config);
        fprintf('✅ Successfully set polynomial coefficients\n');
        
        fprintf('✅ Single SimulationInput creation successful\n');
        
    catch ME
        fprintf('❌ Single SimulationInput creation failed: %s\n', ME.message);
        return;
    end
    
    % Test 2: Create array of SimulationInput objects
    fprintf('\n--- Test 2: Array of SimulationInput Objects ---\n');
    try
        trial_indices = [1, 2];  % Test with 2 trials
        simInputs = Simulink.SimulationInput.empty(0, length(trial_indices));
        
        for i = 1:length(trial_indices)
            trial = trial_indices(i);
            
            % Create SimulationInput object
            simIn = Simulink.SimulationInput(config.model_name);
            
            % Set simulation parameters
            simIn = setModelParameters(simIn, config);
            simIn = setPolynomialCoefficients(simIn, config.coefficient_values, config);
            
            simInputs(i) = simIn;
            fprintf('✅ Created SimulationInput %d\n', i);
        end
        
        fprintf('✅ Array of SimulationInput objects created successfully\n');
        fprintf('  Array size: %s\n', mat2str(size(simInputs)));
        fprintf('  Array class: %s\n', class(simInputs));
        
        % Test array properties
        for i = 1:length(simInputs)
            fprintf('  simInputs(%d).ModelName: %s\n', i, simInputs(i).ModelName);
        end
        
    catch ME
        fprintf('❌ Array of SimulationInput objects failed: %s\n', ME.message);
        return;
    end
    
    % Test 3: Test parsim with single SimulationInput
    fprintf('\n--- Test 3: Parsim with Single SimulationInput ---\n');
    try
        fprintf('Running parsim with single SimulationInput...\n');
        simOut = parsim(simIn, 'ShowProgress', true, 'StopOnError', 'off');
        fprintf('✅ Parsim with single SimulationInput successful\n');
        fprintf('  Output class: %s\n', class(simOut));
        
    catch ME
        fprintf('❌ Parsim with single SimulationInput failed: %s\n', ME.message);
        fprintf('  Error details: %s\n', ME.message);
    end
    
    % Test 4: Test parsim with array of SimulationInput objects
    fprintf('\n--- Test 4: Parsim with Array of SimulationInput Objects ---\n');
    try
        fprintf('Running parsim with array of SimulationInput objects...\n');
        fprintf('  Array size: %s\n', mat2str(size(simInputs)));
        fprintf('  Array class: %s\n', class(simInputs));
        
        % Check each SimulationInput in the array
        for i = 1:length(simInputs)
            fprintf('  simInputs(%d): class=%s, ModelName=%s\n', ...
                i, class(simInputs(i)), simInputs(i).ModelName);
        end
        
        simOuts = parsim(simInputs, 'ShowProgress', true, 'StopOnError', 'off');
        fprintf('✅ Parsim with array of SimulationInput objects successful\n');
        fprintf('  Output class: %s\n', class(simOuts));
        fprintf('  Output size: %s\n', mat2str(size(simOuts)));
        
    catch ME
        fprintf('❌ Parsim with array of SimulationInput objects failed: %s\n', ME.message);
        fprintf('  Error details: %s\n', ME.message);
        
        % Additional debugging
        fprintf('\n--- Additional Debugging ---\n');
        fprintf('Checking if simInputs is valid for parsim...\n');
        
        % Check if simInputs is a valid array
        if ~isvector(simInputs)
            fprintf('  simInputs is not a vector: size = %s\n', mat2str(size(simInputs)));
        end
        
        % Check each element
        for i = 1:length(simInputs)
            if ~isa(simInputs(i), 'Simulink.SimulationInput')
                fprintf('  simInputs(%d) is not a Simulink.SimulationInput: %s\n', i, class(simInputs(i)));
            end
        end
        
        % Try converting to cell array
        try
            simInputsCell = num2cell(simInputs);
            fprintf('  Converting to cell array: %s\n', mat2str(size(simInputsCell)));
            simOuts = parsim(simInputsCell, 'ShowProgress', true, 'StopOnError', 'off');
            fprintf('✅ Parsim with cell array successful\n');
        catch ME2
            fprintf('❌ Parsim with cell array also failed: %s\n', ME2.message);
        end
    end
    
    fprintf('\n=== Test Complete ===\n');
end 