
% identifyLoggedSignals.m
% Identifies what signals are currently being logged in the GolfSwing3D_Kinetic model
% This helps understand what data is available for the neural network pipeline
% Enhanced to handle SignalBus logging and extract constituent signals

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

%% Find all logged signals (individual lines)
fprintf('\n--- Finding Logged Individual Signals ---\n');

% Find all lines with signal logging enabled
loggedLines = find_system(modelName, 'FindAll', 'on', 'Type', 'line', 'SignalLogging', 'on');

fprintf('Found %d individual signals with logging enabled.\n', length(loggedLines));

%% Find SignalBus objects
fprintf('\n--- Finding SignalBus Objects ---\n');

% Find all SignalBus blocks
signalBusBlocks = find_system(modelName, 'FindAll', 'on', 'BlockType', 'BusCreator');

fprintf('Found %d BusCreator blocks (potential SignalBus sources).\n', length(signalBusBlocks));

% Find logged SignalBus lines
loggedBusLines = {};
busSignalInfo = struct();

for i = 1:length(signalBusBlocks)
    busBlock = signalBusBlocks(i);
    busPath = get(busBlock, 'Parent');
    busName = get(busBlock, 'Name');
    
    % Check if the bus output line is logged
    try
        busLine = get(busBlock, 'LineHandles');
        if isfield(busLine, 'Outport') && ~isempty(busLine.Outport)
            outLine = busLine.Outport(1);
            if outLine > 0
                isLogged = get(outLine, 'SignalLogging');
                if strcmp(isLogged, 'on')
                    loggedBusLines{end+1} = outLine;
                    
                    % Get bus signal information
                    busSignalInfo(end+1).name = busName;
                    busSignalInfo(end).path = busPath;
                    busSignalInfo(end).line = outLine;
                    
                    fprintf('✓ Found logged SignalBus: %s at %s\n', busName, busPath);
                end
            end
        end
    catch ME
        % Skip if we can't access the line
        continue;
    end
end

fprintf('Found %d logged SignalBus objects.\n', length(loggedBusLines));

%% Extract individual signal information
signalInfo = struct();
signalNames = {};

fprintf('\n--- Logged Individual Signal Details ---\n');
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
    signalInfo(i).type = 'individual';
    
    signalNames{end+1} = signalName;
    
    % Display information
    fprintf('%-30s %-20s %-15s %-10s\n', ...
           signalName, ...
           extractAfter(blockPath, '/'), ...
           num2str(portNum), ...
           dimsStr);
end

%% Extract SignalBus constituent signals
fprintf('\n--- SignalBus Constituent Signals ---\n');

busConstituentSignals = {};
busSignalNames = {};

for i = 1:length(busSignalInfo)
    busInfo = busSignalInfo(i);
    busBlock = find_system(modelName, 'FindAll', 'on', 'Name', busInfo.name, 'BlockType', 'BusCreator');
    
    if ~isempty(busBlock)
        busBlock = busBlock(1); % Take the first match
        
        % Get input ports (constituent signals)
        try
            inPorts = get(busBlock, 'PortHandles');
            if isfield(inPorts, 'Inport')
                for j = 1:length(inPorts.Inport)
                    inPort = inPorts.Inport(j);
                    
                    % Get the line connected to this input port
                    inLine = get(inPort, 'Line');
                    if inLine > 0
                        % Get signal name from the connected line
                        signalName = get(inLine, 'Name');
                        if isempty(signalName)
                            % Try to get from source block
                            srcPort = get(inLine, 'SrcPortHandle');
                            if srcPort > 0
                                srcBlock = get(srcPort, 'Parent');
                                signalName = get(srcBlock, 'Name');
                            else
                                signalName = sprintf('%s_Input_%d', busInfo.name, j);
                            end
                        end
                        
                        % Get signal dimensions
                        try
                            signalDims = get(inLine, 'CompiledPortDimensions');
                            if ~isempty(signalDims)
                                dimsStr = sprintf('[%s]', num2str(signalDims));
                            else
                                dimsStr = 'Unknown';
                            end
                        catch
                            dimsStr = 'Unknown';
                        end
                        
                        % Store bus constituent signal
                        busConstituentSignals{end+1} = struct();
                        busConstituentSignals{end}.name = signalName;
                        busConstituentSignals{end}.busName = busInfo.name;
                        busConstituentSignals{end}.busPath = busInfo.path;
                        busConstituentSignals{end}.port = j;
                        busConstituentSignals{end}.dimensions = dimsStr;
                        busConstituentSignals{end}.type = 'bus_constituent';
                        
                        busSignalNames{end+1} = signalName;
                        
                        fprintf('  - %s (via SignalBus: %s)\n', signalName, busInfo.name);
                    end
                end
            end
        catch ME
            fprintf('  ⚠ Could not extract signals from SignalBus %s: %s\n', busInfo.name, ME.message);
        end
    end
end

fprintf('Found %d constituent signals in logged SignalBus objects.\n', length(busConstituentSignals));

%% Combine all signals
allSignalNames = [signalNames, busSignalNames];
allSignalInfo = [signalInfo, busConstituentSignals];

fprintf('\n--- Combined Signal Summary ---\n');
fprintf('Individual logged signals: %d\n', length(signalNames));
fprintf('SignalBus constituent signals: %d\n', length(busSignalNames));
fprintf('Total available signals: %d\n', length(allSignalNames));

%% Categorize all signals
fprintf('\n--- Signal Categories ---\n');

% Define categories based on signal names
categories = struct();
categories.joint_states = {};
categories.positions = {};
categories.velocities = {};
categories.forces = {};
categories.torques = {};
categories.other = {};

for i = 1:length(allSignalNames)
    name = allSignalNames{i};
    
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
    
    for j = 1:length(allSignalNames)
        if contains(allSignalNames{j}, req_signal)
            fprintf('✓ Found %s: %s\n', req_signal, allSignalNames{j});
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
    fprintf('2. Find the signal lines carrying the required data\n');
    fprintf('3. Either:\n');
    fprintf('   a) Right-click on individual signal lines -> "Signal Properties" -> "Logging" -> "Log signal data"\n');
    fprintf('   b) Add them to an existing SignalBus that is already being logged\n');
    fprintf('4. Set appropriate signal names (q, qd, qdd, tau)\n');
else
    fprintf('✓ All required signals for neural network training are available!\n');
end

%% SignalBus Analysis
fprintf('\n--- SignalBus Analysis ---\n');

if ~isempty(busSignalInfo)
    fprintf('Logged SignalBus objects found:\n');
    for i = 1:length(busSignalInfo)
        fprintf('  - %s at %s\n', busSignalInfo(i).name, busSignalInfo(i).path);
    end
    
    fprintf('\nTo access SignalBus data in simulation output:\n');
    fprintf('1. The SignalBus will appear as a single logged signal\n');
    fprintf('2. Use logsout.getElement() to access the bus\n');
    fprintf('3. Use .getElement() on the bus to access individual signals\n');
    fprintf('4. Example: busSignal = logsout.getElement(''SignalBusName'');\n');
    fprintf('           q_signal = busSignal.getElement(''q'');\n');
else
    fprintf('No logged SignalBus objects found.\n');
end

%% Save results
fprintf('\n--- Saving Results ---\n');

results.signalInfo = signalInfo;
results.signalNames = signalNames;
results.busSignalInfo = busSignalInfo;
results.busConstituentSignals = busConstituentSignals;
results.busSignalNames = busSignalNames;
results.allSignalNames = allSignalNames;
results.allSignalInfo = allSignalInfo;
results.categories = categories;
results.missing_signals = missing_signals;
results.total_individual_signals = length(loggedLines);
results.total_bus_signals = length(busConstituentSignals);
results.total_signals = length(allSignalNames);

save('logged_signals_analysis.mat', 'results');
fprintf('Analysis saved to: logged_signals_analysis.mat\n');

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Individual logged signals: %d\n', length(loggedLines));
fprintf('Logged SignalBus objects: %d\n', length(busSignalInfo));
fprintf('SignalBus constituent signals: %d\n', length(busConstituentSignals));
fprintf('Total available signals: %d\n', length(allSignalNames));
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