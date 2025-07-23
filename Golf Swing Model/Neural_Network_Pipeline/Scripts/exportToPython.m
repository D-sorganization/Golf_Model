function exportToPython(dataset_file, output_format)
% exportToPython.m
% Export MATLAB dataset to Python-friendly formats
% 
% Inputs:
%   dataset_file - Path to .mat dataset file
%   output_format - 'csv', 'hdf5', or 'both' (default: 'both')

if nargin < 2
    output_format = 'both';
end

fprintf('=== Export to Python ===\n');
fprintf('Dataset: %s\n', dataset_file);
fprintf('Format: %s\n\n', output_format);

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
output_dir = 'python_export';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('✓ Created output directory: %s\n', output_dir);
end

% Extract timestamp for filenames
[~, name, ~] = fileparts(dataset_file);
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Initialize data structures for export
all_kinematics = [];
all_torques = [];
all_metadata = [];

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
        
        % Extract time series data
        time = sim_data.time;
        signals = sim_data.signals;
        
        % Find joint kinematics (positions, velocities, accelerations)
        kinematics_data = extractJointKinematics(signals, time);
        
        % Find joint torques
        torques_data = extractJointTorques(signals, time);
        
        if ~isempty(kinematics_data) && ~isempty(torques_data)
            % Add simulation metadata
            kinematics_data.simulation_id = repmat(sim_idx, size(kinematics_data, 1), 1);
            torques_data.simulation_id = repmat(sim_idx, size(torques_data, 1), 1);
            
            % Add polynomial input metadata
            poly_inputs = sim_params.polynomial_inputs;
            kinematics_data.hip_torque_coeffs = repmat(poly_inputs.hip_torque, size(kinematics_data, 1), 1);
            kinematics_data.spine_torque_coeffs = repmat(poly_inputs.spine_torque, size(kinematics_data, 1), 1);
            kinematics_data.shoulder_torque_coeffs = repmat(poly_inputs.shoulder_torque, size(kinematics_data, 1), 1);
            kinematics_data.elbow_torque_coeffs = repmat(poly_inputs.elbow_torque, size(kinematics_data, 1), 1);
            kinematics_data.wrist_torque_coeffs = repmat(poly_inputs.wrist_torque, size(kinematics_data, 1), 1);
            
            % Combine data
            all_kinematics = [all_kinematics; kinematics_data];
            all_torques = [all_torques; torques_data];
            
            successful_count = successful_count + 1;
        end
        
    catch ME
        fprintf('\n✗ Error processing simulation %d: %s\n', sim_idx, ME.message);
        continue;
    end
end

fprintf('\n\n✓ Processed %d successful simulations\n', successful_count);

% Export data
if strcmp(output_format, 'csv') || strcmp(output_format, 'both')
    exportToCSV(all_kinematics, all_torques, output_dir, name, timestamp);
end

if strcmp(output_format, 'hdf5') || strcmp(output_format, 'both')
    exportToHDF5(all_kinematics, all_torques, output_dir, name, timestamp);
end

% Create Python helper script
createPythonHelper(output_dir, name, timestamp);

fprintf('\n=== Export Complete ===\n');
fprintf('Output directory: %s\n', output_dir);
fprintf('Total data points: %d\n', size(all_kinematics, 1));
fprintf('Time range: %.3f to %.3f seconds\n', min(all_kinematics.time), max(all_kinematics.time));

end

function kinematics_data = extractJointKinematics(signals, time)
% Extract joint kinematics from Simscape signals
kinematics_data = [];

% Define joint names and their signal patterns
joint_patterns = {
    'hip', {'Hip', 'hip'};
    'spine', {'Spine', 'spine'};
    'shoulder', {'Shoulder', 'shoulder'};
    'elbow', {'Elbow', 'elbow'};
    'wrist', {'Wrist', 'wrist'};
};

% Initialize data structure
data_struct = struct();
data_struct.time = time;

% Extract position, velocity, and acceleration for each joint
for joint_idx = 1:size(joint_patterns, 1)
    joint_name = joint_patterns{joint_idx, 1};
    patterns = joint_patterns{joint_idx, 2};
    
    % Find position signals
    pos_signal = findSignalByName(signals, patterns, 'Position');
    if ~isempty(pos_signal)
        data_struct.([joint_name '_pos_x']) = pos_signal.Values.Data(:, 1);
        data_struct.([joint_name '_pos_y']) = pos_signal.Values.Data(:, 2);
        data_struct.([joint_name '_pos_z']) = pos_signal.Values.Data(:, 3);
    end
    
    % Find velocity signals
    vel_signal = findSignalByName(signals, patterns, 'Velocity');
    if ~isempty(vel_signal)
        data_struct.([joint_name '_vel_x']) = vel_signal.Values.Data(:, 1);
        data_struct.([joint_name '_vel_y']) = vel_signal.Values.Data(:, 2);
        data_struct.([joint_name '_vel_z']) = vel_signal.Values.Data(:, 3);
    end
    
    % Find acceleration signals
    acc_signal = findSignalByName(signals, patterns, 'Acceleration');
    if ~isempty(acc_signal)
        data_struct.([joint_name '_acc_x']) = acc_signal.Values.Data(:, 1);
        data_struct.([joint_name '_acc_y']) = acc_signal.Values.Data(:, 2);
        data_struct.([joint_name '_acc_z']) = acc_signal.Values.Data(:, 3);
    end
end

% Convert to table
if length(fieldnames(data_struct)) > 1  % More than just time
    kinematics_data = struct2table(data_struct);
end

end

function torques_data = extractJointTorques(signals, time)
% Extract joint torques from Simscape signals
torques_data = [];

% Define torque signal patterns
torque_patterns = {
    'hip_torque', {'Hip', 'hip'};
    'spine_torque', {'Spine', 'spine'};
    'shoulder_torque', {'Shoulder', 'shoulder'};
    'elbow_torque', {'Elbow', 'elbow'};
    'wrist_torque', {'Wrist', 'wrist'};
};

% Initialize data structure
data_struct = struct();
data_struct.time = time;

% Extract torques for each joint
for torque_idx = 1:size(torque_patterns, 1)
    torque_name = torque_patterns{torque_idx, 1};
    patterns = torque_patterns{torque_idx, 2};
    
    % Find torque signals
    torque_signal = findSignalByName(signals, patterns, 'Torque');
    if ~isempty(torque_signal)
        data_struct.([torque_name '_x']) = torque_signal.Values.Data(:, 1);
        data_struct.([torque_name '_y']) = torque_signal.Values.Data(:, 2);
        data_struct.([torque_name '_z']) = torque_signal.Values.Data(:, 3);
    end
end

% Convert to table
if length(fieldnames(data_struct)) > 1  % More than just time
    torques_data = struct2table(data_struct);
end

end

function signal = findSignalByName(signals, patterns, signal_type)
% Find signal by name patterns
signal = [];

for i = 1:length(signals)
    signal_name = signals(i).Name;
    
    % Check if signal matches any pattern
    for j = 1:length(patterns)
        if contains(lower(signal_name), lower(patterns{j})) && ...
           contains(lower(signal_name), lower(signal_type))
            signal = signals(i);
            return;
        end
    end
end

end

function exportToCSV(kinematics_data, torques_data, output_dir, name, timestamp)
% Export data to CSV files
fprintf('\nExporting to CSV...\n');

% Export kinematics
kinematics_file = fullfile(output_dir, sprintf('%s_kinematics_%s.csv', name, timestamp));
writetable(kinematics_data, kinematics_file);
fprintf('✓ Kinematics: %s\n', kinematics_file);

% Export torques
torques_file = fullfile(output_dir, sprintf('%s_torques_%s.csv', name, timestamp));
writetable(torques_data, torques_file);
fprintf('✓ Torques: %s\n', torques_file);

% Create combined file for easy analysis
combined_data = [kinematics_data, torques_data(:, 2:end)];  % Remove duplicate time column
combined_file = fullfile(output_dir, sprintf('%s_combined_%s.csv', name, timestamp));
writetable(combined_data, combined_file);
fprintf('✓ Combined: %s\n', combined_file);

end

function exportToHDF5(kinematics_data, torques_data, output_dir, name, timestamp)
% Export data to HDF5 file
fprintf('\nExporting to HDF5...\n');

hdf5_file = fullfile(output_dir, sprintf('%s_dataset_%s.h5', name, timestamp));

% Convert tables to arrays for HDF5
kinematics_array = table2array(kinematics_data);
torques_array = table2array(torques_data);

% Get column names
kinematics_cols = kinematics_data.Properties.VariableNames;
torques_cols = torques_data.Properties.VariableNames;

% Save to HDF5
h5create(hdf5_file, '/kinematics/data', size(kinematics_array));
h5write(hdf5_file, '/kinematics/data', kinematics_array);

h5create(hdf5_file, '/torques/data', size(torques_array));
h5write(hdf5_file, '/torques/data', torques_array);

% Save column names as attributes
h5writeatt(hdf5_file, '/kinematics/data', 'columns', kinematics_cols);
h5writeatt(hdf5_file, '/torques/data', 'columns', torques_cols);

fprintf('✓ HDF5: %s\n', hdf5_file);

end

function createPythonHelper(output_dir, name, timestamp)
% Create Python helper script
python_script = fullfile(output_dir, sprintf('load_dataset_%s.py', timestamp));

script_content = sprintf([...
'#!/usr/bin/env python3\n', ...
'"""\n', ...
'Python helper script to load golf swing dataset\n', ...
'Generated: %s\n', ...
'"""\n\n', ...
'import pandas as pd\n', ...
'import numpy as np\n', ...
'import h5py\n', ...
'import matplotlib.pyplot as plt\n', ...
'from pathlib import Path\n\n', ...
'def load_csv_dataset(base_name="%s", timestamp="%s"):\n', ...
'    """Load dataset from CSV files"""\n', ...
'    data_dir = Path(".")\n', ...
'    \n', ...
'    # Load kinematics\n', ...
'    kinematics_file = data_dir / f"{base_name}_kinematics_{timestamp}.csv"\n', ...
'    kinematics = pd.read_csv(kinematics_file)\n', ...
'    \n', ...
'    # Load torques\n', ...
'    torques_file = data_dir / f"{base_name}_torques_{timestamp}.csv"\n', ...
'    torques = pd.read_csv(torques_file)\n', ...
'    \n', ...
'    # Load combined\n', ...
'    combined_file = data_dir / f"{base_name}_combined_{timestamp}.csv"\n', ...
'    combined = pd.read_csv(combined_file)\n', ...
'    \n', ...
'    return kinematics, torques, combined\n\n', ...
'def load_hdf5_dataset(base_name="%s", timestamp="%s"):\n', ...
'    """Load dataset from HDF5 file"""\n', ...
'    data_dir = Path(".")\n', ...
'    hdf5_file = data_dir / f"{base_name}_dataset_{timestamp}.h5"\n', ...
'    \n', ...
'    with h5py.File(hdf5_file, "r") as f:\n', ...
'        # Load data\n', ...
'        kinematics_data = f["/kinematics/data"][:]\n', ...
'        torques_data = f["/torques/data"][:]\n', ...
'        \n', ...
'        # Get column names\n', ...
'        kinematics_cols = f["/kinematics/data"].attrs["columns"]\n', ...
'        torques_cols = f["/torques/data"].attrs["columns"]\n', ...
'        \n', ...
'        # Convert to DataFrames\n', ...
'        kinematics = pd.DataFrame(kinematics_data, columns=kinematics_cols)\n', ...
'        torques = pd.DataFrame(torques_data, columns=torques_cols)\n', ...
'    \n', ...
'    return kinematics, torques\n\n', ...
'def plot_sample_data(kinematics, torques, simulation_id=1):\n', ...
'    """Plot sample data for a specific simulation"""\n', ...
'    # Filter data for specific simulation\n', ...
'    sim_kin = kinematics[kinematics.simulation_id == simulation_id]\n', ...
'    sim_torq = torques[torques.simulation_id == simulation_id]\n', ...
'    \n', ...
'    fig, axes = plt.subplots(2, 2, figsize=(12, 8))\n', ...
'    \n', ...
'    # Plot hip position\n', ...
'    axes[0,0].plot(sim_kin.time, sim_kin.hip_pos_x, label="X")\n', ...
'    axes[0,0].plot(sim_kin.time, sim_kin.hip_pos_y, label="Y")\n', ...
'    axes[0,0].plot(sim_kin.time, sim_kin.hip_pos_z, label="Z")\n', ...
'    axes[0,0].set_title("Hip Position")\n', ...
'    axes[0,0].set_xlabel("Time (s)")\n', ...
'    axes[0,0].set_ylabel("Position (m)")\n', ...
'    axes[0,0].legend()\n', ...
'    \n', ...
'    # Plot hip torques\n', ...
'    axes[0,1].plot(sim_torq.time, sim_torq.hip_torque_x, label="X")\n', ...
'    axes[0,1].plot(sim_torq.time, sim_torq.hip_torque_y, label="Y")\n', ...
'    axes[0,1].plot(sim_torq.time, sim_torq.hip_torque_z, label="Z")\n', ...
'    axes[0,1].set_title("Hip Torques")\n', ...
'    axes[0,1].set_xlabel("Time (s)")\n', ...
'    axes[0,1].set_ylabel("Torque (N⋅m)")\n', ...
'    axes[0,1].legend()\n', ...
'    \n', ...
'    # Plot shoulder position\n', ...
'    axes[1,0].plot(sim_kin.time, sim_kin.shoulder_pos_x, label="X")\n', ...
'    axes[1,0].plot(sim_kin.time, sim_kin.shoulder_pos_y, label="Y")\n', ...
'    axes[1,0].plot(sim_kin.time, sim_kin.shoulder_pos_z, label="Z")\n', ...
'    axes[1,0].set_title("Shoulder Position")\n', ...
'    axes[1,0].set_xlabel("Time (s)")\n', ...
'    axes[1,0].set_ylabel("Position (m)")\n', ...
'    axes[1,0].legend()\n', ...
'    \n', ...
'    # Plot shoulder torques\n', ...
'    axes[1,1].plot(sim_torq.time, sim_torq.shoulder_torque_x, label="X")\n', ...
'    axes[1,1].plot(sim_torq.time, sim_torq.shoulder_torque_y, label="Y")\n', ...
'    axes[1,1].plot(sim_torq.time, sim_torq.shoulder_torque_z, label="Z")\n', ...
'    axes[1,1].set_title("Shoulder Torques")\n', ...
'    axes[1,1].set_xlabel("Time (s)")\n', ...
'    axes[1,1].set_ylabel("Torque (N⋅m)")\n', ...
'    axes[1,1].legend()\n', ...
'    \n', ...
'    plt.tight_layout()\n', ...
'    plt.show()\n\n', ...
'if __name__ == "__main__":\n', ...
'    # Example usage\n', ...
'    print("Loading dataset...")\n', ...
'    try:\n', ...
'        kinematics, torques, combined = load_csv_dataset()\n', ...
'        print(f"✓ Loaded {len(kinematics)} data points")\n', ...
'        print(f"✓ {kinematics.simulation_id.nunique()} simulations")\n', ...
'        print(f"✓ Time range: {kinematics.time.min():.3f} to {kinematics.time.max():.3f} seconds")\n', ...
'        \n', ...
'        # Plot sample data\n', ...
'        plot_sample_data(kinematics, torques, simulation_id=1)\n', ...
'        \n', ...
'    except FileNotFoundError as e:\n', ...
'        print(f"✗ Error: {e}")\n', ...
'        print("Make sure you are in the correct directory with the exported files.")\n'], ...
datestr(now), name, timestamp, name, timestamp, name, timestamp);

% Write Python script
fid = fopen(python_script, 'w');
fprintf(fid, '%s', script_content);
fclose(fid);

fprintf('✓ Python helper: %s\n', python_script);

end 