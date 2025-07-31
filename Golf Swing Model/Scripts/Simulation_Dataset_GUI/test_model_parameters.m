% Test script to check if the issue is with setModelParameters
% This script tests the exact sequence from robust_dataset_generator.m

fprintf('Testing setModelParameters function...\n');

% Create a test configuration similar to test_robust_generator.m
config = struct();
config.model_name = 'GolfSwing3D_Kinetic';
config.simulation_time = 2.0;

try
    % Step 1: Create SimulationInput object
    fprintf('Step 1: Creating SimulationInput object...\n');
    simIn = Simulink.SimulationInput(config.model_name);
    fprintf('✓ Created SimulationInput object\n');
    
    % Step 2: Set basic parameters (like in setModelParameters)
    fprintf('Step 2: Setting basic model parameters...\n');
    simIn = simIn.setModelParameter('StopTime', num2str(config.simulation_time));
    fprintf('✓ Set StopTime\n');
    
    simIn = simIn.setModelParameter('Solver', 'ode23t');
    fprintf('✓ Set Solver\n');
    
    simIn = simIn.setModelParameter('RelTol', '1e-3');
    simIn = simIn.setModelParameter('AbsTol', '1e-5');
    fprintf('✓ Set tolerances\n');
    
    simIn = simIn.setModelParameter('SaveOutput', 'on');
    simIn = simIn.setModelParameter('SaveFormat', 'Structure');
    simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');
    fprintf('✓ Set output options\n');
    
    simIn = simIn.setModelParameter('SignalLogging', 'on');
    simIn = simIn.setModelParameter('SaveTime', 'on');
    fprintf('✓ Set logging options\n');
    
    simIn = simIn.setModelParameter('LimitDataPoints', 'off');
    fprintf('✓ Set LimitDataPoints\n');
    
    simIn = simIn.setModelParameter('SimscapeLogType', 'all');
    fprintf('✓ Set SimscapeLogType\n');
    
    % Step 3: Try to run the simulation
    fprintf('Step 3: Attempting to run simulation...\n');
    simOut = sim(simIn);
    fprintf('✓ Simulation completed successfully!\n');
    
catch ME
    fprintf('✗ Error occurred: %s\n', ME.message);
    fprintf('Error details:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\nTest completed.\n'); 