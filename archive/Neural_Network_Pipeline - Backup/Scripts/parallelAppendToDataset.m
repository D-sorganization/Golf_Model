function parallelAppendToDataset(existing_dataset_file, num_additional_simulations, num_workers)
% parallelAppendToDataset.m
% Parallel append to existing dataset using parsim for maximum performance
% 
% Inputs:
%   existing_dataset_file - Path to existing .mat dataset file
%   num_additional_simulations - Number of new simulations to add (default: 10)
%   num_workers - Number of parallel workers (default: auto-detect)

if nargin < 2
    num_additional_simulations = 10;
end

if nargin < 3
    % Auto-detect number of workers (use available cores, but respect limits)
    max_cores = feature('numcores');
    % Check parallel pool limits
    try
        pool_info = parallel.clusterProfiles;
        if ~isempty(pool_info)
            cluster = parallel.clusterProfiles('local');
            max_workers = cluster.NumWorkers;
        else
            max_workers = 6; % Default limit
        end
    catch
        max_workers = 6; % Default limit
    end
    num_workers = min(max_cores, max_workers);
    fprintf('Auto-detected %d CPU cores, using %d workers (system limit)\n', max_cores, num_workers);
end

fprintf('=== Parallel Append to Dataset ===\n');
fprintf('Existing dataset: %s\n', existing_dataset_file);
fprintf('Additional simulations: %d\n', num_additional_simulations);
fprintf('Parallel workers: %d\n', num_workers);
fprintf('Duration: 0.3 seconds each\n\n');

% Check for Parallel Computing Toolbox
if ~license('test', 'Distrib_Computing_Toolbox')
    error('Parallel Computing Toolbox is required for this function');
end

% Check if existing dataset exists
if ~exist(existing_dataset_file, 'file')
    error('Existing dataset file not found: %s', existing_dataset_file);
end

% Load existing dataset
fprintf('Loading existing dataset...\n');
existing_data = load(existing_dataset_file);
if ~isfield(existing_data, 'dataset')
    error('Invalid dataset file: missing "dataset" field');
end

existing_dataset = existing_data.dataset;
original_count = length(existing_dataset.simulations);

fprintf('✓ Existing dataset loaded: %d simulations\n', original_count);

% Add scripts to path
addpath('Scripts');

% Model name
model_name = 'GolfSwing3D_Kinetic';

% Load model
if ~bdIsLoaded(model_name)
    load_system(model_name);
    fprintf('✓ Model loaded\n');
end

% Initialize parallel pool if not already running
if isempty(gcp('nocreate'))
    fprintf('Starting parallel pool with %d workers...\n', num_workers);
    parpool('local', num_workers);
    fprintf('✓ Parallel pool started\n');
else
    current_pool = gcp;
    fprintf('✓ Using existing parallel pool with %d workers\n', current_pool.NumWorkers);
end

% Start timing
total_start_time = tic;

% Create array of SimulationInput objects
fprintf('Preparing %d additional simulation inputs...\n', num_additional_simulations);
simInputs = Simulink.SimulationInput.empty(0, num_additional_simulations);

% Store metadata separately
all_polynomial_inputs = cell(num_additional_simulations, 1);
all_starting_positions = cell(num_additional_simulations, 1);

for sim_idx = 1:num_additional_simulations
    % Generate random polynomial inputs
    config = struct();
    config.hip_torque_range = [-30, 30];
    config.spine_torque_range = [-20, 20];
    config.shoulder_torque_range = [-15, 15];
    config.elbow_torque_range = [-10, 10];
    config.wrist_torque_range = [-8, 8];
    config.translation_force_range = [-50, 50];
    config.polynomial_order = 4;
    config.swing_duration_range = [0.8, 1.2];
    
    polynomial_inputs = generatePolynomialInputs(config);
    starting_positions = generateRandomStartingPositions(config);
    
    % Create SimulationInput object
    simIn = Simulink.SimulationInput(model_name);
    
    % Set simulation parameters
    simIn = simIn.setModelParameter('StopTime', '0.3');
    simIn = simIn.setModelParameter('Solver', 'ode23t');
    simIn = simIn.setModelParameter('RelTol', '1e-3');
    simIn = simIn.setModelParameter('AbsTol', '1e-5');
    simIn = simIn.setModelParameter('SaveOutput', 'on');
    simIn = simIn.setModelParameter('SaveFormat', 'Dataset');
    simIn = simIn.setModelParameter('SimscapeLogType', 'all');
    
    % Set model workspace variables for polynomial inputs
    simIn = simIn.setVariable('PolynomialInputs', polynomial_inputs);
    
    % Set starting positions in model workspace
    if isfield(starting_positions, 'hip_x')
        simIn = simIn.setVariable('HipStartPositionX', starting_positions.hip_x);
    end
    if isfield(starting_positions, 'hip_y')
        simIn = simIn.setVariable('HipStartPositionY', starting_positions.hip_y);
    end
    if isfield(starting_positions, 'hip_z')
        simIn = simIn.setVariable('HipStartPositionZ', starting_positions.hip_z);
    end
    if isfield(starting_positions, 'spine_rx')
        simIn = simIn.setVariable('SpineStartPositionX', starting_positions.spine_rx);
    end
    if isfield(starting_positions, 'spine_ry')
        simIn = simIn.setVariable('SpineStartPositionY', starting_positions.spine_ry);
    end
    
    % Store metadata separately
    all_polynomial_inputs{sim_idx} = polynomial_inputs;
    all_starting_positions{sim_idx} = starting_positions;
    
    simInputs(sim_idx) = simIn;
end

fprintf('✓ Additional simulation inputs prepared\n');

% Run parallel simulations
fprintf('Starting parallel simulations...\n');
fprintf('This will utilize %d CPU cores for maximum performance\n', num_workers);

try
    simOut = parsim(simInputs, ...
        'ShowProgress', 'on', ...
        'TransferBaseWorkspaceVariables', 'on');
    
    fprintf('✓ Parallel simulations completed\n');
    
catch ME
    fprintf('✗ Parallel simulation failed: %s\n', ME.message);
    fprintf('Falling back to sequential simulation...\n');
    
    % Fallback to sequential simulation
    simOut = sim(simInputs);
end

% Process results
fprintf('Processing simulation results...\n');

% Initialize new data arrays
new_simulations = cell(num_additional_simulations, 1);
new_parameters = cell(num_additional_simulations, 1);
new_success_flags = false(num_additional_simulations, 1);
new_simulation_times = zeros(num_additional_simulations, 1);

successful_sims = 0;
failed_sims = 0;

for sim_idx = 1:num_additional_simulations
    try
        % Get simulation output
        if iscell(simOut)
            sim_result = simOut{sim_idx};
        else
            sim_result = simOut(sim_idx);
        end
        
        % Check if simulation was successful
        if isempty(sim_result)
            throw(MException('Simulation:Empty', 'Simulation returned empty results'));
        end
        
        % Extract metadata from stored arrays
        sim_id = original_count + sim_idx;
        polynomial_inputs = all_polynomial_inputs{sim_idx};
        starting_positions = all_starting_positions{sim_idx};
        
        % Extract data from Simscape Results Explorer
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            % Find the run corresponding to this simulation
            latest_run = Simulink.sdi.getRun(runIDs(end - num_additional_simulations + sim_idx));
            all_signals = latest_run.getAllSignals;
            
            % Create simulation data structure
            sim_data = struct();
            sim_data.time = sim_result.tout;
            sim_data.signals = all_signals;
            sim_data.signal_names = {all_signals.Name};
            
            % Store results
            new_simulations{sim_idx} = sim_data;
            new_parameters{sim_idx} = struct();
            new_parameters{sim_idx}.polynomial_inputs = polynomial_inputs;
            new_parameters{sim_idx}.starting_positions = starting_positions;
            new_parameters{sim_idx}.simulation_time = sim_result.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
            
            new_success_flags(sim_idx) = true;
            new_simulation_times(sim_idx) = sim_result.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
            successful_sims = successful_sims + 1;
            
        else
            throw(MException('Simulation:NoData', 'No Simscape data found'));
        end
        
    catch ME
        % Handle errors
        new_success_flags(sim_idx) = false;
        new_simulation_times(sim_idx) = 0;
        failed_sims = failed_sims + 1;
        
        fprintf('✗ Additional simulation %d failed: %s\n', sim_idx, ME.message);
        continue;
    end
end

total_time = toc(total_start_time);

% Combine datasets
fprintf('\nCombining datasets...\n');

% Append new data to existing dataset
existing_dataset.simulations = [existing_dataset.simulations; new_simulations];
existing_dataset.parameters = [existing_dataset.parameters; new_parameters];
existing_dataset.success_flags = [existing_dataset.success_flags; new_success_flags];
existing_dataset.simulation_times = [existing_dataset.simulation_times; new_simulation_times];

% Calculate combined statistics
total_simulations = length(existing_dataset.simulations);
total_successful = sum(existing_dataset.success_flags);
total_failed = total_simulations - total_successful;

% Final results
fprintf('\n=== Parallel Dataset Append Complete ===\n');
fprintf('Original simulations: %d\n', original_count);
fprintf('New simulations: %d\n', num_additional_simulations);
fprintf('Total simulations: %d\n', total_simulations);
fprintf('Additional time: %.2f seconds (%.2f minutes)\n', total_time, total_time/60);
fprintf('New successful: %d (%.1f%%)\n', successful_sims, 100*successful_sims/num_additional_simulations);
fprintf('New failed: %d (%.1f%%)\n', failed_sims, 100*failed_sims/num_additional_simulations);
fprintf('Overall success rate: %.1f%% (%d/%d)\n', 100*total_successful/total_simulations, total_successful, total_simulations);
fprintf('Average simulation time: %.2f seconds\n', mean(existing_dataset.simulation_times(existing_dataset.success_flags)));
fprintf('Speedup factor: %.1fx (vs sequential)\n', (num_additional_simulations * 28.61) / total_time);

% Save updated dataset
if successful_sims > 0
    % Create backup of original
    [filepath, name, ext] = fileparts(existing_dataset_file);
    backup_file = fullfile(filepath, sprintf('%s_backup_%s%s', name, datestr(now, 'yyyymmdd_HHMMSS'), ext));
    copyfile(existing_dataset_file, backup_file);
    fprintf('✓ Original dataset backed up: %s\n', backup_file);
    
    % Save updated dataset
    dataset = existing_dataset;  % Create dataset variable for saving
    save(existing_dataset_file, 'dataset', '-v7.3');
    fprintf('✓ Updated dataset saved: %s\n', existing_dataset_file);
    
    % Also save with new timestamp
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    new_filename = sprintf('parallel_dataset_%d_sims_%s.mat', total_simulations, timestamp);
    save(new_filename, 'dataset', '-v7.3');
    fprintf('✓ New timestamped copy: %s\n', new_filename);
else
    fprintf('✗ No new successful simulations to save\n');
end

fprintf('\n=== Parallel Dataset Append Complete ===\n');

end 