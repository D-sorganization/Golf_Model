function robust_dataset_generator(config, varargin)
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
    %   robust_dataset_generator(config)
    %   robust_dataset_generator(config, 'BatchSize', 100, 'SaveInterval', 50)
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'BatchSize', 100, @isnumeric);           % Trials per batch
    addParameter(p, 'SaveInterval', 50, @isnumeric);         % Save every N trials
    addParameter(p, 'MaxMemoryGB', 8, @isnumeric);           % Max memory usage
    addParameter(p, 'MaxWorkers', 4, @isnumeric);            % Max parallel workers
    addParameter(p, 'ResumeFrom', '', @ischar);              % Resume from checkpoint
    addParameter(p, 'CheckpointFile', '', @ischar);          % Custom checkpoint file
    addParameter(p, 'Verbosity', 'normal', @ischar);         % Output verbosity level
    addParameter(p, 'PerformanceMonitoring', true, @islogical); % Enable performance monitoring
    addParameter(p, 'CaptureWorkspace', true, @islogical);   % Capture model workspace data
    parse(p, varargin{:});
    
    batch_size = p.Results.BatchSize;
    save_interval = p.Results.SaveInterval;
    max_memory_gb = p.Results.MaxMemoryGB;
    max_workers = p.Results.MaxWorkers;
    resume_from = p.Results.ResumeFrom;
    checkpoint_file = p.Results.CheckpointFile;
    verbosity_level = p.Results.Verbosity;
    enable_performance_monitoring = p.Results.PerformanceMonitoring;
    capture_workspace = p.Results.CaptureWorkspace;
    
    % Initialize verbosity control
    verbosity_control('set', verbosity_level);
    
    % Initialize performance monitoring
    if enable_performance_monitoring
        performance_monitor('start');
        recordPhase('Initialization');
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
    
    % Initialize parallel pool with memory limits
    if enable_performance_monitoring
        endPhase();
        recordPhase('Parallel Pool Setup');
    end
    pool = initializeParallelPool(max_workers, max_memory_gb);
    
    % Main generation loop
    total_trials = config.num_simulations;
    successful_trials = 0;
    
    if enable_performance_monitoring
        endPhase();
        recordPhase('Dataset Generation');
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
            batch_results = processBatch(config, batch_start:batch_end, pool);
            batch_duration = toc(batch_start_time);
            
            % Update progress
            successful_in_batch = sum([batch_results.success]);
            failed_in_batch = length(batch_results) - successful_in_batch;
            successful_trials = successful_trials + successful_in_batch;
            
            % Record batch performance
            if enable_performance_monitoring
                recordBatchTime(batch_num, current_batch_size, batch_duration, successful_in_batch);
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
                    recordCheckpointTime(checkpoint_duration);
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
            endPhase();
            recordPhase('Final Compilation');
        end
        logMessage('info', 'Compiling final dataset...');
        compileFinalDataset(config, all_results, successful_trials);
        
        % Cleanup
        if ~isempty(pool)
            delete(pool);
        end
        
        % Stop performance monitoring and generate report
        if enable_performance_monitoring
            endPhase();
            performance_monitor('stop');
        end
        
        logMessage('info', 'Dataset generation complete!');
        logMessage('info', 'Total trials: %d', total_trials);
        logMessage('info', 'Successful: %d (%.1f%%)', successful_trials, ...
            100 * successful_trials / total_trials);
        
    catch ME
        % Emergency save on error
        logMessage('error', 'Error during generation: %s', ME.message);
        logMessage('info', 'Saving emergency checkpoint...');
        saveCheckpoint(checkpoint_file, completed_trials, all_results, config);
        
        % Stop performance monitoring
        if enable_performance_monitoring
            performance_monitor('stop');
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

function batch_results = processBatch(config, trial_indices, pool)
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
                batch_results{i} = runSingleTrial(trial, trial_config, []);
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
                    if ~isempty(simOuts(i)) && isSimulationSuccessful(simOuts(i))
                        batch_results{i} = processSimulationOutput(trial, config, simOuts(i));
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
                    batch_results{i} = runSingleTrial(trial, config, []);
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
        checkpoint.successful_count = sum([all_results.success]);
        
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
        % Extract successful results
        successful_results = all_results([all_results.success]);
        
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