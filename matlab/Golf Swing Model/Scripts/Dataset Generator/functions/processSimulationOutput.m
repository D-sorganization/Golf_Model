function result = processSimulationOutput(trial_num, config, simOut, capture_workspace)
result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);

try
    fprintf('Processing simulation output for trial %d...\n', trial_num);

    % Start timing for this trial
    trial_start_time = tic;

    % Extract data using the enhanced signal extraction system
    fprintf('  ⏱️  Starting signal extraction...\n');
    signal_extraction_start = tic;

    options = struct();
    options.extract_combined_bus = config.use_signal_bus;
    options.extract_logsout = config.use_logsout;
    options.extract_simscape = config.use_simscape;
    options.verbose = false; % Set to true for debugging

    [data_table, signal_info] = extractSignalsFromSimOut(simOut, options);

    signal_extraction_time = toc(signal_extraction_start);
    fprintf('  ⏱️  Signal extraction completed in %.3f seconds\n', signal_extraction_time);

    if isempty(data_table)
        result.error = 'No data extracted from simulation';
        fprintf('No data extracted from simulation output\n');
        return;
    end

    fprintf('Extracted %d rows of data\n', height(data_table));

    % Resample data to desired frequency if specified
    if isfield(config, 'sample_rate') && ~isempty(config.sample_rate) && config.sample_rate > 0
        fprintf('  ⏱️  Starting data resampling...\n');
        resampling_start = tic;

        data_table = resampleDataToFrequency(data_table, config.sample_rate, config.simulation_time);

        resampling_time = toc(resampling_start);
        fprintf('  ⏱️  Data resampling completed in %.3f seconds\n', resampling_time);
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
        fprintf('  ⏱️  Starting model workspace data addition...\n');
        workspace_start = tic;

        data_table = addModelWorkspaceData(data_table, simOut, num_rows);

        workspace_time = toc(workspace_start);
        fprintf('  ⏱️  Model workspace data addition completed in %.3f seconds\n', workspace_time);
    else
        fprintf('Debug: Model workspace capture disabled by user setting\n');
    end

    % Save to file in selected format(s)
    fprintf('  ⏱️  Starting file saving...\n');
    file_saving_start = tic;

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

    file_saving_time = toc(file_saving_start);
    fprintf('  ⏱️  File saving completed in %.3f seconds\n', file_saving_time);

    result.success = true;
    result.filename = filename;
    result.data_points = num_rows;
    result.columns = width(data_table);

    % Calculate total trial time
    total_trial_time = toc(trial_start_time);
    fprintf('⏱️  Trial %d completed in %.3f seconds: %d data points, %d columns\n', ...
        trial_num, total_trial_time, num_rows, width(data_table));

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
