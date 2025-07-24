% testWorkspaceAndSimscape.m
% Test extraction from simOut.out (ToWorkspace blocks) and simOut.simscape
% Verify we can get all data from both individual sim() and parsim()

clear; clc;

fprintf('=== Test Workspace and Simscape Data Extraction ===\n\n');
fprintf('This test will verify:\n');
fprintf('1. Data extraction from simOut.out (ToWorkspace blocks)\n');
fprintf('2. Data extraction from simOut.simscape (Simscape Results Explorer)\n');
fprintf('3. Both individual sim() and parsim() approaches\n\n');

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
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
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
    
    % Extract from simOut.out (ToWorkspace blocks)
    if isfield(simOut, 'out') && ~isempty(simOut.out)
        outData = simOut.out;
        if isa(outData, 'Simulink.SimulationData.Dataset')
            workspaceCount = outData.numElements;
            fprintf('✓ Workspace signals (simOut.out): %d\n', workspaceCount);
            
            % Show some signal names
            if workspaceCount > 0
                fprintf('  Sample workspace signals:\n');
                for j = 1:min(5, workspaceCount)
                    try
                        element = outData.getElement(j);
                        fprintf('    %d: %s\n', j, element.Name);
                    catch
                        fprintf('    %d: [Error accessing]\n', j);
                    end
                end
                if workspaceCount > 5
                    fprintf('    ... and %d more\n', workspaceCount - 5);
                end
            end
        else
            fprintf('✓ Workspace data: present (%s)\n', class(outData));
        end
    else
        fprintf('✗ No workspace data found in simOut.out\n');
    end
    
    % Extract from simOut.simscape (Simscape Results Explorer)
    if isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
        simscapeData = simOut.simscape;
        if isstruct(simscapeData)
            simscapeCount = length(fieldnames(simscapeData));
            fprintf('✓ Simscape signals (simOut.simscape): %d\n', simscapeCount);
            
            % Show some simscape field names
            if simscapeCount > 0
                simscapeFields = fieldnames(simscapeData);
                fprintf('  Sample simscape fields:\n');
                for j = 1:min(5, simscapeCount)
                    fprintf('    %d: %s\n', j, simscapeFields{j});
                end
                if simscapeCount > 5
                    fprintf('    ... and %d more\n', simscapeCount - 5);
                end
            end
        elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
            simscapeCount = simscapeData.numElements;
            fprintf('✓ Simscape signals (simOut.simscape): %d\n', simscapeCount);
        else
            fprintf('✓ Simscape data: present (%s)\n', class(simscapeData));
        end
    else
        fprintf('✗ No Simscape data found in simOut.simscape\n');
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
    
    % Analyze parsim results
    fprintf('\nParsim results analysis:\n');
    
    totalWorkspaceSignals = 0;
    totalSimscapeSignals = 0;
    
    for simIdx = 1:length(parsimOutArray)
        fprintf('\nSimulation %d/%d:\n', simIdx, length(parsimOutArray));
        
        simOut = parsimOutArray(simIdx);
        if isempty(simOut)
            fprintf('  ✗ Empty output\n');
            continue;
        end
        
        % Check simOut.out (ToWorkspace blocks)
        if isfield(simOut, 'out') && ~isempty(simOut.out)
            outData = simOut.out;
            if isa(outData, 'Simulink.SimulationData.Dataset')
                workspaceCount = outData.numElements;
                fprintf('  ✓ Workspace signals (simOut.out): %d\n', workspaceCount);
                totalWorkspaceSignals = workspaceCount;
            else
                fprintf('  ✓ Workspace data: present (%s)\n', class(outData));
            end
        else
            fprintf('  ✗ No workspace data found in simOut.out\n');
        end
        
        % Check simOut.simscape (Simscape Results Explorer)
        if isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
            simscapeData = simOut.simscape;
            if isstruct(simscapeData)
                simscapeCount = length(fieldnames(simscapeData));
                fprintf('  ✓ Simscape signals (simOut.simscape): %d\n', simscapeCount);
                totalSimscapeSignals = simscapeCount;
            elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
                simscapeCount = simscapeData.numElements;
                fprintf('  ✓ Simscape signals (simOut.simscape): %d\n', simscapeCount);
                totalSimscapeSignals = simscapeCount;
            else
                fprintf('  ✓ Simscape data: present (%s)\n', class(simscapeData));
            end
        else
            fprintf('  ✗ No Simscape data found in simOut.simscape\n');
        end
    end
    
catch ME
    fprintf('✗ Error in parsim test: %s\n', ME.message);
    return;
end

%% Step 3: Summary
fprintf('\n--- Step 3: Summary ---\n');

totalSignals = totalWorkspaceSignals + totalSimscapeSignals;

fprintf('🎯 WORKSPACE AND SIMSCAPE TEST RESULTS:\n\n');

fprintf('Data Capture Summary:\n');
fprintf('  Workspace signals (simOut.out): %d\n', totalWorkspaceSignals);
fprintf('  Simscape signals (simOut.simscape): %d\n', totalSimscapeSignals);
fprintf('  TOTAL SIGNALS PER SIMULATION: %d\n\n', totalSignals);

% Check if we have the expected amount
if totalSignals >= 590
    fprintf('✅ EXCELLENT: All expected data captured!\n');
    fprintf('✅ SUCCESS: Both workspace and Simscape data working!\n');
    fprintf('✅ SUCCESS: Ready for large-scale dataset generation!\n\n');
    
    fprintf('Next Steps:\n');
    fprintf('  1. Use this configuration for your full dataset\n');
    fprintf('  2. Increase numSims to your desired dataset size\n');
    fprintf('  3. Increase StopTime to full simulation duration\n');
    fprintf('  4. Add parameter variations as needed\n');
    
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
    
    fprintf('Recommendation: Check ToWorkspace block configuration\n');
end

%% Step 4: Save Results
fprintf('\n--- Step 4: Save Results ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('WorkspaceAndSimscape_%s', timestamp);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('✓ Created output directory: %s\n', outputDir);
    end
    
    % Save test results
    testResults = struct();
    testResults.timestamp = timestamp;
    testResults.numSims = numSims;
    testResults.workspaceSignals = totalWorkspaceSignals;
    testResults.simscapeSignals = totalSimscapeSignals;
    testResults.totalSignals = totalSignals;
    testResults.simOut = simOut;
    testResults.parsimOutArray = parsimOutArray;
    
    % Save results
    resultsFilename = fullfile(outputDir, 'workspace_and_simscape_results.mat');
    save(resultsFilename, 'testResults');
    fprintf('✓ Test results saved to: %s\n', resultsFilename);
    
catch ME
    fprintf('✗ Error saving results: %s\n', ME.message);
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Workspace and Simscape test finished! 🚀\n'); 