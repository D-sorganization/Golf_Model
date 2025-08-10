function [trial_data, signal_names] = extractCompleteTrialData(simOut, sim_idx, config)
    % Standalone function for extracting complete trial data
    % This function can be called from parfor loops

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
        trial_data = zeros(num_time_points, 0);
        signal_names = {'time', 'simulation_id'};

        % Add time and simulation ID
        trial_data = [trial_data, target_time(:)];
        trial_data = [trial_data, repmat(sim_idx, num_time_points, 1)];

        % Extract data based on selected sources
        if config.use_model_workspace
            [trial_data, signal_names] = extractModelWorkspaceData(config.model_name, trial_data, signal_names, num_time_points);
        end

        if config.use_logsout
            [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time);
        end

        if config.use_signal_bus
            [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time);
        end

        if config.use_simscape
            [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time);
        end

        % Filter and clean up
        [trial_data, signal_names] = filterDiscreteVariables(trial_data, signal_names);
        signal_names = makeUniqueColumnNames(signal_names);

        % Final validation
        if size(trial_data, 2) ~= length(signal_names)
            min_length = min(size(trial_data, 2), length(signal_names));
            trial_data = trial_data(:, 1:min_length);
            signal_names = signal_names(1:min_length);
        end

    catch ME
        trial_data = [];
        signal_names = {};
    end
end

% Include helper functions to avoid path issues
function [trial_data, signal_names] = extractModelWorkspaceData(model_name, trial_data, signal_names, num_time_points)
    % Extract segment lengths, inertials, and anthropomorphic parameters from model workspace
    try
        % Validate inputs
        if isempty(num_time_points) || num_time_points <= 0
            return;
        end

        % Get model workspace
        model_workspace = get_param(model_name, 'ModelWorkspace');
        workspace_vars = model_workspace.whos;

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
                            trial_data = [trial_data, data_column];
                            signal_names{end+1} = sprintf('ModelWorkspace_%s', var_name);
                            extracted_count = extracted_count + 1;

                        elseif isvector(var_value)
                            % Vector value - handle as time-invariant parameters
                            for j = 1:length(var_value)
                                data_column = repmat(var_value(j), num_time_points, 1);
                                trial_data = [trial_data, data_column];
                                signal_names{end+1} = sprintf('ModelWorkspace_%s_%d', var_name, j);
                                extracted_count = extracted_count + 1;
                            end

                        elseif ismatrix(var_value) && size(var_value, 1) == 3 && size(var_value, 2) == 3
                            % 3x3 matrix (e.g., inertia tensor) - flatten to 9 components
                            flat_inertia = var_value(:)'; % Flatten to row vector
                            for j = 1:9
                                data_column = repmat(flat_inertia(j), num_time_points, 1);
                                trial_data = [trial_data, data_column];
                                signal_names{end+1} = sprintf('ModelWorkspace_%s_%d', var_name, j);
                                extracted_count = extracted_count + 1;
                            end
                        end
                    end
                catch ME
                    % Continue to next variable
                end
            end
        end

    catch ME
        % Continue without model workspace data
    end
end

function [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time)
    % Extract data from logsout (standard Simulink logging)
    try
        if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
            logsout = simOut.logsout;

            for i = 1:logsout.numElements
                try
                    element = logsout.getElement(i);
                    signal_name = element.Name;
                    data = element.Values.Data;
                    time = element.Values.Time;

                    % Clean signal name
                    clean_name = strrep(signal_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');

                    % Handle different data types
                    if isvector(data)
                        % Single-dimensional data
                        resampled_data = interp1(time, data, target_time, 'linear', 'extrap');
                        trial_data = [trial_data, resampled_data(:)];
                        signal_names{end+1} = clean_name;
                    elseif ismatrix(data) && size(data, 2) > 1
                        % Multi-dimensional data - extract each component
                        for j = 1:size(data, 2)
                            component_data = data(:, j);
                            resampled_data = interp1(time, component_data, target_time, 'linear', 'extrap');
                            trial_data = [trial_data, resampled_data(:)];
                            signal_names{end+1} = sprintf('%s_%d', clean_name, j);
                        end
                    end

                catch ME
                    % Continue to next element
                end
            end
        end

    catch ME
        % Continue without logsout data
    end
end

function [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time)
    % Extract data from signal log structs (ToWorkspace blocks)
    try
        % Look for signal bus data in simulation output
        signal_bus_fields = {'ClubData', 'HandData', 'JointData', 'BodyData', 'Club', 'Hand', 'Joint', 'Body'};

        for i = 1:length(signal_bus_fields)
            field_name = signal_bus_fields{i};
            if isfield(simOut, field_name)
                try
                    log_struct = simOut.(field_name);
                    log_fields = fieldnames(log_struct);

                    for j = 1:length(log_fields)
                        field_name_inner = log_fields{j};
                        field_data = log_struct.(field_name_inner);

                        if isstruct(field_data) && isfield(field_data, 'Data') && isfield(field_data, 'Time')
                            % This is a time series field
                            data = field_data.Data;
                            time = field_data.Time;

                            % Handle 3D rotation matrices (3x3xN arrays)
                            if ndims(data) == 3 && size(data, 1) == 3 && size(data, 2) == 3
                                % This is a 3D rotation matrix - extract each component
                                for row = 1:3
                                    for col = 1:3
                                        element_data = squeeze(data(row, col, :));
                                        resampled_data = interp1(time, element_data, target_time, 'linear', 'extrap');
                                        element_name = sprintf('%s_%s_%d%d', field_name, field_name_inner, row, col);
                                        trial_data = [trial_data, resampled_data(:)];
                                        signal_names{end+1} = element_name;
                                    end
                                end

                            elseif ismatrix(data) && size(data, 2) > 1
                                % Multi-dimensional data - extract each component
                                for k = 1:size(data, 2)
                                    component_data = data(:, k);
                                    resampled_data = interp1(time, component_data, target_time, 'linear', 'extrap');
                                    trial_data = [trial_data, resampled_data(:)];
                                    signal_names{end+1} = sprintf('%s_%s_%d', field_name, field_name_inner, k);
                                end
                            else
                                % Single-dimensional data
                                resampled_data = interp1(time, data, target_time, 'linear', 'extrap');
                                trial_data = [trial_data, resampled_data(:)];
                                signal_names{end+1} = sprintf('%s_%s', field_name, field_name_inner);
                            end
                        end
                    end

                catch ME
                    % Continue to next signal log
                end
            end
        end

    catch ME
        % Continue without signal log data
    end
end

function [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time)
    % Extract data from Simscape Results Explorer
    try
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run_id = runIDs(end);
            run_obj = Simulink.sdi.getRun(latest_run_id);
            all_signals = run_obj.getAllSignals;

            for i = 1:length(all_signals)
                sig = all_signals(i);
                try
                    % Get signal data
                    data = sig.Values.Data;
                    time = sig.Values.Time;

                    % Use original signal name, but clean it for table compatibility
                    original_name = sig.Name;
                    clean_name = strrep(original_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');

                    % Handle different data types
                    if isvector(data)
                        % Single-dimensional data
                        resampled_data = interp1(time, data, target_time, 'linear', 'extrap');
                        trial_data = [trial_data, resampled_data(:)];
                        signal_names{end+1} = clean_name;
                    elseif ismatrix(data) && size(data, 2) > 1
                        % Multi-dimensional data - extract each component
                        for j = 1:size(data, 2)
                            component_data = data(:, j);
                            resampled_data = interp1(time, component_data, target_time, 'linear', 'extrap');
                            trial_data = [trial_data, resampled_data(:)];
                            signal_names{end+1} = sprintf('%s_%d', clean_name, j);
                        end
                    end

                catch ME
                    % Continue to next signal
                end
            end
        end

    catch ME
        % Continue without Simscape data
    end
end

function [trial_data, signal_names] = filterDiscreteVariables(trial_data, signal_names)
    % Filter out discrete variables that are all zeros (unused signals)
    try
        % Find discrete variable columns
        discrete_indices = [];
        for i = 1:length(signal_names)
            if startsWith(signal_names{i}, 'Discrete_')
                discrete_indices = [discrete_indices, i];
            end
        end

        if isempty(discrete_indices)
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
        end

    catch ME
        % Continue without filtering
    end
end

function signal_names = makeUniqueColumnNames(signal_names)
    % Ensure all column names are unique
    try
        [unique_names, ~, ic] = unique(signal_names);
        if length(unique_names) < length(signal_names)
            for i = 1:length(signal_names)
                count = sum(ic(1:i) == ic(i));
                if count > 1
                    signal_names{i} = sprintf('%s_%d', signal_names{i}, count);
                end
            end
        end
    catch ME
        % Continue without making names unique
    end
end