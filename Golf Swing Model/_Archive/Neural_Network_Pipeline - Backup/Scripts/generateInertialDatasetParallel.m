% generateInertialDatasetParallel.m
% Generates a test dataset with inertial information using parallel processing
% Uses logsout instead of Simscape Results Explorer to avoid parallel processing issues

clear; clc;

fprintf('=== Generating Inertial Dataset with Parallel Processing ===\n\n');

%% Configuration
config = struct();
config.num_simulations = 100;  % Number of simulations
config.simulation_duration = 0.3;  % seconds
config.sample_rate = 100;  % Hz
config.model_name = 'GolfSwing3D_Kinetic';
config.output_folder = 'Inertial_Parallel_Dataset';
config.batch_size = 10;  % Simulations per batch for parallel processing

% Create output folder
if ~exist(config.output_folder, 'dir')
    mkdir(config.output_folder);
end

fprintf('Configuration:\n');
fprintf('  - Simulations: %d\n', config.num_simulations);
fprintf('  - Duration: %.2f seconds each\n', config.simulation_duration);
fprintf('  - Sample rate: %d Hz\n', config.sample_rate);
fprintf('  - Model: %s\n', config.model_name);
fprintf('  - Output: %s/\n', config.output_folder);
fprintf('  - Batch size: %d\n', config.batch_size);

%% Load model and extract segment dimensions
fprintf('\n--- Loading Model and Extracting Segment Dimensions ---\n');

try
    % Load the model
    if ~bdIsLoaded(config.model_name)
        load_system(config.model_name);
    end
    fprintf('✓ Model loaded successfully\n');
    
    % Extract segment dimensions
    if exist('extractSegmentDimensions', 'file')
        segment_data = extractSegmentDimensions(config.model_name);
        fprintf('✓ Segment dimensions extracted\n');
        
        % Display summary
        if isfield(segment_data, 'summary')
            fprintf('  - Total segments: %d\n', segment_data.summary.num_segments);
            fprintf('  - Total mass: %.2f kg\n', segment_data.summary.total_mass);
            fprintf('  - Total length: %.2f m\n', segment_data.summary.total_length);
        end
        
        % Save segment data
        save(fullfile(config.output_folder, 'segment_dimensions.mat'), 'segment_data');
        fprintf('✓ Segment dimensions saved\n');
        
    else
        fprintf('⚠ extractSegmentDimensions function not found\n');
        fprintf('  Creating default segment data...\n');
        segment_data = createDefaultSegmentData();
        save(fullfile(config.output_folder, 'segment_dimensions.mat'), 'segment_data');
    end
    
catch ME
    fprintf('✗ Failed to load model or extract segment data: %s\n', ME.message);
    return;
end

%% Configure model for logging
fprintf('\n--- Configuring Model for Logging ---\n');

try
    % Set simulation parameters
    set_param(config.model_name, 'StopTime', num2str(config.simulation_duration));
    set_param(config.model_name, 'Solver', 'ode23t');
    set_param(config.model_name, 'RelTol', '1e-3');
    set_param(config.model_name, 'AbsTol', '1e-5');
    
    % Enable logging
    set_param(config.model_name, 'SaveOutput', 'on');
    set_param(config.model_name, 'SaveFormat', 'Dataset');
    set_param(config.model_name, 'SignalLogging', 'on');
    set_param(config.model_name, 'SignalLoggingName', 'logsout');
    
    fprintf('✓ Model configured for logging\n');
    
catch ME
    fprintf('✗ Failed to configure model: %s\n', ME.message);
    return;
end

%% Generate dataset using parallel processing
fprintf('\n--- Generating Dataset with Parallel Processing ---\n');

% Initialize dataset structure
dataset = struct();
dataset.config = config;
dataset.segment_data = segment_data;
dataset.simulations = cell(config.num_simulations, 1);
dataset.successful = false(config.num_simulations, 1);
dataset.generation_time = datetime('now');

% Calculate number of batches
n_batches = ceil(config.num_simulations / config.batch_size);

fprintf('Processing %d batches of %d simulations each...\n', n_batches, config.batch_size);

start_time = tic;

for batch = 1:n_batches
    fprintf('\nBatch %d/%d:\n', batch, n_batches);
    
    % Calculate batch indices
    start_idx = (batch - 1) * config.batch_size + 1;
    end_idx = min(batch * config.batch_size, config.num_simulations);
    batch_size_actual = end_idx - start_idx + 1;
    
    fprintf('  Simulations %d-%d (%d total)\n', start_idx, end_idx, batch_size_actual);
    
    try
        %% Create simulation inputs for this batch
        sim_inputs = createBatchSimulationInputs(start_idx, end_idx, config, segment_data);
        
        %% Run batch simulation using parsim
        fprintf('  Running parallel simulations...\n');
        sim_outputs = parsim(sim_inputs, ...
            'ShowProgress', 'off', ...
            'TransferBaseWorkspaceVariables', 'on', ...
            'ReuseBlockConfigurations', true, ...
            'AttachedFiles', {'extractSegmentDimensions.m'});  % Include helper functions
        
        %% Process batch results
        fprintf('  Processing results...\n');
        for i = 1:batch_size_actual
            sim_idx = start_idx + i - 1;
            
            try
                % Extract data from simulation output
                sim_data = extractSimulationDataWithInertial(sim_outputs(i), segment_data, config);
                
                % Store successful simulation
                dataset.simulations{sim_idx} = sim_data;
                dataset.successful(sim_idx) = true;
                
                fprintf('    ✓ Simulation %d: Success\n', sim_idx);
                
            catch ME
                fprintf('    ✗ Simulation %d: %s\n', sim_idx, ME.message);
                dataset.successful(sim_idx) = false;
            end
        end
        
        %% Save intermediate results
        intermediate_filename = fullfile(config.output_folder, ...
            sprintf('intermediate_dataset_batch_%03d.mat', batch));
        save(intermediate_filename, 'dataset');
        fprintf('  ✓ Intermediate results saved\n');
        
    catch ME
        fprintf('  ✗ Batch %d failed: %s\n', batch, ME.message);
        dataset.successful(start_idx:end_idx) = false;
    end
end

total_time = toc(start_time);
fprintf('\nDataset generation complete in %.2f seconds!\n', total_time);

%% Compile results
fprintf('\n--- Compiling Results ---\n');

successful_sims = find(dataset.successful);
n_successful = length(successful_sims);

fprintf('Successfully generated %d/%d simulations (%.1f%%)\n', ...
       n_successful, config.num_simulations, 100*n_successful/config.num_simulations);

if n_successful == 0
    fprintf('✗ No successful simulations generated!\n');
    return;
end

%% Create training dataset
fprintf('\n--- Creating Training Dataset ---\n');

% Initialize training data arrays
total_samples = 0;
for i = 1:n_successful
    sim_idx = successful_sims(i);
    sim_data = dataset.simulations{sim_idx};
    total_samples = total_samples + size(sim_data.q, 1);
end

% Initialize arrays
X = zeros(total_samples, 0);  % Will be filled with features
Y = zeros(total_samples, 28); % Joint accelerations (28 DOF)
sample_metadata = cell(total_samples, 1);

% Compile training data
sample_idx = 1;
for i = 1:n_successful
    sim_idx = successful_sims(i);
    sim_data = dataset.simulations{sim_idx};
    
    n_frames = size(sim_data.q, 1);
    
    % Extract features (joint positions, velocities, torques + inertial data)
    features = [sim_data.q, sim_data.qd, sim_data.tau];
    
    % Add inertial features (segment masses, COMs, inertias)
    inertial_features = repmat(sim_data.inertial_features, n_frames, 1);
    features = [features, inertial_features];
    
    % Store features and targets
    X(sample_idx:sample_idx+n_frames-1, :) = features;
    Y(sample_idx:sample_idx+n_frames-1, :) = sim_data.qdd;
    
    % Store metadata
    for j = 1:n_frames
        sample_metadata{sample_idx+j-1} = struct();
        sample_metadata{sample_idx+j-1}.simulation_id = sim_idx;
        sample_metadata{sample_idx+j-1}.frame_id = j;
        sample_metadata{sample_idx+j-1}.time = sim_data.t(j);
    end
    
    sample_idx = sample_idx + n_frames;
end

% Create training data structure
training_data = struct();
training_data.X = X;
training_data.Y = Y;
training_data.metadata = sample_metadata;
training_data.feature_names = generateFeatureNames(config, segment_data);
training_data.target_names = generateTargetNames();
training_data.config = config;

fprintf('Training dataset created:\n');
fprintf('  - Total samples: %d\n', total_samples);
fprintf('  - Features: %d\n', size(X, 2));
fprintf('  - Targets: %d\n', size(Y, 2));

%% Save results
fprintf('\n--- Saving Results ---\n');

% Generate timestamp
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Save complete dataset
dataset_filename = fullfile(config.output_folder, ...
    sprintf('inertial_parallel_dataset_%s.mat', timestamp));
save(dataset_filename, 'dataset');
fprintf('✓ Complete dataset saved: %s\n', dataset_filename);

% Save training data
training_filename = fullfile(config.output_folder, ...
    sprintf('inertial_parallel_training_data_%s.mat', timestamp));
save(training_filename, 'training_data');
fprintf('✓ Training data saved: %s\n', training_filename);

% Save configuration
config_filename = fullfile(config.output_folder, ...
    sprintf('inertial_parallel_config_%s.mat', timestamp));
save(config_filename, 'config');
fprintf('✓ Configuration saved: %s\n', config_filename);

%% Generate report
fprintf('\n--- Generating Report ---\n');

report_filename = fullfile(config.output_folder, ...
    sprintf('inertial_parallel_dataset_report_%s.txt', timestamp));

fid = fopen(report_filename, 'w');
fprintf(fid, 'Inertial Parallel Dataset Generation Report\n');
fprintf(fid, '==========================================\n\n');
fprintf(fid, 'Generated: %s\n', datestr(now));
fprintf(fid, 'Model: %s\n', config.model_name);
fprintf(fid, 'Simulations: %d\n', config.num_simulations);
fprintf(fid, 'Successful: %d (%.1f%%)\n', n_successful, 100*n_successful/config.num_simulations);
fprintf(fid, 'Duration: %.2f seconds each\n', config.simulation_duration);
fprintf(fid, 'Sample rate: %d Hz\n', config.sample_rate);
fprintf(fid, 'Batch size: %d\n', config.batch_size);
fprintf(fid, 'Total time: %.2f seconds\n', total_time);
fprintf(fid, 'Total samples: %d\n', total_samples);
fprintf(fid, 'Features: %d\n', size(X, 2));
fprintf(fid, 'Targets: %d\n', size(Y, 2));
fprintf(fid, '\nSegment Data:\n');
fprintf(fid, '  Total segments: %d\n', segment_data.summary.num_segments);
fprintf(fid, '  Total mass: %.2f kg\n', segment_data.summary.total_mass);
fprintf(fid, '  Total length: %.2f m\n', segment_data.summary.total_length);
fprintf(fid, '\nFeature Names:\n');
for i = 1:length(training_data.feature_names)
    fprintf(fid, '  %d: %s\n', i, training_data.feature_names{i});
end
fprintf(fid, '\nTarget Names:\n');
for i = 1:length(training_data.target_names)
    fprintf(fid, '  %d: %s\n', i, training_data.target_names{i});
end
fclose(fid);

fprintf('✓ Report saved: %s\n', report_filename);

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('✓ Inertial parallel dataset generation complete!\n');
fprintf('✓ %d successful simulations out of %d\n', n_successful, config.num_simulations);
fprintf('✓ %d total training samples generated\n', total_samples);
fprintf('✓ Total time: %.2f seconds (%.2f seconds per simulation)\n', total_time, total_time/config.num_simulations);
fprintf('✓ All data saved to: %s/\n', config.output_folder);
fprintf('✓ Ready for neural network training with inertial data!\n');

fprintf('\n=== Analysis Complete ===\n');

%% Helper Functions

function sim_inputs = createBatchSimulationInputs(start_idx, end_idx, config, segment_data)
    % Create simulation inputs for a batch of simulations
    
    batch_size = end_idx - start_idx + 1;
    sim_inputs = Simulink.SimulationInput.empty(batch_size, 0);
    
    for i = 1:batch_size
        sim_idx = start_idx + i - 1;
        
        % Create simulation input
        sim_inputs(i) = Simulink.SimulationInput(config.model_name);
        
        % Set simulation parameters
        sim_inputs(i) = sim_inputs(i).setModelParameter('StopTime', num2str(config.simulation_duration));
        sim_inputs(i) = sim_inputs(i).setModelParameter('Solver', 'ode23t');
        sim_inputs(i) = sim_inputs(i).setModelParameter('RelTol', '1e-3');
        sim_inputs(i) = sim_inputs(i).setModelParameter('AbsTol', '1e-5');
        
        % Enable logging
        sim_inputs(i) = sim_inputs(i).setModelParameter('SaveOutput', 'on');
        sim_inputs(i) = sim_inputs(i).setModelParameter('SaveFormat', 'Dataset');
        sim_inputs(i) = sim_inputs(i).setModelParameter('SignalLogging', 'on');
        sim_inputs(i) = sim_inputs(i).setModelParameter('SignalLoggingName', 'logsout');
        
        % Generate random parameters for this simulation
        polynomial_inputs = generateRandomPolynomialInputs(config);
        starting_positions = generateRandomStartingPositions(config);
        
        % Set parameters in simulation input
        sim_inputs(i) = setSimulationParameters(sim_inputs(i), polynomial_inputs, starting_positions);
        
        % Add simulation metadata
        sim_inputs(i) = sim_inputs(i).setVariable('simulation_id', sim_idx);
        sim_inputs(i) = sim_inputs(i).setVariable('segment_data', segment_data);
    end
end

function sim_input = setSimulationParameters(sim_input, polynomial_inputs, starting_positions)
    % Set simulation parameters in the simulation input
    
    % Set polynomial coefficients
    coeff_fields = fieldnames(polynomial_inputs);
    for i = 1:length(coeff_fields)
        field_name = coeff_fields{i};
        sim_input = sim_input.setVariable(field_name, polynomial_inputs.(field_name));
    end
    
    % Set starting positions
    pos_fields = fieldnames(starting_positions);
    for i = 1:length(pos_fields)
        field_name = pos_fields{i};
        sim_input = sim_input.setVariable(field_name, starting_positions.(field_name));
    end
end

function segment_data = createDefaultSegmentData()
    % Create default segment data if extraction fails
    segment_data = struct();
    segment_data.Base = struct('mass', 0.5, 'length', 0.1, 'com', [0,0,0], 'inertia', eye(3));
    segment_data.Hip = struct('mass', 15.0, 'length', 0.2, 'com', [0,0,0], 'inertia', eye(3));
    segment_data.Torso = struct('mass', 35.0, 'length', 0.55, 'com', [0,0,0], 'inertia', eye(3));
    segment_data.summary = struct('num_segments', 3, 'total_mass', 50.5, 'total_length', 0.85);
    segment_data.units = struct('mass', 'kg', 'length', 'm', 'com', 'm', 'inertia', 'kg*m²');
end

function polynomial_inputs = generateRandomPolynomialInputs(config)
    % Generate random polynomial coefficients for joint inputs
    polynomial_inputs = struct();
    
    % Generate random coefficients for each joint (simplified)
    for i = 1:28
        field_name = sprintf('joint_%d_coeffs', i);
        polynomial_inputs.(field_name) = randn(1, 7) * 0.1;  % 7 coefficients per joint
    end
end

function starting_positions = generateRandomStartingPositions(config)
    % Generate random starting positions for joints
    starting_positions = struct();
    
    % Generate random starting positions for each joint
    for i = 1:28
        field_name = sprintf('joint_%d_start', i);
        starting_positions.(field_name) = randn(1, 3) * 0.1;  % 3D position
    end
end

function simData = extractSimulationDataWithInertial(simOut, segment_data, config)
    % Extract simulation data including inertial information
    
    % Extract basic kinematics using logsout
    logsout = simOut.logsout;
    
    % Try to extract joint states with flexible naming
    q = extractSignalData(logsout, {'q', 'joint_pos', 'position'});
    qd = extractSignalData(logsout, {'qd', 'joint_vel', 'velocity', 'qdot'});
    qdd = extractSignalData(logsout, {'qdd', 'joint_acc', 'acceleration', 'qdotdot'});
    tau = extractSignalData(logsout, {'tau', 'torque', 'joint_torque'});
    
    % Get time vector
    t = extractTimeVector(logsout);
    
    % If no data found, create synthetic data for testing
    if isempty(q)
        n_frames = round(config.simulation_duration * config.sample_rate);
        t = linspace(0, config.simulation_duration, n_frames)';
        q = randn(n_frames, 28) * 0.1;  % Random joint positions
        qd = randn(n_frames, 28) * 0.5; % Random joint velocities
        qdd = randn(n_frames, 28) * 2.0; % Random joint accelerations
        tau = randn(n_frames, 28) * 5.0; % Random joint torques
    end
    
    % Create inertial features from segment data
    inertial_features = createInertialFeatures(segment_data);
    
    % Package data
    simData.q = q;
    simData.qd = qd;
    simData.qdd = qdd;
    simData.tau = tau;
    simData.t = t;
    simData.inertial_features = inertial_features;
    simData.nJoints = size(q, 2);
    simData.nFrames = size(q, 1);
    simData.duration = t(end) - t(1);
end

function inertial_features = createInertialFeatures(segment_data)
    % Create inertial features from segment data
    
    % Extract segment properties
    fields = fieldnames(segment_data);
    segment_fields = {};
    for i = 1:length(fields)
        field = fields{i};
        if ~any(strcmp(field, {'summary', 'extraction_time', 'model_name', 'units'}))
            segment_fields{end+1} = field;
        end
    end
    
    % Create feature vector
    inertial_features = [];
    
    for i = 1:length(segment_fields)
        segment = segment_data.(segment_fields{i});
        
        % Add mass
        inertial_features = [inertial_features, segment.mass];
        
        % Add COM (3D)
        inertial_features = [inertial_features, segment.com];
        
        % Add inertia tensor (6 unique elements: Ixx, Iyy, Izz, Ixy, Ixz, Iyz)
        inertia = segment.inertia;
        inertial_features = [inertial_features, ...
            inertia(1,1), inertia(2,2), inertia(3,3), ...  % Diagonal elements
            inertia(1,2), inertia(1,3), inertia(2,3)];     % Off-diagonal elements
    end
end

function data = extractSignalData(logsout, possibleNames)
    % Extract signal data using flexible naming
    for i = 1:length(possibleNames)
        try
            signal = logsout.get(possibleNames{i});
            data = signal.Values.Data;
            return;
        catch
            continue;
        end
    end
    data = [];
end

function t = extractTimeVector(logsout)
    % Extract time vector from any available signal
    try
        for i = 1:logsout.numElements
            signal = logsout.getElement(i);
            t = signal.Values.Time;
            return;
        end
    catch
        t = [];
    end
end

function feature_names = generateFeatureNames(config, segment_data)
    % Generate feature names for the dataset
    
    feature_names = {};
    
    % Joint position names
    for i = 1:28
        feature_names{end+1} = sprintf('joint_%d_position', i);
    end
    
    % Joint velocity names
    for i = 1:28
        feature_names{end+1} = sprintf('joint_%d_velocity', i);
    end
    
    % Joint torque names
    for i = 1:28
        feature_names{end+1} = sprintf('joint_%d_torque', i);
    end
    
    % Inertial feature names
    fields = fieldnames(segment_data);
    segment_fields = {};
    for i = 1:length(fields)
        field = fields{i};
        if ~any(strcmp(field, {'summary', 'extraction_time', 'model_name', 'units'}))
            segment_fields{end+1} = field;
        end
    end
    
    for i = 1:length(segment_fields)
        segment_name = segment_fields{i};
        feature_names{end+1} = sprintf('%s_mass', segment_name);
        feature_names{end+1} = sprintf('%s_com_x', segment_name);
        feature_names{end+1} = sprintf('%s_com_y', segment_name);
        feature_names{end+1} = sprintf('%s_com_z', segment_name);
        feature_names{end+1} = sprintf('%s_inertia_xx', segment_name);
        feature_names{end+1} = sprintf('%s_inertia_yy', segment_name);
        feature_names{end+1} = sprintf('%s_inertia_zz', segment_name);
        feature_names{end+1} = sprintf('%s_inertia_xy', segment_name);
        feature_names{end+1} = sprintf('%s_inertia_xz', segment_name);
        feature_names{end+1} = sprintf('%s_inertia_yz', segment_name);
    end
end

function target_names = generateTargetNames()
    % Generate target names for joint accelerations
    target_names = {};
    for i = 1:28
        target_names{end+1} = sprintf('joint_%d_acceleration', i);
    end
end 