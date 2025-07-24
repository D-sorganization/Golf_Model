% debugParsimDataCapture.m
% Deep dive debug script to examine exactly what parsim captures
% Focus on logged signal bus signals and Simscape Results Explorer data

clear; clc;

fprintf('=== Deep Dive Parsim Data Capture Debug ===\n\n');
fprintf('This script will examine:\n');
fprintf('1. What parsim actually captures vs. individual sim()\n');
fprintf('2. Logged signal bus signals (your manually logged signals)\n');
fprintf('3. Simscape Results Explorer data\n');
fprintf('4. All available output fields and their contents\n\n');

%% Step 1: Run Individual Simulation for Comparison
fprintf('--- Step 1: Individual Simulation (Baseline) ---\n');

try
    % Load model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Create simulation input with complete logging
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable ALL logging parameters
    simInput = simInput.setModelParameter('SaveOutput', 'on');
    simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    simInput = simInput.setModelParameter('SaveState', 'on');
    simInput = simInput.setModelParameter('StateSaveName', 'xout');
    
    % Run individual simulation
    fprintf('Running individual simulation...\n');
    individualOut = sim(simInput);
    fprintf('✓ Individual simulation completed\n');
    
    % Analyze individual simulation output
    fprintf('\nIndividual Simulation Output Analysis:\n');
    individualFields = fieldnames(individualOut);
    fprintf('Total output fields: %d\n', length(individualFields));
    
    for i = 1:length(individualFields)
        fieldName = individualFields{i};
        fieldValue = individualOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        
        if ~isempty(fieldValue)
            if isa(fieldValue, 'Simulink.SimulationData.Dataset')
                fprintf('    Type: Dataset with %d elements\n', fieldValue.numElements);
            elseif isstruct(fieldValue)
                fprintf('    Type: Struct with %d fields\n', length(fieldnames(fieldValue)));
            else
                fprintf('    Type: %s\n', class(fieldValue));
            end
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error in individual simulation: %s\n', ME.message);
    return;
end

%% Step 2: Run Parsim Simulation
fprintf('\n--- Step 2: Parsim Simulation (Test) ---\n');

try
    % Create array for parsim
    simInputArray = Simulink.SimulationInput.empty(0, 2);
    
    % Create two identical simulation inputs
    for i = 1:2
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.1');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Enable ALL logging parameters (same as individual)
        simInput = simInput.setModelParameter('SaveOutput', 'on');
        simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');
        simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
        simInput = simInput.setModelParameter('SaveState', 'on');
        simInput = simInput.setModelParameter('StateSaveName', 'xout');
        
        simInputArray(i) = simInput;
    end
    
    % Run parsim
    fprintf('Running parsim simulation...\n');
    parsimOutArray = parsim(simInputArray, 'ShowProgress', 'on');
    fprintf('✓ Parsim simulation completed\n');
    
    % Analyze parsim simulation output
    fprintf('\nParsim Simulation Output Analysis:\n');
    
    for simIdx = 1:length(parsimOutArray)
        fprintf('\nSimulation %d/%d:\n', simIdx, length(parsimOutArray));
        
        simOut = parsimOutArray(simIdx);
        if isempty(simOut)
            fprintf('  ✗ Empty output\n');
            continue;
        end
        
        parsimFields = fieldnames(simOut);
        fprintf('  Total output fields: %d\n', length(parsimFields));
        
        for i = 1:length(parsimFields)
            fieldName = parsimFields{i};
            fieldValue = simOut.(fieldName);
            fprintf('    Field %d: %s\n', i, fieldName);
            
            if ~isempty(fieldValue)
                if isa(fieldValue, 'Simulink.SimulationData.Dataset')
                    fprintf('      Type: Dataset with %d elements\n', fieldValue.numElements);
                elseif isstruct(fieldValue)
                    fprintf('      Type: Struct with %d fields\n', length(fieldnames(fieldValue)));
                else
                    fprintf('      Type: %s\n', class(fieldValue));
                end
            else
                fprintf('      Type: Empty\n');
            end
        end
    end
    
catch ME
    fprintf('✗ Error in parsim simulation: %s\n', ME.message);
    return;
end

%% Step 3: Detailed Comparison
fprintf('\n--- Step 3: Detailed Data Comparison ---\n');

% Compare individual vs parsim
fprintf('Comparing individual vs parsim output:\n');

% Check for 'out' field (Data Inspector signals)
if isfield(individualOut, 'out') && ~isempty(individualOut.out)
    individualOutCount = individualOut.out.numElements;
    fprintf('  Individual simulation - Data Inspector signals: %d\n', individualOutCount);
else
    individualOutCount = 0;
    fprintf('  Individual simulation - No Data Inspector signals\n');
end

% Check parsim for 'out' field
parsimOutCount = 0;
for simIdx = 1:length(parsimOutArray)
    simOut = parsimOutArray(simIdx);
    if ~isempty(simOut) && isfield(simOut, 'out') && ~isempty(simOut.out)
        parsimOutCount = simOut.out.numElements;
        fprintf('  Parsim simulation %d - Data Inspector signals: %d\n', simIdx, parsimOutCount);
    else
        fprintf('  Parsim simulation %d - No Data Inspector signals\n', simIdx);
    end
end

% Check for 'simscape' field (Simscape Results Explorer)
if isfield(individualOut, 'simscape') && ~isempty(individualOut.simscape)
    fprintf('  Individual simulation - Simscape data: PRESENT\n');
    individualSimscape = individualOut.simscape;
    if isstruct(individualSimscape)
        fprintf('    Simscape fields: %d\n', length(fieldnames(individualSimscape)));
    elseif isa(individualSimscape, 'Simulink.SimulationData.Dataset')
        fprintf('    Simscape elements: %d\n', individualSimscape.numElements);
    end
else
    fprintf('  Individual simulation - No Simscape data\n');
end

% Check parsim for 'simscape' field
for simIdx = 1:length(parsimOutArray)
    simOut = parsimOutArray(simIdx);
    if ~isempty(simOut) && isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
        fprintf('  Parsim simulation %d - Simscape data: PRESENT\n', simIdx);
        parsimSimscape = simOut.simscape;
        if isstruct(parsimSimscape)
            fprintf('    Simscape fields: %d\n', length(fieldnames(parsimSimscape)));
        elseif isa(parsimSimscape, 'Simulink.SimulationData.Dataset')
            fprintf('    Simscape elements: %d\n', parsimSimscape.numElements);
        end
    else
        fprintf('  Parsim simulation %d - No Simscape data\n', simIdx);
    end
end

%% Step 4: Examine Signal Bus Data
fprintf('\n--- Step 4: Signal Bus Data Analysis ---\n');

% Look for signal bus data in individual simulation
fprintf('Individual simulation signal bus analysis:\n');
if individualOutCount > 0
    try
        logsout = individualOut.out;
        fprintf('  Total logged signals: %d\n', logsout.numElements);
        
        % Look for signal bus patterns
        signalBusCount = 0;
        for i = 1:min(20, logsout.numElements)  % Check first 20 signals
            try
                signal = logsout.getElement(i);
                signalName = signal.Name;
                if contains(signalName, 'Bus') || contains(signalName, 'bus')
                    signalBusCount = signalBusCount + 1;
                    fprintf('    Signal bus found: %s\n', signalName);
                end
            catch
                % Skip if can't access signal
            end
        end
        fprintf('  Signal bus signals found: %d (in first 20)\n', signalBusCount);
        
    catch ME
        fprintf('  Error analyzing signal bus data: %s\n', ME.message);
    end
else
    fprintf('  No Data Inspector signals to analyze\n');
end

% Look for signal bus data in parsim
fprintf('\nParsim simulation signal bus analysis:\n');
for simIdx = 1:length(parsimOutArray)
    simOut = parsimOutArray(simIdx);
    if ~isempty(simOut) && isfield(simOut, 'out') && ~isempty(simOut.out)
        try
            logsout = simOut.out;
            fprintf('  Simulation %d - Total logged signals: %d\n', simIdx, logsout.numElements);
            
            % Look for signal bus patterns
            signalBusCount = 0;
            for i = 1:min(20, logsout.numElements)  % Check first 20 signals
                try
                    signal = logsout.getElement(i);
                    signalName = signal.Name;
                    if contains(signalName, 'Bus') || contains(signalName, 'bus')
                        signalBusCount = signalBusCount + 1;
                        fprintf('    Signal bus found: %s\n', signalName);
                    end
                catch
                    % Skip if can't access signal
                end
            end
            fprintf('  Simulation %d - Signal bus signals found: %d (in first 20)\n', simIdx, signalBusCount);
            
        catch ME
            fprintf('  Simulation %d - Error analyzing signal bus data: %s\n', simIdx, ME.message);
        end
    else
        fprintf('  Simulation %d - No Data Inspector signals to analyze\n', simIdx);
    end
end

%% Step 5: Examine Simscape Results Explorer Data
fprintf('\n--- Step 5: Simscape Results Explorer Analysis ---\n');

% Individual simulation Simscape analysis
fprintf('Individual simulation Simscape analysis:\n');
if isfield(individualOut, 'simscape') && ~isempty(individualOut.simscape)
    simscapeData = individualOut.simscape;
    if isstruct(simscapeData)
        simscapeFields = fieldnames(simscapeData);
        fprintf('  Simscape fields: %d\n', length(simscapeFields));
        for i = 1:min(10, length(simscapeFields))  % Show first 10
            fprintf('    Field %d: %s\n', i, simscapeFields{i});
        end
        if length(simscapeFields) > 10
            fprintf('    ... and %d more fields\n', length(simscapeFields) - 10);
        end
    elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
        fprintf('  Simscape dataset elements: %d\n', simscapeData.numElements);
        for i = 1:min(10, simscapeData.numElements)  % Show first 10
            try
                element = simscapeData.getElement(i);
                fprintf('    Element %d: %s\n', i, element.Name);
            catch
                fprintf('    Element %d: [Error accessing]\n', i);
            end
        end
        if simscapeData.numElements > 10
            fprintf('    ... and %d more elements\n', simscapeData.numElements - 10);
        end
    end
else
    fprintf('  No Simscape data found\n');
end

% Parsim simulation Simscape analysis
fprintf('\nParsim simulation Simscape analysis:\n');
for simIdx = 1:length(parsimOutArray)
    simOut = parsimOutArray(simIdx);
    if ~isempty(simOut) && isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
        fprintf('  Simulation %d:\n', simIdx);
        simscapeData = simOut.simscape;
        if isstruct(simscapeData)
            simscapeFields = fieldnames(simscapeData);
            fprintf('    Simscape fields: %d\n', length(simscapeFields));
        elseif isa(simscapeData, 'Simulink.SimulationData.Dataset')
            fprintf('    Simscape dataset elements: %d\n', simscapeData.numElements);
        end
    else
        fprintf('  Simulation %d - No Simscape data found\n', simIdx);
    end
end

%% Step 6: Save Debug Results
fprintf('\n--- Step 6: Saving Debug Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('ParsimDebug_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save debug results
debugResults = struct();
debugResults.timestamp = timestamp;
debugResults.individualOut = individualOut;
debugResults.parsimOutArray = parsimOutArray;
debugResults.individualOutCount = individualOutCount;
debugResults.parsimOutCount = parsimOutCount;

% Save results
resultsFilename = fullfile(outputDir, 'parsim_debug_results.mat');
save(resultsFilename, 'debugResults');
fprintf('✓ Debug results saved to: %s\n', resultsFilename);

%% Step 7: Summary
fprintf('\n--- Step 7: Debug Summary ---\n');

fprintf('🎯 PARSIM DEBUG SUMMARY:\n\n');

% Data Inspector signals comparison
if individualOutCount > 0 && parsimOutCount > 0
    fprintf('✅ Data Inspector signals: BOTH individual and parsim captured data\n');
    fprintf('   Individual: %d signals\n', individualOutCount);
    fprintf('   Parsim: %d signals\n', parsimOutCount);
elseif individualOutCount > 0 && parsimOutCount == 0
    fprintf('❌ Data Inspector signals: Individual captured, parsim FAILED\n');
    fprintf('   Individual: %d signals\n', individualOutCount);
    fprintf('   Parsim: 0 signals\n');
elseif individualOutCount == 0 && parsimOutCount > 0
    fprintf('⚠️  Data Inspector signals: Parsim captured, individual FAILED\n');
    fprintf('   Individual: 0 signals\n');
    fprintf('   Parsim: %d signals\n', parsimOutCount);
else
    fprintf('❌ Data Inspector signals: BOTH individual and parsim FAILED\n');
end

% Simscape data comparison
individualHasSimscape = isfield(individualOut, 'simscape') && ~isempty(individualOut.simscape);
parsimHasSimscape = false;
for simIdx = 1:length(parsimOutArray)
    simOut = parsimOutArray(simIdx);
    if ~isempty(simOut) && isfield(simOut, 'simscape') && ~isempty(simOut.simscape)
        parsimHasSimscape = true;
        break;
    end
end

if individualHasSimscape && parsimHasSimscape
    fprintf('✅ Simscape data: BOTH individual and parsim captured data\n');
elseif individualHasSimscape && ~parsimHasSimscape
    fprintf('❌ Simscape data: Individual captured, parsim FAILED\n');
elseif ~individualHasSimscape && parsimHasSimscape
    fprintf('⚠️  Simscape data: Parsim captured, individual FAILED\n');
else
    fprintf('❌ Simscape data: BOTH individual and parsim FAILED\n');
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Deep dive debug finished! 🔍\n'); 