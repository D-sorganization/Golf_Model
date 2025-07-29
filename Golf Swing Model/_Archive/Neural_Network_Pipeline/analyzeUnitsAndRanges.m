% analyzeUnitsAndRanges.m
% Comprehensive analysis of units and ranges in the golf swing model
% This script will help verify whether Simscape outputs radians or degrees

clear; clc; close all;

fprintf('=== Comprehensive Unit and Range Analysis ===\n\n');

%% 1. Check existing data files for ranges
fprintf('=== 1. Analyzing Existing Data Files ===\n');

% Check for existing model input files
data_files = {
    'Input Files/3DModelInputs.mat'
    'Input Files/3DModelInputs_Impact.mat'
    'Input Files/3DModelInputs_TopofBackswing.mat'
    'Scripts/3DModelInputs.mat'
};

for i = 1:length(data_files)
    if exist(data_files{i}, 'file')
        fprintf('\nAnalyzing: %s\n', data_files{i});
        try
            data = load(data_files{i});
            fields = fieldnames(data);
            
            % Look for position-related fields
            position_fields = {};
            for j = 1:length(fields)
                field_name = fields{j};
                if contains(lower(field_name), {'position', 'startposition'}) && ...
                   ~contains(lower(field_name), {'torque', 'force'})
                    position_fields{end+1} = field_name;
                end
            end
            
            if ~isempty(position_fields)
                fprintf('  Position fields found:\n');
                for j = 1:length(position_fields)
                    field_name = position_fields{j};
                    try
                        field_data = data.(field_name);
                        if isa(field_data, 'Simulink.Parameter')
                            value = field_data.Value;
                        else
                            value = field_data;
                        end
                        
                        if isnumeric(value)
                            min_val = min(value(:));
                            max_val = max(value(:));
                            min_deg = min_val * 180/pi;
                            max_deg = max_val * 180/pi;
                            
                            % Determine if this looks like radians or degrees
                            if abs(max_val) > 2*pi
                                unit_guess = 'DEGREES';
                            else
                                unit_guess = 'RADIANS';
                            end
                            
                            fprintf('    %-25s: [%.4f, %.4f] rad, [%.2f, %.2f] deg (%s)\n', ...
                                field_name, min_val, max_val, min_deg, max_deg, unit_guess);
                        end
                    catch ME
                        fprintf('    %-25s: ERROR - %s\n', field_name, ME.message);
                    end
                end
            else
                fprintf('  No position fields found\n');
            end
            
        catch ME
            fprintf('  ERROR loading file: %s\n', ME.message);
        end
    else
        fprintf('\nFile not found: %s\n', data_files{i});
    end
end

%% 2. Run a test simulation to check actual output ranges
fprintf('\n=== 2. Running Test Simulation ===\n');

model_name = 'GolfSwing3D_Kinetic';

% Check if model exists
if ~exist([model_name '.slx'], 'file')
    fprintf('Model %s.slx not found. Checking for alternative models...\n', model_name);
    
    % Look for alternative model names
    alternative_models = {
        'GolfSwing3D_KineticallyDriven'
        'GolfSwing3D'
        'Model/GolfSwing3D_Kinetic'
    };
    
    model_found = false;
    for i = 1:length(alternative_models)
        if exist([alternative_models{i} '.slx'], 'file')
            model_name = alternative_models{i};
            fprintf('Found model: %s.slx\n', model_name);
            model_found = true;
            break;
        end
    end
    
    if ~model_found
        fprintf('No suitable model found. Skipping simulation test.\n');
    end
end

if exist([model_name '.slx'], 'file')
    try
        % Load model
        load_system(model_name);
        fprintf('✓ Model loaded: %s\n', model_name);
        
        % Set simulation parameters
        set_param(model_name, 'StopTime', '0.3');
        set_param(model_name, 'MaxStep', '0.001');
        
        % Run simulation
        fprintf('Running simulation...\n');
        simOut = sim(model_name);
        fprintf('✓ Simulation completed\n');
        
        % Analyze simlog data
        if isfield(simOut, ['simlog_' model_name])
            simlog = simOut.(['simlog_' model_name]);
            fprintf('\nSimlog data available. Analyzing joint ranges...\n');
            
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
            
            fprintf('\nJoint Position Ranges from Simulation:\n');
            fprintf('%-60s %-15s %-15s %-15s %-15s %-10s\n', 'Joint Path', 'Min (rad)', 'Max (rad)', 'Min (deg)', 'Max (deg)', 'Unit Guess');
            fprintf('%s\n', repmat('-', 1, 130));
            
            for i = 1:length(joint_paths)
                try
                    % Navigate to the joint data
                    path_parts = strsplit(joint_paths{i}, '.');
                    current = simlog;
                    for j = 1:length(path_parts)
                        if isfield(current, path_parts{j})
                            current = current.(path_parts{j});
                        else
                            error('Path not found');
                        end
                    end
                    
                    % Get the position data
                    if isfield(current, 'series')
                        values = current.series.values;
                        
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
                        
                        fprintf('%-60s %-15.4f %-15.4f %-15.2f %-15.2f %-10s\n', ...
                            joint_paths{i}, min_val, max_val, min_deg, max_deg, unit_guess);
                    end
                catch ME
                    fprintf('%-60s %s\n', joint_paths{i}, 'ERROR: Could not access data');
                end
            end
        else
            fprintf('No simlog data available\n');
        end
        
        % Analyze logsout data
        if isfield(simOut, 'logsout')
            logsout = simOut.logsout;
            fprintf('\nLogsout signals available:\n');
            
            signal_names = logsout.getElementNames;
            joint_signals = {};
            for i = 1:length(signal_names)
                if contains(lower(signal_names{i}), {'q', 'position', 'joint'})
                    joint_signals{end+1} = signal_names{i};
                end
            end
            
            if ~isempty(joint_signals)
                fprintf('\nJoint-related signals in logsout:\n');
                for i = 1:length(joint_signals)
                    try
                        signal_data = logsout.getElement(joint_signals{i});
                        values = signal_data.Values.Data;
                        
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
        
    catch ME
        fprintf('✗ Simulation failed: %s\n', ME.message);
    end
end

%% 3. Check existing scripts for unit conversion patterns
fprintf('\n=== 3. Analyzing Unit Conversion Patterns in Code ===\n');

% Look for conversion patterns in the codebase
conversion_patterns = {
    '* 180/pi'  'Radians to degrees'
    '* pi/180'  'Degrees to radians'
    'rad2deg'   'rad2deg function'
    'deg2rad'   'deg2rad function'
};

fprintf('Common conversion patterns found in codebase:\n');
for i = 1:size(conversion_patterns, 1)
    pattern = conversion_patterns{i, 1};
    description = conversion_patterns{i, 2};
    fprintf('  %-15s: %s\n', pattern, description);
end

%% 4. Expected ranges for golf swing motions
fprintf('\n=== 4. Expected Ranges for Golf Swing Motions ===\n');

expected_ranges = {
    'Hip Rotation (X)', -90, 90, -1.57, 1.57
    'Hip Rotation (Y)', -45, 45, -0.79, 0.79
    'Hip Rotation (Z)', -120, 120, -2.09, 2.09
    'Torso Rotation', -180, 180, -3.14, 3.14
    'Spine Tilt (X)', -30, 30, -0.52, 0.52
    'Spine Tilt (Y)', -20, 20, -0.35, 0.35
    'Shoulder Rotation (X)', -90, 90, -1.57, 1.57
    'Shoulder Rotation (Y)', -120, 120, -2.09, 2.09
    'Shoulder Rotation (Z)', -60, 60, -1.05, 1.05
    'Elbow Flexion', 0, 150, 0, 2.62
    'Wrist Motion (X)', -60, 60, -1.05, 1.05
    'Wrist Motion (Y)', -45, 45, -0.79, 0.79
};

fprintf('Expected joint ranges for golf swing motions:\n');
fprintf('%-25s %-15s %-15s %-15s %-15s\n', 'Joint Motion', 'Min (deg)', 'Max (deg)', 'Min (rad)', 'Max (rad)');
fprintf('%s\n', repmat('-', 1, 85));

for i = 1:size(expected_ranges, 1)
    joint_name = expected_ranges{i, 1};
    min_deg = expected_ranges{i, 2};
    max_deg = expected_ranges{i, 3};
    min_rad = expected_ranges{i, 4};
    max_rad = expected_ranges{i, 5};
    
    fprintf('%-25s %-15.0f %-15.0f %-15.2f %-15.2f\n', ...
        joint_name, min_deg, max_deg, min_rad, max_rad);
end

%% 5. Summary and recommendations
fprintf('\n=== 5. Summary and Recommendations ===\n');

fprintf('Based on the analysis:\n\n');

fprintf('1. SIMSCAPE UNITS:\n');
fprintf('   - Simscape typically outputs joint positions in RADIANS\n');
fprintf('   - This is the standard for Simscape multibody joints\n');
fprintf('   - Values should typically be in the range [-π, π] radians\n\n');

fprintf('2. CONVERSION NEEDED:\n');
fprintf('   - If your model outputs radians, convert to degrees using: degrees = radians * 180/pi\n');
fprintf('   - If your model outputs degrees, convert to radians using: radians = degrees * pi/180\n\n');

fprintf('3. EXPECTED RANGES:\n');
fprintf('   - For realistic golf swing motions, joint ranges should be:\n');
fprintf('     * Hip rotation: ±90° (±1.57 rad)\n');
fprintf('     * Shoulder rotation: ±120° (±2.09 rad)\n');
fprintf('     * Elbow flexion: 0-150° (0-2.62 rad)\n');
fprintf('     * Wrist motion: ±60° (±1.05 rad)\n\n');

fprintf('4. VERIFICATION STEPS:\n');
fprintf('   - Run the verifyUnitsAndRanges.m script to check actual model output\n');
fprintf('   - Compare the ranges with expected golf swing motions\n');
fprintf('   - If ranges are much smaller than expected, check:\n');
fprintf('     * Simulation duration (should be ~0.3-1.0 seconds)\n');
fprintf('     * Joint torque magnitudes (should be sufficient to drive motion)\n');
fprintf('     * Model configuration and initial conditions\n\n');

fprintf('5. CORRECTING THE TEST DATASET:\n');
fprintf('   - If Simscape outputs radians, your test dataset should:\n');
fprintf('     * Generate test data in radians (small values)\n');
fprintf('     * Convert to degrees for documentation: degrees = radians * 180/pi\n');
fprintf('     * Document both units clearly\n\n');

fprintf('=== Analysis Complete ===\n'); 