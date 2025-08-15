% crashRecovery.m
% Crash recovery and simulation resumption utilities

function crashRecovery(action, varargin)
    % Crash recovery and simulation resumption utilities
    %
    % Usage:
    %   crashRecovery('check', folder_path)     - Check for existing trial files
    %   crashRecovery('resume', folder_path)    - Resume interrupted simulation
    %   crashRecovery('cleanup', folder_path)   - Clean up incomplete files
    %   crashRecovery('status', folder_path)    - Show detailed status

    if nargin < 2
        fprintf('Error: folder_path is required\n');
        fprintf('Usage: crashRecovery(action, folder_path)\n');
        return;
    end

    folder_path = varargin{1};

    if ~exist(folder_path, 'dir')
        fprintf('Error: Folder does not exist: %s\n', folder_path);
        return;
    end

    switch lower(action)
        case 'check'
            checkExistingTrials(folder_path);

        case 'resume'
            if nargin < 3
                fprintf('Error: Need total_trials parameter for resume\n');
                fprintf('Usage: crashRecovery(''resume'', folder_path, total_trials)\n');
                return;
            end
            total_trials = varargin{2};
            resumeSimulation(folder_path, total_trials);

        case 'cleanup'
            cleanupIncompleteFiles(folder_path);

        case 'status'
            showDetailedStatus(folder_path);

        otherwise
            fprintf('Unknown action: %s\n', action);
            fprintf('Available actions: check, resume, cleanup, status\n');
    end
end

function checkExistingTrials(folder_path)
    % Check for existing trial files in the folder

    fprintf('\n=== Checking Existing Trial Files ===\n');
    fprintf('Folder: %s\n\n', folder_path);

    try
        % Find all trial files
        trial_files = dir(fullfile(folder_path, 'trial_*.mat'));

        if isempty(trial_files)
            fprintf('No trial files found in folder.\n');
            return;
        end

        fprintf('Found %d trial files:\n', length(trial_files));

        % Extract trial numbers and check file integrity
        trial_numbers = [];
        valid_files = [];
        corrupted_files = [];

        for i = 1:length(trial_files)
            filename = trial_files(i).name;

            % Extract trial number from filename (trial_XXX_*.mat)
            parts = strsplit(filename, '_');
            if length(parts) >= 2
                try
                    trial_num = str2double(parts{2});
                    if ~isnan(trial_num)
                        trial_numbers = [trial_numbers; trial_num];

                        % Check if file is valid
                        filepath = fullfile(folder_path, filename);
                        try
                            file_info = whos('-file', filepath);
                            has_required_vars = any(strcmp({file_info.name}, 'trial_data')) && ...
                                              any(strcmp({file_info.name}, 'polynomial_coeffs'));

                            if has_required_vars
                                valid_files = [valid_files; trial_num];
                                fprintf('  ✓ Trial %03d: %s (%.1f MB)\n', trial_num, filename, trial_files(i).bytes/1024/1024);
                            else
                                corrupted_files = [corrupted_files; trial_num];
                                fprintf('  ✗ Trial %03d: %s (missing required variables)\n', trial_num, filename);
                            end
                        catch
                            corrupted_files = [corrupted_files; trial_num];
                            fprintf('  ✗ Trial %03d: %s (corrupted file)\n', trial_num, filename);
                        end
                    end
                catch
                    fprintf('  ? %s (invalid filename format)\n', filename);
                end
            end
        end

        % Summary
        fprintf('\n=== Summary ===\n');
        fprintf('Total files found: %d\n', length(trial_files));
        fprintf('Valid trial files: %d\n', length(valid_files));
        fprintf('Corrupted/incomplete files: %d\n', length(corrupted_files));

        if ~isempty(valid_files)
            fprintf('Trial number range: %d - %d\n', min(valid_files), max(valid_files));
            fprintf('Missing trials: ');

            % Find missing trial numbers
            expected_trials = min(valid_files):max(valid_files);
            missing_trials = setdiff(expected_trials, valid_files);

            if isempty(missing_trials)
                fprintf('None\n');
            else
                fprintf('%s\n', mat2str(missing_trials));
            end
        end

        % Recommendations
        fprintf('\n=== Recommendations ===\n');
        if ~isempty(corrupted_files)
            fprintf('• Run: crashRecovery(''cleanup'', ''%s'')\n', folder_path);
        end

        if ~isempty(valid_files)
            fprintf('• To resume: crashRecovery(''resume'', ''%s'', %d)\n', folder_path, max(valid_files) + 100);
        end

    catch ME
        fprintf('Error checking trial files: %s\n', ME.message);
    end
end

function resumeSimulation(folder_path, total_trials)
    % Resume simulation from where it left off

    fprintf('\n=== Resuming Simulation ===\n');
    fprintf('Folder: %s\n', folder_path);
    fprintf('Target total trials: %d\n\n', total_trials);

    try
        % Check existing trials
        trial_files = dir(fullfile(folder_path, 'trial_*.mat'));
        existing_trials = [];

        for i = 1:length(trial_files)
            filename = trial_files(i).name;
            parts = strsplit(filename, '_');
            if length(parts) >= 2
                trial_num = str2double(parts{2});
                if ~isnan(trial_num)
                    existing_trials = [existing_trials; trial_num];
                end
            end
        end

        if ~isempty(existing_trials)
            existing_trials = sort(existing_trials);
            fprintf('Existing trials: %s\n', mat2str(existing_trials));
            fprintf('Highest trial number: %d\n', max(existing_trials));
        else
            fprintf('No existing trials found.\n');
        end

        % Calculate remaining trials
        if ~isempty(existing_trials)
            remaining_trials = total_trials - max(existing_trials);
            start_trial = max(existing_trials) + 1;
        else
            remaining_trials = total_trials;
            start_trial = 1;
        end

        if remaining_trials <= 0
            fprintf('✓ All %d trials already completed!\n', total_trials);
            return;
        end

        fprintf('Remaining trials: %d (starting from trial %d)\n', remaining_trials, start_trial);

        % Ask for confirmation
        confirm = input(sprintf('Resume simulation for %d more trials? (y/n): ', remaining_trials), 's');
        if ~(strcmpi(confirm, 'y') || strcmpi(confirm, 'yes'))
            fprintf('Resume cancelled by user.\n');
            return;
        end

        % Get configuration from existing trial file
        config = loadConfigurationFromExisting(folder_path);
        if isempty(config)
            fprintf('Could not load configuration from existing files.\n');
            fprintf('Please run the original simulation script.\n');
            return;
        end

        % Update configuration for resume
        config.num_simulations = remaining_trials;
        config.start_trial = start_trial;
        config.resume_mode = true;

        fprintf('\n=== Configuration for Resume ===\n');
        fprintf('Model: %s\n', config.model_name);
        fprintf('Simulation time: %.1f seconds\n', config.simulation_time);
        fprintf('Sample rate: %d Hz\n', config.sample_rate);
        fprintf('Output folder: %s\n', config.output_folder);
        fprintf('Batch size: %d\n', config.batch_size);

        % Run the memory-safe simulation script
        fprintf('\nStarting resumed simulation...\n');
        runResumedSimulation(config, folder_path);

    catch ME
        fprintf('Error resuming simulation: %s\n', ME.message);
    end
end

function config = loadConfigurationFromExisting(folder_path)
    % Load configuration from an existing trial file

    try
        trial_files = dir(fullfile(folder_path, 'trial_*.mat'));
        if isempty(trial_files)
            config = [];
            return;
        end

        % Load the first valid trial file
        for i = 1:length(trial_files)
            filepath = fullfile(folder_path, trial_files(i).name);
            try
                file_data = load(filepath);
                if isfield(file_data, 'config')
                    config = file_data.config;
                    fprintf('✓ Loaded configuration from: %s\n', trial_files(i).name);
                    return;
                end
            catch
                continue;
            end
        end

        config = [];

    catch ME
        fprintf('Error loading configuration: %s\n', ME.message);
        config = [];
    end
end

function runResumedSimulation(config, folder_path)
    % Run the resumed simulation using the memory-safe script

    try
        % Import the memory-safe simulation functions
        addpath(fileparts(mfilename('fullpath')));

        % Run simulations in batches
        successful_trials = 0;
        failed_trials = 0;

        % Calculate number of batches
        num_batches = ceil(config.num_simulations / config.batch_size);

        for batch_idx = 1:num_batches
            fprintf('\n--- Batch %d/%d (Resume Mode) ---\n', batch_idx, num_batches);

            % Calculate batch range
            start_idx = config.start_trial + (batch_idx - 1) * config.batch_size;
            end_idx = min(config.start_trial + batch_idx * config.batch_size - 1, config.start_trial + config.num_simulations - 1);
            batch_size_actual = end_idx - start_idx + 1;

            fprintf('Processing trials %d-%d (%d trials)\n', start_idx, end_idx, batch_size_actual);

            % Run batch sequentially for resume mode
            for i = 1:batch_size_actual
                sim_idx = start_idx + i - 1;
                try
                    fprintf('Running simulation %d/%d...\n', sim_idx, config.start_trial + config.num_simulations - 1);
                    result = runSingleTrialMemorySafe(sim_idx, config);
                    if ~isempty(result)
                        successful_trials = successful_trials + 1;
                        fprintf('✓ Trial %d completed successfully\n', sim_idx);
                    else
                        failed_trials = failed_trials + 1;
                        fprintf('✗ Trial %d failed\n', sim_idx);
                    end
                catch ME
                    failed_trials = failed_trials + 1;
                    fprintf('✗ Simulation %d failed: %s\n', sim_idx, ME.message);
                end
            end

            % Memory cleanup after each batch
            fprintf('Performing memory cleanup...\n');
            if exist('memoryMonitor', 'file')
                memoryMonitor('cleanup');
            else
                clear('ans');
                if exist('java.lang.System', 'class')
                    java.lang.System.gc();
                end
            end

            % Progress update
            fprintf('Progress: %d/%d trials completed (%.1f%%)\n', ...
                successful_trials + failed_trials, config.num_simulations, ...
                (successful_trials + failed_trials) / config.num_simulations * 100);
        end

        % Summary
        fprintf('\n--- Resume Summary ---\n');
        fprintf('Total trials attempted: %d\n', config.num_simulations);
        fprintf('Successful trials: %d\n', successful_trials);
        fprintf('Failed trials: %d\n', failed_trials);
        fprintf('Success rate: %.1f%%\n', (successful_trials / config.num_simulations) * 100);

    catch ME
        fprintf('Error in resumed simulation: %s\n', ME.message);
    end
end

function cleanupIncompleteFiles(folder_path)
    % Clean up incomplete or corrupted trial files

    fprintf('\n=== Cleaning Up Incomplete Files ===\n');
    fprintf('Folder: %s\n\n', folder_path);

    try
        trial_files = dir(fullfile(folder_path, 'trial_*.mat'));

        if isempty(trial_files)
            fprintf('No trial files found to clean up.\n');
            return;
        end

        files_to_delete = {};

        for i = 1:length(trial_files)
            filename = trial_files(i).name;
            filepath = fullfile(folder_path, filename);

            try
                % Check if file is valid
                file_info = whos('-file', filepath);
                has_required_vars = any(strcmp({file_info.name}, 'trial_data')) && ...
                                  any(strcmp({file_info.name}, 'polynomial_coeffs'));

                if ~has_required_vars
                    files_to_delete{end+1} = filepath;
                    fprintf('  ✗ %s (missing required variables)\n', filename);
                end

            catch
                files_to_delete{end+1} = filepath;
                fprintf('  ✗ %s (corrupted file)\n', filename);
            end
        end

        if isempty(files_to_delete)
            fprintf('No incomplete files found.\n');
            return;
        end

        fprintf('\nFound %d incomplete/corrupted files.\n', length(files_to_delete));

        % Ask for confirmation
        confirm = input('Delete these files? (y/n): ', 's');
        if ~(strcmpi(confirm, 'y') || strcmpi(confirm, 'yes'))
            fprintf('Cleanup cancelled by user.\n');
            return;
        end

        % Delete files
        deleted_count = 0;
        for i = 1:length(files_to_delete)
            try
                delete(files_to_delete{i});
                deleted_count = deleted_count + 1;
                fprintf('  ✓ Deleted: %s\n', files_to_delete{i});
            catch ME
                fprintf('  ✗ Failed to delete: %s (%s)\n', files_to_delete{i}, ME.message);
            end
        end

        fprintf('\n✓ Cleanup complete: %d files deleted\n', deleted_count);

    catch ME
        fprintf('Error during cleanup: %s\n', ME.message);
    end
end

function showDetailedStatus(folder_path)
    % Show detailed status of trial files

    fprintf('\n=== Detailed Status Report ===\n');
    fprintf('Folder: %s\n\n', folder_path);

    try
        trial_files = dir(fullfile(folder_path, 'trial_*.mat'));

        if isempty(trial_files)
            fprintf('No trial files found.\n');
            return;
        end

        % Sort files by modification time
        [~, sort_idx] = sort([trial_files.datenum]);
        trial_files = trial_files(sort_idx);

        fprintf('File Analysis:\n');
        fprintf('%-20s %-10s %-12s %-15s %-10s\n', 'Filename', 'Size (MB)', 'Modified', 'Trial #', 'Status');
        fprintf('%s\n', repmat('-', 1, 70));

        valid_trials = [];
        corrupted_trials = [];

        for i = 1:length(trial_files)
            filename = trial_files(i).name;
            filepath = fullfile(folder_path, filename);
            file_size_mb = trial_files(i).bytes / 1024 / 1024;
            modified_date = datestr(trial_files(i).datenum, 'yyyy-mm-dd HH:MM');

            % Extract trial number
            parts = strsplit(filename, '_');
            trial_num = '?';
            if length(parts) >= 2
                trial_num = parts{2};
            end

            % Check file validity
            try
                file_info = whos('-file', filepath);
                has_required_vars = any(strcmp({file_info.name}, 'trial_data')) && ...
                                  any(strcmp({file_info.name}, 'polynomial_coeffs'));

                if has_required_vars
                    status = '✓ Valid';
                    if ~isnan(str2double(trial_num))
                        valid_trials = [valid_trials; str2double(trial_num)];
                    end
                else
                    status = '✗ Incomplete';
                    if ~isnan(str2double(trial_num))
                        corrupted_trials = [corrupted_trials; str2double(trial_num)];
                    end
                end
            catch
                status = '✗ Corrupted';
                if ~isnan(str2double(trial_num))
                    corrupted_trials = [corrupted_trials; str2double(trial_num)];
                end
            end

            fprintf('%-20s %-10.1f %-12s %-15s %-10s\n', ...
                filename(1:min(19, length(filename))), file_size_mb, modified_date, trial_num, status);
        end

        % Summary statistics
        fprintf('\n=== Summary Statistics ===\n');
        fprintf('Total files: %d\n', length(trial_files));
        fprintf('Valid files: %d\n', length(valid_trials));
        fprintf('Corrupted/incomplete: %d\n', length(corrupted_trials));

        if ~isempty(valid_trials)
            valid_trials = sort(valid_trials);
            fprintf('Valid trial range: %d - %d\n', min(valid_trials), max(valid_trials));
            fprintf('Missing trials: ');

            expected_trials = min(valid_trials):max(valid_trials);
            missing_trials = setdiff(expected_trials, valid_trials);

            if isempty(missing_trials)
                fprintf('None\n');
            else
                fprintf('%s\n', mat2str(missing_trials));
            end
        end

        % File size statistics
        file_sizes = [trial_files.bytes] / 1024 / 1024;
        fprintf('Average file size: %.1f MB\n', mean(file_sizes));
        fprintf('Total data size: %.1f MB\n', sum(file_sizes));

    catch ME
        fprintf('Error generating detailed status: %s\n', ME.message);
    end
end
