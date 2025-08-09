% Test script to extract simulation data from different sources
% This script helps diagnose what data is available and where it's stored

fprintf('=== Running test simulation for data extraction ===\n');

%% Workspace Cleanup Setup
% Save current workspace state to restore later
initial_vars = who;
initial_vars = setdiff(initial_vars, {'initial_vars'}); % Don't save this variable

% Function to restore workspace
function restoreWorkspace(initial_vars)
    current_vars = who;
    vars_to_clear = setdiff(current_vars, [initial_vars, {'initial_vars'}]);
    if ~isempty(vars_to_clear)
        clear(vars_to_clear{:});
    end
end

%% Configuration
model_name = 'GolfSwing3D_Kinetic';
sim_time = 0.3;

% Check if 'out' exists in workspace (from manual run)
if exist('out', 'var')
    fprintf('✓ Found "out" variable in workspace (from manual simulation)\n');
    simOut = out;
    manual_run = true;
else
    fprintf('No "out" variable found, running simulation programmatically...\n');
    
    % Ensure model is loaded
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end
    
    % Set up logging
    set_param(model_name, 'StopTime', num2str(sim_time));
    set_param(model_name, 'SignalLogging', 'on');
    set_param(model_name, 'SignalLoggingName', 'out');
    set_param(model_name, 'SignalLoggingSaveFormat', 'Dataset');
    set_param(model_name, 'SimscapeLogType', 'all'); % Ensure Simscape logging is on
    
    % Run simulation
    simOut = sim(model_name);
    manual_run = false;
end

% Debug: Show what fields are in simOut
fprintf('\n=== Debug: simOut structure ===\n');
fprintf('simOut fields:\n');
fields = fieldnames(simOut);
for i = 1:length(fields)
    field = fields{i};
    val = simOut.(field);
    if isnumeric(val)
        if isvector(val)
            fprintf('  %s: numeric vector [%dx1]\n', field, length(val));
        else
            fprintf('  %s: numeric matrix [%dx%d]\n', field, size(val,1), size(val,2));
        end
    elseif isstruct(val)
        fprintf('  %s: struct with %d fields\n', field, length(fieldnames(val)));
    elseif isa(val, 'Simulink.SimulationData.Dataset')
        fprintf('  %s: Dataset with %d elements\n', field, val.numElements);
    else
        fprintf('  %s: %s\n', field, class(val));
    end
end

%% 1. Save logsout data as table and CSV
if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
    logsout = simOut.logsout;
    fprintf('\n=== Extracting logsout data ===\n');
    fprintf('logsout has %d elements\n', logsout.numElements);
    
    % Extract all signals
    all_names = {};
    all_data = {};
    all_time = [];
    for i = 1:logsout.numElements
        try
            element = logsout.getElement(i);
            name = matlab.lang.makeValidName(element.Name);
            data = element.Values.Data;
            time = element.Values.Time;
            all_names{end+1} = name;
            all_data{end+1} = data(:);
            if isempty(all_time)
                all_time = time(:);
            end
            fprintf('  ✓ %s (%d points)\n', name, length(data));
        catch ME
            fprintf('  ✗ Error extracting element %d: %s\n', i, ME.message);
        end
    end
    
    % Align all signals to the common time vector
    if ~isempty(all_names)
        T = table(all_time, 'VariableNames', {'time'});
        for i = 1:length(all_names)
            d = all_data{i};
            if length(d) ~= height(T)
                % Pad with NaN if needed
                d = nan(height(T),1);
            end
            T.(all_names{i}) = d;
        end
        writetable(T, 'test_logsout.csv');
        save('test_logsout.mat', 'T');
        fprintf('✓ logsout saved to test_logsout.csv and test_logsout.mat (table)\n');
        fprintf('  Table size: %dx%d\n', height(T), width(T));
    else
        fprintf('✗ No signals extracted from logsout\n');
    end
else
    fprintf('✗ logsout not found in simOut\n');
end

%% 2. Save all signal log variables (like RScapLogs, HipLogs, etc.) as table and CSV
fprintf('\n=== Extracting signal log variables ===\n');
all_names = {};
all_data = {};
all_time = [];

% Look for signal log structs (like RScapLogs, HipLogs, etc.)
signal_log_fields = {};
for i = 1:length(fields)
    field = fields{i};
    if endsWith(field, 'Logs') && isstruct(simOut.(field))
        signal_log_fields{end+1} = field;
    end
end

fprintf('Found %d signal log fields: %s\n', length(signal_log_fields), strjoin(signal_log_fields, ', '));

for i = 1:length(signal_log_fields)
    field = signal_log_fields{i};
    log_struct = simOut.(field);
    struct_fields = fieldnames(log_struct);
    fprintf('  %s has %d fields: %s\n', field, length(struct_fields), strjoin(struct_fields, ', '));
    
    for j = 1:length(struct_fields)
        subfield = struct_fields{j};
        try
            val = log_struct.(subfield);
            if isnumeric(val) && isvector(val) && length(val) > 1
                name = sprintf('%s_%s', field, subfield);
                all_names{end+1} = name;
                all_data{end+1} = val(:);
                if isempty(all_time)
                    all_time = val(:);
                end
                fprintf('    ✓ %s (%d points)\n', name, length(val));
            end
        catch
            % skip
        end
    end
end

% Also check for other numeric vectors in simOut
for i = 1:length(fields)
    field = fields{i};
    if ~endsWith(field, 'Logs') && ~strcmp(field, 'logsout') && ~strcmp(field, 'tout')
        try
            val = simOut.(field);
            if isnumeric(val) && isvector(val) && length(val) > 1
                if isempty(all_time)
                    all_time = val(:);
                    all_names{end+1} = field;
                    all_data{end+1} = val(:);
                elseif length(val) == length(all_time)
                    all_names{end+1} = field;
                    all_data{end+1} = val(:);
                end
                fprintf('  ✓ %s (%d points)\n', field, length(val));
            end
        catch
            % skip
        end
    end
end

if ~isempty(all_names)
    T2 = table(all_time, 'VariableNames', {'time'});
    for i = 1:length(all_names)
        d = all_data{i};
        if length(d) ~= height(T2)
            d = nan(height(T2),1);
        end
        T2.(matlab.lang.makeValidName(all_names{i})) = d;
    end
    writetable(T2, 'test_signal_logs.csv');
    save('test_signal_logs.mat', 'T2');
    fprintf('✓ Signal log variables saved to test_signal_logs.csv and test_signal_logs.mat (table)\n');
    fprintf('  Table size: %dx%d\n', height(T2), width(T2));
else
    fprintf('✗ No signal log variables found\n');
end

%% 3. Save all Simscape Results Explorer signals as table and CSV
fprintf('\n=== Extracting Simscape Results Explorer data ===\n');
try
    runIDs = Simulink.sdi.getAllRunIDs;
    if ~isempty(runIDs)
        latest_run_id = runIDs(end);
        run_obj = Simulink.sdi.getRun(latest_run_id);
        all_signals = run_obj.getAllSignals;
        fprintf('Found %d Simscape signals\n', length(all_signals));
        
        all_names = {};
        all_data = {};
        all_time = [];
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
                
                all_names{end+1} = clean_name;
                all_data{end+1} = data(:);
                if isempty(all_time)
                    all_time = time(:);
                end
                fprintf('  ✓ %s (%d points)\n', original_name, length(data));
            catch ME
                fprintf('  ✗ Error extracting signal %s: %s\n', sig.Name, ME.message);
            end
        end
        
        if ~isempty(all_names)
            T3 = table(all_time, 'VariableNames', {'time'});
            for i = 1:length(all_names)
                d = all_data{i};
                if length(d) ~= height(T3)
                    d = nan(height(T3),1);
                end
                T3.(all_names{i}) = d;
            end
            writetable(T3, 'test_simscape_data.csv');
            save('test_simscape_data.mat', 'T3');
            fprintf('✓ Simscape Results Explorer data saved to test_simscape_data.csv and test_simscape_data.mat (table)\n');
            fprintf('  Table size: %dx%d\n', height(T3), width(T3));
        else
            fprintf('✗ No Simscape signals extracted\n');
        end
    else
        fprintf('✗ No Simscape runs found in Results Explorer\n');
    end
catch ME
    fprintf('✗ Failed to extract Simscape Results Explorer data: %s\n', ME.message);
end

fprintf('\n=== Test data extraction complete ===\n');
fprintf('Files created (if data present):\n');
fprintf('  test_logsout.csv, test_logsout.mat\n');
fprintf('  test_signal_logs.csv, test_signal_logs.mat\n');
fprintf('  test_simscape_data.csv, test_simscape_data.mat\n');

%% Restore workspace
restoreWorkspace(initial_vars); 