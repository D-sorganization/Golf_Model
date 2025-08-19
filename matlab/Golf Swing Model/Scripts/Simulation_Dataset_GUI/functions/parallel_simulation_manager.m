function successful_trials = parallel_simulation_manager(handles, config, mode)
    % PARALLEL_SIMULATION_MANAGER - Manages parallel and sequential simulation execution
    %
    % This function provides a unified interface for running simulations in either
    % parallel or sequential mode, with robust error handling and progress tracking.
    %
    % Inputs:
    %   handles - GUI handles structure for progress updates
    %   config - Configuration structure with simulation parameters
    %   mode - Execution mode: 'parallel' or 'sequential'
    %
    % Outputs:
    %   successful_trials - Number of successfully completed trials
    %
    % Usage:
    %   successful_trials = parallel_simulation_manager(handles, config, 'parallel');
    %   successful_trials = parallel_simulation_manager(handles, config, 'sequential');
    
    if nargin < 3
        mode = 'parallel'; % Default to parallel mode
    end
    
    switch lower(mode)
        case 'parallel'
            successful_trials = runParallelSimulations(handles, config);
        case 'sequential'
            successful_trials = runSequentialSimulations(handles, config);
        otherwise
            error('Invalid mode: %s. Use ''parallel'' or ''sequential''', mode);
    end
end

function successful_trials = runParallelSimulations(handles, config)
    % RUNPARALLELSIMULATIONS - Execute simulations using parallel processing
    %
    % This function manages parallel simulation execution using MATLAB's Parallel
    % Computing Toolbox with robust error handling, progress tracking, and
    % checkpoint capabilities.
    %
    % Inputs:
    %   handles - GUI handles structure for progress updates
    %   config - Configuration structure with simulation parameters
    %
    % Outputs:
    %   successful_trials - Number of successfully completed trials
    
    % Initialize parallel pool with better error handling
    try
        % First, check if there's an existing pool and clean it up if needed
        existing_pool = gcp('nocreate');
        if ~isempty(existing_pool)
            try
                % Check if the existing pool is healthy
                pool_info = existing_pool;
                fprintf('Found existing parallel pool with %d workers\n', pool_info.NumWorkers);

                % Test if the pool is responsive
                try
                    spmd
                        test_var = 1;
                    end
                    fprintf('Existing pool is healthy, using it\n');
                catch
                    fprintf('Existing pool appears unresponsive, deleting it\n');
                    delete(existing_pool);
                    existing_pool = [];
                end
            catch
                fprintf('Error checking existing pool, deleting it\n');
                delete(existing_pool);
                existing_pool = [];
            end
        end

        % Create new pool if needed
        if isempty(existing_pool)
            % Get cluster profile and worker count from user preferences
            cluster_profile = getFieldOrDefault(handles.preferences, 'cluster_profile', 'Local_Cluster');
            max_workers = getFieldOrDefault(handles.preferences, 'max_parallel_workers', 14);
            
            % Ensure cluster profile exists
            available_profiles = parallel.clusterProfiles();
            if ~ismember(cluster_profile, available_profiles)
                fprintf('Warning: Cluster profile "%s" not found, falling back to Local_Cluster\n', cluster_profile);
                cluster_profile = 'Local_Cluster';
                % Ensure Local_Cluster exists
                if ~ismember(cluster_profile, available_profiles)
                    fprintf('Local_Cluster not found, creating it...\n');
                    try
                        cluster = parallel.cluster.Local;
                        cluster.Profile = 'Local_Cluster';
                        cluster.saveProfile();
                        fprintf('Local_Cluster profile created successfully\n');
                    catch ME
                        fprintf('Failed to create Local_Cluster profile: %s\n', ME.message);
                        cluster_profile = 'local';
                    end
                end
            end
            
            % Get cluster object
            try
                cluster_obj = parcluster(cluster_profile);
                fprintf('Using cluster profile: %s\n', cluster_profile);
                
                % Check if cluster supports the requested number of workers
                if isfield(cluster_obj, 'NumWorkers') && cluster_obj.NumWorkers > 0
                    cluster_max_workers = cluster_obj.NumWorkers;
                    fprintf('Cluster supports max %d workers\n', cluster_max_workers);
                    % Use the minimum of requested and cluster limit
                    num_workers = min(max_workers, cluster_max_workers);
                else
                    num_workers = max_workers;
                end
                
                fprintf('Starting parallel pool with %d workers using %s profile...\n', num_workers, cluster_profile);
                
                % Start parallel pool with specified cluster profile
                parpool(cluster_obj, num_workers);
                fprintf('Successfully started parallel pool with %s profile (%d workers)\n', cluster_profile, num_workers);
                
            catch ME
                fprintf('Failed to use cluster profile %s: %s\n', cluster_profile, ME.message);
                fprintf('Falling back to local profile...\n');
                
                % Fallback to local profile
                temp_cluster = parcluster('local');
                fallback_workers = min(max_workers, temp_cluster.NumWorkers);
                parpool('local', fallback_workers);
                fprintf('Successfully started parallel pool with local profile (%d workers)\n', fallback_workers);
            end
        end
    catch ME
        warning('Failed to start parallel pool: %s. Falling back to sequential execution.', ME.message);
        successful_trials = runSequentialSimulations(handles, config);
        return;
    end

    % Get batch processing parameters
    batch_size = config.batch_size;
    save_interval = config.save_interval;
    total_trials = config.num_simulations;

    % Debug print to confirm settings
    fprintf('[RUNTIME] Using batch size: %d, save interval: %d, verbosity: %s\n', config.batch_size, config.save_interval, config.verbosity);

    if ~strcmp(config.verbosity, 'Silent')
        fprintf('Starting parallel batch processing:\n');
        fprintf('  Total trials: %d\n', total_trials);
        fprintf('  Batch size: %d\n', batch_size);
        fprintf('  Save interval: %d batches\n', save_interval);
    end

    % Calculate number of batches
    num_batches = ceil(total_trials / batch_size);
    successful_trials = 0;

    % Store initial workspace state for restoration
    initial_vars = who;

    % Check for existing checkpoint
    checkpoint_file = fullfile(config.output_folder, 'parallel_checkpoint.mat');
    start_batch = 1;
    if exist(checkpoint_file, 'file') && get(handles.enable_checkpoint_resume, 'Value')
        try
            checkpoint_data = load(checkpoint_file);
            if isfield(checkpoint_data, 'completed_trials')
                successful_trials = checkpoint_data.completed_trials;
                start_batch = checkpoint_data.next_batch;
                fprintf('Found checkpoint: %d trials completed, resuming from batch %d\n', successful_trials, start_batch);
            end
        catch ME
            fprintf('Warning: Could not load checkpoint: %s\n', ME.message);
        end
    elseif exist(checkpoint_file, 'file') && ~get(handles.enable_checkpoint_resume, 'Value')
        fprintf('Checkpoint found but resume disabled - starting fresh\n');
    end

    % Ensure model is available on all parallel workers
    try
        fprintf('Loading model on parallel workers...\n');
        spmd
            if ~bdIsLoaded(config.model_name)
                load_system(config.model_path);
            end
        end
        fprintf('Model loaded on all workers\n');
    catch ME
        fprintf('Warning: Could not preload model on workers: %s\n', ME.message);
    end

    % Process batches
    for batch_idx = start_batch:num_batches
        % Check for stop request
        if checkStopRequest(handles)
            fprintf('Parallel simulation stopped by user at batch %d\n', batch_idx);
            break;
        end

        % Calculate trials for this batch
        start_trial = (batch_idx - 1) * batch_size + 1;
        end_trial = min(batch_idx * batch_size, total_trials);
        batch_trials = end_trial - start_trial + 1;

        if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
            fprintf('\n--- Batch %d/%d (Trials %d-%d) ---\n', batch_idx, num_batches, start_trial, end_trial);
        end

        % Update progress
        progress_msg = sprintf('Batch %d/%d: Processing trials %d-%d...', batch_idx, num_batches, start_trial, end_trial);
        set(handles.progress_text, 'String', progress_msg);
        drawnow;

        % Prepare simulation inputs for this batch
        try
            batch_simInputs = prepareSimulationInputsForBatch(config, start_trial, end_trial);

            if isempty(batch_simInputs)
                fprintf('Failed to prepare simulation inputs for batch %d\n', batch_idx);
                continue;
            end

            if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                fprintf('Prepared %d simulation inputs for batch %d\n', length(batch_simInputs), batch_idx);
            end

        catch ME
            fprintf('Error preparing batch %d inputs: %s\n', batch_idx, ME.message);
            continue;
        end

        % Run batch simulations
        try
            if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                fprintf('Running batch %d with parsim...\n', batch_idx);
            end

            % Use parsim for parallel simulation with robust error handling
            % Attach all external functions needed by parallel workers
            attached_files = {
                config.model_path, ...
                'runSingleTrial.m', ...
                'processSimulationOutput.m', ...
                'setModelParameters.m', ...
                'setPolynomialCoefficients.m', ...
                'extractSignalsFromSimOut.m', ...
                'extractFromCombinedSignalBus.m', ...
                'extractFromNestedStruct.m', ...
                'extractLogsoutDataFixed.m', ...
                'extractSimscapeDataRecursive.m', ...
                'traverseSimlogNode.m', ...
                'extractDataFromField.m', ...
                'combineDataSources.m', ...
                'addModelWorkspaceData.m', ...
                'extractWorkspaceOutputs.m', ...
                'resampleDataToFrequency.m', ...
                'getPolynomialParameterInfo.m', ...
                'getShortenedJointName.m', ...
                'generateRandomCoefficients.m', ...
                'prepareSimulationInputsForBatch.m', ...
                'restoreWorkspace.m', ...
                'getMemoryInfo.m', ...
                'checkHighMemoryUsage.m', ...
                'loadInputFile.m', ...
                'checkStopRequest.m', ...
                'extractCoefficientsFromTable.m', ...
                'shouldShowDebug.m', ...
                'shouldShowVerbose.m', ...
                'shouldShowNormal.m', ...
                'mergeTables.m', ...
                'logical2str.m', ...
                'fallbackSimlogExtraction.m', ...
                'extractTimeSeriesData.m', ...
                'extractConstantMatrixData.m'
            };

            batch_simOuts = parsim(batch_simInputs, ...
                                'TransferBaseWorkspaceVariables', 'on', ...
                                'AttachedFiles', attached_files, ...
                                'StopOnError', 'off');  % Don't stop on individual simulation errors

            % Check if parsim succeeded
            if isempty(batch_simOuts)
                fprintf('Batch %d failed - no results returned\n', batch_idx);
                continue;
            end

            % Process batch results
            batch_successful = 0;
            for i = 1:length(batch_simOuts)
                trial_num = start_trial + i - 1;

                try
                    current_simOut = batch_simOuts(i);

                    % Check if we got a valid single simulation output object
                    if isempty(current_simOut)
                        fprintf('Trial %d: Empty simulation output\n', trial_num);
                        continue;
                    end

                    % Process the simulation output
                    result = processSimulationOutput(trial_num, config, current_simOut, config.capture_workspace);

                    if result.success
                        batch_successful = batch_successful + 1;
                        successful_trials = successful_trials + 1;

                        if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                            fprintf('Trial %d: Success\n', trial_num);
                        end
                    else
                        if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                            fprintf('Trial %d: Failed - %s\n', trial_num, result.error_message);
                        end
                    end

                catch ME
                    fprintf('Error processing trial %d: %s\n', trial_num, ME.message);
                end
            end

            % Update progress for this batch
            if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                fprintf('Batch %d: %d/%d trials successful\n', batch_idx, batch_successful, batch_trials);
            end

            % Update overall progress
            progress_ratio = (batch_idx) / num_batches;
            updateProgressBar(handles, progress_ratio);
            progress_msg = sprintf('Completed batch %d/%d (%d total successful trials)', batch_idx, num_batches, successful_trials);
            set(handles.progress_text, 'String', progress_msg);
            drawnow;

        catch ME
            fprintf('Error running batch %d: %s\n', batch_idx, ME.message);
            continue;
        end

        % Save checkpoint if needed
        if mod(batch_idx, save_interval) == 0 || batch_idx == num_batches
            try
                checkpoint_data = struct();
                checkpoint_data.completed_trials = successful_trials;
                checkpoint_data.next_batch = batch_idx + 1;
                checkpoint_data.timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
                save(checkpoint_file, 'checkpoint_data');
                fprintf('Checkpoint saved: %d trials completed\n', successful_trials);
            catch ME
                fprintf('Warning: Could not save checkpoint: %s\n', ME.message);
            end
        end

        % Check memory usage and warn if high
        if checkHighMemoryUsage(80) % 80% threshold
            fprintf('Warning: High memory usage detected. Consider reducing batch size.\n');
        end
    end

    % Restore workspace
    restoreWorkspace(initial_vars);

    % Final summary
    if ~strcmp(config.verbosity, 'Silent')
        fprintf('\n=== PARALLEL BATCH PROCESSING SUMMARY ===\n');
        fprintf('Total trials requested: %d\n', total_trials);
        fprintf('Successful trials: %d\n', successful_trials);
        fprintf('Success rate: %.1f%%\n', (successful_trials / total_trials) * 100);
        fprintf('Batches processed: %d\n', batch_idx);
        
        if successful_trials == 0
            fprintf('\nAll parallel simulations failed. Common causes:\n');
            fprintf('   • Model configuration issues\n');
            fprintf('   • Insufficient memory for parallel workers\n');
            fprintf('   • Model configuration conflicts in parallel mode\n');
            fprintf('   • Missing dependencies on parallel workers\n');
        end
    end
end

function successful_trials = runSequentialSimulations(handles, config)
    % RUNSEQUENTIALSIMULATIONS - Execute simulations sequentially
    %
    % This function runs simulations sequentially with progress tracking and
    % error handling. Used as fallback when parallel processing is not available.
    %
    % Inputs:
    %   handles - GUI handles structure for progress updates
    %   config - Configuration structure with simulation parameters
    %
    % Outputs:
    %   successful_trials - Number of successfully completed trials
    
    fprintf('Running simulations sequentially...\n');
    
    total_trials = config.num_simulations;
    successful_trials = 0;
    
    % Store initial workspace state
    initial_vars = who;
    
    % Process trials sequentially
    for trial_num = 1:total_trials
        % Check for stop request
        if checkStopRequest(handles)
            fprintf('Sequential simulation stopped by user at trial %d\n', trial_num);
            break;
        end
        
        % Update progress
        progress_ratio = trial_num / total_trials;
        updateProgressBar(handles, progress_ratio);
        progress_msg = sprintf('Trial %d/%d: Processing...', trial_num, total_trials);
        set(handles.progress_text, 'String', progress_msg);
        drawnow;
        
        try
            % Generate coefficients for this trial
            coefficients = generateRandomCoefficients(config.num_coefficients);
            
            % Run single trial
            result = runSingleTrial(trial_num, config, coefficients, config.capture_workspace);
            
            if result.success
                successful_trials = successful_trials + 1;
                
                if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                    fprintf('Trial %d: Success\n', trial_num);
                end
            else
                if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
                    fprintf('Trial %d: Failed - %s\n', trial_num, result.error_message);
                end
            end
            
        catch ME
            fprintf('Error in trial %d: %s\n', trial_num, ME.message);
        end
        
        % Check memory usage
        if checkHighMemoryUsage(80)
            fprintf('Warning: High memory usage detected.\n');
        end
    end
    
    % Restore workspace
    restoreWorkspace(initial_vars);
    
    % Final summary
    if ~strcmp(config.verbosity, 'Silent')
        fprintf('\n=== SEQUENTIAL PROCESSING SUMMARY ===\n');
        fprintf('Total trials: %d\n', total_trials);
        fprintf('Successful trials: %d\n', successful_trials);
        fprintf('Success rate: %.1f%%\n', (successful_trials / total_trials) * 100);
    end
end

function value = getFieldOrDefault(struct_obj, field_name, default_value)
    % GETFIELDORDEFAULT - Get field value or return default if field doesn't exist
    %
    % Inputs:
    %   struct_obj - Structure to check
    %   field_name - Name of field to retrieve
    %   default_value - Default value if field doesn't exist
    %
    % Outputs:
    %   value - Field value or default value
    
    if isfield(struct_obj, field_name)
        value = struct_obj.(field_name);
    else
        value = default_value;
    end
end
