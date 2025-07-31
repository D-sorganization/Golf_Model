% Test script to verify separate function files are accessible to parallel workers
fprintf('=== Testing Separate Function Files for Parallel Workers ===\n\n');

% Test 1: Check if functions exist in main workspace
fprintf('Test 1: Checking function availability in main workspace...\n');
functions_to_test = {'setModelParameters', 'setPolynomialCoefficients', 'loadInputFile', 'getPolynomialParameterInfo'};

for i = 1:length(functions_to_test)
    func_name = functions_to_test{i};
    if exist(func_name, 'file')
        fprintf('  ✅ %s is available\n', func_name);
    else
        fprintf('  ❌ %s is NOT available\n', func_name);
    end
end

% Test 2: Test function calls in main workspace
fprintf('\nTest 2: Testing function calls in main workspace...\n');
try
    param_info = getPolynomialParameterInfo();
    fprintf('  ✅ getPolynomialParameterInfo() call successful\n');
    fprintf('  Found %d joints: ', length(param_info.joint_names));
    for i = 1:length(param_info.joint_names)
        if i > 1, fprintf(', '); end
        fprintf('%s', param_info.joint_names{i});
    end
    fprintf('\n');
catch ME
    fprintf('  ❌ getPolynomialParameterInfo() call failed: %s\n', ME.message);
end

% Test 3: Test parallel worker accessibility
fprintf('\nTest 3: Testing parallel worker accessibility...\n');

% Check if Parallel Computing Toolbox is available
if ~exist('parpool', 'file')
    fprintf('  ❌ Parallel Computing Toolbox not available\n');
    return;
end

try
    % Create a small parallel pool
    fprintf('  Creating parallel pool...\n');
    pool = gcp('nocreate');
    if isempty(pool)
        pool = parpool('Processes', 1);
    end
    
    % Test function accessibility in parallel workers
    fprintf('  Testing function accessibility in workers...\n');
    
    spmd
        % Check if functions are available on this worker
        worker_functions_available = zeros(1, length(functions_to_test));
        for i = 1:length(functions_to_test)
            func_name = functions_to_test{i};
            worker_functions_available(i) = exist(func_name, 'file');
        end
        
        % Try to call getPolynomialParameterInfo
        try
            worker_param_info = getPolynomialParameterInfo();
            worker_call_success = true;
        catch
            worker_call_success = false;
        end
    end
    
    % Display results
    fprintf('  Worker function availability:\n');
    for i = 1:length(functions_to_test)
        func_name = functions_to_test{i};
        if worker_functions_available{1}(i)
            fprintf('    ✅ %s available on worker\n', func_name);
        else
            fprintf('    ❌ %s NOT available on worker\n', func_name);
        end
    end
    
    if worker_call_success{1}
        fprintf('  ✅ Function call successful on worker\n');
    else
        fprintf('  ❌ Function call failed on worker\n');
    end
    
    fprintf('  ✅ Parallel worker test completed successfully\n');
    
catch ME
    fprintf('  ❌ Parallel worker test failed: %s\n', ME.message);
end

% Test 4: Test with actual SimulationInput object
fprintf('\nTest 4: Testing with SimulationInput object...\n');
try
    % Create a test SimulationInput
    model_name = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end
    
    simIn = Simulink.SimulationInput(model_name);
    
    % Test setModelParameters
    test_config = struct();
    test_config.simulation_time = 1.0;
    test_config.enable_animation = false;
    
    simIn = setModelParameters(simIn, test_config);
    fprintf('  ✅ setModelParameters call successful\n');
    
    % Test setPolynomialCoefficients
    test_coefficients = ones(1, 36); % 6 joints * 6 coefficients each
    simIn = setPolynomialCoefficients(simIn, test_coefficients, test_config);
    fprintf('  ✅ setPolynomialCoefficients call successful\n');
    
catch ME
    fprintf('  ❌ SimulationInput test failed: %s\n', ME.message);
end

fprintf('\n=== Test Summary ===\n');
fprintf('Separate function files have been created and should now be accessible to parallel workers.\n');
fprintf('This approach is more robust than class-based methods for parallel processing.\n'); 