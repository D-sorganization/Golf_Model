function generateSimulationTrainingData()
% generateSimulationTrainingData.m
% Comprehensive golf swing simulation training data generator
% Generates individual CSV files for each trial with complete data tables
% No truncated bullshit - full comprehensive datasets

fprintf('=== Golf Swing Training Data Generator (CSV Version) ===\n\n');

%% Workspace Cleanup Setup
% Save current workspace state to restore later
% Get variables from base workspace before we start
initial_vars = evalin('base', 'who');
% Store initial_vars in base workspace for later cleanup
assignin('base', 'initial_vars_backup', initial_vars);

% Save current warning state for restoration later
warning_state = warning('query', 'all');
assignin('base', 'warning_state_backup', warning_state);

% Suppress common Simulink warnings that clutter output
warning('off', 'Simulink:Simulation:DesktopSimHelper');
warning('off', 'SimscapeMultibody:Explorer:UnableToLaunchExplorer');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

%% Initialize Performance Tracking
performance_metrics = struct();
performance_metrics.start_time = tic;
performance_metrics.trial_times = [];
performance_metrics.successful_trials = 0;
performance_metrics.failed_trials = 0;
performance_metrics.total_data_points = 0;
performance_metrics.total_columns = 0;

%% Get User Configuration
fprintf('=== Configuration Setup ===\n\n');

% Prompt for number of trials
while true
    num_trials_str = input('Enter number of trials to run (default: 10): ', 's');
    if isempty(num_trials_str)
        config.num_simulations = 10;
        break;
    else
        config.num_simulations = str2double(num_trials_str);
        if ~isnan(config.num_simulations) && config.num_simulations > 0 && config.num_simulations == round(config.num_simulations)
            break;
        else
            fprintf('Please enter a valid positive integer.\n');
        end
    end
end

% Prompt for simulation duration
while true
    sim_time_str = input('Enter simulation duration in seconds (default: 0.3): ', 's');
    if isempty(sim_time_str)
        config.simulation_time = 0.3;
        break;
    else
        config.simulation_time = str2double(sim_time_str);
        if ~isnan(config.simulation_time) && config.simulation_time > 0
            break;
        else
            fprintf('Please enter a valid positive number.\n');
        end
    end
end

% Prompt for data folder location using popup dialog
fprintf('Select folder location for trial data...\n');
folder_location = uigetdir(pwd, 'Select folder location for trial data');

if folder_location == 0
    % User cancelled the dialog
    fprintf('Folder selection cancelled by user.\n');
    return;
end

fprintf('✓ Selected folder location: %s\n', folder_location);

% Prompt for folder name
while true
    folder_name = input('Enter folder name for trial data (default: training_data_csv): ', 's');
    if isempty(folder_name)
        folder_name = 'training_data_csv';
    end

    % Create full path
    config.output_folder = fullfile(folder_location, folder_name);

    % Check if folder exists or can be created
    if exist(config.output_folder, 'dir')
        overwrite = input('Folder already exists. Overwrite existing data? (y/n): ', 's');
        if strcmpi(overwrite, 'y') || strcmpi(overwrite, 'yes')
            % Remove existing folder and recreate
            try
                rmdir(config.output_folder, 's');
                mkdir(config.output_folder);
                fprintf('✓ Recreated folder: %s\n', config.output_folder);
                break;
            catch ME
                fprintf('✗ Could not recreate folder: %s\n', ME.message);
            end
        else
            fprintf('Please choose a different folder name.\n');
        end
    else
        try
            mkdir(config.output_folder);
            fprintf('✓ Created folder: %s\n', config.output_folder);
            break;
        catch ME
            fprintf('✗ Could not create folder: %s\n', ME.message);
        end
    end
end

% Prompt for sample rate
while true
    sample_rate_str = input('Enter sample rate in Hz (default: 100): ', 's');
    if isempty(sample_rate_str)
        config.sample_rate = 100;
        break;
    else
        config.sample_rate = str2double(sample_rate_str);
        if ~isnan(config.sample_rate) && config.sample_rate > 0 && config.sample_rate == round(config.sample_rate)
            break;
        else
            fprintf('Please enter a valid positive integer.\n');
        end
    end
end

% Set other configuration parameters
config.model_name = 'GolfSwing3D_Kinetic';  % Model name (fixed)

% Ask user about parallel execution
fprintf('\nExecution Mode:\n');
fprintf('  1. Parallel (faster, uses all CPU cores)\n');
fprintf('  2. Sequential (slower, but more stable)\n');
while true
    exec_mode = input('Choose execution mode (1 or 2, default: 1): ', 's');
    if isempty(exec_mode)
        config.use_parallel = true;
        break;
    elseif strcmp(exec_mode, '1')
        config.use_parallel = true;
        break;
    elseif strcmp(exec_mode, '2')
        config.use_parallel = false;
        break;
    else
        fprintf('Please enter 1 or 2.\n');
    end
end

fprintf('\n=== Configuration Summary ===\n');
fprintf('  Number of trials: %d\n', config.num_simulations);
fprintf('  Simulation duration: %.1f seconds\n', config.simulation_time);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Output folder: %s\n', config.output_folder);
fprintf('  Model: %s\n', config.model_name);
if config.use_parallel
    fprintf('  Execution mode: Parallel\n');
else
    fprintf('  Execution mode: Sequential\n');
end
fprintf('  Output format: CSV files (full data tables)\n');

% Confirm with user
confirm = input('\nStart generation with these settings? (y/n): ', 's');
if ~(strcmpi(confirm, 'y') || strcmpi(confirm, 'yes'))
    fprintf('Generation cancelled by user.\n');
    % Clean up before returning
    performEmergencyCleanup();
    return;
end

fprintf('\n');

%% Main Execution Block with Error Handling
try

%% Check for parallel computing availability
if config.use_parallel
    fprintf('=== Parallel Computing Setup ===\n');
    try
        % Try to start parallel pool
        pool = gcp('nocreate');
        if isempty(pool)
            fprintf('Starting parallel pool...\n');
            parpool('local');
            fprintf('✓ Parallel pool started\n');
        else
            fprintf('✓ Using existing parallel pool with %d workers\n', pool.NumWorkers);
        end
        use_parallel = true;
        fprintf('✓ Parallel computing enabled\n');
    catch ME
        fprintf('⚠️  Parallel computing not available: %s\n', ME.message);
        fprintf('  Falling back to sequential execution\n');
        use_parallel = false;
    end
else
    fprintf('=== Sequential Execution Mode ===\n');
    fprintf('✓ Sequential execution selected by user\n');
    use_parallel = false;
end

%% Run Simulations
fprintf('\n=== Running Simulations ===\n');

% Initialize progress tracking
progress = struct();
progress.current_trial = 0;

if use_parallel
    % Parallel execution with progress tracking
    fprintf('Running simulations in parallel...\n');

    % Create array to store results
    trial_results = cell(config.num_simulations, 1);

    % Run simulations in parallel
    parfor sim_idx = 1:config.num_simulations
        try
            fprintf('Worker: Starting trial %d...\n', sim_idx);
            trial_start_time = tic;
            [trial_result, ~] = runSingleTrialWithCSV(sim_idx, config); % Don't capture signal_names in parfor
            trial_time = toc(trial_start_time);

            % Store trial result in cell array - ensure it's properly structured
            if ~isempty(trial_result)
                trial_result.trial_time = trial_time;
                trial_results{sim_idx} = trial_result;
            else
                trial_results{sim_idx} = struct('success', false, 'trial_time', trial_time);
            end

            fprintf('Worker: Trial %d completed in %.2f seconds\n', sim_idx, trial_time);

        catch ME
            fprintf('Worker: Simulation %d failed: %s\n', sim_idx, ME.message);
            % Store failed result
            trial_results{sim_idx} = struct('success', false, 'trial_time', 0);
        end
    end

    % Process results and collect metrics
    for sim_idx = 1:config.num_simulations
        result = trial_results{sim_idx};
        if ~isempty(result) && isfield(result, 'success') && result.success
            performance_metrics.successful_trials = performance_metrics.successful_trials + 1;
            performance_metrics.trial_times = [performance_metrics.trial_times, result.trial_time];
            performance_metrics.total_data_points = performance_metrics.total_data_points + result.data_points;
            performance_metrics.total_columns = result.columns;

            fprintf('✓ Trial %d completed successfully (%.2f seconds)\n', sim_idx, result.trial_time);
            fprintf('  CSV file: %s\n', result.filename);
            fprintf('  Data points: %d, Columns: %d\n', result.data_points, result.columns);
        else
            performance_metrics.failed_trials = performance_metrics.failed_trials + 1;
            fprintf('✗ Trial %d failed\n', sim_idx);
        end
    end

else
    % Sequential execution with detailed progress tracking
    fprintf('Running simulations sequentially...\n');

    for sim_idx = 1:config.num_simulations
    progress.current_trial = sim_idx;

    % Calculate progress and ETA
    if sim_idx > 1
        progress.avg_trial_time = mean(performance_metrics.trial_times);
        remaining_trials = config.num_simulations - sim_idx;
        progress.eta_estimate = remaining_trials * progress.avg_trial_time;

        fprintf('\n--- Trial %d/%d (%.1f%% complete) ---\n', sim_idx, config.num_simulations, (sim_idx-1)/config.num_simulations*100);
        fprintf('Average trial time: %.2f seconds\n', progress.avg_trial_time);
        fprintf('Estimated time remaining: %.1f minutes\n', progress.eta_estimate/60);
    else
        fprintf('\n--- Trial %d/%d ---\n', sim_idx, config.num_simulations);
    end

    try
        trial_start_time = tic;
        [result, signal_names] = runSingleTrialWithCSV(sim_idx, config);
        trial_time = toc(trial_start_time);

        if ~isempty(result)
            performance_metrics.successful_trials = performance_metrics.successful_trials + 1;
            performance_metrics.trial_times = [performance_metrics.trial_times, trial_time];
            performance_metrics.total_data_points = performance_metrics.total_data_points + result.data_points;
            performance_metrics.total_columns = result.columns;

            fprintf('✓ Trial %d completed successfully (%.2f seconds)\n', sim_idx, trial_time);
            fprintf('  CSV file: %s\n', result.filename);
            fprintf('  Data points: %d, Columns: %d\n', result.data_points, result.columns);

        else
            performance_metrics.failed_trials = performance_metrics.failed_trials + 1;
            fprintf('✗ Trial %d failed\n', sim_idx);
        end

    catch ME
        performance_metrics.failed_trials = performance_metrics.failed_trials + 1;
        fprintf('✗ Simulation %d failed: %s\n', sim_idx, ME.message);
    end
    end % End of sequential for loop
end % End of if use_parallel

%% Calculate Final Performance Metrics
performance_metrics.total_time = toc(performance_metrics.start_time);

% Ensure success_rate is always calculated even if no trials completed
if isfield(performance_metrics, 'successful_trials') && config.num_simulations > 0
    performance_metrics.success_rate = (performance_metrics.successful_trials / config.num_simulations) * 100;
else
    performance_metrics.success_rate = 0;
end

if ~isempty(performance_metrics.trial_times)
    performance_metrics.avg_trial_time = mean(performance_metrics.trial_times);
    performance_metrics.min_trial_time = min(performance_metrics.trial_times);
    performance_metrics.max_trial_time = max(performance_metrics.trial_times);
    performance_metrics.std_trial_time = std(performance_metrics.trial_times);
else
    performance_metrics.avg_trial_time = 0;
    performance_metrics.min_trial_time = 0;
    performance_metrics.max_trial_time = 0;
    performance_metrics.std_trial_time = 0;
end

%% Generate Final Summary
fprintf('\n=== Final Summary ===\n');
fprintf('Total trials attempted: %d\n', config.num_simulations);
fprintf('Successful trials: %d\n', performance_metrics.successful_trials);
fprintf('Failed trials: %d\n', performance_metrics.failed_trials);
fprintf('Success rate: %.1f%%\n', performance_metrics.success_rate);
fprintf('\n');

fprintf('Performance Metrics:\n');
fprintf('  Total execution time: %.2f seconds (%.2f minutes)\n', performance_metrics.total_time, performance_metrics.total_time/60);
fprintf('  Average trial time: %.2f seconds\n', performance_metrics.avg_trial_time);
fprintf('  Min trial time: %.2f seconds\n', performance_metrics.min_trial_time);
fprintf('  Max trial time: %.2f seconds\n', performance_metrics.max_trial_time);
fprintf('  Trial time std dev: %.2f seconds\n', performance_metrics.std_trial_time);
fprintf('\n');

fprintf('Data Generated:\n');
fprintf('  Total data points: %d\n', performance_metrics.total_data_points);
fprintf('  Data columns per trial: %d\n', performance_metrics.total_columns);
if performance_metrics.successful_trials > 0
    fprintf('  Average data points per trial: %d\n', performance_metrics.total_data_points / performance_metrics.successful_trials);
end
fprintf('\n');

fprintf('Files Created:\n');
fprintf('  CSV trial files: %d files\n', performance_metrics.successful_trials);

fprintf('\n=== Generation Complete ===\n');
fprintf('All CSV files have been created in: %s\n', config.output_folder);
fprintf('Each CSV file contains a complete data table with all simulation data.\n');

catch ME_main
    % Handle any errors during main execution
    fprintf('\n✗ Critical error during execution: %s\n', ME_main.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME_main.stack)
        fprintf('  %s (line %d)\n', ME_main.stack(i).name, ME_main.stack(i).line);
    end
    fprintf('\nPerforming emergency cleanup...\n');

    % Try to save any partial performance data
    try
        if exist('config', 'var') && exist('performance_metrics', 'var')
            % Ensure required fields exist before saving
            if ~isfield(performance_metrics, 'success_rate')
                if isfield(performance_metrics, 'successful_trials') && exist('config', 'var')
                    performance_metrics.success_rate = (performance_metrics.successful_trials / config.num_simulations) * 100;
                else
                    performance_metrics.success_rate = 0;
                end
            end
            if ~isfield(performance_metrics, 'total_time')
                performance_metrics.total_time = 0;
            end
        end
    catch
        % Continue with cleanup even if saving fails
    end
end

%% Clean up workspace
fprintf('\n=== Cleaning up workspace ===\n');

try
    % First, clean up Simulink-specific items
    fprintf('Cleaning up Simulink states...\n');

    % Clear Simulation Data Inspector runs
    try
        Simulink.sdi.clear();
        fprintf('✓ Cleared Simulation Data Inspector runs\n');
    catch
        fprintf('⚠️  Could not clear SDI runs (may not be available)\n');
    end

    % Close any open Simulink models that might have been opened during simulation
    try
        models = find_system('Type', 'block_diagram');
        for i = 1:length(models)
            if ~strcmp(models{i}, 'simulink') % Don't close the main Simulink library
                try
                    close_system(models{i}, 0); % Close without saving
                catch
                    % Model might already be closed or protected
                end
            end
        end
        fprintf('✓ Closed temporary Simulink models\n');
    catch
        fprintf('⚠️  Could not close Simulink models\n');
    end

    % Clean up parallel pool if we started it
    if exist('use_parallel', 'var') && use_parallel
        try
            pool = gcp('nocreate');
            if ~isempty(pool)
                delete(pool);
                fprintf('✓ Closed parallel pool\n');
            end
        catch
            fprintf('⚠️  Could not close parallel pool\n');
        end
    end

    % Clean up base workspace variables
    fprintf('Cleaning up base workspace variables...\n');
    if evalin('base', 'exist(''initial_vars_backup'', ''var'')')
        % Get the initial variables list
        initial_vars_backup = evalin('base', 'initial_vars_backup');

        % Get current variables in base workspace
        current_vars = evalin('base', 'who');

        % Find variables to remove (current vars that weren't in initial list)
        vars_to_remove = setdiff(current_vars, initial_vars_backup);

        % Also remove our backup variables
        vars_to_remove = union(vars_to_remove, {'initial_vars_backup', 'warning_state_backup'});

        if ~isempty(vars_to_remove)
            % Remove the variables
            for i = 1:length(vars_to_remove)
                try
                    evalin('base', ['clear ', vars_to_remove{i}]);
                catch
                    % Variable might already be cleared or protected
                end
            end
            fprintf('✓ Cleared %d temporary variables from base workspace\n', length(vars_to_remove));
            if length(vars_to_remove) <= 10  % Only show details if not too many
                fprintf('  Removed variables: %s\n', strjoin(vars_to_remove, ', '));
            end
        else
            fprintf('✓ No temporary variables to clear from base workspace\n');
        end
    else
        fprintf('⚠️  No initial_vars_backup found. Performing basic cleanup...\n');

        % Fallback: remove common temporary variables that this script creates
        common_temp_vars = {'config', 'performance_metrics', 'progress', 'trial_results', ...
                          'simInput', 'simOut', 'use_parallel', 'pool', 'confirm', ...
                          'num_trials_str', 'sim_time_str', 'folder_location', 'folder_name', ...
                          'sample_rate_str', 'exec_mode', 'overwrite', 'fid', 'ME', ...
                          'initial_vars_backup', 'warning_state_backup'};

        for i = 1:length(common_temp_vars)
            if evalin('base', ['exist(''', common_temp_vars{i}, ''', ''var'')'])
                try
                    evalin('base', ['clear ', common_temp_vars{i}]);
                catch
                    % Continue if variable can't be cleared
                end
            end
        end
        fprintf('✓ Cleared common temporary variables from base workspace\n');
    end

    % Restore warning state
    fprintf('Restoring warning settings...\n');
    try
        if evalin('base', 'exist(''warning_state_backup'', ''var'')')
            warning_state_backup = evalin('base', 'warning_state_backup');
            warning(warning_state_backup);
            fprintf('✓ Restored original warning settings\n');
        else
            % Restore commonly suppressed warnings
            warning('on', 'Simulink:Simulation:DesktopSimHelper');
            warning('on', 'SimscapeMultibody:Explorer:UnableToLaunchExplorer');
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
            fprintf('✓ Restored default warning settings\n');
        end
    catch
        fprintf('⚠️  Could not restore warning settings\n');
    end

    % Clear function workspace variables (local to this function)
    fprintf('Cleaning up function workspace...\n');
    clearvars -except % This clears all local variables in the function

    fprintf('✓ Workspace cleanup complete\n');

catch ME_cleanup
    fprintf('⚠️  Workspace cleanup encountered errors: %s\n', ME_cleanup.message);
    fprintf('   Some variables may remain in workspace\n');
    fprintf('   You can manually run: performEmergencyCleanup() to retry cleanup\n');
end

fprintf('\n=== Script Complete ===\n');
fprintf('If you experience workspace issues, run: performEmergencyCleanup()\n');

end

%% Helper Functions

function [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, column_name)
    % Global helper function to safely add a column to trial_data
    try
        % Handle empty data
        if isempty(data_column)
            fprintf('      ⚠️  Skipping %s: empty data\n', column_name);
            success = false;
            return;
        end

        % Ensure data_column is a column vector with correct dimensions
        if ~iscolumn(data_column)
            data_column = data_column(:);
        end

        % Check if dimensions match
        if size(trial_data, 1) == size(data_column, 1)
            trial_data = [trial_data, data_column];
            signal_names{end+1} = column_name;
            success = true;
        else
            fprintf('      ⚠️  Skipping %s: dimension mismatch (expected %d rows, got %d)\n', ...
                column_name, size(trial_data, 1), size(data_column, 1));
            fprintf('      ⚠️  trial_data size: %s, data_column size: %s\n', ...
                mat2str(size(trial_data)), mat2str(size(data_column)));
            success = false;
        end
    catch ME
        fprintf('      ⚠️  Error adding column %s: %s\n', column_name, ME.message);
        success = false;
    end
end

function [trial_data, signal_names] = extractModelWorkspaceData(model_name, trial_data, signal_names, num_time_points)
    % Extract segment lengths, inertials, and anthropomorphic parameters from model workspace
    % This captures critical data for matching anthropomorphies to motion patterns

    try
        % Validate inputs
        if isempty(num_time_points) || num_time_points <= 0
            fprintf('    ⚠️  Invalid num_time_points: %s\n', mat2str(num_time_points));
            return;
        end

        % Get model workspace
        model_workspace = get_param(model_name, 'ModelWorkspace');
        workspace_vars = model_workspace.whos;

        fprintf('    Extracting model workspace data...\n');

        % Define categories of variables to extract
        anthropomorphic_vars = {
            % Segment lengths
            'segment_lengths', 'arm_length', 'leg_length', 'torso_length', 'spine_length',
            'left_arm_length', 'right_arm_length', 'left_leg_length', 'right_leg_length',
            'left_forearm_length', 'right_forearm_length', 'left_upper_arm_length', 'right_upper_arm_length',
            'left_thigh_length', 'right_thigh_length', 'left_shank_length', 'right_shank_length',
            'neck_length', 'head_height', 'shoulder_width', 'hip_width',

            % Segment masses
            'segment_masses', 'arm_mass', 'leg_mass', 'torso_mass', 'spine_mass',
            'left_arm_mass', 'right_arm_mass', 'left_leg_mass', 'right_leg_mass',
            'left_forearm_mass', 'right_forearm_mass', 'left_upper_arm_mass', 'right_upper_arm_mass',
            'left_thigh_mass', 'right_thigh_mass', 'left_shank_mass', 'right_shank_mass',
            'neck_mass', 'head_mass', 'total_mass', 'golfer_mass',

            % Segment inertias
            'segment_inertias', 'arm_inertia', 'leg_inertia', 'torso_inertia', 'spine_inertia',
            'left_arm_inertia', 'right_arm_inertia', 'left_leg_inertia', 'right_leg_inertia',
            'left_forearm_inertia', 'right_forearm_inertia', 'left_upper_arm_inertia', 'right_upper_arm_inertia',
            'left_thigh_inertia', 'right_thigh_inertia', 'left_shank_inertia', 'right_shank_inertia',
            'neck_inertia', 'head_inertia',

            % Anthropomorphic parameters
            'golfer_height', 'golfer_weight', 'golfer_bmi', 'golfer_age', 'golfer_gender',
            'shoulder_height', 'hip_height', 'knee_height', 'ankle_height',
            'arm_span', 'sitting_height', 'standing_height',

            % Club parameters
            'club_length', 'club_mass', 'club_inertia', 'club_cg', 'club_moi',
            'grip_length', 'shaft_length', 'head_mass', 'head_cg',

            % Joint parameters
            'joint_limits', 'joint_stiffness', 'joint_damping', 'joint_friction',
            'muscle_parameters', 'tendon_parameters', 'activation_parameters'
        };

        extracted_count = 0;

        % Extract anthropomorphic variables
        for i = 1:length(anthropomorphic_vars)
            var_name = anthropomorphic_vars{i};
            if model_workspace.hasVariable(var_name)
                try
                    var_value = model_workspace.getVariable(var_name);

                    % Handle different data types
                    if isnumeric(var_value)
                        if isscalar(var_value)
                            % Scalar value - repeat for all time points
                            data_column = repmat(var_value, num_time_points, 1);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s', var_name));
                            if success
                                extracted_count = extracted_count + 1;
                            end

                        elseif isvector(var_value)
                            % Vector value - handle as time-invariant parameters
                            for j = 1:length(var_value)
                                data_column = repmat(var_value(j), num_time_points, 1);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s_%d', var_name, j));
                                if success
                                    extracted_count = extracted_count + 1;
                                end
                            end

                        elseif ismatrix(var_value) && size(var_value, 1) == 3 && size(var_value, 2) == 3
                            % 3x3 matrix (e.g., inertia tensor) - flatten to 9 components
                            flat_inertia = var_value(:)'; % Flatten to row vector
                            for j = 1:9
                                data_column = repmat(flat_inertia(j), num_time_points, 1);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s_%d', var_name, j));
                                if success
                                    extracted_count = extracted_count + 1;
                                end
                            end
                        end
                    end
                catch ME
                    fprintf('      ⚠️  Error processing variable %s: %s\n', var_name, ME.message);
                    % Continue to next variable
                end
            end
        end



            % Skip if already processed or if it's a system variable
            if any(strcmp(anthropomorphic_vars, var_name)) || ...
               startsWith(var_name, 'sl_') || startsWith(var_name, 'sim_') || ...
               startsWith(var_name, 'gcs_') || startsWith(var_name, 'gcb_')
                continue;
            end

            try
                var_value = model_workspace.getVariable(var_name);

                % Only extract numeric variables
                if isnumeric(var_value)
                    if isscalar(var_value)
                        data_column = repmat(var_value, num_time_points, 1);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s', var_name));
                        if success
                            extracted_count = extracted_count + 1;
                        end

                    elseif isvector(var_value) && length(var_value) <= 10
                        % Small vectors - extract each component
                        for j = 1:length(var_value)
                            data_column = repmat(var_value(j), num_time_points, 1);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s_%d', var_name, j));
                            if success
                                extracted_count = extracted_count + 1;
                            end
                        end
                    end
                end
            catch ME
                fprintf('      ⚠️  Error processing workspace variable %s: %s\n', var_name, ME.message);
                % Continue to next variable
            end
        end

        fprintf('    ✓ Extracted %d model workspace variables\n', extracted_count);

    catch ME
        fprintf('    ⚠️  Could not extract model workspace data: %s\n', ME.message);
    end
end

function [trial_data, signal_names] = filterDiscreteVariables(trial_data, signal_names)
    % Filter out discrete variables that are all zeros (unused signals)

    try
        fprintf('    Filtering discrete variables...\n');

        % Find discrete variable columns
        discrete_indices = [];
        for i = 1:length(signal_names)
            if startsWith(signal_names{i}, 'Discrete_')
                discrete_indices = [discrete_indices, i];
            end
        end

        if isempty(discrete_indices)
            fprintf('    ✓ No discrete variables found to filter\n');
            return;
        end

        % Check which discrete variables are all zeros
        zero_discrete_indices = [];
        for i = 1:length(discrete_indices)
            col_idx = discrete_indices(i);
            if col_idx <= size(trial_data, 2)
                if all(trial_data(:, col_idx) == 0)
                    zero_discrete_indices = [zero_discrete_indices, col_idx];
                end
            end
        end

        % Remove zero discrete variables
        if ~isempty(zero_discrete_indices)
            % Remove from trial_data (in reverse order to maintain indices)
            for i = length(zero_discrete_indices):-1:1
                col_idx = zero_discrete_indices(i);
                if col_idx <= size(trial_data, 2)
                    trial_data(:, col_idx) = [];
                end
            end

            % Remove from signal_names (in reverse order to maintain indices)
            for i = length(zero_discrete_indices):-1:1
                col_idx = zero_discrete_indices(i);
                if col_idx <= length(signal_names)
                    signal_names(col_idx) = [];
                end
            end

            fprintf('    ✓ Filtered out %d zero discrete variables\n', length(zero_discrete_indices));
        else
            fprintf('    ✓ No zero discrete variables found\n');
        end

    catch ME
        fprintf('    ⚠️  Error filtering discrete variables: %s\n', ME.message);
    end
end

function [result, signal_names] = runSingleTrialWithCSV(sim_idx, config)
    % Run a single trial and save as CSV file with complete data

    try
        % Generate unique polynomial coefficients for this trial
        polynomial_coeffs = generateRandomPolynomialCoefficients();

        % Create simulation input
        simInput = Simulink.SimulationInput(config.model_name);

        % Set simulation time
        simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));

        % Set polynomial coefficients as variables
        simInput = setPolynomialVariables(simInput, polynomial_coeffs);

        % Configure logging
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');

        % Disable visualization to suppress Multibody Explorer warnings
        simInput = simInput.setModelParameter('SimMechanicsOpenEditorOnUpdate', 'off');
        simInput = simInput.setModelParameter('SimMechanicsOpenEditorOnUpdate', 'off');

        % Suppress Multibody Explorer warnings
        warning('off', 'Simulink:Simulation:DesktopSimHelper');

        % Run simulation
        fprintf('  Running simulation...\n');
        simOut = sim(simInput);

        % Extract all data from this simulation
        fprintf('  Extracting data...\n');
        [trial_data, signal_names] = extractCompleteTrialData(simOut, sim_idx, config);

        if ~isempty(trial_data)
            % Create comprehensive CSV file
            fprintf('  Creating CSV file...\n');

            % Create table with all data
            data_table = array2table(trial_data, 'VariableNames', signal_names);

            % Save as CSV file
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            filename = sprintf('trial_%03d_%s.csv', sim_idx, timestamp);
            filepath = fullfile(config.output_folder, filename);

            % Save CSV file
            writetable(data_table, filepath);

            result = struct();
            result.success = true;
            result.filename = filename;
            result.data_points = size(trial_data, 1);
            result.columns = size(trial_data, 2);
            result.trial_time = 0; % Will be set by caller

            fprintf('  ✓ CSV file created: %s\n', filename);
        else
            result = [];
            signal_names = {}; % Ensure signal_names is empty if trial_data is empty
        end

        % Clean up trial-specific variables to avoid memory buildup
        clearvars polynomial_coeffs simInput simOut trial_data data_table timestamp filename filepath

    catch ME
        fprintf('  Trial %d error: %s\n', sim_idx, ME.message);
        result = [];
        signal_names = {}; % Ensure signal_names is empty on error

        % Clean up even on error
        clearvars polynomial_coeffs simInput simOut trial_data data_table timestamp filename filepath
    end
end

function coeffs = generateRandomPolynomialCoefficients()
    % Generate random polynomial coefficients for different joints
    coeffs = struct();

    % Define joints that use polynomial inputs
    joints = {'Hip', 'Spine', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW'};

    for i = 1:length(joints)
        joint = joints{i};

        % Generate random coefficients for 3rd order polynomial (4 coefficients)
        % Range: -100 to 100 for reasonable torque values
        coeffs.([joint '_coeffs']) = (rand(1, 4) - 0.5) * 200;
    end
end

function simInput = setPolynomialVariables(simInput, coeffs)
    % Set polynomial coefficients as variables in the simulation input

    fields = fieldnames(coeffs);
    for i = 1:length(fields)
        field_name = fields{i};
        coeff_values = coeffs.(field_name);

        % Set as variable in simulation input
        simInput = simInput.setVariable(field_name, coeff_values);
    end
end

function [trial_data, signal_names] = extractCompleteTrialData(simOut, sim_idx, config)
    % Extract all available data from simulation output for a single trial
    % Uses the same robust extraction methods as test_sim_data_extraction.m

    try
        % Get time vector and resample to target sample rate
        time_vector = simOut.tout;
        if isempty(time_vector)
            trial_data = [];
            signal_names = {};
            return;
        end

        % Resample to target sample rate
        target_time = 0:1/config.sample_rate:config.simulation_time;
        target_time = target_time(target_time <= config.simulation_time);

        % Initialize data matrix and signal names
        num_time_points = length(target_time);
        trial_data = zeros(num_time_points, 0); % Will grow as we add columns
        signal_names = {'time', 'simulation_id'}; % Start with time and simulation ID

        % Add time and simulation ID
        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, target_time, 'time');
        if ~success
            fprintf('    ⚠️  Failed to add time column\n');
        end

        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, repmat(sim_idx, num_time_points, 1), 'simulation_id');
        if ~success
            fprintf('    ⚠️  Failed to add simulation_id column\n');
        end

        % Extract model workspace data (NEW: segment lengths, inertials, anthropomorphies)
        [trial_data, signal_names] = extractModelWorkspaceData(config.model_name, trial_data, signal_names, num_time_points);

        % Extract logsout data (same as test script)
        [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time);

        % Extract signal log structs (same as test script)
        [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time);

        % Extract Simscape Results Explorer data (same as test script)
        [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time);

        % Filter out discrete variables that are all zeros (NEW)
        [trial_data, signal_names] = filterDiscreteVariables(trial_data, signal_names);

        % Ensure unique column names
        signal_names = makeUniqueColumnNames(signal_names);

        % Final validation - ensure trial_data and signal_names are consistent
        if size(trial_data, 2) ~= length(signal_names)
            fprintf('    ⚠️  Data/signal name mismatch detected. Truncating to match...\n');
            min_length = min(size(trial_data, 2), length(signal_names));
            trial_data = trial_data(:, 1:min_length);
            signal_names = signal_names(1:min_length);
        end

        % Clean up temporary variables
        clearvars time_vector target_time num_time_points

    catch ME
        fprintf('    Error extracting trial data: %s\n', ME.message);
        trial_data = [];
        signal_names = {};

        % Clean up even on error
        clearvars time_vector target_time num_time_points
    end
end

function [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time)
    % Extract data from logsout with improved rotation matrix handling
    try
        if ~isfield(simOut, 'logsout') || isempty(simOut.logsout)
            return;
        end

        logsout = simOut.logsout;
        for i = 1:logsout.numElements
            try
                element = logsout.getElement(i);
                % Use original name but clean it properly (preserve parentheses)
                original_name = element.Name;
                name = strrep(original_name, ' ', '_');
                name = strrep(name, '-', '_');
                name = strrep(name, '.', '_');
                % Don't remove parentheses - they're part of the signal names!
                name = strrep(name, '[', '');
                name = strrep(name, ']', '');
                name = strrep(name, '/', '_');
                name = strrep(name, '\', '_');
                data = element.Values.Data;
                time = element.Values.Time;

                % Handle rotation matrices and other multi-dimensional data
                if ismatrix(data) && size(data, 2) > 1
                    % Multi-dimensional data - extract each component
                    for j = 1:size(data, 2)
                        component_data = data(:, j);
                        resampled_data = resampleSignal(component_data, time, target_time);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, sprintf('%s_%d', name, j));
                        if ~success
                            fprintf('      ⚠️  Failed to add logsout column %s_%d\n', name, j);
                        end
                    end
                else
                    % Single-dimensional data
                    resampled_data = resampleSignal(data, time, target_time);
                    [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, name);
                    if ~success
                        fprintf('      ⚠️  Failed to add logsout column %s\n', name);
                    end
                end

            catch ME
                fprintf('      ⚠️  Error processing logsout element %d: %s\n', i, ME.message);
                % Continue to next signal
            end
        end

    catch ME
        fprintf('      ⚠️  Error extracting logsout data: %s\n', ME.message);
        % Continue without logsout data
    end
end

function [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time)
    % Extract data from signal log structs with improved rotation matrix handling
    try
        fields = fieldnames(simOut);

        % Look for signal log structs (like RScapLogs, HipLogs, etc.)
        for i = 1:length(fields)
            field = fields{i};
            if endsWith(field, 'Logs') && isstruct(simOut.(field))
                log_struct = simOut.(field);
                struct_fields = fieldnames(log_struct);

                for j = 1:length(struct_fields)
                    subfield = struct_fields{j};
                    try
                        val = log_struct.(subfield);
                        if isnumeric(val)
                            if isvector(val) && length(val) > 1
                                % Vector data
                                name = sprintf('%s_%s', field, subfield);
                                resampled_data = resampleSignal(val, 1:length(val), target_time);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, name);
                                if ~success
                                    fprintf('      ⚠️  Failed to add signal log column %s\n', name);
                                end
                            elseif ndims(val) == 3 && size(val, 1) == 3 && size(val, 2) == 3
                                % 3D rotation matrix (3x3xN array) - extract each component
                                fprintf('      Found 3D rotation matrix in signal log: %s.%s (size: %s)\n', field, subfield, mat2str(size(val)));

                                % Extract each element of the 3x3 matrix as a separate column
                                for row = 1:3
                                    for col = 1:3
                                        % Extract the time series for this matrix element
                                        element_data = squeeze(val(row, col, :));

                                        % Resample to target time
                                        resampled_data = resampleSignal(element_data, 1:length(element_data), target_time);

                                        % Create column name for this matrix element
                                        element_name = sprintf('%s_%s_%d%d', field, subfield, row, col);

                                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, element_name);
                                        if ~success
                                            fprintf('      ⚠️  Failed to add rotation matrix element %s\n', element_name);
                                        end
                                    end
                                end
                            elseif ismatrix(val) && size(val, 2) > 1 && size(val, 1) > 1
                                % Matrix data (e.g., rotation matrices) - extract each component
                                for k = 1:size(val, 2)
                                    component_data = val(:, k);
                                    name = sprintf('%s_%s_%d', field, subfield, k);
                                    resampled_data = resampleSignal(component_data, 1:length(component_data), target_time);
                                    [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, name);
                                    if ~success
                                        fprintf('      ⚠️  Failed to add signal log column %s\n', name);
                                    end
                                end
                            end
                        end
                    catch ME
                        fprintf('      ⚠️  Error processing signal log field %s.%s: %s\n', field, subfield, ME.message);
                        % Continue to next field
                    end
                end
            end
        end

        % Also check for other numeric vectors in simOut
        for i = 1:length(fields)
            field = fields{i};
            if ~endsWith(field, 'Logs') && ~strcmp(field, 'logsout') && ~strcmp(field, 'tout')
                try
                    val = simOut.(field);
                    if isnumeric(val)
                        if isvector(val) && length(val) > 1
                            % Vector data
                            resampled_data = resampleSignal(val, 1:length(val), target_time);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, field);
                            if ~success
                                fprintf('      ⚠️  Failed to add simOut column %s\n', field);
                            end
                        elseif ismatrix(val) && size(val, 2) > 1 && size(val, 1) > 1
                            % Matrix data - extract each component
                            for k = 1:size(val, 2)
                                component_data = val(:, k);
                                name = sprintf('%s_%d', field, k);
                                resampled_data = resampleSignal(component_data, 1:length(component_data), target_time);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, name);
                                if ~success
                                    fprintf('      ⚠️  Failed to add simOut column %s\n', name);
                                end
                            end
                        end
                    end
                catch ME
                    fprintf('      ⚠️  Error processing simOut field %s: %s\n', field, ME.message);
                    % Continue to next field
                end
            end
        end

    catch ME
        fprintf('      ⚠️  Error extracting signal log structs: %s\n', ME.message);
        % Continue without signal log data
    end
end

function [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time)
    % Extract data from Simscape Results Explorer with improved rotation matrix handling
    try
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run_id = runIDs(end);
            run_obj = Simulink.sdi.getRun(latest_run_id);
            all_signals = run_obj.getAllSignals;

            for i = 1:length(all_signals)
                sig = all_signals(i);
                try
                    % Get signal data using the correct method
                    data = sig.Values.Data;
                    time = sig.Values.Time;

                    % Use original signal name, but clean it for table compatibility
                    original_name = sig.Name;
                    % Replace problematic characters but preserve parentheses (they indicate vector components)
                    clean_name = strrep(original_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    % Don't remove parentheses - they're part of the signal names!
                    % clean_name = strrep(clean_name, '(', '');
                    % clean_name = strrep(clean_name, ')', '');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');

                    % Handle 3D rotation matrices (3x3xN arrays)
                    if ndims(data) == 3 && size(data, 1) == 3 && size(data, 2) == 3
                        % This is a 3D rotation matrix - extract each component
                        fprintf('      Found 3D rotation matrix: %s (size: %s)\n', clean_name, mat2str(size(data)));

                        % Extract each element of the 3x3 matrix as a separate column
                        for row = 1:3
                            for col = 1:3
                                % Extract the time series for this matrix element
                                element_data = squeeze(data(row, col, :));

                                % Resample to target time
                                resampled_data = resampleSignal(element_data, time, target_time);

                                % Create column name for this matrix element
                                element_name = sprintf('%s_%d%d', clean_name, row, col);

                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, element_name);
                                if ~success
                                    fprintf('      ⚠️  Failed to add rotation matrix element %s\n', element_name);
                                end
                            end
                        end

                    % Handle 2D matrices (time x components)
                    elseif ismatrix(data) && size(data, 2) > 1
                        % Multi-dimensional data - extract each component
                        for j = 1:size(data, 2)
                            component_data = data(:, j);
                            resampled_data = resampleSignal(component_data, time, target_time);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, sprintf('%s_%d', clean_name, j));
                            if ~success
                                fprintf('      ⚠️  Failed to add Simscape column %s_%d\n', clean_name, j);
                            end
                        end
                    else
                        % Single-dimensional data
                        resampled_data = resampleSignal(data, time, target_time);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, clean_name);
                        if ~success
                            fprintf('      ⚠️  Failed to add Simscape column %s\n', clean_name);
                        end
                    end

                catch ME
                    fprintf('      ⚠️  Error processing Simscape signal %d: %s\n', i, ME.message);
                    % Continue to next signal
                end
            end
        end

    catch ME
        fprintf('      ⚠️  Error extracting Simscape results data: %s\n', ME.message);
        % Continue without Simscape data
    end
end

function resampled_data = resampleSignal(data, time, target_time)
    % Resample signal data to target time points

    if isempty(time) || isempty(data)
        resampled_data = zeros(length(target_time), 1);
        return;
    end

    try
        % Handle different data dimensions
        if isvector(data)
            % 1D data
            resampled_data = interp1(time, data, target_time, 'linear', 'extrap');
            resampled_data = resampled_data(:);
        else
            % Multi-dimensional data
            [n_rows, n_cols] = size(data);
            resampled_data = zeros(length(target_time), n_cols);

            for col = 1:n_cols
                resampled_data(:, col) = interp1(time, data(:, col), target_time, 'linear', 'extrap');
            end
        end
    catch
        % If interpolation fails, use nearest neighbor
        resampled_data = interp1(time, data, target_time, 'nearest', 'extrap');
        if ~isvector(resampled_data)
            resampled_data = resampled_data(:);
        end
    end
end

function unique_names = makeUniqueColumnNames(names)
    % Make column names unique by appending numbers to duplicates

    unique_names = names;
    seen_names = containers.Map('KeyType', 'char', 'ValueType', 'any');

    for i = 1:length(names)
        name = names{i};
        if isKey(seen_names, name)
            % Name already exists, append counter
            count = seen_names(name) + 1;
            seen_names(name) = count;
            unique_names{i} = sprintf('%s_%d', name, count);
        else
            % First occurrence of this name
            seen_names(name) = 1;
        end
    end
end

function value = getFieldOrDefault(struct_var, field_name, default_value)
    % Helper function to safely get field value or return default
    if isfield(struct_var, field_name)
        value = struct_var.(field_name);
    else
        value = default_value;
    end
end

function performEmergencyCleanup()
    % Emergency cleanup function - can be called if script fails unexpectedly
    % This function can be called manually by the user if needed

    fprintf('\n=== Emergency Workspace Cleanup ===\n');

    try
        % Clean up Simulink states
        try
            Simulink.sdi.clear();
            fprintf('✓ Cleared Simulation Data Inspector runs\n');
        catch
            fprintf('⚠️  Could not clear SDI runs\n');
        end

        % Close parallel pool
        try
            pool = gcp('nocreate');
            if ~isempty(pool)
                delete(pool);
                fprintf('✓ Closed parallel pool\n');
            end
        catch
            fprintf('⚠️  Could not close parallel pool\n');
        end

        % Close any open Simulink models
        try
            models = find_system('Type', 'block_diagram');
            for i = 1:length(models)
                if ~strcmp(models{i}, 'simulink')
                    try
                        close_system(models{i}, 0);
                    catch
                        % Continue
                    end
                end
            end
            fprintf('✓ Closed temporary Simulink models\n');
        catch
            fprintf('⚠️  Could not close Simulink models\n');
        end

        % Clean up common variables
        common_temp_vars = {'config', 'performance_metrics', 'progress', 'trial_results', ...
                          'simInput', 'simOut', 'use_parallel', 'pool', 'confirm', ...
                          'num_trials_str', 'sim_time_str', 'folder_location', 'folder_name', ...
                          'sample_rate_str', 'exec_mode', 'overwrite', 'fid', 'ME', ...
                          'initial_vars_backup', 'warning_state_backup'};

        cleared_count = 0;
        for i = 1:length(common_temp_vars)
            if evalin('base', ['exist(''', common_temp_vars{i}, ''', ''var'')'])
                try
                    evalin('base', ['clear ', common_temp_vars{i}]);
                    cleared_count = cleared_count + 1;
                catch
                    % Continue
                end
            end
        end

        if cleared_count > 0
            fprintf('✓ Cleared %d common temporary variables\n', cleared_count);
        end

        % Restore warnings
        try
            warning('on', 'Simulink:Simulation:DesktopSimHelper');
            warning('on', 'SimscapeMultibody:Explorer:UnableToLaunchExplorer');
            warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
            fprintf('✓ Restored warning settings\n');
        catch
            fprintf('⚠️  Could not restore warning settings\n');
        end

        fprintf('✓ Emergency cleanup complete\n');
        fprintf('Note: If you need to run this cleanup manually, call: performEmergencyCleanup()\n');

    catch ME_emergency
        fprintf('✗ Emergency cleanup failed: %s\n', ME_emergency.message);
    end
end
