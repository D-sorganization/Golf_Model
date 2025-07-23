function success = updateModelParameters(polynomial_inputs, starting_positions, model_name)
% updateModelParameters.m
% Updates Simulink model parameters with polynomial inputs and starting positions
% 
% Inputs:
%   polynomial_inputs - Structure containing polynomial coefficients
%   starting_positions - Structure containing initial joint positions
%   model_name - Name of the Simulink model (default: 'GolfSwing3D_Kinetic')
%
% Outputs:
%   success - Boolean indicating if update was successful

%% Default model name
if nargin < 3
    model_name = 'GolfSwing3D_Kinetic';
end

%% Check if model is loaded
if ~bdIsLoaded(model_name)
    try
        load_system(model_name);
        fprintf('Loaded model: %s\n', model_name);
    catch ME
        fprintf('Error loading model %s: %s\n', model_name, ME.message);
        success = false;
        return;
    end
end

%% Update polynomial input parameters
fprintf('Updating polynomial input parameters...\n');

try
    % Hip torque polynomials
    if isfield(polynomial_inputs, 'hip_torque_x')
        set_param([model_name '/Hip Torque X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.hip_torque_x));
    end
    if isfield(polynomial_inputs, 'hip_torque_y')
        set_param([model_name '/Hip Torque Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.hip_torque_y));
    end
    if isfield(polynomial_inputs, 'hip_torque_z')
        set_param([model_name '/Hip Torque Z Polynomial'], 'Coefficients', mat2str(polynomial_inputs.hip_torque_z));
    end
    
    % Spine torque polynomials
    if isfield(polynomial_inputs, 'spine_torque_x')
        set_param([model_name '/Spine Torque X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.spine_torque_x));
    end
    if isfield(polynomial_inputs, 'spine_torque_y')
        set_param([model_name '/Spine Torque Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.spine_torque_y));
    end
    
    % Shoulder torque polynomials
    if isfield(polynomial_inputs, 'left_shoulder_x')
        set_param([model_name '/Left Shoulder X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.left_shoulder_x));
    end
    if isfield(polynomial_inputs, 'left_shoulder_y')
        set_param([model_name '/Left Shoulder Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.left_shoulder_y));
    end
    if isfield(polynomial_inputs, 'left_shoulder_z')
        set_param([model_name '/Left Shoulder Z Polynomial'], 'Coefficients', mat2str(polynomial_inputs.left_shoulder_z));
    end
    
    if isfield(polynomial_inputs, 'right_shoulder_x')
        set_param([model_name '/Right Shoulder X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.right_shoulder_x));
    end
    if isfield(polynomial_inputs, 'right_shoulder_y')
        set_param([model_name '/Right Shoulder Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.right_shoulder_y));
    end
    if isfield(polynomial_inputs, 'right_shoulder_z')
        set_param([model_name '/Right Shoulder Z Polynomial'], 'Coefficients', mat2str(polynomial_inputs.right_shoulder_z));
    end
    
    % Elbow torque polynomials
    if isfield(polynomial_inputs, 'left_elbow_z')
        set_param([model_name '/Left Elbow Z Polynomial'], 'Coefficients', mat2str(polynomial_inputs.left_elbow_z));
    end
    if isfield(polynomial_inputs, 'right_elbow_z')
        set_param([model_name '/Right Elbow Z Polynomial'], 'Coefficients', mat2str(polynomial_inputs.right_elbow_z));
    end
    
    % Wrist torque polynomials
    if isfield(polynomial_inputs, 'left_wrist_x')
        set_param([model_name '/Left Wrist X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.left_wrist_x));
    end
    if isfield(polynomial_inputs, 'left_wrist_y')
        set_param([model_name '/Left Wrist Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.left_wrist_y));
    end
    
    if isfield(polynomial_inputs, 'right_wrist_x')
        set_param([model_name '/Right Wrist X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.right_wrist_x));
    end
    if isfield(polynomial_inputs, 'right_wrist_y')
        set_param([model_name '/Right Wrist Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.right_wrist_y));
    end
    
    % Translation force polynomials
    if isfield(polynomial_inputs, 'translation_force_x')
        set_param([model_name '/Translation Force X Polynomial'], 'Coefficients', mat2str(polynomial_inputs.translation_force_x));
    end
    if isfield(polynomial_inputs, 'translation_force_y')
        set_param([model_name '/Translation Force Y Polynomial'], 'Coefficients', mat2str(polynomial_inputs.translation_force_y));
    end
    if isfield(polynomial_inputs, 'translation_force_z')
        set_param([model_name '/Translation Force Z Polynomial'], 'Coefficients', mat2str(polynomial_inputs.translation_force_z));
    end
    
    % Swing duration
    if isfield(polynomial_inputs, 'swing_duration')
        set_param(model_name, 'StopTime', num2str(polynomial_inputs.swing_duration));
    end
    
    fprintf('✓ Polynomial parameters updated\n');
    
catch ME
    fprintf('Error updating polynomial parameters: %s\n', ME.message);
    success = false;
    return;
end

%% Update starting position parameters
fprintf('Updating starting position parameters...\n');

try
    % Get model workspace
    model_workspace = get_param(model_name, 'ModelWorkspace');
    
    % Update initial joint positions in model workspace
    if isfield(starting_positions, 'hip_x')
        model_workspace.assignin('initial_hip_x', starting_positions.hip_x);
    end
    if isfield(starting_positions, 'hip_y')
        model_workspace.assignin('initial_hip_y', starting_positions.hip_y);
    end
    if isfield(starting_positions, 'hip_z')
        model_workspace.assignin('initial_hip_z', starting_positions.hip_z);
    end
    if isfield(starting_positions, 'hip_rx')
        model_workspace.assignin('initial_hip_rx', starting_positions.hip_rx);
    end
    if isfield(starting_positions, 'hip_ry')
        model_workspace.assignin('initial_hip_ry', starting_positions.hip_ry);
    end
    if isfield(starting_positions, 'hip_rz')
        model_workspace.assignin('initial_hip_rz', starting_positions.hip_rz);
    end
    
    % Spine and torso
    if isfield(starting_positions, 'spine_rx')
        model_workspace.assignin('initial_spine_rx', starting_positions.spine_rx);
    end
    if isfield(starting_positions, 'spine_ry')
        model_workspace.assignin('initial_spine_ry', starting_positions.spine_ry);
    end
    if isfield(starting_positions, 'torso_rz')
        model_workspace.assignin('initial_torso_rz', starting_positions.torso_rz);
    end
    
    % Left shoulder
    if isfield(starting_positions, 'left_shoulder_x')
        model_workspace.assignin('initial_left_shoulder_x', starting_positions.left_shoulder_x);
    end
    if isfield(starting_positions, 'left_shoulder_y')
        model_workspace.assignin('initial_left_shoulder_y', starting_positions.left_shoulder_y);
    end
    if isfield(starting_positions, 'left_shoulder_z')
        model_workspace.assignin('initial_left_shoulder_z', starting_positions.left_shoulder_z);
    end
    if isfield(starting_positions, 'left_shoulder_rx')
        model_workspace.assignin('initial_left_shoulder_rx', starting_positions.left_shoulder_rx);
    end
    if isfield(starting_positions, 'left_shoulder_ry')
        model_workspace.assignin('initial_left_shoulder_ry', starting_positions.left_shoulder_ry);
    end
    if isfield(starting_positions, 'left_shoulder_rz')
        model_workspace.assignin('initial_left_shoulder_rz', starting_positions.left_shoulder_rz);
    end
    
    % Right shoulder
    if isfield(starting_positions, 'right_shoulder_x')
        model_workspace.assignin('initial_right_shoulder_x', starting_positions.right_shoulder_x);
    end
    if isfield(starting_positions, 'right_shoulder_y')
        model_workspace.assignin('initial_right_shoulder_y', starting_positions.right_shoulder_y);
    end
    if isfield(starting_positions, 'right_shoulder_z')
        model_workspace.assignin('initial_right_shoulder_z', starting_positions.right_shoulder_z);
    end
    if isfield(starting_positions, 'right_shoulder_rx')
        model_workspace.assignin('initial_right_shoulder_rx', starting_positions.right_shoulder_rx);
    end
    if isfield(starting_positions, 'right_shoulder_ry')
        model_workspace.assignin('initial_right_shoulder_ry', starting_positions.right_shoulder_ry);
    end
    if isfield(starting_positions, 'right_shoulder_rz')
        model_workspace.assignin('initial_right_shoulder_rz', starting_positions.right_shoulder_rz);
    end
    
    % Arms and hands (fixed positions)
    if isfield(starting_positions, 'left_elbow_rz')
        model_workspace.assignin('initial_left_elbow_rz', starting_positions.left_elbow_rz);
    end
    if isfield(starting_positions, 'left_forearm_rz')
        model_workspace.assignin('initial_left_forearm_rz', starting_positions.left_forearm_rz);
    end
    if isfield(starting_positions, 'left_wrist_rx')
        model_workspace.assignin('initial_left_wrist_rx', starting_positions.left_wrist_rx);
    end
    if isfield(starting_positions, 'left_wrist_ry')
        model_workspace.assignin('initial_left_wrist_ry', starting_positions.left_wrist_ry);
    end
    
    if isfield(starting_positions, 'right_elbow_rz')
        model_workspace.assignin('initial_right_elbow_rz', starting_positions.right_elbow_rz);
    end
    if isfield(starting_positions, 'right_forearm_rz')
        model_workspace.assignin('initial_right_forearm_rz', starting_positions.right_forearm_rz);
    end
    if isfield(starting_positions, 'right_wrist_rx')
        model_workspace.assignin('initial_right_wrist_rx', starting_positions.right_wrist_rx);
    end
    if isfield(starting_positions, 'right_wrist_ry')
        model_workspace.assignin('initial_right_wrist_ry', starting_positions.right_wrist_ry);
    end
    
    fprintf('✓ Starting position parameters updated\n');
    
catch ME
    fprintf('Error updating starting position parameters: %s\n', ME.message);
    success = false;
    return;
end

%% Verify model is ready for simulation
try
    % Check if model can be compiled
    feval(model_name, [], [], [], 'compile');
    feval(model_name, [], [], [], 'term');
    fprintf('✓ Model compilation successful\n');
    success = true;
    
catch ME
    fprintf('Error during model compilation: %s\n', ME.message);
    success = false;
    return;
end

fprintf('Model parameters updated successfully!\n');

end 