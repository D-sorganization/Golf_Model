% Comprehensive Animation Control Fix
% This script tries multiple approaches to disable animation

function disableAnimation(model_name)
    % Try multiple approaches to disable animation
    
    fprintf('Attempting to disable animation for %s...\n', model_name);
    
    % Approach 1: Set SimulationMode to accelerator (if available)
    try
        set_param(model_name, 'SimulationMode', 'accelerator');
        current_mode = get_param(model_name, 'SimulationMode');
        if strcmp(current_mode, 'accelerator')
            fprintf('✓ Success: Using accelerator mode (no animation)\n');
            return;
        else
            fprintf('⚠ Accelerator mode not available, trying other approaches...\n');
        end
    catch ME
        fprintf('⚠ Accelerator mode failed: %s\n', ME.message);
    end
    
    % Approach 2: Set to normal mode and try to disable animation display
    try
        set_param(model_name, 'SimulationMode', 'normal');
        fprintf('✓ Set to normal mode\n');
        
        % Try various animation parameters
        animation_params = {
            'AnimationMode', 'off';
            'ShowAnimation', 'off';
            'DisplayAnimation', 'off';
            'VisualAnimation', 'off';
            'AnimateSimulation', 'off';
            'Animation', 'off';
            'ShowSimulationAnimation', 'off';
            'EnableAnimation', 'off';
            'SimulationAnimation', 'off'
        };
        
        for i = 1:size(animation_params, 1)
            param_name = animation_params{i, 1};
            param_value = animation_params{i, 2};
            
            try
                set_param(model_name, param_name, param_value);
                fprintf('✓ Set %s = %s\n', param_name, param_value);
            catch ME
                % Parameter doesn't exist, that's okay
            end
        end
        
    catch ME
        fprintf('✗ Error setting normal mode: %s\n', ME.message);
    end
    
    % Approach 3: Try to disable Simscape animation specifically
    try
        % Look for Simscape blocks and disable their animation
        simscape_blocks = find_system(model_name, 'BlockType', 'SimscapeBlock');
        if ~isempty(simscape_blocks)
            fprintf('Found %d Simscape blocks, attempting to disable animation...\n', length(simscape_blocks));
            
            for i = 1:length(simscape_blocks)
                block_path = simscape_blocks{i};
                try
                    % Try to set animation parameters on Simscape blocks
                    set_param(block_path, 'AnimationMode', 'off');
                    fprintf('✓ Disabled animation for Simscape block: %s\n', block_path);
                catch ME
                    % Block doesn't support this parameter
                end
            end
        end
    catch ME
        fprintf('⚠ Error with Simscape blocks: %s\n', ME.message);
    end
    
    % Approach 4: Try to set simulation parameters that might disable animation
    try
        % Set parameters that might help
        set_param(model_name, 'SolverType', 'Fixed-step');
        set_param(model_name, 'FixedStep', '0.001');
        fprintf('✓ Set fixed-step solver (may reduce animation)\n');
    catch ME
        fprintf('⚠ Error setting solver: %s\n', ME.message);
    end
    
    fprintf('Animation control attempts completed.\n');
end

function enableAnimation(model_name)
    % Enable animation for debugging/visualization
    
    fprintf('Enabling animation for %s...\n', model_name);
    
    try
        set_param(model_name, 'SimulationMode', 'normal');
        fprintf('✓ Set to normal mode\n');
        
        % Try to enable animation parameters
        animation_params = {
            'AnimationMode', 'on';
            'ShowAnimation', 'on';
            'DisplayAnimation', 'on';
            'VisualAnimation', 'on';
            'AnimateSimulation', 'on';
            'Animation', 'on';
            'ShowSimulationAnimation', 'on';
            'EnableAnimation', 'on';
            'SimulationAnimation', 'on'
        };
        
        for i = 1:size(animation_params, 1)
            param_name = animation_params{i, 1};
            param_value = animation_params{i, 2};
            
            try
                set_param(model_name, param_name, param_value);
                fprintf('✓ Set %s = %s\n', param_name, param_value);
            catch ME
                % Parameter doesn't exist, that's okay
            end
        end
        
    catch ME
        fprintf('✗ Error enabling animation: %s\n', ME.message);
    end
    
    fprintf('Animation enabled.\n');
end

% Test the functions
fprintf('=== Animation Control Test ===\n');

model_name = 'GolfSwing3D_Kinetic';

% Load model
try
    if ~bdIsLoaded(model_name)
        load_system(model_name);
        fprintf('✓ Model loaded\n');
    end
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

% Test disable animation
fprintf('\n--- Testing Disable Animation ---\n');
disableAnimation(model_name);

% Test enable animation
fprintf('\n--- Testing Enable Animation ---\n');
enableAnimation(model_name);

fprintf('\nTest completed!\n'); 