% testJointRanges.m
% Test the joint_ranges array definition

clear; clc;

try
    % Define realistic joint ranges for golf swing (in radians)
    % These ranges are based on typical golf swing motions
    % Total of 28 DOFs as per Simulink model
    joint_ranges = [
        % Hip joints (3 DOF)
        0.5, 0.3, 1.0,    % Hip Rx, Ry, Rz (±~30°, ±~17°, ±~57°)
        % Torso joint (1 DOF)
        1.5,               % Torso Rz (±~86°)
        % Spine joints (2 DOF)
        0.3, 0.2,         % Spine Rx, Ry (±~17°, ±~11°)
        % Left scapula (2 DOF)
        0.4, 0.3,         % LScap Rx, Ry (±~23°, ±~17°)
        % Left shoulder (3 DOF)
        0.8, 1.2, 0.5,    % LShoulder Rx, Ry, Rz (±~46°, ±~69°, ±~29°)
        % Left elbow (1 DOF)
        1.5,               % LElbow Rz (0-86°)
        % Left forearm (1 DOF)
        0.8,               % LForearm Rz (±~46°)
        % Left wrist (2 DOF)
        0.5, 0.4,         % LWrist Rx, Ry (±~29°, ±~23°)
        % Right wrist (2 DOF)
        0.5, 0.4,         % RWrist Rx, Ry (±~29°, ±~23°)
        % Right forearm (1 DOF)
        0.8,               % RForearm Rz (±~46°)
        % Right elbow (1 DOF)
        1.5,               % REllbow Rz (0-86°)
        % Right scapula (2 DOF)
        0.4, 0.3,         % RScap Rx, Ry (±~23°, ±~17°)
        % Right shoulder (3 DOF)
        0.8, 1.2, 0.5,    % RShoulder Rx, Ry, Rz (±~46°, ±~69°, ±~29°)
        % Additional joints to reach 28 DOFs (if needed)
        0.5, 0.5, 0.5, 0.5  % Additional joints with default range (±~29°)
    ];
    
    fprintf('✓ Joint ranges array created successfully\n');
    fprintf('  Length: %d elements\n', length(joint_ranges));
    fprintf('  Expected: 28 elements\n');
    
    if length(joint_ranges) == 28
        fprintf('✓ Array has correct length\n');
    else
        fprintf('✗ Array has wrong length\n');
    end
    
catch ME
    fprintf('✗ Error creating joint_ranges array: %s\n', ME.message);
end 