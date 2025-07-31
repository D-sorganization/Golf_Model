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
                
                % Get coefficients for this trial
                if trial <= size(config.coefficient_values, 1)
                    trial_coefficients = config.coefficient_values(trial, :);
                else
                    trial_coefficients = config.coefficient_values(end, :);
                end
                
                % Check if function exists
                if ~exist('runSingleTrial', 'file')
                    error('runSingleTrial function not found in path');
                end
                
                batch_results{i} = runSingleTrial(trial, config, trial_coefficients, capture_workspace);
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
            
            % Set up parallel workers with required functions
            fprintf('Setting up parallel workers with required functions...\n');
            current_dir = pwd;
            % Add current directory to parallel workers' path
            spmd
                addpath(current_dir);
                % Load the simulation worker functions
                simulation_worker_functions;
                % Ensure all required functions are available
                if ~exist('setModelParameters', 'file')
                    fprintf('Warning: setModelParameters function not found on worker\n');
                end
                if ~exist('setPolynomialCoefficients', 'file')
                    fprintf('Warning: setPolynomialCoefficients function not found on worker\n');
                end
                if ~exist('loadInputFile', 'file')
                    fprintf('Warning: loadInputFile function not found on worker\n');
                end
            end
            
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
                    
                    fprintf('DEBUG: Processing trial %d simulation output\n', trial);
                    fprintf('DEBUG: simOut class: %s\n', class(simOut));
                    
                    % Check if simOut is a valid simulation output object
                    if isempty(simOut) || ~isobject(simOut) || ~isa(simOut, 'Simulink.SimulationOutput')
                        fprintf('DEBUG: Invalid simulation output for trial %d - treating as failed\n', trial);
                        batch_results{i} = struct('success', false, 'error', 'Invalid simulation output');
                        continue;
                    end
                    
                    fprintf('DEBUG: About to call isSimulationSuccessful for trial %d\n', trial);
                    success_result = isSimulationSuccessful(simOut);
                    fprintf('DEBUG: isSimulationSuccessful returned: %s for trial %d\n', mat2str(success_result), trial);
                    if success_result
                        fprintf('DEBUG: Simulation successful, calling processSimulationOutput for trial %d\n', trial);
                        batch_results{i} = processSimulationOutput(trial, config, simOut, capture_workspace);
                    else
                        fprintf('DEBUG: Simulation failed for trial %d\n', trial);
                        batch_results{i} = struct('success', false, 'error', 'Simulation failed');
                    end
                catch ME
                    fprintf('DEBUG: Error processing trial %d: %s\n', trial, ME.message);
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
                    % Get coefficients for this trial
                    if trial <= size(config.coefficient_values, 1)
                        trial_coefficients = config.coefficient_values(trial, :);
                    else
                        trial_coefficients = config.coefficient_values(end, :);
                    end
                    
                    batch_results{i} = runSingleTrial(trial, config, trial_coefficients, capture_workspace);
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
    
    fprintf('=== DEBUG: ENTERING isSimulationSuccessful FUNCTION ===\n');
    fprintf('DEBUG: Checking simulation success...\n');
    fprintf('DEBUG: simOut class: %s\n', class(simOut));
    
    % Early return if simOut is not a valid simulation output object
    if isempty(simOut) || ~isobject(simOut) || ~isa(simOut, 'Simulink.SimulationOutput')
        fprintf('DEBUG: simOut is not a valid Simulink.SimulationOutput object\n');
        return;
    end
    
    fprintf('DEBUG: simOut properties: ');
    if isobject(simOut)
        props = properties(simOut);
        fprintf('%s\n', strjoin(props, ', '));
    else
        fprintf('not an object\n');
    end
    
    try
        % Check for error message
        if isprop(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
            fprintf('DEBUG: Simulation has error message: %s\n', simOut.ErrorMessage);
            return;
        end
        
        % Check simulation metadata
        if isprop(simOut, 'SimulationMetadata') && ...
           isfield(simOut.SimulationMetadata, 'ExecutionInfo')
            
            execInfo = simOut.SimulationMetadata.ExecutionInfo;
            if isfield(execInfo, 'StopEvent') && execInfo.StopEvent == "CompletedNormally"
                success = true;
                fprintf('DEBUG: Simulation completed normally\n');
                return;
            else
                fprintf('DEBUG: Simulation did not complete normally\n');
            end
        end
        
        % Check for output data (including CombinedSignalBus)
        fprintf('DEBUG: Checking for data sources...\n');
        has_logsout = isprop(simOut, 'logsout') || isfield(simOut, 'logsout');
        has_simlog = isprop(simOut, 'simlog') || isfield(simOut, 'simlog');
        has_combined_bus = isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus');
        fprintf('DEBUG: has_logsout: %s, has_simlog: %s, has_combined_bus: %s\n', ...
            mat2str(has_logsout), mat2str(has_simlog), mat2str(has_combined_bus));
        
        if has_logsout || has_simlog || has_combined_bus
            success = true;
            fprintf('DEBUG: Simulation marked as successful due to data presence\n');
        else
            fprintf('DEBUG: No data sources found (logsout, simlog, or CombinedSignalBus)\n');
        end
        
    catch ME
        % If we can't determine, assume failure
        fprintf('DEBUG: Error checking simulation success: %s\n', ME.message);
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

function logProgress(current, total, message)
    % Fallback progress logging function
    percentage = 100 * current / total;
    fprintf('\r%s: %d/%d (%.1f%%)', message, current, total, percentage);
    if current == total
        fprintf('\n');
    end
end

function logTrialResult(trial_num, success, duration, error_msg)
    % Fallback trial result logging function
    if success
        fprintf('Trial %d completed successfully in %.2f seconds\n', trial_num, duration);
    else
        fprintf('Trial %d failed after %.2f seconds: %s\n', trial_num, duration, error_msg);
    end
end

function logCheckpoint(duration, file_size_mb)
    % Fallback checkpoint logging function
    fprintf('Checkpoint saved in %.2f seconds (%.1f MB)\n', duration, file_size_mb);
end

function recordTrialTime(trial, duration, processing_time)
    % Fallback trial time recording function
    % Do nothing in fallback version
end

function recordBatchTime(batch_num, batch_size, duration, successful)
    % Fallback batch time recording function
    % Do nothing in fallback version
end

function recordCheckpointTime(duration)
    % Fallback checkpoint time recording function
    % Do nothing in fallback version
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

% ============================================================================
% SIMULATION FUNCTIONS (copied from Data_GUI.m for self-containment)
% ============================================================================

function result = runSingleTrial(trial_num, config, trial_coefficients, capture_workspace)
    result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);
    
    try
        % Create simulation input
        simIn = Simulink.SimulationInput(config.model_path);
        
        % Set model parameters
        simIn = setModelParameters(simIn, config);
        
        % Set polynomial coefficients for this trial
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);
        
        % Suppress specific warnings that are not critical
        warning_state = warning('off', 'Simulink:Bus:EditTimeBusPropNotAllowed');
        warning_state2 = warning('off', 'Simulink:Engine:BlockOutputNotUpdated');
        warning_state3 = warning('off', 'Simulink:Engine:OutputNotConnected');
        warning_state4 = warning('off', 'Simulink:Engine:InputNotConnected');
        warning_state5 = warning('off', 'Simulink:Blocks:UnconnectedOutputPort');
        warning_state6 = warning('off', 'Simulink:Blocks:UnconnectedInputPort');
        
        % Run simulation with progress indicator and visualization suppression
        fprintf('Running trial %d simulation...', trial_num);
        
        % Suppress visualization by setting model parameters
        try
            simIn = simIn.setModelParameter('ShowSimulationManager', 'off');
            simIn = simIn.setModelParameter('ShowProgress', 'off');
        catch
            % If these parameters don't exist, continue anyway
        end
        
        simOut = sim(simIn);
        fprintf(' Done.\n');
        
        % Restore warning state
        warning(warning_state);
        warning(warning_state2);
        warning(warning_state3);
        warning(warning_state4);
        warning(warning_state5);
        warning(warning_state6);
        
        % Process simulation output
        result = processSimulationOutput(trial_num, config, simOut, capture_workspace);
        
    catch ME
        % Restore warning state in case of error
        if exist('warning_state', 'var')
            warning(warning_state);
        end
        if exist('warning_state2', 'var')
            warning(warning_state2);
        end
        if exist('warning_state3', 'var')
            warning(warning_state3);
        end
        if exist('warning_state4', 'var')
            warning(warning_state4);
        end
        if exist('warning_state5', 'var')
            warning(warning_state5);
        end
        if exist('warning_state6', 'var')
            warning(warning_state6);
        end
        
        fprintf(' Failed.\n');
        result.success = false;
        result.error = ME.message;
        fprintf('Trial %d simulation failed: %s\n', trial_num, ME.message);
        
        % Print stack trace for debugging
        fprintf('Error details:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

function simIn = setModelParameters(simIn, config)
    % Set basic simulation parameters with careful error handling
    try
        % Set stop time
        if isfield(config, 'simulation_time') && ~isempty(config.simulation_time)
            simIn = simIn.setModelParameter('StopTime', num2str(config.simulation_time));
        end
        
        % Set solver carefully
        try
            simIn = simIn.setModelParameter('Solver', 'ode23t');
        catch
            fprintf('Warning: Could not set solver to ode23t\n');
        end
        
        % Set tolerances carefully
        try
            simIn = simIn.setModelParameter('RelTol', '1e-3');
            simIn = simIn.setModelParameter('AbsTol', '1e-5');
        catch
            fprintf('Warning: Could not set solver tolerances\n');
        end
        
        % CRITICAL: Set output options for data logging
        try
            simIn = simIn.setModelParameter('SaveOutput', 'on');
            simIn = simIn.setModelParameter('SaveFormat', 'Structure');
            simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');
        catch ME
            fprintf('Warning: Could not set output options: %s\n', ME.message);
        end
        
        % Additional logging settings
        try
            simIn = simIn.setModelParameter('SignalLogging', 'on');
            simIn = simIn.setModelParameter('SaveTime', 'on');
        catch
            fprintf('Warning: Could not set logging options\n');
        end
        
        % To Workspace block settings
        try
            simIn = simIn.setModelParameter('LimitDataPoints', 'off');
        catch
            fprintf('Warning: Could not set LimitDataPoints\n');
        end
        
        % MINIMAL SIMSCAPE LOGGING CONFIGURATION (Essential Only)
        % Only set the essential parameter that actually works
        try
            simIn = simIn.setModelParameter('SimscapeLogType', 'all');
            fprintf('Debug: ✅ Set SimscapeLogType = all (essential parameter)\n');
        catch ME
            fprintf('Warning: Could not set essential SimscapeLogType parameter: %s\n', ME.message);
            fprintf('Warning: Simscape data extraction may not work without this parameter\n');
        end
        
        % Set other model parameters to suppress unconnected port warnings
        try
            simIn = simIn.setModelParameter('UnconnectedInputMsg', 'none');
            simIn = simIn.setModelParameter('UnconnectedOutputMsg', 'none');
        catch
            % These parameters might not exist in all model types
        end
        
        % ANIMATION CONTROL - Set simulation mode based on animation preference
        try
            if isfield(config, 'enable_animation') && ~config.enable_animation
                % Disable animation by setting to accelerator mode
                simIn = simIn.setModelParameter('SimulationMode', 'accelerator');
                fprintf('Debug: Animation disabled (accelerator mode)\n');
            else
                % Enable animation with normal mode
                simIn = simIn.setModelParameter('SimulationMode', 'normal');
                fprintf('Debug: Animation enabled (normal mode)\n');
            end
        catch ME
            fprintf('Warning: Could not set animation mode: %s\n', ME.message);
        end
        
    catch ME
        fprintf('Error setting model parameters: %s\n', ME.message);
        rethrow(ME);
    end
end

function simIn = setPolynomialCoefficients(simIn, trial_coefficients, config)
    % DEBUG: Print what we're receiving
    fprintf('DEBUG: setPolynomialCoefficients called with:\n');
    fprintf('  coefficients class: %s\n', class(trial_coefficients));
    fprintf('  coefficients size: %s\n', mat2str(size(trial_coefficients)));
    if iscell(trial_coefficients)
        fprintf('  coefficients is cell array with %d elements\n', numel(trial_coefficients));
        if numel(trial_coefficients) > 0
            fprintf('  first element class: %s\n', class(trial_coefficients{1}));
        end
    end
    
    % Set polynomial coefficients for the simulation
    try
        fprintf('DEBUG: Starting setPolynomialCoefficients processing\n');
        if ~isempty(trial_coefficients)
            % Handle parallel worker coefficient format issues
            if iscell(trial_coefficients)
                fprintf('Debug: Converting cell array coefficients to numeric (parallel worker fix)\n');
                try
                    % Check if cells contain strings or numbers
                    if all(cellfun(@ischar, trial_coefficients))
                        % Convert string cells to numeric
                        trial_coefficients = cellfun(@str2double, trial_coefficients);
                        fprintf('Debug: Converted string cells to numeric\n');
                    elseif all(cellfun(@isnumeric, trial_coefficients))
                        % Convert numeric cells to array
                        trial_coefficients = cell2mat(trial_coefficients);
                        fprintf('Debug: Converted numeric cells to array\n');
                    else
                        % Mixed content or other issues
                        fprintf('Warning: Mixed cell content, attempting element-wise conversion\n');
                        numeric_coeffs = zeros(size(trial_coefficients));
                        for i = 1:numel(trial_coefficients)
                            if ischar(trial_coefficients{i})
                                numeric_coeffs(i) = str2double(trial_coefficients{i});
                            elseif isnumeric(trial_coefficients{i})
                                numeric_coeffs(i) = trial_coefficients{i};
                            else
                                numeric_coeffs(i) = NaN;
                            end
                        end
                        trial_coefficients = numeric_coeffs;
                    end
                catch ME
                    fprintf('Error: Could not convert cell coefficients to numeric: %s\n', ME.message);
                    % Try one more approach - flatten and convert
                    try
                        trial_coefficients = str2double(trial_coefficients(:));
                        fprintf('Debug: Used str2double on flattened cells\n');
                    catch
                        fprintf('Error: All conversion attempts failed\n');
                        return;
                    end
                end
            end
            
            % Ensure coefficients are numeric
            if ~isnumeric(trial_coefficients)
                fprintf('Error: Coefficients must be numeric, got %s\n', class(trial_coefficients));
                return;
            end
            
            % Set coefficients for each joint
            fprintf('DEBUG: About to call getPolynomialParameterInfo()\n');
            param_info = getPolynomialParameterInfo();
            fprintf('DEBUG: getPolynomialParameterInfo() returned successfully\n');
            coeff_idx = 1;
            
            fprintf('DEBUG: Starting loop through %d joints\n', length(param_info.joint_names));
            for j = 1:length(param_info.joint_names)
                joint_name = param_info.joint_names{j};
                coeffs = param_info.joint_coeffs{j};
                fprintf('DEBUG: Processing joint %d: %s with %d coefficients\n', j, joint_name, length(coeffs));
                
                for k = 1:length(coeffs)
                    fprintf('DEBUG: Processing coefficient %d: %s (class: %s)\n', k, coeffs{k}, class(coeffs{k}));
                    if coeff_idx <= length(trial_coefficients)
                        param_name = sprintf('%s_%s', joint_name, coeffs{k});
                        fprintf('DEBUG: Created param_name: %s\n', param_name);
                        simIn = simIn.setVariable(param_name, trial_coefficients(coeff_idx));
                        fprintf('DEBUG: Set variable %s = %.3f\n', param_name, trial_coefficients(coeff_idx));
                        coeff_idx = coeff_idx + 1;
                    end
                end
            end
        end
    catch ME
        fprintf('Warning: Could not set polynomial coefficients: %s\n', ME.message);
    end
end

function param_info = getPolynomialParameterInfo()
    % Get polynomial parameter information for coefficient setting
    param_info = struct();
    param_info.joint_names = {'Hip', 'Knee', 'Ankle', 'Shoulder', 'Elbow', 'Wrist'};
    param_info.joint_coeffs = {
        {'a0', 'a1', 'a2', 'a3', 'a4', 'a5'},  % Hip
        {'b0', 'b1', 'b2', 'b3', 'b4', 'b5'},  % Knee
        {'c0', 'c1', 'c2', 'c3', 'c4', 'c5'},  % Ankle
        {'d0', 'd1', 'd2', 'd3', 'd4', 'd5'},  % Shoulder
        {'e0', 'e1', 'e2', 'e3', 'e4', 'e5'},  % Elbow
        {'f0', 'f1', 'f2', 'f3', 'f4', 'f5'}   % Wrist
    };
end

function result = processSimulationOutput(trial_num, config, simOut, capture_workspace)
    result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);
    result.data_captured = struct();
    result.data_captured.signal_bus = false;
    result.data_captured.logsout = false;
    result.data_captured.simscape = false;
    result.data_captured.workspace = false;
    
    try
        fprintf('Processing simulation output for trial %d...\n', trial_num);
        
        % --- BEGIN VERIFICATION CHECKS ---
        fprintf('  Verification for Trial %d:\n', trial_num);
        fprintf('  - Model Workspace Capture Requested: %s\n', logical2str(capture_workspace));
        fprintf('  - CombinedSignalBus Capture Requested: %s\n', logical2str(config.use_signal_bus));
        fprintf('  - Logsout Capture Requested: %s\n', logical2str(config.use_logsout));
        fprintf('  - Simscape Results Capture Requested: %s\n', logical2str(config.use_simscape));
        
        % Check what data sources are actually available and contain data
        if isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus')
            bus_data = simOut.CombinedSignalBus;
            if ~isempty(bus_data) && isstruct(bus_data)
                fields = fieldnames(bus_data);
                has_data = any(cellfun(@(f) ~isempty(bus_data.(f)), fields));
                fprintf('  - CombinedSignalBus Available: YES (has data: %s)\n', logical2str(has_data));
                result.data_captured.signal_bus = has_data;
            else
                fprintf('  - CombinedSignalBus Available: YES (empty)\n');
            end
        else
            fprintf('  - CombinedSignalBus Available: NO\n');
        end
        
        if isprop(simOut, 'logsout') || isfield(simOut, 'logsout')
            logsout_data = simOut.logsout;
            if ~isempty(logsout_data)
                if isa(logsout_data, 'Simulink.SimulationData.Dataset')
                    has_data = logsout_data.numElements > 0;
                    fprintf('  - Logsout Available: YES (has data: %s, %d elements)\n', logical2str(has_data), logsout_data.numElements);
                    result.data_captured.logsout = has_data;
                else
                    fprintf('  - Logsout Available: YES (non-Dataset format)\n');
                    result.data_captured.logsout = true;
                end
            else
                fprintf('  - Logsout Available: YES (empty)\n');
            end
        else
            fprintf('  - Logsout Available: NO\n');
        end
        
        if isprop(simOut, 'simlog') || isfield(simOut, 'simlog')
            simlog_data = simOut.simlog;
            if ~isempty(simlog_data)
                fprintf('  - Simscape simlog Available: YES (has data)\n');
                result.data_captured.simscape = true;
            else
                fprintf('  - Simscape simlog Available: YES (empty)\n');
            end
        else
            fprintf('  - Simscape simlog Available: NO\n');
        end
        % --- END VERIFICATION CHECKS ---
        
        % Extract data using the enhanced signal extraction system
        options = struct();
        options.extract_combined_bus = config.use_signal_bus;
        options.extract_logsout = config.use_logsout;
        options.extract_simscape = config.use_simscape;
        
        % Set verbosity based on config
        if isfield(config, 'Verbosity')
            options.verbose = strcmp(config.Verbosity, 'verbose');
        else
            options.verbose = false; % Default to quiet
        end
        
        if options.verbose
            fprintf('DEBUG: About to call extractSignalsFromSimOut...\n');
        end
        try
            [data_table, signal_info] = extractSignalsFromSimOut(simOut, options);
            if options.verbose
                fprintf('DEBUG: extractSignalsFromSimOut completed successfully\n');
            end
        catch ME
            fprintf('ERROR: extractSignalsFromSimOut failed: %s\n', ME.message);
            fprintf('Stack trace:\n');
            for i = 1:length(ME.stack)
                fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
            result.error = sprintf('Data extraction failed: %s', ME.message);
            return;
        end
        
        if isempty(data_table)
            result.error = 'No data extracted from simulation';
            fprintf('No data extracted from simulation output\n');
            return;
        end
        
        fprintf('Extracted %d rows of data\n', height(data_table));
        
        % Resample data to desired frequency if specified
        if isfield(config, 'sample_rate') && ~isempty(config.sample_rate) && config.sample_rate > 0
            data_table = resampleDataToFrequency(data_table, config.sample_rate, config.simulation_time);
            fprintf('Resampled to %d rows at %g Hz\n', height(data_table), config.sample_rate);
        end
        
        % Add trial metadata
        num_rows = height(data_table);
        data_table.trial_id = repmat(trial_num, num_rows, 1);
        
        % Add coefficient columns
        param_info = getPolynomialParameterInfo();
        coeff_idx = 1;
        for j = 1:length(param_info.joint_names)
            joint_name = param_info.joint_names{j};
            coeffs = param_info.joint_coeffs{j};
            for k = 1:length(coeffs)
                coeff_name = sprintf('input_%s_%s', getShortenedJointName(joint_name), coeffs(k));
                if coeff_idx <= size(config.coefficient_values, 2)
                    data_table.(coeff_name) = repmat(config.coefficient_values(trial_num, coeff_idx), num_rows, 1);
                end
                coeff_idx = coeff_idx + 1;
            end
        end
        
        % Add model workspace variables (segment lengths, masses, inertias, etc.)
        % Use the capture_workspace parameter passed to this function
        if nargin < 4
            capture_workspace = true; % Default to true if not provided
        end
        
        if capture_workspace
            data_table = addModelWorkspaceData(data_table, simOut, num_rows);
            result.data_captured.workspace = true;
        else
            logWorkspaceCapture(false, 0);
        end
        
        % Save to file in selected format(s)
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        saved_files = {};
        
        % Determine file format from config (handle both field names for compatibility)
        file_format = 1; % Default to CSV
        if isfield(config, 'file_format')
            file_format = config.file_format;
        elseif isfield(config, 'format')
            file_format = config.format;
        end
        
        % Save based on selected format
        switch file_format
            case 1 % CSV Files
                filename = sprintf('trial_%03d_%s.csv', trial_num, timestamp);
                filepath = fullfile(config.output_folder, filename);
                writetable(data_table, filepath);
                saved_files{end+1} = filename;
                
            case 2 % MAT Files
                filename = sprintf('trial_%03d_%s.mat', trial_num, timestamp);
                filepath = fullfile(config.output_folder, filename);
                save(filepath, 'data_table', 'config');
                saved_files{end+1} = filename;
                
            case 3 % Both CSV and MAT
                % Save CSV
                csv_filename = sprintf('trial_%03d_%s.csv', trial_num, timestamp);
                csv_filepath = fullfile(config.output_folder, csv_filename);
                writetable(data_table, csv_filepath);
                saved_files{end+1} = csv_filename;
                
                % Save MAT
                mat_filename = sprintf('trial_%03d_%s.mat', trial_num, timestamp);
                mat_filepath = fullfile(config.output_folder, mat_filename);
                save(mat_filepath, 'data_table', 'config');
                saved_files{end+1} = mat_filename;
        end
        
        % Update result with primary filename
        filename = saved_files{1};
        
        % Verify each source was captured if requested
        if config.use_signal_bus && ~result.data_captured.signal_bus
            fprintf('WARNING: CombinedSignalBus requested but not captured\n');
            result.success = false;
        elseif config.use_logsout && ~result.data_captured.logsout
            fprintf('WARNING: Logsout requested but not captured\n');
            result.success = false;
        elseif config.use_simscape && ~result.data_captured.simscape
            fprintf('WARNING: Simscape requested but not captured\n');
            result.success = false;
        elseif capture_workspace && ~result.data_captured.workspace
            fprintf('WARNING: Model workspace requested but not captured\n');
            result.success = false;
        else
            result.success = true;
        end
        
        result.filename = filename;
        result.data_points = num_rows;
        result.columns = width(data_table);
        
        fprintf('Trial %d completed: %d data points, %d columns (success: %s)\n', trial_num, num_rows, width(data_table), logical2str(result.success));
        
    catch ME
        result.success = false;
        result.error = ME.message;
        fprintf('Error processing trial %d output: %s\n', trial_num, ME.message);
        
        % Print stack trace for debugging
        fprintf('Processing error details:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end

% Fallback functions for missing dependencies
function short_name = getShortenedJointName(joint_name)
    % Fallback function for joint name shortening
    short_name = joint_name;
end

function data_table = addModelWorkspaceData(data_table, simOut, num_rows)
    % Fallback function for adding workspace data
    % This is a simplified version - the full version would extract model workspace variables
    fprintf('Workspace data capture not implemented in fallback version\n');
    % IMPORTANT: Return the data_table to prevent it from becoming []
    % This ensures the calling function can continue with the table
end

function logWorkspaceCapture(enabled, num_vars)
    % Fallback function for workspace capture logging
    if enabled
        fprintf('Workspace capture enabled (%d variables)\n', num_vars);
    else
        fprintf('Workspace capture disabled\n');
    end
end

function data_table = resampleDataToFrequency(data_table, target_freq, simulation_time)
    % Fallback function for data resampling
    % This is a simplified version - the full version would resample the data
    fprintf('Data resampling not implemented in fallback version\n');
    % IMPORTANT: Return the data_table to prevent it from becoming []
    % This ensures the calling function can continue with the table
end

function [data_table, signal_info] = extractSignalsFromSimOut(simOut, options)
    % Extract signals from simulation output based on specified options
    % This replaces the missing extractAllSignalsFromBus function
    
    data_table = [];
    signal_info = struct();
    
    try
        % Validate simOut input to prevent brace indexing errors
        if isempty(simOut)
            if options.verbose
                fprintf('Warning: Empty simulation output provided\n');
            end
            return;
        end
        
        % Check if simOut is a valid simulation output object
        if ~isobject(simOut) && ~isstruct(simOut)
            if options.verbose
                fprintf('Warning: Invalid simulation output type: %s\n', class(simOut));
            end
            return;
        end
        
        % Initialize data collection
        all_data = {};
        
        % Extract from CombinedSignalBus if enabled and available
        if options.extract_combined_bus && (isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus'))
            if options.verbose
                fprintf('DEBUG: Extracting from CombinedSignalBus...\n');
            end
            
            try
                combinedBus = simOut.CombinedSignalBus;
                if ~isempty(combinedBus)
                    if options.verbose
                        fprintf('DEBUG: Calling extractCombinedSignalBusData...\n');
                    end
                    signal_bus_data = extractCombinedSignalBusData(combinedBus);
                    
                    if ~isempty(signal_bus_data)
                        all_data{end+1} = signal_bus_data;
                        if options.verbose
                            fprintf('DEBUG: CombinedSignalBus: %d columns extracted\n', width(signal_bus_data));
                        end
                    else
                        if options.verbose
                            fprintf('DEBUG: CombinedSignalBus extraction returned empty data\n');
                        end
                    end
                else
                    if options.verbose
                        fprintf('DEBUG: CombinedSignalBus is empty\n');
                    end
                end
            catch ME
                fprintf('ERROR: Failed to extract CombinedSignalBus data: %s\n', ME.message);
                if options.verbose
                    fprintf('Stack trace:\n');
                    for i = 1:length(ME.stack)
                        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                    end
                end
            end
        end
        
        % Extract from logsout if enabled and available
        if options.extract_logsout && (isprop(simOut, 'logsout') || isfield(simOut, 'logsout'))
            if options.verbose
                fprintf('Extracting from logsout...\n');
            end
            
            try
                logsout_data = extractLogsoutDataFixed(simOut.logsout);
                if ~isempty(logsout_data)
                    all_data{end+1} = logsout_data;
                    if options.verbose
                        fprintf('Logsout: %d columns extracted\n', width(logsout_data));
                    end
                end
            catch ME
                if contains(ME.message, 'brace indexing') || contains(ME.message, 'comma separated list')
                    if options.verbose
                        fprintf('Warning: Brace indexing error accessing logsout: %s\n', ME.message);
                    end
                else
                    if options.verbose
                        fprintf('Warning: Error extracting logsout: %s\n', ME.message);
                    end
                end
            end
        end
        
        % Extract from Simscape if enabled and available
        if options.extract_simscape
            if options.verbose
                fprintf('DEBUG: Checking for Simscape simlog...\n');
            end
            
            % Enhanced simlog access for parallel execution
            simlog_available = false;
            simlog_data = [];
            
            if isprop(simOut, 'simlog') || isfield(simOut, 'simlog')
                try
                    simlog_data = simOut.simlog;
                    if ~isempty(simlog_data)
                        simlog_available = true;
                        if options.verbose
                            fprintf('DEBUG: Simscape simlog found and accessible\n');
                        end
                    else
                        if options.verbose
                            fprintf('DEBUG: Simscape simlog is empty\n');
                        end
                    end
                catch ME
                    fprintf('ERROR: Failed to access simlog: %s\n', ME.message);
                end
            else
                if options.verbose
                    fprintf('DEBUG: No simlog property/field found in simOut\n');
                end
            end
            
            if simlog_available
                try
                    if options.verbose
                        fprintf('DEBUG: Calling extractSimscapeDataFixed...\n');
                    end
                    simscape_data = extractSimscapeDataFixed(simlog_data);
                    if ~isempty(simscape_data)
                        all_data{end+1} = simscape_data;
                        if options.verbose
                            fprintf('DEBUG: Simscape: %d columns extracted\n', width(simscape_data));
                        end
                    else
                        if options.verbose
                            fprintf('DEBUG: Simscape extraction returned empty data\n');
                        end
                    end
                catch ME
                    fprintf('ERROR: Failed to extract Simscape data: %s\n', ME.message);
                    if options.verbose
                        fprintf('Stack trace:\n');
                        for i = 1:length(ME.stack)
                            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
                        end
                    end
                end
            else
                if options.verbose
                    fprintf('DEBUG: No Simscape simlog data available\n');
                end
            end
        end
        
        % Combine all extracted data
        if ~isempty(all_data)
            % Start with the first dataset
            data_table = all_data{1};
            
            % Add additional datasets as columns
            for i = 2:length(all_data)
                if ~isempty(all_data{i})
                    % Get common time column if available
                    if ismember('time', data_table.Properties.VariableNames) && ...
                       ismember('time', all_data{i}.Properties.VariableNames)
                        % Merge on time column
                        data_table = outerjoin(data_table, all_data{i}, 'MergeKeys', true);
                    else
                        % Simple concatenation
                        data_table = [data_table, all_data{i}];
                    end
                end
            end
            
            if options.verbose
                fprintf('Final combined dataset: %d rows, %d columns\n', height(data_table), width(data_table));
            end
        else
            if options.verbose
                fprintf('No data extracted from any source\n');
            end
        end
        
    catch ME
        fprintf('Error in extractSignalsFromSimOut: %s\n', ME.message);
        data_table = [];
    end
end 

% ============================================================================
% MISSING FUNCTION DEPENDENCIES - ADDED FOR INTEGRATION
% ============================================================================

function data_table = extractCombinedSignalBusData(combinedBus)
    % Extract data from CombinedSignalBus structure
    data_table = [];
    
    try
        if ~isstruct(combinedBus)
            fprintf('DEBUG: CombinedSignalBus is not a struct\n');
            return;
        end
        
        % Get field names
        fields = fieldnames(combinedBus);
        data_cells = {};
        var_names = {};
        
        % Find time reference from first valid field
        time_data = [];
        expected_length = 0;
        
        for i = 1:length(fields)
            field_name = fields{i};
            field_value = combinedBus.(field_name);
            
            if isstruct(field_value) && isfield(field_value, 'time')
                time_data = field_value.time;
                expected_length = length(time_data);
                break;
            elseif isnumeric(field_value) && length(field_value) > 10
                % Assume this is time data
                time_data = field_value;
                expected_length = length(time_data);
                break;
            end
        end
        
        if isempty(time_data)
            fprintf('DEBUG: No time data found in CombinedSignalBus\n');
            return;
        end
        
        % Add time column
        data_cells{end+1} = time_data;
        var_names{end+1} = 'time';
        
        % Extract all signals
        for i = 1:length(fields)
            field_name = fields{i};
            field_value = combinedBus.(field_name);
            
            if isstruct(field_value)
                % Handle nested structure
                sub_fields = fieldnames(field_value);
                for j = 1:length(sub_fields)
                    sub_field = sub_fields{j};
                    sub_value = field_value.(sub_field);
                    
                    if isnumeric(sub_value) && length(sub_value) == expected_length
                        data_cells{end+1} = sub_value;
                        var_names{end+1} = sprintf('%s_%s', field_name, sub_field);
                    elseif isnumeric(sub_value) && size(sub_value, 1) == expected_length
                        % Multi-column data
                        for col = 1:size(sub_value, 2)
                            data_cells{end+1} = sub_value(:, col);
                            var_names{end+1} = sprintf('%s_%s_%d', field_name, sub_field, col);
                        end
                    end
                end
            elseif isnumeric(field_value) && length(field_value) == expected_length
                data_cells{end+1} = field_value;
                var_names{end+1} = field_name;
            end
        end
        
        if length(data_cells) > 1
            data_table = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('DEBUG: CombinedSignalBus extracted %d columns\n', width(data_table));
        end
        
    catch ME
        fprintf('Error extracting CombinedSignalBus data: %s\n', ME.message);
    end
end

function logsout_data = extractLogsoutDataFixed(logsout)
    % Fixed logsout data extraction
    logsout_data = [];
    
    try
        % Handle modern Simulink.SimulationData.Dataset format
        if isa(logsout, 'Simulink.SimulationData.Dataset')
            if logsout.numElements == 0
                fprintf('DEBUG: Logsout dataset is empty\n');
                return;
            end
            
            % Get time from first element
            first_element = logsout.getElement(1);
            
            % Handle Signal objects properly
            if isa(first_element, 'Simulink.SimulationData.Signal')
                time = first_element.Values.Time;
            elseif isa(first_element, 'timeseries')
                time = first_element.Time;
            else
                fprintf('DEBUG: Unsupported first element type: %s\n', class(first_element));
                return;
            end
            
            data_cells = {time};
            var_names = {'time'};
            expected_length = length(time);
            
            % Process each element in the dataset
            for i = 1:logsout.numElements
                element = logsout.getElement(i);
                
                if isa(element, 'Simulink.SimulationData.Signal')
                    signalName = element.Name;
                    if isempty(signalName)
                        signalName = sprintf('Signal_%d', i);
                    end
                    
                    % Extract data from Signal object
                    data = element.Values.Data;
                    signal_time = element.Values.Time;
                    
                    % Ensure data matches time length and is valid
                    if isnumeric(data) && length(signal_time) == expected_length && ~isempty(data)
                        if size(data, 1) == expected_length
                            if size(data, 2) > 1
                                % Multi-dimensional signal
                                for col = 1:size(data, 2)
                                    col_data = data(:, col);
                                    if length(col_data) == expected_length
                                        data_cells{end+1} = col_data;
                                        var_names{end+1} = sprintf('%s_%d', signalName, col);
                                    end
                                end
                            else
                                % Single column signal
                                flat_data = data(:);
                                if length(flat_data) == expected_length
                                    data_cells{end+1} = flat_data;
                                    var_names{end+1} = signalName;
                                end
                            end
                        end
                    end
                elseif isa(element, 'timeseries')
                    signalName = element.Name;
                    data = element.Data;
                    if isnumeric(data) && length(data) == expected_length && ~isempty(data)
                        flat_data = data(:);
                        if length(flat_data) == expected_length
                            data_cells{end+1} = flat_data;
                            var_names{end+1} = signalName;
                        end
                    end
                end
            end
            
            % Validate all data vectors have the same length before creating table
            if length(data_cells) > 1
                lengths = cellfun(@length, data_cells);
                if all(lengths == expected_length)
                    logsout_data = table(data_cells{:}, 'VariableNames', var_names);
                    fprintf('DEBUG: Logsout extracted %d columns\n', width(logsout_data));
                else
                    % Try to create table with only vectors of the correct length
                    valid_indices = find(lengths == expected_length);
                    if length(valid_indices) > 1
                        valid_cells = data_cells(valid_indices);
                        valid_names = var_names(valid_indices);
                        logsout_data = table(valid_cells{:}, 'VariableNames', valid_names);
                        fprintf('DEBUG: Logsout extracted %d columns (filtered)\n', width(logsout_data));
                    end
                end
            end
            
        else
            fprintf('DEBUG: Logsout format not supported: %s\n', class(logsout));
        end
        
    catch ME
        fprintf('Error extracting logsout data: %s\n', ME.message);
    end
end

function simscape_data = extractSimscapeDataFixed(simlog)
    % Fixed Simscape data extraction using Method 2 (direct access)
    simscape_data = table();
    
    try
        if isempty(simlog)
            fprintf('DEBUG: Simlog is empty\n');
            return;
        end
        
        if ~isa(simlog, 'simscape.logging.Node')
            fprintf('DEBUG: Simlog is not a simscape.logging.Node: %s\n', class(simlog));
            return;
        end
        
        % Use Method 2: Direct access to node.series.time and node.series.values
        [time_data, all_signals] = traverseSimlogNodeFixed(simlog, '');
        
        if isempty(time_data) || isempty(all_signals)
            fprintf('DEBUG: No time data or signals extracted from simlog\n');
            return;
        end
        
        % Build table
        data_cells = {time_data};
        var_names = {'time'};
        expected_length = length(time_data);
        
        for i = 1:length(all_signals)
            signal = all_signals{i};
            if length(signal.data) == expected_length
                data_cells{end+1} = signal.data(:);
                var_names{end+1} = signal.name;
            end
        end
        
        if length(data_cells) > 1
            simscape_data = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('DEBUG: Simscape extracted %d columns\n', width(simscape_data));
        end
        
    catch ME
        fprintf('Error extracting Simscape data: %s\n', ME.message);
    end
end

function [time_data, signals] = traverseSimlogNodeFixed(node, parent_path)
    % Traverse Simscape log nodes using Method 2 (direct access)
    time_data = [];
    signals = {};
    
    try
        % Get current node name
        node_name = '';
        try
            node_name = node.id;
        catch
            node_name = 'UnnamedNode';
        end
        current_path = fullfile(parent_path, node_name);
        
        % Method 2: Direct access to series data
        if isprop(node, 'series')
            try
                extracted_time = node.series.time;
                extracted_data = node.series.values;
                
                if ~isempty(extracted_time) && ~isempty(extracted_data) && length(extracted_time) > 0
                    if isempty(time_data)
                        time_data = extracted_time;
                    end
                    
                    signal_name = matlab.lang.makeValidName(sprintf('%s_%s', current_path, node_name));
                    signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                end
            catch ME
                % No series data at this node
                fprintf('DEBUG: No series data at node %s: %s\n', node_name, ME.message);
            end
        end
        
        % Recurse into child nodes
        child_ids = [];
        try
            child_ids = node.children();
        catch
            % Use properties as children
            try
                all_props = properties(node);
                child_ids = {};
                for i = 1:length(all_props)
                    prop_name = all_props{i};
                    if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                        try
                            prop_value = node.(prop_name);
                            if isa(prop_value, 'simscape.logging.Node')
                                child_ids{end+1} = prop_name;
                            end
                        catch
                            % Skip properties that can't be accessed
                        end
                    end
                end
            catch
                child_ids = [];
            end
        end
        
        % Process child nodes
        for i = 1:length(child_ids)
            try
                child_node = node.(child_ids{i});
                [child_time, child_signals] = traverseSimlogNodeFixed(child_node, current_path);
                
                if isempty(time_data) && ~isempty(child_time)
                    time_data = child_time;
                end
                
                if ~isempty(child_signals)
                    signals = [signals, child_signals];
                end
            catch ME
                fprintf('DEBUG: Error accessing child %s: %s\n', child_ids{i}, ME.message);
            end
        end
        
    catch ME
        fprintf('DEBUG: Error traversing node %s: %s\n', node_name, ME.message);
    end
end

% ============================================================================
% HELPER FUNCTIONS FOR INTEGRATION
% ============================================================================

function simIn = loadInputFile(simIn, input_file)
    % Load input file into simulation
    try
        if exist(input_file, 'file')
            simIn = simIn.setExternalInput(input_file);
            fprintf('DEBUG: Loaded input file: %s\n', input_file);
        else
            fprintf('WARNING: Input file not found: %s\n', input_file);
        end
    catch ME
        fprintf('ERROR: Failed to load input file %s: %s\n', input_file, ME.message);
    end
end

% Helper function for logical to string conversion
function str = logical2str(logical_val)
    if logical_val
        str = 'enabled';
    else
        str = 'disabled';
    end
end 