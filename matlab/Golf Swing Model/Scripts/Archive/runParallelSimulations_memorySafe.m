% runParallelSimulations_memorySafe.m
% Memory-safe version of parallel golf swing simulations
% Includes proper cleanup, memory management, and crash prevention

fprintf('=== Memory-Safe Parallel Golf Swing Simulations ===\n\n');

%% Get User Configuration
fprintf('=== Golf Swing Simulation Configuration ===\n\n');

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

% Prompt for batch size (memory management)
while true
    batch_size_str = input('Enter batch size for memory cleanup (default: 50): ', 's');
    if isempty(batch_size_str)
        config.batch_size = 50;
        break;
    else
        config.batch_size = str2double(batch_size_str);
        if ~isnan(config.batch_size) && config.batch_size > 0 && config.batch_size <= config.num_simulations
            break;
        else
            fprintf('Please enter a valid positive integer <= %d.\n', config.num_simulations);
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
    folder_name = input('Enter folder name for trial data (default: trial_data): ', 's');
    if isempty(folder_name)
        folder_name = 'trial_data';
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

% Set other configuration parameters
config.sample_rate = 100;      % 100 Hz sampling (fixed)
config.model_name = 'GolfSwing3D_Kinetic';  % Model name (fixed)

fprintf('\n=== Configuration Summary ===\n');
fprintf('  Number of trials: %d\n', config.num_simulations);
fprintf('  Simulation duration: %.1f seconds\n', config.simulation_time);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Batch size: %d (memory cleanup interval)\n', config.batch_size);
fprintf('  Output folder: %s\n', config.output_folder);
fprintf('  Model: %s\n', config.model_name);
fprintf('\n');

% Confirm with user
confirm = input('Start simulations with these settings? (y/n): ', 's');
if ~(strcmpi(confirm, 'y') || strcmpi(confirm, 'yes'))
    fprintf('Simulation cancelled by user.\n');
    return;
end

fprintf('\n');

%% Memory Management Setup
% Save initial workspace state
initial_vars = who;
initial_vars = setdiff(initial_vars, {'initial_vars', 'config'});

% Function to restore workspace
function restoreWorkspace(initial_vars)
    current_vars = who;
    vars_to_clear = setdiff(current_vars, [initial_vars, {'initial_vars', 'config'}]);
    if ~isempty(vars_to_clear)
        clear(vars_to_clear{:});
    end
end

%% Check for parallel computing availability
try
    % Try to start parallel pool with limited workers for memory safety
    pool = gcp('nocreate');
    if isempty(pool)
        fprintf('Starting parallel pool with limited workers...\n');
        % Use fewer workers to reduce memory pressure
        num_workers = min(4, feature('numcores'));
        parpool('local', num_workers);
        fprintf('✓ Parallel pool started with %d workers\n', num_workers);
    else
        fprintf('✓ Using existing parallel pool with %d workers\n', pool.NumWorkers);
    end
    use_parallel = true;
catch ME
    fprintf('⚠️  Parallel computing not available: %s\n', ME.message);
    fprintf('  Falling back to sequential execution\n');
    use_parallel = false;
end

%% Run simulations in batches
fprintf('\n--- Running Simulations (Memory-Safe Mode) ---\n');

successful_trials = 0;
failed_trials = 0;

% Calculate number of batches
num_batches = ceil(config.num_simulations / config.batch_size);

for batch_idx = 1:num_batches
    fprintf('\n--- Batch %d/%d ---\n', batch_idx, num_batches);

    % Calculate batch range
    start_idx = (batch_idx - 1) * config.batch_size + 1;
    end_idx = min(batch_idx * config.batch_size, config.num_simulations);
    batch_size_actual = end_idx - start_idx + 1;

    fprintf('Processing trials %d-%d (%d trials)\n', start_idx, end_idx, batch_size_actual);

    % Run batch
    if use_parallel
        % Parallel execution for this batch
        batch_results = cell(batch_size_actual, 1);

        parfor i = 1:batch_size_actual
            sim_idx = start_idx + i - 1;
            try
                fprintf('Worker: Starting simulation %d/%d\n', sim_idx, config.num_simulations);
                batch_results{i} = runSingleTrialMemorySafe(sim_idx, config);
                fprintf('Worker: Completed simulation %d/%d\n', sim_idx, config.num_simulations);
            catch ME
                fprintf('Worker: Simulation %d failed: %s\n', sim_idx, ME.message);
                batch_results{i} = [];
            end
        end

        % Process batch results
        for i = 1:batch_size_actual
            if ~isempty(batch_results{i})
                successful_trials = successful_trials + 1;
                fprintf('✓ Trial %d completed successfully\n', start_idx + i - 1);
            else
                failed_trials = failed_trials + 1;
                fprintf('✗ Trial %d failed\n', start_idx + i - 1);
            end
        end

    else
        % Sequential execution for this batch
        for i = 1:batch_size_actual
            sim_idx = start_idx + i - 1;
            try
                fprintf('Running simulation %d/%d...\n', sim_idx, config.num_simulations);
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
    end

    % Memory cleanup after each batch
    fprintf('Performing memory cleanup...\n');
    restoreWorkspace(initial_vars);

    % Force garbage collection
    if exist('OCTAVE_VERSION', 'builtin')
        % Octave
        clear -f;
    else
        % MATLAB
        clear('ans');
        if exist('java.lang.System', 'class')
            java.lang.System.gc();
        end
    end

    % Check available memory
    if exist('memory', 'builtin')
        try
            mem_info = memory;
            fprintf('Memory usage: %.1f MB used, %.1f MB available\n', ...
                mem_info.MemUsedMATLAB/1024/1024, mem_info.MemAvailable/1024/1024);
        catch
            fprintf('Memory cleanup completed\n');
        end
    else
        fprintf('Memory cleanup completed\n');
    end

    % Progress update
    fprintf('Progress: %d/%d trials completed (%.1f%%)\n', ...
        successful_trials + failed_trials, config.num_simulations, ...
        (successful_trials + failed_trials) / config.num_simulations * 100);
end

%% Summary
fprintf('\n--- Summary ---\n');
fprintf('Total trials attempted: %d\n', config.num_simulations);
fprintf('Successful trials: %d\n', successful_trials);
fprintf('Failed trials: %d\n', failed_trials);
fprintf('Success rate: %.1f%%\n', (successful_trials / config.num_simulations) * 100);

if successful_trials > 0
    fprintf('\n✓ Individual trial files saved to: %s/\n', config.output_folder);
    fprintf('  Use compileTrialDataset.m to combine all trials into a single dataset\n');
else
    fprintf('\n✗ No successful trials completed\n');
end

% Final cleanup
restoreWorkspace(initial_vars);
fprintf('\n=== Memory-Safe Parallel Simulations Complete ===\n');

%% Helper Functions

function result = runSingleTrialMemorySafe(sim_idx, config)
    % Memory-safe version of single trial execution

    try
        % Generate unique polynomial coefficients for this trial
        polynomial_coeffs = generateRandomPolynomialCoefficients();

        % Create simulation input
        simInput = Simulink.SimulationInput(config.model_name);

        % Set simulation time
        simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));

        % Set polynomial coefficients as variables
        simInput = setPolynomialVariables(simInput, polynomial_coeffs);

        % Configure logging with minimal memory usage
        simInput = simInput.setModelParameter('SignalLogging', 'on');
        simInput = simInput.setModelParameter('SignalLoggingName', 'out');
        simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
        simInput = simInput.setModelParameter('SimscapeLogType', 'all');

        % Run simulation
        simOut = sim(simInput);

        % Extract data with memory management
        trial_data = extractTrialDataMemorySafe(simOut, sim_idx, config);

        if ~isempty(trial_data)
            % Save individual trial file
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            filename = sprintf('trial_%03d_%s.mat', sim_idx, timestamp);
            filepath = fullfile(config.output_folder, filename);

            % Save trial data
            save(filepath, 'trial_data', 'polynomial_coeffs', 'sim_idx', 'config');

            result = struct();
            result.success = true;
            result.filename = filename;
            result.data_points = size(trial_data, 1);
            result.columns = size(trial_data, 2);

            % Clear large variables immediately
            clear('trial_data', 'simOut');
        else
            result = [];
        end

    catch ME
        fprintf('  Trial %d error: %s\n', sim_idx, ME.message);
        result = [];
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

function trial_data = extractTrialDataMemorySafe(simOut, sim_idx, config)
    % Memory-safe data extraction with limited scope

    try
        % Get time vector and resample to 100 Hz
        time_vector = simOut.tout;
        if isempty(time_vector)
            trial_data = [];
            return;
        end

        % Resample to 100 Hz
        target_time = 0:1/config.sample_rate:config.simulation_time;
        target_time = target_time(target_time <= config.simulation_time);

        % Initialize data matrix
        num_time_points = length(target_time);
        trial_data = zeros(num_time_points, 0); % Will grow as we add columns

        % Add time and simulation ID
        trial_data = [trial_data, target_time', repmat(sim_idx, num_time_points, 1)];

        % Extract data in smaller chunks to manage memory
        trial_data = extractLogsoutDataMemorySafe(simOut, trial_data, target_time);
        trial_data = extractSignalBusDataMemorySafe(simOut, trial_data, target_time);
        trial_data = extractSimscapeDataMemorySafe(simOut, trial_data, target_time);

        % Skip heavy data extraction to save memory
        % trial_data = extractModelWorkspaceData(simOut, trial_data, target_time);
        % trial_data = extractMatrixData(simOut, trial_data, target_time);

    catch ME
        fprintf('    Error extracting trial data: %s\n', ME.message);
        trial_data = [];
    end
end

function trial_data = extractLogsoutDataMemorySafe(simOut, trial_data, target_time)
    % Memory-safe logsout data extraction

    try
        logsout = simOut.logsout;
        if isempty(logsout)
            return;
        end

        % Limit number of signals to prevent memory issues
        max_signals = 50;
        num_signals = min(logsout.numElements, max_signals);

        for i = 1:num_signals
            try
                element = logsout.getElement(i);
                signal_name = element.Name;

                % Get signal data
                if isa(element, 'Simulink.SimulationData.Signal')
                    data = element.Values.Data;
                    time = element.Values.Time;
                else
                    try
                        [data, time] = element.getData;
                    catch
                        continue;
                    end
                end

                % Resample to target time
                resampled_data = resampleSignal(data, time, target_time);

                % Add to dataset
                trial_data = [trial_data, resampled_data];

                % Clear temporary variables
                clear('data', 'time', 'resampled_data');

            catch ME
                % Continue to next signal
            end
        end

    catch ME
        % Continue without logsout data
    end
end

function trial_data = extractSignalBusDataMemorySafe(simOut, trial_data, target_time)
    % Memory-safe signal bus data extraction

    try
        % Define expected signal bus structs (limited set)
        expected_structs = {
            'HipLogs', 'SpineLogs', 'TorsoLogs', ...
            'LSLogs', 'RSLogs', 'LELogs', 'RELogs'
        };

        for i = 1:length(expected_structs)
            struct_name = expected_structs{i};

            try
                if ~isempty(simOut.(struct_name))
                    log_struct = simOut.(struct_name);

                    if isstruct(log_struct)
                        fields = fieldnames(log_struct);

                        % Limit number of fields to prevent memory issues
                        max_fields = 20;
                        num_fields = min(length(fields), max_fields);

                        for j = 1:num_fields
                            field_name = fields{j};
                            field_data = log_struct.(field_name);

                            % Extract data from field
                            if isa(field_data, 'timeseries')
                                data = field_data.Data;
                                time = field_data.Time;
                            elseif isstruct(field_data) && isfield(field_data, 'Data') && isfield(field_data, 'Time')
                                data = field_data.Data;
                                time = field_data.Time;
                            elseif isnumeric(field_data)
                                data = field_data;
                                time = [];
                            else
                                continue;
                            end

                            % Resample to target time
                            if ~isempty(time)
                                resampled_data = resampleSignal(data, time, target_time);
                                trial_data = [trial_data, resampled_data];

                                % Clear temporary variables
                                clear('data', 'time', 'resampled_data');
                            end
                        end
                    end
                end

            catch ME
                % Continue to next struct
            end
        end

    catch ME
        % Continue without signal bus data
    end
end

function trial_data = extractSimscapeDataMemorySafe(simOut, trial_data, target_time)
    % Memory-safe Simscape data extraction

    try
        simlog = simOut.simlog;
        if isempty(simlog) || ~isa(simlog, 'simscape.logging.Node')
            return;
        end

        % Try to access child nodes
        try
            child_nodes = simlog.Children;
        catch
            try
                child_nodes = simlog.children;
            catch
                try
                    child_nodes = simlog.Nodes;
                catch
                    return;
                end
            end
        end

        if ~isempty(child_nodes)
            % Limit number of nodes to prevent memory issues
            max_nodes = 10;
            num_nodes = min(length(child_nodes), max_nodes);

            for i = 1:num_nodes
                child_node = child_nodes(i);
                node_name = child_node.Name;

                % Look for joint-related nodes
                if contains(lower(node_name), {'joint', 'actuator', 'motor', 'drive'})
                    try
                        signals = child_node.Children;

                        % Limit number of signals
                        max_signals = 10;
                        num_signals = min(length(signals), max_signals);

                        for j = 1:num_signals
                            signal = signals(j);
                            signal_name = signal.Name;

                            if hasData(signal)
                                [data, time] = getData(signal);
                                resampled_data = resampleSignal(data, time, target_time);
                                trial_data = [trial_data, resampled_data];

                                % Clear temporary variables
                                clear('data', 'time', 'resampled_data');
                            end
                        end

                    catch ME
                        % Continue to next node
                    end
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

function has_data = hasData(signal)
    % Check if signal has data
    try
        has_data = ~isempty(signal) && signal.hasData;
    catch
        has_data = false;
    end
end

function [data, time] = getData(signal)
    % Get data from signal
    try
        [data, time] = signal.getData;
    catch
        data = [];
        time = [];
    end
end
