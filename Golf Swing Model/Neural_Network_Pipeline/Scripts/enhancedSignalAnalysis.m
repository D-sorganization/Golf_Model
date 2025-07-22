% enhancedSignalAnalysis.m
% Enhanced analysis of logged signals for neural network training
% Identifies current signals and recommends additional signals needed for ML

clear; clc;

fprintf('=== Enhanced Signal Analysis for Neural Network Training ===\n\n');

%% Load the model
modelName = 'GolfSwing3D_Kinetic';

% Check if model exists
if ~exist([modelName '.slx'], 'file')
    fprintf('Error: Model %s.slx not found in current directory.\n', modelName);
    fprintf('Please ensure you are in the correct directory or update the model path.\n');
    return;
end

% Load the model
if ~bdIsLoaded(modelName)
    load_system(modelName);
    fprintf('Model %s loaded successfully.\n', modelName);
else
    fprintf('Model %s is already loaded.\n', modelName);
end

%% Define required signals for neural network training
fprintf('--- Required Signals for Neural Network Training ---\n');

% Core signals needed for inverse dynamics training
required_signals = struct();
required_signals.joint_states = {
    'q',      'Joint positions (28x1 vector)'
    'qd',     'Joint velocities (28x1 vector)' 
    'qdd',    'Joint accelerations (28x1 vector)'
    'tau',    'Joint torques (28x1 vector)'
};

% Additional useful signals for analysis and validation
required_signals.kinematics = {
    'CHx', 'CHy', 'CHz',     'Clubhead position (x,y,z)'
    'CHvx', 'CHvy', 'CHvz',  'Clubhead velocity (x,y,z)'
    'CHax', 'CHay', 'CHaz',  'Clubhead acceleration (x,y,z)'
    'MHx', 'MHy', 'MHz',     'Mid-hands position (x,y,z)'
    'MHvx', 'MHvy', 'MHz',   'Mid-hands velocity (x,y,z)'
};

required_signals.forces = {
    'LH_force_x', 'LH_force_y', 'LH_force_z',     'Left hand forces'
    'RH_force_x', 'RH_force_y', 'RH_force_z',     'Right hand forces'
    'LH_torque_x', 'LH_torque_y', 'LH_torque_z',  'Left hand torques'
    'RH_torque_x', 'RH_torque_y', 'RH_torque_z',  'Right hand torques'
};

required_signals.energy = {
    'kinetic_energy',    'Total kinetic energy'
    'potential_energy',  'Total potential energy'
    'total_energy',      'Total mechanical energy'
};

% Display required signals
fprintf('Core Joint States (Required for Training):\n');
for i = 1:size(required_signals.joint_states, 1)
    fprintf('  - %s: %s\n', required_signals.joint_states{i,1}, required_signals.joint_states{i,2});
end

fprintf('\nKinematics (Useful for Analysis):\n');
for i = 1:size(required_signals.kinematics, 1)
    fprintf('  - %s: %s\n', required_signals.kinematics{i,1}, required_signals.kinematics{i,2});
end

fprintf('\nForces (Useful for Analysis):\n');
for i = 1:size(required_signals.forces, 1)
    fprintf('  - %s: %s\n', required_signals.forces{i,1}, required_signals.forces{i,2});
end

%% Find currently logged signals
fprintf('\n--- Currently Logged Signals ---\n');

% Find all lines with signal logging enabled
loggedLines = find_system(modelName, 'FindAll', 'on', 'Type', 'line', 'SignalLogging', 'on');

fprintf('Found %d signals with logging enabled.\n', length(loggedLines));

if isempty(loggedLines)
    fprintf('No signals are currently being logged.\n');
    fprintf('You need to enable signal logging in the Simulink model.\n');
else
    % Extract signal names
    signalNames = {};
    for i = 1:length(loggedLines)
        line = loggedLines(i);
        signalName = get(line, 'Name');
        if isempty(signalName)
            signalName = sprintf('Signal_%d', i);
        end
        signalNames{end+1} = signalName;
    end
    
    fprintf('Currently logged signals:\n');
    for i = 1:length(signalNames)
        fprintf('  - %s\n', signalNames{i});
    end
end

%% Check for required signals
fprintf('\n--- Signal Availability Check ---\n');

% Check core joint states
core_signals = required_signals.joint_states(:,1);
missing_core = {};
available_core = {};

for i = 1:length(core_signals)
    req_signal = core_signals{i};
    found = false;
    
    for j = 1:length(signalNames)
        if contains(signalNames{j}, req_signal)
            fprintf('✓ Found %s: %s\n', req_signal, signalNames{j});
            available_core{end+1} = req_signal;
            found = true;
            break;
        end
    end
    
    if ~found
        fprintf('✗ Missing %s\n', req_signal);
        missing_core{end+1} = req_signal;
    end
end

%% Simscape Results Explorer Analysis
fprintf('\n--- Simscape Results Explorer Analysis ---\n');

% Check if Simscape logging is enabled
simscape_logging = get_param(modelName, 'SimscapeLogType');
fprintf('Simscape logging type: %s\n', simscape_logging);

if strcmp(simscape_logging, 'none')
    fprintf('⚠ Simscape logging is disabled. Enable it to access Simscape Results Explorer data.\n');
else
    fprintf('✓ Simscape logging is enabled. You can access data through Simscape Results Explorer.\n');
end

%% Recommendations for additional logging
fprintf('\n--- Recommendations for Additional Signal Logging ---\n');

if ~isempty(missing_core)
    fprintf('MISSING CORE SIGNALS (Required for neural network training):\n');
    for i = 1:length(missing_core)
        fprintf('  - %s\n', missing_core{i});
    end
    
    fprintf('\nTo enable these signals in Simulink:\n');
    fprintf('1. Open the GolfSwing3D_Kinetic model\n');
    fprintf('2. Find the signal lines carrying joint data\n');
    fprintf('3. Right-click on each signal line\n');
    fprintf('4. Select "Signal Properties" -> "Logging"\n');
    fprintf('5. Check "Log signal data" and set signal name\n');
    fprintf('6. Use these exact names: q, qd, qdd, tau\n');
else
    fprintf('✓ All core signals are available for neural network training!\n');
end

%% Simscape Results Explorer Guide
fprintf('\n--- Simscape Results Explorer Guide ---\n');

fprintf('To access Simscape data:\n');
fprintf('1. Run a simulation\n');
fprintf('2. Open Simscape Results Explorer (View -> Simscape -> Results Explorer)\n');
fprintf('3. Available data categories:\n');
fprintf('   - Variables: Position, velocity, acceleration\n');
fprintf('   - Forces: Applied forces and torques\n');
fprintf('   - Energy: Kinetic, potential, and total energy\n');
fprintf('   - Sensors: Sensor readings and measurements\n');

fprintf('\nTo export Simscape data to logsout format:\n');
fprintf('1. In Simscape Results Explorer, right-click on desired signals\n');
fprintf('2. Select "Export to Workspace"\n');
fprintf('3. Choose "Dataset" format\n');
fprintf('4. The data will be available as a Dataset object\n');

%% Create logging configuration script
fprintf('\n--- Creating Logging Configuration Script ---\n');

createLoggingConfigScript(modelName, missing_core, required_signals);

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Total currently logged signals: %d\n', length(loggedLines));
fprintf('Core signals available: %d/%d\n', length(available_core), length(core_signals));
fprintf('Core signals missing: %d\n', length(missing_core));

if isempty(missing_core)
    fprintf('\n✓ Model is ready for neural network training!\n');
else
    fprintf('\n⚠ Model needs additional signal logging for neural network training.\n');
    fprintf('Run the generated logging configuration script to enable missing signals.\n');
end

fprintf('\nAnalysis complete.\n');

%% Helper Functions

function createLoggingConfigScript(modelName, missing_signals, required_signals)
    % Create a script to help configure signal logging
    
    scriptName = 'configureSignalLogging.m';
    
    fid = fopen(scriptName, 'w');
    
    fprintf(fid, '%% configureSignalLogging.m\n');
    fprintf(fid, '%% Script to configure signal logging for neural network training\n');
    fprintf(fid, '%% Generated by enhancedSignalAnalysis.m\n\n');
    
    fprintf(fid, 'clear; clc;\n\n');
    
    fprintf(fid, '%% Load model\n');
    fprintf(fid, 'modelName = ''%s'';\n', modelName);
    fprintf(fid, 'if ~bdIsLoaded(modelName)\n');
    fprintf(fid, '    load_system(modelName);\n');
    fprintf(fid, 'end\n\n');
    
    fprintf(fid, '%% Enable Simscape logging\n');
    fprintf(fid, 'set_param(modelName, ''SimscapeLogType'', ''all'');\n\n');
    
    if ~isempty(missing_signals)
        fprintf(fid, '%% Configure signal logging for missing signals\n');
        fprintf(fid, 'fprintf(''Configuring signal logging...\\n'');\n\n');
        
        for i = 1:length(missing_signals)
            signal = missing_signals{i};
            fprintf(fid, '%% Enable logging for %s\n', signal);
            fprintf(fid, '%% Find the signal line carrying %s data and enable logging\n', signal);
            fprintf(fid, '%% Right-click on signal line -> Signal Properties -> Logging -> Log signal data\n');
            fprintf(fid, '%% Set signal name to: %s\n\n', signal);
        end
    end
    
    fprintf(fid, '%% Save model\n');
    fprintf(fid, 'save_system(modelName);\n');
    fprintf(fid, 'fprintf(''Signal logging configuration complete.\\n'');\n');
    
    fclose(fid);
    
    fprintf('Created logging configuration script: %s\n', scriptName);
    fprintf('Run this script to help configure signal logging.\n');
end 