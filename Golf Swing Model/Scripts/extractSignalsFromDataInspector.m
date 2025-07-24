% extractSignalsFromDataInspector.m
% Extract signals directly from the Data Inspector
% This is needed when signals are logged to Data Inspector but not workspace

clear; clc;

fprintf('=== Extracting Signals from Data Inspector ===\n\n');

%% Step 1: Check Data Inspector Runs
fprintf('--- Step 1: Checking Data Inspector Runs ---\n');

runIDs = Simulink.sdi.getAllRunIDs;
if isempty(runIDs)
    fprintf('✗ No runs found in Data Inspector\n');
    return;
end

fprintf('✓ Found %d runs in Data Inspector\n', length(runIDs));

%% Step 2: Analyze First Run
fprintf('\n--- Step 2: Analyzing First Run ---\n');

% Get the first run
run = Simulink.sdi.getRun(runIDs(1));
fprintf('Analyzing run: %s\n', run.Name);

% Get all signals in this run
signals = run.getAllSignals;
fprintf('Total signals in run: %d\n', length(signals));

if length(signals) == 0
    fprintf('✗ No signals found in run\n');
    return;
end

%% Step 3: Display All Signal Names
fprintf('\n--- Step 3: All Signal Names ---\n');

allSignalNames = {};
for i = 1:length(signals)
    signal = signals(i);
    signalName = signal.Name;
    allSignalNames{end+1} = signalName;
    fprintf('  %d. %s\n', i, signalName);
end

%% Step 4: Extract Joint Center Positions
fprintf('\n--- Step 4: Extracting Joint Center Positions ---\n');

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

%% Step 5: Save Results
fprintf('\n--- Step 5: Saving Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('DataInspector_Extraction_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save joint center data
if ~isempty(fieldnames(jointCenterData))
    jcFilename = fullfile(outputDir, 'joint_centers_from_data_inspector.mat');
    save(jcFilename, 'jointCenterData');
    fprintf('✓ Joint center data saved to: %s\n', jcFilename);
else
    fprintf('✗ No joint center data to save\n');
end

% Save all signal names
signalNamesFilename = fullfile(outputDir, 'all_signal_names.mat');
save(signalNamesFilename, 'allSignalNames');
fprintf('✓ All signal names saved to: %s\n', signalNamesFilename);

%% Step 6: Summary Report
fprintf('\n--- Step 6: Summary Report ---\n');

fprintf('Data Inspector Analysis Summary:\n');
fprintf('  Total runs: %d\n', length(runIDs));
fprintf('  Total signals: %d\n', length(allSignalNames));
fprintf('  Joint center signals found: %d\n', length(jointCenterSignals));

if length(jointCenterSignals) > 0
    fprintf('\nJoint center signals found:\n');
    for i = 1:length(jointCenterSignals)
        fprintf('  - %s\n', jointCenterSignals{i});
    end
    fprintf('\n🎉 SUCCESS! Joint center positions extracted from Data Inspector!\n');
else
    fprintf('\n⚠️  No joint center signals identified.\n');
    fprintf('Check signal names and logging configuration.\n');
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Data Inspector extraction completed! 🚀\n'); 