% analyzeJointRanges.m
% Analyze the actual ranges of joint values across the 100-simulation dataset
% to verify if the conversion from radians to degrees was properly applied

clear; clc;

fprintf('=== Analyzing Joint Ranges in 100-Simulation Dataset ===\n\n');

% Load the dataset
files = dir('100_Simulation_Test_Dataset/100_sim_dataset_*.mat');
if isempty(files)
    fprintf('No dataset files found\n');
    return;
end

[~, idx] = sort([files.datenum], 'descend');
latest_file = files(idx(1)).name;
fprintf('Loading dataset: %s\n', latest_file);
load(['100_Simulation_Test_Dataset/' latest_file]);

% Initialize arrays to store min/max values across all simulations
n_joints = 28;
n_simulations = length(dataset.simulations);

% Arrays to store global min/max for each joint
global_min_pos = inf(1, n_joints);
global_max_pos = -inf(1, n_joints);
global_min_vel = inf(1, n_joints);
global_max_vel = -inf(1, n_joints);
global_min_acc = inf(1, n_joints);
global_max_acc = -inf(1, n_joints);
global_min_torque = inf(1, n_joints);
global_max_torque = -inf(1, n_joints);

% Arrays to store min/max for each simulation
sim_min_pos = zeros(n_simulations, n_joints);
sim_max_pos = zeros(n_simulations, n_joints);
sim_min_vel = zeros(n_simulations, n_joints);
sim_max_vel = zeros(n_simulations, n_joints);
sim_min_acc = zeros(n_simulations, n_joints);
sim_max_acc = zeros(n_simulations, n_joints);
sim_min_torque = zeros(n_simulations, n_joints);
sim_max_torque = zeros(n_simulations, n_joints);

fprintf('Analyzing %d simulations with %d joints each...\n', n_simulations, n_joints);

% Analyze each simulation
for sim_idx = 1:n_simulations
    if dataset.success_flags(sim_idx)
        sim_data = dataset.simulations{sim_idx};
        
        % Get min/max for this simulation
        sim_min_pos(sim_idx, :) = min(sim_data.q, [], 1);
        sim_max_pos(sim_idx, :) = max(sim_data.q, [], 1);
        sim_min_vel(sim_idx, :) = min(sim_data.qd, [], 1);
        sim_max_vel(sim_idx, :) = max(sim_data.qd, [], 1);
        sim_min_acc(sim_idx, :) = min(sim_data.qdd, [], 1);
        sim_max_acc(sim_idx, :) = max(sim_data.qdd, [], 1);
        sim_min_torque(sim_idx, :) = min(sim_data.tau, [], 1);
        sim_max_torque(sim_idx, :) = max(sim_data.tau, [], 1);
        
        % Update global min/max
        global_min_pos = min(global_min_pos, sim_min_pos(sim_idx, :));
        global_max_pos = max(global_max_pos, sim_max_pos(sim_idx, :));
        global_min_vel = min(global_min_vel, sim_min_vel(sim_idx, :));
        global_max_vel = max(global_max_vel, sim_max_vel(sim_idx, :));
        global_min_acc = min(global_min_acc, sim_min_acc(sim_idx, :));
        global_max_acc = max(global_max_acc, sim_max_acc(sim_idx, :));
        global_min_torque = min(global_min_torque, sim_min_torque(sim_idx, :));
        global_max_torque = max(global_max_torque, sim_max_torque(sim_idx, :));
    end
end

% Get joint names
if ~isempty(dataset.simulations) && dataset.success_flags(1)
    joint_names = dataset.simulations{1}.signal_names.simplified_names;
else
    joint_names = cell(1, n_joints);
    for i = 1:n_joints
        joint_names{i} = sprintf('Joint_%d', i);
    end
end

fprintf('\n=== JOINT RANGES ANALYSIS ===\n\n');

% Display results in a table format
fprintf('Joint Ranges Across All 100 Simulations:\n');
fprintf('%-20s %-15s %-15s %-15s %-15s\n', 'Joint Name', 'Pos Min (deg)', 'Pos Max (deg)', 'Pos Range (deg)', 'Expected Range');
fprintf('%-20s %-15s %-15s %-15s %-15s\n', '----------', '------------', '------------', '------------', '-------------');

for j = 1:n_joints
    pos_range = global_max_pos(j) - global_min_pos(j);
    
    % Determine expected range based on joint type
    if j <= 3
        expected_range = '±30°, ±17°, ±57°';  % Hip joints
    elseif j == 4
        expected_range = '±86°';              % Torso
    elseif j <= 6
        expected_range = '±17°, ±11°';        % Spine
    elseif j <= 8
        expected_range = '±23°, ±17°';        % Left scapula
    elseif j <= 11
        expected_range = '±46°, ±69°, ±29°';  % Left shoulder
    elseif j == 12
        expected_range = '0-86°';             % Left elbow
    elseif j == 13
        expected_range = '±46°';              % Left forearm
    elseif j <= 15
        expected_range = '±29°, ±23°';        % Left wrist
    elseif j <= 17
        expected_range = '±29°, ±23°';        % Right wrist
    elseif j == 18
        expected_range = '±46°';              % Right forearm
    elseif j == 19
        expected_range = '0-86°';             % Right elbow
    elseif j <= 21
        expected_range = '±23°, ±17°';        % Right scapula
    elseif j <= 24
        expected_range = '±46°, ±69°, ±29°';  % Right shoulder
    else
        expected_range = '±29°';              % Additional joints
    end
    
    fprintf('%-20s %-15.2f %-15.2f %-15.2f %-15s\n', ...
        joint_names{j}, global_min_pos(j), global_max_pos(j), pos_range, expected_range);
end

fprintf('\n=== VELOCITY RANGES ===\n');
fprintf('%-20s %-15s %-15s %-15s\n', 'Joint Name', 'Vel Min (deg/s)', 'Vel Max (deg/s)', 'Vel Range (deg/s)');
fprintf('%-20s %-15s %-15s %-15s\n', '----------', '--------------', '--------------', '--------------');

for j = 1:n_joints
    vel_range = global_max_vel(j) - global_min_vel(j);
    fprintf('%-20s %-15.2f %-15.2f %-15.2f\n', ...
        joint_names{j}, global_min_vel(j), global_max_vel(j), vel_range);
end

fprintf('\n=== ACCELERATION RANGES ===\n');
fprintf('%-20s %-15s %-15s %-15s\n', 'Joint Name', 'Acc Min (deg/s²)', 'Acc Max (deg/s²)', 'Acc Range (deg/s²)');
fprintf('%-20s %-15s %-15s %-15s\n', '----------', '---------------', '---------------', '---------------');

for j = 1:n_joints
    acc_range = global_max_acc(j) - global_min_acc(j);
    fprintf('%-20s %-15.2f %-15.2f %-15.2f\n', ...
        joint_names{j}, global_min_acc(j), global_max_acc(j), acc_range);
end

fprintf('\n=== TORQUE RANGES ===\n');
fprintf('%-20s %-15s %-15s %-15s\n', 'Joint Name', 'Torque Min (Nm)', 'Torque Max (Nm)', 'Torque Range (Nm)');
fprintf('%-20s %-15s %-15s %-15s\n', '----------', '-------------', '-------------', '-------------');

for j = 1:n_joints
    torque_range = global_max_torque(j) - global_min_torque(j);
    fprintf('%-20s %-15.2f %-15.2f %-15.2f\n', ...
        joint_names{j}, global_min_torque(j), global_max_torque(j), torque_range);
end

% Summary statistics
fprintf('\n=== SUMMARY STATISTICS ===\n');
fprintf('Position Ranges:\n');
fprintf('  Overall Min: %.2f degrees\n', min(global_min_pos));
fprintf('  Overall Max: %.2f degrees\n', max(global_max_pos));
fprintf('  Average Range: %.2f degrees\n', mean(global_max_pos - global_min_pos));

fprintf('\nVelocity Ranges:\n');
fprintf('  Overall Min: %.2f deg/s\n', min(global_min_vel));
fprintf('  Overall Max: %.2f deg/s\n', max(global_max_vel));
fprintf('  Average Range: %.2f deg/s\n', mean(global_max_vel - global_min_vel));

fprintf('\nAcceleration Ranges:\n');
fprintf('  Overall Min: %.2f deg/s²\n', min(global_min_acc));
fprintf('  Overall Max: %.2f deg/s²\n', max(global_max_acc));
fprintf('  Average Range: %.2f deg/s²\n', mean(global_max_acc - global_min_acc));

fprintf('\nTorque Ranges:\n');
fprintf('  Overall Min: %.2f Nm\n', min(global_min_torque));
fprintf('  Overall Max: %.2f Nm\n', max(global_max_torque));
fprintf('  Average Range: %.2f Nm\n', mean(global_max_torque - global_min_torque));

% Check if values look like degrees or radians
fprintf('\n=== UNIT ANALYSIS ===\n');
max_pos_abs = max(abs(global_min_pos), abs(global_max_pos));
max_vel_abs = max(abs(global_min_vel), abs(global_max_vel));
max_acc_abs = max(abs(global_min_acc), abs(global_max_acc));

fprintf('Maximum absolute position values: %.2f\n', max(max_pos_abs));
fprintf('Maximum absolute velocity values: %.2f\n', max(max_vel_abs));
fprintf('Maximum absolute acceleration values: %.2f\n', max(max_acc_abs));

if max(max_pos_abs) < 2  % Less than 2π radians
    fprintf('\n⚠️  WARNING: Position values appear to be in RADIANS, not degrees!\n');
    fprintf('   Expected range for degrees: ~±90°\n');
    fprintf('   Actual range: ~±%.2f (looks like radians)\n', max(max_pos_abs));
else
    fprintf('\n✅ Position values appear to be in DEGREES as expected.\n');
end

if max(max_vel_abs) < 10  % Less than typical degree velocities
    fprintf('\n⚠️  WARNING: Velocity values may be in rad/s, not deg/s!\n');
    fprintf('   Expected range for deg/s: ~±500 deg/s\n');
    fprintf('   Actual range: ~±%.2f (looks like rad/s)\n', max(max_vel_abs));
else
    fprintf('\n✅ Velocity values appear to be in DEGREES/SECOND as expected.\n');
end

if max(max_acc_abs) < 100  % Less than typical degree accelerations
    fprintf('\n⚠️  WARNING: Acceleration values may be in rad/s², not deg/s²!\n');
    fprintf('   Expected range for deg/s²: ~±2000 deg/s²\n');
    fprintf('   Actual range: ~±%.2f (looks like rad/s²)\n', max(max_acc_abs));
else
    fprintf('\n✅ Acceleration values appear to be in DEGREES/SECOND² as expected.\n');
end

fprintf('\n=== Analysis Complete ===\n'); 