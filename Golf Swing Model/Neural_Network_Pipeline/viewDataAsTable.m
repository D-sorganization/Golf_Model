% viewDataAsTable.m
% Display dataset as a readable table with proper anatomical labels

clear; clc; close all;

fprintf('=== Viewing Dataset as Table with Anatomical Labels ===\n');

%% Load the most recent test dataset
dataset_files = dir('test_dataset_*.mat');
if isempty(dataset_files)
    error('No test dataset files found. Run testDatasetGeneration.m first.');
end

[~, idx] = max([dataset_files.datenum]);
latest_file = dataset_files(idx).name;
fprintf('Loading: %s\n', latest_file);

data = load(latest_file);

%% Define anatomical joint mapping (28 DOFs to actual joints)
% Based on the joint structure you described
joint_labels = cell(28, 1);
is_translation = false(28, 1); % Track which DOFs are translations vs rotations

% Hips/Base - 6 DOF Joint (6 DOFs)
joint_labels{1} = 'Hips_X_Translation';
joint_labels{2} = 'Hips_Y_Translation';
joint_labels{3} = 'Hips_Z_Translation';
joint_labels{4} = 'Hips_X_Rotation';
joint_labels{5} = 'Hips_Y_Rotation';
joint_labels{6} = 'Hips_Z_Rotation';
is_translation(1:3) = true; % First 3 are translations
is_translation(4:6) = false; % Last 3 are rotations

% Spine - Universal Joint (2 DOFs)
joint_labels{7} = 'Spine_Flexion';
joint_labels{8} = 'Spine_LateralBend';

% Torso - Revolute Joint (1 DOF)
joint_labels{9} = 'Torso_Rotation';

% LScap - Universal Joint (2 DOFs)
joint_labels{10} = 'LScap_Elevation';
joint_labels{11} = 'LScap_Protraction';

% RScap - Universal Joint (2 DOFs)
joint_labels{12} = 'RScap_Elevation';
joint_labels{13} = 'RScap_Protraction';

% LS - Gimbal Joint (3 DOFs)
joint_labels{14} = 'LShoulder_Flexion';
joint_labels{15} = 'LShoulder_Abduction';
joint_labels{16} = 'LShoulder_Rotation';

% RS - Gimbal Joint (3 DOFs)
joint_labels{17} = 'RShoulder_Flexion';
joint_labels{18} = 'RShoulder_Abduction';
joint_labels{19} = 'RShoulder_Rotation';

% LE - Revolute Joint (1 DOF)
joint_labels{20} = 'LElbow_Flexion';

% RE - Revolute Joint (1 DOF)
joint_labels{21} = 'RElbow_Flexion';

% LF - Revolute Joint (1 DOF)
joint_labels{22} = 'LWrist_Flexion';

% RF - Revolute Joint (1 DOF)
joint_labels{23} = 'RWrist_Flexion';

% LW - Universal Joint (2 DOFs)
joint_labels{24} = 'LWrist_RadialDeviation';
joint_labels{25} = 'LWrist_Supination';

% RW - Universal Joint (2 DOFs)
joint_labels{26} = 'RWrist_RadialDeviation';
joint_labels{27} = 'RWrist_Supination';

% Note: We have 28 DOFs but only 27 labels, so adding one more
joint_labels{28} = 'Club_Connection';
is_translation(28) = false; % Club connection is rotational

% Verify we have 28 labels
if length(joint_labels) ~= 28
    error('Joint label count mismatch: expected 28, got %d', length(joint_labels));
end

%% Create table for first simulation
if data.dataset.success_flags(1)
    sim1 = data.dataset.simulations{1};
    
    fprintf('\n=== Simulation 1 Data Table (Anatomical Labels) ===\n');
    fprintf('Time points: %d, Joints: %d\n\n', size(sim1.q, 1), size(sim1.q, 2));
    
    % Create column names with anatomical labels and proper units
    column_names = {'Time_s'};
    
    % Add joint position columns with anatomical labels and proper units
    for j = 1:length(joint_labels)
        if is_translation(j)
            column_names{end+1} = sprintf('%s_Position_m', joint_labels{j});
        else
            column_names{end+1} = sprintf('%s_Position_deg', joint_labels{j});
        end
    end
    
    % Add joint velocity columns with anatomical labels and proper units
    for j = 1:length(joint_labels)
        if is_translation(j)
            column_names{end+1} = sprintf('%s_Velocity_ms', joint_labels{j});
        else
            column_names{end+1} = sprintf('%s_Velocity_degs', joint_labels{j});
        end
    end
    
    % Add joint acceleration columns with anatomical labels and proper units
    for j = 1:length(joint_labels)
        if is_translation(j)
            column_names{end+1} = sprintf('%s_Accel_ms2', joint_labels{j});
        else
            column_names{end+1} = sprintf('%s_Accel_degs2', joint_labels{j});
        end
    end
    
    % Add joint torque columns with anatomical labels
    for j = 1:length(joint_labels)
        column_names{end+1} = sprintf('%s_Torque_Nm', joint_labels{j});
    end
    
    % Add mid-hands position and orientation columns if available
    if isfield(sim1, 'MH') && isfield(sim1, 'MH_R')
        % Mid-hands position columns
        column_names{end+1} = 'MidHands_Position_X_m';
        column_names{end+1} = 'MidHands_Position_Y_m';
        column_names{end+1} = 'MidHands_Position_Z_m';
        
        % Mid-hands rotation matrix columns (9 elements)
        column_names{end+1} = 'MidHands_Rotation_R11';
        column_names{end+1} = 'MidHands_Rotation_R12';
        column_names{end+1} = 'MidHands_Rotation_R13';
        column_names{end+1} = 'MidHands_Rotation_R21';
        column_names{end+1} = 'MidHands_Rotation_R22';
        column_names{end+1} = 'MidHands_Rotation_R23';
        column_names{end+1} = 'MidHands_Rotation_R31';
        column_names{end+1} = 'MidHands_Rotation_R32';
        column_names{end+1} = 'MidHands_Rotation_R33';
    end
    
    % Convert data to proper units
    % Convert angular measurements from radians to degrees
    q_converted = sim1.q;
    qd_converted = sim1.qd;
    qdd_converted = sim1.qdd;
    
    % Convert rotations to degrees (translations stay in meters)
    for j = 1:length(joint_labels)
        if ~is_translation(j)
            q_converted(:, j) = sim1.q(:, j) * 180/pi; % rad to deg
            qd_converted(:, j) = sim1.qd(:, j) * 180/pi; % rad/s to deg/s
            qdd_converted(:, j) = sim1.qdd(:, j) * 180/pi; % rad/s² to deg/s²
        end
    end
    
    % Create data matrix with converted units
    table_data = [sim1.time, q_converted, qd_converted, qdd_converted, sim1.tau];
    
    % Add mid-hands data if available
    if isfield(sim1, 'MH') && isfield(sim1, 'MH_R')
        % Reshape rotation matrices to columns
        MH_R_reshaped = reshape(sim1.MH_R, size(sim1.MH_R, 1) * size(sim1.MH_R, 2), size(sim1.MH_R, 3))';
        table_data = [table_data, sim1.MH, MH_R_reshaped];
    end
    
    % Create table
    data_table = array2table(table_data, 'VariableNames', column_names);
    
    % Display table (first 5 rows, first 15 columns for readability)
    fprintf('Data Table (first 5 rows, first 15 columns shown):\n');
    disp(data_table(1:min(5, height(data_table)), 1:15));
    
    if height(data_table) > 5
        fprintf('\n... (showing first 5 of %d rows)\n', height(data_table));
    end
    
    % Show table info
    fprintf('\nTable Information:\n');
    fprintf('  Rows: %d\n', height(data_table));
    fprintf('  Columns: %d\n', width(data_table));
    fprintf('  Column breakdown:\n');
    fprintf('    - Time: 1 column\n');
    fprintf('    - Joint Positions: %d columns\n', length(joint_labels));
    fprintf('    - Joint Velocities: %d columns\n', length(joint_labels));
    fprintf('    - Joint Accelerations: %d columns\n', length(joint_labels));
    fprintf('    - Joint Torques: %d columns\n', length(joint_labels));
    
    % Save table to CSV for easy viewing
    csv_filename = sprintf('simulation1_anatomical_table_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
    writetable(data_table, csv_filename);
    fprintf('\n✓ Table saved to CSV: %s\n', csv_filename);
    
    % Show joint breakdown
    fprintf('\n=== Anatomical Joint Breakdown ===\n');
    fprintf('Hips/Base (6 DOF): %s, %s, %s, %s, %s, %s\n', ...
           joint_labels{1:6});
    fprintf('Spine (Universal): %s, %s\n', joint_labels{7:8});
    fprintf('Torso (Revolute): %s\n', joint_labels{9});
    fprintf('LScap (Universal): %s, %s\n', joint_labels{10:11});
    fprintf('RScap (Universal): %s, %s\n', joint_labels{12:13});
    fprintf('LShoulder (Gimbal): %s, %s, %s\n', joint_labels{14:16});
    fprintf('RShoulder (Gimbal): %s, %s, %s\n', joint_labels{17:19});
    fprintf('LElbow (Revolute): %s\n', joint_labels{20});
    fprintf('RElbow (Revolute): %s\n', joint_labels{21});
    fprintf('LWrist (Revolute): %s\n', joint_labels{22});
    fprintf('RWrist (Revolute): %s\n', joint_labels{23});
    fprintf('LWrist (Universal): %s, %s\n', joint_labels{24:25});
    fprintf('RWrist (Universal): %s, %s\n', joint_labels{26:27});
    
    % Show mid-hands position and orientation data
    fprintf('\n=== Mid-Hands Position and Orientation Data ===\n');
    if isfield(sim1, 'MH') && isfield(sim1, 'MH_R')
        fprintf('✓ Mid-hands position data available\n');
        fprintf('✓ Mid-hands rotation data available\n');
        
        % Mid-hands position statistics
        fprintf('\nMid-Hands Position Statistics:\n');
        fprintf('  X range: %.4f to %.4f m\n', min(sim1.MH(:, 1)), max(sim1.MH(:, 1)));
        fprintf('  Y range: %.4f to %.4f m\n', min(sim1.MH(:, 2)), max(sim1.MH(:, 2)));
        fprintf('  Z range: %.4f to %.4f m\n', min(sim1.MH(:, 3)), max(sim1.MH(:, 3)));
        
        % Calculate mid-hands velocity
        dt = diff(sim1.time);
        MH_vel = diff(sim1.MH) ./ dt;
        fprintf('\nMid-Hands Velocity Statistics:\n');
        fprintf('  VX range: %.4f to %.4f m/s\n', min(MH_vel(:, 1)), max(MH_vel(:, 1)));
        fprintf('  VY range: %.4f to %.4f m/s\n', min(MH_vel(:, 2)), max(MH_vel(:, 2)));
        fprintf('  VZ range: %.4f to %.4f m/s\n', min(MH_vel(:, 3)), max(MH_vel(:, 3)));
        
        % Rotation matrix statistics (check orthogonality and determinant)
        fprintf('\nMid-Hands Rotation Matrix Statistics:\n');
        det_vals = zeros(size(sim1.MH_R, 3), 1);
        for k = 1:size(sim1.MH_R, 3)
            det_vals(k) = det(sim1.MH_R(:, :, k));
        end
        fprintf('  Determinant range: %.6f to %.6f (should be ~1.0)\n', min(det_vals), max(det_vals));
        
        % Extract Euler angles from rotation matrices
        euler_angles = zeros(size(sim1.MH_R, 3), 3);
        for k = 1:size(sim1.MH_R, 3)
            R = sim1.MH_R(:, :, k);
            % Extract roll, pitch, yaw (ZYX convention)
            euler_angles(k, 1) = atan2(R(3, 2), R(3, 3)); % Roll (X)
            euler_angles(k, 2) = asin(-R(3, 1)); % Pitch (Y)
            euler_angles(k, 3) = atan2(R(2, 1), R(1, 1)); % Yaw (Z)
        end
        euler_angles_deg = euler_angles * 180/pi;
        fprintf('  Roll (X) range: %.2f to %.2f deg\n', min(euler_angles_deg(:, 1)), max(euler_angles_deg(:, 1)));
        fprintf('  Pitch (Y) range: %.2f to %.2f deg\n', min(euler_angles_deg(:, 2)), max(euler_angles_deg(:, 2)));
        fprintf('  Yaw (Z) range: %.2f to %.2f deg\n', min(euler_angles_deg(:, 3)), max(euler_angles_deg(:, 3)));
        
    else
        fprintf('✗ Mid-hands position and orientation data not available\n');
        fprintf('  This data is crucial for matching motion capture and determining club position\n');
    end
    
    % Show summary statistics by joint type with proper units
    fprintf('\n=== Summary Statistics by Joint Type (Converted Units) ===\n');
    
    % Time range
    fprintf('Time range: %.3f to %.3f seconds\n', min(sim1.time), max(sim1.time));
    
    % Hips statistics (first 6 DOFs - 3 translations, 3 rotations)
    fprintf('\nHips/Base Statistics:\n');
    fprintf('  Translation Position range: %.4f to %.4f m\n', min(q_converted(:, 1:3), [], 'all'), max(q_converted(:, 1:3), [], 'all'));
    fprintf('  Rotation Position range: %.4f to %.4f deg\n', min(q_converted(:, 4:6), [], 'all'), max(q_converted(:, 4:6), [], 'all'));
    fprintf('  Translation Velocity range: %.4f to %.4f m/s\n', min(qd_converted(:, 1:3), [], 'all'), max(qd_converted(:, 1:3), [], 'all'));
    fprintf('  Rotation Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 4:6), [], 'all'), max(qd_converted(:, 4:6), [], 'all'));
    fprintf('  Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 1:6), [], 'all'), max(sim1.tau(:, 1:6), [], 'all'));
    
    % Shoulder statistics (Gimbal joints)
    fprintf('\nShoulder Statistics:\n');
    fprintf('  LShoulder Position range: %.4f to %.4f deg\n', min(q_converted(:, 14:16), [], 'all'), max(q_converted(:, 14:16), [], 'all'));
    fprintf('  RShoulder Position range: %.4f to %.4f deg\n', min(q_converted(:, 17:19), [], 'all'), max(q_converted(:, 17:19), [], 'all'));
    fprintf('  LShoulder Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 14:16), [], 'all'), max(qd_converted(:, 14:16), [], 'all'));
    fprintf('  RShoulder Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 17:19), [], 'all'), max(qd_converted(:, 17:19), [], 'all'));
    fprintf('  LShoulder Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 14:16), [], 'all'), max(sim1.tau(:, 14:16), [], 'all'));
    fprintf('  RShoulder Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 17:19), [], 'all'), max(sim1.tau(:, 17:19), [], 'all'));
    
    % Elbow statistics
    fprintf('\nElbow Statistics:\n');
    fprintf('  LElbow Position range: %.4f to %.4f deg\n', min(q_converted(:, 20)), max(q_converted(:, 20)));
    fprintf('  RElbow Position range: %.4f to %.4f deg\n', min(q_converted(:, 21)), max(q_converted(:, 21)));
    fprintf('  LElbow Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 20)), max(qd_converted(:, 20)));
    fprintf('  RElbow Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 21)), max(qd_converted(:, 21)));
    fprintf('  LElbow Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 20)), max(sim1.tau(:, 20)));
    fprintf('  RElbow Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 21)), max(sim1.tau(:, 21)));
    
    % Wrist statistics
    fprintf('\nWrist Statistics:\n');
    fprintf('  LWrist Position range: %.4f to %.4f deg\n', min(q_converted(:, 22:25), [], 'all'), max(q_converted(:, 22:25), [], 'all'));
    fprintf('  RWrist Position range: %.4f to %.4f deg\n', min(q_converted(:, 23:27), [], 'all'), max(q_converted(:, 23:27), [], 'all'));
    fprintf('  LWrist Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 22:25), [], 'all'), max(qd_converted(:, 22:25), [], 'all'));
    fprintf('  RWrist Velocity range: %.4f to %.4f deg/s\n', min(qd_converted(:, 23:27), [], 'all'), max(qd_converted(:, 23:27), [], 'all'));
    fprintf('  LWrist Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 22:25), [], 'all'), max(sim1.tau(:, 22:25), [], 'all'));
    fprintf('  RWrist Torque range: %.4f to %.4f Nm\n', min(sim1.tau(:, 23:27), [], 'all'), max(sim1.tau(:, 23:27), [], 'all'));
    
else
    fprintf('✗ No successful simulations found\n');
end

%% Also show the training data format with anatomical labels
fprintf('\n=== Training Data Format (Anatomical Labels) ===\n');
fprintf('X (Features) shape: %d x %d\n', size(data.X, 1), size(data.X, 2));
fprintf('Y (Targets) shape: %d x %d\n', size(data.Y, 1), size(data.Y, 2));

% Create training data table with anatomical labels
train_column_names = {};

% Add feature columns with anatomical labels
for j = 1:length(joint_labels)
    train_column_names{end+1} = sprintf('%s_Position', joint_labels{j});
end
for j = 1:length(joint_labels)
    train_column_names{end+1} = sprintf('%s_Velocity', joint_labels{j});
end
for j = 1:length(joint_labels)
    train_column_names{end+1} = sprintf('%s_Torque', joint_labels{j});
end

% Add target columns with anatomical labels
for j = 1:length(joint_labels)
    train_column_names{end+1} = sprintf('%s_Accel_Target', joint_labels{j});
end

% Create training table
train_data = [data.X, data.Y];
train_table = array2table(train_data, 'VariableNames', train_column_names);

fprintf('\nTraining Data Table (first 3 rows, first 10 columns):\n');
disp(train_table(1:min(3, height(train_table)), 1:10));

fprintf('\n=== Complete! ===\n');
fprintf('Check the CSV file for the full anatomical table view\n'); 