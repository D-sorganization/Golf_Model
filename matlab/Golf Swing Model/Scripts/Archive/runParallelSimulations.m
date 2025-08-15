% runParallelSimulations.m
% Run multiple golf swing simulations in parallel and save individual trial files
% Each trial is saved as a separate .mat file for easy expansion and compilation

fprintf('=== Parallel Golf Swing Simulations ===\n\n');

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

%% Check for parallel computing availability
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
catch ME
    fprintf('⚠️  Parallel computing not available: %s\n', ME.message);
    fprintf('  Falling back to sequential execution\n');
    use_parallel = false;
end

%% Run simulations
fprintf('\n--- Running Simulations ---\n');

if use_parallel
    % Parallel execution
    fprintf('Running simulations in parallel...\n');

    % Create array to store results
    trial_results = cell(config.num_simulations, 1);

    % Run simulations in parallel
    parfor sim_idx = 1:config.num_simulations
        try
            fprintf('Worker: Starting simulation %d/%d\n', sim_idx, config.num_simulations);
            trial_results{sim_idx} = runSingleTrial(sim_idx, config);
            fprintf('Worker: Completed simulation %d/%d\n', sim_idx, config.num_simulations);
        catch ME
            fprintf('Worker: Simulation %d failed: %s\n', sim_idx, ME.message);
            trial_results{sim_idx} = [];
        end
    end

    % Process results
    successful_trials = 0;
    for sim_idx = 1:config.num_simulations
        if ~isempty(trial_results{sim_idx})
            successful_trials = successful_trials + 1;
            fprintf('✓ Trial %d completed successfully\n', sim_idx);
        else
            fprintf('✗ Trial %d failed\n', sim_idx);
        end
    end

else
    % Sequential execution
    fprintf('Running simulations sequentially...\n');

    successful_trials = 0;
    for sim_idx = 1:config.num_simulations
        try
            fprintf('Running simulation %d/%d...\n', sim_idx, config.num_simulations);
            result = runSingleTrial(sim_idx, config);
            if ~isempty(result)
                successful_trials = successful_trials + 1;
                fprintf('✓ Trial %d completed successfully\n', sim_idx);
            else
                fprintf('✗ Trial %d failed\n', sim_idx);
            end
        catch ME
            fprintf('✗ Simulation %d failed: %s\n', sim_idx, ME.message);
        end
    end
end

%% Summary
fprintf('\n--- Summary ---\n');
fprintf('Total trials attempted: %d\n', config.num_simulations);
fprintf('Successful trials: %d\n', successful_trials);
fprintf('Failed trials: %d\n', config.num_simulations - successful_trials);
fprintf('Success rate: %.1f%%\n', (successful_trials / config.num_simulations) * 100);

if successful_trials > 0
    fprintf('\n✓ Individual trial files saved to: %s/\n', config.output_folder);
    fprintf('  Use compileTrialDataset.m to combine all trials into a single dataset\n');
else
    fprintf('\n✗ No successful trials completed\n');
end

fprintf('\n=== Parallel Simulations Complete ===\n');

%% Helper Functions

function result = runSingleTrial(sim_idx, config)
    % Run a single trial and save the result

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

        % Run simulation
        simOut = sim(simInput);

        % Extract all data from this simulation
        trial_data = extractTrialData(simOut, sim_idx, config);

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

function trial_data = extractTrialData(simOut, sim_idx, config)
    % Extract all available data from simulation output for a single trial

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

        % Extract logsout data
        trial_data = extractLogsoutData(simOut, trial_data, target_time);

        % Extract signal bus data
        trial_data = extractSignalBusData(simOut, trial_data, target_time);

        % Extract Simscape data
        trial_data = extractSimscapeData(simOut, trial_data, target_time);

        % Extract model workspace variables
        trial_data = extractModelWorkspaceData(simOut, trial_data, target_time);

        % Extract inertia matrices and rotation matrices
        trial_data = extractMatrixData(simOut, trial_data, target_time);

    catch ME
        fprintf('    Error extracting trial data: %s\n', ME.message);
        trial_data = [];
    end
end

function trial_data = extractLogsoutData(simOut, trial_data, target_time)
    % Extract data from logsout

    try
        logsout = simOut.logsout;
        if isempty(logsout)
            return;
        end

        for i = 1:logsout.numElements
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

            catch ME
                % Continue to next signal
            end
        end

    catch ME
        % Continue without logsout data
    end
end

function trial_data = extractSignalBusData(simOut, trial_data, target_time)
    % Extract data from signal bus structs

    try
        % Define expected signal bus structs
        expected_structs = {
            'HipLogs', 'SpineLogs', 'TorsoLogs', ...
            'LSLogs', 'RSLogs', 'LELogs', 'RELogs', ...
            'LWLogs', 'RWLogs', 'LScapLogs', 'RScapLogs', ...
            'LFLogs', 'RFLogs'
        };

        for i = 1:length(expected_structs)
            struct_name = expected_structs{i};

            try
                if ~isempty(simOut.(struct_name))
                    log_struct = simOut.(struct_name);

                    if isstruct(log_struct)
                        fields = fieldnames(log_struct);

                        for j = 1:length(fields)
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

function trial_data = extractSimscapeData(simOut, trial_data, target_time)
    % Extract data from Simscape Results Explorer

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
            for i = 1:length(child_nodes)
                child_node = child_nodes(i);
                node_name = child_node.Name;

                % Look for joint-related nodes
                if contains(lower(node_name), {'joint', 'actuator', 'motor', 'drive'})
                    try
                        signals = child_node.Children;

                        for j = 1:length(signals)
                            signal = signals(j);
                            signal_name = signal.Name;

                            if hasData(signal)
                                [data, time] = getData(signal);
                                resampled_data = resampleSignal(data, time, target_time);
                                trial_data = [trial_data, resampled_data];
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

function trial_data = extractModelWorkspaceData(simOut, trial_data, target_time)
    % Extract model workspace variables (constant values)

    try
        % Get model workspace variables
        model_workspace = get_param(simOut.SimulationMetadata.ModelInfo.ModelName, 'ModelWorkspace');
        variables = model_workspace.getVariableNames;

        for i = 1:length(variables)
            var_name = variables{i};

            try
                var_value = model_workspace.getVariable(var_name);

                % Only include numeric variables
                if isnumeric(var_value)
                    % Create constant column for all time points
                    constant_data = repmat(var_value, length(target_time), 1);
                    trial_data = [trial_data, constant_data];
                end

            catch ME
                % Continue to next variable
            end
        end

    catch ME
        % Continue without model workspace data
    end
end

function trial_data = extractMatrixData(simOut, trial_data, target_time)
    % Extract inertia matrices and rotation matrices

    try
        % Look for rotation matrices in signal buses
        rotation_fields = {'Rotation_Transform'};

        for i = 1:length(rotation_fields)
            field_name = rotation_fields{i};

            % Check in each signal bus struct
            expected_structs = {'HipLogs', 'SpineLogs', 'TorsoLogs', 'LSLogs', 'RSLogs', 'LELogs', 'RELogs', 'LWLogs', 'RWLogs', 'LScapLogs', 'RScapLogs', 'LFLogs', 'RFLogs'};

            for j = 1:length(expected_structs)
                struct_name = expected_structs{j};

                try
                    if ~isempty(simOut.(struct_name)) && isfield(simOut.(struct_name), field_name)
                        matrix_data = simOut.(struct_name).(field_name);

                        if isnumeric(matrix_data)
                            % Flatten 3x3xN matrix to Nx9
                            if ndims(matrix_data) == 3
                                [~, ~, n_frames] = size(matrix_data);
                                flattened = reshape(matrix_data, [], n_frames)';
                                resampled_data = resampleSignal(flattened, 1:n_frames, target_time);
                                trial_data = [trial_data, resampled_data];
                            end
                        end
                    end
                catch ME
                    % Continue to next struct
                end
            end
        end

    catch ME
        % Continue without matrix data
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
