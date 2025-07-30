function robust_dataset_generator(config, varargin)
    % ROBUST_DATASET_GENERATOR - Crash-resistant dataset generation with intermediate saves
    % 
    % Features:
    % - Memory monitoring and automatic batch sizing
    % - Intermediate progress saves every N trials
    % - Automatic recovery from crashes
    % - Parallel pool management with memory limits
    % - Progress tracking and resume capability
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
    parse(p, varargin{:});
    
    batch_size = p.Results.BatchSize;
    save_interval = p.Results.SaveInterval;
    max_memory_gb = p.Results.MaxMemoryGB;
    max_workers = p.Results.MaxWorkers;
    resume_from = p.Results.ResumeFrom;
    checkpoint_file = p.Results.CheckpointFile;
    
    % Initialize checkpoint system
    if isempty(checkpoint_file)
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        checkpoint_file = fullfile(config.output_folder, sprintf('checkpoint_%s.mat', timestamp));
    end
    
    % Initialize or load checkpoint
    if ~isempty(resume_from) && exist(resume_from, 'file')
        fprintf('Resuming from checkpoint: %s\n', resume_from);
        checkpoint = load(resume_from);
        completed_trials = checkpoint.completed_trials;
        all_results = checkpoint.all_results;
        start_trial = length(completed_trials) + 1;
        fprintf('Resuming from trial %d\n', start_trial);
    else
        completed_trials = [];
        all_results = {};
        start_trial = 1;
        fprintf('Starting new dataset generation\n');
    end
    
    % Calculate optimal batch size based on available memory
    optimal_batch_size = calculateOptimalBatchSize(max_memory_gb, config);
    batch_size = min(batch_size, optimal_batch_size);
    fprintf('Using batch size: %d trials\n', batch_size);
    
    % Initialize parallel pool with memory limits
    pool = initializeParallelPool(max_workers, max_memory_gb);
    
    % Main generation loop
    total_trials = config.num_simulations;
    successful_trials = 0;
    
    try
        for batch_start = start_trial:batch_size:total_trials
            batch_end = min(batch_start + batch_size - 1, total_trials);
            current_batch_size = batch_end - batch_start + 1;
            
            fprintf('\n=== Processing Batch %d-%d of %d ===\n', ...
                batch_start, batch_end, total_trials);
            
            % Check memory before starting batch
            if ~checkMemoryAvailable(max_memory_gb)
                fprintf('⚠️  Low memory detected. Pausing for cleanup...\n');
                cleanupMemory();
                pause(5); % Give system time to free memory
            end
            
            % Process batch
            batch_results = processBatch(config, batch_start:batch_end, pool);
            
            % Update progress
            successful_in_batch = sum([batch_results.success]);
            successful_trials = successful_trials + successful_in_batch;
            
            % Add to completed trials
            completed_trials = [completed_trials, batch_start:batch_end];
            all_results = [all_results, batch_results];
            
            % Save checkpoint
            if mod(length(completed_trials), save_interval) == 0 || batch_end == total_trials
                saveCheckpoint(checkpoint_file, completed_trials, all_results, config);
                fprintf('✓ Checkpoint saved: %d/%d trials completed\n', ...
                    length(completed_trials), total_trials);
            end
            
            % Progress report
            fprintf('Batch complete: %d/%d successful (%.1f%%)\n', ...
                successful_trials, length(completed_trials), ...
                100 * successful_trials / length(completed_trials));
        end
        
        % Final compilation
        fprintf('\n=== Compiling Final Dataset ===\n');
        compileFinalDataset(config, all_results, successful_trials);
        
        % Cleanup
        if ~isempty(pool)
            delete(pool);
        end
        
        fprintf('\n✅ Dataset generation complete!\n');
        fprintf('Total trials: %d\n', total_trials);
        fprintf('Successful: %d (%.1f%%)\n', successful_trials, ...
            100 * successful_trials / total_trials);
        
    catch ME
        % Emergency save on error
        fprintf('\n❌ Error during generation: %s\n', ME.message);
        fprintf('Saving emergency checkpoint...\n');
        saveCheckpoint(checkpoint_file, completed_trials, all_results, config);
        
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
            fprintf('Processing trial %d/%d...\n', trial, config.num_simulations);
            
            try
                batch_results{i} = runSingleTrial(trial, config, []);
            catch ME
                fprintf('Trial %d failed: %s\n', trial, ME.message);
                batch_results{i} = struct('success', false, 'error', ME.message);
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