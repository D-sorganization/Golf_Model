% countJoints.m
% Count joint ranges elements

joint_ranges = [
    % Hip joints (3 DOF)
    0.5, 0.3, 1.0;    % Hip Rx, Ry, Rz (±~30°, ±~17°, ±~57°)
    % Torso joint (1 DOF)
    1.5;               % Torso Rz (±~86°)
    % Spine joints (2 DOF)
    0.3, 0.2;         % Spine Rx, Ry (±~17°, ±~11°)
    % Left scapula (2 DOF)
    0.4, 0.3;         % LScap Rx, Ry (±~23°, ±~17°)
    % Left shoulder (3 DOF)
    0.8, 1.2, 0.5;    % LShoulder Rx, Ry, Rz (±~46°, ±~69°, ±~29°)
    % Left elbow (1 DOF)
    1.5;               % LElbow Rz (0-86°)
    % Left forearm (1 DOF)
    0.8;               % LForearm Rz (±~46°)
    % Left wrist (2 DOF)
    0.5, 0.4;         % LWrist Rx, Ry (±~29°, ±~23°)
    % Right wrist (2 DOF)
    0.5, 0.4;         % RWrist Rx, Ry (±~29°, ±~23°)
    % Right forearm (1 DOF)
    0.8;               % RForearm Rz (±~46°)
    % Right elbow (1 DOF)
    1.5;               % REllbow Rz (0-86°)
    % Right scapula (2 DOF)
    0.4, 0.3;         % RScap Rx, Ry (±~23°, ±~17°)
    % Right shoulder (3 DOF)
    0.8, 1.2, 0.5;    % RShoulder Rx, Ry, Rz (±~46°, ±~69°, ±~29°)
    % Additional joints to reach 28 DOFs (if needed)
    0.5, 0.5, 0.5, 0.5;  % Additional joints with default range (±~29°)
];

fprintf('Joint ranges array has %d elements\n', length(joint_ranges));

% Count by section
fprintf('\nBreakdown:\n');
fprintf('Hip joints (3): 3\n');
fprintf('Torso joint (1): 1\n');
fprintf('Spine joints (2): 2\n');
fprintf('Left scapula (2): 2\n');
fprintf('Left shoulder (3): 3\n');
fprintf('Left elbow (1): 1\n');
fprintf('Left forearm (1): 1\n');
fprintf('Left wrist (2): 2\n');
fprintf('Right wrist (2): 2\n');
fprintf('Right forearm (1): 1\n');
fprintf('Right elbow (1): 1\n');
fprintf('Right scapula (2): 2\n');
fprintf('Right shoulder (3): 3\n');
fprintf('Additional (4): 4\n');
fprintf('Total: 3+1+2+2+3+1+1+2+2+1+1+2+3+4 = %d\n', 3+1+2+2+3+1+1+2+2+1+1+2+3+4); 