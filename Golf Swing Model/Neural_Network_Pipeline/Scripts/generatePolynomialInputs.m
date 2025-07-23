function polynomial_inputs = generatePolynomialInputs(config)
% generatePolynomialInputs.m
% Generates random polynomial inputs for golf swing simulation
% 
% Inputs:
%   config - Configuration structure with parameter ranges
%
% Outputs:
%   polynomial_inputs - Structure containing polynomial coefficients

%% Default configuration if not provided
if nargin < 1
    config = struct();
end

% Set default ranges if not specified
if ~isfield(config, 'hip_torque_range')
    config.hip_torque_range = [-50, 50]; % Nm
end
if ~isfield(config, 'spine_torque_range')
    config.spine_torque_range = [-30, 30]; % Nm
end
if ~isfield(config, 'shoulder_torque_range')
    config.shoulder_torque_range = [-20, 20]; % Nm
end
if ~isfield(config, 'elbow_torque_range')
    config.elbow_torque_range = [-15, 15]; % Nm
end
if ~isfield(config, 'wrist_torque_range')
    config.wrist_torque_range = [-10, 10]; % Nm
end
if ~isfield(config, 'translation_force_range')
    config.translation_force_range = [-100, 100]; % N
end
if ~isfield(config, 'polynomial_order')
    config.polynomial_order = 4; % 4th order polynomials
end
if ~isfield(config, 'swing_duration_range')
    config.swing_duration_range = [0.8, 1.2]; % seconds
end

%% Generate random polynomial coefficients for each joint

% Hip torques (X, Y, Z)
hip_torque_x = generateRandomPolynomial(config.polynomial_order, config.hip_torque_range);
hip_torque_y = generateRandomPolynomial(config.polynomial_order, config.hip_torque_range);
hip_torque_z = generateRandomPolynomial(config.polynomial_order, config.hip_torque_range);

% Spine torques (X, Y)
spine_torque_x = generateRandomPolynomial(config.polynomial_order, config.spine_torque_range);
spine_torque_y = generateRandomPolynomial(config.polynomial_order, config.spine_torque_range);

% Left shoulder torques (X, Y, Z)
left_shoulder_x = generateRandomPolynomial(config.polynomial_order, config.shoulder_torque_range);
left_shoulder_y = generateRandomPolynomial(config.polynomial_order, config.shoulder_torque_range);
left_shoulder_z = generateRandomPolynomial(config.polynomial_order, config.shoulder_torque_range);

% Right shoulder torques (X, Y, Z)
right_shoulder_x = generateRandomPolynomial(config.polynomial_order, config.shoulder_torque_range);
right_shoulder_y = generateRandomPolynomial(config.polynomial_order, config.shoulder_torque_range);
right_shoulder_z = generateRandomPolynomial(config.polynomial_order, config.shoulder_torque_range);

% Left elbow torque (Z only)
left_elbow_z = generateRandomPolynomial(config.polynomial_order, config.elbow_torque_range);

% Right elbow torque (Z only)
right_elbow_z = generateRandomPolynomial(config.polynomial_order, config.elbow_torque_range);

% Left wrist torques (X, Y)
left_wrist_x = generateRandomPolynomial(config.polynomial_order, config.wrist_torque_range);
left_wrist_y = generateRandomPolynomial(config.polynomial_order, config.wrist_torque_range);

% Right wrist torques (X, Y)
right_wrist_x = generateRandomPolynomial(config.polynomial_order, config.wrist_torque_range);
right_wrist_y = generateRandomPolynomial(config.polynomial_order, config.wrist_torque_range);

% Translation forces (X, Y, Z)
translation_force_x = generateRandomPolynomial(config.polynomial_order, config.translation_force_range);
translation_force_y = generateRandomPolynomial(config.polynomial_order, config.translation_force_range);
translation_force_z = generateRandomPolynomial(config.polynomial_order, config.translation_force_range);

% Swing duration
swing_duration = config.swing_duration_range(1) + ...
                 rand() * (config.swing_duration_range(2) - config.swing_duration_range(1));

%% Package all polynomial inputs
polynomial_inputs = struct();

% Hip torques
polynomial_inputs.hip_torque_x = hip_torque_x;
polynomial_inputs.hip_torque_y = hip_torque_y;
polynomial_inputs.hip_torque_z = hip_torque_z;

% Spine torques
polynomial_inputs.spine_torque_x = spine_torque_x;
polynomial_inputs.spine_torque_y = spine_torque_y;

% Shoulder torques
polynomial_inputs.left_shoulder_x = left_shoulder_x;
polynomial_inputs.left_shoulder_y = left_shoulder_y;
polynomial_inputs.left_shoulder_z = left_shoulder_z;
polynomial_inputs.right_shoulder_x = right_shoulder_x;
polynomial_inputs.right_shoulder_y = right_shoulder_y;
polynomial_inputs.right_shoulder_z = right_shoulder_z;

% Elbow torques
polynomial_inputs.left_elbow_z = left_elbow_z;
polynomial_inputs.right_elbow_z = right_elbow_z;

% Wrist torques
polynomial_inputs.left_wrist_x = left_wrist_x;
polynomial_inputs.left_wrist_y = left_wrist_y;
polynomial_inputs.right_wrist_x = right_wrist_x;
polynomial_inputs.right_wrist_y = right_wrist_y;

% Translation forces
polynomial_inputs.translation_force_x = translation_force_x;
polynomial_inputs.translation_force_y = translation_force_y;
polynomial_inputs.translation_force_z = translation_force_z;

% Timing
polynomial_inputs.swing_duration = swing_duration;

% Metadata
polynomial_inputs.generation_time = datetime('now');
polynomial_inputs.config = config;

end

function coeffs = generateRandomPolynomial(order, range)
% Generate random polynomial coefficients within specified range
% 
% Inputs:
%   order - Polynomial order (e.g., 4 for 4th order)
%   range - [min, max] range for coefficient values
%
% Outputs:
%   coeffs - Array of polynomial coefficients [a0, a1, a2, a3, a4]

% Generate random coefficients
coeffs = range(1) + (range(2) - range(1)) * rand(1, order + 1);

% Ensure smooth transitions by constraining higher order terms
% Higher order coefficients should generally be smaller
for i = 2:length(coeffs)
    coeffs(i) = coeffs(i) * (0.5^(i-1)); % Decay factor
end

% Add some correlation between coefficients for realistic motion
% This ensures the polynomial doesn't produce erratic behavior
coeffs = smoothPolynomialCoefficients(coeffs, range);

end

function coeffs = smoothPolynomialCoefficients(coeffs, range)
% Apply smoothing to ensure realistic polynomial behavior

% Limit the maximum change between consecutive coefficients
max_change = (range(2) - range(1)) * 0.3;

for i = 2:length(coeffs)
    prev_coeff = coeffs(i-1);
    current_coeff = coeffs(i);
    
    % If change is too large, smooth it
    if abs(current_coeff - prev_coeff) > max_change
        if current_coeff > prev_coeff
            coeffs(i) = prev_coeff + max_change;
        else
            coeffs(i) = prev_coeff - max_change;
        end
    end
end

end 