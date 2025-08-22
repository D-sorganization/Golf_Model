% Test script to run a minimal simulation and identify where it fails
% This will help isolate the "system cannot find the path specified" error

try
    fprintf('=== TESTING MINIMAL SIMULATION ===\n');

    % Test 1: Check if we can create a basic Simulink.SimulationInput
    fprintf('Testing Simulink.SimulationInput creation...\n');

    model_path = '../../Model/GolfSwing3D_Kinetic.slx';
    if ~exist(model_path, 'file')
        error('Model file not found at: %s', model_path);
    end

    fprintf('✓ Model file found\n');

    % Test 2: Try to create SimulationInput
    try
        sim_input = Simulink.SimulationInput(model_path);
        fprintf('✓ Simulink.SimulationInput created successfully\n');
    catch ME
        fprintf('✗ Failed to create Simulink.SimulationInput: %s\n', ME.message);
        return;
    end

    % Test 3: Try to set basic parameters
    try
        sim_input = sim_input.setModelParameter('StopTime', '0.1'); % Very short simulation
        fprintf('✓ Basic parameters set successfully\n');
    catch ME
        fprintf('✗ Failed to set basic parameters: %s\n', ME.message);
        return;
    end

    % Test 4: Try to run a very short simulation
    fprintf('Attempting to run minimal simulation...\n');
    try
        sim_output = sim(sim_input);
        fprintf('✓ Minimal simulation completed successfully!\n');
        fprintf('  Simulation time: %f seconds\n', sim_output.tout(end));
    catch ME
        fprintf('✗ Simulation failed: %s\n', ME.message);

        % Check if it's a system path error
        if contains(ME.message, 'system cannot find the path specified')
            fprintf('  This is the "system cannot find the path specified" error!\n');

            % Check if it's related to Python exports
            fprintf('  Checking if this is related to Python export functions...\n');

            % Test the Python export functions directly
            testPythonExports();
        end
    end

catch ME
    fprintf('ERROR in test script: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== MINIMAL SIMULATION TEST COMPLETE ===\n');

function testPythonExports()
% Test the Python export functions that might be causing the system path error

fprintf('  Testing Python export functions...\n');

% Create some dummy data
dummy_data = struct();
dummy_data.test_field = [1, 2, 3, 4, 5];

% Test each export function
export_functions = {'exportToPyTorch', 'exportToTensorFlow', 'exportToNumPy', 'exportToPickle'};

for i = 1:length(export_functions)
    func_name = export_functions{i};
    if exist(func_name, 'file')
        fprintf('    Testing %s...\n', func_name);
        try
            % Call with minimal data
            feval(func_name, dummy_data, 'test_output');
            fprintf('      ✓ %s completed without error\n', func_name);
        catch ME
            fprintf('      ✗ %s failed: %s\n', func_name, ME.message);
            if contains(ME.message, 'system cannot find the path specified')
                fprintf('        This is the source of the system path error!\n');
            end
        end
    else
        fprintf('    %s function not found\n', func_name);
    end
end
end
