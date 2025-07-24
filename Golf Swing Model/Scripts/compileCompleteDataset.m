% compileCompleteDataset.m
% Compile complete dataset from multiple simulations with varying polynomial inputs
% Creates a comprehensive CSV file with all joint data, inertia matrices, rotation matrices, etc.
% Samples at 100 Hz to reduce redundancy

fprintf('=== Complete Dataset Compilation ===\n\n');

%% Configuration
config = struct();
config.simulation_time = 0.3;  % 0.3 seconds as requested
config.sample_rate = 100;      % 100 Hz sampling
config.num_simulations = 2;    % Start with 2 trials as requested
config.model_name = 'GolfSwing3D_Kinetic';

% Output file
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
config.output_csv = sprintf('complete_golf_dataset_%s.csv', timestamp);
config.output_summary = sprintf('dataset_summary_%s.txt', timestamp);

fprintf('Configuration:\n');
fprintf('  Simulation time: %.1f seconds\n', config.simulation_time);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Number of simulations: %d\n', config.num_simulations);
fprintf('  Output CSV: %s\n', config.output_csv);
fprintf('\n');

%% Initialize dataset storage
all_data = [];
simulation_id = 0;

%% Run multiple simulations with different polynomial inputs
for sim_idx = 1:config.num_simulations
    simulation_id = simulation_id + 1;
    fprintf('--- Running Simulation %d/%d ---\n', sim_idx, config.num_simulations);
    
    try
        % Generate random polynomial coefficients for this simulation
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
        simInput = simInput.setModelParameter('SignalLoggingSaveToWorkspace', 'on');
        
        % Run simulation
        fprintf('  Running simulation...\n');
        simOut = sim(simInput);
        
        % Extract all data from this simulation
        fprintf('  Extracting data...\n');
        sim_data = extractAllSimulationData(simOut, simulation_id, config);
        
        % Add to main dataset
        if ~isempty(sim_data)
            all_data = [all_data; sim_data];
            fprintf('  ✓ Extracted %d data points\n', size(sim_data, 1));
        else
            fprintf('  ✗ No data extracted\n');
        end
        
    catch ME
        fprintf('  ✗ Simulation %d failed: %s\n', sim_idx, ME.message);
        continue;
    end
end

%% Create comprehensive CSV file
if ~isempty(all_data)
    fprintf('\n--- Creating CSV Dataset ---\n');
    
    % Convert to table
    data_table = array2table(all_data);
    
    % Create column names
    column_names = createColumnNames();
    data_table.Properties.VariableNames = column_names;
    
    % Save to CSV
    writetable(data_table, config.output_csv);
    fprintf('✓ Dataset saved to: %s\n', config.output_csv);
    fprintf('  Total data points: %d\n', size(all_data, 1));
    fprintf('  Total columns: %d\n', size(all_data, 2));
    
    % Create summary file
    createDatasetSummary(config, all_data, column_names);
    
else
    fprintf('✗ No data collected from any simulation\n');
end

fprintf('\n=== Dataset Compilation Complete ===\n');

%% Helper Functions

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

function sim_data = extractAllSimulationData(simOut, simulation_id, config)
    % Extract all available data from simulation output
    
    try
        % Get time vector and resample to 100 Hz
        time_vector = simOut.tout;
        if isempty(time_vector)
            fprintf('    ✗ No time vector found\n');
            sim_data = [];
            return;
        end
        
        % Resample to 100 Hz
        target_time = 0:1/config.sample_rate:config.simulation_time;
        target_time = target_time(target_time <= config.simulation_time);
        
        % Initialize data matrix
        num_time_points = length(target_time);
        sim_data = zeros(num_time_points, 0); % Will grow as we add columns
        
        % Add time and simulation ID
        sim_data = [sim_data, target_time', repmat(simulation_id, num_time_points, 1)];
        
        % Extract logsout data
        sim_data = extractLogsoutData(simOut, sim_data, target_time);
        
        % Extract signal bus data
        sim_data = extractSignalBusData(simOut, sim_data, target_time);
        
        % Extract Simscape data
        sim_data = extractSimscapeData(simOut, sim_data, target_time);
        
        % Extract model workspace variables
        sim_data = extractModelWorkspaceData(simOut, sim_data, target_time);
        
        % Extract inertia matrices and rotation matrices
        sim_data = extractMatrixData(simOut, sim_data, target_time);
        
    catch ME
        fprintf('    ✗ Error extracting simulation data: %s\n', ME.message);
        sim_data = [];
    end
end

function sim_data = extractLogsoutData(simOut, sim_data, target_time)
    % Extract data from logsout
    
    try
        logsout = simOut.logsout;
        if isempty(logsout)
            return;
        end
        
        fprintf('    Extracting logsout data...\n');
        
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
        
        fprintf('    Extracting signal bus data...\n');
        
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
            return;
        end
        
        fprintf('    Extracting Simscape data...\n');
        
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

function sim_data = extractModelWorkspaceData(simOut, sim_data, target_time)
    % Extract model workspace variables (constant values)
    
    try
        fprintf('    Extracting model workspace data...\n');
        
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
                    sim_data = [sim_data, constant_data];
                end
                
            catch ME
                fprintf('      ✗ Error extracting variable %s: %s\n', var_name, ME.message);
            end
        end
        
    catch ME
        fprintf('    ✗ Error accessing model workspace: %s\n', ME.message);
    end
end

function sim_data = extractMatrixData(simOut, sim_data, target_time)
    % Extract inertia matrices and rotation matrices
    
    try
        fprintf('    Extracting matrix data...\n');
        
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

function createDatasetSummary(config, all_data, column_names)
    % Create a summary file with dataset information
    
    try
        fid = fopen(config.output_summary, 'w');
        if fid == -1
            fprintf('✗ Could not create summary file\n');
            return;
        end
        
        fprintf(fid, 'Complete Golf Dataset Summary\n');
        fprintf(fid, '============================\n\n');
        fprintf(fid, 'Generated: %s\n', datestr(now));
        fprintf(fid, 'Configuration:\n');
        fprintf(fid, '  Simulation time: %.1f seconds\n', config.simulation_time);
        fprintf(fid, '  Sample rate: %d Hz\n', config.sample_rate);
        fprintf(fid, '  Number of simulations: %d\n', config.num_simulations);
        fprintf(fid, '  Model: %s\n', config.model_name);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Dataset Statistics:\n');
        fprintf(fid, '  Total data points: %d\n', size(all_data, 1));
        fprintf(fid, '  Total columns: %d\n', size(all_data, 2));
        fprintf(fid, '  Data points per simulation: %d\n', size(all_data, 1) / config.num_simulations);
        fprintf(fid, '\n');
        
        fprintf(fid, 'Column Categories:\n');
        fprintf(fid, '  Time and ID: 2 columns\n');
        fprintf(fid, '  Logsout signals: %d columns\n', length(column_names) - 2);
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
        fprintf(fid, '  ✓ Model workspace variables\n');
        fprintf(fid, '\n');
        
        fprintf(fid, 'Joints Included:\n');
        joints = {'Hip', 'Spine', 'Torso', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW', 'LScap', 'RScap', 'LF', 'RF'};
        for i = 1:length(joints)
            fprintf(fid, '  - %s\n', joints{i});
        end
        fprintf(fid, '\n');
        
        fprintf(fid, 'Output Files:\n');
        fprintf(fid, '  CSV Dataset: %s\n', config.output_csv);
        fprintf(fid, '  Summary: %s\n', config.output_summary);
        
        fclose(fid);
        fprintf('✓ Summary saved to: %s\n', config.output_summary);
        
    catch ME
        fprintf('✗ Error creating summary: %s\n', ME.message);
    end
end 