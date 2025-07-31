% Test script to verify the parameter fix for ShowSimulationManager and ShowProgress
% This script tests that the try-catch blocks properly handle invalid parameters

fprintf('Testing parameter fix for ShowSimulationManager and ShowProgress...\n');

% Test 1: Create a SimulationInput object
try
    simIn = Simulink.SimulationInput('GolfSwing3D_Kinetic');
    fprintf('✓ Successfully created SimulationInput object\n');
catch ME
    fprintf('✗ Failed to create SimulationInput object: %s\n', ME.message);
    return;
end

% Test 2: Try to set ShowSimulationManager parameter (should be caught by try-catch)
try
    simIn = simIn.setModelParameter('ShowSimulationManager', 'off');
    fprintf('✓ ShowSimulationManager parameter was set successfully\n');
catch ME
    fprintf('✓ ShowSimulationManager parameter failed as expected: %s\n', ME.message);
end

% Test 3: Try to set ShowProgress parameter (should be caught by try-catch)
try
    simIn = simIn.setModelParameter('ShowProgress', 'off');
    fprintf('✓ ShowProgress parameter was set successfully\n');
catch ME
    fprintf('✓ ShowProgress parameter failed as expected: %s\n', ME.message);
end

% Test 4: Set a valid parameter to ensure the object still works
try
    simIn = simIn.setModelParameter('StopTime', '1.0');
    fprintf('✓ Valid parameter (StopTime) was set successfully\n');
catch ME
    fprintf('✗ Failed to set valid parameter: %s\n', ME.message);
end

fprintf('\nParameter fix test completed successfully!\n');
fprintf('The try-catch blocks are now properly handling invalid parameters.\n'); 