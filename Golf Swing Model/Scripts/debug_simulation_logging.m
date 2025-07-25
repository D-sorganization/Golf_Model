% debug_simulation_logging.m
% Debug script to test simulation with proper logging configuration

clear; clc;

fprintf('=== Debugging Simulation Logging ===\n\n');

model_name = 'GolfSwing3D_Kinetic';

% Load the model
try
    load_system(model_name);
    fprintf('✓ Model loaded: %s\n', model_name);
catch ME
    fprintf('✗ Failed to load model: %s\n', ME.message);
    return;
end

% Test configuration
config = struct();
config.model_name = model_name;
config.simulation_time = 0.1; % Short simulation for testing
config.sample_rate = 100;
config.modeling_mode = 3;
config.torque_scenario = 1; % Variable torques
config.coeff_range = 0.1;
config.constant_value = 1.0;
config.use_model_workspace = true;
config.use_logsout = true;
config.use_signal_bus = true;
config.use_simscape = true;

fprintf('Configuration:\n');
fprintf('  Simulation time: %.1f seconds\n', config.simulation_time);
fprintf('  Modeling mode: %d\n', config.modeling_mode);
fprintf('  Torque scenario: %d\n', config.torque_scenario);

% Test 1: Check current model logging settings
fprintf('\n--- Test 1: Check Model Logging Settings ---\n');
try
    fprintf('Current model parameters:\n');
    fprintf('  SignalLogging: %s\n', get_param(model_name, 'SignalLogging'));
    fprintf('  SignalLoggingName: %s\n', get_param(model_name, 'SignalLoggingName'));
    fprintf('  SignalLoggingSaveFormat: %s\n', get_param(model_name, 'SignalLoggingSaveFormat'));
    
    % Check for ToWorkspace blocks
    to_workspace_blocks = find_system(model_name, 'BlockType', 'ToWorkspace');
    fprintf('  ToWorkspace blocks: %d\n', length(to_workspace_blocks));
    
    fprintf('  ToWorkspace block details:\n');
    for i = 1:length(to_workspace_blocks)
        block_name = to_workspace_blocks{i};
        var_name = get_param(block_name, 'VariableName');
        save_format = get_param(block_name, 'SaveFormat');
        fprintf('    %d: %s -> %s (%s)\n', i, block_name, var_name, save_format);
    end
    
catch ME
    fprintf('✗ Error checking logging settings: %s\n', ME.message);
end

% Test 2: Generate polynomial coefficients
fprintf('\n--- Test 2: Generate Polynomial Coefficients ---\n');
try
    polynomial_coeffs = generatePolynomialCoefficients(config);
    fprintf('✓ Generated %d polynomial coefficients\n', length(fieldnames(polynomial_coeffs)));
    
    % Show a few sample coefficients
    coeff_names = fieldnames(polynomial_coeffs);
    for i = 1:min(3, length(coeff_names))
        fprintf('  %s = %.4f\n', coeff_names{i}, polynomial_coeffs.(coeff_names{i}));
    end
    
catch ME
    fprintf('✗ Failed to generate coefficients: %s\n', ME.message);
    return;
end

% Test 3: Create simulation input with enhanced logging
fprintf('\n--- Test 3: Create Enhanced Simulation Input ---\n');
try
    simInput = Simulink.SimulationInput(model_name);
    simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));
    
    % Set modeling mode properly
    modeling_mode_param = Simulink.Parameter(config.modeling_mode);
    simInput = simInput.setVariable('ModelingMode', modeling_mode_param);
    
    % Set polynomial coefficients
    simInput = setPolynomialVariables(simInput, polynomial_coeffs);
    
    % Enhanced logging configuration
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    simInput = simInput.setModelParameter('SaveOutput', 'on');
    simInput = simInput.setModelParameter('SaveState', 'on');
    simInput = simInput.setModelParameter('SaveFormat', 'Dataset');
    
    fprintf('✓ Created enhanced simulation input\n');
    
catch ME
    fprintf('✗ Failed to create simulation input: %s\n', ME.message);
    return;
end

% Test 4: Run simulation with enhanced logging
fprintf('\n--- Test 4: Run Enhanced Simulation ---\n');
try
    fprintf('Running simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Simulation completed\n');
    
    % Check simulation output
    fprintf('  Simulation output fields:\n');
    output_fields = fieldnames(simOut);
    for i = 1:length(output_fields)
        fprintf('    - %s\n', output_fields{i});
    end
    
    % Check for errors
    if isfield(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
        fprintf('  ⚠ Simulation error: %s\n', simOut.ErrorMessage);
    end
    
    % Check time vector
    if isfield(simOut, 'tout')
        fprintf('  Time vector length: %d\n', length(simOut.tout));
        if ~isempty(simOut.tout)
            fprintf('  Time range: %.3f to %.3f seconds\n', simOut.tout(1), simOut.tout(end));
        end
    else
        fprintf('  ⚠ No time vector (tout) found\n');
    end
    
    % Check logsout
    if isfield(simOut, 'logsout')
        fprintf('  Logsout available: ✓\n');
        if ~isempty(simOut.logsout)
            fprintf('  Logsout elements: %d\n', simOut.logsout.numElements);
            
            % List some signal names
            fprintf('  Sample signal names:\n');
            for i = 1:min(5, simOut.logsout.numElements)
                try
                    element = simOut.logsout.getElement(i);
                    fprintf('    %d: %s\n', i, element.Name);
                catch
                    fprintf('    %d: <error getting name>\n', i);
                end
            end
        else
            fprintf('  ⚠ Logsout is empty\n');
        end
    else
        fprintf('  ⚠ No logsout found\n');
    end
    
    % Check for ToWorkspace variables in base workspace
    fprintf('\n  Checking base workspace for ToWorkspace variables:\n');
    base_vars = who;
    to_workspace_vars = {};
    for i = 1:length(base_vars)
        var_name = base_vars{i};
        if contains(var_name, 'Logs') || contains(var_name, 'Data')
            to_workspace_vars{end+1} = var_name;
        end
    end
    
    if ~isempty(to_workspace_vars)
        fprintf('  Found ToWorkspace variables:\n');
        for i = 1:length(to_workspace_vars)
            var_name = to_workspace_vars{i};
            var_data = eval(var_name);
            if isstruct(var_data)
                fprintf('    %s: struct with fields: %s\n', var_name, strjoin(fieldnames(var_data), ', '));
            else
                fprintf('    %s: %s\n', var_name, class(var_data));
            end
        end
    else
        fprintf('  ⚠ No ToWorkspace variables found in base workspace\n');
    end
    
    % Check for signal bus data
    signal_bus_fields = {'ClubData', 'HandData', 'JointData', 'BodyData', 'Club', 'Hand', 'Joint', 'Body'};
    for i = 1:length(signal_bus_fields)
        field_name = signal_bus_fields{i};
        if isfield(simOut, field_name)
            fprintf('  Signal bus %s: ✓\n', field_name);
        end
    end
    
    % Check for any other data fields
    data_fields = {'yout', 'xout', 'simout', 'simulation_data'};
    for i = 1:length(data_fields)
        field_name = data_fields{i};
        if isfield(simOut, field_name)
            fprintf('  Data field %s: ✓\n', field_name);
        end
    end
    
catch ME
    fprintf('✗ Enhanced simulation failed: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
    return;
end

% Test 5: Check Simscape Results Explorer
fprintf('\n--- Test 5: Check Simscape Results Explorer ---\n');
try
    simscapeRuns = Simulink.sdi.getAllRunIDs;
    if ~isempty(simscapeRuns)
        fprintf('✓ Found %d Simscape runs\n', length(simscapeRuns));
        
        % Get the most recent run
        latestRun = simscapeRuns(end);
        runObj = Simulink.sdi.getRun(latestRun);
        
        fprintf('Latest run: %s (ID: %d)\n', runObj.Name, latestRun);
        
        % Get all signals from the run
        signals = runObj.getAllSignals;
        fprintf('Total Simscape signals: %d\n', length(signals));
        
        if length(signals) > 0
            fprintf('Sample Simscape signals:\n');
            for i = 1:min(10, length(signals))
                signal = signals(i);
                fprintf('  %d: %s\n', i, signal.Name);
            end
            
            % Check for specific signal categories
            fprintf('\n  Signal categories:\n');
            joint_signals = {};
            club_signals = {};
            hand_signals = {};
            
            for i = 1:length(signals)
                signal = signals(i);
                signal_name = signal.Name;
                
                if contains(signal_name, 'Joint') || contains(signal_name, 'q') || contains(signal_name, 'qd') || contains(signal_name, 'qdd')
                    joint_signals{end+1} = signal_name;
                elseif contains(signal_name, 'Club')
                    club_signals{end+1} = signal_name;
                elseif contains(signal_name, 'Hand')
                    hand_signals{end+1} = signal_name;
                end
            end
            
            fprintf('    Joint-related signals: %d\n', length(joint_signals));
            fprintf('    Club-related signals: %d\n', length(club_signals));
            fprintf('    Hand-related signals: %d\n', length(hand_signals));
        end
    else
        fprintf('⚠ No Simscape runs found\n');
    end
    
catch ME
    fprintf('✗ Error checking Simscape Results: %s\n', ME.message);
end

% Test 6: Try data extraction
fprintf('\n--- Test 6: Try Data Extraction ---\n');
try
    [trial_data, signal_names] = extractCompleteTrialData(simOut, 1, config);
    
    if ~isempty(trial_data)
        fprintf('✓ Data extraction successful\n');
        fprintf('  Data matrix size: %dx%d\n', size(trial_data, 1), size(trial_data, 2));
        fprintf('  Number of signals: %d\n', length(signal_names));
        
        % Show first few signal names
        fprintf('  First 10 signal names:\n');
        for i = 1:min(10, length(signal_names))
            fprintf('    %d: %s\n', i, signal_names{i});
        end
        
    else
        fprintf('✗ No data extracted\n');
        
        % Try individual extraction methods
        fprintf('\n  Testing individual extraction methods:\n');
        
        % Test logsout extraction
        if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
            try
                [test_data, test_names] = extractLogsoutData(simOut, zeros(11, 0), {'time'}, 0:0.01:0.1);
                fprintf('    Logsout: %d columns extracted\n', size(test_data, 2));
            catch ME
                fprintf('    Logsout error: %s\n', ME.message);
            end
        end
        
        % Test model workspace extraction
        try
            [test_data, test_names] = extractModelWorkspaceData(model_name, zeros(11, 0), {'time'}, 11);
            fprintf('    Model workspace: %d columns extracted\n', size(test_data, 2));
        catch ME
            fprintf('    Model workspace error: %s\n', ME.message);
        end
        
        % Test Simscape extraction
        try
            [test_data, test_names] = extractSimscapeResultsData(simOut, zeros(11, 0), {'time'}, 0:0.01:0.1);
            fprintf('    Simscape: %d columns extracted\n', size(test_data, 2));
        catch ME
            fprintf('    Simscape error: %s\n', ME.message);
        end
    end
    
catch ME
    fprintf('✗ Data extraction failed: %s\n', ME.message);
end

% Cleanup
try
    close_system(model_name, 0);
    fprintf('\n✓ Model closed\n');
catch
    fprintf('\n⚠ Could not close model\n');
end

fprintf('\n=== Debug Complete ===\n'); 