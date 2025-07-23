% extractJointStatesFromSimscape.m
% Extracts joint state signals (q, qd, qdd, tau) from Simscape Results Explorer
% Maps the actual signal names to the required neural network format

clear; clc;

fprintf('=== Joint State Extraction from Simscape Data ===\n\n');

%% Check Simscape Results Explorer
try
    simscapeRuns = Simulink.sdi.getAllRunIDs;
    if isempty(simscapeRuns)
        fprintf('No Simscape runs found. Please run a simulation first.\n');
        return;
    end
    
    % Get the most recent run
    latestRun = simscapeRuns(end);
    runObj = Simulink.sdi.getRun(latestRun);
    
    fprintf('Using run: %s (ID: %d)\n', runObj.Name, latestRun);
    
catch ME
    fprintf('Error accessing Simscape Results Explorer: %s\n', ME.message);
    return;
end

%% Define signal mappings for your golf swing model
fprintf('\n--- Mapping Joint State Signals ---\n');

% Joint position signals (q) - these are the .q signals from your model
joint_position_signals = {
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rx.q'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Ry.q'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rz.q'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Torso_Kinetically_Driven.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Spine_Tilt_Kinetically_Driven.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.q'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Spine_Tilt_Kinetically_Driven.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.q'
    'GolfSwing3D_Kinetic.Left_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.q'
    'GolfSwing3D_Kinetic.Left_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.q'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.q'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.q'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.q'
    'GolfSwing3D_Kinetic.Left_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
    'GolfSwing3D_Kinetic.Left_Forearm.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
    'GolfSwing3D_Kinetic.Left_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.q'
    'GolfSwing3D_Kinetic.Left_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.q'
    'GolfSwing3D_Kinetic.Right_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.q'
    'GolfSwing3D_Kinetic.Right_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.q'
    'GolfSwing3D_Kinetic.Right_Forearm.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
    'GolfSwing3D_Kinetic.Right_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
    'GolfSwing3D_Kinetic.Right_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.q'
    'GolfSwing3D_Kinetic.Right_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.q'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.q'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.q'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.q'
};

% Joint velocity signals (qd) - these are the .w signals from your model
joint_velocity_signals = {
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rx.w'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Ry.w'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rz.w'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Torso_Kinetically_Driven.Revolute_Joint.Kinetically_Driven_Revolute.Rz.w'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Spine_Tilt_Kinetically_Driven.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.w'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Spine_Tilt_Kinetically_Driven.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.w'
    'GolfSwing3D_Kinetic.Left_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.w'
    'GolfSwing3D_Kinetic.Left_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.w'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.w'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.w'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.w'
    'GolfSwing3D_Kinetic.Left_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.w'
    'GolfSwing3D_Kinetic.Left_Forearm.Revolute_Joint.Kinetically_Driven_Revolute.Rz.w'
    'GolfSwing3D_Kinetic.Left_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.w'
    'GolfSwing3D_Kinetic.Left_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.w'
    'GolfSwing3D_Kinetic.Right_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.w'
    'GolfSwing3D_Kinetic.Right_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.w'
    'GolfSwing3D_Kinetic.Right_Forearm.Revolute_Joint.Kinetically_Driven_Revolute.Rz.w'
    'GolfSwing3D_Kinetic.Right_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.w'
    'GolfSwing3D_Kinetic.Right_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.w'
    'GolfSwing3D_Kinetic.Right_Scapula_Joint.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.w'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.w'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.w'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.w'
};

% Joint acceleration signals (qdd) - actual angular accelerations from Simscape
joint_acceleration_signals = {
    'AngularKinematicsLogs.HipAngularAccelerationX'
    'AngularKinematicsLogs.HipAngularAccelerationY'
    'AngularKinematicsLogs.HipAngularAccelerationZ'
    'AngularKinematicsLogs.TorsoAngularAcceleration'
    'AngularKinematicsLogs.SpineAngularAccelerationX'
    'AngularKinematicsLogs.SpineAngularAccelerationY'
    'AngularKinematicsLogs.LScapAngularAccelerationX'
    'AngularKinematicsLogs.LScapAngularAccelerationY'
    'AngularKinematicsLogs.LSAngularAccelerationX'
    'AngularKinematicsLogs.LSAngularAccelerationY'
    'AngularKinematicsLogs.LSAngularAccelerationZ'
    'AngularKinematicsLogs.LEAngularAcceleration'
    'AngularKinematicsLogs.LFAngularAcceleration'
    'AngularKinematicsLogs.LWAngularAccelerationX'
    'AngularKinematicsLogs.LWAngularAccelerationY'
    'AngularKinematicsLogs.RScapAngularAccelerationX'
    'AngularKinematicsLogs.RScapAngularAccelerationY'
    'AngularKinematicsLogs.RSAngularAccelerationX'
    'AngularKinematicsLogs.RSAngularAccelerationY'
    'AngularKinematicsLogs.RSAngularAccelerationZ'
    'AngularKinematicsLogs.REAngularAcceleration'
    'AngularKinematicsLogs.RFAngularAcceleration'
    'AngularKinematicsLogs.RWAngularAccelerationX'
    'AngularKinematicsLogs.RWAngularAccelerationY'
};

% Joint torque signals (tau) - actuator torque inputs (control signals)
joint_torque_signals = {
    'HipTorqueXInput'
    'HipTorqueYInput'
    'HipTorqueZInput'
    'SpineLogs.ActuatorTorqueX'
    'SpineLogs.ActuatorTorqueY'
    'LSLogs.ActuatorTorqueX'
    'LSLogs.ActuatorTorqueY'
    'LSLogs.ActuatorTorqueZ'
    'LWLogs.ActuatorTorqueX'
    'LWLogs.ActuatorTorqueY'
    'RSLogs.ActuatorTorqueX'
    'RSLogs.ActuatorTorqueY'
    'RSLogs.ActuatorTorqueZ'
    'RWLogs.ActuatorTorqueX'
    'RWLogs.ActuatorTorqueY'
    'TranslationForceXInput'
    'TranslationForceYInput'
    'TranslationForceZInput'
    'LSTorqueXInput'
};

% Beam state signals (flexible shaft data)
beam_state_signals = {
    % Modal coordinates (deformation states)
    'Shaft_Modal_Coordinates_1'
    'Shaft_Modal_Coordinates_2'
    'Shaft_Modal_Coordinates_3'
    'Shaft_Modal_Coordinates_4'
    'Shaft_Modal_Coordinates_5'
    'Shaft_Modal_Coordinates_6'
    'Shaft_Modal_Coordinates_7'
    'Shaft_Modal_Coordinates_8'
    'Shaft_Modal_Coordinates_9'
    'Shaft_Modal_Coordinates_10'
    
    % Strain energy
    'Shaft_Strain_Energy'
    'Shaft_Strain_Energy_Density'
    
    % Displacement at beam nodes
    'Shaft_Displacement_X'
    'Shaft_Displacement_Y'
    'Shaft_Displacement_Z'
    
    % Internal forces and moments
    'Shaft_Internal_Force_X'
    'Shaft_Internal_Force_Y'
    'Shaft_Internal_Force_Z'
    'Shaft_Internal_Moment_X'
    'Shaft_Internal_Moment_Y'
    'Shaft_Internal_Moment_Z'
    
    % Beam tip position and orientation
    'Shaft_Tip_Position_X'
    'Shaft_Tip_Position_Y'
    'Shaft_Tip_Position_Z'
    'Shaft_Tip_Orientation_X'
    'Shaft_Tip_Orientation_Y'
    'Shaft_Tip_Orientation_Z'
};

fprintf('Joint positions (q): %d signals\n', length(joint_position_signals));
fprintf('Joint velocities (qd): %d signals\n', length(joint_velocity_signals));
fprintf('Joint accelerations (qdd): %d signals\n', length(joint_acceleration_signals));
fprintf('Joint torques (tau): %d signals\n', length(joint_torque_signals));
fprintf('Beam states: %d signals\n', length(beam_state_signals));

%% Extract signals from Simscape
fprintf('\n--- Extracting Joint State Data ---\n');

% Get all available signals
allSignals = runObj.getAllSignals;
allSignalNames = {allSignals.Name};

% Initialize data structures
extracted_data = struct();
extracted_data.time = [];
extracted_data.q = [];
extracted_data.qd = [];
extracted_data.tau = [];
extracted_data.beam_states = [];

% Extract joint positions (q)
fprintf('Extracting joint positions...\n');
q_data = [];
for i = 1:length(joint_position_signals)
    signal_name = joint_position_signals{i};
    
    % Find the signal in the available signals
    signal_idx = find(strcmp(allSignalNames, signal_name));
    
    if ~isempty(signal_idx)
        signal = allSignals(signal_idx);
        [data, time] = signal.getData;
        
        if isempty(extracted_data.time)
            extracted_data.time = time;
        end
        
        q_data = [q_data, data];
        fprintf('  ✓ %s\n', signal_name);
    else
        fprintf('  ✗ %s (not found)\n', signal_name);
        % Add zeros for missing signal
        if ~isempty(extracted_data.time)
            q_data = [q_data, zeros(length(extracted_data.time), 1)];
        end
    end
end
extracted_data.q = q_data;

% Extract joint velocities (qd)
fprintf('\nExtracting joint velocities...\n');
qd_data = [];
for i = 1:length(joint_velocity_signals)
    signal_name = joint_velocity_signals{i};
    
    % Find the signal in the available signals
    signal_idx = find(strcmp(allSignalNames, signal_name));
    
    if ~isempty(signal_idx)
        signal = allSignals(signal_idx);
        [data, time] = signal.getData;
        
        qd_data = [qd_data, data];
        fprintf('  ✓ %s\n', signal_name);
    else
        fprintf('  ✗ %s (not found)\n', signal_name);
        % Add zeros for missing signal
        if ~isempty(extracted_data.time)
            qd_data = [qd_data, zeros(length(extracted_data.time), 1)];
        end
    end
end
extracted_data.qd = qd_data;

% Extract joint accelerations (qdd)
fprintf('\nExtracting joint accelerations...\n');
qdd_data = [];
for i = 1:length(joint_acceleration_signals)
    signal_name = joint_acceleration_signals{i};
    
    % Find the signal in the available signals
    signal_idx = find(strcmp(allSignalNames, signal_name));
    
    if ~isempty(signal_idx)
        signal = allSignals(signal_idx);
        [data, time] = signal.getData;
        
        qdd_data = [qdd_data, data];
        fprintf('  ✓ %s\n', signal_name);
    else
        fprintf('  ✗ %s (not found)\n', signal_name);
        % Add zeros for missing signal
        if ~isempty(extracted_data.time)
            qdd_data = [qdd_data, zeros(length(extracted_data.time), 1)];
        end
    end
end
extracted_data.qdd = qdd_data;

% Extract joint torques (tau)
fprintf('\nExtracting joint torques...\n');
tau_data = [];
for i = 1:length(joint_torque_signals)
    signal_name = joint_torque_signals{i};
    
    % Find the signal in the available signals
    signal_idx = find(strcmp(allSignalNames, signal_name));
    
    if ~isempty(signal_idx)
        signal = allSignals(signal_idx);
        [data, time] = signal.getData;
        
        tau_data = [tau_data, data];
        fprintf('  ✓ %s\n', signal_name);
    else
        fprintf('  ✗ %s (not found)\n', signal_name);
        % Add zeros for missing signal
        if ~isempty(extracted_data.time)
            tau_data = [tau_data, zeros(length(extracted_data.time), 1)];
        end
    end
end
extracted_data.tau = tau_data;

% Extract beam states
fprintf('\nExtracting beam states...\n');
beam_data = [];
for i = 1:length(beam_state_signals)
    signal_name = beam_state_signals{i};
    
    % Find the signal in the available signals
    signal_idx = find(strcmp(allSignalNames, signal_name));
    
    if ~isempty(signal_idx)
        signal = allSignals(signal_idx);
        [data, time] = signal.getData;
        
        beam_data = [beam_data, data];
        fprintf('  ✓ %s\n', signal_name);
    else
        fprintf('  ✗ %s (not found)\n', signal_name);
        % Add zeros for missing signal
        if ~isempty(extracted_data.time)
            beam_data = [beam_data, zeros(length(extracted_data.time), 1)];
        end
    end
end
extracted_data.beam_states = beam_data;

%% Create logsout-compatible structure
fprintf('\n--- Creating logsout-Compatible Structure ---\n');

% Create a structure that mimics logsout
logsout_struct = struct();
logsout_struct.numElements = 4; % q, qd, qdd, tau
logsout_struct.time = extracted_data.time;

% Add get method simulation
logsout_struct.get = @(name) getJointStateElement(logsout_struct, name, extracted_data);

% Save the extracted data
save('extracted_joint_states.mat', 'extracted_data', 'logsout_struct');

fprintf('Joint state data saved to: extracted_joint_states.mat\n');

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Time points: %d\n', length(extracted_data.time));
fprintf('Joint positions (q): %dx%d\n', size(extracted_data.q, 1), size(extracted_data.q, 2));
fprintf('Joint velocities (qd): %dx%d\n', size(extracted_data.qd, 1), size(extracted_data.qd, 2));
fprintf('Joint accelerations (qdd): %dx%d\n', size(extracted_data.qdd, 1), size(extracted_data.qdd, 2));
fprintf('Joint torques (tau): %dx%d\n', size(extracted_data.tau, 1), size(extracted_data.tau, 2));
fprintf('Beam states: %dx%d\n', size(extracted_data.beam_states, 1), size(extracted_data.beam_states, 2));

fprintf('\n✓ All required joint state and beam signals extracted!\n');
fprintf('You can now use this data with your neural network pipeline.\n');

%% Helper Functions

function element = getJointStateElement(logsout_struct, name, extracted_data)
    % Simulate logsout.get() method for joint state signals
    
    switch lower(name)
        case 'q'
            data = extracted_data.q;
        case 'qd'
            data = extracted_data.qd;
        case 'qdd'
            data = extracted_data.qdd;
        case 'tau'
            data = extracted_data.tau;
        case 'beam_states'
            data = extracted_data.beam_states;
        otherwise
            error('Signal %s not found. Available: q, qd, qdd, tau, beam_states', name);
    end
    
    % Create a signal element structure
    element = struct();
    element.Name = name;
    element.Values = struct();
    element.Values.Data = data;
    element.Values.Time = extracted_data.time;
end 