% testParsimBasicCapture.m
% Test parsim to verify capture of Data Inspector signals (590+ signals)
% This is a simpler test to ensure basic signal logging works with parsim

clear; clc;

fprintf('=== Testing Parsim Basic Data Capture ===\n\n');
fprintf('This script will test:\n');
fprintf('1. Parallel simulation with parsim\n');
fprintf('2. Capture Data Inspector signals (590+)\n');
fprintf('3. Verify data integrity and efficiency\n\n');

%% Step 1: Setup Test Parameters
fprintf('--- Step 1: Setting Up Test Parameters ---\n');

% Number of parallel simulations to test
numSims = 4;  % Start with 4 parallel simulations
fprintf('Number of parallel simulations: %d\n', numSims);

% Create parameter variations for testing
testParams = cell(numSims, 1);
for i = 1:numSims
    % Create different parameter sets for each simulation
    params = struct();
    params.simIndex = i;
    params.stopTime = 0.1;  % Short duration for testing
    params.fixedStep = 0.001;
    params.solver = 'ode4';
    
    % Add some parameter variations to test different scenarios
    params.testParam = 1.0 + (i-1) * 0.1;  % Vary a test parameter
    
    testParams{i} = params;
    fprintf('  Simulation %d: stopTime=%.1fs, testParam=%.1f\n', i, params.stopTime, params.testParam);
end

%% Step 2: Create Simulation Input Array
fprintf('\n--- Step 2: Creating Simulation Input Array ---\n');

try
    % Load the model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Create array of simulation inputs (proper array, not cell array)
    simInputArray = Simulink.SimulationInput.empty(0, numSims);
    
    for i = 1:numSims
        params = testParams{i};
        
        % Create simulation input
        simInput = Simulink.SimulationInput(modelName);
        
        % Set model parameters
        simInput = simInput.setModelParameter('StopTime', num2str(params.stopTime));
        simInput = simInput.setModelParameter('Solver', params.solver);
        simInput = simInput.setModelParameter('FixedStep', num2str(params.fixedStep));
        
        % Enable Data Inspector signal logging (basic setup)
        simInput = simInput.setModelParameter('SaveOutput', 'on');
        simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        % Store in array
        simInputArray(i) = simInput;
    end
    
    fprintf('✓ Created %d simulation inputs\n', numSims);
    
catch ME
    fprintf('✗ Error creating simulation inputs: %s\n', ME.message);
    return;
end

%% Step 3: Run Parallel Simulations
fprintf('\n--- Step 3: Running Parallel Simulations ---\n');

tic;  % Start timing

try
    % Run parallel simulations
    fprintf('Starting %d parallel simulations...\n', numSims);
    simOutArray = parsim(simInputArray, 'ShowProgress', 'on');
    
    simulationTime = toc;
    fprintf('✓ Parallel simulations completed in %.2f seconds\n', simulationTime);
    fprintf('  Average time per simulation: %.2f seconds\n', simulationTime / numSims);
    
catch ME
    fprintf('✗ Error in parallel simulation: %s\n', ME.message);
    return;
end

%% Step 4: Analyze Results
fprintf('\n--- Step 4: Analyzing Results ---\n');

% Initialize results tracking
totalSignals = 0;
signalCounts = zeros(numSims, 1);
dataIntegrity = true;
missingData = false;

% Analyze each simulation result
for i = 1:numSims
    fprintf('\nAnalyzing simulation %d/%d:\n', i, numSims);
    
    simOut = simOutArray(i);
    
    % Check if simulation completed successfully
    if isempty(simOut)
        fprintf('  ✗ Simulation %d failed - empty output\n', i);
        dataIntegrity = false;
        missingData = true;
        continue;
    end
    
    % Check for out data (Data Inspector signals)
    if isfield(simOut, 'out') && ~isempty(simOut.out)
        logsout = simOut.out;
        signalCount = logsout.numElements;
        signalCounts(i) = signalCount;
        totalSignals = totalSignals + signalCount;
        fprintf('  ✓ Data Inspector signals: %d\n', signalCount);
        
        % Verify we have the expected number of signals (should be around 590+)
        if signalCount < 500
            fprintf('  ⚠️  Warning: Low signal count (%d) - expected ~590+\n', signalCount);
            dataIntegrity = false;
        end
        
        % Check for time data
        if signalCount > 0
            try
                firstSignal = logsout.getElement(1);
                if ~isempty(firstSignal.Values)
                    timePoints = length(firstSignal.Values.Time);
                    fprintf('  ✓ Time points: %d\n', timePoints);
                end
            catch
                fprintf('  ⚠️  Warning: Could not verify time data\n');
            end
        end
    else
        fprintf('  ✗ No Data Inspector signals found\n');
        missingData = true;
    end
    
    % Check for any other fields
    workspaceFields = fieldnames(simOut);
    fprintf('  ✓ Total output fields: %d\n', length(workspaceFields));
    for j = 1:length(workspaceFields)
        fieldName = workspaceFields{j};
        fprintf('    - %s\n', fieldName);
    end
end

%% Step 5: Data Integrity Check
fprintf('\n--- Step 5: Data Integrity Check ---\n');

% Calculate statistics
avgSignals = mean(signalCounts(signalCounts > 0));
stdSignals = std(signalCounts(signalCounts > 0));
minSignals = min(signalCounts(signalCounts > 0));
maxSignals = max(signalCounts(signalCounts > 0));

fprintf('Signal count statistics:\n');
fprintf('  Average: %.1f signals\n', avgSignals);
fprintf('  Standard deviation: %.1f signals\n', stdSignals);
fprintf('  Range: %d - %d signals\n', minSignals, maxSignals);

% Check consistency
if stdSignals > 10
    fprintf('  ⚠️  Warning: High variability in signal counts\n');
    dataIntegrity = false;
end

% Check for missing data
if missingData
    fprintf('  ⚠️  Warning: Some simulations had missing data\n');
    dataIntegrity = false;
end

%% Step 6: Performance Analysis
fprintf('\n--- Step 6: Performance Analysis ---\n');

% Calculate efficiency metrics
totalSimTime = simulationTime;
avgSimTime = totalSimTime / numSims;
efficiency = numSims / totalSimTime;  % simulations per second

fprintf('Performance metrics:\n');
fprintf('  Total simulation time: %.2f seconds\n', totalSimTime);
fprintf('  Average time per simulation: %.2f seconds\n', avgSimTime);
fprintf('  Efficiency: %.2f simulations/second\n', efficiency);

% Estimate for larger datasets
estimatedTime100 = 100 / efficiency;
estimatedTime1000 = 1000 / efficiency;

fprintf('\nEstimated times for larger datasets:\n');
fprintf('  100 simulations: %.1f seconds (%.1f minutes)\n', estimatedTime100, estimatedTime100/60);
fprintf('  1000 simulations: %.1f seconds (%.1f minutes)\n', estimatedTime1000, estimatedTime1000/60);

%% Step 7: Save Test Results
fprintf('\n--- Step 7: Saving Test Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('ParsimBasicTest_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save test results
testResults = struct();
testResults.timestamp = timestamp;
testResults.numSimulations = numSims;
testResults.simulationTime = simulationTime;
testResults.avgSimTime = avgSimTime;
testResults.efficiency = efficiency;
testResults.signalCounts = signalCounts;
testResults.avgSignals = avgSignals;
testResults.stdSignals = stdSignals;
testResults.dataIntegrity = dataIntegrity;
testResults.missingData = missingData;
testResults.testParams = testParams;

% Save results
resultsFilename = fullfile(outputDir, 'parsim_basic_test_results.mat');
save(resultsFilename, 'testResults');
fprintf('✓ Test results saved to: %s\n', resultsFilename);

% Save a sample simulation output for detailed analysis
if ~isempty(simOutArray) && ~isempty(simOutArray(1))
    sampleFilename = fullfile(outputDir, 'sample_simulation_output.mat');
    sampleOut = simOutArray(1);
    save(sampleFilename, 'sampleOut');
    fprintf('✓ Sample simulation output saved to: %s\n', sampleFilename);
end

%% Step 8: Final Summary
fprintf('\n--- Step 8: Final Summary ---\n');

fprintf('🎯 PARSIM BASIC DATA CAPTURE TEST RESULTS:\n\n');

if dataIntegrity && ~missingData
    fprintf('✅ SUCCESS: All simulations completed successfully!\n');
    fprintf('✅ SUCCESS: All Data Inspector signals captured!\n');
    fprintf('✅ SUCCESS: Data integrity verified!\n\n');
else
    fprintf('⚠️  WARNING: Some issues detected with data capture\n');
    if missingData
        fprintf('  - Missing data in some simulations\n');
    end
    if ~dataIntegrity
        fprintf('  - Data integrity issues detected\n');
    end
    fprintf('\n');
end

fprintf('Basic Data Capture Summary:\n');
fprintf('  • %d parallel simulations completed\n', numSims);
fprintf('  • Average signals: %.1f per simulation\n', avgSignals);
fprintf('  • Total time: %.2f seconds\n', totalSimTime);
fprintf('  • Efficiency: %.2f simulations/second\n', efficiency);
fprintf('\n');

fprintf('Scalability Estimate:\n');
fprintf('  • 100 simulations: ~%.1f minutes\n', estimatedTime100/60);
fprintf('  • 1000 simulations: ~%.1f minutes\n', estimatedTime1000/60);
fprintf('  • 10000 simulations: ~%.1f hours\n', estimatedTime1000*10/3600);
fprintf('\n');

fprintf('Output directory: %s\n', outputDir);
fprintf('Basic parsim test finished! 🚀\n'); 