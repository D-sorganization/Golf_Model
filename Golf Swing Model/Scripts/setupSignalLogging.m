% setupSignalLogging.m
% Script to help set up proper signal logging for the golf swing model
% This will check what signals are available and provide logging options

clear; clc;

fprintf('=== Signal Logging Setup for Golf Swing Model ===\n\n');
fprintf('This script will help you set up proper signal logging.\n');
fprintf('We need to identify what signals are available and how to log them.\n\n');

%% Step 1: Check Current Model State
fprintf('--- Step 1: Check Current Model State ---\n');

try
    % Load model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Check current logging configuration
    fprintf('\nCurrent logging configuration:\n');
    fprintf('  SignalLogging: %s\n', get_param(modelName, 'SignalLogging'));
    fprintf('  SignalLoggingName: %s\n', get_param(modelName, 'SignalLoggingName'));
    fprintf('  SignalLoggingSaveFormat: %s\n', get_param(modelName, 'SignalLoggingSaveFormat'));
    fprintf('  SimscapeLogType: %s\n', get_param(modelName, 'SimscapeLogType'));
    fprintf('  SimscapeLogName: %s\n', get_param(modelName, 'SimscapeLogName'));
    
    % Check for existing logging blocks
    fprintf('\nExisting logging blocks:\n');
    toWorkspaceBlocks = find_system(modelName, 'BlockType', 'ToWorkspace');
    fprintf('  ToWorkspace blocks: %d\n', length(toWorkspaceBlocks));
    
    scopeBlocks = find_system(modelName, 'BlockType', 'Scope');
    fprintf('  Scope blocks: %d\n', length(scopeBlocks));
    
    displayBlocks = find_system(modelName, 'BlockType', 'Display');
    fprintf('  Display blocks: %d\n', length(displayBlocks));
    
catch ME
    fprintf('✗ Error checking model state: %s\n', ME.message);
    return;
end

%% Step 2: Find Available Signals
fprintf('\n--- Step 2: Find Available Signals ---\n');

try
    % Look for signal buses
    fprintf('Looking for signal buses...\n');
    busBlocks = find_system(modelName, 'BlockType', 'Bus');
    fprintf('  Bus blocks found: %d\n', length(busBlocks));
    
    % Look for signal lines that could be logged
    fprintf('\nLooking for signal lines...\n');
    
    % Get all blocks in the model
    allBlocks = find_system(modelName, 'FollowLinks', 'on', 'LookUnderMasks', 'on');
    fprintf('  Total blocks in model: %d\n', length(allBlocks));
    
    % Look for specific signal types
    fprintf('\nLooking for specific signal types:\n');
    
    % Joint-related signals
    jointBlocks = find_system(modelName, 'Name', '*Joint*');
    fprintf('  Joint-related blocks: %d\n', length(jointBlocks));
    
    % Position-related signals
    positionBlocks = find_system(modelName, 'Name', '*Position*');
    fprintf('  Position-related blocks: %d\n', length(positionBlocks));
    
    % Force-related signals
    forceBlocks = find_system(modelName, 'Name', '*Force*');
    fprintf('  Force-related blocks: %d\n', length(forceBlocks));
    
    % Simscape blocks
    simscapeBlocks = find_system(modelName, 'BlockType', 'SimscapeBlock');
    fprintf('  Simscape blocks: %d\n', length(simscapeBlocks));
    
catch ME
    fprintf('✗ Error finding signals: %s\n', ME.message);
end

%% Step 3: Check Simscape Results Explorer Data
fprintf('\n--- Step 3: Check Simscape Results Explorer Data ---\n');

try
    % Run a quick simulation to see what Simscape data is available
    fprintf('Running quick simulation to check Simscape data...\n');
    
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.01');  % Very short
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable Simscape logging
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    
    quickOut = sim(simInput);
    
    % Check what we got
    quickFields = fieldnames(quickOut);
    fprintf('Quick simulation output fields: %d\n', length(quickFields));
    for i = 1:length(quickFields)
        fieldName = quickFields{i};
        fieldValue = quickOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        if ~isempty(fieldValue)
            fprintf('    Type: %s\n', class(fieldValue));
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error checking Simscape data: %s\n', ME.message);
end

%% Step 4: Provide Logging Options
fprintf('\n--- Step 4: Logging Options ---\n');

fprintf('Based on the analysis, here are your options for logging signals:\n\n');

fprintf('OPTION 1: Add ToWorkspace Blocks (Recommended)\n');
fprintf('  • Add ToWorkspace blocks to your signal buses\n');
fprintf('  • This will log signals directly to the workspace\n');
fprintf('  • Works with both individual sim() and parsim()\n');
fprintf('  • Steps:\n');
fprintf('    1. Open the model in Simulink\n');
fprintf('    2. Find your signal buses\n');
fprintf('    3. Add ToWorkspace blocks to the bus outputs\n');
fprintf('    4. Set VariableName for each ToWorkspace block\n');
fprintf('    5. Set SaveFormat to "Dataset"\n\n');

fprintf('OPTION 2: Use Data Inspector (Current Approach)\n');
fprintf('  • Right-click signals and select "Log"\n');
fprintf('  • Signals appear in Data Inspector\n');
fprintf('  • Need to extract from Data Inspector after simulation\n');
fprintf('  • May not work well with parsim()\n\n');

fprintf('OPTION 3: Use Simscape Results Explorer\n');
fprintf('  • Simscape automatically logs joint states and properties\n');
fprintf('  • Access via simOut.simscape field\n');
fprintf('  • Works with both individual sim() and parsim()\n');
fprintf('  • Contains: joint positions, velocities, forces, torques\n\n');

%% Step 5: Test Current Data Inspector Approach
fprintf('\n--- Step 5: Test Current Data Inspector Approach ---\n');

try
    fprintf('Testing if Data Inspector signals are available...\n');
    
    % Run simulation and immediately check Data Inspector
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.01');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable signal logging to Data Inspector
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    fprintf('Running simulation with Data Inspector logging...\n');
    simOut = sim(simInput);
    
    % Check Data Inspector
    runIDs = Simulink.sdi.getAllRunIDs;
    if ~isempty(runIDs)
        fprintf('✓ Data Inspector runs found: %d\n', length(runIDs));
        
        % Check the latest run
        latestRun = Simulink.sdi.getRun(runIDs(end));
        signals = latestRun.getAllSignals;
        fprintf('✓ Data Inspector signals found: %d\n', length(signals));
        
        % Show some signal names
        fprintf('Sample signal names:\n');
        for i = 1:min(10, length(signals))
            signal = signals(i);
            fprintf('  %d: %s\n', i, signal.Name);
        end
        if length(signals) > 10
            fprintf('  ... and %d more signals\n', length(signals) - 10);
        end
        
    else
        fprintf('✗ No Data Inspector runs found\n');
    end
    
catch ME
    fprintf('✗ Error testing Data Inspector: %s\n', ME.message);
end

%% Step 6: Recommendations
fprintf('\n--- Step 6: Recommendations ---\n');

fprintf('🎯 RECOMMENDED APPROACH:\n\n');

fprintf('1. IMMEDIATE SOLUTION: Use Data Inspector + Extraction\n');
fprintf('   • Your signals are already logged to Data Inspector\n');
fprintf('   • Use extractSignalsFromDataInspector.m to get the data\n');
fprintf('   • This works for individual simulations\n\n');

fprintf('2. LONG-TERM SOLUTION: Add ToWorkspace Blocks\n');
fprintf('   • Add ToWorkspace blocks to your signal buses\n');
fprintf('   • This will enable parsim() to work properly\n');
fprintf('   • More reliable and efficient\n\n');

fprintf('3. HYBRID APPROACH: Combine Both\n');
fprintf('   • Use Data Inspector for immediate needs\n');
fprintf('   • Gradually add ToWorkspace blocks for parsim()\n\n');

fprintf('QUESTION: Do you want to:\n');
fprintf('  A) Test the Data Inspector extraction approach now?\n');
fprintf('  B) Get instructions for adding ToWorkspace blocks?\n');
fprintf('  C) Try a different approach?\n');

fprintf('\nSignal logging setup analysis finished! 🔧\n'); 