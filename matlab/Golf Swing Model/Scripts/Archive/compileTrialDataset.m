% compileTrialDataset.m
% Compile individual trial files into a comprehensive dataset
% Reads all .mat files from the trial_data folder and combines them

fprintf('=== Trial Dataset Compilation ===\n\n');

%% Get User Configuration
fprintf('=== Trial Dataset Compilation Configuration ===\n\n');

% Prompt for trial data folder using popup dialog
fprintf('Select trial data folder...\n');
config.trial_folder = uigetdir(pwd, 'Select trial data folder');

if config.trial_folder == 0
    % User cancelled the dialog
    fprintf('Folder selection cancelled by user.\n');
    return;
end

% Check if folder exists
if ~exist(config.trial_folder, 'dir')
    fprintf('✗ Selected folder not found: %s\n', config.trial_folder);
    fprintf('Compilation cancelled.\n');
    return;
end

fprintf('✓ Selected trial folder: %s\n', config.trial_folder);

% Prompt for output CSV filename
while true
    output_csv = input('Enter output CSV filename (default: complete_golf_dataset.csv): ', 's');
    if isempty(output_csv)
        config.output_csv = 'complete_golf_dataset.csv';
    else
        % Add .csv extension if not provided
        [~, ~, ext] = fileparts(output_csv);
        if isempty(ext)
            output_csv = [output_csv, '.csv'];
        end
        config.output_csv = output_csv;
    end

    % Check if file already exists
    if exist(config.output_csv, 'file')
        overwrite = input('File already exists. Overwrite? (y/n): ', 's');
        if strcmpi(overwrite, 'y') || strcmpi(overwrite, 'yes')
            break;
        else
            fprintf('Please choose a different filename.\n');
        end
    else
        break;
    end
end

% Prompt for output summary filename
while true
    output_summary = input('Enter output summary filename (default: dataset_summary.txt): ', 's');
    if isempty(output_summary)
        config.output_summary = 'dataset_summary.txt';
    else
        % Add .txt extension if not provided
        [~, ~, ext] = fileparts(output_summary);
        if isempty(ext)
            output_summary = [output_summary, '.txt'];
        end
        config.output_summary = output_summary;
    end

    % Check if file already exists
    if exist(config.output_summary, 'file')
        overwrite = input('File already exists. Overwrite? (y/n): ', 's');
        if strcmpi(overwrite, 'y') || strcmpi(overwrite, 'yes')
            break;
        else
            fprintf('Please choose a different filename.\n');
        end
    else
        break;
    end
end

fprintf('\n=== Configuration Summary ===\n');
fprintf('  Trial folder: %s\n', config.trial_folder);
fprintf('  Output CSV: %s\n', config.output_csv);
fprintf('  Output summary: %s\n', config.output_summary);
fprintf('\n');

% Confirm with user
confirm = input('Start compilation with these settings? (y/n): ', 's');
if ~(strcmpi(confirm, 'y') || strcmpi(confirm, 'yes'))
    fprintf('Compilation cancelled by user.\n');
    return;
end

fprintf('\n');

%% Check if trial folder exists
if ~exist(config.trial_folder, 'dir')
    fprintf('✗ Trial folder not found: %s\n', config.trial_folder);
    fprintf('  Please run runParallelSimulations.m first to generate trial files\n');
    return;
end

%% Find all trial files
trial_files = dir(fullfile(config.trial_folder, 'trial_*.mat'));
num_files = length(trial_files);

if num_files == 0
    fprintf('✗ No trial files found in %s\n', config.trial_folder);
    fprintf('  Please run runParallelSimulations.m first to generate trial files\n');
    return;
end

fprintf('Found %d trial files\n', num_files);

%% Load and combine all trial data
fprintf('\n--- Loading Trial Data ---\n');

all_data = [];
column_names = {};
successful_trials = 0;
failed_trials = 0;

for file_idx = 1:num_files
    filename = trial_files(file_idx).name;
    filepath = fullfile(config.trial_folder, filename);

    try
        fprintf('Loading %s (%d/%d)...\n', filename, file_idx, num_files);

        % Load trial data
        trial_data = load(filepath);

        if isfield(trial_data, 'trial_data') && ~isempty(trial_data.trial_data)
            % Get data matrix
            data_matrix = trial_data.trial_data;

            % Check if this is the first successful trial
            if isempty(all_data)
                all_data = data_matrix;
                % Create column names based on data size
                column_names = createColumnNames(size(data_matrix, 2));
            else
                % Check if column count matches
                if size(data_matrix, 2) == size(all_data, 2)
                    all_data = [all_data; data_matrix];
                else
                    fprintf('  ⚠️  Column count mismatch: expected %d, got %d\n', ...
                        size(all_data, 2), size(data_matrix, 2));
                    % Try to pad or truncate to match
                    if size(data_matrix, 2) < size(all_data, 2)
                        % Pad with zeros
                        padding = zeros(size(data_matrix, 1), size(all_data, 2) - size(data_matrix, 2));
                        data_matrix = [data_matrix, padding];
                    else
                        % Truncate
                        data_matrix = data_matrix(:, 1:size(all_data, 2));
                    end
                    all_data = [all_data; data_matrix];
                end
            end

            successful_trials = successful_trials + 1;
            fprintf('  ✓ Loaded %d data points\n', size(data_matrix, 1));

        else
            fprintf('  ✗ No valid data found\n');
            failed_trials = failed_trials + 1;
        end

    catch ME
        fprintf('  ✗ Error loading %s: %s\n', filename, ME.message);
        failed_trials = failed_trials + 1;
    end
end

%% Create comprehensive dataset
if ~isempty(all_data)
    fprintf('\n--- Creating Dataset ---\n');

    % Convert to table
    data_table = array2table(all_data);

    % Set column names
    if length(column_names) == size(all_data, 2)
        data_table.Properties.VariableNames = column_names;
    else
        fprintf('⚠️  Column name count mismatch, using generic names\n');
        % Create generic column names
        generic_names = cell(1, size(all_data, 2));
        for i = 1:size(all_data, 2)
            generic_names{i} = sprintf('Column_%d', i);
        end
        data_table.Properties.VariableNames = generic_names;
    end

    % Save to CSV
    writetable(data_table, config.output_csv);
    fprintf('✓ Dataset saved to: %s\n', config.output_csv);
    fprintf('  Total data points: %d\n', size(all_data, 1));
    fprintf('  Total columns: %d\n', size(all_data, 2));

    % Create summary file
    createDatasetSummary(config, all_data, column_names, successful_trials, failed_trials, trial_files);

else
    fprintf('✗ No data collected from any trial files\n');
end

fprintf('\n=== Dataset Compilation Complete ===\n');

%% Helper Functions

function column_names = createColumnNames(num_columns)
    % Create column names for the dataset

    column_names = {'time', 'simulation_id'};

    % Add logsout signal names
    logsout_names = {'CHS', 'CHPathUnitVector', 'Face', 'Path', 'CHGlobalPosition', 'CHy', 'MaximumCHS', 'HipGlobalPosition', 'HipGlobalVelocity', 'HUBGlobalPosition', 'GolferMass', 'GolferCOM', 'KillswitchState', 'ButtPosition', 'LeftHandSpeed', 'LHAVGlobal', 'LeftHandPostion', 'LHGlobalVelocity', 'LHGlobalAngularVelocity', 'LHGlobalPosition', 'MidHandSpeed', 'MPGlobalPosition', 'MPGlobalVelocity', 'RightHandSpeed', 'RHAVGlobal', 'RHGlobalVelocity', 'RHGlobalAngularVelocity', 'RHGlobalPosition'};

    % Add torque signal names
    torque_names = {'ForceAlongHandPath', 'LHForceAlongHandPath', 'RHForceAlongHandPath', 'SumofMomentsLHonClub', 'SumofMomentsRHonClub', 'TotalHandForceGlobal', 'TotalHandTorqueGlobal', 'LHonClubForceLocal', 'LHonClubTorqueLocal', 'RHonClubForceLocal', 'RHonClubTorqueLocal', 'HipTorqueXInput', 'HipTorqueYInput', 'HipTorqueZInput', 'TranslationForceXInput', 'TranslationForceYInput', 'TranslationForceZInput', 'LSTorqueXInput', 'SumofMomentsonClubLocal', 'BaseonHipForceHipBase'};

    % Add signal bus field names (positions, velocities, accelerations, torques)
    signal_bus_names = {};
    joints = {'Hip', 'Spine', 'Torso', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW', 'LScap', 'RScap', 'LF', 'RF'};

    for i = 1:length(joints)
        joint = joints{i};
        signal_bus_names = [signal_bus_names, {
            [joint '_PositionX'], [joint '_PositionY'], [joint '_PositionZ'], ...
            [joint '_VelocityX'], [joint '_VelocityY'], [joint '_VelocityZ'], ...
            [joint '_AccelerationX'], [joint '_AccelerationY'], [joint '_AccelerationZ'], ...
            [joint '_AngularPositionX'], [joint '_AngularPositionY'], [joint '_AngularPositionZ'], ...
            [joint '_AngularVelocityX'], [joint '_AngularVelocityY'], [joint '_AngularVelocityZ'], ...
            [joint '_AngularAccelerationX'], [joint '_AngularAccelerationY'], [joint '_AngularAccelerationZ'], ...
            [joint '_ConstraintForceLocal'], [joint '_ConstraintTorqueLocal'], ...
            [joint '_ActuatorTorqueX'], [joint '_ActuatorTorqueY'], [joint '_ActuatorTorqueZ'], ...
            [joint '_ForceLocal'], [joint '_TorqueLocal'], ...
            [joint '_GlobalPosition'], [joint '_GlobalVelocity'], [joint '_GlobalAcceleration'], ...
            [joint '_GlobalAngularVelocity'], [joint '_Rotation_Transform']
        }];
    end

    % Add rotation matrix components (9 components per joint)
    rotation_names = {};
    for i = 1:length(joints)
        joint = joints{i};
        for row = 1:3
            for col = 1:3
                rotation_names{end+1} = sprintf('%s_Rotation_%d%d', joint, row, col);
            end
        end
    end

    % Combine all column names
    column_names = [column_names, logsout_names, torque_names, signal_bus_names, rotation_names];

    % Ensure unique names
    column_names = unique(column_names, 'stable');

    % If we have more columns than names, add generic names
    if length(column_names) < num_columns
        for i = length(column_names) + 1:num_columns
            column_names{i} = sprintf('Column_%d', i);
        end
    elseif length(column_names) > num_columns
        % Truncate to match actual column count
        column_names = column_names(1:num_columns);
    end
end

function createDatasetSummary(config, all_data, column_names, successful_trials, failed_trials, trial_files)
    % Create a summary file with dataset information

    try
        fid = fopen(config.output_summary, 'w');
        if fid == -1
            fprintf('✗ Could not create summary file\n');
            return;
        end

        fprintf(fid, 'Complete Golf Dataset Summary\n');
        fprintf(fid, '============================\n\n');
        fprintf(fid, 'Generated: %s\n', datestr(now));
        fprintf(fid, 'Compiled from: %s\n', config.trial_folder);
        fprintf(fid, '\n');

        fprintf(fid, 'Trial Statistics:\n');
        fprintf(fid, '  Total trial files found: %d\n', length(trial_files));
        fprintf(fid, '  Successful trials: %d\n', successful_trials);
        fprintf(fid, '  Failed trials: %d\n', failed_trials);
        fprintf(fid, '  Success rate: %.1f%%\n', (successful_trials / length(trial_files)) * 100);
        fprintf(fid, '\n');

        fprintf(fid, 'Dataset Statistics:\n');
        fprintf(fid, '  Total data points: %d\n', size(all_data, 1));
        fprintf(fid, '  Total columns: %d\n', size(all_data, 2));
        if successful_trials > 0
            fprintf(fid, '  Data points per trial: %d\n', size(all_data, 1) / successful_trials);
        end
        fprintf(fid, '\n');

        fprintf(fid, 'Column Categories:\n');
        fprintf(fid, '  Time and ID: 2 columns\n');
        fprintf(fid, '  Data columns: %d columns\n', size(all_data, 2) - 2);
        fprintf(fid, '\n');

        fprintf(fid, 'Data Types Included:\n');
        fprintf(fid, '  ✓ Joint positions (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint velocities (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint accelerations (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint angular positions (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint angular velocities (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint angular accelerations (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint activation torques\n');
        fprintf(fid, '  ✓ Constraint forces and torques\n');
        fprintf(fid, '  ✓ Global positions, velocities, accelerations\n');
        fprintf(fid, '  ✓ Rotation matrices (9 components per joint)\n');
        fprintf(fid, '  ✓ Club and hand data\n');
        fprintf(fid, '  ✓ Model workspace variables\n');
        fprintf(fid, '\n');

        fprintf(fid, 'Joints Included:\n');
        joints = {'Hip', 'Spine', 'Torso', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW', 'LScap', 'RScap', 'LF', 'RF'};
        for i = 1:length(joints)
            fprintf(fid, '  - %s\n', joints{i});
        end
        fprintf(fid, '\n');

        fprintf(fid, 'Trial Files Used:\n');
        for i = 1:length(trial_files)
            fprintf(fid, '  %s\n', trial_files(i).name);
        end
        fprintf(fid, '\n');

        fprintf(fid, 'Output Files:\n');
        fprintf(fid, '  CSV Dataset: %s\n', config.output_csv);
        fprintf(fid, '  Summary: %s\n', config.output_summary);

        fclose(fid);
        fprintf('✓ Summary saved to: %s\n', config.output_summary);

    catch ME
        fprintf('✗ Error creating summary: %s\n', ME.message);
    end
end
