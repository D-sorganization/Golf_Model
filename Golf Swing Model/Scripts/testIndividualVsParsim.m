% testIndividualVsParsim.m
% Test to compare individual sim() vs parsim() Data Inspector logging

clear; clc;

fprintf('=== Individual vs Parsim Data Inspector Test ===\n\n');
fprintf('This test will compare:\n');
fprintf('1. Individual sim() Data Inspector logging\n');
fprintf('2. Parsim() Data Inspector logging\n');
fprintf('3. Identify the best approach for dataset generation\n\n');

%% Step 1: Test Individual Simulation
fprintf('--- Step 1: Test Individual Simulation ---\n');

try
    % Load model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Clear Data Inspector
    Simulink.sdi.clear;
    fprintf('✓ Data Inspector cleared\n');
    
    % Create simulation input
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.05');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable all logging
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    % Run individual simulation
    fprintf('Running individual simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Individual simulation completed\n');
    
    % Check Data Inspector
    allRunIDs = Simulink.sdi.getAllRunIDs;
    fprintf('✓ Data Inspector runs after individual sim: %d\n', length(allRunIDs));
    
    if length(allRunIDs) > 0
        % Get signals from first run
        runObj = Simulink.sdi.getRun(allRunIDs(1));
        allSignals = runObj.getAllSignals;
        fprintf('✓ Signals in individual sim run: %d\n', length(allSignals));
        
        % Count key signals
        keySignalCount = 0;
        for sigIdx = 1:length(allSignals)
            signal = allSignals(sigIdx);
            signalName = signal.Name;
            
            if contains(signalName, 'GlobalPosition') || ...
               contains(signalName, 'Position') || ...
               contains(signalName, '.q') || ...
               contains(signalName, '.w') || ...
               contains(signalName, '.tau') || ...
               contains(signalName, 'CHGlobal') || ...
               contains(signalName, 'HipGlobal') || ...
               contains(signalName, 'TorsoLogs') || ...
               contains(signalName, 'LELogs') || ...
               contains(signalName, 'RELogs') || ...
               contains(signalName, 'LHGlobal') || ...
               contains(signalName, 'RHGlobal') || ...
               contains(signalName, 'MPGlobal') || ...
               contains(signalName, 'HUBGlobal')
                keySignalCount = keySignalCount + 1;
            end
        end
        fprintf('✓ Key signals in individual sim: %d\n', keySignalCount);
    end
    
catch ME
    fprintf('✗ Error in individual simulation: %s\n', ME.message);
    return;
end

%% Step 2: Test Parsim
fprintf('\n--- Step 2: Test Parsim ---\n');

try
    % Clear Data Inspector again
    Simulink.sdi.clear;
    fprintf('✓ Data Inspector cleared for parsim test\n');
    
    % Create parsim inputs
    numSims = 2;
    simInputArray = Simulink.SimulationInput.empty(0, numSims);
    
    for i = 1:numSims
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.05');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable all logging
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');
        simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        simInputArray(i) = simInput;
    end
    
    % Run parsim
    fprintf('Running parsim with %d simulations...\n', numSims);
    parsimOutArray = parsim(simInputArray, 'ShowProgress', 'on');
    fprintf('✓ Parsim completed\n');
    
    % Check Data Inspector
    allRunIDs = Simulink.sdi.getAllRunIDs;
    fprintf('✓ Data Inspector runs after parsim: %d\n', length(allRunIDs));
    
    if length(allRunIDs) > 0
        % Get signals from first run
        runObj = Simulink.sdi.getRun(allRunIDs(1));
        allSignals = runObj.getAllSignals;
        fprintf('✓ Signals in parsim run: %d\n', length(allSignals));
        
        % Count key signals
        keySignalCount = 0;
        for sigIdx = 1:length(allSignals)
            signal = allSignals(sigIdx);
            signalName = signal.Name;
            
            if contains(signalName, 'GlobalPosition') || ...
               contains(signalName, 'Position') || ...
               contains(signalName, '.q') || ...
               contains(signalName, '.w') || ...
               contains(signalName, '.tau') || ...
               contains(signalName, 'CHGlobal') || ...
               contains(signalName, 'HipGlobal') || ...
               contains(signalName, 'TorsoLogs') || ...
               contains(signalName, 'LELogs') || ...
               contains(signalName, 'RELogs') || ...
               contains(signalName, 'LHGlobal') || ...
               contains(signalName, 'RHGlobal') || ...
               contains(signalName, 'MPGlobal') || ...
               contains(signalName, 'HUBGlobal')
                keySignalCount = keySignalCount + 1;
            end
        end
        fprintf('✓ Key signals in parsim: %d\n', keySignalCount);
    end
    
catch ME
    fprintf('✗ Error in parsim test: %s\n', ME.message);
    return;
end

%% Step 3: Summary and Recommendations
fprintf('\n--- Step 3: Summary and Recommendations ---\n');

fprintf('🎯 COMPARISON RESULTS:\n\n');

% Get final counts
individualRuns = Simulink.sdi.getAllRunIDs;
individualRunCount = length(individualRuns);

fprintf('Data Inspector Logging Comparison:\n');
fprintf('  Individual sim() runs: %d\n', individualRunCount);
fprintf('  Parsim() runs: %d\n', length(allRunIDs) - individualRunCount);
fprintf('\n');

if individualRunCount > 0 && (length(allRunIDs) - individualRunCount) == 0
    fprintf('❌ ISSUE IDENTIFIED:\n');
    fprintf('  • Individual sim() logs to Data Inspector: YES\n');
    fprintf('  • Parsim() logs to Data Inspector: NO\n');
    fprintf('  • This explains why parsim + Data Inspector failed\n\n');
    
    fprintf('✅ SOLUTION: Use parfor instead of parsim\n');
    fprintf('  • parfor loop with individual sim() calls\n');
    fprintf('  • Each sim() will log to Data Inspector\n');
    fprintf('  • Extract data after each simulation\n');
    fprintf('  • Combine results for dataset generation\n\n');
    
    fprintf('Next Steps:\n');
    fprintf('  1. Create parfor-based dataset generation script\n');
    fprintf('  2. Use individual sim() calls in parallel loop\n');
    fprintf('  3. Extract from Data Inspector after each sim\n');
    fprintf('  4. Combine all data into final dataset\n');
    
elseif individualRunCount > 0 && (length(allRunIDs) - individualRunCount) > 0
    fprintf('✅ BOTH METHODS WORK:\n');
    fprintf('  • Individual sim() logs to Data Inspector: YES\n');
    fprintf('  • Parsim() logs to Data Inspector: YES\n');
    fprintf('  • Both approaches are viable\n\n');
    
    fprintf('Recommendation: Use parsim for efficiency\n');
    
else
    fprintf('❌ NEITHER METHOD WORKS:\n');
    fprintf('  • Individual sim() logs to Data Inspector: NO\n');
    fprintf('  • Parsim() logs to Data Inspector: NO\n');
    fprintf('  • Need to debug logging configuration\n\n');
    
    fprintf('Recommendation: Check signal logging setup\n');
end

%% Step 4: Save Results
fprintf('\n--- Step 4: Save Results ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('IndividualVsParsim_%s', timestamp);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('✓ Created output directory: %s\n', outputDir);
    end
    
    % Save test results
    testResults = struct();
    testResults.timestamp = timestamp;
    testResults.individualRunCount = individualRunCount;
    testResults.parsimRunCount = length(allRunIDs) - individualRunCount;
    testResults.totalRunCount = length(allRunIDs);
    testResults.simOut = simOut;
    testResults.parsimOutArray = parsimOutArray;
    
    % Save results
    resultsFilename = fullfile(outputDir, 'individual_vs_parsim_results.mat');
    save(resultsFilename, 'testResults');
    fprintf('✓ Test results saved to: %s\n', resultsFilename);
    
catch ME
    fprintf('✗ Error saving results: %s\n', ME.message);
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Individual vs Parsim test finished! 🔍\n'); 