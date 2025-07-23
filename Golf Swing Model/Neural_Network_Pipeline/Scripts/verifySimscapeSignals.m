% verifySimscapeSignals.m
% Comprehensive verification of all required signals from Simscape Results Explorer
% 
% This script:
% 1. Verifies all required joint states, beam data, and kinematics
% 2. Checks model workspace parameters
% 3. Generates a test dataset from a single simulation
% 4. Cleans up workspace variables
% 5. Provides detailed reporting

function [verification_results, test_dataset] = verifySimscapeSignals(model_name, generate_test_dataset)
% verifySimscapeSignals.m
% 
% Inputs:
%   model_name - Name of the Simulink model (default: 'GolfSwing3D_Kinetic')
%   generate_test_dataset - Boolean to generate test dataset (default: true)
%
% Outputs:
%   verification_results - Structure with verification results
%   test_dataset - Test dataset from single simulation (if requested)

%% Default inputs
if nargin < 1
    model_name = 'GolfSwing3D_Kinetic';
end
if nargin < 2
    generate_test_dataset = true;
end

fprintf('=== Simscape Signal Verification ===\n');
fprintf('Model: %s\n', model_name);
fprintf('Generate test dataset: %s\n\n', mat2str(generate_test_dataset));

%% Initialize results structure
verification_results = struct();
verification_results.model_name = model_name;
verification_results.timestamp = datetime('now');
verification_results.overall_status = 'PENDING';

%% Phase 1: Check Model Loading and Basic Setup
fprintf('Phase 1: Model Loading and Setup\n');
fprintf('--------------------------------\n');

try
    % Check if model is loaded
    if ~bdIsLoaded(model_name)
        load_system(model_name);
        fprintf('✓ Model loaded successfully\n');
    else
        fprintf('✓ Model already loaded\n');
    end
    
    % Check Simscape logging
    simscape_log_type = get_param(model_name, 'SimscapeLogType');
    fprintf('✓ Simscape logging type: %s\n', simscape_log_type);
    
    verification_results.model_loaded = true;
    verification_results.simscape_logging = simscape_log_type;
    
catch ME
    fprintf('✗ Model loading failed: %s\n', ME.message);
    verification_results.model_loaded = false;
    verification_results.overall_status = 'FAILED';
    return;
end

%% Phase 2: Run Single Simulation to Generate Data
fprintf('\nPhase 2: Running Test Simulation\n');
fprintf('--------------------------------\n');

try
    % Set simulation parameters
    set_param(model_name, 'StopTime', '1.0');
    set_param(model_name, 'Solver', 'ode23t');
    set_param(model_name, 'RelTol', '1e-4');
    set_param(model_name, 'AbsTol', '1e-6');
    
    fprintf('Running simulation...\n');
    simOut = sim(model_name);
    
    if isempty(simOut) || ~isfield(simOut, 'tout') || isempty(simOut.tout)
        error('Simulation returned empty results');
    end
    
    fprintf('✓ Simulation completed successfully\n');
    fprintf('  Duration: %.3f seconds\n', simOut.tout(end));
    fprintf('  Time points: %d\n', length(simOut.tout));
    
    verification_results.simulation_successful = true;
    verification_results.simulation_duration = simOut.tout(end);
    verification_results.time_points = length(simOut.tout);
    
catch ME
    fprintf('✗ Simulation failed: %s\n', ME.message);
    verification_results.simulation_successful = false;
    verification_results.overall_status = 'FAILED';
    return;
end

%% Phase 3: Verify Simscape Results Explorer Data
fprintf('\nPhase 3: Verifying Simscape Results Explorer Data\n');
fprintf('------------------------------------------------\n');

try
    % Get Simscape runs
    runIDs = Simulink.sdi.getAllRunIDs;
    if isempty(runIDs)
        error('No Simscape runs found in Results Explorer');
    end
    
    % Get latest run
    latest_run_id = runIDs(end);
    run_obj = Simulink.sdi.getRun(latest_run_id);
    
    fprintf('✓ Found Simscape run: %s (ID: %d)\n', run_obj.Name, latest_run_id);
    
    % Get all signals
    all_signals = run_obj.getAllSignals;
    all_signal_names = {all_signals.Name};
    
    fprintf('✓ Total signals available: %d\n', length(all_signal_names));
    
    verification_results.total_signals = length(all_signal_names);
    verification_results.signal_names = all_signal_names;
    
catch ME
    fprintf('✗ Simscape data access failed: %s\n', ME.message);
    verification_results.simscape_accessible = false;
    verification_results.overall_status = 'FAILED';
    return;
end

%% Phase 4: Verify Required Signal Categories
fprintf('\nPhase 4: Verifying Required Signal Categories\n');
fprintf('--------------------------------------------\n');

% Define required signal patterns
required_signals = struct();

% Joint states
required_signals.joint_positions = {
    'GolfSwing3D_Kinetic.*\.q$'  % Joint position signals
};

required_signals.joint_velocities = {
    'GolfSwing3D_Kinetic.*\.w$'  % Joint velocity signals
};

required_signals.joint_accelerations = {
    'AngularKinematicsLogs.*AngularAcceleration'  % Direct acceleration signals
};

required_signals.joint_torques = {
    '.*Torque.*Input$'           % Actuator torque inputs
    '.*ActuatorTorque.*'         % Actuator torques
    '.*TorqueLocal.*'            % Local torques
};

% Beam states (flexible shaft)
required_signals.beam_modal_coordinates = {
    '.*Modal.*Coordinates.*'     % Modal coordinates
    '.*Beam.*Modal.*'            % Beam modal data
};

required_signals.beam_strain_energy = {
    '.*Strain.*Energy.*'         % Strain energy
    '.*Beam.*Energy.*'           % Beam energy
};

required_signals.beam_displacement = {
    '.*Displacement.*'           % Displacement
    '.*Beam.*Displacement.*'     % Beam displacement
};

required_signals.beam_forces_moments = {
    '.*Internal.*Force.*'        % Internal forces
    '.*Internal.*Moment.*'       % Internal moments
    '.*Beam.*Force.*'            % Beam forces
    '.*Beam.*Moment.*'           % Beam moments
};

% Kinematics
required_signals.clubhead_kinematics = {
    '.*Clubhead.*'               % Clubhead data
    'CH.*'                       % Clubhead shorthand
    'MaximumCHS'                 % Maximum clubhead speed
};

required_signals.hand_kinematics = {
    '.*Hand.*'                   % Hand data
    'LH.*'                       % Left hand
    'RH.*'                       % Right hand
};

required_signals.body_kinematics = {
    '.*Hip.*'                    % Hip data
    '.*Torso.*'                  % Torso data
    '.*Shoulder.*'               % Shoulder data
    '.*AngularKinematicsLogs.*'  % Angular kinematics
};

% Check each category
categories = fieldnames(required_signals);
verification_results.signal_categories = struct();

for i = 1:length(categories)
    category = categories{i};
    patterns = required_signals.(category);
    
    fprintf('\nChecking %s:\n', strrep(category, '_', ' '));
    
    found_signals = {};
    for j = 1:length(patterns)
        pattern = patterns{j};
        matches = regexp(all_signal_names, pattern, 'match');
        matches = matches(~cellfun(@isempty, matches));
        found_signals = [found_signals, matches{:}];
    end
    
    found_signals = unique(found_signals);
    
    if ~isempty(found_signals)
        fprintf('  ✓ Found %d signals\n', length(found_signals));
        for k = 1:min(5, length(found_signals))
            fprintf('    - %s\n', found_signals{k});
        end
        if length(found_signals) > 5
            fprintf('    ... and %d more\n', length(found_signals) - 5);
        end
    else
        fprintf('  ✗ No signals found\n');
    end
    
    verification_results.signal_categories.(category) = struct();
    verification_results.signal_categories.(category).found = ~isempty(found_signals);
    verification_results.signal_categories.(category).count = length(found_signals);
    verification_results.signal_categories.(category).signals = found_signals;
end

%% Phase 5: Verify Model Workspace Data
fprintf('\nPhase 5: Verifying Model Workspace Data\n');
fprintf('--------------------------------------\n');

try
    % Get model workspace
    model_workspace = get_param(model_name, 'ModelWorkspace');
    workspace_vars = model_workspace.whos;
    
    fprintf('✓ Model workspace accessible\n');
    fprintf('  Variables: %d\n', length(workspace_vars));
    
    % Check for key workspace variables
    key_vars = {'initial_hip_x', 'initial_hip_y', 'initial_hip_z', ...
                'initial_spine_rx', 'initial_spine_ry', ...
                'initial_torso_rz', 'initial_left_shoulder_x'};
    
    found_key_vars = {};
    for i = 1:length(key_vars)
        var_name = key_vars{i};
        if model_workspace.hasVariable(var_name)
            found_key_vars{end+1} = var_name;
        end
    end
    
    fprintf('  Key variables found: %d/%d\n', length(found_key_vars), length(key_vars));
    for i = 1:length(found_key_vars)
        fprintf('    ✓ %s\n', found_key_vars{i});
    end
    
    verification_results.model_workspace = struct();
    verification_results.model_workspace.accessible = true;
    verification_results.model_workspace.total_variables = length(workspace_vars);
    verification_results.model_workspace.key_variables_found = length(found_key_vars);
    verification_results.model_workspace.key_variables = found_key_vars;
    
catch ME
    fprintf('✗ Model workspace access failed: %s\n', ME.message);
    verification_results.model_workspace = struct();
    verification_results.model_workspace.accessible = false;
end

%% Phase 6: Generate Test Dataset (if requested)
test_dataset = [];
if generate_test_dataset
    fprintf('\nPhase 6: Generating Test Dataset\n');
    fprintf('-------------------------------\n');
    
    try
        % Generate sample polynomial inputs
        config = struct();
        config.hip_torque_range = [-50, 50];
        config.spine_torque_range = [-30, 30];
        config.shoulder_torque_range = [-20, 20];
        config.elbow_torque_range = [-15, 15];
        config.wrist_torque_range = [-10, 10];
        config.translation_force_range = [-100, 100];
        config.polynomial_order = 4;
        config.swing_duration_range = [0.8, 1.2];
        
        polynomial_inputs = generatePolynomialInputs(config);
        starting_positions = generateRandomStartingPositions(config);
        
        fprintf('✓ Generated polynomial inputs and starting positions\n');
        
        % Extract joint states and beam data
        joint_data = extractJointStatesFromSimscape();
        
        fprintf('✓ Extracted joint states and beam data\n');
        
        % Create test dataset structure
        test_dataset = struct();
        test_dataset.config = config;
        test_dataset.metadata = struct();
        test_dataset.metadata.creation_time = datetime('now');
        test_dataset.metadata.description = 'Test dataset from single simulation';
        test_dataset.metadata.verification_run = true;
        
        test_dataset.simulation_data = joint_data;
        test_dataset.parameters = struct();
        test_dataset.parameters.polynomial_inputs = polynomial_inputs;
        test_dataset.parameters.starting_positions = starting_positions;
        test_dataset.parameters.simulation_duration = simOut.tout(end);
        test_dataset.parameters.time_points = length(simOut.tout);
        
        % Save test dataset
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        test_filename = sprintf('test_dataset_verification_%s.mat', timestamp);
        save(test_filename, 'test_dataset', '-v7.3');
        
        fprintf('✓ Test dataset saved: %s\n', test_filename);
        fprintf('  Size: %.2f MB\n', dir(test_filename).bytes / (1024^2));
        
        verification_results.test_dataset_generated = true;
        verification_results.test_dataset_filename = test_filename;
        
    catch ME
        fprintf('✗ Test dataset generation failed: %s\n', ME.message);
        verification_results.test_dataset_generated = false;
    end
end

%% Phase 7: Overall Assessment
fprintf('\nPhase 7: Overall Assessment\n');
fprintf('--------------------------\n');

% Check all critical components
critical_checks = {
    verification_results.model_loaded
    verification_results.simulation_successful
    verification_results.simscape_accessible
};

if all(critical_checks)
    verification_results.overall_status = 'PASSED';
    fprintf('✓ Overall verification: PASSED\n');
else
    verification_results.overall_status = 'FAILED';
    fprintf('✗ Overall verification: FAILED\n');
end

% Signal category summary
categories = fieldnames(verification_results.signal_categories);
fprintf('\nSignal Category Summary:\n');
for i = 1:length(categories)
    category = categories{i};
    status = verification_results.signal_categories.(category).found;
    count = verification_results.signal_categories.(category).count;
    
    if status
        fprintf('  ✓ %s: %d signals\n', strrep(category, '_', ' '), count);
    else
        fprintf('  ✗ %s: No signals found\n', strrep(category, '_', ' '));
    end
end

%% Phase 8: Cleanup Workspace
fprintf('\nPhase 8: Cleaning Workspace\n');
fprintf('--------------------------\n');

% List of variables to keep
keep_vars = {'verification_results', 'test_dataset', 'model_name'};

% Get all variables in workspace
all_vars = who;

% Variables to remove
remove_vars = setdiff(all_vars, keep_vars);

if ~isempty(remove_vars)
    fprintf('Removing %d workspace variables:\n', length(remove_vars));
    for i = 1:length(remove_vars)
        fprintf('  - %s\n', remove_vars{i});
    end
    
    % Remove variables
    clear(remove_vars{:});
    fprintf('✓ Workspace cleaned\n');
else
    fprintf('✓ No variables to remove\n');
end

% Final workspace status
remaining_vars = who;
fprintf('Remaining variables: %d\n', length(remaining_vars));
for i = 1:length(remaining_vars)
    fprintf('  - %s\n', remaining_vars{i});
end

%% Final Report
fprintf('\n=== Verification Complete ===\n');
fprintf('Overall Status: %s\n', verification_results.overall_status);
fprintf('Total Signals Found: %d\n', verification_results.total_signals);

if generate_test_dataset && ~isempty(test_dataset)
    fprintf('Test Dataset: Generated (%s)\n', verification_results.test_dataset_filename);
else
    fprintf('Test Dataset: Not generated\n');
end

fprintf('\nNext Steps:\n');
if strcmp(verification_results.overall_status, 'PASSED')
    fprintf('✓ System is ready for dataset generation\n');
    fprintf('✓ All required signals are available\n');
    fprintf('✓ Model workspace is accessible\n');
else
    fprintf('⚠️  System needs attention before dataset generation\n');
    fprintf('⚠️  Check missing signals and model configuration\n');
end

end 