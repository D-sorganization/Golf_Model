function result = processSimulationOutput(trial_num, config, simOut, capture_workspace)
result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);

try
    fprintf('Processing simulation output for trial %d...\n', trial_num);

    % Ensure config has enhanced settings for maximum data extraction
    config = ensureEnhancedConfig(config);

    % Extract data using the enhanced signal extraction system with 1956 column support
    options = struct();
    options.extract_combined_bus = config.use_signal_bus;
    options.extract_logsout = config.use_logsout;
    options.extract_simscape = config.use_simscape;
    options.verbose = config.verbose; % Use config verbose setting for debugging 1956 column extraction

    % Use existing extraction method for comprehensive data capture
    [data_table, signal_info] = extractSignalsFromSimOut(simOut, options);

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
    else
        fprintf('Debug: Model workspace capture disabled by user setting\n');
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

    result.success = true;
    result.filename = filename;
    result.data_points = num_rows;
    result.columns = width(data_table);

    % Report column count and 1956 target achievement for individual trial
    fprintf('Trial %d completed: %d data points, %d columns\n', trial_num, num_rows, width(data_table));
    if width(data_table) >= 1956
        fprintf('✓ Trial %d: Target 1956 columns ACHIEVED (%d columns)\n', trial_num, width(data_table));
    else
        fprintf('✗ Trial %d: Target 1956 columns MISSED (%d columns, need %d more)\n', trial_num, width(data_table), 1956 - width(data_table));
    end

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
