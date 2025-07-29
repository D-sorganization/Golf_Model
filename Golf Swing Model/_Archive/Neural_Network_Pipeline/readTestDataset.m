% readTestDataset.m
% Script to read and visualize the test dataset

clear; clc; close all;

fprintf('=== Reading Test Dataset ===\n');

%% Find the most recent test dataset
dataset_files = dir('test_dataset_*.mat');
if isempty(dataset_files)
    error('No test dataset files found. Run testDatasetGeneration.m first.');
end

% Get the most recent file
[~, idx] = max([dataset_files.datenum]);
latest_file = dataset_files(idx).name;

fprintf('Loading dataset: %s\n', latest_file);

%% Load the dataset
try
    data = load(latest_file);
    fprintf('✓ Dataset loaded successfully\n');
catch ME
    error('Failed to load dataset: %s', ME.message);
end

%% Display dataset information
fprintf('\n=== Dataset Information ===\n');
fprintf('Dataset fields: %s\n', strjoin(fieldnames(data), ', '));

if isfield(data, 'dataset')
    fprintf('\nDataset metadata:\n');
    fprintf('  Description: %s\n', data.dataset.metadata.description);
    fprintf('  Version: %s\n', data.dataset.metadata.version);
    fprintf('  Creation time: %s\n', datestr(data.dataset.metadata.creation_time));
    
    fprintf('\nConfiguration:\n');
    fprintf('  Simulations: %d\n', data.dataset.config.num_simulations);
    fprintf('  Duration: %.1f seconds\n', data.dataset.config.simulation_duration);
    fprintf('  Sample rate: %d Hz\n', data.dataset.config.sample_rate);
    
    fprintf('\nResults:\n');
    n_successful = sum(data.dataset.success_flags);
    fprintf('  Successful: %d/%d (%.1f%%)\n', ...
           n_successful, data.dataset.config.num_simulations, ...
           100*n_successful/data.dataset.config.num_simulations);
end

if isfield(data, 'X') && isfield(data, 'Y')
    fprintf('\nTraining data:\n');
    fprintf('  X shape: %d x %d (features)\n', size(data.X, 1), size(data.X, 2));
    fprintf('  Y shape: %d x %d (targets)\n', size(data.Y, 1), size(data.Y, 2));
    
    % Calculate feature breakdown
    n_joints = 28;
    n_features_per_joint = size(data.X, 2) / n_joints;
    fprintf('  Features per joint: %.1f\n', n_features_per_joint);
    fprintf('  Total joints: %d\n', n_joints);
end

%% Visualize the data
fprintf('\n=== Creating Visualizations ===\n');

if isfield(data, 'dataset') && isfield(data, 'X')
    % Plot joint positions for first simulation
    if data.dataset.success_flags(1)
        sim1 = data.dataset.simulations{1};
        
        figure('Name', 'Joint Positions - Simulation 1', 'Position', [100, 100, 1200, 800]);
        
        % Plot first 8 joints (to avoid overcrowding)
        n_plot_joints = min(8, size(sim1.q, 2));
        
        for j = 1:n_plot_joints
            subplot(2, 4, j);
            plot(sim1.time, sim1.q(:, j), 'b-', 'LineWidth', 2);
            title(sprintf('Joint %d Position', j));
            xlabel('Time (s)');
            ylabel('Position (rad)');
            grid on;
        end
        
        sgtitle('Joint Positions - First 8 Joints (Simulation 1)');
        
        % Plot joint velocities
        figure('Name', 'Joint Velocities - Simulation 1', 'Position', [100, 100, 1200, 800]);
        
        for j = 1:n_plot_joints
            subplot(2, 4, j);
            plot(sim1.time, sim1.qd(:, j), 'r-', 'LineWidth', 2);
            title(sprintf('Joint %d Velocity', j));
            xlabel('Time (s)');
            ylabel('Velocity (rad/s)');
            grid on;
        end
        
        sgtitle('Joint Velocities - First 8 Joints (Simulation 1)');
        
        % Plot joint torques
        figure('Name', 'Joint Torques - Simulation 1', 'Position', [100, 100, 1200, 800]);
        
        for j = 1:n_plot_joints
            subplot(2, 4, j);
            plot(sim1.time, sim1.tau(:, j), 'g-', 'LineWidth', 2);
            title(sprintf('Joint %d Torque', j));
            xlabel('Time (s)');
            ylabel('Torque (Nm)');
            grid on;
        end
        
        sgtitle('Joint Torques - First 8 Joints (Simulation 1)');
        
        fprintf('✓ Created 3 visualization figures\n');
    end
    
    % Plot feature correlation matrix
    if size(data.X, 1) > 1
        figure('Name', 'Feature Correlation Matrix', 'Position', [100, 100, 800, 600]);
        
        % Calculate correlation matrix for first 20 features (to avoid memory issues)
        n_features_to_plot = min(20, size(data.X, 2));
        corr_matrix = corr(data.X(:, 1:n_features_to_plot));
        
        imagesc(corr_matrix);
        colorbar;
        title('Feature Correlation Matrix (First 20 Features)');
        xlabel('Feature Index');
        ylabel('Feature Index');
        axis equal tight;
        
        fprintf('✓ Created feature correlation matrix\n');
    end
end

%% Test data access patterns
fprintf('\n=== Testing Data Access Patterns ===\n');

if isfield(data, 'X') && isfield(data, 'Y')
    % Test accessing specific time steps
    fprintf('Testing time step access...\n');
    
    % Get first time step
    first_step_X = data.X(1, :);
    first_step_Y = data.Y(1, :);
    
    fprintf('  First time step - X: %d features, Y: %d targets\n', ...
           length(first_step_X), length(first_step_Y));
    
    % Get last time step
    last_step_X = data.X(end, :);
    last_step_Y = data.Y(end, :);
    
    fprintf('  Last time step - X: %d features, Y: %d targets\n', ...
           length(last_step_X), length(last_step_Y));
    
    % Test accessing specific joints
    n_joints = 28;
    if size(data.X, 2) >= 3*n_joints  % Assuming [q, qd, tau] format
        fprintf('Testing joint-specific access...\n');
        
        % Extract first joint data from first time step
        joint1_q = first_step_X(1);
        joint1_qd = first_step_X(n_joints + 1);
        joint1_tau = first_step_X(2*n_joints + 1);
        
        fprintf('  Joint 1 - q: %.4f, qd: %.4f, tau: %.4f\n', ...
               joint1_q, joint1_qd, joint1_tau);
    end
end

fprintf('\n=== Dataset Reading Complete ===\n');
fprintf('Dataset successfully loaded and visualized!\n'); 