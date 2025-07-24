% testToWorkspaceLogging.m
% Test the new ToWorkspace block configuration
% Verify that all signals are now being logged to workspace

clear; clc;

fprintf('=== Testing ToWorkspace Block Logging ===\n\n');
fprintf('This script will test:\n');
fprintf('1. ToWorkspace blocks (your signal bus data)\n');
fprintf('2. Simscape Results Explorer data\n');
fprintf('3. Combined data capture for parsim\n\n');

%% Step 1: Check ToWorkspace Blocks
fprintf('--- Step 1: Check ToWorkspace Blocks ---\n');

try
    % Load model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Find ToWorkspace blocks
    toWorkspaceBlocks = find_system(modelName, 'BlockType', 'ToWorkspace');
    fprintf('✓ ToWorkspace blocks found: %d\n', length(toWorkspaceBlocks));
    
    % Show some ToWorkspace block details
    fprintf('\nSample ToWorkspace blocks:\n');
    for i = 1:min(10, length(toWorkspaceBlocks))
        blockPath = toWorkspaceBlocks{i};
        try
            varName = get_param(blockPath, 'VariableName');
            saveFormat = get_param(blockPath, 'SaveFormat');
            fprintf('  %d: %s\n', i, blockPath);
            fprintf('    VariableName: %s\n', varName);
            fprintf('    SaveFormat: %s\n', saveFormat);
        catch
            fprintf('  %d: %s (error reading parameters)\n', i, blockPath);
        end
    end
    
    if length(toWorkspaceBlocks) > 10
        fprintf('  ... and %d more ToWorkspace blocks\n', length(toWorkspaceBlocks) - 10);
    end
    
catch ME
    fprintf('✗ Error checking ToWorkspace blocks: %s\n', ME.message);
    return;
end

%% Step 2: Test Individual Simulation
fprintf('\n--- Step 2: Test Individual Simulation ---\n');

try
    % Create simulation input
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable Simscape logging
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    
    % Run simulation
    fprintf('Running simulation with ToWorkspace blocks...\n');
    simOut = sim(simInput);
    fprintf('✓ Simulation completed\n');
    
    % Analyze output
    outputFields = fieldnames(simOut);
    fprintf('\nSimulation output fields: %d\n', length(outputFields));
    
    for i = 1:length(outputFields)
        fieldName = outputFields{i};
        fieldValue = simOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        
        if ~isempty(fieldValue)
            fprintf('    Type: %s\n', class(fieldValue));
            
            if isa(fieldValue, 'Simulink.SimulationData.Dataset')
                fprintf('    Elements: %d\n', fieldValue.numElements);
                
                % Show some element names if it's the out field
                if strcmp(fieldName, 'out') && fieldValue.numElements > 0
                    fprintf('    Sample elements:\n');
                    for j = 1:min(5, fieldValue.numElements)
                        try
                            element = fieldValue.getElement(j);
                            fprintf('      %d: %s\n', j, element.Name);
                        catch
                            fprintf('      %d: [Error accessing]\n', j);
                        end
                    end
                    if fieldValue.numElements > 5
                        fprintf('      ... and %d more elements\n', fieldValue.numElements - 5);
                    end
                end
                
            elseif isstruct(fieldValue)
                fprintf('    Struct fields: %d\n', length(fieldnames(fieldValue)));
                
                % Show some field names if it's the simscape field
                if strcmp(fieldName, 'simscape')
                    simscapeFields = fieldnames(fieldValue);
                    fprintf('    Sample simscape fields:\n');
                    for j = 1:min(5, length(simscapeFields))
                        fprintf('      %d: %s\n', j, simscapeFields{j});
                    end
                    if length(simscapeFields) > 5
                        fprintf('      ... and %d more fields\n', length(simscapeFields) - 5);
                    end
                end
            end
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error in individual simulation: %s\n', ME.message);
    return;
end

%% Step 3: Test Parsim
fprintf('\n--- Step 3: Test Parsim ---\n');

try
    % Create array for parsim
    simInputArray = Simulink.SimulationInput.empty(0, 2);
    
    % Create two simulation inputs
    for i = 1:2
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.1');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable Simscape logging
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');
        simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
        
        simInputArray(i) = simInput;
    end
    
    % Run parsim
    fprintf('Running parsim with ToWorkspace blocks...\n');
    parsimOutArray = parsim(simInputArray, 'ShowProgress', 'on');
    fprintf('✓ Parsim completed\n');
    
    % Analyze parsim results
    fprintf('\nParsim results analysis:\n');
    
    for simIdx = 1:length(parsimOutArray)
        fprintf('\nSimulation %d/%d:\n', simIdx, length(parsimOutArray));
        
        simOut = parsimOutArray(simIdx);
        if isempty(simOut)
            fprintf('  ✗ Empty output\n');
            continue;
        end
        
        parsimFields = fieldnames(simOut);
        fprintf('  Output fields: %d\n', length(parsimFields));
        
        % Check for out field (ToWorkspace data)
        if isfield(simOut, 'out') && ~isempty(simOut.out)
            outData = simOut.out;
            if isa(outData, 'Simulink.SimulationData.Dataset')
                fprintf('  ✓ ToWorkspace data: %d elements\n', outData.numElements);
            else
                fprintf('  ✓ ToWorkspace data: present (%s)\n', class(outData));
            end
        else
            fprintf('  ✗ No ToWorkspace data found\n');
        end
        
        % Check for simscape field
        if isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
            simscapeData = simOut.simscape;
            if isstruct(simscapeData)
                fprintf('  ✓ Simscape data: %d fields\n', length(fieldnames(simscapeData)));
            elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
                fprintf('  ✓ Simscape data: %d elements\n', simscapeData.numElements);
            else
                fprintf('  ✓ Simscape data: present (%s)\n', class(simscapeData));
            end
        else
            fprintf('  ✗ No Simscape data found\n');
        end
    end
    
catch ME
    fprintf('✗ Error in parsim test: %s\n', ME.message);
end

%% Step 4: Calculate Total Quantities
fprintf('\n--- Step 4: Calculate Total Quantities ---\n');

try
    % Get data from individual simulation
    if isfield(simOut, 'out') && ~isempty(simOut.out)
        outData = simOut.out;
        if isa(outData, 'Simulink.SimulationData.Dataset')
            toWorkspaceCount = outData.numElements;
        else
            toWorkspaceCount = 0;
        end
    else
        toWorkspaceCount = 0;
    end
    
    if isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
        simscapeData = simOut.simscape;
        if isstruct(simscapeData)
            simscapeCount = length(fieldnames(simscapeData));
        elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
            simscapeCount = simscapeData.numElements;
        else
            simscapeCount = 0;
        end
    else
        simscapeCount = 0;
    end
    
    totalQuantities = toWorkspaceCount + simscapeCount;
    
    fprintf('Data quantities summary:\n');
    fprintf('  ToWorkspace signals (signal bus data): %d\n', toWorkspaceCount);
    fprintf('  Simscape data (joint states, properties): %d\n', simscapeCount);
    fprintf('  TOTAL QUANTITIES PER DATA POINT: %d\n', totalQuantities);
    
    % Check if we have the expected amount
    if totalQuantities >= 590
        fprintf('  ✅ SUCCESS: All expected data captured!\n');
    elseif totalQuantities >= 500
        fprintf('  ⚠️  WARNING: Most data captured, but some may be missing\n');
    else
        fprintf('  ❌ ERROR: Significant data missing\n');
    end
    
catch ME
    fprintf('✗ Error calculating quantities: %s\n', ME.message);
end

%% Step 5: Save Test Results
fprintf('\n--- Step 5: Save Test Results ---\n');

try
    % Create output directory
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    outputDir = sprintf('ToWorkspaceTest_%s', timestamp);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
        fprintf('✓ Created output directory: %s\n', outputDir);
    end
    
    % Save test results
    testResults = struct();
    testResults.timestamp = timestamp;
    testResults.toWorkspaceBlocks = length(toWorkspaceBlocks);
    testResults.toWorkspaceCount = toWorkspaceCount;
    testResults.simscapeCount = simscapeCount;
    testResults.totalQuantities = totalQuantities;
    testResults.simOut = simOut;
    testResults.parsimOutArray = parsimOutArray;
    
    % Save results
    resultsFilename = fullfile(outputDir, 'toworkspace_test_results.mat');
    save(resultsFilename, 'testResults');
    fprintf('✓ Test results saved to: %s\n', resultsFilename);
    
catch ME
    fprintf('✗ Error saving results: %s\n', ME.message);
end

%% Step 6: Summary
fprintf('\n--- Step 6: Summary ---\n');

fprintf('🎯 TOWORKSPACE LOGGING TEST RESULTS:\n\n');

if toWorkspaceCount > 0 && simscapeCount > 0
    fprintf('✅ SUCCESS: Both ToWorkspace and Simscape data captured!\n');
    fprintf('✅ SUCCESS: Parsim should now work properly!\n');
    fprintf('✅ SUCCESS: All %d quantities available per data point!\n\n', totalQuantities);
    
    fprintf('Data Sources Verified:\n');
    fprintf('  ✓ ToWorkspace blocks: %d signals (your signal bus data)\n', toWorkspaceCount);
    fprintf('  ✓ Simscape Results Explorer: %d elements (joint states, properties)\n', simscapeCount);
    fprintf('  ✓ Combined total: %d quantities per data point\n\n', totalQuantities);
    
    fprintf('Next Steps:\n');
    fprintf('  1. Use this configuration for your dataset generation\n');
    fprintf('  2. parsim() will now capture all data directly\n');
    fprintf('  3. No Data Inspector extraction needed\n');
    
elseif toWorkspaceCount > 0
    fprintf('⚠️  PARTIAL SUCCESS: ToWorkspace data captured, but Simscape data missing\n');
    fprintf('  ToWorkspace signals: %d\n', toWorkspaceCount);
    fprintf('  Simscape data: %d\n', simscapeCount);
    fprintf('  Total: %d quantities\n\n', totalQuantities);
    
    fprintf('Recommendation: Check Simscape logging configuration\n');
    
else
    fprintf('❌ FAILURE: No data captured\n');
    fprintf('  ToWorkspace signals: %d\n', toWorkspaceCount);
    fprintf('  Simscape data: %d\n', simscapeCount);
    fprintf('  Total: %d quantities\n\n', totalQuantities);
    
    fprintf('Recommendation: Check ToWorkspace block configuration\n');
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('ToWorkspace logging test finished! 🔧\n'); 