% testIndividualSimulationLogging.m
% Test if individual sim() calls can capture logged data
% This will help us understand what's actually working

clear; clc;

fprintf('=== Testing Individual Simulation Logging ===\n\n');
fprintf('This script will test:\n');
fprintf('1. Individual sim() with different logging configurations\n');
fprintf('2. What parameters actually work for data capture\n');
fprintf('3. Whether the issue is with sim() or parsim()\n\n');

%% Test 1: Basic sim() with minimal parameters
fprintf('--- Test 1: Basic sim() with minimal parameters ---\n');

try
    % Load model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Create basic simulation input
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Run basic simulation
    fprintf('Running basic simulation...\n');
    basicOut = sim(simInput);
    fprintf('✓ Basic simulation completed\n');
    
    % Analyze output
    basicFields = fieldnames(basicOut);
    fprintf('Basic simulation output fields: %d\n', length(basicFields));
    for i = 1:length(basicFields)
        fieldName = basicFields{i};
        fieldValue = basicOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        if ~isempty(fieldValue)
            fprintf('    Type: %s\n', class(fieldValue));
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error in basic simulation: %s\n', ME.message);
end

%% Test 2: sim() with explicit signal logging
fprintf('\n--- Test 2: sim() with explicit signal logging ---\n');

try
    % Create simulation input with signal logging
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Add signal logging parameters
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    % Run simulation with signal logging
    fprintf('Running simulation with signal logging...\n');
    signalOut = sim(simInput);
    fprintf('✓ Signal logging simulation completed\n');
    
    % Analyze output
    signalFields = fieldnames(signalOut);
    fprintf('Signal logging simulation output fields: %d\n', length(signalFields));
    for i = 1:length(signalFields)
        fieldName = signalFields{i};
        fieldValue = signalOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        if ~isempty(fieldValue)
            fprintf('    Type: %s\n', class(fieldValue));
            if isa(fieldValue, 'Simulink.SimulationData.Dataset')
                fprintf('    Elements: %d\n', fieldValue.numElements);
            end
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error in signal logging simulation: %s\n', ME.message);
end

%% Test 3: sim() with Simscape logging
fprintf('\n--- Test 3: sim() with Simscape logging ---\n');

try
    % Create simulation input with Simscape logging
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Add Simscape logging parameters
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    
    % Run simulation with Simscape logging
    fprintf('Running simulation with Simscape logging...\n');
    simscapeOut = sim(simInput);
    fprintf('✓ Simscape logging simulation completed\n');
    
    % Analyze output
    simscapeFields = fieldnames(simscapeOut);
    fprintf('Simscape logging simulation output fields: %d\n', length(simscapeFields));
    for i = 1:length(simscapeFields)
        fieldName = simscapeFields{i};
        fieldValue = simscapeOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        if ~isempty(fieldValue)
            fprintf('    Type: %s\n', class(fieldValue));
            if isa(fieldValue, 'Simulink.SimulationData.Dataset')
                fprintf('    Elements: %d\n', fieldValue.numElements);
            elseif isstruct(fieldValue)
                fprintf('    Struct fields: %d\n', length(fieldnames(fieldValue)));
            end
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error in Simscape logging simulation: %s\n', ME.message);
end

%% Test 4: Check model configuration directly
fprintf('\n--- Test 4: Check model configuration directly ---\n');

try
    % Check current model parameters
    fprintf('Current model parameters:\n');
    fprintf('  SignalLogging: %s\n', get_param(modelName, 'SignalLogging'));
    fprintf('  SignalLoggingName: %s\n', get_param(modelName, 'SignalLoggingName'));
    fprintf('  SignalLoggingSaveFormat: %s\n', get_param(modelName, 'SignalLoggingSaveFormat'));
    fprintf('  SimscapeLogType: %s\n', get_param(modelName, 'SimscapeLogType'));
    fprintf('  SimscapeLogName: %s\n', get_param(modelName, 'SimscapeLogName'));
    
    % Check if signals are actually logged in the model
    fprintf('\nChecking for logged signals in model...\n');
    
    % Look for signal logging blocks
    signalLoggingBlocks = find_system(modelName, 'BlockType', 'ToWorkspace');
    fprintf('  ToWorkspace blocks found: %d\n', length(signalLoggingBlocks));
    for i = 1:min(5, length(signalLoggingBlocks))
        fprintf('    Block %d: %s\n', i, signalLoggingBlocks{i});
    end
    
    % Look for signal logging configuration
    signalLoggingConfig = get_param(modelName, 'SignalLogging');
    fprintf('  SignalLogging configuration: %s\n', signalLoggingConfig);
    
catch ME
    fprintf('✗ Error checking model configuration: %s\n', ME.message);
end

%% Test 5: Try setting model parameters directly
fprintf('\n--- Test 5: Set model parameters directly ---\n');

try
    % Set model parameters directly
    fprintf('Setting model parameters directly...\n');
    set_param(modelName, 'SignalLogging', 'on');
    set_param(modelName, 'SignalLoggingName', 'out');
    set_param(modelName, 'SignalLoggingSaveFormat', 'Dataset');
    set_param(modelName, 'SimscapeLogType', 'all');
    set_param(modelName, 'SimscapeLogName', 'simscape');
    fprintf('✓ Model parameters set\n');
    
    % Run simulation with model-level configuration
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    fprintf('Running simulation with model-level configuration...\n');
    modelOut = sim(simInput);
    fprintf('✓ Model-level configuration simulation completed\n');
    
    % Analyze output
    modelFields = fieldnames(modelOut);
    fprintf('Model-level configuration output fields: %d\n', length(modelFields));
    for i = 1:length(modelFields)
        fieldName = modelFields{i};
        fieldValue = modelOut.(fieldName);
        fprintf('  Field %d: %s\n', i, fieldName);
        if ~isempty(fieldValue)
            fprintf('    Type: %s\n', class(fieldValue));
            if isa(fieldValue, 'Simulink.SimulationData.Dataset')
                fprintf('    Elements: %d\n', fieldValue.numElements);
            elseif isstruct(fieldValue)
                fprintf('    Struct fields: %d\n', length(fieldnames(fieldValue)));
            end
        else
            fprintf('    Type: Empty\n');
        end
    end
    
catch ME
    fprintf('✗ Error in model-level configuration test: %s\n', ME.message);
end

%% Summary
fprintf('\n--- Summary ---\n');

fprintf('🎯 INDIVIDUAL SIMULATION LOGGING TEST RESULTS:\n\n');

% Check if any test captured data
testsWithData = 0;
if exist('basicOut', 'var') && isfield(basicOut, 'out')
    testsWithData = testsWithData + 1;
    fprintf('✅ Basic test: Captured data\n');
else
    fprintf('❌ Basic test: No data captured\n');
end

if exist('signalOut', 'var') && isfield(signalOut, 'out')
    testsWithData = testsWithData + 1;
    fprintf('✅ Signal logging test: Captured data\n');
else
    fprintf('❌ Signal logging test: No data captured\n');
end

if exist('simscapeOut', 'var') && isfield(simscapeOut, 'simscape')
    testsWithData = testsWithData + 1;
    fprintf('✅ Simscape logging test: Captured data\n');
else
    fprintf('❌ Simscape logging test: No data captured\n');
end

if exist('modelOut', 'var') && (isfield(modelOut, 'out') || isfield(modelOut, 'simscape'))
    testsWithData = testsWithData + 1;
    fprintf('✅ Model-level configuration test: Captured data\n');
else
    fprintf('❌ Model-level configuration test: No data captured\n');
end

fprintf('\nTotal tests with data capture: %d/4\n', testsWithData);

if testsWithData == 0
    fprintf('\n🚨 CRITICAL ISSUE: No individual sim() calls are capturing data!\n');
    fprintf('This means the problem is NOT with parsim - it is with the logging setup itself.\n');
    fprintf('We need to fix the basic logging configuration before parsim can work.\n');
else
    fprintf('\n✅ Some individual sim() calls are working!\n');
    fprintf('We can use the working configuration for parsim.\n');
end

fprintf('\nIndividual simulation logging test finished! 🔍\n'); 