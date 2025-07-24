% testJointCenterDataExtraction_Short_Fixed.m
% Fixed version that explicitly sets signal logging parameters in simulation input
% - 2 simulation runs
% - 0.1 second duration each
% - Limited data points for troubleshooting
% - Organized output folder

clear; clc;

fprintf('=== Fixed Joint Center Position Data Extraction Test ===\n\n');
fprintf('This script will:\n');
fprintf('1. Generate 2 test simulations (0.1s each)\n');
fprintf('2. Explicitly set signal logging parameters in simulation input\n');
fprintf('3. Extract joint center positions from signal buses\n');
fprintf('4. Show ALL signals to verify we capture everything we need\n');
fprintf('5. Save results in organized troubleshooting folder\n\n');

%% Create Output Directory
fprintf('--- Creating Output Directory ---\n');

% Create timestamped folder for troubleshooting
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('JointCenterTest_Fixed_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
else
    fprintf('✓ Output directory exists: %s\n', outputDir);
end

%% Step 1: Generate Test Simulations
fprintf('\n--- Step 1: Generating Test Simulations ---\n');

simResults = cell(2, 1);
simNames = {'Test_Run_1', 'Test_Run_2'};

try
    % Load the model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Run 2 simulations with different parameters
    for runIdx = 1:2
        fprintf('\nRunning simulation %d/2: %s\n', runIdx, simNames{runIdx});
        
        % Create simulation input
        simInput = Simulink.SimulationInput(modelName);
        
        % Set short simulation time (0.1 seconds)
        simInput = simInput.setModelParameter('StopTime', '0.1');
        
        % Enable ALL logging parameters explicitly in simulation input
        simInput = simInput.setModelParameter('SaveOutput', 'on');
        simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        
        % Set solver to fixed step for consistent results
        simInput = simInput.setModelParameter('Solver', 'ode4');
        simInput = simInput.setModelParameter('FixedStep', '0.001'); % 1ms step size
        
        % Run the simulation
        fprintf('  Running simulation...\n');
        simOut = sim(simInput);
        simResults{runIdx} = simOut;
        fprintf('  ✓ Simulation %d completed successfully\n', runIdx);
        
        % Save individual simulation result
        simFilename = fullfile(outputDir, sprintf('sim_%s.mat', simNames{runIdx}));
        save(simFilename, 'simOut');
        fprintf('  ✓ Saved to: %s\n', simFilename);
    end
    
catch ME
    fprintf('✗ Error in simulation: %s\n', ME.message);
    return;
end

%% Step 2: Analyze Signal Buses (Complete Analysis)
fprintf('\n--- Step 2: Analyzing Signal Buses (Complete) ---\n');

% Analyze first simulation only for signal discovery
simOut = simResults{1};

try
    if isfield(simOut, 'out') && ~isempty(simOut.out)
        logsout = simOut.out;
        fprintf('✓ Out data available\n');
        
        % Get all signal names (complete display)
        allSignalNames = {};
        for i = 1:logsout.numElements
            signalElement = logsout.getElement(i);
            allSignalNames{end+1} = signalElement.Name;
        end
        
        fprintf('Total logged signals: %d\n', length(allSignalNames));
        
        % Display ALL signal names - we need to see everything
        fprintf('\nALL logged signal names (%d total):\n', length(allSignalNames));
        for i = 1:length(allSignalNames)
            fprintf('  %d. %s\n', i, allSignalNames{i});
        end
        
    else
        fprintf('✗ No out data found\n');
        fprintf('Checking Data Inspector for runs...\n');
        
        % Check Data Inspector as fallback
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            fprintf('✓ Found %d runs in Data Inspector\n', length(runIDs));
            for i = 1:min(3, length(runIDs))
                run = Simulink.sdi.getRun(runIDs(i));
                fprintf('  Run %d: %s\n', i, run.Name);
            end
        else
            fprintf('✗ No runs found in Data Inspector either\n');
        end
        return;
    end
    
catch ME
    fprintf('✗ Error analyzing signal buses: %s\n', ME.message);
    return;
end

%% Step 3: Extract Joint Center Positions (Both Runs)
fprintf('\n--- Step 3: Extracting Joint Center Positions ---\n');

jointCenterResults = cell(2, 1);

for runIdx = 1:2
    fprintf('\nProcessing simulation %d/2: %s\n', runIdx, simNames{runIdx});
    
    try
        % Extract joint center positions using our function
        jointCenters = extractJointCenterPositionsFromBuses(simResults{runIdx});
        jointCenterResults{runIdx} = jointCenters;
        
        if ~isempty(jointCenters)
            fprintf('  ✓ Joint center positions extracted\n');
            
            % Save individual joint center result
            jcFilename = fullfile(outputDir, sprintf('joint_centers_%s.mat', simNames{runIdx}));
            save(jcFilename, 'jointCenters');
            fprintf('  ✓ Saved to: %s\n', jcFilename);
        else
            fprintf('  ✗ No joint center positions extracted\n');
        end
        
    catch ME
        fprintf('  ✗ Error extracting joint center positions: %s\n', ME.message);
        jointCenterResults{runIdx} = [];
    end
end

%% Step 4: Quick Data Analysis
fprintf('\n--- Step 4: Quick Data Analysis ---\n');

analysisResults = struct();

for runIdx = 1:2
    fprintf('\nAnalysis for %s:\n', simNames{runIdx});
    
    if ~isempty(jointCenterResults{runIdx})
        jointCenters = jointCenterResults{runIdx};
        
        % Basic statistics
        fields = fieldnames(jointCenters);
        fields = fields(~strcmp(fields, 'time')); % Exclude time field
        
        analysisResults(runIdx).runName = simNames{runIdx};
        analysisResults(runIdx).timePoints = length(jointCenters.time);
        analysisResults(runIdx).signalCount = length(fields);
        analysisResults(runIdx).signalNames = fields;
        
        fprintf('  Time points: %d\n', analysisResults(runIdx).timePoints);
        fprintf('  Joint center signals: %d\n', analysisResults(runIdx).signalCount);
        
        % Show ALL signal names - we need to see everything
        if length(fields) > 0
            fprintf('  ALL joint center signals:\n');
            for i = 1:length(fields)
                fprintf('    - %s\n', fields{i});
            end
        end
        
    else
        fprintf('  ✗ No joint center data available\n');
        analysisResults(runIdx).runName = simNames{runIdx};
        analysisResults(runIdx).timePoints = 0;
        analysisResults(runIdx).signalCount = 0;
        analysisResults(runIdx).signalNames = {};
    end
end

%% Step 5: Final Summary
fprintf('\n--- Step 5: Final Summary ---\n');

fprintf('Test completed!\n\n');
fprintf('Output directory: %s\n', outputDir);

% Check if joint center positions were found
totalSignals = sum([analysisResults.signalCount]);
if totalSignals > 0
    fprintf('🎉 SUCCESS! Joint center positions found in %d signals across both runs.\n', totalSignals);
    fprintf('The data is ready for motion matching and 3D visualization.\n\n');
else
    fprintf('⚠️  WARNING: No joint center position signals found.\n');
    fprintf('This suggests the signals are not being logged properly.\n');
    fprintf('Check that you have enabled signal logging on your signal buses.\n\n');
end

fprintf('Fixed test completed! 🚀\n'); 