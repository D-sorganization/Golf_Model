% quickParsimTest.m
% Quick test to verify parsim can capture all needed data
% Tests both workspace signals and Simscape Results Explorer data

clear; clc;

fprintf('=== Quick Parsim Data Capture Test ===\n\n');
fprintf('This test will verify we can capture:\n');
fprintf('1. Workspace signals (from ToWorkspace blocks)\n');
fprintf('2. Simscape Results Explorer data\n');
fprintf('3. Combined data for dataset generation\n\n');

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
    
    % Check for ToWorkspace blocks
    toWorkspaceBlocks = find_system(modelName, 'BlockType', 'ToWorkspace');
    fprintf('✓ ToWorkspace blocks found: %d\n', length(toWorkspaceBlocks));
    
catch ME
    fprintf('✗ Error in setup: %s\n', ME.message);
    return;
end

%% Step 2: Create Parsim Inputs
fprintf('\n--- Step 2: Create Parsim Inputs ---\n');

try
    % Create array for parsim (just 2 simulations)
    numSims = 2;
    simInputArray = Simulink.SimulationInput.empty(0, numSims);
    
    % Create simulation inputs with different parameters
    for i = 1:numSims
        simInput = Simulink.SimulationInput(modelName);
        
        % Quick simulation parameters
        simInput = simInput.setModelParameter('StopTime', '0.05');  % Very short
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable all logging
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

%% Step 4: Analyze Results
fprintf('\n--- Step 4: Analyze Results ---\n');

totalWorkspaceSignals = 0;
totalSimscapeSignals = 0;

for simIdx = 1:length(parsimOutArray)
    fprintf('\nSimulation %d/%d Analysis:\n', simIdx, length(parsimOutArray));
    
    simOut = parsimOutArray(simIdx);
    if isempty(simOut)
        fprintf('  ✗ Empty output\n');
        continue;
    end
    
    % List all output fields
    outputFields = fieldnames(simOut);
    fprintf('  Output fields: %d\n', length(outputFields));
    for j = 1:length(outputFields)
        fprintf('    %d: %s\n', j, outputFields{j});
    end
    
    % Check workspace data (ToWorkspace blocks)
    if isfield(simOut, 'out') && ~isempty(simOut.out)
        outData = simOut.out;
        if isa(outData, 'Simulink.SimulationData.Dataset')
            workspaceCount = outData.numElements;
            fprintf('  ✓ Workspace signals: %d\n', workspaceCount);
            totalWorkspaceSignals = workspaceCount;
            
            % Show some signal names
            if workspaceCount > 0
                fprintf('    Sample workspace signals:\n');
                for k = 1:min(5, workspaceCount)
                    try
                        element = outData.getElement(k);
                        fprintf('      %d: %s\n', k, element.Name);
                    catch
                        fprintf('      %d: [Error accessing]\n', k);
                    end
                end
                if workspaceCount > 5
                    fprintf('      ... and %d more\n', workspaceCount - 5);
                end
            end
        else
            fprintf('  ✓ Workspace data: present (%s)\n', class(outData));
        end
    else
        fprintf('  ✗ No workspace data found\n');
    end
    
    % Check Simscape data
    if isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
        simscapeData = simOut.simscape;
        if isstruct(simscapeData)
            simscapeCount = length(fieldnames(simscapeData));
            fprintf('  ✓ Simscape signals: %d\n', simscapeCount);
            totalSimscapeSignals = simscapeCount;
            
            % Show some simscape field names
            if simscapeCount > 0
                simscapeFields = fieldnames(simscapeData);
                fprintf('    Sample simscape fields:\n');
                for k = 1:min(5, simscapeCount)
                    fprintf('      %d: %s\n', k, simscapeFields{k});
                end
                if simscapeCount > 5
                    fprintf('      ... and %d more\n', simscapeCount - 5);
                end
            end
        elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
            simscapeCount = simscapeData.numElements;
            fprintf('  ✓ Simscape signals: %d\n', simscapeCount);
            totalSimscapeSignals = simscapeCount;
        else
            fprintf('  ✓ Simscape data: present (%s)\n', class(simscapeData));
        end
    else
        fprintf('  ✗ No Simscape data found\n');
    end
end

%% Step 5: Summary
fprintf('\n--- Step 5: Summary ---\n');

totalSignals = totalWorkspaceSignals + totalSimscapeSignals;

fprintf('🎯 QUICK PARSIM TEST RESULTS:\n\n');

fprintf('Data Capture Summary:\n');
fprintf('  Workspace signals (ToWorkspace blocks): %d\n', totalWorkspaceSignals);
fprintf('  Simscape signals (Results Explorer): %d\n', totalSimscapeSignals);
fprintf('  TOTAL SIGNALS PER SIMULATION: %d\n\n', totalSignals);

% Check if we have the expected amount
if totalSignals >= 590
    fprintf('✅ EXCELLENT: All expected data captured!\n');
    fprintf('✅ SUCCESS: Parsim is working perfectly!\n');
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
    
    fprintf('Recommendation: Check logging configuration\n');
end

%% Step 6: Save Results
fprintf('\n--- Step 6: Save Results ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('QuickParsimTest_%s', timestamp);
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
    testResults.parsimOutArray = parsimOutArray;
    
    % Save results
    resultsFilename = fullfile(outputDir, 'quick_parsim_test_results.mat');
    save(resultsFilename, 'testResults');
    fprintf('✓ Test results saved to: %s\n', resultsFilename);
    
catch ME
    fprintf('✗ Error saving results: %s\n', ME.message);
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Quick parsim test finished! 🚀\n'); 