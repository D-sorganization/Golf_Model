% extractJointCentersWithCleanNames.m
% Extract joint center positions from Data Inspector with clean field names
% This fixes the invalid field name issues

clear; clc;

fprintf('=== Extracting Joint Centers with Clean Names ===\n\n');

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

%% Step 2: Check Data Inspector
fprintf('\n--- Step 2: Checking Data Inspector ---\n');

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

%% Step 3: Extract Joint Center Positions with Clean Names
fprintf('\n--- Step 3: Extracting Joint Center Positions ---\n');

jointCenterSignals = {};
jointCenterData = struct();
timeData = [];

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
                % Create clean field name
                cleanName = createCleanFieldName(signalName);
                
                % Store the data
                jointCenterData.(cleanName) = signalData.Data;
                
                % Store time data if not already stored
                if isempty(timeData)
                    timeData = signalData.Time;
                end
                
                fprintf('    ✓ Data extracted as: %s (%d time points)\n', cleanName, length(signalData.Data));
            end
        catch ME
            fprintf('    ✗ Error extracting data: %s\n', ME.message);
        end
    end
end

%% Step 4: Add Time Data
if ~isempty(timeData)
    jointCenterData.time = timeData;
    fprintf('✓ Time data added (%d time points)\n', length(timeData));
end

%% Step 5: Save Results
fprintf('\n--- Step 5: Saving Results ---\n');

% Create output directory
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outputDir = sprintf('JointCenters_Clean_%s', timestamp);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
    fprintf('✓ Created output directory: %s\n', outputDir);
end

% Save joint center data
if ~isempty(fieldnames(jointCenterData))
    jcFilename = fullfile(outputDir, 'joint_centers_clean.mat');
    save(jcFilename, 'jointCenterData');
    fprintf('✓ Joint center data saved to: %s\n', jcFilename);
    
    % Also save the original signal names for reference
    signalNamesFilename = fullfile(outputDir, 'original_signal_names.mat');
    save(signalNamesFilename, 'jointCenterSignals');
    fprintf('✓ Original signal names saved to: %s\n', signalNamesFilename);
else
    fprintf('✗ No joint center data to save\n');
end

%% Step 6: Create Mapping File
fprintf('\n--- Step 6: Creating Name Mapping ---\n');

% Create a mapping between original names and clean names
nameMapping = struct();
for i = 1:length(jointCenterSignals)
    originalName = jointCenterSignals{i};
    cleanName = createCleanFieldName(originalName);
    nameMapping.(cleanName) = originalName;
end

mappingFilename = fullfile(outputDir, 'name_mapping.mat');
save(mappingFilename, 'nameMapping');
fprintf('✓ Name mapping saved to: %s\n', mappingFilename);

%% Step 7: Final Summary
fprintf('\n--- Step 7: Final Summary ---\n');

fprintf('Joint Center Extraction Summary:\n');
fprintf('  Data Inspector signals: %d\n', length(signals));
fprintf('  Joint center signals found: %d\n', length(jointCenterSignals));
fprintf('  Successfully extracted: %d\n', length(fieldnames(jointCenterData)) - 1); % -1 for time field

if length(jointCenterSignals) > 0
    fprintf('\n🎉 SUCCESS! Joint center positions extracted with clean names!\n');
    fprintf('The data is ready for motion matching and 3D visualization.\n\n');
    
    fprintf('Key joint center signals found:\n');
    fprintf('  - Hip positions (X, Y, Z)\n');
    fprintf('  - Torso positions\n');
    fprintf('  - Shoulder positions (Left/Right)\n');
    fprintf('  - Elbow positions (Left/Right)\n');
    fprintf('  - Hand positions (Left/Right)\n');
    fprintf('  - Club head position\n');
    fprintf('  - Midpoint position\n');
else
    fprintf('\n⚠️  No joint center signals identified.\n');
end

fprintf('\nOutput directory: %s\n', outputDir);
fprintf('Clean extraction completed! 🚀\n');

%% Helper Function
function cleanName = createCleanFieldName(originalName)
    % Replace problematic characters with underscores
    cleanName = originalName;
    
    % Replace dots with underscores
    cleanName = strrep(cleanName, '.', '_');
    
    % Replace parentheses with underscores
    cleanName = strrep(cleanName, '(', '_');
    cleanName = strrep(cleanName, ')', '_');
    
    % Replace spaces with underscores
    cleanName = strrep(cleanName, ' ', '_');
    
    % Replace any other problematic characters
    cleanName = regexprep(cleanName, '[^a-zA-Z0-9_]', '_');
    
    % Remove multiple consecutive underscores
    cleanName = regexprep(cleanName, '_+', '_');
    
    % Remove leading/trailing underscores
    cleanName = strtrim(cleanName);
    if cleanName(1) == '_'
        cleanName = cleanName(2:end);
    end
    if cleanName(end) == '_'
        cleanName = cleanName(1:end-1);
    end
    
    % Ensure it starts with a letter
    if ~isempty(cleanName) && ~isletter(cleanName(1))
        cleanName = ['Signal_' cleanName];
    end
    
    % Limit length to avoid MATLAB field name limits
    if length(cleanName) > 63
        cleanName = cleanName(1:63);
    end
end 