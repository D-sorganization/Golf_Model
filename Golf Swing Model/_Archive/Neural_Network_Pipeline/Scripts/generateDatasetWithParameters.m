% generateDatasetWithParameters.m
% Generates comprehensive datasets with full parameter documentation
% Manages storage efficiently with options for data reduction

clear; clc;

fprintf('=== Golf Swing Dataset Generator with Parameter Documentation ===\n\n');

%% Configuration
config = struct();

% Dataset parameters
config.num_simulations = 1000;
config.simulation_duration = 10; % seconds
config.sample_rate = 1000; % Hz
config.downsample_rate = 100; % Hz for archive

% Storage options
config.keep_full_resolution = true; % Keep full resolution for active training
config.create_archive = true; % Create downsampled archive
config.compression = true; % Use compression for archive

% Parameter variation ranges
config.parameter_ranges = struct();
config.parameter_ranges.golfer_height = [1.65, 1.95]; % meters
config.parameter_ranges.golfer_mass = [60, 100]; % kg
config.parameter_ranges.arm_length = [0.6, 0.8]; % meters
config.parameter_ranges.leg_length = [0.8, 1.0]; % meters
config.parameter_ranges.torso_length = [0.4, 0.6]; % meters
config.parameter_ranges.club_length = [0.8, 1.2]; % meters
config.parameter_ranges.club_mass = [0.2, 0.4]; % kg

% Neural network parameters
config.input_signals = {'q', 'qd', 'qdd'}; % Input to neural network
config.output_signals = {'tau'}; % Output from neural network

fprintf('Configuration:\n');
fprintf('  Simulations: %d\n', config.num_simulations);
fprintf('  Duration: %d seconds\n', config.simulation_duration);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Archive rate: %d Hz\n', config.downsample_rate);

%% Calculate Storage Requirements
fprintf('\n--- Storage Requirements Analysis ---\n');

% Per simulation calculations
time_points = config.simulation_duration * config.sample_rate;
num_signals = 99; % 28q + 28qd + 24qdd + 19tau
data_points_per_sim = time_points * num_signals;
bytes_per_sim = data_points_per_sim * 8; % double precision
mb_per_sim = bytes_per_sim / (1024^2);

% Total requirements
total_data_points = config.num_simulations * data_points_per_sim;
total_bytes = total_data_points * 8;
total_gb = total_bytes / (1024^3);

% Archive requirements
archive_time_points = config.simulation_duration * config.downsample_rate;
archive_data_points_per_sim = archive_time_points * num_signals;
archive_bytes_per_sim = archive_data_points_per_sim * 8;
archive_mb_per_sim = archive_bytes_per_sim / (1024^2);
archive_total_mb = config.num_simulations * archive_mb_per_sim;

fprintf('Per simulation:\n');
fprintf('  Time points: %d\n', time_points);
fprintf('  Data points: %d\n', data_points_per_sim);
fprintf('  Size: %.2f MB\n', mb_per_sim);

fprintf('\nTotal dataset:\n');
fprintf('  Full resolution: %.2f GB\n', total_gb);
fprintf('  Archive (downsampled): %.2f MB\n', archive_total_mb);

if config.compression
    estimated_compression_ratio = 0.3; % Assume 70% compression
    compressed_archive_mb = archive_total_mb * estimated_compression_ratio;
    fprintf('  Compressed archive: ~%.2f MB\n', compressed_archive_mb);
end

%% Create Dataset Structure
fprintf('\n--- Creating Dataset Structure ---\n');

% Initialize dataset
dataset = struct();
dataset.config = config;
dataset.metadata = struct();
dataset.simulations = cell(config.num_simulations, 1);
dataset.parameters = cell(config.num_simulations, 1);

% Create parameter documentation structure
parameter_fields = fieldnames(config.parameter_ranges);
dataset.parameter_documentation = struct();
for i = 1:length(parameter_fields)
    field = parameter_fields{i};
    range = config.parameter_ranges.(field);
    dataset.parameter_documentation.(field) = struct();
    dataset.parameter_documentation.(field).range = range;
    dataset.parameter_documentation.(field).units = getParameterUnits(field);
    dataset.parameter_documentation.(field).description = getParameterDescription(field);
end

%% Generate Parameter Sets
fprintf('\n--- Generating Parameter Sets ---\n');

% Generate random parameter sets
parameter_sets = generateParameterSets(config.parameter_ranges, config.num_simulations);

% Store parameter sets in dataset
for i = 1:config.num_simulations
    dataset.parameters{i} = parameter_sets(i);
end

fprintf('Generated %d parameter sets\n', config.num_simulations);

%% Simulation Loop
fprintf('\n--- Starting Simulation Loop ---\n');

% Create progress tracking
progress_interval = max(1, round(config.num_simulations / 20));
start_time = tic;

for sim_idx = 1:config.num_simulations
    % Progress update
    if mod(sim_idx, progress_interval) == 0
        elapsed = toc(start_time);
        remaining = elapsed * (config.num_simulations - sim_idx) / sim_idx;
        fprintf('Progress: %d/%d (%.1f%%) - Elapsed: %.1fs, Remaining: %.1fs\n', ...
                sim_idx, config.num_simulations, 100*sim_idx/config.num_simulations, ...
                elapsed, remaining);
    end
    
    % Get current parameter set
    current_params = parameter_sets(sim_idx);
    
    % Update model parameters
    updateModelParameters(current_params);
    
    % Run simulation
    try
        simOut = runSimulation(config.simulation_duration);
        
        % Extract joint states
        joint_data = extractJointStatesFromSimscape();
        
        % Store simulation data
        dataset.simulations{sim_idx} = joint_data;
        
        % Add simulation metadata
        dataset.simulations{sim_idx}.metadata = struct();
        dataset.simulations{sim_idx}.metadata.simulation_id = sim_idx;
        dataset.simulations{sim_idx}.metadata.parameters = current_params;
        dataset.simulations{sim_idx}.metadata.timestamp = datetime('now');
        dataset.simulations{sim_idx}.metadata.duration = config.simulation_duration;
        dataset.simulations{sim_idx}.metadata.sample_rate = config.sample_rate;
        
    catch ME
        fprintf('Error in simulation %d: %s\n', sim_idx, ME.message);
        % Store error information
        dataset.simulations{sim_idx} = struct();
        dataset.simulations{sim_idx}.error = ME.message;
        dataset.simulations{sim_idx}.metadata.simulation_id = sim_idx;
        dataset.simulations{sim_idx}.metadata.parameters = current_params;
        dataset.simulations{sim_idx}.metadata.timestamp = datetime('now');
    end
end

%% Create Archive Dataset
if config.create_archive
    fprintf('\n--- Creating Archive Dataset ---\n');
    
    archive_dataset = struct();
    archive_dataset.config = config;
    archive_dataset.parameter_documentation = dataset.parameter_documentation;
    archive_dataset.parameters = dataset.parameters;
    archive_dataset.simulations = cell(config.num_simulations, 1);
    
    for sim_idx = 1:config.num_simulations
        if isfield(dataset.simulations{sim_idx}, 'error')
            archive_dataset.simulations{sim_idx} = dataset.simulations{sim_idx};
        else
            % Downsample the data
            archive_dataset.simulations{sim_idx} = downsampleSimulationData(...
                dataset.simulations{sim_idx}, config.downsample_rate, config.sample_rate);
        end
    end
    
    fprintf('Archive dataset created\n');
end

%% Save Datasets
fprintf('\n--- Saving Datasets ---\n');

% Save full resolution dataset
if config.keep_full_resolution
    full_filename = sprintf('golf_swing_dataset_full_%d_sims_%s.mat', ...
                          config.num_simulations, datestr(now, 'yyyymmdd_HHMMSS'));
    save(full_filename, 'dataset', '-v7.3');
    fprintf('Full resolution dataset saved: %s\n', full_filename);
end

% Save archive dataset
if config.create_archive
    archive_filename = sprintf('golf_swing_dataset_archive_%d_sims_%s.mat', ...
                              config.num_simulations, datestr(now, 'yyyymmdd_HHMMSS'));
    
    if config.compression
        save(archive_filename, 'archive_dataset', '-v7.3', '-nocompression');
        fprintf('Archive dataset saved: %s\n', archive_filename);
    else
        save(archive_filename, 'archive_dataset', '-v7.3');
        fprintf('Archive dataset saved: %s\n', archive_filename);
    end
end

%% Generate Summary Report
fprintf('\n--- Dataset Summary Report ---\n');

% Count successful simulations
successful_sims = 0;
failed_sims = 0;
for i = 1:config.num_simulations
    if isfield(dataset.simulations{i}, 'error')
        failed_sims = failed_sims + 1;
    else
        successful_sims = successful_sims + 1;
    end
end

fprintf('Simulation Results:\n');
fprintf('  Successful: %d (%.1f%%)\n', successful_sims, 100*successful_sims/config.num_simulations);
fprintf('  Failed: %d (%.1f%%)\n', failed_sims, 100*failed_sims/config.num_simulations);

% Parameter statistics
fprintf('\nParameter Statistics:\n');
for i = 1:length(parameter_fields)
    field = parameter_fields{i};
    values = zeros(successful_sims, 1);
    valid_count = 0;
    
    for j = 1:config.num_simulations
        if ~isfield(dataset.simulations{j}, 'error')
            valid_count = valid_count + 1;
            values(valid_count) = dataset.parameters{j}.(field);
        end
    end
    
    if valid_count > 0
        values = values(1:valid_count);
        fprintf('  %s: min=%.3f, max=%.3f, mean=%.3f, std=%.3f\n', ...
                field, min(values), max(values), mean(values), std(values));
    end
end

fprintf('\nDataset generation complete!\n');

%% Helper Functions

function units = getParameterUnits(field)
    % Return units for parameter field
    unit_map = containers.Map();
    unit_map('golfer_height') = 'm';
    unit_map('golfer_mass') = 'kg';
    unit_map('arm_length') = 'm';
    unit_map('leg_length') = 'm';
    unit_map('torso_length') = 'm';
    unit_map('club_length') = 'm';
    unit_map('club_mass') = 'kg';
    
    if isKey(unit_map, field)
        units = unit_map(field);
    else
        units = 'unknown';
    end
end

function description = getParameterDescription(field)
    % Return description for parameter field
    desc_map = containers.Map();
    desc_map('golfer_height') = 'Total height of the golfer';
    desc_map('golfer_mass') = 'Total mass of the golfer';
    desc_map('arm_length') = 'Length of upper arm segment';
    desc_map('leg_length') = 'Length of leg segment';
    desc_map('torso_length') = 'Length of torso segment';
    desc_map('club_length') = 'Length of golf club';
    desc_map('club_mass') = 'Mass of golf club';
    
    if isKey(desc_map, field)
        description = desc_map(field);
    else
        description = 'No description available';
    end
end

function parameter_sets = generateParameterSets(ranges, num_sets)
    % Generate random parameter sets within specified ranges
    fields = fieldnames(ranges);
    parameter_sets = struct();
    
    for i = 1:num_sets
        for j = 1:length(fields)
            field = fields{j};
            range = ranges.(field);
            parameter_sets(i).(field) = range(1) + (range(2) - range(1)) * rand();
        end
    end
end

function updateModelParameters(params)
    % Update the Simulink model with new parameters
    % This function should be customized for your specific model
    
    % Example parameter updates
    try
        % Update golfer parameters
        set_param('GolfSwing3D_Kinetic/Golfer_Model/Golfer_Height', 'Value', num2str(params.golfer_height));
        set_param('GolfSwing3D_Kinetic/Golfer_Model/Golfer_Mass', 'Value', num2str(params.golfer_mass));
        
        % Update segment lengths
        set_param('GolfSwing3D_Kinetic/Segments/Arm_Length', 'Value', num2str(params.arm_length));
        set_param('GolfSwing3D_Kinetic/Segments/Leg_Length', 'Value', num2str(params.leg_length));
        set_param('GolfSwing3D_Kinetic/Segments/Torso_Length', 'Value', num2str(params.torso_length));
        
        % Update club parameters
        set_param('GolfSwing3D_Kinetic/Club/Club_Length', 'Value', num2str(params.club_length));
        set_param('GolfSwing3D_Kinetic/Club/Club_Mass', 'Value', num2str(params.club_mass));
        
    catch ME
        warning('Could not update all model parameters: %s', ME.message);
    end
end

function simOut = runSimulation(duration)
    % Run the simulation for specified duration
    set_param('GolfSwing3D_Kinetic', 'StopTime', num2str(duration));
    simOut = sim('GolfSwing3D_Kinetic');
end

function downsampled_data = downsampleSimulationData(sim_data, target_rate, original_rate)
    % Downsample simulation data to target rate
    downsampled_data = sim_data;
    
    % Calculate downsampling factor
    factor = original_rate / target_rate;
    
    % Downsample time vector
    downsampled_data.time = sim_data.time(1:factor:end);
    
    % Downsample signal data
    if isfield(sim_data, 'q')
        downsampled_data.q = sim_data.q(1:factor:end, :);
    end
    if isfield(sim_data, 'qd')
        downsampled_data.qd = sim_data.qd(1:factor:end, :);
    end
    if isfield(sim_data, 'qdd')
        downsampled_data.qdd = sim_data.qdd(1:factor:end, :);
    end
    if isfield(sim_data, 'tau')
        downsampled_data.tau = sim_data.tau(1:factor:end, :);
    end
    
    % Update metadata
    downsampled_data.metadata.sample_rate = target_rate;
    downsampled_data.metadata.downsampled_from = original_rate;
end 