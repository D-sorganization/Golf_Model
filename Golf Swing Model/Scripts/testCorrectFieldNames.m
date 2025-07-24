% testCorrectFieldNames.m
% Test extraction using correct field names from model configuration
% Based on verification: SignalLoggingName: logsout, SimscapeLogName: simlog

clear; clc;

fprintf('=== Test Correct Field Names ===\n\n');
fprintf('Using field names from model configuration:\n');
fprintf('  SignalLoggingName: logsout\n');
fprintf('  SimscapeLogName: simlog\n\n');

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
    
    % Create simulation input
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.05');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable all logging
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simlog');
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'logsout');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    % Run individual simulation
    fprintf('Running individual simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Individual simulation completed\n');
    
    % Analyze simOut structure
    outputFields = fieldnames(simOut);
    fprintf('✓ simOut fields: %d\n', length(outputFields));
    for i = 1:length(outputFields)
        fprintf('  %d: %s\n', i, outputFields{i});
    end
    
    % Extract from simOut.logsout (signal logging)
    if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
        logsoutData = simOut.logsout;
        if isa(logsoutData, 'Simulink.SimulationData.Dataset')
            logsoutCount = logsoutData.numElements;
            fprintf('✓ Signal logging (simOut.logsout): %d elements\n', logsoutCount);
            
            % Show some signal names
            if logsoutCount > 0
                fprintf('  Sample signal logging elements:\n');
                for j = 1:min(5, logsoutCount)
                    try
                        element = logsoutData.getElement(j);
                        fprintf('    %d: %s\n', j, element.Name);
                    catch
                        fprintf('    %d: [Error accessing]\n', j);
                    end
                end
                if logsoutCount > 5
                    fprintf('    ... and %d more\n', logsoutCount - 5);
                end
            end
        else
            fprintf('✓ Signal logging data: present (%s)\n', class(logsoutData));
        end
    else
        fprintf('✗ No signal logging data found in simOut.logsout\n');
    end
    
    % Extract from simOut.simlog (Simscape logging)
    if isfield(simOut, 'simlog') && ~isempty(simOut.simlog)
        simlogData = simOut.simlog;
        if isstruct(simlogData)
            simlogCount = length(fieldnames(simlogData));
            fprintf('✓ Simscape logging (simOut.simlog): %d fields\n', simlogCount);
            
            % Show some simlog field names
            if simlogCount > 0
                simlogFields = fieldnames(simlogData);
                fprintf('  Sample simlog fields:\n');
                for j = 1:min(5, simlogCount)
                    fprintf('    %d: %s\n', j, simlogFields{j});
                end
                if simlogCount > 5
                    fprintf('    ... and %d more\n', simlogCount - 5);
                end
            end
        elseif isa(simlogData, 'Simulink.SimulationData.Dataset')
            simlogCount = simlogData.numElements;
            fprintf('✓ Simscape logging (simOut.simlog): %d elements\n', simlogCount);
        else
            fprintf('✓ Simscape logging data: present (%s)\n', class(simlogData));
        end
    else
        fprintf('✗ No Simscape logging data found in simOut.simlog\n');
    end
    
catch ME
    fprintf('✗ Error in individual simulation: %s\n', ME.message);
    return;
end

%% Step 2: Test Parsim
fprintf('\n--- Step 2: Test Parsim ---\n');

try
    % Create parsim inputs
    numSims = 2;
    simInputArray = Simulink.SimulationInput.empty(0, numSims);
    
    for i = 1:numSims
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.05');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable all logging with correct field names
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');
        simInput = simInput.setModelParameter('SimscapeLogName', 'simlog');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'logsout');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        simInputArray(i) = simInput;
    end
    
    % Run parsim
    fprintf('Running parsim with %d simulations...\n', numSims);
    parsimOutArray = parsim(simInputArray, 'ShowProgress', 'on');
    fprintf('✓ Parsim completed\n');
    
    % Analyze parsim results
    fprintf('\nParsim results analysis:\n');
    
    totalLogsoutSignals = 0;
    totalSimlogSignals = 0;
    
    for simIdx = 1:length(parsimOutArray)
        fprintf('\nSimulation %d/%d:\n', simIdx, length(parsimOutArray));
        
        simOut = parsimOutArray(simIdx);
        if isempty(simOut)
            fprintf('  ✗ Empty output\n');
            continue;
        end
        
        % Check simOut.logsout (signal logging)
        if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
            logsoutData = simOut.logsout;
            if isa(logsoutData, 'Simulink.SimulationData.Dataset')
                logsoutCount = logsoutData.numElements;
                fprintf('  ✓ Signal logging (simOut.logsout): %d elements\n', logsoutCount);
                totalLogsoutSignals = logsoutCount;
            else
                fprintf('  ✓ Signal logging data: present (%s)\n', class(logsoutData));
            end
        else
            fprintf('  ✗ No signal logging data found in simOut.logsout\n');
        end
        
        % Check simOut.simlog (Simscape logging)
        if isfield(simOut, 'simlog') && ~isempty(simOut.simlog)
            simlogData = simOut.simlog;
            if isstruct(simlogData)
                simlogCount = length(fieldnames(simlogData));
                fprintf('  ✓ Simscape logging (simOut.simlog): %d fields\n', simlogCount);
                totalSimlogSignals = simlogCount;
            elseif isa(simlogData, 'Simulink.SimulationData.Dataset')
                simlogCount = simlogData.numElements;
                fprintf('  ✓ Simscape logging (simOut.simlog): %d elements\n', simlogCount);
                totalSimlogSignals = simlogCount;
            else
                fprintf('  ✓ Simscape logging data: present (%s)\n', class(simlogData));
            end
        else
            fprintf('  ✗ No Simscape logging data found in simOut.simlog\n');
        end
    end
    
catch ME
    fprintf('✗ Error in parsim test: %s\n', ME.message);
    return;
end

%% Step 3: Summary
fprintf('\n--- Step 3: Summary ---\n');

totalSignals = totalLogsoutSignals + totalSimlogSignals;

fprintf('🎯 CORRECT FIELD NAMES TEST RESULTS:\n\n');

fprintf('Data Capture Summary:\n');
fprintf('  Signal logging (simOut.logsout): %d\n', totalLogsoutSignals);
fprintf('  Simscape logging (simOut.simlog): %d\n', totalSimlogSignals);
fprintf('  TOTAL SIGNALS PER SIMULATION: %d\n\n', totalSignals);

% Check if we have the expected amount
if totalSignals >= 590
    fprintf('✅ EXCELLENT: All expected data captured!\n');
    fprintf('✅ SUCCESS: Both signal and Simscape logging working!\n');
    fprintf('✅ SUCCESS: Ready for large-scale dataset generation!\n\n');
    
    fprintf('Next Steps:\n');
    fprintf('  1. Use this configuration for your full dataset\n');
    fprintf('  2. Extract from simOut.logsout and simOut.simlog\n');
    fprintf('  3. Increase numSims to your desired dataset size\n');
    fprintf('  4. Increase StopTime to full simulation duration\n');
    
elseif totalSignals >= 500
    fprintf('⚠️  GOOD: Most data captured, but some may be missing\n');
    fprintf('  Expected: ~590 signals, Got: %d signals\n\n', totalSignals);
    
    fprintf('Recommendation: Check for missing signal sources\n');
    
elseif totalSignals > 0
    fprintf('⚠️  PARTIAL: Some data captured, but significant gaps\n');
    fprintf('  Expected: ~590 signals, Got: %d signals\n\n', totalSignals);
    
    fprintf('Recommendation: Debug missing data sources\n');
    
else
    fprintf('❌ FAILURE: No data captured\n');
    fprintf('  Expected: ~590 signals, Got: %d signals\n\n', totalSignals);
    
    fprintf('Recommendation: Check signal logging configuration\n');
end

%% Step 4: Save Results
fprintf('\n--- Step 4: Save Results ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('CorrectFieldNames_%s', timestamp);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('✓ Created output directory: %s\n', outputDir);
    end
    
    % Save test results
    testResults = struct();
    testResults.timestamp = timestamp;
    testResults.numSims = numSims;
    testResults.logsoutSignals = totalLogsoutSignals;
    testResults.simlogSignals = totalSimlogSignals;
    testResults.totalSignals = totalSignals;
    testResults.simOut = simOut;
    testResults.parsimOutArray = parsimOutArray;
    
    % Save results
    resultsFilename = fullfile(outputDir, 'correct_field_names_results.mat');
    save(resultsFilename, 'testResults');
    fprintf('✓ Test results saved to: %s\n', resultsFilename);
    
catch ME
    fprintf('✗ Error saving results: %s\n', ME.message);
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Correct field names test finished! 🚀\n'); 