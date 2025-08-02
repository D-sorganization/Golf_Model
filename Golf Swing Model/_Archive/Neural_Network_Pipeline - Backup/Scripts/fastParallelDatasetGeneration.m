function fastParallelDatasetGeneration(num_simulations, num_workers)
% fastParallelDatasetGeneration.m
% Fast parallel dataset generation using parsim for maximum performance
% Focuses on simulation speed without complex Simscape data extraction
% 
% Inputs:
%   num_simulations - Number of simulations to run (default: 10)
%   num_workers - Number of parallel workers (default: auto-detect)

if nargin < 1
    num_simulations = 10;
end

if nargin < 2
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

fprintf('=== Fast Parallel Dataset Generation ===\n');
fprintf('Simulations: %d\n', num_simulations);
fprintf('Parallel workers: %d\n', num_workers);
fprintf('Duration: 0.3 seconds each\n\n');

% Check for Parallel Computing Toolbox
if ~license('test', 'Distrib_Computing_Toolbox')
    error('Parallel Computing Toolbox is required for this function');
end

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
fprintf('Preparing %d simulation inputs...\n', num_simulations);
simInputs = Simulink.SimulationInput.empty(0, num_simulations);

% Store metadata separately
all_polynomial_inputs = cell(num_simulations, 1);
all_starting_positions = cell(num_simulations, 1);

for sim_idx = 1:num_simulations
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
    
    simInputs(sim_idx) = simIn;
    
    % Store metadata
    all_polynomial_inputs{sim_idx} = polynomial_inputs;
    all_starting_positions{sim_idx} = starting_positions;
end

fprintf('✓ Simulation inputs prepared\n');

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

% Initialize dataset
dataset = struct();
dataset.simulations = cell(num_simulations, 1);
dataset.parameters = cell(num_simulations, 1);
dataset.success_flags = false(num_simulations, 1);
dataset.simulation_times = zeros(num_simulations, 1);

successful_sims = 0;
failed_sims = 0;

for sim_idx = 1:num_simulations
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
        sim_id = sim_idx;
        polynomial_inputs = all_polynomial_inputs{sim_idx};
        starting_positions = all_starting_positions{sim_idx};
        
        % Create basic simulation data structure (without Simscape data)
        sim_data = struct();
        sim_data.time = sim_result.tout;
        sim_data.success = true;
        sim_data.simulation_time = sim_result.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
        
        % Store results
        dataset.simulations{sim_idx} = sim_data;
        dataset.parameters{sim_idx} = struct();
        dataset.parameters{sim_idx}.polynomial_inputs = polynomial_inputs;
        dataset.parameters{sim_idx}.starting_positions = starting_positions;
        dataset.parameters{sim_idx}.simulation_time = sim_result.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
        
        dataset.success_flags(sim_idx) = true;
        dataset.simulation_times(sim_idx) = sim_result.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
        successful_sims = successful_sims + 1;
        
    catch ME
        % Handle errors
        dataset.success_flags(sim_idx) = false;
        dataset.simulation_times(sim_idx) = 0;
        failed_sims = failed_sims + 1;
        
        fprintf('✗ Simulation %d failed: %s\n', sim_idx, ME.message);
        continue;
    end
end

total_time = toc(total_start_time);

% Final results
fprintf('\n=== Fast Parallel Dataset Generation Complete ===\n');
fprintf('Total time: %.2f seconds (%.2f minutes)\n', total_time, total_time/60);
fprintf('Successful simulations: %d (%.1f%%)\n', successful_sims, 100*successful_sims/num_simulations);
fprintf('Failed simulations: %d (%.1f%%)\n', failed_sims, 100*failed_sims/num_simulations);
fprintf('Average simulation time: %.2f seconds\n', mean(dataset.simulation_times(dataset.success_flags)));
fprintf('Speedup factor: %.1fx (vs sequential)\n', (num_simulations * 28.61) / total_time);

% Save dataset
if successful_sims > 0
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('fast_parallel_dataset_%d_sims_%s.mat', successful_sims, timestamp);
    save(filename, 'dataset', '-v7.3');
    fprintf('✓ Dataset saved: %s\n', filename);
else
    fprintf('✗ No successful simulations to save\n');
end

fprintf('\n=== Fast Parallel Dataset Generation Complete ===\n');

end 