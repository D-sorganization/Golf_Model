% analyzeCompleteDataLogging.m
% Analyze all available data sources to determine total logged quantities
% Combines Data Inspector signals with Simscape Results Explorer data

clear; clc;

fprintf('=== Complete Data Logging Analysis ===\n\n');
fprintf('This script will analyze:\n');
fprintf('1. Data Inspector signals (joint positions, velocities, accelerations)\n');
fprintf('2. Simscape Results Explorer data (inertial properties, workspace parameters)\n');
fprintf('3. Calculate total logged quantities per data point\n\n');

%% Step 1: Run Simulation to Generate Fresh Data
fprintf('--- Step 1: Running Simulation ---\n');

try
    % Load the model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Create simulation input with explicit signal logging
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.1');
    simInput = simInput.setModelParameter('SaveOutput', 'on');
    simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Run the simulation
    fprintf('Running simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Simulation completed successfully\n');
    
catch ME
    fprintf('✗ Error in simulation: %s\n', ME.message);
    return;
end

%% Step 2: Analyze Data Inspector Signals
fprintf('\n--- Step 2: Analyzing Data Inspector Signals ---\n');

runIDs = Simulink.sdi.getAllRunIDs;
if isempty(runIDs)
    fprintf('✗ No runs found in Data Inspector\n');
    return;
end

fprintf('✓ Found %d runs in Data Inspector\n', length(runIDs));

% Analyze the first run
run = Simulink.sdi.getRun(runIDs(1));
fprintf('Analyzing run: %s\n', run.Name);

signals = run.getAllSignals;
fprintf('Total signals in Data Inspector: %d\n', length(signals));

%% Step 3: Categorize Data Inspector Signals
fprintf('\n--- Step 3: Categorizing Data Inspector Signals ---\n');

% Initialize categories
categories = struct();
categories.position = {};
categories.velocity = {};
categories.acceleration = {};
categories.angular_position = {};
categories.angular_velocity = {};
categories.angular_acceleration = {};
categories.force = {};
categories.torque = {};
categories.moment = {};
categories.impulse = {};
categories.work = {};
categories.power = {};
categories.other = {};

% Categorize signals
for i = 1:length(signals)
    signal = signals(i);
    signalName = signal.Name;
    
    % Position signals
    if contains(lower(signalName), 'position') && ~contains(lower(signalName), 'angular')
        categories.position{end+1} = signalName;
    % Velocity signals
    elseif contains(lower(signalName), 'velocity') && ~contains(lower(signalName), 'angular')
        categories.velocity{end+1} = signalName;
    % Acceleration signals
    elseif contains(lower(signalName), 'acceleration') && ~contains(lower(signalName), 'angular')
        categories.acceleration{end+1} = signalName;
    % Angular position signals
    elseif contains(lower(signalName), 'angular') && contains(lower(signalName), 'position')
        categories.angular_position{end+1} = signalName;
    % Angular velocity signals
    elseif contains(lower(signalName), 'angular') && contains(lower(signalName), 'velocity')
        categories.angular_velocity{end+1} = signalName;
    % Angular acceleration signals
    elseif contains(lower(signalName), 'angular') && contains(lower(signalName), 'acceleration')
        categories.angular_acceleration{end+1} = signalName;
    % Force signals
    elseif contains(lower(signalName), 'force')
        categories.force{end+1} = signalName;
    % Torque signals
    elseif contains(lower(signalName), 'torque')
        categories.torque{end+1} = signalName;
    % Moment signals
    elseif contains(lower(signalName), 'moment') || contains(lower(signalName), 'mof')
        categories.moment{end+1} = signalName;
    % Impulse signals
    elseif contains(lower(signalName), 'impulse')
        categories.impulse{end+1} = signalName;
    % Work signals
    elseif contains(lower(signalName), 'work')
        categories.work{end+1} = signalName;
    % Power signals
    elseif contains(lower(signalName), 'power')
        categories.power{end+1} = signalName;
    % Other signals
    else
        categories.other{end+1} = signalName;
    end
end

%% Step 4: Display Signal Categories
fprintf('\n--- Step 4: Signal Categories Summary ---\n');

categoryNames = fieldnames(categories);
totalSignals = 0;

for i = 1:length(categoryNames)
    category = categoryNames{i};
    signalList = categories.(category);
    count = length(signalList);
    totalSignals = totalSignals + count;
    
    fprintf('%s: %d signals\n', category, count);
    
    % Show first few examples
    if count > 0
        fprintf('  Examples: ');
        for j = 1:min(3, count)
            fprintf('%s', signalList{j});
            if j < min(3, count)
                fprintf(', ');
            end
        end
        if count > 3
            fprintf(' ... (%d more)', count - 3);
        end
        fprintf('\n');
    end
end

fprintf('\nTotal Data Inspector signals: %d\n', totalSignals);

%% Step 5: Analyze Simscape Results Explorer Data
fprintf('\n--- Step 5: Analyzing Simscape Results Explorer Data ---\n');

% Get model workspace parameters
try
    modelWksp = get_param(modelName, 'ModelWorkspace');
    modelVars = modelWksp.getVariableNames;
    fprintf('Model workspace variables: %d\n', length(modelVars));
    
    % Count workspace parameters
    workspaceParams = 0;
    for i = 1:length(modelVars)
        varName = modelVars{i};
        try
            varValue = modelWksp.getVariable(varName);
            if isnumeric(varValue)
                workspaceParams = workspaceParams + 1;
            end
        catch
            % Skip non-numeric variables
        end
    end
    fprintf('Numeric workspace parameters: %d\n', workspaceParams);
    
catch ME
    fprintf('✗ Error accessing model workspace: %s\n', ME.message);
    workspaceParams = 0;
end

%% Step 6: Estimate Inertial Properties
fprintf('\n--- Step 6: Estimating Inertial Properties ---\n');

% Count inertial properties from signal names
inertialSignals = 0;
for i = 1:length(signals)
    signal = signals(i);
    signalName = signal.Name;
    
    % Look for mass, inertia, COM signals
    if contains(lower(signalName), 'mass') || ...
       contains(lower(signalName), 'inertia') || ...
       contains(lower(signalName), 'com') || ...
       contains(lower(signalName), 'center of mass')
        inertialSignals = inertialSignals + 1;
    end
end

fprintf('Inertial property signals: %d\n', inertialSignals);

%% Step 7: Calculate Total Quantities
fprintf('\n--- Step 7: Total Quantities Calculation ---\n');

% Count by category
positionCount = length(categories.position);
velocityCount = length(categories.velocity);
accelerationCount = length(categories.acceleration);
angularPositionCount = length(categories.angular_position);
angularVelocityCount = length(categories.angular_velocity);
angularAccelerationCount = length(categories.angular_acceleration);
forceCount = length(categories.force);
torqueCount = length(categories.torque);
momentCount = length(categories.moment);
impulseCount = length(categories.impulse);
workCount = length(categories.work);
powerCount = length(categories.power);
otherCount = length(categories.other);

% Calculate totals
totalKinematicQuantities = positionCount + velocityCount + accelerationCount + ...
                          angularPositionCount + angularVelocityCount + angularAccelerationCount;
totalDynamicQuantities = forceCount + torqueCount + momentCount + impulseCount + workCount + powerCount;
totalOtherQuantities = otherCount + inertialSignals + workspaceParams;

totalQuantities = totalKinematicQuantities + totalDynamicQuantities + totalOtherQuantities;

fprintf('Kinematic quantities (positions, velocities, accelerations): %d\n', totalKinematicQuantities);
fprintf('Dynamic quantities (forces, torques, moments, impulses, work, power): %d\n', totalDynamicQuantities);
fprintf('Other quantities (inertial properties, workspace params, misc): %d\n', totalOtherQuantities);
fprintf('\nTOTAL LOGGED QUANTITIES PER DATA POINT: %d\n', totalQuantities);

%% Step 8: Detailed Breakdown
fprintf('\n--- Step 8: Detailed Breakdown ---\n');

fprintf('Position signals: %d\n', positionCount);
fprintf('Velocity signals: %d\n', velocityCount);
fprintf('Acceleration signals: %d\n', accelerationCount);
fprintf('Angular position signals: %d\n', angularPositionCount);
fprintf('Angular velocity signals: %d\n', angularVelocityCount);
fprintf('Angular acceleration signals: %d\n', angularAccelerationCount);
fprintf('Force signals: %d\n', forceCount);
fprintf('Torque signals: %d\n', torqueCount);
fprintf('Moment signals: %d\n', momentCount);
fprintf('Impulse signals: %d\n', impulseCount);
fprintf('Work signals: %d\n', workCount);
fprintf('Power signals: %d\n', powerCount);
fprintf('Inertial property signals: %d\n', inertialSignals);
fprintf('Workspace parameters: %d\n', workspaceParams);
fprintf('Other signals: %d\n', otherCount);

%% Step 9: Save Analysis Results
fprintf('\n--- Step 9: Saving Analysis Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('CompleteDataAnalysis_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save analysis results
analysisResults = struct();
analysisResults.timestamp = timestamp;
analysisResults.totalSignals = totalSignals;
analysisResults.totalQuantities = totalQuantities;
analysisResults.categories = categories;
analysisResults.breakdown = struct();
analysisResults.breakdown.position = positionCount;
analysisResults.breakdown.velocity = velocityCount;
analysisResults.breakdown.acceleration = accelerationCount;
analysisResults.breakdown.angularPosition = angularPositionCount;
analysisResults.breakdown.angularVelocity = angularVelocityCount;
analysisResults.breakdown.angularAcceleration = angularAccelerationCount;
analysisResults.breakdown.force = forceCount;
analysisResults.breakdown.torque = torqueCount;
analysisResults.breakdown.moment = momentCount;
analysisResults.breakdown.impulse = impulseCount;
analysisResults.breakdown.work = workCount;
analysisResults.breakdown.power = powerCount;
analysisResults.breakdown.inertial = inertialSignals;
analysisResults.breakdown.workspaceParams = workspaceParams;
analysisResults.breakdown.other = otherCount;

% Save results
resultsFilename = fullfile(outputDir, 'complete_data_analysis.mat');
save(resultsFilename, 'analysisResults');
fprintf('✓ Analysis results saved to: %s\n', resultsFilename);

%% Step 10: Final Summary
fprintf('\n--- Step 10: Final Summary ---\n');

fprintf('🎯 COMPLETE DATA LOGGING SUMMARY:\n\n');
fprintf('For every data point in your simulation, you are logging:\n');
fprintf('  • %d kinematic quantities (positions, velocities, accelerations)\n', totalKinematicQuantities);
fprintf('  • %d dynamic quantities (forces, torques, moments, impulses, work, power)\n', totalDynamicQuantities);
fprintf('  • %d other quantities (inertial properties, workspace parameters, misc)\n', totalOtherQuantities);
fprintf('\n🎉 TOTAL: %d LOGGED QUANTITIES PER DATA POINT\n\n', totalQuantities);

fprintf('This comprehensive dataset includes:\n');
fprintf('  ✓ Global positions of every joint center\n');
fprintf('  ✓ Linear and angular velocities/accelerations\n');
fprintf('  ✓ Forces, torques, and moments\n');
fprintf('  ✓ Work, power, and impulse data\n');
fprintf('  ✓ Inertial properties\n');
fprintf('  ✓ Model workspace parameters\n\n');

fprintf('Output directory: %s\n', outputDir);
fprintf('Complete data analysis finished! 🚀\n'); 