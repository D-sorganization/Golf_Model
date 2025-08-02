% Debug Animation Parameters
% This script finds the correct animation parameters for the GolfSwing3D_Kinetic model

fprintf('Debugging Animation Parameters for GolfSwing3D_Kinetic...\n');

% Load the model
model_name = 'GolfSwing3D_Kinetic';
try
    if ~bdIsLoaded(model_name)
        load_system(model_name);
        fprintf('✓ Model loaded successfully\n');
    else
        fprintf('✓ Model already loaded\n');
    end
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

% Get all model parameters
fprintf('\n--- All Model Parameters ---\n');
try
    all_params = get_param(model_name, 'ObjectParameters');
    param_names = fieldnames(all_params);
    
    % Look for animation-related parameters
    animation_params = {};
    for i = 1:length(param_names)
        param_name = param_names{i};
        if contains(lower(param_name), 'anim') || contains(lower(param_name), 'display') || contains(lower(param_name), 'visual')
            animation_params{end+1} = param_name;
        end
    end
    
    fprintf('Found %d animation-related parameters:\n', length(animation_params));
    for i = 1:length(animation_params)
        param_name = animation_params{i};
        try
            current_value = get_param(model_name, param_name);
            fprintf('  %s = %s\n', param_name, mat2str(current_value));
        catch
            fprintf('  %s = [error getting value]\n', param_name);
        end
    end
    
    if isempty(animation_params)
        fprintf('No animation-related parameters found. All parameters:\n');
        for i = 1:min(50, length(param_names))  % Show first 50
            fprintf('  %s\n', param_names{i});
        end
        if length(param_names) > 50
            fprintf('  ... and %d more\n', length(param_names) - 50);
        end
    end
    
catch ME
    fprintf('✗ Error getting parameters: %s\n', ME.message);
end

% Test specific animation parameters
fprintf('\n--- Testing Specific Animation Parameters ---\n');

% Test AnimationMode
try
    current_anim_mode = get_param(model_name, 'AnimationMode');
    fprintf('AnimationMode = %s\n', current_anim_mode);
    
    % Try to set it to off
    set_param(model_name, 'AnimationMode', 'off');
    new_anim_mode = get_param(model_name, 'AnimationMode');
    fprintf('After setting AnimationMode to off: %s\n', new_anim_mode);
    
    % Try to set it back
    set_param(model_name, 'AnimationMode', 'on');
    final_anim_mode = get_param(model_name, 'AnimationMode');
    fprintf('After setting AnimationMode to on: %s\n', final_anim_mode);
    
catch ME
    fprintf('✗ AnimationMode test failed: %s\n', ME.message);
end

% Test other potential animation parameters
potential_params = {'AnimationMode', 'ShowAnimation', 'DisplayAnimation', 'VisualAnimation', 'AnimateSimulation'};

for i = 1:length(potential_params)
    param_name = potential_params{i};
    try
        value = get_param(model_name, param_name);
        fprintf('✓ %s = %s\n', param_name, mat2str(value));
    catch ME
        fprintf('✗ %s: %s\n', param_name, ME.message);
    end
end

% Check simulation mode
fprintf('\n--- Current Simulation Mode ---\n');
try
    current_mode = get_param(model_name, 'SimulationMode');
    fprintf('Current SimulationMode = %s\n', current_mode);
    
    % Try to set to normal
    set_param(model_name, 'SimulationMode', 'normal');
    normal_mode = get_param(model_name, 'SimulationMode');
    fprintf('After setting to normal: %s\n', normal_mode);
    
catch ME
    fprintf('✗ SimulationMode test failed: %s\n', ME.message);
end

fprintf('\nDebug completed!\n'); 