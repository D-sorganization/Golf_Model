% Test Animation Fallback for Licenses Without Accelerator Mode
% This script tests the fallback logic when accelerator mode is not available

fprintf('Testing Animation Fallback Logic...\n');

% Test 1: Check if model can be loaded
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

% Test 2: Test the fallback logic (simulate license limitation)
fprintf('\n--- Testing Fallback Logic ---\n');

% Simulate animation disabled scenario
enable_animation = false;
fprintf('Animation setting: %s\n', mat2str(enable_animation));

try
    if ~enable_animation
        % Try accelerator mode first, but fall back to normal if not available
        try
            set_param(model_name, 'SimulationMode', 'accelerator');
            current_mode = get_param(model_name, 'SimulationMode');
            if strcmp(current_mode, 'accelerator')
                fprintf('✓ Accelerator mode set successfully (no animation)\n');
            else
                fprintf('⚠ Accelerator mode requested but got: %s\n', current_mode);
            end
        catch ME
            % Fall back to normal mode but disable animation display
            fprintf('⚠ Accelerator mode failed, falling back to normal mode\n');
            set_param(model_name, 'SimulationMode', 'normal');
            % Disable animation display in normal mode
            set_param(model_name, 'AnimationMode', 'off');
            current_mode = get_param(model_name, 'SimulationMode');
            anim_mode = get_param(model_name, 'AnimationMode');
            fprintf('✓ Fallback successful: Mode=%s, Animation=%s\n', current_mode, anim_mode);
        end
    else
        % Use normal mode for animation
        set_param(model_name, 'SimulationMode', 'normal');
        % Enable animation display
        set_param(model_name, 'AnimationMode', 'on');
        current_mode = get_param(model_name, 'SimulationMode');
        anim_mode = get_param(model_name, 'AnimationMode');
        fprintf('✓ Animation enabled: Mode=%s, Animation=%s\n', current_mode, anim_mode);
    end
catch ME
    fprintf('✗ Error in fallback logic: %s\n', ME.message);
end

% Test 3: Test animation enabled scenario
fprintf('\n--- Testing Animation Enabled ---\n');
enable_animation = true;
fprintf('Animation setting: %s\n', mat2str(enable_animation));

try
    if ~enable_animation
        % This should not execute
        fprintf('⚠ Unexpected: Animation should be enabled\n');
    else
        % Use normal mode for animation
        set_param(model_name, 'SimulationMode', 'normal');
        % Enable animation display
        set_param(model_name, 'AnimationMode', 'on');
        current_mode = get_param(model_name, 'SimulationMode');
        anim_mode = get_param(model_name, 'AnimationMode');
        fprintf('✓ Animation enabled: Mode=%s, Animation=%s\n', current_mode, anim_mode);
    end
catch ME
    fprintf('✗ Error in animation enabled logic: %s\n', ME.message);
end

fprintf('\nAnimation fallback test completed!\n');
fprintf('If the fallback logic works, you should see:\n');
fprintf('- Either accelerator mode success OR fallback to normal mode with animation off\n');
fprintf('- Animation mode properly controlled in both scenarios\n'); 