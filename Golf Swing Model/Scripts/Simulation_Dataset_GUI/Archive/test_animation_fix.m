% Test Animation Fix for Golf Swing Data Generator
% This script tests that the animation control works properly with license limitations

fprintf('Testing Animation Control Fix...\n');

% Test 1: Check if the actual working script exists
working_script = 'Golf Swing Model/Scripts/Simulation_Dataset_GUI/Data_GUI.m';
if exist(working_script, 'file')
    fprintf('✓ Found working script: %s\n', working_script);
else
    fprintf('✗ Working script not found: %s\n', working_script);
    return;
end

% Test 2: Check if setModelParameters.m has the fix
set_params_script = 'Golf Swing Model/Scripts/Simulation_Dataset_GUI/setModelParameters.m';
if exist(set_params_script, 'file')
    fprintf('✓ Found setModelParameters.m\n');
    
    % Check if the fix is in place
    fid = fopen(set_params_script, 'r');
    if fid ~= -1
        content = fread(fid, '*char')';
        fclose(fid);
        
        if contains(content, 'AnimationMode') && contains(content, 'accelerator mode not available')
            fprintf('✓ Animation control fix is in place\n');
        else
            fprintf('✗ Animation control fix not found in setModelParameters.m\n');
        end
    end
else
    fprintf('✗ setModelParameters.m not found\n');
end

% Test 3: Check if extractFromCombinedSignalBus.m handles 1x1 matrices
extract_script = 'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractFromCombinedSignalBus.m';
if exist(extract_script, 'file')
    fprintf('✓ Found extractFromCombinedSignalBus.m\n');
    
    % Check if 1x1 matrix handling is in place
    fid = fopen(extract_script, 'r');
    if fid ~= -1
        content = fread(fid, '*char')';
        fclose(fid);
        
        if contains(content, 'num_elements == 1') && contains(content, 'scalar value')
            fprintf('✓ 1x1 matrix handling is in place\n');
        else
            fprintf('✗ 1x1 matrix handling not found\n');
        end
    end
else
    fprintf('✗ extractFromCombinedSignalBus.m not found\n');
end

% Test 4: Check if model can be loaded
model_name = 'GolfSwing3D_Kinetic';
try
    if ~bdIsLoaded(model_name)
        load_system(model_name);
        fprintf('✓ Model loaded successfully\n');
    else
        fprintf('✓ Model already loaded\n');
    end
    
    % Test animation control
    fprintf('\n--- Testing Animation Control ---\n');
    
    % Test accelerator mode (should fail gracefully)
    try
        set_param(model_name, 'SimulationMode', 'accelerator');
        current_mode = get_param(model_name, 'SimulationMode');
        if strcmp(current_mode, 'accelerator')
            fprintf('✓ Accelerator mode works (license supports it)\n');
        else
            fprintf('⚠ Accelerator mode not available (expected for your license)\n');
        end
    catch ME
        fprintf('⚠ Accelerator mode failed (expected): %s\n', ME.message);
    end
    
    % Test normal mode with animation off
    try
        set_param(model_name, 'SimulationMode', 'normal');
        set_param(model_name, 'AnimationMode', 'off');
        fprintf('✓ Normal mode with animation off works\n');
    catch ME
        fprintf('⚠ Animation control failed: %s\n', ME.message);
    end
    
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
end

fprintf('\nTest completed!\n');
fprintf('\nTo run the actual GUI, use:\n');
fprintf('cd(''Golf Swing Model/Scripts/Simulation_Dataset_GUI'')\n');
fprintf('Data_GUI\n'); 