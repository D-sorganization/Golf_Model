% Test script to debug simulation execution
% This script will create a minimal GUI instance and trigger simulation

try
    fprintf('=== TESTING SIMULATION DEBUG ===\n');

    % Create the GUI
    fprintf('Creating GUI...\n');
    Data_GUI();

    % Wait a moment for GUI to fully initialize
    pause(3);

    % Find the GUI figure
    fprintf('Looking for GUI figure...\n');
    fig = findall(0, 'Type', 'figure', 'Name', 'Enhanced Golf Swing Data Generator');

    if isempty(fig)
        fprintf('ERROR: GUI figure not found\n');
        return;
    end

    fprintf('Found GUI figure\n');

    % Get the handles from the figure
    current_handles = guidata(fig);

    % Check if we have the necessary UI elements
    if isfield(current_handles, 'play_pause_button')
        fprintf('Found play button, attempting to click...\n');

        % Simulate button click
        startGeneration([], [], fig);

        % Wait for simulation to start
        pause(5);

        % Check if simulation is running
        if isfield(current_handles, 'is_running') && current_handles.is_running
            fprintf('SUCCESS: Simulation appears to be running\n');
        else
            fprintf('WARNING: Simulation does not appear to be running\n');
        end

    else
        fprintf('ERROR: Play button not found in handles\n');
        fprintf('Available fields in handles:\n');
        field_names = fieldnames(current_handles);
        for i = 1:length(field_names)
            fprintf('  %s\n', field_names{i});
        end
    end

catch ME
    fprintf('ERROR in test script: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('=== TEST COMPLETE ===\n');
