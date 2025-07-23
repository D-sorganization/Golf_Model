% viewDataAsTable.m
% Display dataset as a readable table with proper labels

clear; clc; close all;

fprintf('=== Viewing Dataset as Table ===\n');

%% Load the most recent test dataset
dataset_files = dir('test_dataset_*.mat');
if isempty(dataset_files)
    error('No test dataset files found. Run testDatasetGeneration.m first.');
end

[~, idx] = max([dataset_files.datenum]);
latest_file = dataset_files(idx).name;
fprintf('Loading: %s\n', latest_file);

data = load(latest_file);

%% Create table for first simulation
if data.dataset.success_flags(1)
    sim1 = data.dataset.simulations{1};
    
    fprintf('\n=== Simulation 1 Data Table ===\n');
    fprintf('Time points: %d, Joints: %d\n\n', size(sim1.q, 1), size(sim1.q, 2));
    
    % Create column names
    n_joints = size(sim1.q, 2);
    column_names = {'Time_s'};
    
    % Add joint position columns
    for j = 1:n_joints
        column_names{end+1} = sprintf('Joint%d_Position_rad', j);
    end
    
    % Add joint velocity columns
    for j = 1:n_joints
        column_names{end+1} = sprintf('Joint%d_Velocity_rads', j);
    end
    
    % Add joint acceleration columns
    for j = 1:n_joints
        column_names{end+1} = sprintf('Joint%d_Accel_rads2', j);
    end
    
    % Add joint torque columns
    for j = 1:n_joints
        column_names{end+1} = sprintf('Joint%d_Torque_Nm', j);
    end
    
    % Create data matrix
    table_data = [sim1.time, sim1.q, sim1.qd, sim1.qdd, sim1.tau];
    
    % Create table
    data_table = array2table(table_data, 'VariableNames', column_names);
    
    % Display table
    fprintf('Data Table (first 5 rows shown):\n');
    disp(data_table(1:min(5, height(data_table)), :));
    
    if height(data_table) > 5
        fprintf('\n... (showing first 5 of %d rows)\n', height(data_table));
    end
    
    % Show table info
    fprintf('\nTable Information:\n');
    fprintf('  Rows: %d\n', height(data_table));
    fprintf('  Columns: %d\n', width(data_table));
    fprintf('  Column breakdown:\n');
    fprintf('    - Time: 1 column\n');
    fprintf('    - Joint Positions: %d columns\n', n_joints);
    fprintf('    - Joint Velocities: %d columns\n', n_joints);
    fprintf('    - Joint Accelerations: %d columns\n', n_joints);
    fprintf('    - Joint Torques: %d columns\n', n_joints);
    
    % Save table to CSV for easy viewing
    csv_filename = sprintf('simulation1_data_table_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
    writetable(data_table, csv_filename);
    fprintf('\n✓ Table saved to CSV: %s\n', csv_filename);
    
    % Show summary statistics
    fprintf('\n=== Summary Statistics ===\n');
    
    % Time range
    fprintf('Time range: %.3f to %.3f seconds\n', min(sim1.time), max(sim1.time));
    
    % Position statistics
    fprintf('\nJoint Position Statistics (rad):\n');
    fprintf('  Min: %.4f, Max: %.4f, Mean: %.4f, Std: %.4f\n', ...
           min(sim1.q(:)), max(sim1.q(:)), mean(sim1.q(:)), std(sim1.q(:)));
    
    % Velocity statistics
    fprintf('\nJoint Velocity Statistics (rad/s):\n');
    fprintf('  Min: %.4f, Max: %.4f, Mean: %.4f, Std: %.4f\n', ...
           min(sim1.qd(:)), max(sim1.qd(:)), mean(sim1.qd(:)), std(sim1.qd(:)));
    
    % Acceleration statistics
    fprintf('\nJoint Acceleration Statistics (rad/s²):\n');
    fprintf('  Min: %.4f, Max: %.4f, Mean: %.4f, Std: %.4f\n', ...
           min(sim1.qdd(:)), max(sim1.qdd(:)), mean(sim1.qdd(:)), std(sim1.qdd(:)));
    
    % Torque statistics
    fprintf('\nJoint Torque Statistics (Nm):\n');
    fprintf('  Min: %.4f, Max: %.4f, Mean: %.4f, Std: %.4f\n', ...
           min(sim1.tau(:)), max(sim1.tau(:)), mean(sim1.tau(:)), std(sim1.tau(:)));
    
else
    fprintf('✗ No successful simulations found\n');
end

%% Also show the training data format
fprintf('\n=== Training Data Format ===\n');
fprintf('X (Features) shape: %d x %d\n', size(data.X, 1), size(data.X, 2));
fprintf('Y (Targets) shape: %d x %d\n', size(data.Y, 1), size(data.Y, 2));

% Create training data table
n_joints = 28;
train_column_names = {};

% Add feature columns
for j = 1:n_joints
    train_column_names{end+1} = sprintf('Joint%d_Position', j);
end
for j = 1:n_joints
    train_column_names{end+1} = sprintf('Joint%d_Velocity', j);
end
for j = 1:n_joints
    train_column_names{end+1} = sprintf('Joint%d_Torque', j);
end

% Add target columns
for j = 1:n_joints
    train_column_names{end+1} = sprintf('Joint%d_Accel_Target', j);
end

% Create training table
train_data = [data.X, data.Y];
train_table = array2table(train_data, 'VariableNames', train_column_names);

fprintf('\nTraining Data Table (first 3 rows, first 10 columns):\n');
disp(train_table(1:min(3, height(train_table)), 1:10));

fprintf('\n=== Complete! ===\n');
fprintf('Check the CSV file for the full table view\n'); 