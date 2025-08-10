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
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s', var_name));
                            if success
                                extracted_count = extracted_count + 1;
                            end

                        elseif isvector(var_value)
                            % Vector value - handle as time-invariant parameters
                            for j = 1:length(var_value)
                                data_column = repmat(var_value(j), num_time_points, 1);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s_%d', var_name, j));
                                if success
                                    extracted_count = extracted_count + 1;
                                end
                            end

                        elseif ismatrix(var_value) && size(var_value, 1) == 3 && size(var_value, 2) == 3
                            % 3x3 matrix (e.g., inertia tensor) - flatten to 9 components
                            flat_inertia = var_value(:)'; % Flatten to row vector
                            for j = 1:9
                                data_column = repmat(flat_inertia(j), num_time_points, 1);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s_%d', var_name, j));
                                if success
                                    extracted_count = extracted_count + 1;
                                end
                            end
                        end
                    end
                catch ME
                    % Continue to next variable
                end
            end
        end

        % Extract all workspace variables that might be relevant
        for i = 1:length(workspace_vars)
            var_info = workspace_vars(i);
            var_name = var_info.name;

            % Skip if already processed or if it's a system variable
            if any(strcmp(anthropomorphic_vars, var_name)) || ...
               startsWith(var_name, 'sl_') || startsWith(var_name, 'sim_') || ...
               startsWith(var_name, 'gcs_') || startsWith(var_name, 'gcb_')
                continue;
            end

            try
                var_value = model_workspace.getVariable(var_name);

                % Only extract numeric variables
                if isnumeric(var_value)
                    if isscalar(var_value)
                        data_column = repmat(var_value, num_time_points, 1);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s', var_name));
                        if success
                            extracted_count = extracted_count + 1;
                        end

                    elseif isvector(var_value) && length(var_value) <= 10
                        % Small vectors - extract each component
                        for j = 1:length(var_value)
                            data_column = repmat(var_value(j), num_time_points, 1);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, sprintf('ModelWorkspace_%s_%d', var_name, j));
                            if success
                                extracted_count = extracted_count + 1;
                            end
                        end
                    end
                end
            catch ME
                % Continue to next variable
            end
        end

    catch ME
        % Continue without model workspace data
    end
end

function [trial_data, signal_names] = extractLogsoutData(simOut, trial_data, signal_names, target_time)
    % Extract data from logsout with improved rotation matrix handling
    try
        if ~isfield(simOut, 'logsout') || isempty(simOut.logsout)
            return;
        end

        logsout = simOut.logsout;
        for i = 1:logsout.numElements
            try
                element = logsout.getElement(i);
                % Use original name but clean it properly (preserve parentheses)
                original_name = element.Name;
                name = strrep(original_name, ' ', '_');
                name = strrep(name, '-', '_');
                name = strrep(name, '.', '_');
                % Don't remove parentheses - they're part of the signal names!
                name = strrep(name, '[', '');
                name = strrep(name, ']', '');
                name = strrep(name, '/', '_');
                name = strrep(name, '\', '_');
                data = element.Values.Data;
                time = element.Values.Time;

                % Handle rotation matrices and other multi-dimensional data
                if ismatrix(data) && size(data, 2) > 1
                    % Multi-dimensional data - extract each component
                    for j = 1:size(data, 2)
                        component_data = data(:, j);
                        resampled_data = resampleSignal(component_data, time, target_time);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, sprintf('%s_%d', name, j));
                    end
                else
                    % Single-dimensional data
                    resampled_data = resampleSignal(data, time, target_time);
                    [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, name);
                end

            catch ME
                % Continue to next signal
            end
        end

    catch ME
        % Continue without logsout data
    end
end

function [trial_data, signal_names] = extractSignalLogStructs(simOut, trial_data, signal_names, target_time)
    % Extract data from custom signal log structs (HipLogs, SpineLogs, etc.)
    try
        % Define signal log struct names
        signal_log_names = {'HipLogs', 'SpineLogs', 'TorsoLogs', 'LELogs', 'LFLogs', 'LScapLogs', 'LSLogs', 'LWLogs', 'RELogs', 'RFLogs', 'RScapLogs', 'RSLogs', 'RWLogs'};

        for i = 1:length(signal_log_names)
            log_name = signal_log_names{i};
            if isfield(simOut, log_name)
                try
                    log_struct = simOut.(log_name);
                    log_fields = fieldnames(log_struct);

                    for j = 1:length(log_fields)
                        field_name = log_fields{j};
                        field_data = log_struct.(field_name);

                        if isstruct(field_data) && isfield(field_data, 'Data') && isfield(field_data, 'Time')
                            % This is a time series field
                            data = field_data.Data;
                            time = field_data.Time;

                            % Handle 3D rotation matrices (3x3xN arrays)
                            if ndims(data) == 3 && size(data, 1) == 3 && size(data, 2) == 3
                                % This is a 3D rotation matrix - extract each component

                                % Extract each element of the 3x3 matrix as a separate column
                                for row = 1:3
                                    for col = 1:3
                                        % Extract the time series for this matrix element
                                        element_data = squeeze(data(row, col, :));

                                        % Resample to target time
                                        resampled_data = resampleSignal(element_data, time, target_time);

                                        % Create column name for this matrix element
                                        element_name = sprintf('%s_%s_%d%d', log_name, field_name, row, col);

                                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, element_name);
                                    end
                                end

                            elseif ismatrix(data) && size(data, 2) > 1
                                % Multi-dimensional data - extract each component
                                for k = 1:size(data, 2)
                                    component_data = data(:, k);
                                    resampled_data = resampleSignal(component_data, time, target_time);
                                    [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, sprintf('%s_%s_%d', log_name, field_name, k));
                                end
                            else
                                % Single-dimensional data
                                resampled_data = resampleSignal(data, time, target_time);
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, sprintf('%s_%s', log_name, field_name));
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
    % Extract data from Simscape Results Explorer with improved rotation matrix handling
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
                    % Replace problematic characters but preserve parentheses (they indicate vector components)
                    clean_name = strrep(original_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    % Don't remove parentheses - they're part of the signal names!
                    % clean_name = strrep(clean_name, '(', '');
                    % clean_name = strrep(clean_name, ')', '');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');

                    % Handle 3D rotation matrices (3x3xN arrays)
                    if ndims(data) == 3 && size(data, 1) == 3 && size(data, 2) == 3
                        % This is a 3D rotation matrix - extract each component

                        % Extract each element of the 3x3 matrix as a separate column
                        for row = 1:3
                            for col = 1:3
                                % Extract the time series for this matrix element
                                element_data = squeeze(data(row, col, :));

                                % Resample to target time
                                resampled_data = resampleSignal(element_data, time, target_time);

                                % Create column name for this matrix element
                                element_name = sprintf('%s_%d%d', clean_name, row, col);

                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, element_name);
                            end
                        end

                    % Handle 2D matrices (time x components) - FIXED VERSION
                    elseif ismatrix(data) && size(data, 2) > 1
                        % Multi-dimensional data - extract each component

                        % Resample the entire matrix first
                        resampled_matrix = resampleSignal(data, time, target_time);

                        % Then extract each component
                        for j = 1:size(resampled_matrix, 2)
                            component_data = resampled_matrix(:, j);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, component_data, sprintf('%s_%d', clean_name, j));
                        end
                    else
                        % Single-dimensional data
                        resampled_data = resampleSignal(data, time, target_time);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, clean_name);
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

function [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, column_name)
    % Global helper function to safely add a column to trial_data
    try
        % Handle empty data
        if isempty(data_column)
            success = false;
            return;
        end

        % Ensure data_column is a column vector with correct dimensions
        if ~iscolumn(data_column)
            data_column = data_column(:);
        end

        % Check if dimensions match
        if size(trial_data, 1) == size(data_column, 1)
            trial_data = [trial_data, data_column];
            signal_names{end+1} = column_name;
            success = true;
        else
            success = false;
        end
    catch ME
        success = false;
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