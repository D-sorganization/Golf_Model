% Safe GUI Launcher with Comprehensive Error Handling
% This script provides a safer way to launch the GUI with fallback options

function safe_launch_gui()
    fprintf('\n=== Safe GUI Launcher ===\n');

    % Step 1: Check environment
    fprintf('Checking environment...\n');
    if ~usejava('desktop')
        error('MATLAB desktop is required to run the GUI. Please run MATLAB with desktop enabled.');
    end

    % Step 2: Change to correct directory
    script_path = fileparts(which(mfilename));
    if ~isempty(script_path)
        cd(script_path);
        fprintf('Changed to GUI directory: %s\n', pwd);
    end

    % Step 3: Add current directory to path
    addpath(pwd);
    fprintf('Added current directory to MATLAB path\n');

    % Step 4: Check for required files
    required_files = {'GolfSwingDataGeneratorGUI.m', 'GolfSwingDataGeneratorHelpers.m'};
    missing_files = {};
    for i = 1:length(required_files)
        if ~exist(required_files{i}, 'file')
            missing_files{end+1} = required_files{i};
        end
    end

    if ~isempty(missing_files)
        error('Missing required files: %s', strjoin(missing_files, ', '));
    end

    % Step 5: Try to launch GUI with multiple fallback options
    fprintf('\nAttempting to launch GUI...\n');

    % Option 1: Try normal launch
    try
        fprintf('Trying normal launch...\n');
        GolfSwingDataGeneratorGUI();
        fprintf('GUI launched successfully!\n');
        return;
    catch ME
        fprintf('Normal launch failed: %s\n', ME.message);
    end

    % Option 2: Try with error suppression and manual figure creation
    try
        fprintf('\nTrying alternative launch method...\n');

        % Create a simple test figure first
        test_fig = figure('Name', 'Test', 'Visible', 'off');
        close(test_fig);

        % Now try the GUI again
        warning('off', 'all');
        GolfSwingDataGeneratorGUI();
        warning('on', 'all');
        fprintf('GUI launched successfully with alternative method!\n');
        return;
    catch ME
        fprintf('Alternative launch failed: %s\n', ME.message);
    end

    % Option 3: Try minimal GUI
    try
        fprintf('\nTrying minimal GUI version...\n');
        launch_minimal_gui();
        fprintf('Minimal GUI launched successfully!\n');
        return;
    catch ME
        fprintf('Minimal GUI failed: %s\n', ME.message);
    end

    % If all options fail, provide diagnostic information
    fprintf('\n=== All launch attempts failed ===\n');
    fprintf('Please run diagnose_gui_error.m for detailed diagnostics.\n');
    fprintf('\nPossible solutions:\n');
    fprintf('1. Check if MATLAB has proper display/graphics support\n');
    fprintf('2. Try running MATLAB with: matlab -softwareopengl\n');
    fprintf('3. Update graphics drivers\n');
    fprintf('4. Check MATLAB installation and toolboxes\n');

    % Show the last error details
    fprintf('\nLast error details:\n');
    disp(getReport(ME, 'extended', 'hyperlinks', 'off'));
end

function launch_minimal_gui()
    % Create a minimal version of the GUI for testing
    fig = figure('Name', 'Golf Swing Data Generator - Minimal', ...
                 'Position', [100, 100, 800, 600], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none');

    % Add a simple panel
    panel = uipanel('Parent', fig, ...
                    'Title', 'Minimal GUI Test', ...
                    'Position', [0.1, 0.1, 0.8, 0.8]);

    % Add a text label
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'If you can see this, basic GUI functionality is working.', ...
              'Position', [50, 250, 600, 30], ...
              'FontSize', 12);

    % Add a button to test callbacks
    uicontrol('Parent', panel, ...
              'Style', 'pushbutton', ...
              'String', 'Test Button', ...
              'Position', [350, 200, 100, 30], ...
              'Callback', @(~,~) fprintf('Button clicked!\n'));

    % Add instructions
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', ['This is a minimal GUI test. If this works but the main GUI does not, ' ...
                        'there may be an issue with specific GUI components or initialization code.'], ...
              'Position', [50, 100, 600, 60], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
end
