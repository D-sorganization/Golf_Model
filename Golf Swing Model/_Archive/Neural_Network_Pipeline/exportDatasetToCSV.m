% exportDatasetToCSV.m
% Export the generated dataset to CSV format for easy inspection

clear; clc;

fprintf('=== Exporting Dataset to CSV ===\n\n');

% Find the most recent dataset file
files = dir('golf_swing_dataset_*.mat');
if isempty(files)
    % Try alternative naming patterns
    files = dir('test_dataset_*.mat');
    if isempty(files)
        files = dir('*dataset*.mat');
        if isempty(files)
            fprintf('No dataset files found\n');
            fprintf('Looking for files with patterns: golf_swing_dataset_*.mat, test_dataset_*.mat, *dataset*.mat\n');
            return;
        end
    end
end

% Sort by date and get the most recent
[~, idx] = sort([files.datenum], 'descend');
latest_file = files(idx(1)).name;

fprintf('Loading dataset: %s\n', latest_file);
load(latest_file);

% Find the most recent training data file
files = dir('*training_data_*.mat');
if ~isempty(files)
    [~, idx] = sort([files.datenum], 'descend');
    latest_training_file = files(idx(1)).name;
    fprintf('Loading training data: %s\n', latest_training_file);
    load(latest_training_file);
end

%% Export individual simulation data to CSV
fprintf('\nExporting individual simulation data...\n');

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
        
        % Save to CSV
        csv_filename = sprintf('simulation_%d_data_%s.csv', sim_idx, datestr(now, 'yyyymmdd_HHMMSS'));
        writetable(sim_table, csv_filename);
        fprintf('  ✓ Saved: %s (%d rows, %d columns)\n', csv_filename, size(sim_table, 1), size(sim_table, 2));
    end
end

%% Export training data to CSV
if exist('training_data', 'var')
    fprintf('\nExporting training data...\n');
    
    % Create feature names
    feature_names = {};
    joint_names = {'Joint_1', 'Joint_2', 'Joint_3', 'Joint_4', 'Joint_5', 'Joint_6', 'Joint_7', 'Joint_8', ...
                   'Joint_9', 'Joint_10', 'Joint_11', 'Joint_12', 'Joint_13', 'Joint_14', 'Joint_15', 'Joint_16', ...
                   'Joint_17', 'Joint_18', 'Joint_19', 'Joint_20', 'Joint_21', 'Joint_22', 'Joint_23', 'Joint_24', ...
                   'Joint_25', 'Joint_26', 'Joint_27', 'Joint_28'};
    
    % Add position feature names
    for i = 1:28
        feature_names{end+1} = sprintf('%s_pos_deg', joint_names{i});
    end
    
    % Add velocity feature names
    for i = 1:28
        feature_names{end+1} = sprintf('%s_vel_deg_s', joint_names{i});
    end
    
    % Add torque feature names
    for i = 1:28
        feature_names{end+1} = sprintf('%s_torque_Nm', joint_names{i});
    end
    
    % Create target names
    target_names = {};
    for i = 1:28
        target_names{end+1} = sprintf('%s_acc_deg_s2', joint_names{i});
    end
    
    % Create feature table
    feature_table = array2table(training_data.X, 'VariableNames', feature_names);
    feature_filename = sprintf('training_features_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
    writetable(feature_table, feature_filename);
    fprintf('  ✓ Saved: %s (%d rows, %d columns)\n', feature_filename, size(feature_table, 1), size(feature_table, 2));
    
    % Create target table
    target_table = array2table(training_data.Y, 'VariableNames', target_names);
    target_filename = sprintf('training_targets_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
    writetable(target_table, target_filename);
    fprintf('  ✓ Saved: %s (%d rows, %d columns)\n', target_filename, size(target_table, 1), size(target_table, 2));
    
    % Create combined training table
    combined_table = [feature_table, target_table];
    combined_filename = sprintf('training_data_combined_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
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
summary_filename = sprintf('dataset_summary_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
writetable(summary_table, summary_filename);
fprintf('  ✓ Saved: %s\n', summary_filename);

fprintf('\n=== Export Complete ===\n');
fprintf('All CSV files have been created for easy inspection.\n');
fprintf('You can open these files in Excel or any spreadsheet application.\n'); 