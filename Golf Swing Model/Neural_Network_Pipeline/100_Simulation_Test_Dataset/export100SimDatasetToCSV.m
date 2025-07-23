% export100SimDatasetToCSV.m
% Export the 100-simulation dataset to CSV format for easy inspection

clear; clc;

fprintf('=== Exporting 100-Simulation Dataset to CSV ===\n\n');

% Find the most recent 100-simulation dataset file
files = dir('100_sim_dataset_*.mat');
if isempty(files)
    fprintf('No 100-simulation dataset files found\n');
    return;
end

% Sort by date and get the most recent
[~, idx] = sort([files.datenum], 'descend');
latest_file = files(idx(1)).name;

fprintf('Loading dataset: %s\n', latest_file);
load(latest_file);

% Find the most recent training data file
files = dir('100_sim_training_data_*.mat');
if ~isempty(files)
    [~, idx] = sort([files.datenum], 'descend');
    latest_training_file = files(idx(1)).name;
    fprintf('Loading training data: %s\n', latest_training_file);
    load(latest_training_file);
end

%% Export individual simulation data to CSV
fprintf('\nExporting individual simulation data...\n');

% Create a subfolder for individual simulation files
if ~exist('individual_simulations', 'dir')
    mkdir('individual_simulations');
end

for sim_idx = 1:length(dataset.simulations)
    if dataset.success_flags(sim_idx)
        sim_data = dataset.simulations{sim_idx};
        
        % Create time column
        time_data = sim_data.time;
        
        % Create joint position columns
        joint_positions = sim_data.q;
        
        % Create joint velocity columns
        joint_velocities = sim_data.qd;
        
        % Create joint acceleration columns
        joint_accelerations = sim_data.qdd;
        
        % Create joint torque columns
        joint_torques = sim_data.tau;
        
        % Create mid-hands position columns
        midhands_position = sim_data.MH;
        
        % Create column names
        joint_names = sim_data.signal_names.simplified_names;
        
        % Create comprehensive table
        table_data = [time_data, joint_positions, joint_velocities, joint_accelerations, joint_torques, midhands_position];
        
        % Create column headers
        headers = {'Time_s'};
        
        % Add joint position headers
        for i = 1:length(joint_names)
            headers{end+1} = sprintf('%s_pos_deg', joint_names{i});
        end
        
        % Add joint velocity headers
        for i = 1:length(joint_names)
            headers{end+1} = sprintf('%s_vel_deg_s', joint_names{i});
        end
        
        % Add joint acceleration headers
        for i = 1:length(joint_names)
            headers{end+1} = sprintf('%s_acc_deg_s2', joint_names{i});
        end
        
        % Add joint torque headers
        for i = 1:length(joint_names)
            headers{end+1} = sprintf('%s_torque_Nm', joint_names{i});
        end
        
        % Add mid-hands position headers
        headers{end+1} = 'Midhands_X_m';
        headers{end+1} = 'Midhands_Y_m';
        headers{end+1} = 'Midhands_Z_m';
        
        % Create table
        sim_table = array2table(table_data, 'VariableNames', headers);
        
        % Save to CSV in subfolder
        csv_filename = sprintf('individual_simulations/simulation_%03d_data.csv', sim_idx);
        writetable(sim_table, csv_filename);
        
        if mod(sim_idx, 10) == 0
            fprintf('  ✓ Saved simulation %d/100\n', sim_idx);
        end
    end
end

fprintf('  ✓ All individual simulation files saved in individual_simulations/ folder\n');

%% Export training data to CSV
if exist('training_data', 'var')
    fprintf('\nExporting training data...\n');
    
    % Create feature names
    feature_names = {};
    joint_names = sim_data.signal_names.simplified_names;
    
    % Add position feature names
    for i = 1:length(joint_names)
        feature_names{end+1} = sprintf('%s_pos_deg', joint_names{i});
    end
    
    % Add velocity feature names
    for i = 1:length(joint_names)
        feature_names{end+1} = sprintf('%s_vel_deg_s', joint_names{i});
    end
    
    % Add torque feature names
    for i = 1:length(joint_names)
        feature_names{end+1} = sprintf('%s_torque_Nm', joint_names{i});
    end
    
    % Create target names
    target_names = {};
    for i = 1:length(joint_names)
        target_names{end+1} = sprintf('%s_acc_deg_s2', joint_names{i});
    end
    
    % Create feature table
    feature_table = array2table(training_data.X, 'VariableNames', feature_names);
    feature_filename = 'training_features_100sim.csv';
    writetable(feature_table, feature_filename);
    fprintf('  ✓ Saved: %s (%d rows, %d columns)\n', feature_filename, size(feature_table, 1), size(feature_table, 2));
    
    % Create target table
    target_table = array2table(training_data.Y, 'VariableNames', target_names);
    target_filename = 'training_targets_100sim.csv';
    writetable(target_table, target_filename);
    fprintf('  ✓ Saved: %s (%d rows, %d columns)\n', target_filename, size(target_table, 1), size(target_table, 2));
    
    % Create combined training table
    combined_table = [feature_table, target_table];
    combined_filename = 'training_data_combined_100sim.csv';
    writetable(combined_table, combined_filename);
    fprintf('  ✓ Saved: %s (%d rows, %d columns)\n', combined_filename, size(combined_table, 1), size(combined_table, 2));
end

%% Create summary table
fprintf('\nCreating summary table...\n');

% Create summary data
summary_data = [];
summary_headers = {'Metric', 'Value', 'Units'};

% Dataset info
summary_data = [summary_data; {'Number of Simulations', length(dataset.simulations), 'count'}];
summary_data = [summary_data; {'Successful Simulations', sum(dataset.success_flags), 'count'}];
summary_data = [summary_data; {'Simulation Duration', dataset.config.simulation_duration, 'seconds'}];
summary_data = [summary_data; {'Sample Rate', dataset.config.sample_rate, 'Hz'}];
summary_data = [summary_data; {'Time Points per Simulation', dataset.config.simulation_duration * dataset.config.sample_rate + 1, 'count'}];
summary_data = [summary_data; {'Total Time Points', length(dataset.simulations) * (dataset.config.simulation_duration * dataset.config.sample_rate + 1), 'count'}];

if exist('training_data', 'var')
    summary_data = [summary_data; {'Training Samples', training_data.metadata.n_samples, 'count'}];
    summary_data = [summary_data; {'Training Features', training_data.metadata.n_features, 'count'}];
    summary_data = [summary_data; {'Training Targets', training_data.metadata.n_targets, 'count'}];
end

% Check ranges from first simulation
if ~isempty(dataset.simulations) && dataset.success_flags(1)
    sim1 = dataset.simulations{1};
    summary_data = [summary_data; {'Joint Positions Range', sprintf('[%.1f, %.1f]', min(sim1.q(:)), max(sim1.q(:))), 'degrees'}];
    summary_data = [summary_data; {'Joint Velocities Range', sprintf('[%.1f, %.1f]', min(sim1.qd(:)), max(sim1.qd(:))), 'degrees/s'}];
    summary_data = [summary_data; {'Joint Accelerations Range', sprintf('[%.1f, %.1f]', min(sim1.qdd(:)), max(sim1.qdd(:))), 'degrees/s²'}];
    summary_data = [summary_data; {'Joint Torques Range', sprintf('[%.1f, %.1f]', min(sim1.tau(:)), max(sim1.tau(:))), 'Nm'}];
end

% Create summary table
summary_table = cell2table(summary_data, 'VariableNames', summary_headers);
summary_filename = 'dataset_summary_100sim.csv';
writetable(summary_table, summary_filename);
fprintf('  ✓ Saved: %s\n', summary_filename);

%% Create joint mapping table
fprintf('\nCreating joint mapping table...\n');

% Create joint mapping data
joint_mapping_data = [];
joint_mapping_headers = {'Joint_Index', 'Simplified_Name', 'Simulink_Position_Signal', 'Simulink_Velocity_Signal'};

if ~isempty(dataset.simulations) && dataset.success_flags(1)
    sim1 = dataset.simulations{1};
    joint_names = sim1.signal_names.simplified_names;
    simulink_pos = sim1.signal_names.simulink_positions;
    simulink_vel = sim1.signal_names.simulink_velocities;
    
    for i = 1:length(joint_names)
        pos_signal = '';
        vel_signal = '';
        
        if i <= length(simulink_pos)
            pos_signal = simulink_pos{i};
        end
        
        if i <= length(simulink_vel)
            vel_signal = simulink_vel{i};
        end
        
        joint_mapping_data = [joint_mapping_data; {i, joint_names{i}, pos_signal, vel_signal}];
    end
end

% Create joint mapping table
joint_mapping_table = cell2table(joint_mapping_data, 'VariableNames', joint_mapping_headers);
joint_mapping_filename = 'joint_mapping_100sim.csv';
writetable(joint_mapping_table, joint_mapping_filename);
fprintf('  ✓ Saved: %s\n', joint_mapping_filename);

fprintf('\n=== Export Complete ===\n');
fprintf('All CSV files have been created for easy inspection:\n');
fprintf('  - Individual simulation files: individual_simulations/simulation_XXX_data.csv\n');
fprintf('  - Training features: training_features_100sim.csv\n');
fprintf('  - Training targets: training_targets_100sim.csv\n');
fprintf('  - Combined training data: training_data_combined_100sim.csv\n');
fprintf('  - Dataset summary: dataset_summary_100sim.csv\n');
fprintf('  - Joint mapping: joint_mapping_100sim.csv\n');
fprintf('\nYou can open these files in Excel or any spreadsheet application.\n'); 