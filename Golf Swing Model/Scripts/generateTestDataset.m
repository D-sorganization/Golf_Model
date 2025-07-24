% generateTestDataset.m
% Generate test dataset using Data Inspector approach with parfor
% This uses the working method we confirmed earlier

clear; clc;

fprintf('=== Generate Test Dataset ===\n\n');
fprintf('Using Data Inspector approach with parfor for parallel processing\n');
fprintf('This method has been confirmed to work with 76+ joint center signals\n\n');

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
    
    % Set dataset parameters
    numSims = 5;  % Start with 5 simulations for testing
    stopTime = 0.1;  % Short duration for testing
    fprintf('✓ Dataset parameters set:\n');
    fprintf('  Number of simulations: %d\n', numSims);
    fprintf('  Stop time: %.2f seconds\n', stopTime);
    
catch ME
    fprintf('✗ Error in setup: %s\n', ME.message);
    return;
end

%% Step 2: Generate Dataset
fprintf('\n--- Step 2: Generate Dataset ---\n');

try
    % Initialize storage
    allSimData = cell(numSims, 1);
    
    % Use parfor for parallel processing
    fprintf('Starting parallel dataset generation...\n');
    
    parfor simIdx = 1:numSims
        fprintf('Processing simulation %d/%d...\n', simIdx, numSims);
        
        % Create simulation input with parameter variation
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', num2str(stopTime));
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable all logging
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');
        simInput = simInput.setModelParameter('SimscapeLogName', 'simlog');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'logsout');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        % Add parameter variation for dataset diversity
        % You can modify these parameters based on your needs
        variationFactor = 0.9 + 0.2 * rand();  % 0.9 to 1.1
        simInput = simInput.setVariable('someParameter', variationFactor);
        
        % Run simulation
        simOut = sim(simInput);
        
        % Extract data from Data Inspector
        % Note: In parfor, we need to extract data differently
        % For now, we'll store the simOut and extract later
        
        % Store simulation data
        simData = struct();
        simData.simIdx = simIdx;
        simData.simOut = simOut;
        simData.variationFactor = variationFactor;
        simData.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        
        allSimData{simIdx} = simData;
        
        fprintf('  ✓ Simulation %d/%d completed\n', simIdx, numSims);
    end
    
    fprintf('✓ All simulations completed!\n');
    
catch ME
    fprintf('✗ Error in dataset generation: %s\n', ME.message);
    return;
end

%% Step 3: Extract Data from Data Inspector
fprintf('\n--- Step 3: Extract Data from Data Inspector ---\n');

try
    % Get all runs from Data Inspector
    allRunIDs = Simulink.sdi.getAllRunIDs;
    fprintf('✓ Data Inspector runs found: %d\n', length(allRunIDs));
    
    if length(allRunIDs) == 0
        fprintf('❌ No runs found in Data Inspector!\n');
        fprintf('This suggests the signals are not being logged to Data Inspector.\n');
        fprintf('Please check your signal logging configuration.\n');
        return;
    end
    
    % Extract data from each run
    extractedData = cell(length(allRunIDs), 1);
    
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
        
        extractedData{runIdx} = runData;
    end
    
catch ME
    fprintf('✗ Error extracting from Data Inspector: %s\n', ME.message);
    return;
end

%% Step 4: Analyze Results
fprintf('\n--- Step 4: Analyze Results ---\n');

totalSignals = 0;
totalKeySignals = 0;

for runIdx = 1:length(extractedData)
    if ~isempty(extractedData{runIdx})
        runData = extractedData{runIdx};
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

%% Step 5: Summary
fprintf('\n--- Step 5: Summary ---\n');

avgSignalsPerRun = totalSignals / length(extractedData);
avgKeySignalsPerRun = totalKeySignals / length(extractedData);

fprintf('🎯 DATASET GENERATION RESULTS:\n\n');

fprintf('Dataset Summary:\n');
fprintf('  Total runs processed: %d\n', length(extractedData));
fprintf('  Average signals per run: %.0f\n', avgSignalsPerRun);
fprintf('  Average key signals per run: %.0f\n', avgKeySignalsPerRun);
fprintf('  TOTAL KEY SIGNALS: %d\n\n', totalKeySignals);

% Check if we have the expected amount
if avgKeySignalsPerRun >= 76  % Based on our earlier success
    fprintf('✅ EXCELLENT: Dataset generation successful!\n');
    fprintf('✅ SUCCESS: All expected data captured!\n');
    fprintf('✅ SUCCESS: Ready for large-scale dataset generation!\n\n');
    
    fprintf('Next Steps:\n');
    fprintf('  1. Increase numSims to your desired dataset size\n');
    fprintf('  2. Increase stopTime to full simulation duration\n');
    fprintf('  3. Add more parameter variations as needed\n');
    fprintf('  4. Use this approach for your full dataset\n');
    
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
    
    fprintf('Recommendation: Check signal logging configuration\n');
end

%% Step 6: Save Dataset
fprintf('\n--- Step 6: Save Dataset ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('TestDataset_%s', timestamp);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('✓ Created output directory: %s\n', outputDir);
    end
    
    % Save dataset
    datasetFilename = fullfile(outputDir, 'test_dataset.mat');
    save(datasetFilename, 'extractedData', 'allSimData', 'numSims', 'stopTime');
    fprintf('✓ Dataset saved to: %s\n', datasetFilename);
    
    % Save summary
    summary = struct();
    summary.timestamp = timestamp;
    summary.numSims = numSims;
    summary.stopTime = stopTime;
    summary.totalSignals = totalSignals;
    summary.totalKeySignals = totalKeySignals;
    summary.avgSignalsPerRun = avgSignalsPerRun;
    summary.avgKeySignalsPerRun = avgKeySignalsPerRun;
    
    summaryFilename = fullfile(outputDir, 'dataset_summary.mat');
    save(summaryFilename, 'summary');
    fprintf('✓ Summary saved to: %s\n', summaryFilename);
    
catch ME
    fprintf('✗ Error saving dataset: %s\n', ME.message);
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Test dataset generation finished! 🚀\n');

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