% controlWithNeuralNetwork.m
% Uses trained neural network to control golf swing model with desired kinematics
% This implements the complete pipeline: desired kinematics -> neural network -> joint torques -> simulation

clear; clc;

%% Configuration
% Load trained model
modelPath = 'TrainedModels/inverse_dynamics_model.mat';
if ~exist(modelPath, 'file')
    error('Trained model not found. Please run trainInverseDynamicsModel.m first.');
end

fprintf('Loading trained model from %s...\n', modelPath);
load(modelPath);

% Simulation parameters
simDuration = 1.0;  % seconds
dt = 0.001;         % time step
nSteps = round(simDuration / dt);
t = (0:nSteps-1) * dt;

% Control parameters
useFeedback = true;  % Use feedback control to correct deviations
feedbackGain = 0.1;  % Feedback gain for position correction

%% Define desired kinematics
fprintf('Defining desired kinematics...\n');

% Example: Define a desired golf swing trajectory
% This could come from motion capture data, optimization, or manual specification
desiredKinematics = generateDesiredGolfSwing(t);

% Extract desired states
q_desired = desiredKinematics.q;
qd_desired = desiredKinematics.qd;
qdd_desired = desiredKinematics.qdd;

nJoints = size(q_desired, 2);

fprintf('Desired trajectory: %d joints, %d time steps\n', nJoints, size(q_desired, 1));

%% Initialize simulation
fprintf('Initializing simulation...\n');

% Initialize state variables
q_current = q_desired(1, :);  % Start at desired initial position
qd_current = qd_desired(1, :); % Start at desired initial velocity

% Storage for simulation results
q_sim = zeros(nSteps, nJoints);
qd_sim = zeros(nSteps, nJoints);
qdd_sim = zeros(nSteps, nJoints);
tau_sim = zeros(nSteps, nJoints);
error_sim = zeros(nSteps, nJoints);

%% Run simulation with neural network control
fprintf('Running simulation with neural network control...\n');

for step = 1:nSteps
    % Current desired state
    q_des = q_desired(step, :);
    qd_des = qd_desired(step, :);
    qdd_des = qdd_desired(step, :);
    
    % Prepare input for neural network
    if useFeedback
        % Add feedback correction to desired position
        position_error = q_des - q_current;
        q_des_corrected = q_des + feedbackGain * position_error;
        
        % Use corrected desired state
        nn_input = [q_des_corrected, qd_des, qdd_des];
    else
        % Use original desired state
        nn_input = [q_des, qd_des, qdd_des];
    end
    
    % Normalize input
    nn_input_norm = (nn_input - X_mean) ./ X_std;
    
    % Predict joint torques using neural network
    tau_pred_norm = predict(net, nn_input_norm);
    tau_pred = tau_pred_norm .* Y_std + Y_mean;
    
    % Store results
    q_sim(step, :) = q_current;
    qd_sim(step, :) = qd_current;
    qdd_sim(step, :) = qdd_des;
    tau_sim(step, :) = tau_pred;
    error_sim(step, :) = q_des - q_current;
    
    % Update state for next step (simple Euler integration)
    if step < nSteps
        % Simple physics update (in practice, this would be done by the Simulink model)
        qd_current = qd_current + qdd_des * dt;
        q_current = q_current + qd_current * dt;
        
        % Optional: Add some realistic constraints or limits
        q_current = constrainJointLimits(q_current);
    end
    
    % Progress indicator
    if mod(step, 100) == 0
        fprintf('Step %d/%d (%.1f%%)\n', step, nSteps, 100*step/nSteps);
    end
end

%% Evaluate performance
fprintf('\nEvaluating control performance...\n');

% Calculate tracking errors
position_rmse = sqrt(mean((q_sim - q_desired).^2, 'all'));
velocity_rmse = sqrt(mean((qd_sim - qd_desired).^2, 'all'));
acceleration_rmse = sqrt(mean((qdd_sim - qdd_desired).^2, 'all'));

fprintf('Position tracking RMSE: %.4f\n', position_rmse);
fprintf('Velocity tracking RMSE: %.4f\n', velocity_rmse);
fprintf('Acceleration tracking RMSE: %.4f\n', acceleration_rmse);

% Calculate maximum errors
max_position_error = max(abs(q_sim - q_desired), [], 'all');
max_velocity_error = max(abs(qd_sim - qd_desired), [], 'all');

fprintf('Maximum position error: %.4f\n', max_position_error);
fprintf('Maximum velocity error: %.4f\n', max_velocity_error);

%% Save results
fprintf('Saving results...\n');

results.t = t;
results.q_sim = q_sim;
results.qd_sim = qd_sim;
results.qdd_sim = qdd_sim;
results.tau_sim = tau_sim;
results.q_desired = q_desired;
results.qd_desired = qd_desired;
results.qdd_desired = qdd_desired;
results.error_sim = error_sim;
results.performance.position_rmse = position_rmse;
results.performance.velocity_rmse = velocity_rmse;
results.performance.acceleration_rmse = acceleration_rmse;
results.performance.max_position_error = max_position_error;
results.performance.max_velocity_error = max_velocity_error;

save('neural_network_control_results.mat', 'results');

%% Plot results
plotControlResults(results, t, nJoints);

fprintf('\n=== Neural Network Control Complete ===\n');
fprintf('Results saved to: neural_network_control_results.mat\n');

%% Helper Functions

function desiredKinematics = generateDesiredGolfSwing(t)
    % Generate a desired golf swing trajectory
    % This is a simplified example - in practice, this would come from
    % motion capture data or optimization
    
    nSteps = length(t);
    nJoints = 28;
    
    % Initialize arrays
    q = zeros(nSteps, nJoints);
    qd = zeros(nSteps, nJoints);
    qdd = zeros(nSteps, nJoints);
    
    % Example: Create a simple backswing and downswing pattern
    % This is just a demonstration - real golf swings are much more complex
    
    % Backswing phase (0-40% of time)
    backswing_end = round(0.4 * nSteps);
    backswing_t = t(1:backswing_end) / t(backswing_end);
    
    % Downswing phase (40-80% of time)
    downswing_start = backswing_end + 1;
    downswing_end = round(0.8 * nSteps);
    downswing_t = (t(downswing_start:downswing_end) - t(downswing_start)) / (t(downswing_end) - t(downswing_start));
    
    % Follow-through phase (80-100% of time)
    follow_start = downswing_end + 1;
    follow_t = (t(follow_start:end) - t(follow_start)) / (t(end) - t(follow_start));
    
    % Generate joint trajectories (simplified)
    for joint = 1:nJoints
        % Different joints have different patterns
        amplitude = 0.5 + 0.5 * sin(joint * pi / nJoints);  % Vary amplitude by joint
        phase = joint * 0.1;  % Vary phase by joint
        
        % Backswing: gradual increase
        q(1:backswing_end, joint) = amplitude * backswing_t.^2;
        
        % Downswing: rapid decrease then increase
        if ~isempty(downswing_t)
            q(downswing_start:downswing_end, joint) = amplitude * (1 - downswing_t.^2);
        end
        
        % Follow-through: gradual decrease
        if ~isempty(follow_t)
            q(follow_start:end, joint) = amplitude * (1 - follow_t);
        end
        
        % Add some variation based on joint type
        if joint <= 3  % Base joints
            q(:, joint) = q(:, joint) * 0.3;
        elseif joint <= 9  % Hip joints
            q(:, joint) = q(:, joint) * 0.8;
        elseif joint <= 15  % Torso joints
            q(:, joint) = q(:, joint) * 1.2;
        else  % Arm joints
            q(:, joint) = q(:, joint) * 1.0;
        end
    end
    
    % Calculate velocities and accelerations (numerical differentiation)
    qd = gradient(q, t);
    qdd = gradient(qd, t);
    
    % Package results
    desiredKinematics.q = q;
    desiredKinematics.qd = qd;
    desiredKinematics.qdd = qdd;
    desiredKinematics.t = t;
end

function q_constrained = constrainJointLimits(q)
    % Apply joint limit constraints
    % This is a simplified version - real joint limits would be more complex
    
    % Example joint limits (min, max) for each joint
    % In practice, these would come from the model definition
    joint_limits = [
        -pi, pi;    % Joint 1
        -pi, pi;    % Joint 2
        -pi, pi;    % Joint 3
        -pi/2, pi/2; % Joint 4
        -pi/2, pi/2; % Joint 5
        -pi/2, pi/2; % Joint 6
        % ... continue for all 28 joints
    ];
    
    % Extend limits for all joints (simplified)
    if size(joint_limits, 1) < length(q)
        joint_limits = repmat([-pi, pi], length(q), 1);
    end
    
    % Apply constraints
    q_constrained = q;
    for i = 1:length(q)
        q_constrained(i) = max(joint_limits(i, 1), min(joint_limits(i, 2), q(i)));
    end
end

function plotControlResults(results, t, nJoints)
    % Plot control results and analysis
    
    figure('Name', 'Neural Network Control Results', 'Position', [100, 100, 1400, 1000]);
    
    % Plot 1: Position tracking for first few joints
    subplot(3,3,1);
    n_plot_joints = min(5, nJoints);
    for j = 1:n_plot_joints
        plot(t, results.q_desired(:, j), 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Desired %d', j));
        hold on;
        plot(t, results.q_sim(:, j), 'r--', 'LineWidth', 1, 'DisplayName', sprintf('Actual %d', j));
    end
    title('Position Tracking (First 5 Joints)');
    xlabel('Time (s)');
    ylabel('Position (rad)');
    legend('Location', 'best');
    grid on;
    
    % Plot 2: Velocity tracking
    subplot(3,3,2);
    for j = 1:n_plot_joints
        plot(t, results.qd_desired(:, j), 'b-', 'LineWidth', 2);
        hold on;
        plot(t, results.qd_sim(:, j), 'r--', 'LineWidth', 1);
    end
    title('Velocity Tracking (First 5 Joints)');
    xlabel('Time (s)');
    ylabel('Velocity (rad/s)');
    grid on;
    
    % Plot 3: Position tracking error
    subplot(3,3,3);
    position_error = results.q_desired - results.q_sim;
    plot(t, position_error(:, 1:n_plot_joints));
    title('Position Tracking Error (First 5 Joints)');
    xlabel('Time (s)');
    ylabel('Error (rad)');
    grid on;
    
    % Plot 4: Torque commands
    subplot(3,3,4);
    for j = 1:n_plot_joints
        plot(t, results.tau_sim(:, j), 'LineWidth', 1);
        hold on;
    end
    title('Neural Network Torque Commands (First 5 Joints)');
    xlabel('Time (s)');
    ylabel('Torque (N⋅m)');
    grid on;
    
    % Plot 5: RMS error over time
    subplot(3,3,5);
    rms_error = sqrt(mean(position_error.^2, 2));
    plot(t, rms_error, 'b-', 'LineWidth', 2);
    title('RMS Position Error Over Time');
    xlabel('Time (s)');
    ylabel('RMS Error (rad)');
    grid on;
    
    % Plot 6: Joint-wise final error
    subplot(3,3,6);
    final_errors = abs(position_error(end, :));
    bar(final_errors);
    title('Final Position Error by Joint');
    xlabel('Joint Index');
    ylabel('Absolute Error (rad)');
    grid on;
    
    % Plot 7: Torque magnitude over time
    subplot(3,3,7);
    torque_magnitude = vecnorm(results.tau_sim, 2, 2);
    plot(t, torque_magnitude, 'b-', 'LineWidth', 2);
    title('Total Torque Magnitude');
    xlabel('Time (s)');
    ylabel('Torque Magnitude (N⋅m)');
    grid on;
    
    % Plot 8: Performance metrics
    subplot(3,3,8);
    metrics = [results.performance.position_rmse, ...
               results.performance.velocity_rmse, ...
               results.performance.max_position_error, ...
               results.performance.max_velocity_error];
    metric_names = {'Pos RMSE', 'Vel RMSE', 'Max Pos Err', 'Max Vel Err'};
    bar(metrics);
    set(gca, 'XTickLabel', metric_names);
    title('Performance Metrics');
    ylabel('Error');
    grid on;
    
    % Plot 9: 3D trajectory (if available)
    subplot(3,3,9);
    % This would show the 3D trajectory of a key point (e.g., clubhead)
    % For now, show a placeholder
    plot3(cos(t), sin(t), t, 'b-', 'LineWidth', 2);
    title('3D Trajectory (Example)');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    
    sgtitle('Neural Network Control Performance Analysis');
end 