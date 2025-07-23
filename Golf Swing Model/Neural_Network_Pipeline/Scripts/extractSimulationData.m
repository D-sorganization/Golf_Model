function extractSimulationData(dataset_file)
% extractSimulationData.m
% Extract comprehensive simulation data from dataset
% 
% Inputs:
%   dataset_file - Path to .mat dataset file

fprintf('=== Extract Simulation Data ===\n');
fprintf('Dataset: %s\n\n', dataset_file);

% Check if dataset exists
if ~exist(dataset_file, 'file')
    error('Dataset file not found: %s', dataset_file);
end

% Load dataset
fprintf('Loading dataset...\n');
data = load(dataset_file);
if ~isfield(data, 'dataset')
    error('Invalid dataset file: missing "dataset" field');
end

dataset = data.dataset;
num_simulations = length(dataset.simulations);
successful_sims = sum(dataset.success_flags);

fprintf('✓ Dataset loaded: %d simulations (%d successful)\n', num_simulations, successful_sims);

% Create output directory
output_dir = 'extracted_data';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('✓ Created output directory: %s\n', output_dir);
end

% Extract timestamp for filenames
[~, name, ~] = fileparts(dataset_file);
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Initialize comprehensive data collection
all_data = [];
simulation_summary = [];

fprintf('Processing simulations...\n');
fprintf('Progress: [');
progress_bar_length = 50;

successful_count = 0;

for sim_idx = 1:num_simulations
    % Update progress bar
    progress = sim_idx / num_simulations;
    filled_length = round(progress * progress_bar_length);
    fprintf('\rProgress: [%s%s] %d/%d (%.1f%%)', ...
            repmat('█', 1, filled_length), ...
            repmat('░', 1, progress_bar_length - filled_length), ...
            sim_idx, num_simulations, progress * 100);
    
    if ~dataset.success_flags(sim_idx)
        continue; % Skip failed simulations
    end
    
    try
        sim_data = dataset.simulations{sim_idx};
        sim_params = dataset.parameters{sim_idx};
        
        % Get time vector
        time = sim_data.time;
        num_timepoints = length(time);
        
        % Create basic data structure for this simulation
        sim_table = table();
        sim_table.simulation_id = repmat(sim_idx, num_timepoints, 1);
        sim_table.time = time;
        
        % Add polynomial input coefficients as metadata
        poly_inputs = sim_params.polynomial_inputs;
        
        % Hip torque coefficients (assuming 4th order polynomial)
        if isfield(poly_inputs, 'hip_torque') && length(poly_inputs.hip_torque) >= 4
            sim_table.hip_torque_a0 = repmat(poly_inputs.hip_torque(1), num_timepoints, 1);
            sim_table.hip_torque_a1 = repmat(poly_inputs.hip_torque(2), num_timepoints, 1);
            sim_table.hip_torque_a2 = repmat(poly_inputs.hip_torque(3), num_timepoints, 1);
            sim_table.hip_torque_a3 = repmat(poly_inputs.hip_torque(4), num_timepoints, 1);
        end
        
        % Spine torque coefficients
        if isfield(poly_inputs, 'spine_torque') && length(poly_inputs.spine_torque) >= 4
            sim_table.spine_torque_a0 = repmat(poly_inputs.spine_torque(1), num_timepoints, 1);
            sim_table.spine_torque_a1 = repmat(poly_inputs.spine_torque(2), num_timepoints, 1);
            sim_table.spine_torque_a2 = repmat(poly_inputs.spine_torque(3), num_timepoints, 1);
            sim_table.spine_torque_a3 = repmat(poly_inputs.spine_torque(4), num_timepoints, 1);
        end
        
        % Shoulder torque coefficients
        if isfield(poly_inputs, 'shoulder_torque') && length(poly_inputs.shoulder_torque) >= 4
            sim_table.shoulder_torque_a0 = repmat(poly_inputs.shoulder_torque(1), num_timepoints, 1);
            sim_table.shoulder_torque_a1 = repmat(poly_inputs.shoulder_torque(2), num_timepoints, 1);
            sim_table.shoulder_torque_a2 = repmat(poly_inputs.shoulder_torque(3), num_timepoints, 1);
            sim_table.shoulder_torque_a3 = repmat(poly_inputs.shoulder_torque(4), num_timepoints, 1);
        end
        
        % Elbow torque coefficients
        if isfield(poly_inputs, 'elbow_torque') && length(poly_inputs.elbow_torque) >= 4
            sim_table.elbow_torque_a0 = repmat(poly_inputs.elbow_torque(1), num_timepoints, 1);
            sim_table.elbow_torque_a1 = repmat(poly_inputs.elbow_torque(2), num_timepoints, 1);
            sim_table.elbow_torque_a2 = repmat(poly_inputs.elbow_torque(3), num_timepoints, 1);
            sim_table.elbow_torque_a3 = repmat(poly_inputs.elbow_torque(4), num_timepoints, 1);
        end
        
        % Wrist torque coefficients
        if isfield(poly_inputs, 'wrist_torque') && length(poly_inputs.wrist_torque) >= 4
            sim_table.wrist_torque_a0 = repmat(poly_inputs.wrist_torque(1), num_timepoints, 1);
            sim_table.wrist_torque_a1 = repmat(poly_inputs.wrist_torque(2), num_timepoints, 1);
            sim_table.wrist_torque_a2 = repmat(poly_inputs.wrist_torque(3), num_timepoints, 1);
            sim_table.wrist_torque_a3 = repmat(poly_inputs.wrist_torque(4), num_timepoints, 1);
        end
        
        % Add starting positions if available
        if isfield(sim_params, 'starting_positions')
            start_pos = sim_params.starting_positions;
            if isfield(start_pos, 'hip_x')
                sim_table.start_hip_x = repmat(start_pos.hip_x, num_timepoints, 1);
            end
            if isfield(start_pos, 'hip_y')
                sim_table.start_hip_y = repmat(start_pos.hip_y, num_timepoints, 1);
            end
            if isfield(start_pos, 'hip_z')
                sim_table.start_hip_z = repmat(start_pos.hip_z, num_timepoints, 1);
            end
            if isfield(start_pos, 'spine_rx')
                sim_table.start_spine_rx = repmat(start_pos.spine_rx, num_timepoints, 1);
            end
            if isfield(start_pos, 'spine_ry')
                sim_table.start_spine_ry = repmat(start_pos.spine_ry, num_timepoints, 1);
            end
        end
        
        % Add simulation metadata
        sim_table.simulation_time = repmat(sim_params.simulation_time, num_timepoints, 1);
        
        % Try to extract actual simulation signals if available
        if isfield(sim_data, 'signals') && ~isempty(sim_data.signals)
            fprintf('\nSimulation %d has %d signals available\n', sim_idx, length(sim_data.signals));
            
            % Try to extract some key signals
            signals_extracted = 0;
            for sig_idx = 1:length(sim_data.signals)
                try
                    signal = sim_data.signals(sig_idx);
                    signal_name = signal.Name;
                    
                    % Extract signal data if available
                    if isfield(signal, 'Values') && isfield(signal.Values, 'Data')
                        signal_data = signal.Values.Data;
                        
                        % Add to table based on signal dimensions
                        if size(signal_data, 2) == 1
                            % Scalar signal
                            col_name = sprintf('signal_%d_%s', sig_idx, strrep(signal_name, ' ', '_'));
                            sim_table.(col_name) = signal_data;
                            signals_extracted = signals_extracted + 1;
                        elseif size(signal_data, 2) == 3
                            % 3D vector signal
                            col_name_x = sprintf('signal_%d_%s_x', sig_idx, strrep(signal_name, ' ', '_'));
                            col_name_y = sprintf('signal_%d_%s_y', sig_idx, strrep(signal_name, ' ', '_'));
                            col_name_z = sprintf('signal_%d_%s_z', sig_idx, strrep(signal_name, ' ', '_'));
                            sim_table.(col_name_x) = signal_data(:, 1);
                            sim_table.(col_name_y) = signal_data(:, 2);
                            sim_table.(col_name_z) = signal_data(:, 3);
                            signals_extracted = signals_extracted + 1;
                        end
                    end
                    
                    % Limit to first 20 signals to avoid huge tables
                    if signals_extracted >= 20
                        break;
                    end
                    
                catch ME
                    % Skip signals that can't be extracted
                    continue;
                end
            end
            
            fprintf('  Extracted %d signals\n', signals_extracted);
        end
        
        % Add to main dataset
        all_data = [all_data; sim_table];
        
        % Create simulation summary
        summary_row = table();
        summary_row.simulation_id = sim_idx;
        summary_row.num_timepoints = num_timepoints;
        summary_row.time_min = min(time);
        summary_row.time_max = max(time);
        summary_row.simulation_time = sim_params.simulation_time;
        summary_row.success = true;
        
        simulation_summary = [simulation_summary; summary_row];
        
        successful_count = successful_count + 1;
        
    catch ME
        fprintf('\n✗ Error processing simulation %d: %s\n', sim_idx, ME.message);
        continue;
    end
end

fprintf('\n\n✓ Processed %d successful simulations\n', successful_count);

% Export data
fprintf('\nExporting to CSV...\n');

% Export main dataset
main_file = fullfile(output_dir, sprintf('%s_extracted_%s.csv', name, timestamp));
writetable(all_data, main_file);
fprintf('✓ Main dataset: %s\n', main_file);

% Export simulation summary
summary_file = fullfile(output_dir, sprintf('%s_extracted_summary_%s.csv', name, timestamp));
writetable(simulation_summary, summary_file);
fprintf('✓ Simulation summary: %s\n', summary_file);

fprintf('\n=== Extraction Complete ===\n');
fprintf('Output directory: %s\n', output_dir);
fprintf('Total data points: %d\n', size(all_data, 1));
fprintf('Successful simulations: %d\n', successful_count);
fprintf('Time range: %.3f to %.3f seconds\n', min(all_data.time), max(all_data.time));
fprintf('Columns in dataset: %d\n', width(all_data));

end 