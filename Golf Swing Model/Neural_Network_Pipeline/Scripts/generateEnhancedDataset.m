% generateEnhancedDataset.m
% Generates an enhanced golf swing dataset with inertial data included
% for robust neural network training

function generateEnhancedDataset(num_simulations, output_dir, include_inertial)
    % Generate enhanced dataset with inertial data
    %
    % Inputs:
    %   num_simulations - Number of simulations to generate
    %   output_dir - Output directory for dataset files
    %   include_inertial - Boolean to include inertial data (default: true)
    
    if nargin < 3
        include_inertial = true;
    end
    
    if nargin < 2
        output_dir = 'Enhanced_Dataset';
    end
    
    if nargin < 1
        num_simulations = 100;
    end
    
    fprintf('=== Generating Enhanced Golf Swing Dataset ===\n');
    fprintf('Number of simulations: %d\n', num_simulations);
    fprintf('Include inertial data: %s\n', mat2str(include_inertial));
    fprintf('Output directory: %s\n\n', output_dir);
    
    % Create output directory
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
        fprintf('Created output directory: %s\n', output_dir);
    end
    
    % Load the model
    model_name = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end
    fprintf('✓ Model %s loaded\n', model_name);
    
    % Extract segment dimensions if including inertial data
    segment_data = [];
    if include_inertial
        fprintf('\n--- Extracting Segment Dimensions ---\n');
        try
            segment_data = extractSegmentDimensions(model_name);
            fprintf('✓ Successfully extracted segment dimensions\n');
            fprintf('  - Total segments: %d\n', segment_data.summary.num_segments);
            fprintf('  - Total mass: %.2f kg\n', segment_data.summary.total_mass);
        catch ME
            fprintf('✗ Failed to extract segment dimensions: %s\n', ME.message);
            fprintf('Continuing without inertial data...\n');
            include_inertial = false;
        end
    end
    
    % Initialize dataset structure
    dataset = struct();
    dataset.simulations = cell(num_simulations, 1);
    dataset.metadata = struct();
    dataset.metadata.generation_time = datetime('now');
    dataset.metadata.num_simulations = num_simulations;
    dataset.metadata.model_name = model_name;
    dataset.metadata.include_inertial = include_inertial;
    
    if include_inertial
        dataset.metadata.segment_data = segment_data;
    end
    
    % Generate simulations
    fprintf('\n--- Generating Simulations ---\n');
    successful_sims = 0;
    failed_sims = 0;
    
    for i = 1:num_simulations
        fprintf('Generating simulation %d/%d...\n', i, num_simulations);
        
        try
            % Generate simulation data
            sim_data = generateSingleSimulation(model_name, include_inertial, segment_data);
            
            % Add simulation to dataset
            dataset.simulations{i} = sim_data;
            successful_sims = successful_sims + 1;
            
            if mod(i, 10) == 0
                fprintf('  Progress: %d/%d simulations completed\n', i, num_simulations);
            end
            
        catch ME
            fprintf('✗ Failed to generate simulation %d: %s\n', i, ME.message);
            failed_sims = failed_sims + 1;
            
            % Add empty simulation to maintain indexing
            dataset.simulations{i} = struct();
        end
    end
    
    % Update metadata
    dataset.metadata.successful_simulations = successful_sims;
    dataset.metadata.failed_simulations = failed_sims;
    dataset.metadata.success_rate = successful_sims / num_simulations;
    
    % Save dataset
    fprintf('\n--- Saving Dataset ---\n');
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    dataset_filename = sprintf('enhanced_dataset_%dsim_%s.mat', num_simulations, timestamp);
    dataset_path = fullfile(output_dir, dataset_filename);
    
    save(dataset_path, 'dataset', '-v7.3');
    fprintf('✓ Dataset saved: %s\n', dataset_path);
    
    % Generate CSV exports
    fprintf('\n--- Generating CSV Exports ---\n');
    generateCSVExports(dataset, output_dir, timestamp);
    
    % Generate summary report
    fprintf('\n--- Generating Summary Report ---\n');
    generateDatasetSummary(dataset, output_dir, timestamp);
    
    fprintf('\n=== Dataset Generation Complete ===\n');
    fprintf('Successful simulations: %d/%d (%.1f%%)\n', ...
        successful_sims, num_simulations, 100*successful_sims/num_simulations);
    fprintf('Dataset file: %s\n', dataset_path);
end

function sim_data = generateSingleSimulation(model_name, include_inertial, segment_data)
    % Generate a single simulation with enhanced data
    
    % Set up simulation parameters
    sim_time = 0.3;  % seconds
    dt = 0.01;       % time step
    time_points = 0:dt:sim_time;
    
    % Generate random initial conditions (within realistic ranges)
    num_joints = 28;  % Based on current model
    
    % Generate joint positions (in degrees)
    q_init = generateRandomJointPositions(num_joints);
    
    % Generate joint velocities
    qd_init = generateRandomJointVelocities(num_joints);
    
    % Run simulation or generate synthetic data
    % For now, generate synthetic data that mimics real golf swing patterns
    sim_data = generateSyntheticSwingData(time_points, q_init, qd_init, num_joints);
    
    % Add inertial data if requested
    if include_inertial && ~isempty(segment_data)
        sim_data.inertial_data = segment_data;
        
        % Add segment-specific features
        sim_data.segment_features = extractSegmentFeatures(segment_data);
    end
    
    % Add metadata
    sim_data.metadata = struct();
    sim_data.metadata.simulation_time = datetime('now');
    sim_data.metadata.initial_conditions = struct();
    sim_data.metadata.initial_conditions.q = q_init;
    sim_data.metadata.initial_conditions.qd = qd_init;
end

function q_init = generateRandomJointPositions(num_joints)
    % Generate random initial joint positions within realistic ranges
    
    % Define realistic joint ranges (in degrees)
    % These are approximate ranges for golf swing joints
    joint_ranges = [
        % Base joints (0-3)
        -10, 10;    % Base rotation
        -5, 5;      % Base lateral
        -5, 5;      % Base vertical
        -5, 5;      % Base roll
        
        % Hip joints (4-7)
        -20, 20;    % Hip flexion
        -15, 15;    % Hip abduction
        -10, 10;    % Hip rotation
        -5, 5;      % Hip roll
        
        % Spine joints (8-11)
        -30, 30;    % Spine flexion
        -20, 20;    % Spine lateral
        -15, 15;    % Spine rotation
        -10, 10;    % Spine roll
        
        % Torso joints (12-15)
        -20, 20;    % Torso flexion
        -15, 15;    % Torso lateral
        -10, 10;    % Torso rotation
        -5, 5;      % Torso roll
        
        % Left arm joints (16-21)
        -45, 45;    % Left shoulder flexion
        -30, 30;    % Left shoulder abduction
        -30, 30;    % Left shoulder rotation
        -90, 90;    % Left elbow flexion
        -45, 45;    % Left wrist flexion
        -30, 30;    % Left wrist deviation
        
        % Right arm joints (22-27)
        -45, 45;    % Right shoulder flexion
        -30, 30;    % Right shoulder abduction
        -30, 30;    % Right shoulder rotation
        -90, 90;    % Right elbow flexion
        -45, 45;    % Right wrist flexion
        -30, 30;    % Right wrist deviation
    ];
    
    % Ensure we have enough ranges
    if size(joint_ranges, 1) < num_joints
        % Extend with default ranges
        default_range = [-30, 30];
        joint_ranges = [joint_ranges; repmat(default_range, num_joints - size(joint_ranges, 1), 1)];
    end
    
    % Generate random positions within ranges
    q_init = zeros(num_joints, 1);
    for i = 1:num_joints
        range = joint_ranges(i, :);
        q_init(i) = range(1) + (range(2) - range(1)) * rand();
    end
end

function qd_init = generateRandomJointVelocities(num_joints)
    % Generate random initial joint velocities
    % Typically small for golf swing start position
    
    max_velocity = 10;  % degrees/second
    qd_init = (2 * rand(num_joints, 1) - 1) * max_velocity;
end

function sim_data = generateSyntheticSwingData(time_points, q_init, qd_init, num_joints)
    % Generate synthetic golf swing data that mimics real patterns
    
    num_time_points = length(time_points);
    
    % Initialize arrays
    q = zeros(num_joints, num_time_points);
    qd = zeros(num_joints, num_time_points);
    qdd = zeros(num_joints, num_time_points);
    tau = zeros(num_joints, num_time_points);
    
    % Generate smooth trajectories using polynomial interpolation
    for i = 1:num_joints
        % Create target positions for key swing phases
        t_key = [0, 0.1, 0.2, 0.3];  % Key time points
        q_key = [q_init(i), q_init(i) + 20*randn(), q_init(i) + 40*randn(), q_init(i) + 60*randn()];
        
        % Interpolate to get smooth trajectory
        q(i, :) = interp1(t_key, q_key, time_points, 'spline');
        
        % Calculate velocities and accelerations
        qd(i, :) = gradient(q(i, :), time_points);
        qdd(i, :) = gradient(qd(i, :), time_points);
        
        % Generate torques (simplified model)
        tau(i, :) = generateTorqueProfile(time_points, qd(i, :), qdd(i, :));
    end
    
    % Generate midhands position and orientation
    MH = generateMidhandsTrajectory(time_points, q);
    MH_R = generateMidhandsOrientation(time_points, q);
    
    % Store simulation data
    sim_data = struct();
    sim_data.time = time_points';
    sim_data.q = q;
    sim_data.qd = qd;
    sim_data.qdd = qdd;
    sim_data.tau = tau;
    sim_data.MH = MH;
    sim_data.MH_R = MH_R;
    
    % Add signal names
    sim_data.signal_names = generateSignalNames(num_joints);
end

function tau = generateTorqueProfile(time_points, qd, qdd)
    % Generate realistic torque profile based on motion
    
    % Simple proportional-derivative control model
    Kp = 100;  % Position gain
    Kd = 10;   % Velocity gain
    
    % Target trajectory (smooth reference)
    % Use moving average instead of smooth function
    window_size = 5;
    target = movmean(qd, window_size, 'Endpoints', 'shrink');
    
    % Generate torques
    tau = Kp * (target - qd) + Kd * (-qdd);
    
    % Add some realistic noise
    noise_level = 0.1;
    tau = tau + noise_level * std(tau) * randn(size(tau));
end

function MH = generateMidhandsTrajectory(time_points, q)
    % Generate midhands position trajectory based on joint positions
    
    num_time_points = length(time_points);
    MH = zeros(num_time_points, 3);
    
    % Simple forward kinematics approximation
    % In reality, this would be computed from the full kinematic chain
    
    for t = 1:num_time_points
        % Extract relevant joint angles
        q_t = q(:, t);
        
        % Approximate midhands position based on arm joint angles
        % This is a simplified model - real implementation would use full FK
        
        % Base position
        x_base = 0.1;
        y_base = 0.0;
        z_base = 0.8;
        
        % Add contributions from arm joints
        % Right arm joints (assuming indices 22-27)
        right_arm_start = 22;
        if right_arm_start <= length(q_t)
            x_offset = sum(q_t(right_arm_start:end)) * 0.01;
            y_offset = sum(q_t(right_arm_start:end)) * 0.005;
            z_offset = sum(q_t(right_arm_start:end)) * 0.008;
        else
            x_offset = 0; y_offset = 0; z_offset = 0;
        end
        
        % Add swing-specific motion
        swing_phase = time_points(t) / time_points(end);
        swing_x = 0.2 * sin(2*pi*swing_phase);
        swing_y = 0.1 * cos(2*pi*swing_phase);
        swing_z = 0.05 * sin(4*pi*swing_phase);
        
        MH(t, :) = [x_base + x_offset + swing_x, ...
                   y_base + y_offset + swing_y, ...
                   z_base + z_offset + swing_z];
    end
end

function MH_R = generateMidhandsOrientation(time_points, q)
    % Generate midhands orientation matrices
    
    num_time_points = length(time_points);
    MH_R = zeros(3, 3, num_time_points);
    
    for t = 1:num_time_points
        % Generate rotation matrix based on swing phase
        swing_phase = time_points(t) / time_points(end);
        
        % Create rotation around different axes based on swing phase
        angle_x = 0.1 * sin(2*pi*swing_phase);
        angle_y = 0.2 * cos(2*pi*swing_phase);
        angle_z = 0.15 * sin(4*pi*swing_phase);
        
        % Create rotation matrices
        Rx = [1, 0, 0; 0, cos(angle_x), -sin(angle_x); 0, sin(angle_x), cos(angle_x)];
        Ry = [cos(angle_y), 0, sin(angle_y); 0, 1, 0; -sin(angle_y), 0, cos(angle_y)];
        Rz = [cos(angle_z), -sin(angle_z), 0; sin(angle_z), cos(angle_z), 0; 0, 0, 1];
        
        % Combine rotations
        R = Rz * Ry * Rx;
        
        % Ensure it's a valid rotation matrix
        [U, ~, V] = svd(R);
        R_valid = U * V';
        
        MH_R(:, :, t) = R_valid;
    end
end

function signal_names = generateSignalNames(num_joints)
    % Generate signal names for joints
    
    joint_names = {
        'Base_Rot', 'Base_Lat', 'Base_Vert', 'Base_Roll', ...
        'Hip_Flex', 'Hip_Abd', 'Hip_Rot', 'Hip_Roll', ...
        'Spine_Flex', 'Spine_Lat', 'Spine_Rot', 'Spine_Roll', ...
        'Torso_Flex', 'Torso_Lat', 'Torso_Rot', 'Torso_Roll', ...
        'LSh_Flex', 'LSh_Abd', 'LSh_Rot', 'LElbow_Flex', 'LWrist_Flex', 'LWrist_Dev', ...
        'RSh_Flex', 'RSh_Abd', 'RSh_Rot', 'RElbow_Flex', 'RWrist_Flex', 'RWrist_Dev'
    };
    
    % Ensure we have enough names
    if length(joint_names) < num_joints
        for i = length(joint_names)+1:num_joints
            joint_names{i} = sprintf('Joint_%d', i);
        end
    end
    
    signal_names = joint_names(1:num_joints);
end

function segment_features = extractSegmentFeatures(segment_data)
    % Extract segment features for neural network input
    
    fields = fieldnames(segment_data);
    segment_fields = {};
    for i = 1:length(fields)
        field = fields{i};
        if ~any(strcmp(field, {'summary', 'extraction_time', 'model_name', 'units'}))
            segment_fields{end+1} = field;
        end
    end
    
    % Initialize feature vector
    num_segments = length(segment_fields);
    segment_features = struct();
    
    % Extract features for each segment
    for i = 1:num_segments
        segment_name = segment_fields{i};
        segment = segment_data.(segment_name);
        
        % Mass features
        segment_features.([segment_name '_mass']) = segment.mass;
        
        % Length features
        segment_features.([segment_name '_length']) = segment.length;
        
        % COM features (flatten 3D vector)
        com = segment.com;
        segment_features.([segment_name '_com_x']) = com(1);
        segment_features.([segment_name '_com_y']) = com(2);
        segment_features.([segment_name '_com_z']) = com(3);
        
        % Inertia features (flatten 3x3 matrix)
        inertia = segment.inertia;
        segment_features.([segment_name '_inertia_11']) = inertia(1,1);
        segment_features.([segment_name '_inertia_12']) = inertia(1,2);
        segment_features.([segment_name '_inertia_13']) = inertia(1,3);
        segment_features.([segment_name '_inertia_21']) = inertia(2,1);
        segment_features.([segment_name '_inertia_22']) = inertia(2,2);
        segment_features.([segment_name '_inertia_23']) = inertia(2,3);
        segment_features.([segment_name '_inertia_31']) = inertia(3,1);
        segment_features.([segment_name '_inertia_32']) = inertia(3,2);
        segment_features.([segment_name '_inertia_33']) = inertia(3,3);
        
        % Volume and density features
        segment_features.([segment_name '_volume']) = segment.volume;
        segment_features.([segment_name '_density']) = segment.density;
    end
    
    % Add summary features
    summary = segment_data.summary;
    segment_features.total_mass = summary.total_mass;
    segment_features.total_length = summary.total_length;
    segment_features.total_volume = summary.total_volume;
    segment_features.average_mass = summary.average_mass;
    segment_features.average_length = summary.average_length;
end

function generateCSVExports(dataset, output_dir, timestamp)
    % Generate CSV exports of the dataset
    
    fprintf('Generating CSV exports...\n');
    
    % Extract all simulation data
    all_features = [];
    all_targets = [];
    all_times = [];
    all_midhands_pos = [];
    all_midhands_rot = [];
    
    successful_sims = 0;
    for i = 1:length(dataset.simulations)
        sim = dataset.simulations{i};
        if ~isempty(sim) && isfield(sim, 'q')
            successful_sims = successful_sims + 1;
            
            % Extract features (joint positions, velocities, accelerations)
            features = [sim.q; sim.qd; sim.qdd];
            all_features = [all_features, features];
            
            % Extract targets (torques)
            all_targets = [all_targets, sim.tau];
            
            % Extract times
            all_times = [all_times, sim.time'];
            
            % Extract midhands data
            all_midhands_pos = [all_midhands_pos, sim.MH'];
            all_midhands_rot = [all_midhands_rot, reshape(sim.MH_R, 9, [])];
        end
    end
    
    % Save feature data
    features_filename = sprintf('enhanced_features_%dsim_%s.csv', successful_sims, timestamp);
    features_path = fullfile(output_dir, features_filename);
    writematrix(all_features', features_path);
    fprintf('  ✓ Features saved: %s\n', features_path);
    
    % Save target data
    targets_filename = sprintf('enhanced_targets_%dsim_%s.csv', successful_sims, timestamp);
    targets_path = fullfile(output_dir, targets_filename);
    writematrix(all_targets', targets_path);
    fprintf('  ✓ Targets saved: %s\n', targets_path);
    
    % Save midhands data
    midhands_pos_filename = sprintf('enhanced_midhands_pos_%dsim_%s.csv', successful_sims, timestamp);
    midhands_pos_path = fullfile(output_dir, midhands_pos_filename);
    writematrix(all_midhands_pos, midhands_pos_path);
    fprintf('  ✓ Midhands positions saved: %s\n', midhands_pos_path);
    
    midhands_rot_filename = sprintf('enhanced_midhands_rot_%dsim_%s.csv', successful_sims, timestamp);
    midhands_rot_path = fullfile(output_dir, midhands_rot_filename);
    writematrix(all_midhands_rot, midhands_rot_path);
    fprintf('  ✓ Midhands rotations saved: %s\n', midhands_rot_path);
    
    % Save time data
    time_filename = sprintf('enhanced_time_%dsim_%s.csv', successful_sims, timestamp);
    time_path = fullfile(output_dir, time_filename);
    writematrix(all_times, time_path);
    fprintf('  ✓ Time data saved: %s\n', time_path);
end

function generateDatasetSummary(dataset, output_dir, timestamp)
    % Generate a summary report of the dataset
    
    fprintf('Generating dataset summary...\n');
    
    summary_filename = sprintf('enhanced_dataset_summary_%s.txt', timestamp);
    summary_path = fullfile(output_dir, summary_filename);
    
    fid = fopen(summary_path, 'w');
    
    fprintf(fid, '=== Enhanced Golf Swing Dataset Summary ===\n\n');
    fprintf(fid, 'Generation Time: %s\n', datestr(dataset.metadata.generation_time));
    fprintf(fid, 'Model: %s\n', dataset.metadata.model_name);
    fprintf(fid, 'Total Simulations: %d\n', dataset.metadata.num_simulations);
    fprintf(fid, 'Successful Simulations: %d\n', dataset.metadata.successful_simulations);
    fprintf(fid, 'Failed Simulations: %d\n', dataset.metadata.failed_simulations);
    fprintf(fid, 'Success Rate: %.1f%%\n', 100*dataset.metadata.success_rate);
    fprintf(fid, 'Include Inertial Data: %s\n\n', mat2str(dataset.metadata.include_inertial));
    
    if dataset.metadata.include_inertial && isfield(dataset.metadata, 'segment_data')
        segment_data = dataset.metadata.segment_data;
        fprintf(fid, '--- Inertial Data Summary ---\n');
        fprintf(fid, 'Total Segments: %d\n', segment_data.summary.num_segments);
        fprintf(fid, 'Total Mass: %.2f kg\n', segment_data.summary.total_mass);
        fprintf(fid, 'Total Length: %.2f m\n', segment_data.summary.total_length);
        fprintf(fid, 'Total Volume: %.4f m³\n', segment_data.summary.total_volume);
        fprintf(fid, 'Average Mass: %.2f kg\n', segment_data.summary.average_mass);
        fprintf(fid, 'Average Length: %.3f m\n\n', segment_data.summary.average_length);
    end
    
    % Analyze first successful simulation
    for i = 1:length(dataset.simulations)
        sim = dataset.simulations{i};
        if ~isempty(sim) && isfield(sim, 'q')
            fprintf(fid, '--- Sample Simulation Analysis ---\n');
            fprintf(fid, 'Time Points: %d\n', length(sim.time));
            fprintf(fid, 'Time Range: [%.3f, %.3f] seconds\n', sim.time(1), sim.time(end));
            fprintf(fid, 'Number of Joints: %d\n', size(sim.q, 1));
            fprintf(fid, 'Joint Position Range: [%.1f, %.1f] degrees\n', min(sim.q(:)), max(sim.q(:)));
            fprintf(fid, 'Joint Velocity Range: [%.1f, %.1f] deg/s\n', min(sim.qd(:)), max(sim.qd(:)));
            fprintf(fid, 'Joint Acceleration Range: [%.1f, %.1f] deg/s²\n', min(sim.qdd(:)), max(sim.qdd(:)));
            fprintf(fid, 'Torque Range: [%.1f, %.1f] N⋅m\n', min(sim.tau(:)), max(sim.tau(:)));
            
            % Midhands analysis
            fprintf(fid, 'Midhands Position Range:\n');
            fprintf(fid, '  X: [%.3f, %.3f] m\n', min(sim.MH(:,1)), max(sim.MH(:,1)));
            fprintf(fid, '  Y: [%.3f, %.3f] m\n', min(sim.MH(:,2)), max(sim.MH(:,2)));
            fprintf(fid, '  Z: [%.3f, %.3f] m\n', min(sim.MH(:,3)), max(sim.MH(:,3)));
            break;
        end
    end
    
    fprintf(fid, '\n=== End of Summary ===\n');
    fclose(fid);
    
    fprintf('  ✓ Summary saved: %s\n', summary_path);
end 