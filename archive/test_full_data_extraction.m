% Comprehensive test to extract ALL available data from simulation
fprintf('Testing comprehensive data extraction...\n');

try
    % Load the model
    model_name = 'Model/GolfSwing3D_Kinetic';
    fprintf('Loading model: %s\n', model_name);

    if ~bdIsLoaded('GolfSwing3D_Kinetic')
        load_system(model_name);
    end

    % Set up simulation parameters
    set_param('GolfSwing3D_Kinetic', 'StopTime', '0.1'); % Short simulation for testing
    set_param('GolfSwing3D_Kinetic', 'SaveOutput', 'on');
    set_param('GolfSwing3D_Kinetic', 'SaveFormat', 'Dataset');

    fprintf('Running short simulation...\n');

    % Run simulation
    simOut = sim('GolfSwing3D_Kinetic');

    fprintf('Simulation completed successfully!\n');
    fprintf('Simulation output type: %s\n', class(simOut));

    % Check ALL available data sources
    fprintf('\n=== Checking ALL available data sources ===\n');

    % Get all available properties
    if isa(simOut, 'Simulink.SimulationOutput')
        available = simOut.who;
    else
        available = fieldnames(simOut);
    end

    fprintf('Available outputs: %s\n', strjoin(available, ', '));

    % Check each data source
    total_signals = 0;
    all_data_sources = {};

    % 1. Check logsout
    if isprop(simOut, 'logsout')
        fprintf('\n--- Logsout Data ---\n');
        logsout = simOut.logsout;
        fprintf('Logsout type: %s\n', class(logsout));
        fprintf('Logsout elements: %d\n', logsout.numElements);

        % List all elements in logsout
        for i = 1:logsout.numElements
            element = logsout.getElement(i);
            fprintf('Element %d: %s (type: %s)\n', i, element.Name, class(element));

            if isa(element, 'Simulink.SimulationData.Signal')
                data = element.Values.Data;
                fprintf('  Data size: %s\n', mat2str(size(data)));
            end
        end

        % Extract logsout data
        addpath('Scripts/Simulation_Dataset_GUI');
        logsout_data = extractLogsoutDataFixed(logsout);
        if ~isempty(logsout_data)
            all_data_sources{end+1} = logsout_data;
            total_signals = total_signals + width(logsout_data);
            fprintf('Logsout extracted: %d columns\n', width(logsout_data));
        end
    end

    % 2. Check CombinedSignalBus specifically
    if isprop(simOut, 'CombinedSignalBus')
        fprintf('\n--- CombinedSignalBus Data ---\n');
        combined_bus = simOut.CombinedSignalBus;
        fprintf('CombinedSignalBus type: %s\n', class(combined_bus));

        if isstruct(combined_bus)
            bus_fields = fieldnames(combined_bus);
            fprintf('CombinedSignalBus fields: %s\n', strjoin(bus_fields, ', '));

            % Extract data from CombinedSignalBus
            bus_data = extractCombinedSignalBusData(combined_bus);
            if ~isempty(bus_data)
                all_data_sources{end+1} = bus_data;
                total_signals = total_signals + width(bus_data);
                fprintf('CombinedSignalBus extracted: %d columns\n', width(bus_data));
            end
        end
    end

    % 3. Check simlog (Simscape data)
    if isprop(simOut, 'simlog')
        fprintf('\n--- Simscape Data ---\n');
        simlog = simOut.simlog;
        fprintf('Simlog type: %s\n', class(simlog));

        % Try to extract Simscape data
        simscape_data = extractSimscapeDataFixed(simlog);
        if ~isempty(simscape_data)
            all_data_sources{end+1} = simscape_data;
            total_signals = total_signals + width(simscape_data);
            fprintf('Simscape extracted: %d columns\n', width(simscape_data));
        end
    end

    % 4. Check workspace outputs (tout, xout, etc.)
    fprintf('\n--- Workspace Outputs ---\n');
    workspace_data = extractWorkspaceOutputs(simOut);
    if ~isempty(workspace_data)
        all_data_sources{end+1} = workspace_data;
        total_signals = total_signals + width(workspace_data);
        fprintf('Workspace outputs extracted: %d columns\n', width(workspace_data));
    end

    % 5. Check for any other data sources
    for i = 1:length(available)
        var_name = available{i};

        % Skip already processed variables
        if ismember(var_name, {'logsout', 'simlog', 'CombinedSignalBus', 'tout', 'xout'})
            continue;
        end

        fprintf('\n--- Checking %s ---\n', var_name);
        try
            if isa(simOut, 'Simulink.SimulationOutput')
                var_data = simOut.get(var_name);
            else
                var_data = simOut.(var_name);
            end

            fprintf('Type: %s\n', class(var_data));
            if isnumeric(var_data)
                fprintf('Size: %s\n', mat2str(size(var_data)));
            elseif isstruct(var_data)
                fields = fieldnames(var_data);
                fprintf('Fields: %s\n', strjoin(fields, ', '));
            end
        catch ME
            fprintf('Error accessing %s: %s\n', var_name, ME.message);
        end
    end

    % Summary
    fprintf('\n=== SUMMARY ===\n');
    fprintf('Total data sources found: %d\n', length(all_data_sources));
    fprintf('Total signals extracted: %d\n', total_signals);

    for i = 1:length(all_data_sources)
        fprintf('Source %d: %d rows, %d columns\n', i, height(all_data_sources{i}), width(all_data_sources{i}));
    end

    % Close the model
    if bdIsLoaded('GolfSwing3D_Kinetic')
        close_system('GolfSwing3D_Kinetic', 0);
    end

    fprintf('\n=== Test completed ===\n');

catch ME
    fprintf('ERROR: Test failed: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

function bus_data = extractCombinedSignalBusData(combined_bus)
    bus_data = [];

    try
        fprintf('Debug: Extracting CombinedSignalBus data\n');

        if ~isstruct(combined_bus)
            fprintf('Debug: CombinedSignalBus is not a struct\n');
            return;
        end

        fields = fieldnames(combined_bus);
        fprintf('Debug: Found %d fields in CombinedSignalBus\n', length(fields));

        % Find time data first
        time_data = [];
        time_field = '';

        for i = 1:length(fields)
            field_name = fields{i};
            field_value = combined_bus.(field_name);

            if isnumeric(field_value) && length(field_value) > 100
                % This might be time data
                time_data = field_value;
                time_field = field_name;
                fprintf('Debug: Found potential time field: %s (length: %d)\n', field_name, length(field_value));
                break;
            end
        end

        if isempty(time_data)
            fprintf('Debug: No time data found in CombinedSignalBus\n');
            return;
        end

        data_cells = {time_data(:)};
        var_names = {'time'};
        expected_length = length(time_data);

        % Extract all numeric fields
        for i = 1:length(fields)
            field_name = fields{i};

            if strcmp(field_name, time_field)
                continue; % Skip time field
            end

            field_value = combined_bus.(field_name);

            if isnumeric(field_value)
                if length(field_value) == expected_length
                    data_cells{end+1} = field_value(:);
                    var_names{end+1} = field_name;
                    fprintf('Debug: Added field %s (length: %d)\n', field_name, length(field_value));
                else
                    fprintf('Debug: Skipping field %s (length mismatch: %d vs %d)\n', field_name, length(field_value), expected_length);
                end
            elseif isstruct(field_value)
                % Handle nested structs
                nested_data = extractNestedStructData(field_value, expected_length);
                if ~isempty(nested_data)
                    % Merge nested data
                    for j = 1:width(nested_data)
                        col_name = nested_data.Properties.VariableNames{j};
                        if ~strcmp(col_name, 'time')
                            data_cells{end+1} = nested_data.(col_name);
                            var_names{end+1} = sprintf('%s_%s', field_name, col_name);
                        end
                    end
                end
            end
        end

        if length(data_cells) > 1
            bus_data = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created CombinedSignalBus table with %d columns\n', width(bus_data));
        end

    catch ME
        fprintf('Error extracting CombinedSignalBus data: %s\n', ME.message);
    end
end

function nested_data = extractNestedStructData(struct_data, expected_length)
    nested_data = [];

    try
        if ~isstruct(struct_data)
            return;
        end

        fields = fieldnames(struct_data);
        data_cells = {};
        var_names = {};

        for i = 1:length(fields)
            field_name = fields{i};
            field_value = struct_data.(field_name);

            if isnumeric(field_value) && length(field_value) == expected_length
                data_cells{end+1} = field_value(:);
                var_names{end+1} = field_name;
            elseif isstruct(field_value)
                % Recursively handle nested structs
                deeper_data = extractNestedStructData(field_value, expected_length);
                if ~isempty(deeper_data)
                    for j = 1:width(deeper_data)
                        col_name = deeper_data.Properties.VariableNames{j};
                        data_cells{end+1} = deeper_data.(col_name);
                        var_names{end+1} = sprintf('%s_%s', field_name, col_name);
                    end
                end
            end
        end

        if ~isempty(data_cells)
            nested_data = table(data_cells{:}, 'VariableNames', var_names);
        end

    catch ME
        fprintf('Error extracting nested struct data: %s\n', ME.message);
    end
end
