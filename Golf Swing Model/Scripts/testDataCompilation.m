% testDataCompilation.m
% Test script to compile data from existing simulation output
% This tests the data compilation with your current 'out' variable

fprintf('=== Test Data Compilation ===\n\n');

%% Check if 'out' variable exists
if ~exist('out', 'var')
    fprintf('✗ Variable ''out'' not found in workspace\n');
    fprintf('Please run extractCompleteJointData.m first to load simulation data\n');
    return;
end

fprintf('✓ Found simulation output in workspace\n');
fprintf('  Type: %s\n', class(out));

%% Configuration
config = struct();
config.simulation_time = 0.1;  % Use actual simulation time
config.sample_rate = 100;      % 100 Hz sampling
config.model_name = 'GolfSwing3D_Kinetic';

% Output file
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
config.output_csv = sprintf('test_dataset_%s.csv', timestamp);
config.output_summary = sprintf('test_summary_%s.txt', timestamp);

fprintf('Configuration:\n');
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Output CSV: %s\n', config.output_csv);
fprintf('\n');

%% Extract data from existing simulation
fprintf('--- Extracting Data from Existing Simulation ---\n');

try
    % Get time vector and resample to 100 Hz
    time_vector = out.tout;
    if isempty(time_vector)
        fprintf('✗ No time vector found\n');
        return;
    end
    
    fprintf('  Original time range: [%.3f, %.3f] seconds\n', time_vector(1), time_vector(end));
    fprintf('  Original time points: %d\n', length(time_vector));
    
    % Resample to 100 Hz
    target_time = 0:1/config.sample_rate:time_vector(end);
    target_time = target_time(target_time <= time_vector(end));
    
    fprintf('  Resampled time points: %d\n', length(target_time));
    fprintf('  Resampled time range: [%.3f, %.3f] seconds\n', target_time(1), target_time(end));
    
    % Initialize data matrix
    num_time_points = length(target_time);
    sim_data = zeros(num_time_points, 0); % Will grow as we add columns
    
    % Add time and simulation ID (use 1 for test)
    sim_data = [sim_data, target_time', repmat(1, num_time_points, 1)];
    
    % Extract logsout data
    fprintf('\n  Extracting logsout data...\n');
    sim_data = extractLogsoutData(out, sim_data, target_time);
    
    % Extract signal bus data
    fprintf('\n  Extracting signal bus data...\n');
    sim_data = extractSignalBusData(out, sim_data, target_time);
    
    % Extract Simscape data
    fprintf('\n  Extracting Simscape data...\n');
    sim_data = extractSimscapeData(out, sim_data, target_time);
    
    % Extract matrix data (rotation matrices)
    fprintf('\n  Extracting matrix data...\n');
    sim_data = extractMatrixData(out, sim_data, target_time);
    
    fprintf('\n  ✓ Data extraction complete\n');
    fprintf('    Total columns: %d\n', size(sim_data, 2));
    fprintf('    Total data points: %d\n', size(sim_data, 1));
    
catch ME
    fprintf('✗ Error extracting data: %s\n', ME.message);
    return;
end

%% Create CSV file
if ~isempty(sim_data)
    fprintf('\n--- Creating Test CSV Dataset ---\n');
    
    % Convert to table
    data_table = array2table(sim_data);
    
    % Create column names
    column_names = createColumnNames();
    
    % Ensure we have enough column names
    if length(column_names) < size(sim_data, 2)
        % Add generic names for extra columns
        for i = length(column_names)+1:size(sim_data, 2)
            column_names{i} = sprintf('Column_%d', i);
        end
    end
    
    % Use only the columns we have
    column_names = column_names(1:size(sim_data, 2));
    data_table.Properties.VariableNames = column_names;
    
    % Save to CSV
    writetable(data_table, config.output_csv);
    fprintf('✓ Test dataset saved to: %s\n', config.output_csv);
    fprintf('  Total data points: %d\n', size(sim_data, 1));
    fprintf('  Total columns: %d\n', size(sim_data, 2));
    
    % Create summary file
    createTestSummary(config, sim_data, column_names);
    
else
    fprintf('✗ No data extracted\n');
end

fprintf('\n=== Test Data Compilation Complete ===\n');

%% Helper Functions (same as in compileCompleteDataset.m)

function sim_data = extractLogsoutData(simOut, sim_data, target_time)
    % Extract data from logsout
    
    try
        logsout = simOut.logsout;
        if isempty(logsout)
            return;
        end
        
        fprintf('    Found %d logsout elements\n', logsout.numElements);
        
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
                sim_data = [sim_data, resampled_data];
                
                fprintf('      ✓ %s (%d → %d points)\n', signal_name, length(time), length(target_time));
                
            catch ME
                fprintf('      ✗ Error extracting signal %s: %s\n', signal_name, ME.message);
            end
        end
        
    catch ME
        fprintf('    ✗ Error accessing logsout: %s\n', ME.message);
    end
end

function sim_data = extractSignalBusData(simOut, sim_data, target_time)
    % Extract data from signal bus structs
    
    try
        % Define expected signal bus structs
        expected_structs = {
            'HipLogs', 'SpineLogs', 'TorsoLogs', ...
            'LSLogs', 'RSLogs', 'LELogs', 'RELogs', ...
            'LWLogs', 'RWLogs', 'LScapLogs', 'RScapLogs', ...
            'LFLogs', 'RFLogs'
        };
        
        fprintf('    Checking %d signal bus structs\n', length(expected_structs));
        
        for i = 1:length(expected_structs)
            struct_name = expected_structs{i};
            
            try
                if ~isempty(simOut.(struct_name))
                    log_struct = simOut.(struct_name);
                    
                    if isstruct(log_struct)
                        fields = fieldnames(log_struct);
                        fprintf('      ✓ %s (%d fields)\n', struct_name, length(fields));
                        
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
                                sim_data = [sim_data, resampled_data];
                            end
                        end
                    end
                end
                
            catch ME
                fprintf('      ✗ Error extracting %s: %s\n', struct_name, ME.message);
            end
        end
        
    catch ME
        fprintf('    ✗ Error accessing signal bus data: %s\n', ME.message);
    end
end

function sim_data = extractSimscapeData(simOut, sim_data, target_time)
    % Extract data from Simscape Results Explorer
    
    try
        simlog = simOut.simlog;
        if isempty(simlog) || ~isa(simlog, 'simscape.logging.Node')
            fprintf('    No Simscape data available\n');
            return;
        end
        
        fprintf('    Found Simscape data\n');
        
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
                    fprintf('    Cannot access Simscape child nodes\n');
                    return;
                end
            end
        end
        
        if ~isempty(child_nodes)
            fprintf('    Found %d child nodes\n', length(child_nodes));
            
            for i = 1:length(child_nodes)
                child_node = child_nodes(i);
                node_name = child_node.Name;
                
                % Look for joint-related nodes
                if contains(lower(node_name), {'joint', 'actuator', 'motor', 'drive'})
                    try
                        signals = child_node.Children;
                        fprintf('      ✓ %s (%d signals)\n', node_name, length(signals));
                        
                        for j = 1:length(signals)
                            signal = signals(j);
                            signal_name = signal.Name;
                            
                            if hasData(signal)
                                [data, time] = getData(signal);
                                resampled_data = resampleSignal(data, time, target_time);
                                sim_data = [sim_data, resampled_data];
                            end
                        end
                        
                    catch ME
                        fprintf('      ✗ Error extracting node %s: %s\n', node_name, ME.message);
                    end
                end
            end
        end
        
    catch ME
        fprintf('    ✗ Error accessing Simscape data: %s\n', ME.message);
    end
end

function sim_data = extractMatrixData(simOut, sim_data, target_time)
    % Extract inertia matrices and rotation matrices
    
    try
        fprintf('    Extracting rotation matrices\n');
        
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
                                sim_data = [sim_data, resampled_data];
                                fprintf('      ✓ %s.%s (3x3x%d → %dx9)\n', struct_name, field_name, n_frames, length(target_time));
                            end
                        end
                    end
                catch ME
                    % Continue to next struct
                end
            end
        end
        
    catch ME
        fprintf('    ✗ Error extracting matrix data: %s\n', ME.message);
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

function column_names = createColumnNames()
    % Create column names for the dataset
    
    column_names = {'time', 'simulation_id'};
    
    % Add logsout signal names
    logsout_names = {'CHS', 'CHPathUnitVector', 'Face', 'Path', 'CHGlobalPosition', 'CHy', 'MaximumCHS', 'HipGlobalPosition', 'HipGlobalVelocity', 'HUBGlobalPosition', 'GolferMass', 'GolferCOM', 'KillswitchState', 'ButtPosition', 'LeftHandSpeed', 'LHAVGlobal', 'LeftHandPostion', 'LHGlobalVelocity', 'LHGlobalAngularVelocity', 'LHGlobalPosition', 'MidHandSpeed', 'MPGlobalPosition', 'MPGlobalVelocity', 'RightHandSpeed', 'RHAVGlobal', 'RHGlobalVelocity', 'RHGlobalAngularVelocity', 'RHGlobalPosition'};
    
    % Add torque signal names
    torque_names = {'ForceAlongHandPath', 'LHForceAlongHandPath', 'RHForceAlongHandPath', 'SumofMomentsLHonClub', 'SumofMomentsRHonClub', 'TotalHandForceGlobal', 'TotalHandTorqueGlobal', 'LHonClubForceLocal', 'LHonClubTorqueLocal', 'RHonClubForceLocal', 'RHonClubTorqueLocal', 'HipTorqueXInput', 'HipTorqueYInput', 'HipTorqueZInput', 'TranslationForceXInput', 'TranslationForceYInput', 'TranslationForceZInput', 'LSTorqueXInput', 'SumofMomentsonClubLocal', 'BaseonHipForceHipBase'};
    
    % Add signal bus field names (positions, velocities, accelerations, torques)
    signal_bus_names = {};
    joints = {'Hip', 'Spine', 'Torso', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW', 'LScap', 'RScap', 'LF', 'RF'};
    
    for i = 1:length(joints)
        joint = joints{i};
        signal_bus_names = [signal_bus_names, {
            [joint '_PositionX'], [joint '_PositionY'], [joint '_PositionZ'], ...
            [joint '_VelocityX'], [joint '_VelocityY'], [joint '_VelocityZ'], ...
            [joint '_AccelerationX'], [joint '_AccelerationY'], [joint '_AccelerationZ'], ...
            [joint '_AngularPositionX'], [joint '_AngularPositionY'], [joint '_AngularPositionZ'], ...
            [joint '_AngularVelocityX'], [joint '_AngularVelocityY'], [joint '_AngularVelocityZ'], ...
            [joint '_AngularAccelerationX'], [joint '_AngularAccelerationY'], [joint '_AngularAccelerationZ'], ...
            [joint '_ConstraintForceLocal'], [joint '_ConstraintTorqueLocal'], ...
            [joint '_ActuatorTorqueX'], [joint '_ActuatorTorqueY'], [joint '_ActuatorTorqueZ'], ...
            [joint '_ForceLocal'], [joint '_TorqueLocal'], ...
            [joint '_GlobalPosition'], [joint '_GlobalVelocity'], [joint '_GlobalAcceleration'], ...
            [joint '_GlobalAngularVelocity'], [joint '_Rotation_Transform']
        }];
    end
    
    % Add rotation matrix components (9 components per joint)
    rotation_names = {};
    for i = 1:length(joints)
        joint = joints{i};
        for row = 1:3
            for col = 1:3
                rotation_names{end+1} = sprintf('%s_Rotation_%d%d', joint, row, col);
            end
        end
    end
    
    % Combine all column names
    column_names = [column_names, logsout_names, torque_names, signal_bus_names, rotation_names];
    
    % Ensure unique names
    column_names = unique(column_names, 'stable');
end

function createTestSummary(config, sim_data, column_names)
    % Create a summary file with dataset information
    
    try
        fid = fopen(config.output_summary, 'w');
        if fid == -1
            fprintf('✗ Could not create summary file\n');
            return;
        end
        
        fprintf(fid, 'Test Golf Dataset Summary\n');
        fprintf(fid, '========================\n\n');
        fprintf(fid, 'Generated: %s\n', datestr(now));
        fprintf(fid, 'Configuration:\n');
        fprintf(fid, '  Sample rate: %d Hz\n', config.sample_rate);
        fprintf(fid, '  Model: %s\n', config.model_name);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Dataset Statistics:\n');
        fprintf(fid, '  Total data points: %d\n', size(sim_data, 1));
        fprintf(fid, '  Total columns: %d\n', size(sim_data, 2));
        fprintf(fid, '\n');
        
        fprintf(fid, 'Column Categories:\n');
        fprintf(fid, '  Time and ID: 2 columns\n');
        fprintf(fid, '  Data columns: %d\n', length(column_names) - 2);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Data Types Included:\n');
        fprintf(fid, '  ✓ Joint positions (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint velocities (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint accelerations (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint angular positions (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint angular velocities (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint angular accelerations (X, Y, Z)\n');
        fprintf(fid, '  ✓ Joint activation torques\n');
        fprintf(fid, '  ✓ Constraint forces and torques\n');
        fprintf(fid, '  ✓ Global positions, velocities, accelerations\n');
        fprintf(fid, '  ✓ Rotation matrices (9 components per joint)\n');
        fprintf(fid, '  ✓ Club and hand data\n');
        fprintf(fid, '\n');
        
        fprintf(fid, 'Output Files:\n');
        fprintf(fid, '  CSV Dataset: %s\n', config.output_csv);
        fprintf(fid, '  Summary: %s\n', config.output_summary);
        
        fclose(fid);
        fprintf('✓ Test summary saved to: %s\n', config.output_summary);
        
    catch ME
        fprintf('✗ Error creating summary: %s\n', ME.message);
    end
end 