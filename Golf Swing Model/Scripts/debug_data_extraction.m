% debug_data_extraction.m
% Debug script to test data extraction functions and identify issues

clear; clc;

fprintf('=== Debugging Data Extraction ===\n\n');

% Test configuration
config = struct();
config.model_name = 'GolfSwing3D_Kinetic';
config.simulation_time = 0.3;
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
fprintf('  Model: %s\n', config.model_name);
fprintf('  Simulation time: %.1f seconds\n', config.simulation_time);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Modeling mode: %d\n', config.modeling_mode);
fprintf('  Torque scenario: %d\n', config.torque_scenario);
fprintf('  Data sources: ModelWorkspace=%d, Logsout=%d, SignalBus=%d, Simscape=%d\n', ...
    config.use_model_workspace, config.use_logsout, config.use_signal_bus, config.use_simscape);

% Test 1: Generate polynomial coefficients
fprintf('\n--- Test 1: Generate Polynomial Coefficients ---\n');
try
    polynomial_coeffs = generatePolynomialCoefficients(config);
    fprintf('✓ Generated polynomial coefficients successfully\n');
    fprintf('  Number of coefficients: %d\n', length(fieldnames(polynomial_coeffs)));
    
    % Show a few sample coefficients
    coeff_names = fieldnames(polynomial_coeffs);
    for i = 1:min(5, length(coeff_names))
        fprintf('  %s = %.4f\n', coeff_names{i}, polynomial_coeffs.(coeff_names{i}));
    end
    
catch ME
    fprintf('✗ Failed to generate polynomial coefficients: %s\n', ME.message);
    return;
end

% Test 2: Create simulation input
fprintf('\n--- Test 2: Create Simulation Input ---\n');
try
    simInput = Simulink.SimulationInput(config.model_name);
    simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));
    simInput = simInput.setVariable('ModelingMode', Simulink.Parameter(config.modeling_mode));
    simInput = setPolynomialVariables(simInput, polynomial_coeffs);
    
    % Configure logging
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    fprintf('✓ Created simulation input successfully\n');
    
catch ME
    fprintf('✗ Failed to create simulation input: %s\n', ME.message);
    return;
end

% Test 3: Run simulation
fprintf('\n--- Test 3: Run Simulation ---\n');
try
    fprintf('Running simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Simulation completed successfully\n');
    
    % Check simulation output
    fprintf('  Simulation output fields:\n');
    output_fields = fieldnames(simOut);
    for i = 1:length(output_fields)
        fprintf('    - %s\n', output_fields{i});
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
        else
            fprintf('  ⚠ Logsout is empty\n');
        end
    else
        fprintf('  ⚠ No logsout found\n');
    end
    
    % Check signal bus data
    signal_bus_fields = {'ClubData', 'HandData', 'JointData', 'BodyData'};
    for i = 1:length(signal_bus_fields)
        field_name = signal_bus_fields{i};
        if isfield(simOut, field_name)
            fprintf('  Signal bus %s: ✓\n', field_name);
        else
            fprintf('  Signal bus %s: ✗\n', field_name);
        end
    end
    
catch ME
    fprintf('✗ Simulation failed: %s\n', ME.message);
    return;
end

% Test 4: Extract data
fprintf('\n--- Test 4: Extract Data ---\n');
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
        
        if length(signal_names) > 10
            fprintf('    ... and %d more signals\n', length(signal_names) - 10);
        end
        
    else
        fprintf('✗ No data extracted\n');
        fprintf('  This is the issue we need to debug\n');
        
        % Debug each data source individually
        fprintf('\n--- Debugging Individual Data Sources ---\n');
        
        % Test model workspace extraction
        if config.use_model_workspace
            fprintf('\nTesting Model Workspace extraction...\n');
            try
                [test_data, test_names] = extractModelWorkspaceData(config.model_name, zeros(31, 0), {'time'}, 31);
                fprintf('  Model workspace: %d columns extracted\n', size(test_data, 2));
            catch ME
                fprintf('  Model workspace error: %s\n', ME.message);
            end
        end
        
        % Test logsout extraction
        if config.use_logsout && isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
            fprintf('\nTesting Logsout extraction...\n');
            try
                [test_data, test_names] = extractLogsoutData(simOut, zeros(31, 0), {'time'}, 0:0.01:0.3);
                fprintf('  Logsout: %d columns extracted\n', size(test_data, 2));
            catch ME
                fprintf('  Logsout error: %s\n', ME.message);
            end
        end
        
        % Test signal bus extraction
        if config.use_signal_bus
            fprintf('\nTesting Signal Bus extraction...\n');
            try
                [test_data, test_names] = extractSignalLogStructs(simOut, zeros(31, 0), {'time'}, 0:0.01:0.3);
                fprintf('  Signal bus: %d columns extracted\n', size(test_data, 2));
            catch ME
                fprintf('  Signal bus error: %s\n', ME.message);
            end
        end
        
        % Test simscape extraction
        if config.use_simscape
            fprintf('\nTesting Simscape extraction...\n');
            try
                [test_data, test_names] = extractSimscapeResultsData(simOut, zeros(31, 0), {'time'}, 0:0.01:0.3);
                fprintf('  Simscape: %d columns extracted\n', size(test_data, 2));
            catch ME
                fprintf('  Simscape error: %s\n', ME.message);
            end
        end
    end
    
catch ME
    fprintf('✗ Data extraction failed: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

fprintf('\n=== Debug Complete ===\n'); 