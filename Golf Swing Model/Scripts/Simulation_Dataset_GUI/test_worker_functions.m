% Test script to verify worker functions are accessible
fprintf('=== Testing Worker Functions ===\n\n');

% Test 1: Check if functions are available in current workspace
fprintf('Test 1: Checking function availability...\n');
functions_to_test = {'setModelParameters', 'setPolynomialCoefficients', 'loadInputFile', 'getPolynomialParameterInfo'};

for i = 1:length(functions_to_test)
    if exist(functions_to_test{i}, 'file')
        fprintf('✓ %s is available\n', functions_to_test{i});
    else
        fprintf('✗ %s is NOT available\n', functions_to_test{i});
    end
end

% Test 2: Try to load the simulation_worker_functions file
fprintf('\nTest 2: Testing simulation_worker_functions loading...\n');
try
    simulation_worker_functions;
    fprintf('✓ simulation_worker_functions loaded successfully\n');
catch ME
    fprintf('✗ simulation_worker_functions failed to load: %s\n', ME.message);
end

% Test 3: Test function calls
fprintf('\nTest 3: Testing function calls...\n');
try
    % Test setModelParameters
    test_config = struct();
    test_config.simulation_time = 1.0;
    test_config.enable_animation = false;
    
    simIn = Simulink.SimulationInput('GolfSwing3D_Kinetic');
    simIn = setModelParameters(simIn, test_config);
    fprintf('✓ setModelParameters call successful\n');
catch ME
    fprintf('✗ setModelParameters call failed: %s\n', ME.message);
end

fprintf('\nTest completed!\n'); 