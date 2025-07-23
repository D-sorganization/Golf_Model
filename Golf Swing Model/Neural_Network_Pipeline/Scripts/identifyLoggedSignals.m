
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

if isempty(loggedLines)
    fprintf('No individual signals are currently being logged.\n');
    fprintf('You may need to enable signal logging in the Simulink model.\n');
end

%% Find SignalBus objects
fprintf('\n--- Finding SignalBus Objects ---\n');

% Find all SignalBus blocks (including in subsystems)
signalBusBlocks = find_system(modelName, 'FindAll', 'on', 'BlockType', 'BusCreator');

fprintf('Found %d BusCreator blocks (potential SignalBus sources).\n', length(signalBusBlocks));

% Find logged SignalBus lines
loggedBusLines = {};
busSignalInfo = [];

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
                    if isempty(busSignalInfo)
                        busSignalInfo = struct('name', {busName}, 'path', {busPath}, 'line', {outLine});
                    else
                        busSignalInfo(end+1).name = busName;
                        busSignalInfo(end).path = busPath;
                        busSignalInfo(end).line = outLine;
                    end
                    
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

%% Extract individual signal information with subsystem analysis
signalInfo = [];
signalNames = {};
subsystemSignals = struct();

fprintf('\n--- Logged Individual Signal Details ---\n');
fprintf('%-30s %-40s %-15s %-10s %-15s\n', 'Signal Name', 'Full Path', 'Port', 'Dimensions', 'Subsystem');
fprintf('%s\n', repmat('-', 1, 120));

if ~isempty(loggedLines)
    for i = 1:length(loggedLines)
    line = loggedLines(i);
    
    % Get signal name
    signalName = get(line, 'Name');
    if isempty(signalName)
        signalName = sprintf('Signal_%d', i);
    end
    
    % Get block path
    blockPath = get(line, 'Parent');
    
    % Determine if signal is in a subsystem
    isInSubsystem = false;
    subsystemName = '';
    if contains(blockPath, '/')
        pathParts = strsplit(blockPath, '/');
        if length(pathParts) > 2  % More than just model name and block name
            % Find the subsystem (everything between model name and block name)
            subsystemPath = strjoin(pathParts(2:end-1), '/');
            subsystemName = pathParts{2}; % First level subsystem
            isInSubsystem = true;
        end
    end
    
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
    if isempty(signalInfo)
        signalInfo = struct('name', {signalName}, 'blockPath', {blockPath}, 'port', {portNum}, ...
                           'dimensions', {dimsStr}, 'type', {'individual'}, 'isInSubsystem', {isInSubsystem}, ...
                           'subsystemName', {subsystemName}, 'subsystemPath', {subsystemPath});
    else
        signalInfo(i).name = signalName;
        signalInfo(i).blockPath = blockPath;
        signalInfo(i).port = portNum;
        signalInfo(i).dimensions = dimsStr;
        signalInfo(i).type = 'individual';
        signalInfo(i).isInSubsystem = isInSubsystem;
        signalInfo(i).subsystemName = subsystemName;
        signalInfo(i).subsystemPath = subsystemPath;
    end
    
    signalNames{end+1} = signalName;
    
    % Track subsystem signals
    if isInSubsystem
        if ~isfield(subsystemSignals, subsystemName)
            subsystemSignals.(subsystemName) = {};
        end
        subsystemSignals.(subsystemName){end+1} = signalName;
    end
    
    % Display information
    fprintf('%-30s %-40s %-15s %-10s %-15s\n', ...
           signalName, ...
           extractAfter(blockPath, '/'), ...
           num2str(portNum), ...
           dimsStr, ...
           subsystemName);
    end
end

%% Extract SignalBus constituent signals with subsystem analysis
fprintf('\n--- SignalBus Constituent Signals ---\n');

busConstituentSignals = {};
busSignalNames = {};

if ~isempty(busSignalInfo) && isstruct(busSignalInfo)
    for i = 1:length(busSignalInfo)
        busInfo = busSignalInfo(i);
        busBlock = find_system(modelName, 'FindAll', 'on', 'Name', busInfo.name, 'BlockType', 'BusCreator');
    
    if ~isempty(busBlock)
        busBlock = busBlock(1); % Take the first match
        
        % Determine if SignalBus is in a subsystem
        busPath = get(busBlock, 'Parent');
        isBusInSubsystem = false;
        busSubsystemName = '';
        if contains(busPath, '/')
            pathParts = strsplit(busPath, '/');
            if length(pathParts) > 2
                busSubsystemName = pathParts{2};
                isBusInSubsystem = true;
            end
        end
        
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
                        busConstituentSignals{end}.isInSubsystem = isBusInSubsystem;
                        busConstituentSignals{end}.subsystemName = busSubsystemName;
                        
                        busSignalNames{end+1} = signalName;
                        
                        fprintf('  - %s (via SignalBus: %s', signalName, busInfo.name);
                        if isBusInSubsystem
                            fprintf(' in %s', busSubsystemName);
                        end
                        fprintf(')\n');
                    end
                end
            end
        catch ME
            fprintf('  ⚠ Could not extract signals from SignalBus %s: %s\n', busInfo.name, ME.message);
        end
    end
    end
end

fprintf('Found %d constituent signals in logged SignalBus objects.\n', length(busConstituentSignals));

%% Subsystem Analysis
fprintf('\n--- Subsystem Signal Analysis ---\n');

subsystemNames = fieldnames(subsystemSignals);
if ~isempty(subsystemNames)
    fprintf('Signals found in subsystems:\n');
    for i = 1:length(subsystemNames)
        subsystemName = subsystemNames{i};
        signals = subsystemSignals.(subsystemName);
        fprintf('  %s (%d signals):\n', subsystemName, length(signals));
        for j = 1:length(signals)
            fprintf('    - %s\n', signals{j});
        end
    end
else
    fprintf('No signals found in subsystems (all signals are at top level).\n');
end

% Count signals by location
topLevelSignals = 0;
subsystemSignalCount = 0;

if ~isempty(signalInfo) && isstruct(signalInfo)
    for i = 1:length(signalInfo)
        if signalInfo(i).isInSubsystem
            subsystemSignalCount = subsystemSignalCount + 1;
        else
            topLevelSignals = topLevelSignals + 1;
        end
    end
end

fprintf('\nSignal distribution:\n');
fprintf('  Top level signals: %d\n', topLevelSignals);
fprintf('  Subsystem signals: %d\n', subsystemSignalCount);
fprintf('  SignalBus constituent signals: %d\n', length(busConstituentSignals));

%% Combine all signals
allSignalNames = [signalNames, busSignalNames];

% Handle empty arrays properly
if isempty(signalInfo) && isempty(busConstituentSignals)
    allSignalInfo = [];
elseif isempty(signalInfo)
    allSignalInfo = busConstituentSignals;
elseif isempty(busConstituentSignals)
    allSignalInfo = signalInfo;
else
    allSignalInfo = [signalInfo, busConstituentSignals];
end

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

if ~isempty(busSignalInfo) && isstruct(busSignalInfo)
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
    fprintf('\nTo enable SignalBus logging:\n');
    fprintf('1. Find the SignalBus output line in your model\n');
    fprintf('2. Right-click on the SignalBus line\n');
    fprintf('3. Select "Signal Properties" -> "Logging" -> "Log signal data"\n');
    fprintf('4. Set an appropriate signal name for the bus\n');
end

%% Simscape Results Explorer Analysis
fprintf('\n--- Simscape Results Explorer Analysis ---\n');

% Check Simscape logging settings
try
    simscapeLogType = get_param(modelName, 'SimscapeLogType');
    fprintf('Simscape logging type: %s\n', simscapeLogType);
    
    if strcmp(simscapeLogType, 'none')
        fprintf('⚠ Simscape logging is disabled. Enable it to access Simscape Results Explorer data.\n');
        fprintf('To enable: Set SimscapeLogType to ''all'' or ''sensors'' in model parameters.\n');
    else
        fprintf('✓ Simscape logging is enabled.\n');
        
        % Try to access Simscape Results Explorer data
        try
            % Check if there are any Simscape runs
            simscapeRuns = Simulink.sdi.getAllRunIDs;
            
            if ~isempty(simscapeRuns)
                fprintf('Found %d Simscape runs in Results Explorer.\n', length(simscapeRuns));
                
                % Get the most recent run
                latestRun = simscapeRuns(end);
                runObj = Simulink.sdi.getRun(latestRun);
                
                fprintf('Latest run: %s (ID: %d)\n', runObj.Name, latestRun);
                
                % Get all signals from the run
                signals = runObj.getAllSignals;
                fprintf('Total Simscape signals available: %d\n', length(signals));
                
                if length(signals) > 0
                    fprintf('\n--- Available Simscape Signals ---\n');
                    
                    % Categorize Simscape signals
                    simscapeCategories = struct();
                    simscapeCategories.joint_states = {};
                    simscapeCategories.positions = {};
                    simscapeCategories.velocities = {};
                    simscapeCategories.forces = {};
                    simscapeCategories.torques = {};
                    simscapeCategories.energy = {};
                    simscapeCategories.other = {};
                    
                    simscapeSignalNames = {};
                    
                    for i = 1:length(signals)
                        signal = signals(i);
                        signalName = signal.Name;
                        simscapeSignalNames{end+1} = signalName;
                        
                        % Categorize based on name patterns
                        if contains(signalName, 'q') || contains(signalName, 'joint')
                            simscapeCategories.joint_states{end+1} = signalName;
                        elseif contains(signalName, 'x') || contains(signalName, 'y') || contains(signalName, 'z') || contains(signalName, 'pos')
                            simscapeCategories.positions{end+1} = signalName;
                        elseif contains(signalName, 'v') || contains(signalName, 'vel') || contains(signalName, 'd')
                            simscapeCategories.velocities{end+1} = signalName;
                        elseif contains(signalName, 'force') || contains(signalName, 'F')
                            simscapeCategories.forces{end+1} = signalName;
                        elseif contains(signalName, 'torque') || contains(signalName, 'tau') || contains(signalName, 'T')
                            simscapeCategories.torques{end+1} = signalName;
                        elseif contains(signalName, 'energy') || contains(signalName, 'kinetic') || contains(signalName, 'potential')
                            simscapeCategories.energy{end+1} = signalName;
                        else
                            simscapeCategories.other{end+1} = signalName;
                        end
                    end
                    
                    % Display categories
                    fprintf('Joint States (%d):\n', length(simscapeCategories.joint_states));
                    for i = 1:length(simscapeCategories.joint_states)
                        fprintf('  - %s\n', simscapeCategories.joint_states{i});
                    end
                    
                    fprintf('\nPositions (%d):\n', length(simscapeCategories.positions));
                    for i = 1:length(simscapeCategories.positions)
                        fprintf('  - %s\n', simscapeCategories.positions{i});
                    end
                    
                    fprintf('\nVelocities (%d):\n', length(simscapeCategories.velocities));
                    for i = 1:length(simscapeCategories.velocities)
                        fprintf('  - %s\n', simscapeCategories.velocities{i});
                    end
                    
                    fprintf('\nForces (%d):\n', length(simscapeCategories.forces));
                    for i = 1:length(simscapeCategories.forces)
                        fprintf('  - %s\n', simscapeCategories.forces{i});
                    end
                    
                    fprintf('\nTorques (%d):\n', length(simscapeCategories.torques));
                    for i = 1:length(simscapeCategories.torques)
                        fprintf('  - %s\n', simscapeCategories.torques{i});
                    end
                    
                    fprintf('\nEnergy (%d):\n', length(simscapeCategories.energy));
                    for i = 1:length(simscapeCategories.energy)
                        fprintf('  - %s\n', simscapeCategories.energy{i});
                    end
                    
                    fprintf('\nOther (%d):\n', length(simscapeCategories.other));
                    for i = 1:length(simscapeCategories.other)
                        fprintf('  - %s\n', simscapeCategories.other{i});
                    end
                    
                    % Check for required signals in Simscape data
                    fprintf('\n--- Neural Network Requirements Check (Simscape) ---\n');
                    required_signals = {'q', 'qd', 'qdd', 'tau'};
                    missing_simscape = {};
                    found_simscape = {};
                    
                    for i = 1:length(required_signals)
                        req_signal = required_signals{i};
                        found = false;
                        
                        for j = 1:length(simscapeSignalNames)
                            if contains(simscapeSignalNames{j}, req_signal)
                                fprintf('✓ Found %s: %s (Simscape)\n', req_signal, simscapeSignalNames{j});
                                found_simscape{end+1} = req_signal;
                                found = true;
                                break;
                            end
                        end
                        
                        if ~found
                            fprintf('✗ Missing %s in Simscape data\n', req_signal);
                            missing_simscape{end+1} = req_signal;
                        end
                    end
                    
                    % Add Simscape signals to overall results
                    allSignalNames = [allSignalNames, simscapeSignalNames];
                    
                    % Update categories with Simscape signals
                    categories.joint_states = [categories.joint_states, simscapeCategories.joint_states];
                    categories.positions = [categories.positions, simscapeCategories.positions];
                    categories.velocities = [categories.velocities, simscapeCategories.velocities];
                    categories.forces = [categories.forces, simscapeCategories.forces];
                    categories.torques = [categories.torques, simscapeCategories.torques];
                    categories.other = [categories.other, simscapeCategories.other];
                    
                else
                    fprintf('No signals found in Simscape Results Explorer.\n');
                end
                
            else
                fprintf('No Simscape runs found in Results Explorer.\n');
                fprintf('Run a simulation to generate Simscape data.\n');
            end
            
        catch ME
            fprintf('Error accessing Simscape Results Explorer: %s\n', ME.message);
            fprintf('Make sure you have run a simulation and Simscape logging is enabled.\n');
        end
        
    end
    
catch ME
    fprintf('Error checking Simscape logging settings: %s\n', ME.message);
end

%% Data Inspector Analysis
fprintf('\n--- Data Inspector Analysis ---\n');

try
    % Check if Data Inspector has any data
    inspectorRuns = Simulink.sdi.getAllRunIDs;
    
    if ~isempty(inspectorRuns)
        fprintf('Found %d runs in Data Inspector.\n', length(inspectorRuns));
        
        % Get the most recent run
        latestRun = inspectorRuns(end);
        runObj = Simulink.sdi.getRun(latestRun);
        
        % Get all signals from Data Inspector
        inspectorSignals = runObj.getAllSignals;
        fprintf('Total Data Inspector signals: %d\n', length(inspectorSignals));
        
        if length(inspectorSignals) > 0
            inspectorSignalNames = {};
            for i = 1:length(inspectorSignals)
                signal = inspectorSignals(i);
                inspectorSignalNames{end+1} = signal.Name;
            end
            
            fprintf('Data Inspector signals:\n');
            for i = 1:min(10, length(inspectorSignalNames))  % Show first 10
                fprintf('  - %s\n', inspectorSignalNames{i});
            end
            if length(inspectorSignalNames) > 10
                fprintf('  ... and %d more signals\n', length(inspectorSignalNames) - 10);
            end
            
            % Add to overall results
            allSignalNames = [allSignalNames, inspectorSignalNames];
        end
    else
        fprintf('No runs found in Data Inspector.\n');
    end
    
catch ME
    fprintf('Error accessing Data Inspector: %s\n', ME.message);
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
results.subsystemSignals = subsystemSignals;
results.total_individual_signals = length(loggedLines);
results.total_bus_signals = length(busConstituentSignals);
results.total_signals = length(allSignalNames);
results.topLevelSignals = topLevelSignals;
results.subsystemSignalCount = subsystemSignalCount;

save('logged_signals_analysis.mat', 'results');
fprintf('Analysis saved to: logged_signals_analysis.mat\n');

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Individual logged signals: %d\n', length(loggedLines));
fprintf('  - Top level signals: %d\n', topLevelSignals);
fprintf('  - Subsystem signals: %d\n', subsystemSignalCount);
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