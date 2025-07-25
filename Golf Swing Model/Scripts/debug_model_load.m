% debug_model_load.m
% Debug script to test model loading and basic simulation

clear; clc;

fprintf('=== Debugging Model Load and Basic Simulation ===\n\n');

model_name = 'GolfSwing3D_Kinetic';

% Test 1: Check if model file exists
fprintf('--- Test 1: Check Model File ---\n');
model_file = [model_name, '.slx'];
if exist(model_file, 'file')
    fprintf('✓ Model file exists: %s\n', model_file);
else
    fprintf('✗ Model file not found: %s\n', model_file);
    
    % Check for .mdl file
    mdl_file = [model_name, '.mdl'];
    if exist(mdl_file, 'file')
        fprintf('✓ Found .mdl file: %s\n', mdl_file);
        model_name = mdl_file(1:end-4); % Remove .mdl extension
    else
        fprintf('✗ No .mdl file found either\n');
        return;
    end
end

% Test 2: Try to load the model
fprintf('\n--- Test 2: Load Model ---\n');
try
    load_system(model_name);
    fprintf('✓ Model loaded successfully\n');
    
    % Check model parameters
    fprintf('  Model parameters:\n');
    fprintf('    StopTime: %s\n', get_param(model_name, 'StopTime'));
    fprintf('    Solver: %s\n', get_param(model_name, 'Solver'));
    fprintf('    SignalLogging: %s\n', get_param(model_name, 'SignalLogging'));
    
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

% Test 3: Check for ModelingMode variable
fprintf('\n--- Test 3: Check ModelingMode Variable ---\n');
try
    model_workspace = get_param(model_name, 'ModelWorkspace');
    if model_workspace.hasVariable('ModelingMode')
        modeling_mode = model_workspace.getVariable('ModelingMode');
        fprintf('✓ ModelingMode found: %d\n', modeling_mode);
    else
        fprintf('⚠ ModelingMode not found in model workspace\n');
    end
catch ME
    fprintf('✗ Error checking ModelingMode: %s\n', ME.message);
end

% Test 4: Check for polynomial coefficient variables
fprintf('\n--- Test 4: Check Polynomial Coefficients ---\n');
try
    workspace_vars = model_workspace.whos;
    coeff_vars = {};
    
    for i = 1:length(workspace_vars)
        var_name = workspace_vars(i).name;
        if contains(var_name, 'Input') && (contains(var_name, 'A') || contains(var_name, 'B') || contains(var_name, 'C') || contains(var_name, 'D') || contains(var_name, 'E') || contains(var_name, 'F') || contains(var_name, 'G'))
            coeff_vars{end+1} = var_name;
        end
    end
    
    fprintf('Found %d polynomial coefficient variables\n', length(coeff_vars));
    if length(coeff_vars) > 0
        fprintf('First 10 coefficients:\n');
        for i = 1:min(10, length(coeff_vars))
            fprintf('  %s\n', coeff_vars{i});
        end
    end
    
catch ME
    fprintf('✗ Error checking polynomial coefficients: %s\n', ME.message);
end

% Test 5: Try a simple simulation
fprintf('\n--- Test 5: Simple Simulation Test ---\n');
try
    % Create a simple simulation input
    simInput = Simulink.SimulationInput(model_name);
    simInput = simInput.setModelParameter('StopTime', '0.1'); % Very short simulation
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    
    fprintf('Running simple simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Simple simulation completed\n');
    
    % Check output
    fprintf('  Simulation output fields:\n');
    output_fields = fieldnames(simOut);
    for i = 1:length(output_fields)
        fprintf('    - %s\n', output_fields{i});
    end
    
    % Check for errors
    if isfield(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
        fprintf('  ⚠ Simulation error: %s\n', simOut.ErrorMessage);
    end
    
    % Check time vector
    if isfield(simOut, 'tout')
        fprintf('  Time vector length: %d\n', length(simOut.tout));
        if ~isempty(simOut.tout)
            fprintf('  Time range: %.3f to %.3f seconds\n', simOut.tout(1), simOut.tout(end));
        end
    else
        fprintf('  ⚠ No time vector (tout) found\n');
    end
    
    % Check logsout
    if isfield(simOut, 'logsout')
        fprintf('  Logsout available: ✓\n');
        if ~isempty(simOut.logsout)
            fprintf('  Logsout elements: %d\n', simOut.logsout.numElements);
        else
            fprintf('  ⚠ Logsout is empty\n');
        end
    else
        fprintf('  ⚠ No logsout found\n');
    end
    
catch ME
    fprintf('✗ Simple simulation failed: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

% Test 6: Check model blocks
fprintf('\n--- Test 6: Check Model Blocks ---\n');
try
    % Get all blocks in the model
    all_blocks = find_system(model_name, 'FollowLinks', 'on', 'LookUnderMasks', 'on');
    fprintf('Total blocks in model: %d\n', length(all_blocks));
    
    % Check for specific block types
    block_types = {'ToWorkspace', 'Scope', 'Outport', 'SimulinkFunction'};
    for i = 1:length(block_types)
        blocks = find_system(model_name, 'BlockType', block_types{i});
        fprintf('  %s blocks: %d\n', block_types{i}, length(blocks));
    end
    
    % Check for function blocks (polynomial input functions)
    function_blocks = find_system(model_name, 'BlockType', 'SubSystem');
    fprintf('  SubSystem blocks: %d\n', length(function_blocks));
    
catch ME
    fprintf('✗ Error checking model blocks: %s\n', ME.message);
end

% Cleanup
try
    close_system(model_name, 0);
    fprintf('\n✓ Model closed\n');
catch
    fprintf('\n⚠ Could not close model\n');
end

fprintf('\n=== Debug Complete ===\n'); 