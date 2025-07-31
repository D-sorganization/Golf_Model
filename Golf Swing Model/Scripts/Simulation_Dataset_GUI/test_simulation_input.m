% Test script to isolate the SimulationInput creation issue
% This script tests different ways of creating SimulationInput objects

fprintf('Testing SimulationInput creation...\n');

% Test 1: Create SimulationInput with model name only
try
    fprintf('Test 1: Creating SimulationInput with model name only...\n');
    simIn1 = Simulink.SimulationInput('GolfSwing3D_Kinetic');
    fprintf('✓ Successfully created SimulationInput with model name\n');
    
    % Try to run simulation
    fprintf('Attempting to run simulation with model name...\n');
    simOut1 = sim(simIn1);
    fprintf('✓ Simulation with model name completed successfully\n');
    
catch ME
    fprintf('✗ Failed with model name: %s\n', ME.message);
end

% Test 2: Create SimulationInput with full path
try
    fprintf('\nTest 2: Creating SimulationInput with full path...\n');
    model_path = fullfile(pwd, '..', '..', 'Model', 'GolfSwing3D_Kinetic.slx');
    fprintf('Model path: %s\n', model_path);
    
    if exist(model_path, 'file')
        fprintf('✓ Model file exists\n');
        simIn2 = Simulink.SimulationInput(model_path);
        fprintf('✓ Successfully created SimulationInput with full path\n');
        
        % Try to run simulation
        fprintf('Attempting to run simulation with full path...\n');
        simOut2 = sim(simIn2);
        fprintf('✓ Simulation with full path completed successfully\n');
    else
        fprintf('✗ Model file not found at: %s\n', model_path);
    end
    
catch ME
    fprintf('✗ Failed with full path: %s\n', ME.message);
end

% Test 3: Check if model is loaded in memory
try
    fprintf('\nTest 3: Checking if model is loaded...\n');
    if bdIsLoaded('GolfSwing3D_Kinetic')
        fprintf('✓ Model is loaded in memory\n');
    else
        fprintf('✗ Model is not loaded in memory\n');
        
        % Try to load the model
        fprintf('Attempting to load model...\n');
        load_system('GolfSwing3D_Kinetic');
        fprintf('✓ Model loaded successfully\n');
    end
catch ME
    fprintf('✗ Error checking/loading model: %s\n', ME.message);
end

fprintf('\nTest completed.\n'); 