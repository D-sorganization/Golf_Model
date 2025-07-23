function appendToDataset(existing_dataset_file, num_additional_simulations)
% appendToDataset.m
% Append new simulation data to an existing dataset
% 
% Inputs:
%   existing_dataset_file - Path to existing .mat dataset file
%   num_additional_simulations - Number of new simulations to add (default: 10)

if nargin < 2
    num_additional_simulations = 10;
end

fprintf('=== Append to Dataset ===\n');
fprintf('Existing dataset: %s\n', existing_dataset_file);
fprintf('Additional simulations: %d\n', num_additional_simulations);
fprintf('Duration: 0.3 seconds each\n\n');

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

% Initialize new data arrays
new_simulations = cell(num_additional_simulations, 1);
new_parameters = cell(num_additional_simulations, 1);
new_success_flags = false(num_additional_simulations, 1);
new_simulation_times = zeros(num_additional_simulations, 1);

% Start timing
total_start_time = tic;

fprintf('Starting additional simulations...\n');
fprintf('Progress: [');
progress_bar_length = 50;

successful_sims = 0;
failed_sims = 0;

for sim_idx = 1:num_additional_simulations
    % Update progress bar
    progress = sim_idx / num_additional_simulations;
    filled_length = round(progress * progress_bar_length);
    fprintf('\rProgress: [%s%s] %d/%d (%.1f%%)', ...
            repmat('█', 1, filled_length), ...
            repmat('░', 1, progress_bar_length - filled_length), ...
            sim_idx, num_additional_simulations, progress * 100);
    
    % Start simulation timer
    sim_start_time = tic;
    
    try
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
        
        % Run simulation
        simOut = sim(simIn);
        sim_time = toc(sim_start_time);
        
        % Check if simulation was successful
        if isempty(simOut)
            throw(MException('Simulation:Empty', 'Simulation returned empty results'));
        end
        
        % Extract data from Simscape Results Explorer
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run = Simulink.sdi.getRun(runIDs(end));
            all_signals = latest_run.getAllSignals;
            
            % Create simulation data structure
            sim_data = struct();
            sim_data.time = simOut.tout;
            sim_data.signals = all_signals;
            sim_data.signal_names = {all_signals.Name};
            
            % Store results
            new_simulations{sim_idx} = sim_data;
            new_parameters{sim_idx} = struct();
            new_parameters{sim_idx}.polynomial_inputs = polynomial_inputs;
            new_parameters{sim_idx}.starting_positions = starting_positions;
            new_parameters{sim_idx}.simulation_time = sim_time;
            
            new_success_flags(sim_idx) = true;
            new_simulation_times(sim_idx) = sim_time;
            successful_sims = successful_sims + 1;
            
        else
            throw(MException('Simulation:NoData', 'No Simscape data found'));
        end
        
    catch ME
        % Handle errors
        new_success_flags(sim_idx) = false;
        new_simulation_times(sim_idx) = toc(sim_start_time);
        failed_sims = failed_sims + 1;
        
        fprintf('\n✗ Additional simulation %d failed: %s\n', sim_idx, ME.message);
        continue;
    end
end

total_time = toc(total_start_time);

% Combine datasets
fprintf('\n\nCombining datasets...\n');

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
fprintf('\n=== Dataset Append Complete ===\n');
fprintf('Original simulations: %d\n', original_count);
fprintf('New simulations: %d\n', num_additional_simulations);
fprintf('Total simulations: %d\n', total_simulations);
fprintf('Additional time: %.2f seconds (%.2f minutes)\n', total_time, total_time/60);
fprintf('New successful: %d (%.1f%%)\n', successful_sims, 100*successful_sims/num_additional_simulations);
fprintf('New failed: %d (%.1f%%)\n', failed_sims, 100*failed_sims/num_additional_simulations);
fprintf('Overall success rate: %.1f%% (%d/%d)\n', 100*total_successful/total_simulations, total_successful, total_simulations);
fprintf('Average simulation time: %.2f seconds\n', mean(existing_dataset.simulation_times(existing_dataset.success_flags)));

% Save updated dataset
if successful_sims > 0
    % Create backup of original
    [filepath, name, ext] = fileparts(existing_dataset_file);
    backup_file = fullfile(filepath, sprintf('%s_backup_%s%s', name, datestr(now, 'yyyymmdd_HHMMSS'), ext));
    copyfile(existing_dataset_file, backup_file);
    fprintf('✓ Original dataset backed up: %s\n', backup_file);
    
    % Save updated dataset (use existing_dataset variable)
    dataset = existing_dataset;  % Create dataset variable for saving
    save(existing_dataset_file, 'dataset', '-v7.3');
    fprintf('✓ Updated dataset saved: %s\n', existing_dataset_file);
    
    % Also save with new timestamp
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    new_filename = sprintf('dataset_%d_sims_%s.mat', total_simulations, timestamp);
    save(new_filename, 'dataset', '-v7.3');
    fprintf('✓ New timestamped copy: %s\n', new_filename);
else
    fprintf('✗ No new successful simulations to save\n');
end

fprintf('\n=== Dataset Append Complete ===\n');

end 