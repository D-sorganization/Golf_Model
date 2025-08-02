% verifyUnitsAndRanges.m
% Script to verify the actual units and ranges from Simulink model output
% This will help determine if Simscape outputs radians or degrees

clear; clc; close all;

fprintf('=== Unit and Range Verification for Simulink Model ===\n\n');

%% Load and configure model
model_name = 'GolfSwing3D_Kinetic';

try
    load_system(model_name);
    fprintf('✓ Model loaded successfully: %s\n', model_name);
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

%% Set up simulation parameters
sim_duration = 0.5; % Short simulation to check ranges
set_param(model_name, 'StopTime', num2str(sim_duration));

%% Run a test simulation
fprintf('\nRunning test simulation...\n');
try
    simOut = sim(model_name);
    fprintf('✓ Simulation completed successfully\n');
catch ME
    fprintf('✗ Simulation failed: %s\n', ME.message);
    return;
end

%% Extract joint data from simulation
fprintf('\n=== Analyzing Joint Data ===\n');

% Get simlog data if available
if isfield(simOut, 'simlog_GolfSwing3D_Kinetic')
    simlog = simOut.simlog_GolfSwing3D_Kinetic;
    fprintf('✓ Simlog data available\n');
    
    % Define joint paths to check
    joint_paths = {
        'Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rx.q'
        'Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Ry.q'
        'Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rz.q'
        'Hips_and_Torso_Inputs.Torso_Kinetically_Driven.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
        'Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.q'
        'Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.q'
        'Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.q'
        'Left_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.q'
    };
    
    fprintf('\nJoint Position Ranges (from Simlog):\n');
    fprintf('%-50s %-15s %-15s %-15s %-15s\n', 'Joint Path', 'Min (rad)', 'Max (rad)', 'Min (deg)', 'Max (deg)');
    fprintf('%s\n', repmat('-', 1, 110));
    
    for i = 1:length(joint_paths)
        try
            % Navigate to the joint data
            path_parts = strsplit(joint_paths{i}, '.');
            current = simlog;
            for j = 1:length(path_parts)
                current = current.(path_parts{j});
            end
            
            % Get the position data
            if isfield(current, 'series')
                values = current.series.values;
                time = current.series.time;
                
                % Calculate ranges
                min_val = min(values);
                max_val = max(values);
                min_deg = min_val * 180/pi;
                max_deg = max_val * 180/pi;
                
                % Determine if this looks like radians or degrees
                if abs(max_val) > 2*pi
                    unit_guess = 'DEGREES';
                else
                    unit_guess = 'RADIANS';
                end
                
                fprintf('%-50s %-15.4f %-15.4f %-15.2f %-15.2f %s\n', ...
                    joint_paths{i}, min_val, max_val, min_deg, max_deg, unit_guess);
            end
        catch ME
            fprintf('%-50s %s\n', joint_paths{i}, 'ERROR: Could not access data');
        end
    end
    
else
    fprintf('✗ No simlog data available\n');
end

%% Check logsout data if available
if isfield(simOut, 'logsout')
    logsout = simOut.logsout;
    fprintf('\n=== Logsout Data Analysis ===\n');
    
    % List available signals
    signal_names = logsout.getElementNames;
    fprintf('Available signals in logsout:\n');
    for i = 1:length(signal_names)
        fprintf('  %s\n', signal_names{i});
    end
    
    % Look for joint-related signals
    joint_signals = {};
    for i = 1:length(signal_names)
        if contains(lower(signal_names{i}), {'q', 'position', 'joint'})
            joint_signals{end+1} = signal_names{i};
        end
    end
    
    if ~isempty(joint_signals)
        fprintf('\nJoint-related signals found:\n');
        for i = 1:length(joint_signals)
            try
                signal_data = logsout.getElement(joint_signals{i});
                values = signal_data.Values.Data;
                time = signal_data.Values.Time;
                
                % Calculate ranges
                min_val = min(values(:));
                max_val = max(values(:));
                min_deg = min_val * 180/pi;
                max_deg = max_val * 180/pi;
                
                % Determine if this looks like radians or degrees
                if abs(max_val) > 2*pi
                    unit_guess = 'DEGREES';
                else
                    unit_guess = 'RADIANS';
                end
                
                fprintf('  %-30s: [%.4f, %.4f] rad, [%.2f, %.2f] deg (%s)\n', ...
                    joint_signals{i}, min_val, max_val, min_deg, max_deg, unit_guess);
            catch ME
                fprintf('  %-30s: ERROR - %s\n', joint_signals{i}, ME.message);
            end
        end
    end
end

%% Check workspace variables
fprintf('\n=== Workspace Variable Analysis ===\n');
workspace_vars = who;
joint_vars = {};
for i = 1:length(workspace_vars)
    var_name = workspace_vars{i};
    if contains(lower(var_name), {'q', 'position', 'joint', 'hip', 'shoulder', 'elbow'})
        joint_vars{end+1} = var_name;
    end
end

if ~isempty(joint_vars)
    fprintf('Joint-related workspace variables:\n');
    for i = 1:length(joint_vars)
        try
            var_data = eval(joint_vars{i});
            if isnumeric(var_data)
                min_val = min(var_data(:));
                max_val = max(var_data(:));
                min_deg = min_val * 180/pi;
                max_deg = max_val * 180/pi;
                
                % Determine if this looks like radians or degrees
                if abs(max_val) > 2*pi
                    unit_guess = 'DEGREES';
                else
                    unit_guess = 'RADIANS';
                end
                
                fprintf('  %-20s: [%.4f, %.4f] rad, [%.2f, %.2f] deg (%s)\n', ...
                    joint_vars{i}, min_val, max_val, min_deg, max_deg, unit_guess);
            end
        catch ME
            fprintf('  %-20s: ERROR - %s\n', joint_vars{i}, ME.message);
        end
    end
end

%% Summary and recommendations
fprintf('\n=== Summary and Recommendations ===\n');
fprintf('Based on the analysis above:\n');
fprintf('1. If joint values are typically in the range [-π, π] radians, then Simscape outputs RADIANS\n');
fprintf('2. If joint values are typically in the range [-180, 180] degrees, then Simscape outputs DEGREES\n');
fprintf('3. For golf swing motions, typical ranges should be:\n');
fprintf('   - Hip rotation: ±90 degrees (±1.57 radians)\n');
fprintf('   - Shoulder rotation: ±120 degrees (±2.09 radians)\n');
fprintf('   - Elbow flexion: 0-150 degrees (0-2.62 radians)\n');
fprintf('   - Wrist motion: ±60 degrees (±1.05 radians)\n');
fprintf('\n4. If the ranges are much smaller than expected, check:\n');
fprintf('   - Whether the simulation ran long enough\n');
fprintf('   - Whether the joint torques are sufficient\n');
fprintf('   - Whether the model is properly configured\n');

%% Test conversion functions
fprintf('\n=== Testing Conversion Functions ===\n');

% Test with known values
test_radians = [0, pi/6, pi/4, pi/3, pi/2, pi, 2*pi];
test_degrees = test_radians * 180/pi;

fprintf('Radians to Degrees conversion test:\n');
for i = 1:length(test_radians)
    fprintf('  %.4f rad = %.2f deg\n', test_radians(i), test_degrees(i));
end

fprintf('\nDegrees to Radians conversion test:\n');
for i = 1:length(test_degrees)
    fprintf('  %.2f deg = %.4f rad\n', test_degrees(i), test_degrees(i) * pi/180);
end

fprintf('\n=== Verification Complete ===\n'); 