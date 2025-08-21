% Test script to launch GUI and trigger simulation
% This will help identify exactly where the simulation fails

try
    fprintf('=== TESTING GUI SIMULATION ===\n');
    
    % Launch the GUI
    fprintf('Launching Data_GUI...\n');
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
    
    % Check if we have the necessary UI elements
    if ~isfield(handles, 'play_pause_button')
        fprintf('ERROR: Play button not found in handles\n');
        fprintf('Available fields in handles:\n');
        field_names = fieldnames(handles);
        for i = 1:length(field_names)
            fprintf('  %s\n', field_names{i});
        end
        return;
    end
    
    fprintf('Found play button\n');
    
    % Set up some basic parameters for testing
    fprintf('Setting up test parameters...\n');
    
    % Set number of trials to a small number for testing
    if isfield(handles, 'num_trials_edit')
        set(handles.num_trials_edit, 'String', '2');
        fprintf('Set number of trials to 2\n');
    end
    
    % Set simulation time to a short duration
    if isfield(handles, 'sim_time_edit')
        set(handles.sim_time_edit, 'String', '0.1');
        fprintf('Set simulation time to 0.1 seconds\n');
    end
    
    % Set output folder
    if isfield(handles, 'output_folder_edit')
        set(handles.output_folder_edit, 'String', pwd);
        fprintf('Set output folder to current directory\n');
    end
    
    if isfield(handles, 'folder_name_edit')
        set(handles.folder_name_edit, 'String', 'test_simulation');
        fprintf('Set folder name to test_simulation\n');
    end
    
    % Enable at least one data source
    if isfield(handles, 'use_logsout')
        set(handles.use_logsout, 'Value', 1);
        fprintf('Enabled logsout data source\n');
    end
    
    % Update the handles
    guidata(fig, handles);
    
    % Now try to trigger the simulation
    fprintf('Attempting to trigger simulation...\n');
    
    % Simulate button click by calling the callback directly
    try
        % Get the current handles again
        current_handles = guidata(fig);
        
        % Call the startGeneration function
        startGeneration([], [], fig);
        
        % Wait for simulation to start
        pause(5);
        
        % Check if simulation is running
        current_handles = guidata(fig);
        if isfield(current_handles, 'is_running') && current_handles.is_running
            fprintf('SUCCESS: Simulation appears to be running\n');
            
            % Wait a bit more to see if it completes
            pause(10);
            
            % Check final status
            final_handles = guidata(fig);
            if isfield(final_handles, 'is_running') && ~final_handles.is_running
                fprintf('Simulation completed\n');
            else
                fprintf('Simulation still running\n');
            end
        else
            fprintf('WARNING: Simulation does not appear to be running\n');
        end
        
    catch ME
        fprintf('ERROR triggering simulation: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
catch ME
    fprintf('ERROR in test script: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== GUI SIMULATION TEST COMPLETE ===\n');
