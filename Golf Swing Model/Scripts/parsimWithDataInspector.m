% parsimWithDataInspector.m
% Parsim with Data Inspector extraction
% Combines parallel processing with the working Data Inspector approach

clear; clc;

fprintf('=== Parsim with Data Inspector Extraction ===\n\n');
fprintf('This approach:\n');
fprintf('1. Uses parsim for parallel processing\n');
fprintf('2. Extracts data from Data Inspector for each simulation\n');
fprintf('3. Combines workspace and Simscape data\n\n');

%% Step 1: Setup
fprintf('--- Step 1: Setup ---\n');

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
    
catch ME
    fprintf('✗ Error in setup: %s\n', ME.message);
    return;
end

%% Step 2: Create Parsim Inputs
fprintf('\n--- Step 2: Create Parsim Inputs ---\n');

try
    % Create array for parsim (just 2 simulations for testing)
    numSims = 2;
    simInputArray = Simulink.SimulationInput.empty(0, numSims);
    
    % Create simulation inputs with different parameters
    for i = 1:numSims
        simInput = Simulink.SimulationInput(modelName);
        
        % Quick simulation parameters
        simInput = simInput.setModelParameter('StopTime', '0.05');  % Very short
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable all logging to Data Inspector
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');
        simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        % Add some parameter variation for testing
        if i == 2
            % Modify a parameter for the second simulation
            simInput = simInput.setVariable('someParameter', 1.1);  % Example
        end
        
        simInputArray(i) = simInput;
        fprintf('✓ Created simulation input %d/%d\n', i, numSims);
    end
    
catch ME
    fprintf('✗ Error creating parsim inputs: %s\n', ME.message);
    return;
end

%% Step 3: Run Parsim
fprintf('\n--- Step 3: Run Parsim ---\n');

try
    fprintf('Running parsim with %d simulations...\n', numSims);
    fprintf('(This should be quick with 0.05s duration)\n\n');
    
    % Run parsim
    parsimOutArray = parsim(simInputArray, 'ShowProgress', 'on');
    fprintf('✓ Parsim completed successfully!\n');
    
catch ME
    fprintf('✗ Error in parsim: %s\n', ME.message);
    return;
end

%% Step 4: Extract Data from Data Inspector
fprintf('\n--- Step 4: Extract Data from Data Inspector ---\n');

try
    % Get all runs from Data Inspector
    allRunIDs = Simulink.sdi.getAllRunIDs;
    fprintf('✓ Data Inspector runs found: %d\n', length(allRunIDs));
    
    % Extract data from each run
    allSimData = cell(length(allRunIDs), 1);
    
    for runIdx = 1:length(allRunIDs)
        fprintf('\nProcessing run %d/%d:\n', runIdx, length(allRunIDs));
        
        % Get run object
        runObj = Simulink.sdi.getRun(allRunIDs(runIdx));
        if isempty(runObj)
            fprintf('  ✗ Empty run object\n');
            continue;
        end
        
        % Get all signals from this run
        allSignals = runObj.getAllSignals;
        fprintf('  ✓ Signals in run: %d\n', length(allSignals));
        
        % Extract joint center positions and other key data
        jointCenterData = struct();
        signalCount = 0;
        
        for sigIdx = 1:length(allSignals)
            signal = allSignals(sigIdx);
            signalName = signal.Name;
            
            % Look for joint center positions and other key signals
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
                
                % Create clean field name
                cleanName = createCleanFieldName(signalName);
                
                % Extract time and data
                timeData = signal.Time;
                signalData = signal.Data;
                
                % Store in struct
                jointCenterData.(cleanName) = struct();
                jointCenterData.(cleanName).time = timeData;
                jointCenterData.(cleanName).data = signalData;
                jointCenterData.(cleanName).originalName = signalName;
                
                signalCount = signalCount + 1;
            end
        end
        
        fprintf('  ✓ Key signals extracted: %d\n', signalCount);
        
        % Store run data
        runData = struct();
        runData.runID = allRunIDs(runIdx);
        runData.totalSignals = length(allSignals);
        runData.keySignals = signalCount;
        runData.jointCenterData = jointCenterData;
        
        allSimData{runIdx} = runData;
    end
    
catch ME
    fprintf('✗ Error extracting from Data Inspector: %s\n', ME.message);
    return;
end

%% Step 5: Analyze Results
fprintf('\n--- Step 5: Analyze Results ---\n');

totalSignals = 0;
totalKeySignals = 0;

for runIdx = 1:length(allSimData)
    if ~isempty(allSimData{runIdx})
        runData = allSimData{runIdx};
        fprintf('\nRun %d Analysis:\n', runIdx);
        fprintf('  Total signals: %d\n', runData.totalSignals);
        fprintf('  Key signals: %d\n', runData.keySignals);
        
        totalSignals = totalSignals + runData.totalSignals;
        totalKeySignals = totalKeySignals + runData.keySignals;
        
        % Show some signal names
        if runData.keySignals > 0
            jointFields = fieldnames(runData.jointCenterData);
            fprintf('  Sample key signals:\n');
            for k = 1:min(5, length(jointFields))
                fprintf('    %d: %s\n', k, jointFields{k});
            end
            if length(jointFields) > 5
                fprintf('    ... and %d more\n', length(jointFields) - 5);
            end
        end
    end
end

%% Step 6: Summary
fprintf('\n--- Step 6: Summary ---\n');

avgSignalsPerRun = totalSignals / length(allSimData);
avgKeySignalsPerRun = totalKeySignals / length(allSimData);

fprintf('🎯 PARSIM WITH DATA INSPECTOR RESULTS:\n\n');

fprintf('Data Capture Summary:\n');
fprintf('  Total runs processed: %d\n', length(allSimData));
fprintf('  Average signals per run: %.0f\n', avgSignalsPerRun);
fprintf('  Average key signals per run: %.0f\n', avgKeySignalsPerRun);
fprintf('  TOTAL KEY SIGNALS: %d\n\n', totalKeySignals);

% Check if we have the expected amount
if avgKeySignalsPerRun >= 76  % Based on our earlier success
    fprintf('✅ EXCELLENT: All expected data captured!\n');
    fprintf('✅ SUCCESS: Parsim + Data Inspector working perfectly!\n');
    fprintf('✅ SUCCESS: Ready for large-scale dataset generation!\n\n');
    
    fprintf('Next Steps:\n');
    fprintf('  1. Use this approach for your full dataset\n');
    fprintf('  2. Increase numSims to your desired dataset size\n');
    fprintf('  3. Increase StopTime to full simulation duration\n');
    fprintf('  4. Add parameter variations as needed\n');
    
elseif avgKeySignalsPerRun >= 50
    fprintf('⚠️  GOOD: Most data captured, but some may be missing\n');
    fprintf('  Expected: ~76 key signals, Got: %.0f signals\n\n', avgKeySignalsPerRun);
    
    fprintf('Recommendation: Check for missing signal sources\n');
    
elseif avgKeySignalsPerRun > 0
    fprintf('⚠️  PARTIAL: Some data captured, but significant gaps\n');
    fprintf('  Expected: ~76 key signals, Got: %.0f signals\n\n', avgKeySignalsPerRun);
    
    fprintf('Recommendation: Debug missing data sources\n');
    
else
    fprintf('❌ FAILURE: No data captured\n');
    fprintf('  Expected: ~76 key signals, Got: %.0f signals\n\n', avgKeySignalsPerRun);
    
    fprintf('Recommendation: Check logging configuration\n');
end

%% Step 7: Save Results
fprintf('\n--- Step 7: Save Results ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('ParsimDataInspector_%s', timestamp);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('✓ Created output directory: %s\n', outputDir);
    end
    
    % Save test results
    testResults = struct();
    testResults.timestamp = timestamp;
    testResults.numSims = numSims;
    testResults.totalSignals = totalSignals;
    testResults.totalKeySignals = totalKeySignals;
    testResults.avgSignalsPerRun = avgSignalsPerRun;
    testResults.avgKeySignalsPerRun = avgKeySignalsPerRun;
    testResults.allSimData = allSimData;
    testResults.parsimOutArray = parsimOutArray;
    
    % Save results
    resultsFilename = fullfile(outputDir, 'parsim_data_inspector_results.mat');
    save(resultsFilename, 'testResults');
    fprintf('✓ Test results saved to: %s\n', resultsFilename);
    
catch ME
    fprintf('✗ Error saving results: %s\n', ME.message);
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Parsim with Data Inspector test finished! 🚀\n');

%% Helper Function
function cleanName = createCleanFieldName(originalName)
    % Create a clean field name for MATLAB struct
    cleanName = originalName;
    
    % Replace problematic characters
    cleanName = strrep(cleanName, '.', '_');
    cleanName = strrep(cleanName, '(', '_');
    cleanName = strrep(cleanName, ')', '_');
    cleanName = strrep(cleanName, ' ', '_');
    cleanName = strrep(cleanName, '-', '_');
    
    % Remove any remaining problematic characters
    cleanName = regexprep(cleanName, '[^a-zA-Z0-9_]', '_');
    
    % Ensure it starts with a letter
    if ~isempty(cleanName) && ~isletter(cleanName(1))
        cleanName = ['Signal_' cleanName];
    end
end 