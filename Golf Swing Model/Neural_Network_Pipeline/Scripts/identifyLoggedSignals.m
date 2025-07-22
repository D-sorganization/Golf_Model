% identifyLoggedSignals.m
% Identifies what signals are currently being logged in the GolfSwing3D_Kinetic model
% This helps understand what data is available for the neural network pipeline

clear; clc;

fprintf('=== Identifying Logged Signals in GolfSwing3D_Kinetic Model ===\n\n');

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

%% Find all logged signals
fprintf('\n--- Finding Logged Signals ---\n');

% Find all lines with signal logging enabled
loggedLines = find_system(modelName, 'FindAll', 'on', 'Type', 'line', 'SignalLogging', 'on');

fprintf('Found %d signals with logging enabled.\n', length(loggedLines));

if isempty(loggedLines)
    fprintf('No signals are currently being logged.\n');
    fprintf('You may need to enable signal logging in the Simulink model.\n');
    return;
end

%% Extract signal information
signalInfo = struct();
signalNames = {};

fprintf('\n--- Logged Signal Details ---\n');
fprintf('%-30s %-20s %-15s %-10s\n', 'Signal Name', 'Block Path', 'Port', 'Dimensions');
fprintf('%s\n', repmat('-', 1, 80));

for i = 1:length(loggedLines)
    line = loggedLines(i);
    
    % Get signal name
    signalName = get(line, 'Name');
    if isempty(signalName)
        signalName = sprintf('Signal_%d', i);
    end
    
    % Get block path
    blockPath = get(line, 'Parent');
    
    % Get port information
    portHandle = get(line, 'SrcPortHandle');
    if portHandle > 0
        portNum = get(portHandle, 'PortNumber');
    else
        portNum = 'N/A';
    end
    
    % Get signal dimensions (if available)
    try
        signalDims = get(line, 'CompiledPortDimensions');
        if ~isempty(signalDims)
            dimsStr = sprintf('[%s]', num2str(signalDims));
        else
            dimsStr = 'Unknown';
        end
    catch
        dimsStr = 'Unknown';
    end
    
    % Store information
    signalInfo(i).name = signalName;
    signalInfo(i).blockPath = blockPath;
    signalInfo(i).port = portNum;
    signalInfo(i).dimensions = dimsStr;
    
    signalNames{end+1} = signalName;
    
    % Display information
    fprintf('%-30s %-20s %-15s %-10s\n', ...
           signalName, ...
           extractAfter(blockPath, '/'), ...
           num2str(portNum), ...
           dimsStr);
end

%% Categorize signals
fprintf('\n--- Signal Categories ---\n');

% Define categories based on signal names
categories = struct();
categories.joint_states = {};
categories.positions = {};
categories.velocities = {};
categories.forces = {};
categories.torques = {};
categories.other = {};

for i = 1:length(signalNames)
    name = signalNames{i};
    
    % Categorize based on name patterns
    if contains(name, 'q') || contains(name, 'joint')
        categories.joint_states{end+1} = name;
    elseif contains(name, 'x') || contains(name, 'y') || contains(name, 'z') || contains(name, 'pos')
        categories.positions{end+1} = name;
    elseif contains(name, 'v') || contains(name, 'vel') || contains(name, 'd')
        categories.velocities{end+1} = name;
    elseif contains(name, 'force') || contains(name, 'F')
        categories.forces{end+1} = name;
    elseif contains(name, 'torque') || contains(name, 'tau') || contains(name, 'T')
        categories.torques{end+1} = name;
    else
        categories.other{end+1} = name;
    end
end

% Display categories
fprintf('Joint States (%d):\n', length(categories.joint_states));
for i = 1:length(categories.joint_states)
    fprintf('  - %s\n', categories.joint_states{i});
end

fprintf('\nPositions (%d):\n', length(categories.positions));
for i = 1:length(categories.positions)
    fprintf('  - %s\n', categories.positions{i});
end

fprintf('\nVelocities (%d):\n', length(categories.velocities));
for i = 1:length(categories.velocities)
    fprintf('  - %s\n', categories.velocities{i});
end

fprintf('\nForces (%d):\n', length(categories.forces));
for i = 1:length(categories.forces)
    fprintf('  - %s\n', categories.forces{i});
end

fprintf('\nTorques (%d):\n', length(categories.torques));
for i = 1:length(categories.torques)
    fprintf('  - %s\n', categories.torques{i});
end

fprintf('\nOther (%d):\n', length(categories.other));
for i = 1:length(categories.other)
    fprintf('  - %s\n', categories.other{i});
end

%% Check for required signals for neural network
fprintf('\n--- Neural Network Requirements Check ---\n');

required_signals = {'q', 'qd', 'qdd', 'tau'};
missing_signals = {};

for i = 1:length(required_signals)
    req_signal = required_signals{i};
    found = false;
    
    for j = 1:length(signalNames)
        if contains(signalNames{j}, req_signal)
            fprintf('✓ Found %s: %s\n', req_signal, signalNames{j});
            found = true;
            break;
        end
    end
    
    if ~found
        fprintf('✗ Missing %s\n', req_signal);
        missing_signals{end+1} = req_signal;
    end
end

%% Recommendations
fprintf('\n--- Recommendations ---\n');

if ~isempty(missing_signals)
    fprintf('Missing signals for neural network training:\n');
    for i = 1:length(missing_signals)
        fprintf('  - %s\n', missing_signals{i});
    end
    fprintf('\nTo enable these signals:\n');
    fprintf('1. Open the Simulink model\n');
    fprintf('2. Right-click on the signal lines\n');
    fprintf('3. Select "Signal Properties" -> "Logging" -> "Log signal data"\n');
    fprintf('4. Set appropriate signal names (q, qd, qdd, tau)\n');
else
    fprintf('✓ All required signals for neural network training are available!\n');
end

%% Save results
fprintf('\n--- Saving Results ---\n');

results.signalInfo = signalInfo;
results.signalNames = signalNames;
results.categories = categories;
results.missing_signals = missing_signals;
results.total_signals = length(loggedLines);

save('logged_signals_analysis.mat', 'results');
fprintf('Analysis saved to: logged_signals_analysis.mat\n');

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Total logged signals: %d\n', length(loggedLines));
fprintf('Joint states: %d\n', length(categories.joint_states));
fprintf('Positions: %d\n', length(categories.positions));
fprintf('Velocities: %d\n', length(categories.velocities));
fprintf('Forces: %d\n', length(categories.forces));
fprintf('Torques: %d\n', length(categories.torques));
fprintf('Other: %d\n', length(categories.other));

if isempty(missing_signals)
    fprintf('\n✓ Model is ready for neural network training!\n');
else
    fprintf('\n⚠ Model needs additional signal logging for neural network training.\n');
end

fprintf('\nAnalysis complete.\n'); 