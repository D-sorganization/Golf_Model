% testDatasetGeneration.m
% Simplified test script to generate a minimal dataset
% 2 simulations, 0.1 seconds each, basic data extraction

clear; clc; close all;

fprintf('=== Simplified Dataset Generation Test ===\n');
fprintf('2 simulations, 0.1 seconds each\n\n');

%% Configuration
config = struct();
config.num_simulations = 2;
config.simulation_duration = 0.1; % 0.1 seconds
config.sample_rate = 100; % Reduced sample rate for speed
config.model_name = 'GolfSwing3D_Kinetic';

fprintf('Configuration:\n');
fprintf('  Simulations: %d\n', config.num_simulations);
fprintf('  Duration: %.1f seconds each\n', config.simulation_duration);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Model: %s\n', config.model_name);

%% Initialize dataset structure
dataset = struct();
dataset.config = config;
dataset.metadata = struct();
dataset.metadata.creation_time = datetime('now');
dataset.metadata.description = 'Test dataset - 2 simulations, 0.1s each';
dataset.metadata.version = 'test_1.0';

dataset.simulations = cell(config.num_simulations, 1);
dataset.success_flags = false(config.num_simulations, 1);
dataset.error_messages = cell(config.num_simulations, 1);

%% Load model
fprintf('\nLoading Simulink model...\n');
try
    load_system(config.model_name);
    fprintf('✓ Model loaded successfully\n');
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

%% Generate simple test data
fprintf('\n=== Starting Test Simulations ===\n');

for sim_idx = 1:config.num_simulations
    fprintf('Simulation %d/%d...\n', sim_idx, config.num_simulations);
    
    try
        % Create simple time vector
        t = 0:1/config.sample_rate:config.simulation_duration;
        n_samples = length(t);
        
        % Generate simple test data (sine waves for demonstration)
        n_joints = 28; % Assuming 28 joints
        
        % Simple joint positions (sine waves with different frequencies)
        q = zeros(n_samples, n_joints);
        for j = 1:n_joints
            freq = 1 + j * 0.1; % Different frequency for each joint
            q(:, j) = 0.1 * sin(2 * pi * freq * t') + 0.05 * randn(n_samples, 1);
        end
        
        % Simple joint velocities (derivative of positions)
        qd = zeros(n_samples, n_joints);
        for j = 1:n_joints
            freq = 1 + j * 0.1;
            qd(:, j) = 0.1 * 2 * pi * freq * cos(2 * pi * freq * t') + 0.01 * randn(n_samples, 1);
        end
        
        % Simple joint accelerations
        qdd = zeros(n_samples, n_joints);
        for j = 1:n_joints
            freq = 1 + j * 0.1;
            qdd(:, j) = -0.1 * (2 * pi * freq)^2 * sin(2 * pi * freq * t') + 0.005 * randn(n_samples, 1);
        end
        
        % Simple joint torques
        tau = zeros(n_samples, n_joints);
        for j = 1:n_joints
            tau(:, j) = 10 * sin(2 * pi * (2 + j * 0.2) * t') + 2 * randn(n_samples, 1);
        end
        
        % Store simulation data
        sim_data = struct();
        sim_data.time = t';
        sim_data.q = q;
        sim_data.qd = qd;
        sim_data.qdd = qdd;
        sim_data.tau = tau;
        sim_data.metadata = struct();
        sim_data.metadata.simulation_id = sim_idx;
        sim_data.metadata.timestamp = datetime('now');
        sim_data.metadata.duration = config.simulation_duration;
        sim_data.metadata.sample_rate = config.sample_rate;
        sim_data.metadata.n_samples = n_samples;
        sim_data.metadata.n_joints = n_joints;
        
        dataset.simulations{sim_idx} = sim_data;
        dataset.success_flags(sim_idx) = true;
        
        fprintf('  ✓ Success: %d samples, %d joints\n', n_samples, n_joints);
        
    catch ME
        fprintf('  ✗ Failed: %s\n', ME.message);
        dataset.success_flags(sim_idx) = false;
        dataset.error_messages{sim_idx} = ME.message;
    end
end

%% Compile results
successful_sims = find(dataset.success_flags);
n_successful = length(successful_sims);

fprintf('\n=== Results ===\n');
fprintf('Successful simulations: %d/%d (%.1f%%)\n', ...
       n_successful, config.num_simulations, 100*n_successful/config.num_simulations);

if n_successful > 0
    % Create training data arrays
    X = [];  % Input features: [q, qd, tau]
    Y = [];  % Output targets: qdd
    
    for i = 1:n_successful
        sim_idx = successful_sims(i);
        sim_data = dataset.simulations{sim_idx};
        
        % Extract features and targets
        q = sim_data.q;      % Joint positions
        qd = sim_data.qd;    % Joint velocities
        qdd = sim_data.qdd;  % Joint accelerations (target)
        tau = sim_data.tau;  % Joint torques
        
        % Create feature matrix: [q, qd, tau]
        X_i = [q, qd, tau];
        Y_i = qdd;
        
        % Append to training data
        X = [X; X_i];
        Y = [Y; Y_i];
    end
    
    fprintf('Training data created:\n');
    fprintf('  X shape: %d x %d (features)\n', size(X, 1), size(X, 2));
    fprintf('  Y shape: %d x %d (targets)\n', size(Y, 1), size(Y, 2));
    
    % Save dataset
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('test_dataset_%s.mat', timestamp);
    
    save(filename, 'dataset', 'X', 'Y', 'config');
    fprintf('\n✓ Dataset saved: %s\n', filename);
    
    % Save training data separately
    training_filename = sprintf('test_training_data_%s.mat', timestamp);
    save(training_filename, 'X', 'Y');
    fprintf('✓ Training data saved: %s\n', training_filename);
    
else
    fprintf('\n✗ No successful simulations to save\n');
end

%% Test data reading
fprintf('\n=== Testing Data Reading ===\n');

if n_successful > 0
    try
        % Test loading the saved dataset
        fprintf('Testing dataset loading...\n');
        loaded_data = load(filename);
        
        fprintf('✓ Dataset loaded successfully\n');
        fprintf('  Dataset fields: %s\n', strjoin(fieldnames(loaded_data), ', '));
        
        if isfield(loaded_data, 'X') && isfield(loaded_data, 'Y')
            fprintf('  X shape: %d x %d\n', size(loaded_data.X, 1), size(loaded_data.X, 2));
            fprintf('  Y shape: %d x %d\n', size(loaded_data.Y, 1), size(loaded_data.Y, 2));
        end
        
        % Test loading training data
        fprintf('Testing training data loading...\n');
        training_data = load(training_filename);
        
        fprintf('✓ Training data loaded successfully\n');
        fprintf('  Training data fields: %s\n', strjoin(fieldnames(training_data), ', '));
        
    catch ME
        fprintf('✗ Error testing data loading: %s\n', ME.message);
    end
end

fprintf('\n=== Test Complete ===\n'); 