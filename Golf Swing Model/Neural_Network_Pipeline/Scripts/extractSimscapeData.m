% extractSimscapeData.m
% Extracts data from Simscape Results Explorer and converts to logsout format
% for use with the neural network pipeline

clear; clc;

fprintf('=== Simscape Data Extraction for Neural Network Training ===\n\n');

%% Check if Simscape Results Explorer has data
fprintf('--- Checking Simscape Results Explorer ---\n');

% Check if there are any Simscape runs
try
    simscapeRuns = Simulink.sdi.getAllRunIDs;
    if isempty(simscapeRuns)
        fprintf('No Simscape runs found in Results Explorer.\n');
        fprintf('Please run a simulation first to generate Simscape data.\n');
        return;
    end
    
    fprintf('Found %d Simscape runs.\n', length(simscapeRuns));
    
    % Get the most recent run
    latestRun = simscapeRuns(end);
    runObj = Simulink.sdi.getRun(latestRun);
    
    fprintf('Latest run: %s\n', runObj.Name);
    fprintf('Run ID: %d\n', latestRun);
    
catch ME
    fprintf('Error accessing Simscape Results Explorer: %s\n', ME.message);
    fprintf('Make sure you have run a simulation and Simscape logging is enabled.\n');
    return;
end

%% Extract available signals from Simscape
fprintf('\n--- Available Simscape Signals ---\n');

% Get all signals from the run
signals = runObj.getAllSignals;
fprintf('Total signals available: %d\n', length(signals));

% Categorize signals
categories = struct();
categories.joint_states = {};
categories.positions = {};
categories.velocities = {};
categories.accelerations = {};
categories.forces = {};
categories.torques = {};
categories.energy = {};
categories.other = {};

for i = 1:length(signals)
    signal = signals(i);
    signalName = signal.Name;
    signalPath = signal.BlockPath;
    
    % Categorize based on name and path
    if contains(signalName, 'q') || contains(signalPath, 'joint')
        categories.joint_states{end+1} = signalName;
    elseif contains(signalName, 'x') || contains(signalName, 'y') || contains(signalName, 'z')
        if contains(signalName, 'v') || contains(signalName, 'vel')
            categories.velocities{end+1} = signalName;
        elseif contains(signalName, 'a') || contains(signalName, 'acc')
            categories.accelerations{end+1} = signalName;
        else
            categories.positions{end+1} = signalName;
        end
    elseif contains(signalName, 'force') || contains(signalName, 'F')
        categories.forces{end+1} = signalName;
    elseif contains(signalName, 'torque') || contains(signalName, 'tau') || contains(signalName, 'T')
        categories.torques{end+1} = signalName;
    elseif contains(signalName, 'energy') || contains(signalName, 'kinetic') || contains(signalName, 'potential')
        categories.energy{end+1} = signalName;
    else
        categories.other{end+1} = signalName;
    end
end

% Display categories
fprintf('\nJoint States (%d):\n', length(categories.joint_states));
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

fprintf('\nAccelerations (%d):\n', length(categories.accelerations));
for i = 1:length(categories.accelerations)
    fprintf('  - %s\n', categories.accelerations{i});
end

fprintf('\nForces (%d):\n', length(categories.forces));
for i = 1:length(categories.forces)
    fprintf('  - %s\n', categories.forces{i});
end

fprintf('\nTorques (%d):\n', length(categories.torques));
for i = 1:length(categories.torques)
    fprintf('  - %s\n', categories.torques{i});
end

fprintf('\nEnergy (%d):\n', length(categories.energy));
for i = 1:length(categories.energy)
    fprintf('  - %s\n', categories.energy{i});
end

%% Extract data and convert to logsout format
fprintf('\n--- Extracting Data to logsout Format ---\n');

% Create a logsout-like structure
logsout = Simulink.SimulationData.Dataset;

% Define signals to extract (prioritize core signals for neural network)
core_signals = {'q', 'qd', 'qdd', 'tau'};
extraction_signals = {};

% Find signals that match core requirements
for i = 1:length(core_signals)
    core_signal = core_signals{i};
    found = false;
    
    for j = 1:length(signals)
        signal = signals(j);
        if contains(signal.Name, core_signal)
            extraction_signals{end+1} = signal.Name;
            found = true;
            fprintf('✓ Found %s: %s\n', core_signal, signal.Name);
            break;
        end
    end
    
    if ~found
        fprintf('⚠ Missing %s\n', core_signal);
    end
end

% Add additional useful signals
additional_signals = {'CHx', 'CHy', 'CHz', 'CHvx', 'CHvy', 'CHvz', 'MHx', 'MHy', 'MHz'};
for i = 1:length(additional_signals)
    add_signal = additional_signals{i};
    for j = 1:length(signals)
        signal = signals(j);
        if contains(signal.Name, add_signal)
            extraction_signals{end+1} = signal.Name;
            fprintf('✓ Found %s: %s\n', add_signal, signal.Name);
            break;
        end
    end
end

%% Extract data for each signal
fprintf('\nExtracting data for %d signals...\n', length(extraction_signals));

extracted_data = struct();
extracted_data.time = [];
extracted_data.signals = struct();

for i = 1:length(extraction_signals)
    signalName = extraction_signals{i};
    
    try
        % Find the signal in the run
        signal = runObj.getSignalByIndex(i);
        
        % Get time and data
        [data, time] = signal.getData;
        
        % Store in extracted_data
        if isempty(extracted_data.time)
            extracted_data.time = time;
        end
        
        % Clean signal name for use as field name
        cleanName = strrep(signalName, ' ', '_');
        cleanName = strrep(cleanName, '-', '_');
        cleanName = strrep(cleanName, '.', '_');
        
        extracted_data.signals.(cleanName) = data;
        
        fprintf('  ✓ Extracted %s (%d time points)\n', signalName, length(time));
        
    catch ME
        fprintf('  ✗ Failed to extract %s: %s\n', signalName, ME.message);
    end
end

%% Create logsout-compatible structure
fprintf('\n--- Creating logsout-Compatible Structure ---\n');

% Create a structure that mimics logsout
logsout_struct = struct();
logsout_struct.numElements = length(fieldnames(extracted_data.signals));
logsout_struct.time = extracted_data.time;

% Add get method simulation
logsout_struct.get = @(name) getSignalElement(logsout_struct, name, extracted_data);

% Save the extracted data
save('extracted_simscape_data.mat', 'extracted_data', 'logsout_struct', 'extraction_signals');

fprintf('Extracted data saved to: extracted_simscape_data.mat\n');

%% Test extraction with neural network pipeline
fprintf('\n--- Testing with Neural Network Pipeline ---\n');

% Create a mock simulation output
mock_simOut = struct();
mock_simOut.logsout = logsout_struct;

% Test the extractSimKinematics function
try
    simData = extractSimKinematics(mock_simOut);
    fprintf('✓ Successfully extracted kinematics data!\n');
    fprintf('  - Joint positions: %dx%d\n', size(simData.q, 1), size(simData.q, 2));
    fprintf('  - Joint velocities: %dx%d\n', size(simData.qd, 1), size(simData.qd, 2));
    fprintf('  - Joint accelerations: %dx%d\n', size(simData.qdd, 1), size(simData.qdd, 2));
    fprintf('  - Joint torques: %dx%d\n', size(simData.tau, 1), size(simData.tau, 2));
catch ME
    fprintf('✗ Failed to extract kinematics: %s\n', ME.message);
end

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Total Simscape signals found: %d\n', length(signals));
fprintf('Signals extracted: %d\n', length(extraction_signals));
fprintf('Data points per signal: %d\n', length(extracted_data.time));

fprintf('\nExtraction complete!\n');
fprintf('You can now use the extracted data with the neural network pipeline.\n');

%% Helper Functions

function element = getSignalElement(logsout_struct, name, extracted_data)
    % Simulate logsout.get() method
    
    % Find the signal in extracted data
    signalNames = fieldnames(extracted_data.signals);
    
    for i = 1:length(signalNames)
        if contains(signalNames{i}, name)
            % Create a signal element structure
            element = struct();
            element.Name = signalNames{i};
            element.Values = struct();
            element.Values.Data = extracted_data.signals.(signalNames{i});
            element.Values.Time = extracted_data.time;
            return;
        end
    end
    
    % If not found, throw error
    error('Signal %s not found in extracted data', name);
end 