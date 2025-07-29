function simpleDatasetGeneration(num_simulations)
% simpleDatasetGeneration.m
% Simple dataset generation using SimulationInput objects
% 
% Inputs:
%   num_simulations - Number of simulations to run (default: 10)

if nargin < 1
    num_simulations = 10;
end

fprintf('=== Simple Dataset Generation ===\n');
fprintf('Simulations: %d\n', num_simulations);
fprintf('Duration: 0.3 seconds each\n\n');

% Add scripts to path
addpath('Scripts');

% Model name
model_name = 'GolfSwing3D_Kinetic';

% Load model
if ~bdIsLoaded(model_name)
    load_system(model_name);
    fprintf('✓ Model loaded\n');
end

% Initialize dataset
dataset = struct();
dataset.simulations = cell(num_simulations, 1);
dataset.parameters = cell(num_simulations, 1);
dataset.success_flags = false(num_simulations, 1);
dataset.simulation_times = zeros(num_simulations, 1);

% Start timing
total_start_time = tic;

fprintf('Starting simulations...\n');
fprintf('Progress: [');
progress_bar_length = 50;

successful_sims = 0;
failed_sims = 0;

for sim_idx = 1:num_simulations
    % Update progress bar
    progress = sim_idx / num_simulations;
    filled_length = round(progress * progress_bar_length);
    fprintf('\rProgress: [%s%s] %d/%d (%.1f%%)', ...
            repmat('█', 1, filled_length), ...
            repmat('░', 1, progress_bar_length - filled_length), ...
            sim_idx, num_simulations, progress * 100);
    
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
            dataset.simulations{sim_idx} = sim_data;
            dataset.parameters{sim_idx} = struct();
            dataset.parameters{sim_idx}.polynomial_inputs = polynomial_inputs;
            dataset.parameters{sim_idx}.starting_positions = starting_positions;
            dataset.parameters{sim_idx}.simulation_time = sim_time;
            
            dataset.success_flags(sim_idx) = true;
            dataset.simulation_times(sim_idx) = sim_time;
            successful_sims = successful_sims + 1;
            
        else
            throw(MException('Simulation:NoData', 'No Simscape data found'));
        end
        
    catch ME
        % Handle errors
        dataset.success_flags(sim_idx) = false;
        dataset.simulation_times(sim_idx) = toc(sim_start_time);
        failed_sims = failed_sims + 1;
        
        fprintf('\n✗ Simulation %d failed: %s\n', sim_idx, ME.message);
        continue;
    end
end

total_time = toc(total_start_time);

% Final results
fprintf('\n\n=== Dataset Generation Complete ===\n');
fprintf('Total time: %.2f seconds (%.2f minutes)\n', total_time, total_time/60);
fprintf('Successful simulations: %d (%.1f%%)\n', successful_sims, 100*successful_sims/num_simulations);
fprintf('Failed simulations: %d (%.1f%%)\n', failed_sims, 100*failed_sims/num_simulations);
fprintf('Average simulation time: %.2f seconds\n', mean(dataset.simulation_times(dataset.success_flags)));

% Save dataset
if successful_sims > 0
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('simple_dataset_%d_sims_%s.mat', successful_sims, timestamp);
    save(filename, 'dataset', '-v7.3');
    fprintf('✓ Dataset saved: %s\n', filename);
else
    fprintf('✗ No successful simulations to save\n');
end

fprintf('\n=== Simple Dataset Generation Complete ===\n');

end 