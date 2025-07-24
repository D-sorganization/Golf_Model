% debugParsimEnvironment.m
% Deep dive debugging of parallel simulation environment
% Systematically investigate why parsim isn't capturing Data Inspector signals
% while individual sim() calls work perfectly

clear; clc;

fprintf('=== Deep Dive: Parallel Simulation Environment Debug ===\n\n');
fprintf('This script will systematically debug:\n');
fprintf('1. Parallel worker environment setup\n');
fprintf('2. Model parameter transfer to parallel workers\n');
fprintf('3. Signal logging configuration in parallel environment\n');
fprintf('4. Data capture differences between sim() and parsim()\n');
fprintf('5. Worker-specific logging behavior\n\n');

%% Step 1: Environment Analysis
fprintf('--- Step 1: Parallel Environment Analysis ---\n');

% Check parallel pool status
pool = gcp('nocreate');
if isempty(pool)
    fprintf('⚠️  No parallel pool found. Creating one...\n');
    pool = parpool('local', 2);  % Start with 2 workers for testing
    fprintf('✓ Created parallel pool with %d workers\n', pool.NumWorkers);
else
    fprintf('✓ Parallel pool already exists with %d workers\n', pool.NumWorkers);
end

% Check worker environment
fprintf('\nWorker environment check:\n');
spmd
    workerID = labindex;
    fprintf('  Worker %d: MATLAB version %s\n', workerID, version);
    fprintf('  Worker %d: Current directory: %s\n', workerID, pwd);
    
    % Check if model is accessible on workers
    try
        modelName = 'GolfSwing3D_Kinetic';
        if ~bdIsLoaded(modelName)
            load_system(modelName);
            fprintf('  Worker %d: ✓ Model loaded successfully\n', workerID);
        else
            fprintf('  Worker %d: ✓ Model already loaded\n', workerID);
        end
    catch ME
        fprintf('  Worker %d: ✗ Error loading model: %s\n', workerID, ME.message);
    end
end

%% Step 2: Model Parameter Transfer Test
fprintf('\n--- Step 2: Model Parameter Transfer Test ---\n');

% Test 1: Basic parameter transfer
fprintf('Test 1: Basic parameter transfer to workers...\n');
spmd
    workerID = labindex;
    try
        modelName = 'GolfSwing3D_Kinetic';
        
        % Test setting a simple parameter
        set_param(modelName, 'StopTime', '0.1');
        stopTime = get_param(modelName, 'StopTime');
        fprintf('  Worker %d: StopTime = %s\n', workerID, stopTime);
        
        % Test signal logging parameters
        set_param(modelName, 'SignalLogging', 'on');
        signalLogging = get_param(modelName, 'SignalLogging');
        fprintf('  Worker %d: SignalLogging = %s\n', workerID, signalLogging);
        
        set_param(modelName, 'SignalLoggingName', 'out');
        signalLoggingName = get_param(modelName, 'SignalLoggingName');
        fprintf('  Worker %d: SignalLoggingName = %s\n', workerID, signalLoggingName);
        
    catch ME
        fprintf('  Worker %d: ✗ Error in parameter test: %s\n', workerID, ME.message);
    end
end

%% Step 3: Individual Worker Simulation Test
fprintf('\n--- Step 3: Individual Worker Simulation Test ---\n');

% Test 2: Run simulation on individual workers
fprintf('Test 2: Running simulation on individual workers...\n');
spmd
    workerID = labindex;
    try
        modelName = 'GolfSwing3D_Kinetic';
        
        % Create simulation input
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.1');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        % Set signal logging parameters
        simInput = simInput.setModelParameter('SaveOutput', 'on');
        simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        fprintf('  Worker %d: Running simulation...\n', workerID);
        simOut = sim(simInput);
        
        % Check results
        if isfield(simOut, 'out') && ~isempty(simOut.out)
            signalCount = simOut.out.numElements;
            fprintf('  Worker %d: ✓ Data Inspector signals: %d\n', workerID, signalCount);
        else
            fprintf('  Worker %d: ✗ No Data Inspector signals found\n', workerID);
        end
        
        % Check other fields
        fields = fieldnames(simOut);
        fprintf('  Worker %d: Output fields: %s\n', workerID, strjoin(fields, ', '));
        
    catch ME
        fprintf('  Worker %d: ✗ Error in simulation: %s\n', workerID, ME.message);
    end
end

%% Step 4: Parsim vs Sim Comparison
fprintf('\n--- Step 4: Parsim vs Sim Comparison ---\n');

% Test 3: Compare parsim vs individual sim calls
fprintf('Test 3: Comparing parsim vs individual sim calls...\n');

% First, run individual sim calls
fprintf('Running individual sim calls...\n');
individualResults = cell(2, 1);
for i = 1:2
    try
        modelName = 'GolfSwing3D_Kinetic';
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.1');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        simInput = simInput.setModelParameter('SaveOutput', 'on');
        simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        simOut = sim(simInput);
        individualResults{i} = simOut;
        
        if isfield(simOut, 'out') && ~isempty(simOut.out)
            signalCount = simOut.out.numElements;
            fprintf('  Individual sim %d: ✓ Data Inspector signals: %d\n', i, signalCount);
        else
            fprintf('  Individual sim %d: ✗ No Data Inspector signals\n', i);
        end
        
    catch ME
        fprintf('  Individual sim %d: ✗ Error: %s\n', i, ME.message);
    end
end

% Now run parsim
fprintf('\nRunning parsim...\n');
try
    modelName = 'GolfSwing3D_Kinetic';
    
    % Create simulation input array
    simInputArray = Simulink.SimulationInput.empty(0, 2);
    
    for i = 1:2
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.1');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        simInput = simInput.setModelParameter('SaveOutput', 'on');
        simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        simInputArray(i) = simInput;
    end
    
    parsimResults = parsim(simInputArray, 'ShowProgress', 'on');
    
    % Compare results
    fprintf('\nComparison Results:\n');
    for i = 1:2
        fprintf('Simulation %d:\n', i);
        
        % Individual sim results
        if ~isempty(individualResults{i})
            if isfield(individualResults{i}, 'out') && ~isempty(individualResults{i}.out)
                indSignalCount = individualResults{i}.out.numElements;
                fprintf('  Individual sim: %d signals\n', indSignalCount);
            else
                fprintf('  Individual sim: No signals\n');
            end
        end
        
        % Parsim results
        if ~isempty(parsimResults) && length(parsimResults) >= i
            if isfield(parsimResults(i), 'out') && ~isempty(parsimResults(i).out)
                parSignalCount = parsimResults(i).out.numElements;
                fprintf('  Parsim: %d signals\n', parSignalCount);
            else
                fprintf('  Parsim: No signals\n');
            end
        end
        fprintf('\n');
    end
    
catch ME
    fprintf('✗ Error in parsim comparison: %s\n', ME.message);
end

%% Step 5: Model Configuration Analysis
fprintf('\n--- Step 5: Model Configuration Analysis ---\n');

% Check model configuration on main thread
fprintf('Analyzing model configuration on main thread...\n');
try
    modelName = 'GolfSwing3D_Kinetic';
    
    % Get current model parameters
    fprintf('Current model parameters:\n');
    fprintf('  SignalLogging: %s\n', get_param(modelName, 'SignalLogging'));
    fprintf('  SignalLoggingName: %s\n', get_param(modelName, 'SignalLoggingName'));
    fprintf('  SignalLoggingSaveFormat: %s\n', get_param(modelName, 'SignalLoggingSaveFormat'));
    fprintf('  SaveOutput: %s\n', get_param(modelName, 'SaveOutput'));
    fprintf('  SaveFormat: %s\n', get_param(modelName, 'SaveFormat'));
    
    % Check if model has any special configurations
    fprintf('\nModel configuration details:\n');
    
    % Check for any custom logging configurations
    try
        loggingConfig = get_param(modelName, 'DataLoggingOverride');
        fprintf('  DataLoggingOverride: %s\n', loggingConfig);
    catch
        fprintf('  DataLoggingOverride: Not available\n');
    end
    
    % Check for any Simscape-specific logging
    try
        simscapeLogType = get_param(modelName, 'SimscapeLogType');
        fprintf('  SimscapeLogType: %s\n', simscapeLogType);
    catch
        fprintf('  SimscapeLogType: Not available\n');
    end
    
catch ME
    fprintf('✗ Error analyzing model configuration: %s\n', ME.message);
end

%% Step 6: Worker-Specific Configuration Test
fprintf('\n--- Step 6: Worker-Specific Configuration Test ---\n');

% Test 4: Explicit configuration on workers
fprintf('Test 4: Explicit configuration on workers...\n');
spmd
    workerID = labindex;
    try
        modelName = 'GolfSwing3D_Kinetic';
        
        % Explicitly set all parameters on the model itself
        set_param(modelName, 'SignalLogging', 'on');
        set_param(modelName, 'SignalLoggingName', 'out');
        set_param(modelName, 'SignalLoggingSaveFormat', 'Dataset');
        set_param(modelName, 'SaveOutput', 'on');
        set_param(modelName, 'SaveFormat', 'Dataset');
        
        fprintf('  Worker %d: Set model parameters explicitly\n', workerID);
        
        % Verify parameters were set
        signalLogging = get_param(modelName, 'SignalLogging');
        signalLoggingName = get_param(modelName, 'SignalLoggingName');
        fprintf('  Worker %d: Verified SignalLogging=%s, Name=%s\n', workerID, signalLogging, signalLoggingName);
        
        % Run simulation with minimal Simulink.SimulationInput
        simInput = Simulink.SimulationInput(modelName);
        simInput = simInput.setModelParameter('StopTime', '0.1');
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001');
        
        simOut = sim(simInput);
        
        if isfield(simOut, 'out') && ~isempty(simOut.out)
            signalCount = simOut.out.numElements;
            fprintf('  Worker %d: ✓ Explicit config - Data Inspector signals: %d\n', workerID, signalCount);
        else
            fprintf('  Worker %d: ✗ Explicit config - No Data Inspector signals\n', workerID);
        end
        
    catch ME
        fprintf('  Worker %d: ✗ Error in explicit config test: %s\n', workerID, ME.message);
    end
end

%% Step 7: Data Inspector Access Test
fprintf('\n--- Step 7: Data Inspector Access Test ---\n');

% Test 5: Check if Data Inspector is accessible on workers
fprintf('Test 5: Data Inspector accessibility on workers...\n');
spmd
    workerID = labindex;
    try
        % Check if Data Inspector runs are available
        runIDs = Simulink.sdi.getAllRunIDs;
        fprintf('  Worker %d: Data Inspector runs available: %d\n', workerID, length(runIDs));
        
        if ~isempty(runIDs)
            % Try to access the most recent run
            run = Simulink.sdi.getRun(runIDs(end));
            signals = run.getAllSignals;
            fprintf('  Worker %d: Most recent run has %d signals\n', workerID, length(signals));
        end
        
    catch ME
        fprintf('  Worker %d: ✗ Error accessing Data Inspector: %s\n', workerID, ME.message);
    end
end

%% Step 8: Save Debug Results
fprintf('\n--- Step 8: Saving Debug Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('ParsimDebug_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save debug information
debugInfo = struct();
debugInfo.timestamp = timestamp;
debugInfo.poolSize = pool.NumWorkers;
debugInfo.individualResults = individualResults;
if exist('parsimResults', 'var')
    debugInfo.parsimResults = parsimResults;
end

% Save results
resultsFilename = fullfile(outputDir, 'parsim_debug_results.mat');
save(resultsFilename, 'debugInfo');
fprintf('✓ Debug results saved to: %s\n', resultsFilename);

%% Step 9: Summary and Recommendations
fprintf('\n--- Step 9: Summary and Recommendations ---\n');

fprintf('🎯 PARSIM ENVIRONMENT DEBUG SUMMARY:\n\n');

fprintf('Key Findings:\n');
fprintf('  • Parallel pool: %d workers\n', pool.NumWorkers);
fprintf('  • Model accessibility: Tested on workers\n');
fprintf('  • Parameter transfer: Tested\n');
fprintf('  • Individual vs parsim: Compared\n');
fprintf('  • Explicit configuration: Tested\n');
fprintf('  • Data Inspector access: Tested\n\n');

fprintf('Next Steps for Resolution:\n');
fprintf('  1. Analyze the debug output above\n');
fprintf('  2. Check for parameter transfer issues\n');
fprintf('  3. Verify worker environment consistency\n');
fprintf('  4. Test alternative parsim configurations\n');
fprintf('  5. Consider model-specific parallel limitations\n\n');

fprintf('Output directory: %s\n', outputDir);
fprintf('Deep dive debugging completed! 🔍\n'); 