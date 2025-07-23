% verifyDataset.m
% Verify the generated dataset and check units

clear; clc;

fprintf('=== Dataset Verification ===\n\n');

% Find the most recent dataset file
files = dir('test_dataset_*.mat');
if isempty(files)
    fprintf('No dataset files found\n');
    return;
end

% Sort by date and get the most recent
[~, idx] = sort([files.datenum], 'descend');
latest_file = files(idx(1)).name;

fprintf('Loading dataset: %s\n', latest_file);
load(latest_file);

fprintf('\nDataset Information:\n');
fprintf('  Creation time: %s\n', dataset.metadata.creation_time);
fprintf('  Description: %s\n', dataset.metadata.description);
fprintf('  Version: %s\n', dataset.metadata.version);
fprintf('  Number of simulations: %d\n', length(dataset.simulations));
fprintf('  Successful simulations: %d\n', sum(dataset.success_flags));

fprintf('\nUnit Documentation:\n');
fprintf('  Joint Positions: %s\n', dataset.metadata.units_documentation.joint_positions);
fprintf('  Joint Velocities: %s\n', dataset.metadata.units_documentation.joint_velocities);
fprintf('  Joint Accelerations: %s\n', dataset.metadata.units_documentation.joint_accelerations);
fprintf('  Joint Torques: %s\n', dataset.metadata.units_documentation.joint_torques);

% Check the first simulation data
if ~isempty(dataset.simulations) && dataset.success_flags(1)
    sim1 = dataset.simulations{1};
    
    fprintf('\nFirst Simulation Data:\n');
    fprintf('  Time points: %d\n', length(sim1.time));
    fprintf('  Joint positions (q): %s\n', mat2str(size(sim1.q)));
    fprintf('  Joint velocities (qd): %s\n', mat2str(size(sim1.qd)));
    fprintf('  Joint accelerations (qdd): %s\n', mat2str(size(sim1.qdd)));
    fprintf('  Joint torques (tau): %s\n', mat2str(size(sim1.tau)));
    
    % Check ranges of joint data
    fprintf('\nJoint Data Ranges (in degrees):\n');
    fprintf('  Positions: [%.2f, %.2f] degrees\n', min(sim1.q(:)), max(sim1.q(:)));
    fprintf('  Velocities: [%.2f, %.2f] degrees/s\n', min(sim1.qd(:)), max(sim1.qd(:)));
    fprintf('  Accelerations: [%.2f, %.2f] degrees/s²\n', min(sim1.qdd(:)), max(sim1.qdd(:)));
    fprintf('  Torques: [%.2f, %.2f] Nm\n', min(sim1.tau(:)), max(sim1.tau(:)));
    
    % Check if ranges are reasonable for degrees
    if max(abs(sim1.q(:))) > 200
        fprintf('\n⚠️  WARNING: Joint positions exceed 200 degrees - may be in radians!\n');
    else
        fprintf('\n✓ Joint positions are in reasonable degree ranges\n');
    end
    
    if max(abs(sim1.qd(:))) > 1000
        fprintf('⚠️  WARNING: Joint velocities exceed 1000 deg/s - may be in rad/s!\n');
    else
        fprintf('✓ Joint velocities are in reasonable degree ranges\n');
    end
    
    if max(abs(sim1.qdd(:))) > 10000
        fprintf('⚠️  WARNING: Joint accelerations exceed 10000 deg/s² - may be in rad/s²!\n');
    else
        fprintf('✓ Joint accelerations are in reasonable degree ranges\n');
    end
end

% Check training data
files = dir('test_training_data_*.mat');
if ~isempty(files)
    [~, idx] = sort([files.datenum], 'descend');
    latest_training_file = files(idx(1)).name;
    
    fprintf('\nLoading training data: %s\n', latest_training_file);
    load(latest_training_file);
    
    fprintf('\nTraining Data Information:\n');
    fprintf('  X shape: %s (features)\n', mat2str(size(training_data.X)));
    fprintf('  Y shape: %s (targets)\n', mat2str(size(training_data.Y)));
    fprintf('  Number of samples: %d\n', training_data.metadata.n_samples);
    fprintf('  Number of features: %d\n', training_data.metadata.n_features);
    fprintf('  Number of targets: %d\n', training_data.metadata.n_targets);
    
    % Check ranges of training data
    fprintf('\nTraining Data Ranges:\n');
    fprintf('  X (features): [%.2f, %.2f]\n', min(training_data.X(:)), max(training_data.X(:)));
    fprintf('  Y (targets): [%.2f, %.2f]\n', min(training_data.Y(:)), max(training_data.Y(:)));
end

fprintf('\n=== Verification Complete ===\n'); 