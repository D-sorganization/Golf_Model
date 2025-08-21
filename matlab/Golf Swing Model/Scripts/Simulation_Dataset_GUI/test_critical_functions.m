% Test script to test critical functions that might be causing simulation failure
% This will help identify if validateInputs or extractCoefficientsFromTable are failing

try
    fprintf('=== TESTING CRITICAL FUNCTIONS ===\n');
    
    % Launch the GUI to get handles
    fprintf('Launching Data_GUI to get handles...\n');
    Data_GUI();
    
    % Wait for GUI to fully initialize
    pause(3);
    
    % Find the GUI figure
    fig = findall(0, 'Type', 'figure', 'Name', 'Enhanced Golf Swing Data Generator');
    
    if isempty(fig)
        fprintf('ERROR: GUI figure not found\n');
        return;
    end
    
    fprintf('Found GUI figure\n');
    
    % Get the handles from the figure
    handles = guidata(fig);
    
    % Test 1: Test validateInputs function
    fprintf('\n--- Testing validateInputs function ---\n');
    
    try
        % Set up some basic parameters for testing
        if isfield(handles, 'num_trials_edit')
            set(handles.num_trials_edit, 'String', '2');
        end
        
        if isfield(handles, 'sim_time_edit')
            set(handles.sim_time_edit, 'String', '0.1');
        end
        
        if isfield(handles, 'output_folder_edit')
            set(handles.output_folder_edit, 'String', pwd);
        end
        
        if isfield(handles, 'folder_name_edit')
            set(handles.folder_name_edit, 'String', 'test_simulation');
        end
        
        if isfield(handles, 'use_logsout')
            set(handles.use_logsout, 'Value', 1);
        end
        
        % Update handles
        guidata(fig, handles);
        
        % Now test validateInputs
        config = validateInputs(handles);
        
        if isempty(config)
            fprintf('✗ validateInputs returned empty config!\n');
            fprintf('  This is likely the cause of the simulation failure.\n');
        else
            fprintf('✓ validateInputs returned valid config\n');
            fprintf('  Model path: %s\n', config.model_path);
            fprintf('  Number of simulations: %d\n', config.num_simulations);
            fprintf('  Output folder: %s\n', config.output_folder);
        end
        
    catch ME
        fprintf('✗ validateInputs failed: %s\n', ME.message);
        fprintf('  This is likely the cause of the simulation failure.\n');
    end
    
    % Test 2: Test extractCoefficientsFromTable function
    fprintf('\n--- Testing extractCoefficientsFromTable function ---\n');
    
    try
        % Add functions folder to path
        addpath(fullfile(pwd, 'functions'));
        
        % Test the function
        coefficient_values = extractCoefficientsFromTable(handles);
        
        if isempty(coefficient_values)
            fprintf('✗ extractCoefficientsFromTable returned empty coefficients!\n');
            fprintf('  This could cause the simulation to fail.\n');
        else
            fprintf('✓ extractCoefficientsFromTable returned valid coefficients\n');
            fprintf('  Number of coefficient sets: %d\n', size(coefficient_values, 1));
            fprintf('  Number of coefficients per set: %d\n', size(coefficient_values, 2));
        end
        
    catch ME
        fprintf('✗ extractCoefficientsFromTable failed: %s\n', ME.message);
        fprintf('  This could cause the simulation to fail.\n');
    end
    
    % Test 3: Test if the model file exists
    fprintf('\n--- Testing model file access ---\n');
    
    model_path = '../../Model/GolfSwing3D_Kinetic.slx';
    if exist(model_path, 'file')
        fprintf('✓ Model file exists at: %s\n', model_path);
    else
        fprintf('✗ Model file not found at: %s\n', model_path);
    end
    
    % Test 4: Test if we can create a SimulationInput
    fprintf('\n--- Testing Simulink.SimulationInput creation ---\n');
    
    try
        sim_input = Simulink.SimulationInput(model_path);
        fprintf('✓ Simulink.SimulationInput created successfully\n');
    catch ME
        fprintf('✗ Failed to create Simulink.SimulationInput: %s\n', ME.message);
    end
    
catch ME
    fprintf('ERROR in test script: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== CRITICAL FUNCTIONS TEST COMPLETE ===\n');
