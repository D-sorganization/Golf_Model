function generateCompleteDataset(input_config)
% generateCompleteDataset.m
% Complete pipeline for generating golf swing dataset with randomized inputs
% 
% Inputs:
%   input_config - Optional configuration structure (if not provided, uses defaults)
% 
% This script:
% 1. Generates random polynomial inputs for joint torques
% 2. Randomizes starting positions (torso, shoulders, hips)
% 3. Runs simulations with varied parameters
% 4. Extracts joint states and beam data
% 5. Stores comprehensive dataset for neural network training

if nargin < 1
    input_config = struct();
end

fprintf('=== Golf Swing Dataset Generation Pipeline ===\n\n');

%% Configuration
config = struct();

% Dataset size (use input config if provided, otherwise defaults)
if isfield(input_config, 'num_simulations')
    config.num_simulations = input_config.num_simulations;
else
    config.num_simulations = 1000;
end

if isfield(input_config, 'simulation_duration')
    config.simulation_duration = input_config.simulation_duration;
else
    config.simulation_duration = 0.3; % seconds
end

if isfield(input_config, 'sample_rate')
    config.sample_rate = input_config.sample_rate;
else
    config.sample_rate = 1000; % Hz
end

% Polynomial input ranges
config.hip_torque_range = [-50, 50]; % Nm
config.spine_torque_range = [-30, 30]; % Nm
config.shoulder_torque_range = [-20, 20]; % Nm
config.elbow_torque_range = [-15, 15]; % Nm
config.wrist_torque_range = [-10, 10]; % Nm
config.translation_force_range = [-100, 100]; % N
config.swing_duration_range = [0.8, 1.2]; % seconds

% Starting position ranges
config.hip_position_range = [-0.1, 0.1]; % meters
config.hip_rotation_range = [-0.2, 0.2]; % radians
config.spine_tilt_range = [-0.3, 0.3]; % radians
config.torso_rotation_range = [-0.4, 0.4]; % radians
config.shoulder_position_range = [-0.05, 0.05]; % meters
config.shoulder_rotation_range = [-0.1, 0.1]; % radians

% Simulation settings
config.solver_type = 'ode23t';
config.relative_tolerance = 1e-3;
config.absolute_tolerance = 1e-5;
config.max_simulation_time = 10; % seconds

% Data storage settings
config.save_interval = 50; % Save every N simulations
config.create_archive = true;
config.compression = true;
config.downsample_rate = 10; % Keep every 10th sample for archive

% Model name
config.model_name = 'GolfSwing3D_Kinetic';

fprintf('Configuration:\n');
fprintf('  Simulations: %d\n', config.num_simulations);
fprintf('  Duration: %d seconds each\n', config.simulation_duration);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Save interval: %d\n', config.save_interval);
fprintf('  Model: %s\n', config.model_name);

%% Initialize dataset structure
dataset = struct();
dataset.config = config;
dataset.metadata = struct();
dataset.metadata.creation_time = datetime('now');
dataset.metadata.description = 'Golf swing dataset with randomized polynomial inputs and starting positions';
dataset.metadata.version = '1.0';

% Initialize storage arrays
dataset.simulations = cell(config.num_simulations, 1);
dataset.parameters = cell(config.num_simulations, 1);
dataset.success_flags = false(config.num_simulations, 1);
dataset.error_messages = cell(config.num_simulations, 1);
dataset.simulation_times = zeros(config.num_simulations, 1);

%% Load model
fprintf('\nLoading Simulink model...\n');
try
    load_system(config.model_name);
    fprintf('✓ Model loaded successfully\n');
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

%% Generate dataset
fprintf('\n=== Starting Dataset Generation ===\n');
fprintf('Progress: [');
progress_bar_length = 50;

start_time = tic;
successful_sims = 0;
failed_sims = 0;

for sim_idx = 1:config.num_simulations
    % Update progress bar
    progress = sim_idx / config.num_simulations;
    filled_length = round(progress * progress_bar_length);
    fprintf('\rProgress: [%s%s] %d/%d (%.1f%%)', ...
            repmat('█', 1, filled_length), ...
            repmat('░', 1, progress_bar_length - filled_length), ...
            sim_idx, config.num_simulations, progress * 100);
    
    % Initialize simulation timer
    sim_start_time = tic;
    
    try
        %% Generate random inputs
        polynomial_inputs = generatePolynomialInputs(config);
        starting_positions = generateRandomStartingPositions(config);
        
        %% Update model parameters
        success = updateModelParameters(polynomial_inputs, starting_positions, config.model_name);
        if ~success
            throw(MException('ModelUpdate:Failed', 'Failed to update model parameters'));
        end
        
        %% Run simulation
        [simOut, sim_success, error_msg] = runSimulation(config.model_name, config);
        sim_time = toc(sim_start_time);
        
        if ~sim_success
            throw(MException('Simulation:Failed', error_msg));
        end
        
        %% Extract data
        fprintf('\nExtracting data for simulation %d...\n', sim_idx);
        joint_data = extractJointStatesFromSimscape();
        
        %% Store results
        dataset.simulations{sim_idx} = joint_data;
        dataset.parameters{sim_idx} = struct();
        dataset.parameters{sim_idx}.polynomial_inputs = polynomial_inputs;
        dataset.parameters{sim_idx}.starting_positions = starting_positions;
        dataset.parameters{sim_idx}.simulation_time = sim_time;
        dataset.parameters{sim_idx}.simulation_index = sim_idx;
        
        dataset.success_flags(sim_idx) = true;
        dataset.error_messages{sim_idx} = '';
        dataset.simulation_times(sim_idx) = sim_time;
        
        successful_sims = successful_sims + 1;
        
        %% Save intermediate results
        if mod(sim_idx, config.save_interval) == 0
            saveIntermediateResults(dataset, sim_idx, config);
        end
        
    catch ME
        % Handle errors
        dataset.success_flags(sim_idx) = false;
        dataset.error_messages{sim_idx} = ME.message;
        dataset.simulation_times(sim_idx) = toc(sim_start_time);
        
        failed_sims = failed_sims + 1;
        
        fprintf('\n✗ Simulation %d failed: %s\n', sim_idx, ME.message);
        
        % Continue with next simulation
        continue;
    end
end

total_time = toc(start_time);

%% Final results
fprintf('\n\n=== Dataset Generation Complete ===\n');
fprintf('Total time: %.1f hours (%.1f days)\n', total_time/3600, total_time/86400);
fprintf('Successful simulations: %d (%.1f%%)\n', successful_sims, 100*successful_sims/config.num_simulations);
fprintf('Failed simulations: %d (%.1f%%)\n', failed_sims, 100*failed_sims/config.num_simulations);
fprintf('Average simulation time: %.2f seconds\n', mean(dataset.simulation_times(dataset.success_flags)));

%% Save final dataset
fprintf('\nSaving final dataset...\n');
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
filename = sprintf('golf_swing_dataset_%s.mat', timestamp);

if config.compression
    save(filename, 'dataset', '-v7.3', '-nocompression');
else
    save(filename, 'dataset', '-v7.3');
end

fprintf('✓ Dataset saved to: %s\n', filename);

%% Create archive dataset (downsampled)
if config.create_archive
    fprintf('\nCreating archive dataset...\n');
    archive_dataset = createArchiveDataset(dataset, config);
    
    archive_filename = sprintf('golf_swing_dataset_archive_%s.mat', timestamp);
    if config.compression
        save(archive_filename, 'archive_dataset', '-v7.3', '-nocompression');
    else
        save(archive_filename, 'archive_dataset', '-v7.3');
    end
    
    fprintf('✓ Archive dataset saved to: %s\n', archive_filename);
end

%% Generate summary report
generateDatasetReport(dataset, config, timestamp);

%% Cleanup workspace
fprintf('\n=== Cleaning Workspace ===\n');

% Variables to keep
keep_vars = {'dataset', 'config', 'total_time', 'successful_sims', 'failed_sims'};

% Get all variables in workspace
all_vars = who;

% Variables to remove
remove_vars = setdiff(all_vars, keep_vars);

if ~isempty(remove_vars)
    fprintf('Removing %d workspace variables:\n', length(remove_vars));
    for i = 1:length(remove_vars)
        fprintf('  - %s\n', remove_vars{i});
    end
    
    % Remove variables
    clear(remove_vars{:});
    fprintf('✓ Workspace cleaned\n');
else
    fprintf('✓ No variables to remove\n');
end

% Final workspace status
remaining_vars = who;
fprintf('Remaining variables: %d\n', length(remaining_vars));
for i = 1:length(remaining_vars)
    fprintf('  - %s\n', remaining_vars{i});
end

fprintf('\n=== Pipeline Complete ===\n');
fprintf('Dataset generation finished successfully!\n');

end

function saveIntermediateResults(dataset, sim_idx, config)
% Save intermediate results to prevent data loss
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
intermediate_filename = sprintf('intermediate_dataset_%d_%s.mat', sim_idx, timestamp);

% Save only completed simulations
intermediate_dataset = struct();
intermediate_dataset.config = config;
intermediate_dataset.metadata = dataset.metadata;
intermediate_dataset.simulations = dataset.simulations(1:sim_idx);
intermediate_dataset.parameters = dataset.parameters(1:sim_idx);
intermediate_dataset.success_flags = dataset.success_flags(1:sim_idx);
intermediate_dataset.error_messages = dataset.error_messages(1:sim_idx);
intermediate_dataset.simulation_times = dataset.simulation_times(1:sim_idx);

save(intermediate_filename, 'intermediate_dataset', '-v7.3');
fprintf('\n✓ Intermediate results saved: %s\n', intermediate_filename);
end

function archive_dataset = createArchiveDataset(dataset, config)
% Create downsampled archive dataset
archive_dataset = struct();
archive_dataset.config = config;
archive_dataset.metadata = dataset.metadata;
archive_dataset.metadata.archive_creation_time = datetime('now');
archive_dataset.metadata.downsample_rate = config.downsample_rate;

% Downsample successful simulations
successful_indices = find(dataset.success_flags);
archive_dataset.simulations = cell(length(successful_indices), 1);
archive_dataset.parameters = cell(length(successful_indices), 1);

for i = 1:length(successful_indices)
    idx = successful_indices(i);
    
    % Downsample simulation data
    sim_data = dataset.simulations{idx};
    archive_sim_data = struct();
    
    % Downsample each field
    fields = fieldnames(sim_data);
    for j = 1:length(fields)
        field_name = fields{j};
        if isnumeric(sim_data.(field_name))
            archive_sim_data.(field_name) = sim_data.(field_name)(1:config.downsample_rate:end, :);
        else
            archive_sim_data.(field_name) = sim_data.(field_name);
        end
    end
    
    archive_dataset.simulations{i} = archive_sim_data;
    archive_dataset.parameters{i} = dataset.parameters{idx};
end

archive_dataset.success_flags = dataset.success_flags(successful_indices);
archive_dataset.error_messages = dataset.error_messages(successful_indices);
archive_dataset.simulation_times = dataset.simulation_times(successful_indices);

fprintf('Archive dataset created with %d successful simulations\n', length(successful_indices));
end

function generateDatasetReport(dataset, config, timestamp)
% Generate comprehensive dataset report
report_filename = sprintf('dataset_report_%s.txt', timestamp);
fid = fopen(report_filename, 'w');

fprintf(fid, '=== Golf Swing Dataset Report ===\n\n');
fprintf(fid, 'Generation Date: %s\n', datestr(now));
fprintf(fid, 'Dataset Version: %s\n', dataset.metadata.version);
fprintf(fid, 'Description: %s\n\n', dataset.metadata.description);

fprintf(fid, 'Configuration:\n');
fprintf(fid, '  Total simulations: %d\n', config.num_simulations);
fprintf(fid, '  Simulation duration: %d seconds\n', config.simulation_duration);
fprintf(fid, '  Sample rate: %d Hz\n', config.sample_rate);
fprintf(fid, '  Model: %s\n\n', config.model_name);

% Statistics
successful_sims = sum(dataset.success_flags);
failed_sims = config.num_simulations - successful_sims;

fprintf(fid, 'Results:\n');
fprintf(fid, '  Successful simulations: %d (%.1f%%)\n', successful_sims, 100*successful_sims/config.num_simulations);
fprintf(fid, '  Failed simulations: %d (%.1f%%)\n', failed_sims, 100*failed_sims/config.num_simulations);
fprintf(fid, '  Average simulation time: %.2f seconds\n', mean(dataset.simulation_times(dataset.success_flags)));
fprintf(fid, '  Total dataset size: ~%.1f GB\n\n', estimateDatasetSize(dataset));

% Error analysis
if failed_sims > 0
    fprintf(fid, 'Error Analysis:\n');
    error_types = unique(dataset.error_messages(~cellfun(@isempty, dataset.error_messages)));
    for i = 1:length(error_types)
        error_count = sum(strcmp(dataset.error_messages, error_types{i}));
        fprintf(fid, '  %s: %d occurrences\n', error_types{i}, error_count);
    end
    fprintf(fid, '\n');
end

% Parameter distribution analysis
fprintf(fid, 'Parameter Distribution:\n');
analyzeParameterDistribution(dataset, fid);

fclose(fid);
fprintf('✓ Dataset report saved to: %s\n', report_filename);
end

function size_gb = estimateDatasetSize(dataset)
% Estimate dataset size in GB
successful_sims = sum(dataset.success_flags);
if successful_sims == 0
    size_gb = 0;
    return;
end

% Estimate size per simulation
sample_sim = dataset.simulations{find(dataset.success_flags, 1)};
fields = fieldnames(sample_sim);
total_elements = 0;

for i = 1:length(fields)
    if isnumeric(sample_sim.(fields{i}))
        total_elements = total_elements + numel(sample_sim.(fields{i}));
    end
end

% 8 bytes per double precision number
size_bytes = total_elements * 8 * successful_sims;
size_gb = size_bytes / (1024^3);
end

function analyzeParameterDistribution(dataset, fid)
% Analyze distribution of polynomial parameters
successful_indices = find(dataset.success_flags);
if isempty(successful_indices)
    return;
end

% Extract polynomial coefficients
all_coeffs = [];
for i = 1:length(successful_indices)
    idx = successful_indices(i);
    poly_inputs = dataset.parameters{idx}.polynomial_inputs;
    
    % Collect all coefficients
    fields = fieldnames(poly_inputs);
    for j = 1:length(fields)
        if strcmp(fields{j}, 'generation_time') || strcmp(fields{j}, 'config')
            continue;
        end
        coeffs = poly_inputs.(fields{j});
        all_coeffs = [all_coeffs, coeffs(:)'];
    end
end

fprintf(fid, '  Polynomial coefficients:\n');
fprintf(fid, '    Mean: %.3f\n', mean(all_coeffs));
fprintf(fid, '    Std: %.3f\n', std(all_coeffs));
fprintf(fid, '    Min: %.3f\n', min(all_coeffs));
fprintf(fid, '    Max: %.3f\n', max(all_coeffs));
fprintf(fid, '    Range: %.3f\n', max(all_coeffs) - min(all_coeffs));
end 