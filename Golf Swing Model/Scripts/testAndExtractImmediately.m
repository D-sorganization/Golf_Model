% testAndExtractImmediately.m
% Run simulation and immediately extract signals from Data Inspector
% This ensures we capture the signals before they get cleared

clear; clc;

fprintf('=== Test and Extract Immediately ===\n\n');
fprintf('This script will:\n');
fprintf('1. Run a quick simulation with signal logging\n');
fprintf('2. Immediately extract signals from Data Inspector\n');
fprintf('3. Show ALL signals to verify we capture everything we need\n\n');

%% Step 1: Run Simulation
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

%% Step 2: Check Workspace Output
fprintf('\n--- Step 2: Checking Workspace Output ---\n');

if isfield(simOut, 'out') && ~isempty(simOut.out)
    logsout = simOut.out;
    fprintf('✓ Out data available in workspace\n');
    
    % Get all signal names
    allSignalNames = {};
    for i = 1:logsout.numElements
        signalElement = logsout.getElement(i);
        allSignalNames{end+1} = signalElement.Name;
    end
    
    fprintf('Total signals in workspace: %d\n', length(allSignalNames));
    fprintf('\nALL workspace signal names:\n');
    for i = 1:length(allSignalNames)
        fprintf('  %d. %s\n', i, allSignalNames{i});
    end
else
    fprintf('✗ No out data in workspace\n');
end

%% Step 3: Check Data Inspector
fprintf('\n--- Step 3: Checking Data Inspector ---\n');

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

if length(signals) == 0
    fprintf('✗ No signals found in Data Inspector run\n');
    return;
end

%% Step 4: Display All Data Inspector Signals
fprintf('\n--- Step 4: All Data Inspector Signals ---\n');

allDISignalNames = {};
for i = 1:length(signals)
    signal = signals(i);
    signalName = signal.Name;
    allDISignalNames{end+1} = signalName;
    fprintf('  %d. %s\n', i, signalName);
end

%% Step 5: Extract Joint Center Positions
fprintf('\n--- Step 5: Extracting Joint Center Positions ---\n');

jointCenterSignals = {};
jointCenterData = struct();

% Look for joint center position signals
for i = 1:length(signals)
    signal = signals(i);
    signalName = signal.Name;
    
    % Check if this signal contains joint center position data
    if contains(lower(signalName), 'joint') || ...
       contains(lower(signalName), 'center') || ...
       contains(lower(signalName), 'position') || ...
       contains(lower(signalName), 'pos')
        
        jointCenterSignals{end+1} = signalName;
        fprintf('  Found joint center signal: %s\n', signalName);
        
        % Extract the data
        try
            signalData = signal.Values;
            if ~isempty(signalData)
                % Convert to our format
                jointCenterData.(signalName) = signalData.Data;
                fprintf('    ✓ Data extracted (%d time points)\n', length(signalData.Data));
            end
        catch ME
            fprintf('    ✗ Error extracting data: %s\n', ME.message);
        end
    end
end

%% Step 6: Save Results
fprintf('\n--- Step 6: Saving Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('Immediate_Extraction_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save joint center data
if ~isempty(fieldnames(jointCenterData))
    jcFilename = fullfile(outputDir, 'joint_centers_immediate.mat');
    save(jcFilename, 'jointCenterData');
    fprintf('✓ Joint center data saved to: %s\n', jcFilename);
else
    fprintf('✗ No joint center data to save\n');
end

% Save all signal names from Data Inspector
if ~isempty(allDISignalNames)
    signalNamesFilename = fullfile(outputDir, 'all_data_inspector_signals.mat');
    save(signalNamesFilename, 'allDISignalNames');
    fprintf('✓ All Data Inspector signal names saved to: %s\n', signalNamesFilename);
end

% Save workspace signal names if available
if exist('allSignalNames', 'var') && ~isempty(allSignalNames)
    wsSignalNamesFilename = fullfile(outputDir, 'all_workspace_signals.mat');
    save(wsSignalNamesFilename, 'allSignalNames');
    fprintf('✓ All workspace signal names saved to: %s\n', wsSignalNamesFilename);
end

%% Step 7: Final Summary
fprintf('\n--- Step 7: Final Summary ---\n');

fprintf('Immediate Extraction Summary:\n');
fprintf('  Data Inspector runs: %d\n', length(runIDs));
fprintf('  Data Inspector signals: %d\n', length(allDISignalNames));

if exist('allSignalNames', 'var')
    fprintf('  Workspace signals: %d\n', length(allSignalNames));
else
    fprintf('  Workspace signals: 0\n');
end

fprintf('  Joint center signals found: %d\n', length(jointCenterSignals));

if length(jointCenterSignals) > 0
    fprintf('\nJoint center signals found:\n');
    for i = 1:length(jointCenterSignals)
        fprintf('  - %s\n', jointCenterSignals{i});
    end
    fprintf('\n🎉 SUCCESS! Joint center positions extracted!\n');
else
    fprintf('\n⚠️  No joint center signals identified.\n');
    fprintf('Check signal names and logging configuration.\n');
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Immediate extraction completed! 🚀\n'); 