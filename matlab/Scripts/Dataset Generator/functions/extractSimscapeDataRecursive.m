% ENHANCED: Extract from Simscape with detailed diagnostics
function simscape_data = extractSimscapeDataRecursive(simlog)
simscape_data = table();  % Empty table if no data

try
    % DETAILED DIAGNOSTICS
    fprintf('=== SIMSCAPE DIAGNOSTIC START ===\n');

    if isempty(simlog)
        fprintf('❌ simlog is EMPTY\n');
        fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');
        return;
    end

    fprintf('✅ simlog exists, class: %s\n', class(simlog));

    if ~isa(simlog, 'simscape.logging.Node')
        fprintf('❌ simlog is not a simscape.logging.Node\n');
        fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');
        return;
    end

    fprintf('✅ simlog is valid simscape.logging.Node\n');

    % Try to inspect the simlog structure
    try
        fprintf(' Inspecting simlog properties...\n');
        props = properties(simlog);
        fprintf('   Properties: %s\n', strjoin(props, ', '));
    catch
        fprintf('❌ Could not get simlog properties\n');
    end

    % Try to get children (properties ARE the children in Multibody)
    try
        children_ids = simlog.children();
        fprintf('✅ Found %d top-level children: %s\n', length(children_ids), strjoin(children_ids, ', '));
    catch ME
        fprintf('❌ Could not get children method: %s\n', ME.message);
        fprintf(' Using properties as children (Multibody approach)\n');

        % Get properties excluding system properties
        all_props = properties(simlog);
        children_ids = {};
        for i = 1:length(all_props)
            prop_name = all_props{i};
            % Skip system properties, keep actual joint/body names
            if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                children_ids{end+1} = prop_name;
            end
        end
        fprintf('✅ Found %d children from properties: %s\n', length(children_ids), strjoin(children_ids, ', '));
    end

    % Try to inspect first child
    if ~isempty(children_ids)
        try
            first_child_id = children_ids{1};
            first_child = simlog.(first_child_id);
            fprintf(' First child (%s) class: %s\n', first_child_id, class(first_child));

            % Try to get series from first child
            try
                series_children = first_child.series.children();
                fprintf('✅ First child has %d series: %s\n', length(series_children), strjoin(series_children, ', '));
            catch ME2
                fprintf('❌ First child series access failed: %s\n', ME2.message);
            end

        catch ME
            fprintf('❌ Could not inspect first child: %s\n', ME.message);
        end
    end

    fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');

    % Recursively collect all series data using primary traversal method
    [time_data, all_signals] = traverseSimlogNode(simlog, '');

    if isempty(time_data) || isempty(all_signals)
        fprintf('⚠️  Primary method found no data. Trying fallback methods...\n');

        % FALLBACK METHOD: Simple property inspection
        [time_data, all_signals] = fallbackSimlogExtraction(simlog);

        if isempty(time_data) || isempty(all_signals)
            fprintf('❌ All extraction methods failed. No usable Simscape data found.\n');
            return;
        else
            fprintf('✅ Fallback method found data!\n');
        end
    else
        fprintf('✅ Primary method found data!\n');
    end

    % Build table
    data_cells = {time_data};
    var_names = {'time'};
    expected_length = length(time_data);

    for i = 1:length(all_signals)
        signal = all_signals{i};
        signal_data = signal.data;
        data_size = size(signal_data);
        num_elements = numel(signal_data);

        if length(signal_data) == expected_length
            % Standard time series data
            data_cells{end+1} = signal_data(:);
            var_names{end+1} = signal.name;
            fprintf('Debug: Added Simscape signal: %s (length: %d)\n', signal.name, expected_length);

        elseif num_elements == 3 && size(signal_data, 1) == 3 && size(signal_data, 2) == 1 && size(signal_data, 3) == expected_length
            % Handle [3 1 N] time-varying 3D vectors (e.g., position, velocity, unit vectors)
            % Extract each component of the 3D vector over time
            for dim = 1:3
                data_cells{end+1} = squeeze(signal_data(dim, 1, :));
                var_names{end+1} = sprintf('%s_dim%d', signal.name, dim);
                fprintf('Debug: Added [3 1 N] Simscape vector %s_dim%d (N=%d)\n', signal.name, dim, expected_length);
            end

        elseif num_elements == 9 && size(signal_data, 1) == 3 && size(signal_data, 2) == 3 && size(signal_data, 3) == expected_length
            % Handle [3 3 N] time-varying 3x3 matrices (e.g., inertia, rotation matrices)
            % Flatten each 3x3 matrix at each timestep into 9 columns
            flat_matrix = reshape(permute(signal_data, [3 1 2]), expected_length, 9);
            for idx = 1:9
                [row, col] = ind2sub([3,3], idx);
                data_cells{end+1} = flat_matrix(:,idx);
                var_names{end+1} = sprintf('%s_I%d%d', signal.name, row, col);
                fprintf('Debug: Added [3 3 N] Simscape matrix %s_I%d%d (N=%d)\n', signal.name, row, col, expected_length);
            end

        else
            fprintf('Debug: Skipped %s (size [%s] not supported - need time series, [3 1 N], or [3 3 N])\n', ...
                signal.name, num2str(data_size));
        end
    end

    if length(data_cells) > 1
        simscape_data = table(data_cells{:}, 'VariableNames', var_names);
        fprintf('Debug: Created Simscape table with %d columns, %d rows.\n', width(simscape_data), height(simscape_data));
    else
        fprintf('Debug: Only time data found in Simscape log.\n');
    end

catch ME
    fprintf('Error extracting Simscape data recursively: %s\n', ME.message);
end
end
