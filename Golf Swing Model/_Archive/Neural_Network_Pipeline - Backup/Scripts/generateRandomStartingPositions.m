function starting_positions = generateRandomStartingPositions(config)
% generateRandomStartingPositions.m
% Generates random starting positions for golf swing simulation
% 
% Inputs:
%   config - Configuration structure with parameter ranges
%
% Outputs:
%   starting_positions - Structure containing initial joint positions

%% Default configuration if not provided
if nargin < 1
    config = struct();
end

% Set default ranges if not specified
if ~isfield(config, 'hip_position_range')
    config.hip_position_range = [-0.1, 0.1]; % meters
end
if ~isfield(config, 'hip_rotation_range')
    config.hip_rotation_range = [-0.2, 0.2]; % radians (~±11 degrees)
end
if ~isfield(config, 'spine_tilt_range')
    config.spine_tilt_range = [-0.3, 0.3]; % radians (~±17 degrees)
end
if ~isfield(config, 'torso_rotation_range')
    config.torso_rotation_range = [-0.4, 0.4]; % radians (~±23 degrees)
end
if ~isfield(config, 'shoulder_position_range')
    config.shoulder_position_range = [-0.05, 0.05]; % meters
end
if ~isfield(config, 'shoulder_rotation_range')
    config.shoulder_rotation_range = [-0.1, 0.1]; % radians (~±6 degrees)
end

%% Generate random starting positions

% Hip position (translation)
hip_x = config.hip_position_range(1) + ...
        rand() * (config.hip_position_range(2) - config.hip_position_range(1));
hip_y = config.hip_position_range(1) + ...
        rand() * (config.hip_position_range(2) - config.hip_position_range(1));
hip_z = config.hip_position_range(1) + ...
        rand() * (config.hip_position_range(2) - config.hip_position_range(1));

% Hip rotation (Rx, Ry, Rz)
hip_rx = config.hip_rotation_range(1) + ...
         rand() * (config.hip_rotation_range(2) - config.hip_rotation_range(1));
hip_ry = config.hip_rotation_range(1) + ...
         rand() * (config.hip_rotation_range(2) - config.hip_rotation_range(1));
hip_rz = config.hip_rotation_range(1) + ...
         rand() * (config.hip_rotation_range(2) - config.hip_rotation_range(1));

% Spine tilt (Rx, Ry)
spine_rx = config.spine_tilt_range(1) + ...
           rand() * (config.spine_tilt_range(2) - config.spine_tilt_range(1));
spine_ry = config.spine_tilt_range(1) + ...
           rand() * (config.spine_tilt_range(2) - config.spine_tilt_range(1));

% Torso rotation (Rz)
torso_rz = config.torso_rotation_range(1) + ...
           rand() * (config.torso_rotation_range(2) - config.torso_rotation_range(1));

% Left shoulder position and rotation
left_shoulder_x = config.shoulder_position_range(1) + ...
                  rand() * (config.shoulder_position_range(2) - config.shoulder_position_range(1));
left_shoulder_y = config.shoulder_position_range(1) + ...
                  rand() * (config.shoulder_position_range(2) - config.shoulder_position_range(1));
left_shoulder_z = config.shoulder_position_range(1) + ...
                  rand() * (config.shoulder_position_range(2) - config.shoulder_position_range(1));

left_shoulder_rx = config.shoulder_rotation_range(1) + ...
                   rand() * (config.shoulder_rotation_range(2) - config.shoulder_rotation_range(1));
left_shoulder_ry = config.shoulder_rotation_range(1) + ...
                   rand() * (config.shoulder_rotation_range(2) - config.shoulder_rotation_range(1));
left_shoulder_rz = config.shoulder_rotation_range(1) + ...
                   rand() * (config.shoulder_rotation_range(2) - config.shoulder_rotation_range(1));

% Right shoulder position and rotation
right_shoulder_x = config.shoulder_position_range(1) + ...
                   rand() * (config.shoulder_position_range(2) - config.shoulder_position_range(1));
right_shoulder_y = config.shoulder_position_range(1) + ...
                   rand() * (config.shoulder_position_range(2) - config.shoulder_position_range(1));
right_shoulder_z = config.shoulder_position_range(1) + ...
                   rand() * (config.shoulder_position_range(2) - config.shoulder_position_range(1));

right_shoulder_rx = config.shoulder_rotation_range(1) + ...
                    rand() * (config.shoulder_rotation_range(2) - config.shoulder_rotation_range(1));
right_shoulder_ry = config.shoulder_rotation_range(1) + ...
                    rand() * (config.shoulder_rotation_range(2) - config.shoulder_rotation_range(1));
right_shoulder_rz = config.shoulder_rotation_range(1) + ...
                    rand() * (config.shoulder_rotation_range(2) - config.shoulder_rotation_range(1));

% Arms and hands - keep fixed (as requested)
% These will use default/standard positions
left_elbow_rz = 0; % Fixed
left_forearm_rz = 0; % Fixed
left_wrist_rx = 0; % Fixed
left_wrist_ry = 0; % Fixed

right_elbow_rz = 0; % Fixed
right_forearm_rz = 0; % Fixed
right_wrist_rx = 0; % Fixed
right_wrist_ry = 0; % Fixed

%% Package all starting positions
starting_positions = struct();

% Hip positions and rotations
starting_positions.hip_x = hip_x;
starting_positions.hip_y = hip_y;
starting_positions.hip_z = hip_z;
starting_positions.hip_rx = hip_rx;
starting_positions.hip_ry = hip_ry;
starting_positions.hip_rz = hip_rz;

% Spine and torso
starting_positions.spine_rx = spine_rx;
starting_positions.spine_ry = spine_ry;
starting_positions.torso_rz = torso_rz;

% Left shoulder
starting_positions.left_shoulder_x = left_shoulder_x;
starting_positions.left_shoulder_y = left_shoulder_y;
starting_positions.left_shoulder_z = left_shoulder_z;
starting_positions.left_shoulder_rx = left_shoulder_rx;
starting_positions.left_shoulder_ry = left_shoulder_ry;
starting_positions.left_shoulder_rz = left_shoulder_rz;

% Right shoulder
starting_positions.right_shoulder_x = right_shoulder_x;
starting_positions.right_shoulder_y = right_shoulder_y;
starting_positions.right_shoulder_z = right_shoulder_z;
starting_positions.right_shoulder_rx = right_shoulder_rx;
starting_positions.right_shoulder_ry = right_shoulder_ry;
starting_positions.right_shoulder_rz = right_shoulder_rz;

% Arms and hands (fixed)
starting_positions.left_elbow_rz = left_elbow_rz;
starting_positions.left_forearm_rz = left_forearm_rz;
starting_positions.left_wrist_rx = left_wrist_rx;
starting_positions.left_wrist_ry = left_wrist_ry;

starting_positions.right_elbow_rz = right_elbow_rz;
starting_positions.right_forearm_rz = right_forearm_rz;
starting_positions.right_wrist_rx = right_wrist_rx;
starting_positions.right_wrist_ry = right_wrist_ry;

% Metadata
starting_positions.generation_time = datetime('now');
starting_positions.config = config;

end 