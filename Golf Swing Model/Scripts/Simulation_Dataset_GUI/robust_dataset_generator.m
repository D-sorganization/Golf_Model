function successful_trials = robust_dataset_generator(config, varargin)
    % ROBUST_DATASET_GENERATOR - Crash-resistant dataset generation with intermediate saves
    % 
    % Features:
    % - Memory monitoring and automatic batch sizing
    % - Intermediate progress saves every N trials
    % - Automatic recovery from crashes
    % - Parallel pool management with memory limits
    % - Progress tracking and resume capability
    % - Performance monitoring and analysis
    % - Verbosity controls for output management
    %
    % Usage:
    %   successful_trials = robust_dataset_generator(config)
    %   successful_trials = robust_dataset_generator(config, 'BatchSize', 100, 'SaveInterval', 50)
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'BatchSize', [], @isnumeric);           % Trials per batch
    addParameter(p, 'SaveInterval', [], @isnumeric);         % Save every N trials
    addParameter(p, 'MaxMemoryGB', 8, @isnumeric);           % Max memory usage
    addParameter(p, 'MaxWorkers', 4, @isnumeric);            % Max parallel workers
    addParameter(p, 'ResumeFrom', '', @ischar);              % Resume from checkpoint
    addParameter(p, 'CheckpointFile', '', @ischar);          % Custom checkpoint file
    addParameter(p, 'Verbosity', '', @ischar);         % Output verbosity level
    addParameter(p, 'PerformanceMonitoring', [], @islogical); % Enable performance monitoring
    addParameter(p, 'CaptureWorkspace', true, @islogical);   % Capture model workspace data
    parse(p, varargin{:});
    
    % Get parameters from input parser or config structure
    batch_size = p.Results.BatchSize;
    if isempty(batch_size) && isfield(config, 'BatchSize')
        batch_size = config.BatchSize;
    elseif isempty(batch_size)
        batch_size = 100; % Default
    end
    
    save_interval = p.Results.SaveInterval;
    if isempty(save_interval) && isfield(config, 'SaveInterval')
        save_interval = config.SaveInterval;
    elseif isempty(save_interval)
        save_interval = 50; % Default
    end
    
    max_memory_gb = p.Results.MaxMemoryGB;
    max_workers = p.Results.MaxWorkers;
    resume_from = p.Results.ResumeFrom;
    checkpoint_file = p.Results.CheckpointFile;
    
    verbosity_level = p.Results.Verbosity;
    if isempty(verbosity_level) && isfield(config, 'Verbosity')
        verbosity_level = config.Verbosity;
    elseif isempty(verbosity_level)
        verbosity_level = 'normal'; % Default
    end
    
    enable_performance_monitoring = p.Results.PerformanceMonitoring;
    if isempty(enable_performance_monitoring) && isfield(config, 'PerformanceMonitoring')
        enable_performance_monitoring = config.PerformanceMonitoring;
    elseif isempty(enable_performance_monitoring)
        enable_performance_monitoring = true; % Default
    end
    
    capture_workspace = p.Results.CaptureWorkspace;
    
    % Initialize verbosity control
    try
        verbosity_control('set', verbosity_level);
    catch ME
        % If verbosity_control is not available, create a simple fallback
        fprintf('Warning: verbosity_control not available, using fallback logging\n');
        global verbosity_level;
        verbosity_level = verbosity_level;
    end
    
    % Initialize performance monitoring
    if enable_performance_monitoring
        try
            performance_monitor('start');
            recordPhase('Initialization');
        catch ME
            fprintf('Warning: Performance monitoring not available: %s\n', ME.message);
            enable_performance_monitoring = false;
        end
    end
    
    % Initialize checkpoint system
    if isempty(checkpoint_file)
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        checkpoint_file = fullfile(config.output_folder, sprintf('checkpoint_%s.mat', timestamp));
    end
    
    % Initialize or load checkpoint
    if ~isempty(resume_from) && exist(resume_from, 'file')
        logMessage('info', 'Resuming from checkpoint: %s', resume_from);
        checkpoint = load(resume_from);
        completed_trials = checkpoint.completed_trials;
        all_results = checkpoint.all_results;
        start_trial = length(completed_trials) + 1;
        logMessage('info', 'Resuming from trial %d', start_trial);
    else
        completed_trials = [];
        all_results = {};
        start_trial = 1;
        logMessage('info', 'Starting new dataset generation');
    end
    
    % Calculate optimal batch size based on available memory
    optimal_batch_size = calculateOptimalBatchSize(max_memory_gb, config);
    batch_size = min(batch_size, optimal_batch_size);
    logMessage('info', 'Using batch size: %d trials', batch_size);
    
    % Initialize parallel pool with memory limits (respect execution mode)
    if enable_performance_monitoring
        try
            endPhase();
            recordPhase('Parallel Pool Setup');
        catch
            % Performance monitoring not available, continue silently
        end
    end
    
    % Check execution mode - use sequential if requested
    if isfield(config, 'execution_mode') && config.execution_mode == 1
        % Sequential mode requested
        logMessage('info', 'Using sequential execution mode as requested');
        pool = [];
    else
        % Parallel mode (default or explicitly requested)
        pool = initializeParallelPool(max_workers, max_memory_gb);
    end
    
    % Main generation loop
    total_trials = config.num_simulations;
    successful_trials = 0;
    
    if enable_performance_monitoring
        try
            endPhase();
            recordPhase('Dataset Generation');
        catch
            % Performance monitoring not available, continue silently
        end
    end
    
    try
        for batch_start = start_trial:batch_size:total_trials
            batch_end = min(batch_start + batch_size - 1, total_trials);
            current_batch_size = batch_end - batch_start + 1;
            batch_num = ceil(batch_start / batch_size);
            
            logMessage('info', 'Processing batch %d: trials %d-%d of %d', ...
                batch_num, batch_start, batch_end, total_trials);
            
            % Check memory before starting batch
            if ~checkMemoryAvailable(max_memory_gb)
                logMessage('warning', 'Low memory detected. Pausing for cleanup...');
                cleanupMemory();
                pause(5); % Give system time to free memory
            end
            
            % Process batch
            batch_start_time = tic;
            batch_results = processBatch(config, batch_start:batch_end, pool, capture_workspace);
            batch_duration = toc(batch_start_time);
            
            % Update progress - handle cell array of structures
            if iscell(batch_results) && ~isempty(batch_results)
                success_values = cellfun(@(x) x.success, batch_results);
                successful_in_batch = sum(success_values);
            else
                successful_in_batch = 0;
            end
            failed_in_batch = length(batch_results) - successful_in_batch;
            successful_trials = successful_trials + successful_in_batch;
            
            % Record batch performance
            if enable_performance_monitoring
                try
                    recordBatchTime(batch_num, current_batch_size, batch_duration, successful_in_batch);
                catch
                    % Performance monitoring not available, continue silently
                end
            end
            
            % Log batch results
            logBatchResult(batch_num, current_batch_size, successful_in_batch, failed_in_batch, batch_duration);
            
            % Add to completed trials
            completed_trials = [completed_trials, batch_start:batch_end];
            all_results = [all_results, batch_results];
            
            % Save checkpoint
            if mod(length(completed_trials), save_interval) == 0 || batch_end == total_trials
                checkpoint_start_time = tic;
                saveCheckpoint(checkpoint_file, completed_trials, all_results, config);
                checkpoint_duration = toc(checkpoint_start_time);
                
                % Get checkpoint file size
                file_info = dir(checkpoint_file);
                file_size_mb = file_info.bytes / 1024^2;
                
                % Record checkpoint performance
                if enable_performance_monitoring
                    try
                        recordCheckpointTime(checkpoint_duration);
                    catch
                        % Performance monitoring not available, continue silently
                    end
                end
                
                % Log checkpoint info
                logCheckpoint(checkpoint_duration, file_size_mb);
                logMessage('info', 'Checkpoint saved: %d/%d trials completed', ...
                    length(completed_trials), total_trials);
            end
            
            % Progress report
            logProgress(length(completed_trials), total_trials, 'Overall progress');
            logMessage('info', 'Batch complete: %d/%d successful (%.1f%%)', ...
                successful_trials, length(completed_trials), ...
                100 * successful_trials / length(completed_trials));
        end
        
        % Final compilation
        if enable_performance_monitoring
            try
                endPhase();
                recordPhase('Final Compilation');
            catch
                % Performance monitoring not available, continue silently
            end
        end
        if successful_trials > 0
            logMessage('info', 'Compiling final dataset...');
            compileFinalDataset(config, all_results, successful_trials);
        else
            logMessage('warning', 'No successful simulations to compile. Skipping dataset compilation.');
        end
        
        % Cleanup
        if ~isempty(pool)
            delete(pool);
        end
        
        % Stop performance monitoring and generate report
        if enable_performance_monitoring
            try
                endPhase();
                performance_monitor('stop');
            catch
                % Performance monitoring not available, continue silently
            end
        end
        
        logMessage('info', 'Dataset generation complete!');
        logMessage('info', 'Total trials: %d', total_trials);
        logMessage('info', 'Successful: %d (%.1f%%)', successful_trials, ...
            100 * successful_trials / total_trials);
        
        % Return successful trials count
        return;
        
    catch ME
        % Emergency save on error
        logMessage('error', 'Error during generation: %s', ME.message);
        logMessage('info', 'Saving emergency checkpoint...');
        saveCheckpoint(checkpoint_file, completed_trials, all_results, config);
        
        % Stop performance monitoring
        if enable_performance_monitoring
            try
                performance_monitor('stop');
            catch
                % Performance monitoring not available, continue silently
            end
        end
        
        % Cleanup
        if ~isempty(pool)
            delete(pool);
        end
        
        rethrow(ME);
    end
end

function optimal_batch_size = calculateOptimalBatchSize(max_memory_gb, config)
    % Calculate optimal batch size based on available memory
    try
        % Estimate memory per simulation (rough estimate)
        % Simscape logging can be memory intensive
        estimated_memory_per_sim_mb = 50; % Conservative estimate
        
        % Get available memory
        [~, systemview] = memory;
        available_memory_mb = systemview.PhysicalMemory.Available / 1024^2;
        
        % Reserve some memory for system
        usable_memory_mb = min(available_memory_mb * 0.7, max_memory_gb * 1024);
        
        % Calculate optimal batch size
        optimal_batch_size = floor(usable_memory_mb / estimated_memory_per_sim_mb);
        
        % Apply reasonable limits
        optimal_batch_size = max(10, min(optimal_batch_size, 500));
        
        fprintf('Memory analysis: %.1f MB available, %.1f MB usable\n', ...
            available_memory_mb, usable_memory_mb);
        fprintf('Estimated optimal batch size: %d\n', optimal_batch_size);
        
    catch
        % Fallback if memory analysis fails
        optimal_batch_size = 100;
        fprintf('Memory analysis failed, using default batch size: %d\n', optimal_batch_size);
    end
end

function pool = initializeParallelPool(max_workers, max_memory_gb)
    % Initialize parallel pool with memory monitoring
    try
        % Check if pool already exists
        pool = gcp('nocreate');
        
        if isempty(pool)
            % Calculate optimal number of workers
            max_cores = feature('numcores');
            num_workers = min(max_cores, max_workers);
            
            % Create pool with memory limits
            pool = parpool('local', num_workers);
            fprintf('Started parallel pool with %d workers\n', num_workers);
        else
            fprintf('Using existing parallel pool with %d workers\n', pool.NumWorkers);
        end
        
        % Set memory monitoring on workers
        spmd
            % Monitor memory usage on each worker
            [~, worker_memory] = memory;
            fprintf('Worker %d: %.1f MB available\n', labindex, ...
                worker_memory.PhysicalMemory.Available / 1024^2);
        end
        
    catch ME
        fprintf('Warning: Parallel pool initialization failed: %s\n', ME.message);
        fprintf('Falling back to sequential execution\n');
        pool = [];
    end
end

function batch_results = processBatch(config, trial_indices, pool, capture_workspace)
    % Process a batch of trials
    batch_results = cell(1, length(trial_indices));
    
    if isempty(pool)
        % Sequential processing
        for i = 1:length(trial_indices)
            trial = trial_indices(i);
            logProgress(i, length(trial_indices), sprintf('Processing trial %d', trial));
            
            try
                trial_start_time = tic;
                % Create config with workspace capture setting
                trial_config = config;
                trial_config.capture_workspace = capture_workspace;
                
                % Debug: Check what we're passing to runSingleTrial
                fprintf('Debug: Calling runSingleTrial with trial=%d, config type=%s, capture_workspace=%s\n', ...
                    trial, class(config), mat2str(capture_workspace));
                
                % Check if function exists
                if ~exist('runSingleTrial', 'file')
                    error('runSingleTrial function not found in path');
                end
                
                batch_results{i} = runSingleTrial(trial, config, [], capture_workspace);
                trial_duration = toc(trial_start_time);
                
                % Record trial performance
                global performance_data;
                if ~isempty(performance_data)
                    recordTrialTime(trial, trial_duration, 0); % Processing time not tracked separately
                end
                
                % Log trial result
                logTrialResult(trial, batch_results{i}.success, trial_duration, ...
                    batch_results{i}.error);
                
            catch ME
                trial_duration = 0;
                batch_results{i} = struct('success', false, 'error', ME.message);
                logTrialResult(trial, false, trial_duration, ME.message);
            end
        end
    else
        % Parallel processing
        try
            % Prepare simulation inputs for this batch
            simInputs = prepareBatchSimulationInputs(config, trial_indices);
            
            % Run parallel simulations
            simOuts = parsim(simInputs, 'ShowProgress', true, ...
                           'ShowSimulationManager', 'off', ...
                           'StopOnError', 'off');
            
            % Process results
            for i = 1:length(simOuts)
                trial = trial_indices(i);
                try
                    % Handle potential brace indexing issues with simOuts(i)
                    if iscell(simOuts) && i <= length(simOuts)
                        simOut = simOuts{i}; % Use cell indexing
                    elseif isnumeric(simOuts) || isstruct(simOuts)
                        simOut = simOuts(i); % Use regular indexing
                    else
                        simOut = [];
                    end
                    
                    if ~isempty(simOut) && isSimulationSuccessful(simOut)
                        batch_results{i} = processSimulationOutput(trial, config, simOut);
                    else
                        batch_results{i} = struct('success', false, 'error', 'Simulation failed');
                    end
                catch ME
                    batch_results{i} = struct('success', false, 'error', ME.message);
                end
            end
            
        catch ME
            fprintf('Parallel batch failed: %s\n', ME.message);
            fprintf('Falling back to sequential processing for this batch\n');
            
            % Fallback to sequential
            for i = 1:length(trial_indices)
                trial = trial_indices(i);
                try
                    batch_results{i} = runSingleTrial(trial, config, [], capture_workspace);
                catch ME
                    batch_results{i} = struct('success', false, 'error', ME.message);
                end
            end
        end
    end
end

function simInputs = prepareBatchSimulationInputs(config, trial_indices)
    % Prepare simulation inputs for a specific batch
    simInputs = Simulink.SimulationInput.empty(0, length(trial_indices));
    
    for i = 1:length(trial_indices)
        trial = trial_indices(i);
        
        % Get coefficients for this trial
        if trial <= size(config.coefficient_values, 1)
            trial_coefficients = config.coefficient_values(trial, :);
        else
            trial_coefficients = config.coefficient_values(end, :);
        end
        
        % Create SimulationInput object
        simIn = Simulink.SimulationInput(config.model_name);
        
        % Set simulation parameters
        simIn = setModelParameters(simIn, config);
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);
        
        % Load input file if specified
        if ~isempty(config.input_file) && exist(config.input_file, 'file')
            simIn = loadInputFile(simIn, config.input_file);
        end
        
        simInputs(i) = simIn;
    end
end

function success = isSimulationSuccessful(simOut)
    % Check if simulation completed successfully
    success = false;
    
    try
        % Check for error message
        if isprop(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
            return;
        end
        
        % Check simulation metadata
        if isprop(simOut, 'SimulationMetadata') && ...
           isfield(simOut.SimulationMetadata, 'ExecutionInfo')
            
            execInfo = simOut.SimulationMetadata.ExecutionInfo;
            if isfield(execInfo, 'StopEvent') && execInfo.StopEvent == "CompletedNormally"
                success = true;
                return;
            end
        end
        
        % Check for output data
        if isprop(simOut, 'logsout') || isfield(simOut, 'logsout') || ...
           isprop(simOut, 'simlog') || isfield(simOut, 'simlog')
            success = true;
        end
        
    catch
        % If we can't determine, assume failure
        success = false;
    end
end

function saveCheckpoint(checkpoint_file, completed_trials, all_results, config)
    % Save checkpoint with progress
    try
        checkpoint = struct();
        checkpoint.completed_trials = completed_trials;
        checkpoint.all_results = all_results;
        checkpoint.config = config;
        checkpoint.timestamp = datestr(now);
        % Handle cell array of structures properly
        if iscell(all_results) && ~isempty(all_results)
            % Extract success field from each cell
            success_values = cellfun(@(x) x.success, all_results, 'UniformOutput', false);
            % Convert to numeric array and sum
            success_array = cell2mat(success_values);
            checkpoint.successful_count = sum(success_array);
        else
            checkpoint.successful_count = 0;
        end
        
        save(checkpoint_file, '-struct', 'checkpoint');
        
        % Also save a backup
        [checkpoint_dir, checkpoint_name, checkpoint_ext] = fileparts(checkpoint_file);
        backup_file = fullfile(checkpoint_dir, [checkpoint_name '_backup' checkpoint_ext]);
        save(backup_file, '-struct', 'checkpoint');
        
    catch ME
        fprintf('Warning: Failed to save checkpoint: %s\n', ME.message);
    end
end

function available = checkMemoryAvailable(max_memory_gb)
    % Check if sufficient memory is available
    try
        [~, systemview] = memory;
        available_memory_gb = systemview.PhysicalMemory.Available / 1024^3;
        available = available_memory_gb > max_memory_gb * 0.3; % Keep 30% buffer
        
        if ~available
            fprintf('⚠️  Low memory: %.1f GB available (need %.1f GB)\n', ...
                available_memory_gb, max_memory_gb * 0.3);
        end
    catch
        available = true; % Assume OK if we can't check
    end
end

function cleanupMemory()
    % Clean up memory
    try
        % Clear variables that might be taking up memory
        evalin('base', 'clear ans');
        
        % Force garbage collection
        java.lang.System.gc();
        
        % Clear MATLAB's internal caches
        clear('functions');
        
    catch
        % Ignore cleanup errors
    end
end

function compileFinalDataset(config, all_results, successful_trials)
    % Compile final dataset from all results
    try
        % Extract successful results - handle cell array of structures
        if iscell(all_results) && ~isempty(all_results)
            % Find successful results
            success_indices = cellfun(@(x) x.success, all_results);
            successful_results = all_results(success_indices);
        else
            successful_results = {};
        end
        
        if isempty(successful_results)
            error('No successful simulations to compile');
        end
        
        % Compile dataset (this would call your existing compileDataset function)
        fprintf('Compiling dataset from %d successful simulations...\n', length(successful_results));
        
        % Save final results
        final_results_file = fullfile(config.output_folder, 'final_results.mat');
        save(final_results_file, 'all_results', 'successful_results', 'config');
        
        fprintf('✓ Final dataset compiled and saved\n');
        
    catch ME
        fprintf('Error compiling final dataset: %s\n', ME.message);
        rethrow(ME);
    end
end

% Fallback logging functions if verbosity_control is not available
function logMessage(level, message, varargin)
    % Fallback logging function
    try
        % Try to use the real logMessage function first
        logMessage_real(level, message, varargin{:});
    catch
        % Fallback to simple fprintf
        if nargin > 2
            formatted_message = sprintf(message, varargin{:});
        else
            formatted_message = message;
        end
        
        switch lower(level)
            case 'error'
                fprintf('❌ ERROR: %s\n', formatted_message);
            case 'warning'
                fprintf('⚠️  WARNING: %s\n', formatted_message);
            case 'info'
                fprintf('ℹ️  INFO: %s\n', formatted_message);
            case 'debug'
                fprintf('🔍 DEBUG: %s\n', formatted_message);
            otherwise
                fprintf('%s\n', formatted_message);
        end
    end
end

function logProgress(current, total, message)
    % Fallback progress logging function
    try
        % Try to use the real logProgress function first
        logProgress_real(current, total, message);
    catch
        % Fallback to simple fprintf
        percentage = 100 * current / total;
        fprintf('\r%s: %d/%d (%.1f%%)', message, current, total, percentage);
        if current == total
            fprintf('\n');
        end
    end
end

function logTrialResult(trial_num, success, duration, error_msg)
    % Fallback trial result logging function
    try
        % Try to use the real logTrialResult function first
        logTrialResult_real(trial_num, success, duration, error_msg);
    catch
        % Fallback to simple fprintf
        if success
            fprintf('Trial %d completed successfully in %.2f seconds\n', trial_num, duration);
        else
            fprintf('Trial %d failed after %.2f seconds: %s\n', trial_num, duration, error_msg);
        end
    end
end

function logCheckpoint(duration, file_size_mb)
    % Fallback checkpoint logging function
    try
        % Try to use the real logCheckpoint function first
        logCheckpoint_real(duration, file_size_mb);
    catch
        % Fallback to simple fprintf
        fprintf('Checkpoint saved in %.2f seconds (%.1f MB)\n', duration, file_size_mb);
    end
end

function recordTrialTime(trial, duration, processing_time)
    % Fallback trial time recording function
    try
        % Try to use the real recordTrialTime function first
        recordTrialTime_real(trial, duration, processing_time);
    catch
        % Fallback - do nothing
    end
end

function recordBatchTime(batch_num, batch_size, duration, successful)
    % Fallback batch time recording function
    try
        % Try to use the real recordBatchTime function first
        recordBatchTime_real(batch_num, batch_size, duration, successful);
    catch
        % Fallback - do nothing
    end
end

function recordCheckpointTime(duration)
    % Fallback checkpoint time recording function
    try
        % Try to use the real recordCheckpointTime function first
        recordCheckpointTime_real(duration);
    catch
        % Fallback - do nothing
    end
end

function logBatchResult(batch_num, batch_size, successful, failed, duration)
    % Fallback batch result logging function
    try
        % Try to use the real logBatchResult function first
        logBatchResult_real(batch_num, batch_size, successful, failed, duration);
    catch
        % Fallback to simple fprintf
        success_rate = 100 * successful / batch_size;
        fprintf('Batch %d: %d/%d successful (%.1f%%) in %.1f seconds\n', ...
            batch_num, successful, batch_size, success_rate, duration);
    end
end 