% checkInertialData.m
% Checks what inertial data is available in the current dataset and model

clear; clc;

fprintf('=== Checking Inertial Data Availability ===\n\n');

%% Check current dataset for inertial data
fprintf('--- Checking Current Dataset ---\n');

% Load the 100-simulation dataset
try
    % Add the correct path to find the dataset
    % Go up one directory from Scripts to Neural_Network_Pipeline
    base_dir = fileparts(pwd);
    dataset_path = fullfile(base_dir, '100_Simulation_Test_Dataset', '100_sim_dataset_20250723_103854.mat');
    if exist(dataset_path, 'file')
        load(dataset_path);
        fprintf('✓ Loaded 100-simulation dataset\n');
        
        % Check what data is available
        fprintf('Available data in dataset:\n');
        if isfield(dataset, 'simulations')
            fprintf('  - %d simulations\n', length(dataset.simulations));
            
            % Check first simulation for available fields
            first_sim = dataset.simulations{1};
            fields = fieldnames(first_sim);
            fprintf('  - Simulation fields: %s\n', strjoin(fields, ', '));
            
            % Check for inertial-related data
            inertial_fields = {};
            for i = 1:length(fields)
                field = fields{i};
                if contains(lower(field), {'inertia', 'mass', 'com', 'center', 'moment'})
                    inertial_fields{end+1} = field;
                end
            end
            
            if ~isempty(inertial_fields)
                fprintf('  - Inertial-related fields: %s\n', strjoin(inertial_fields, ', '));
            else
                fprintf('  - No inertial data found in current dataset\n');
            end
        end
    else
        fprintf('✗ Dataset file not found at: %s\n', dataset_path);
    end
    
catch ME
    fprintf('✗ Could not load dataset: %s\n', ME.message);
end

%% Check Simulink model for inertial data
fprintf('\n--- Checking Simulink Model ---\n');

model_name = 'GolfSwing3D_Kinetic';

try
    % Load the model
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end
    fprintf('✓ Model %s loaded\n', model_name);
    
    % Check model workspace for inertial variables
    model_ws = get_param(model_name, 'ModelWorkspace');
    
    % Get workspace variables using the correct method
    try
        ws_vars = who(model_ws);
    catch
        % Alternative method if who() doesn't work
        ws_vars = {};
        try
            % Try to get variables by evaluating them
            test_vars = {'mass', 'inertia', 'com', 'length'};
            for i = 1:length(test_vars)
                try
                    eval(sprintf('test_val = model_ws.%s;', test_vars{i}));
                    ws_vars{end+1} = test_vars{i};
                catch
                    % Variable doesn't exist, continue
                end
            end
        catch
            fprintf('  - Could not access model workspace variables\n');
        end
    end
    
    if ~isempty(ws_vars)
        fprintf('Model workspace variables (%d total):\n', length(ws_vars));
        
        % Look for inertial-related variables
        inertial_vars = {};
        mass_vars = {};
        com_vars = {};
        inertia_vars = {};
        
        for i = 1:length(ws_vars)
            var_name = ws_vars{i};
            var_lower = lower(var_name);
            
            if contains(var_lower, 'inertia')
                inertia_vars{end+1} = var_name;
            elseif contains(var_lower, 'mass')
                mass_vars{end+1} = var_name;
            elseif contains(var_lower, 'com') || contains(var_lower, 'center')
                com_vars{end+1} = var_name;
            end
        end
        
        if ~isempty(mass_vars)
            fprintf('  - Mass variables: %s\n', strjoin(mass_vars, ', '));
        end
        
        if ~isempty(com_vars)
            fprintf('  - COM variables: %s\n', strjoin(com_vars, ', '));
        end
        
        if ~isempty(inertia_vars)
            fprintf('  - Inertia variables: %s\n', strjoin(inertia_vars, ', '));
        end
        
        if isempty([mass_vars, com_vars, inertia_vars])
            fprintf('  - No inertial variables found in model workspace\n');
        end
    else
        fprintf('  - No variables found in model workspace\n');
    end
    
catch ME
    fprintf('✗ Could not check model: %s\n', ME.message);
end

%% Check Simscape Results Explorer for inertial data
fprintf('\n--- Checking Simscape Results Explorer ---\n');

try
    % Check if there are any Simscape runs
    simscapeRuns = Simulink.sdi.getAllRunIDs;
    
    if isempty(simscapeRuns)
        fprintf('No Simscape runs found in Results Explorer.\n');
        fprintf('Please run a simulation first to generate Simscape data.\n');
    else
        fprintf('Found %d Simscape runs.\n', length(simscapeRuns));
        
        % Get the most recent run
        latestRun = simscapeRuns(end);
        runObj = Simulink.sdi.getRun(latestRun);
        
        fprintf('Latest run: %s\n', runObj.Name);
        
        % Get all signals
        signals = runObj.getAllSignals;
        fprintf('Total signals available: %d\n', length(signals));
        
        % Look for inertial-related signals
        inertial_signals = {};
        mass_signals = {};
        com_signals = {};
        inertia_signals = {};
        
        for i = 1:length(signals)
            signal = signals(i);
            signal_name = signal.Name;
            signal_lower = lower(signal_name);
            
            if contains(signal_lower, 'inertia')
                inertia_signals{end+1} = signal_name;
            elseif contains(signal_lower, 'mass')
                mass_signals{end+1} = signal_name;
            elseif contains(signal_lower, 'com') || contains(signal_lower, 'center')
                com_signals{end+1} = signal_name;
            end
        end
        
        if ~isempty(mass_signals)
            fprintf('  - Mass signals: %s\n', strjoin(mass_signals, ', '));
        end
        
        if ~isempty(com_signals)
            fprintf('  - COM signals: %s\n', strjoin(com_signals, ', '));
        end
        
        if ~isempty(inertia_signals)
            fprintf('  - Inertia signals: %s\n', strjoin(inertia_signals, ', '));
        end
        
        if isempty([mass_signals, com_signals, inertia_signals])
            fprintf('  - No inertial signals found in Simscape data\n');
        end
    end
    
catch ME
    fprintf('✗ Could not check Simscape Results Explorer: %s\n', ME.message);
end

%% Check for segment dimension extraction functions
fprintf('\n--- Checking Segment Dimension Functions ---\n');

% Check if extractSegmentDimensions function exists
if exist('extractSegmentDimensions', 'file')
    fprintf('✓ extractSegmentDimensions function found\n');
    
    % Try to extract segment dimensions
    try
        segment_data = extractSegmentDimensions(model_name);
        fprintf('✓ Successfully extracted segment dimensions\n');
        
        % Display summary
        if isfield(segment_data, 'summary')
            fprintf('  - Total segments: %d\n', segment_data.summary.num_segments);
            fprintf('  - Total mass: %.2f kg\n', segment_data.summary.total_mass);
            fprintf('  - Total length: %.2f m\n', segment_data.summary.total_length);
        end
        
        % List available segments
        fields = fieldnames(segment_data);
        segment_fields = {};
        for i = 1:length(fields)
            field = fields{i};
            if ~any(strcmp(field, {'summary', 'extraction_time', 'model_name', 'units'}))
                segment_fields{end+1} = field;
            end
        end
        
        fprintf('  - Available segments: %s\n', strjoin(segment_fields, ', '));
        
    catch ME
        fprintf('✗ Failed to extract segment dimensions: %s\n', ME.message);
    end
else
    fprintf('✗ extractSegmentDimensions function not found\n');
end

%% Recommendations
fprintf('\n--- Recommendations ---\n');

fprintf('1. INERTIAL DATA STATUS:\n');
fprintf('   - Current dataset: No inertial data included\n');
fprintf('   - Model workspace: Check for mass/COM/inertia variables\n');
fprintf('   - Simscape logging: Check for inertial signals\n\n');

fprintf('2. ADDING INERTIAL DATA TO DATASET:\n');
fprintf('   - Extract segment dimensions using extractSegmentDimensions.m\n');
fprintf('   - Include mass, COM, and inertia tensors for each segment\n');
fprintf('   - Add segment dimensions as additional features to neural network\n');
fprintf('   - Consider segment-specific parameters for different golfer sizes\n\n');

fprintf('3. NEURAL NETWORK IMPLICATIONS:\n');
fprintf('   - Inertial data is critical for accurate dynamics prediction\n');
fprintf('   - Different golfer sizes require different torque profiles\n');
fprintf('   - Segment dimensions affect the relationship between motion and torques\n');
fprintf('   - Consider including golfer anthropometric data as features\n\n');

fprintf('4. NEXT STEPS:\n');
fprintf('   - Run extractSegmentDimensions to get current model parameters\n');
fprintf('   - Modify dataset generation to include inertial data\n');
fprintf('   - Update neural network architecture to handle additional features\n');
fprintf('   - Test with different golfer anthropometrics\n');

fprintf('\n=== Analysis Complete ===\n'); 