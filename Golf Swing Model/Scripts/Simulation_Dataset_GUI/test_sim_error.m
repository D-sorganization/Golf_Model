% Test script to isolate the ShowSimulationManager error
% This script tests the exact sequence that's failing in robust_dataset_generator.m

fprintf('Testing simulation with ShowSimulationManager parameter...\n');

try
    % Step 1: Create SimulationInput object
    simIn = Simulink.SimulationInput('GolfSwing3D_Kinetic');
    fprintf('✓ Created SimulationInput object\n');
    
    % Step 2: Set basic parameters (like in setModelParameters)
    simIn = simIn.setModelParameter('StopTime', '1.0');
    simIn = simIn.setModelParameter('Solver', 'ode23t');
    fprintf('✓ Set basic model parameters\n');
    
    % Step 3: Try to set ShowSimulationManager (this should be caught)
    try
        simIn = simIn.setModelParameter('ShowSimulationManager', 'off');
        fprintf('✓ ShowSimulationManager parameter was set (this might be the issue)\n');
    catch ME
        fprintf('✓ ShowSimulationManager parameter failed as expected: %s\n', ME.message);
    end
    
    % Step 4: Try to set ShowProgress (this should be caught)
    try
        simIn = simIn.setModelParameter('ShowProgress', 'off');
        fprintf('✓ ShowProgress parameter was set (this might be the issue)\n');
    catch ME
        fprintf('✓ ShowProgress parameter failed as expected: %s\n', ME.message);
    end
    
    % Step 5: Try to run the simulation
    fprintf('Attempting to run simulation...\n');
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