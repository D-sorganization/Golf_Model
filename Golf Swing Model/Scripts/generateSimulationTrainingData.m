% generateSimulationTrainingData.m
% Comprehensive golf swing simulation training data generator
% Generates individual CSV files for each trial with complete data tables
% No truncated bullshit - full comprehensive datasets

fprintf('=== Golf Swing Training Data Generator (CSV Version) ===\n\n');

%% Workspace Cleanup Setup
% Save current workspace state to restore later
initial_vars = who;
initial_vars = setdiff(initial_vars, {'initial_vars'}); % Don't save this variable

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
    return;
end

fprintf('\n');

%% Create performance log file
config.performance_log = fullfile(config.output_folder, 'performance_log.txt');
fid = fopen(config.performance_log, 'w');
if fid ~= -1
    fprintf(fid, 'Golf Swing Training Data Generation - Performance Log\n');
    fprintf(fid, '==================================================\n\n');
    fprintf(fid, 'Started: %s\n', datestr(now));
    fprintf(fid, 'Configuration:\n');
    fprintf(fid, '  Number of trials: %d\n', config.num_simulations);
    fprintf(fid, '  Simulation duration: %.1f seconds\n', config.simulation_time);
    fprintf(fid, '  Sample rate: %d Hz\n', config.sample_rate);
    fprintf(fid, '  Output folder: %s\n', config.output_folder);
    fprintf(fid, '\nTrial Results:\n');
    fclose(fid);
end

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
            [trial_results{sim_idx}, signal_names] = runSingleTrialWithCSV(sim_idx, config);
            trial_time = toc(trial_start_time);
            
            % Store trial time (will be collected after parfor)
            trial_results{sim_idx}.trial_time = trial_time;
            
            fprintf('Worker: Trial %d completed in %.2f seconds\n', sim_idx, trial_time);
            
        catch ME
            fprintf('Worker: Simulation %d failed: %s\n', sim_idx, ME.message);
            trial_results{sim_idx} = [];
        end
    end
    
    % Process results and collect metrics
    for sim_idx = 1:config.num_simulations
        if ~isempty(trial_results{sim_idx}) && isfield(trial_results{sim_idx}, 'success') && trial_results{sim_idx}.success
            performance_metrics.successful_trials = performance_metrics.successful_trials + 1;
            performance_metrics.trial_times = [performance_metrics.trial_times, trial_results{sim_idx}.trial_time];
            performance_metrics.total_data_points = performance_metrics.total_data_points + trial_results{sim_idx}.data_points;
            performance_metrics.total_columns = trial_results{sim_idx}.columns;
            
            fprintf('✓ Trial %d completed successfully (%.2f seconds)\n', sim_idx, trial_results{sim_idx}.trial_time);
            fprintf('  CSV file: %s\n', trial_results{sim_idx}.filename);
            fprintf('  Data points: %d, Columns: %d\n', trial_results{sim_idx}.data_points, trial_results{sim_idx}.columns);
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
            
            % Update performance log
            updatePerformanceLog(config.performance_log, sim_idx, trial_time, result.data_points, result.columns, 'success');
            
        else
            performance_metrics.failed_trials = performance_metrics.failed_trials + 1;
            fprintf('✗ Trial %d failed\n', sim_idx);
            updatePerformanceLog(config.performance_log, sim_idx, trial_time, 0, 0, 'failed');
        end
        
    catch ME
        performance_metrics.failed_trials = performance_metrics.failed_trials + 1;
        fprintf('✗ Simulation %d failed: %s\n', sim_idx, ME.message);
        updatePerformanceLog(config.performance_log, sim_idx, trial_time, 0, 0, 'error');
    end
end

%% Calculate Final Performance Metrics
performance_metrics.total_time = toc(performance_metrics.start_time);
performance_metrics.success_rate = (performance_metrics.successful_trials / config.num_simulations) * 100;

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
fprintf('  Performance log: performance_log.txt\n');
fprintf('  Performance summary: performance_summary.txt\n');

%% Save Performance Summary
savePerformanceSummary(config, performance_metrics);

fprintf('\n=== Generation Complete ===\n');
fprintf('All CSV files have been created in: %s\n', config.output_folder);
fprintf('Each CSV file contains a complete data table with all simulation data.\n');

%% Clean up workspace
fprintf('\n=== Cleaning up workspace ===\n');
if evalin('base', 'exist(''initial_vars'', ''var'')')
    % Clean up base workspace, keeping only variables that existed before the script
    evalin('base', ['clearvars -except ', strjoin(initial_vars, ' ')]);
    fprintf('✓ Cleared all temporary variables from base workspace\n');
else
    fprintf('No initial_vars found in base workspace. No cleanup performed.\n');
end
fprintf('✓ Workspace cleanup complete\n');

end

%% Helper Functions

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
        
    catch ME
        fprintf('  Trial %d error: %s\n', sim_idx, ME.message);
        result = [];
        signal_names = {}; % Ensure signal_names is empty on error
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
        trial_data = [trial_data, target_time', repmat(sim_idx, num_time_points, 1)];
        
        % Extract logsout data (same as test script)
        [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time);
        
        % Extract signal log structs (same as test script)
        [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time);
        
        % Extract Simscape Results Explorer data (same as test script)
        [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time);
        
        % Ensure unique column names
        signal_names = makeUniqueColumnNames(signal_names);
        
    catch ME
        fprintf('    Error extracting trial data: %s\n', ME.message);
        trial_data = [];
        signal_names = {};
    end
end

function [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time)
    % Extract data from logsout (same as test script)
    try
        if ~isfield(simOut, 'logsout') || isempty(simOut.logsout)
            return;
        end
        
        logsout = simOut.logsout;
        for i = 1:logsout.numElements
            try
                element = logsout.getElement(i);
                name = matlab.lang.makeValidName(element.Name);
                data = element.Values.Data;
                time = element.Values.Time;
                
                % Resample to target time
                resampled_data = resampleSignal(data, time, target_time);
                trial_data = [trial_data, resampled_data];
                signal_names{end+1} = name;
                
            catch ME
                % Continue to next signal
            end
        end
        
    catch ME
        % Continue without logsout data
    end
end

function [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time)
    % Extract data from signal log structs (same as test script)
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
                        if isnumeric(val) && isvector(val) && length(val) > 1
                            name = sprintf('%s_%s', field, subfield);
                            % Resample to target time
                            resampled_data = resampleSignal(val, 1:length(val), target_time);
                            trial_data = [trial_data, resampled_data];
                            signal_names{end+1} = name;
                        end
                    catch
                        % Continue to next field
                    end
                end
            end
        end
        
        % Also check for other numeric vectors in simOut (same as test script)
        for i = 1:length(fields)
            field = fields{i};
            if ~endsWith(field, 'Logs') && ~strcmp(field, 'logsout') && ~strcmp(field, 'tout')
                try
                    val = simOut.(field);
                    if isnumeric(val) && isvector(val) && length(val) > 1
                        % Resample to target time
                        resampled_data = resampleSignal(val, 1:length(val), target_time);
                        trial_data = [trial_data, resampled_data];
                        signal_names{end+1} = field;
                    end
                catch
                    % Continue to next field
                end
            end
        end
        
    catch ME
        % Continue without signal log data
    end
end

function [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time)
    % Extract data from Simscape Results Explorer (same as test script)
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
                    % Replace problematic characters but keep descriptive names
                    clean_name = strrep(original_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    clean_name = strrep(clean_name, '(', '');
                    clean_name = strrep(clean_name, ')', '');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');
                    
                    % Resample to target time
                    resampled_data = resampleSignal(data, time, target_time);
                    trial_data = [trial_data, resampled_data];
                    signal_names{end+1} = clean_name;
                    
                catch ME
                    % Continue to next signal
                end
            end
        end
        
    catch ME
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

function updatePerformanceLog(log_file, trial_num, trial_time, data_points, columns, status)
    % Update the performance log with trial results
    
    try
        fid = fopen(log_file, 'a');
        if fid ~= -1
            fprintf(fid, '  Trial %d: %s (%.2fs, %d points, %d columns)\n', ...
                trial_num, status, trial_time, data_points, columns);
            fclose(fid);
        end
    catch ME
        % Silently fail if log update fails
    end
end

function savePerformanceSummary(config, performance_metrics)
    % Save a comprehensive performance summary
    
    try
        summary_file = fullfile(config.output_folder, 'performance_summary.txt');
        fid = fopen(summary_file, 'w');
        if fid == -1
            return;
        end
        
        fprintf(fid, 'Golf Swing Training Data Generation - Performance Summary\n');
        fprintf(fid, '==========================================================\n\n');
        fprintf(fid, 'Generated: %s\n', datestr(now));
        fprintf(fid, 'Output folder: %s\n', config.output_folder);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Configuration:\n');
        fprintf(fid, '  Number of trials: %d\n', config.num_simulations);
        fprintf(fid, '  Simulation duration: %.1f seconds\n', config.simulation_time);
        fprintf(fid, '  Sample rate: %d Hz\n', config.sample_rate);
        fprintf(fid, '  Model: %s\n', config.model_name);
        fprintf(fid, '  Output format: CSV files\n');
        fprintf(fid, '\n');
        
        fprintf(fid, 'Results:\n');
        fprintf(fid, '  Successful trials: %d\n', performance_metrics.successful_trials);
        fprintf(fid, '  Failed trials: %d\n', performance_metrics.failed_trials);
        fprintf(fid, '  Success rate: %.1f%%\n', performance_metrics.success_rate);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Performance Metrics:\n');
        fprintf(fid, '  Total execution time: %.2f seconds (%.2f minutes)\n', ...
            performance_metrics.total_time, performance_metrics.total_time/60);
        fprintf(fid, '  Average trial time: %.2f seconds\n', performance_metrics.avg_trial_time);
        fprintf(fid, '  Min trial time: %.2f seconds\n', performance_metrics.min_trial_time);
        fprintf(fid, '  Max trial time: %.2f seconds\n', performance_metrics.max_trial_time);
        fprintf(fid, '  Trial time std dev: %.2f seconds\n', performance_metrics.std_trial_time);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Data Generated:\n');
        fprintf(fid, '  Total data points: %d\n', performance_metrics.total_data_points);
        fprintf(fid, '  Data columns per trial: %d\n', performance_metrics.total_columns);
        if performance_metrics.successful_trials > 0
            fprintf(fid, '  Average data points per trial: %d\n', ...
                performance_metrics.total_data_points / performance_metrics.successful_trials);
        end
        fprintf(fid, '\n');
        
        fprintf(fid, 'Files Created:\n');
        fprintf(fid, '  CSV trial files: %d files\n', performance_metrics.successful_trials);
        fprintf(fid, '  Performance log: performance_log.txt\n');
        fprintf(fid, '  Performance summary: performance_summary.txt\n');
        
        fclose(fid);
        fprintf('✓ Performance summary saved to: %s\n', summary_file);
        
    catch ME
        fprintf('✗ Error saving performance summary: %s\n', ME.message);
    end
end 