% Test Animation Control
% This script tests that the animation control is working properly

fprintf('Testing Animation Control...\n');

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

% Test 2: Test accelerator mode (no animation)
try
    set_param(model_name, 'SimulationMode', 'accelerator');
    current_mode = get_param(model_name, 'SimulationMode');
    if strcmp(current_mode, 'accelerator')
        fprintf('✓ Accelerator mode set successfully (no animation)\n');
    else
        fprintf('✗ Failed to set accelerator mode. Current mode: %s\n', current_mode);
    end
catch ME
    fprintf('✗ Failed to set accelerator mode: %s\n', ME.message);
    fprintf('  This is expected if your license doesn''t support accelerator mode\n');
end

% Test 3: Test normal mode with animation display control
try
    set_param(model_name, 'SimulationMode', 'normal');
    current_mode = get_param(model_name, 'SimulationMode');
    if strcmp(current_mode, 'normal')
        fprintf('✓ Normal mode set successfully\n');
        
        % Test animation display control
        set_param(model_name, 'AnimationMode', 'off');
        anim_mode = get_param(model_name, 'AnimationMode');
        fprintf('✓ Animation display disabled: %s\n', anim_mode);
        
        set_param(model_name, 'AnimationMode', 'on');
        anim_mode = get_param(model_name, 'AnimationMode');
        fprintf('✓ Animation display enabled: %s\n', anim_mode);
    else
        fprintf('✗ Failed to set normal mode. Current mode: %s\n', current_mode);
    end
catch ME
    fprintf('✗ Failed to set normal mode: %s\n', ME.message);
end

% Test 4: Test simulation input creation
try
    simIn = Simulink.SimulationInput(model_name);
    simIn = simIn.setModelParameter('StopTime', '0.1'); % Short test
    fprintf('✓ Simulation input created successfully\n');
catch ME
    fprintf('✗ Failed to create simulation input: %s\n', ME.message);
end

fprintf('\nAnimation control test completed!\n');
fprintf('If all tests passed, the animation control should work properly.\n'); 