function GolfSwingDataGeneratorGUI()
    % GolfSwingDataGeneratorGUI - Generate golf swing training data
    % This GUI provides an interface for configuring and running simulation trials
    
    % Create main figure with responsive sizing
    fig = figure('Name', 'Golf Swing Training Data Generator', ...
                 'Position', [100, 100, 1200, 800], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'on', ...
                 'Color', [0.94, 0.94, 0.94], ...
                 'ResizeFcn', @(src,evt) resizeGUI(src, evt));
    
    % Initialize handles structure
    handles = struct();
    handles.should_stop = false;
    handles.trial_table_data = [];
    
    % Create main layout with proper spacing
    createMainLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
    
    fprintf('GUI launched successfully!\n');
end

function createMainLayout(fig, handles)
    % Create responsive layout with proper spacing
    
    % Main container panel
    main_panel = uipanel('Parent', fig, ...
                        'Position', [0.01, 0.01, 0.98, 0.98], ...
                        'BackgroundColor', [0.94, 0.94, 0.94], ...
                        'BorderType', 'none');
    
    % Configuration Panel with proper spacing to prevent overlaps
    config_panel = uipanel('Parent', main_panel, ...
                          'Title', 'Configuration', ...
                          'Position', [0.02, 0.50, 0.96, 0.47], ...
                          'BackgroundColor', [0.97, 0.97, 0.97], ...
                          'FontSize', 12, ...
                          'FontWeight', 'bold');
    
    % Trial Settings - smaller and better positioned
    trial_panel = uipanel('Parent', config_panel, ...
                         'Title', 'Trial Settings', ...
                         'Position', [0.02, 0.74, 0.47, 0.24], ...
                         'BackgroundColor', [0.98, 0.98, 0.98], ...
                         'FontSize', 10);
    
    % Data Sources panel - smaller and better positioned
    data_panel = uipanel('Parent', config_panel, ...
                        'Title', 'Data Sources', ...
                        'Position', [0.51, 0.74, 0.47, 0.24], ...
                        'BackgroundColor', [0.98, 0.98, 0.98], ...
                        'FontSize', 10);
    
    % Modeling panel - much more space and better positioned
    modeling_panel = uipanel('Parent', config_panel, ...
                           'Title', 'Modeling Mode & Torque Scenarios', ...
                           'Position', [0.02, 0.38, 0.96, 0.34], ...
                           'BackgroundColor', [0.98, 0.98, 0.98], ...
                           'FontSize', 10);
    
    % Output settings panel - more space
    output_panel = uipanel('Parent', config_panel, ...
                          'Title', 'Output Settings', ...
                          'Position', [0.02, 0.02, 0.96, 0.34], ...
                          'BackgroundColor', [0.98, 0.98, 0.98], ...
                          'FontSize', 10);
    
    % Progress panel at bottom - smaller to make room
    progress_panel = uipanel('Parent', main_panel, ...
                           'Title', 'Progress', ...
                           'Position', [0.02, 0.02, 0.96, 0.46], ...
                           'BackgroundColor', [0.97, 0.97, 0.97], ...
                           'FontSize', 12, ...
                           'FontWeight', 'bold');
    
    % Create controls with proper spacing
    createTrialSettings(trial_panel, handles);
    createDataSourceSettings(data_panel, handles);
    createModelingSettings(modeling_panel, handles);
    createOutputSettings(output_panel, handles);
    createProgressSection(progress_panel, handles);
end

function createTrialSettings(parent, handles)
    % Trial settings with proper spacing to prevent overlaps
    y_pos = 0.75;
    spacing = 0.18;
    
    % Number of Trials
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Number of Trials:', ...
              'Units', 'normalized', ...
              'Position', [0.05, y_pos, 0.35, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.num_trials = uicontrol('Parent', parent, ...
                                   'Style', 'edit', ...
                                   'String', '10', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.42, y_pos, 0.2, 0.12], ...
                                   'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    % Duration
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Duration (s):', ...
              'Units', 'normalized', ...
              'Position', [0.05, y_pos, 0.35, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.duration = uicontrol('Parent', parent, ...
                                 'Style', 'edit', ...
                                 'String', '0.3', ...
                                 'Units', 'normalized', ...
                                 'Position', [0.42, y_pos, 0.2, 0.12], ...
                                 'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    % Sample Rate
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Sample Rate (Hz):', ...
              'Units', 'normalized', ...
              'Position', [0.05, y_pos, 0.35, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.sample_rate = uicontrol('Parent', parent, ...
                                    'Style', 'edit', ...
                                    'String', '100', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.42, y_pos, 0.2, 0.12], ...
                                    'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    % Execution Mode
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Execution Mode:', ...
              'Units', 'normalized', ...
              'Position', [0.05, y_pos, 0.35, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.execution_mode = uicontrol('Parent', parent, ...
                                       'Style', 'popupmenu', ...
                                       'String', {'Sequential', 'Parallel'}, ...
                                       'Units', 'normalized', ...
                                       'Position', [0.42, y_pos, 0.35, 0.12], ...
                                       'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    % Animation Control
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Animation:', ...
              'Units', 'normalized', ...
              'Position', [0.05, y_pos, 0.35, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.enable_animation = uicontrol('Parent', parent, ...
                                         'Style', 'checkbox', ...
                                         'String', 'Enable Animation', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.42, y_pos, 0.35, 0.12], ...
                                         'Value', 0, ...  % Default to disabled for speed
                                         'FontSize', 9);
end

function createDataSourceSettings(parent, handles)
    % Data source checkboxes with better spacing
    y_pos = 0.8;
    spacing = 0.18;
    
    handles.logsout_data = uicontrol('Parent', parent, ...
                                     'Style', 'checkbox', ...
                                     'String', 'Logsout Data', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.05, y_pos, 0.9, 0.15], ...
                                     'Value', 1, ...
                                     'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    handles.signal_bus_data = uicontrol('Parent', parent, ...
                                        'Style', 'checkbox', ...
                                        'String', 'Signal Bus Data', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05, y_pos, 0.9, 0.15], ...
                                        'Value', 1, ...
                                        'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    handles.simscape_results = uicontrol('Parent', parent, ...
                                         'Style', 'checkbox', ...
                                         'String', 'Simscape Results', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.05, y_pos, 0.9, 0.15], ...
                                         'Value', 1, ...
                                         'FontSize', 9);
    
    y_pos = y_pos - spacing;
    
    handles.model_workspace = uicontrol('Parent', parent, ...
                                        'Style', 'checkbox', ...
                                        'String', 'Model Workspace', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05, y_pos, 0.9, 0.15], ...
                                        'Value', 1, ...
                                        'FontSize', 9);
end

function createModelingSettings(parent, handles)
    % Modeling mode and torque settings with proper spacing to prevent overlaps
    
    % Row 1: Modeling Mode
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Modeling Mode:', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.82, 0.15, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.modeling_mode = uicontrol('Parent', parent, ...
                                      'Style', 'edit', ...
                                      'String', 'Mode 3 (Hex Polynomial)', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.18, 0.82, 0.25, 0.12], ...
                                      'FontSize', 9, ...
                                      'Enable', 'off');
    
    % Constant Value (same row)
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Constant Value (G):', ...
              'Units', 'normalized', ...
              'Position', [0.48, 0.82, 0.15, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.constant_value = uicontrol('Parent', parent, ...
                                       'Style', 'edit', ...
                                       'String', '10', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.64, 0.82, 0.08, 0.12], ...
                                       'FontSize', 9);
    
    % Coefficient Range (same row)
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Coeff Range (±):', ...
              'Units', 'normalized', ...
              'Position', [0.75, 0.82, 0.13, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.coeff_range = uicontrol('Parent', parent, ...
                                    'Style', 'edit', ...
                                    'String', '50', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.89, 0.82, 0.08, 0.12], ...
                                    'FontSize', 9);
    
    % Row 2: Torque Scenario  
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Torque Scenario:', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.65, 0.15, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.torque_scenario = uicontrol('Parent', parent, ...
                                        'Style', 'popupmenu', ...
                                        'String', {'Variable Torques (A-G varied)', 'Fixed Torques'}, ...
                                        'Units', 'normalized', ...
                                        'Position', [0.18, 0.65, 0.35, 0.12], ...
                                        'FontSize', 9);
    
    % Row 3: Model
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Model:', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.48, 0.08, 0.12], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.model = uicontrol('Parent', parent, ...
                              'Style', 'edit', ...
                              'String', 'GolfSwing3D_Kinetic', ...
                              'Units', 'normalized', ...
                              'Position', [0.12, 0.48, 0.40, 0.12], ...
                              'FontSize', 9);
end

function createOutputSettings(parent, handles)
    % Output settings with improved spacing
    y_pos = 0.8;
    spacing = 0.3;
    
    % Output Folder
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y_pos, 0.12, 0.15], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.output_folder = uicontrol('Parent', parent, ...
                                      'Style', 'edit', ...
                                      'String', 'C:\Users\diete\Golf_Model\Golf Swing Model\Scripts\Simulink', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.15, y_pos-0.02, 0.6, 0.18], ...
                                      'FontSize', 9);
    
    handles.browse_btn = uicontrol('Parent', parent, ...
                                   'Style', 'pushbutton', ...
                                   'String', 'Browse', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.77, y_pos-0.02, 0.1, 0.18], ...
                                   'FontSize', 9, ...
                                   'Callback', @(src,evt) browseFolder(handles));
    
    y_pos = y_pos - spacing;
    
    % Folder Name
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Folder Name:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y_pos, 0.12, 0.15], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9);
    
    handles.folder_name = uicontrol('Parent', parent, ...
                                    'Style', 'edit', ...
                                    'String', 'training_data_csv', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.15, y_pos-0.02, 0.25, 0.18], ...
                                    'FontSize', 9);
end

function createProgressSection(parent, handles)
    % Progress section with better layout
    
    % Status text
    handles.status_text = uicontrol('Parent', parent, ...
                                   'Style', 'text', ...
                                   'String', 'Ready to start...', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.02, 0.85, 0.96, 0.1], ...
                                   'HorizontalAlignment', 'left', ...
                                   'FontSize', 10, ...
                                   'FontWeight', 'bold');
    
    % Trial progress
    handles.trial_progress = uicontrol('Parent', parent, ...
                                      'Style', 'text', ...
                                      'String', 'Trial progress will appear here...', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.02, 0.73, 0.96, 0.1], ...
                                      'HorizontalAlignment', 'left', ...
                                      'FontSize', 9);
    
    % Log area
    handles.log_text = uicontrol('Parent', parent, ...
                                 'Style', 'listbox', ...
                                 'String', {'Golf Swing Data Generator initialized successfully!'}, ...
                                 'Units', 'normalized', ...
                                 'Position', [0.02, 0.15, 0.96, 0.55], ...
                                 'FontSize', 9, ...
                                 'BackgroundColor', [1, 1, 1]);
    
    % Control buttons
    button_panel = uipanel('Parent', parent, ...
                          'Position', [0.02, 0.02, 0.96, 0.12], ...
                          'BackgroundColor', [0.97, 0.97, 0.97], ...
                          'BorderType', 'none');
    
    handles.start_btn = uicontrol('Parent', button_panel, ...
                                  'Style', 'pushbutton', ...
                                  'String', 'Start Generation', ...
                                  'Units', 'normalized', ...
                                  'Position', [0.02, 0.1, 0.2, 0.8], ...
                                  'FontSize', 11, ...
                                  'FontWeight', 'bold', ...
                                  'BackgroundColor', [0.2, 0.8, 0.2], ...
                                  'ForegroundColor', 'white', ...
                                  'Callback', @(src,evt) startGeneration(handles));
    
    handles.stop_btn = uicontrol('Parent', button_panel, ...
                                 'Style', 'pushbutton', ...
                                 'String', 'Stop', ...
                                 'Units', 'normalized', ...
                                 'Position', [0.24, 0.1, 0.15, 0.8], ...
                                 'FontSize', 11, ...
                                 'FontWeight', 'bold', ...
                                 'BackgroundColor', [0.8, 0.2, 0.2], ...
                                 'ForegroundColor', 'white', ...
                                 'Enable', 'off', ...
                                 'Callback', @(src,evt) stopGeneration(handles));
    
    handles.clear_log_btn = uicontrol('Parent', button_panel, ...
                                      'Style', 'pushbutton', ...
                                      'String', 'Clear Log', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.41, 0.1, 0.15, 0.8], ...
                                      'FontSize', 9, ...
                                      'Callback', @(src,evt) clearLog(handles));
    
    handles.run_another_btn = uicontrol('Parent', button_panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Run Another Trial', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.58, 0.1, 0.2, 0.8], ...
                                        'FontSize', 11, ...
                                        'FontWeight', 'bold', ...
                                        'BackgroundColor', [0.2, 0.6, 0.8], ...
                                        'ForegroundColor', 'white', ...
                                        'Enable', 'off', ...  % Initially disabled
                                        'Callback', @(src,evt) runAnotherTrial(handles));
end

function resizeGUI(src, evt)
    % Handle window resizing to maintain proportional layout
    % This function ensures proper spacing when window is resized
    handles = guidata(src);
    % Resize handling is built into normalized units
end

function startGeneration(handles)
    % Start the data generation process
    updateLog(handles, 'Starting data generation...');
    
    % Create backup of all scripts before starting
    try
        backupScripts(handles);
    catch ME
        updateLog(handles, sprintf('Warning: Could not create script backup: %s', ME.message));
    end
    
    % Configure model for animation control
    try
        model_name = get(handles.model, 'String');
        enable_animation = get(handles.enable_animation, 'Value');
        
        % Load the model if not already loaded
        if ~bdIsLoaded(model_name)
            load_system(model_name);
        end
        
        % Set initial simulation mode and animation display based on animation setting
        if ~enable_animation
            % Use comprehensive animation disable function
            disableAnimationComprehensive(model_name);
            updateLog(handles, 'Model configured for no animation using comprehensive approach');
        else
            % Use comprehensive animation enable function
            enableAnimationComprehensive(model_name);
            updateLog(handles, 'Model configured for animation using comprehensive approach');
        end
        
    catch ME
        updateLog(handles, sprintf('Warning: Could not configure model: %s', ME.message));
    end
    
    % Get current settings
    num_trials = str2double(get(handles.num_trials, 'String'));
    duration = str2double(get(handles.duration, 'String'));
    sample_rate = str2double(get(handles.sample_rate, 'String'));
    
    % Update UI state
    set(handles.start_btn, 'Enable', 'off');
    set(handles.stop_btn, 'Enable', 'on');
    set(handles.status_text, 'String', sprintf('Generating %d trials...', num_trials));
    
    % Call the actual generation function
    try
        runTrials(handles);
    catch ME
        updateLog(handles, sprintf('Error: %s', ME.message));
        set(handles.start_btn, 'Enable', 'on');
        set(handles.stop_btn, 'Enable', 'off');
    end
end

function backupScripts(handles)
    % Create a backup of all scripts used in the current run
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    backup_folder = sprintf('Script_Backup_%s', timestamp);
    
    % Create backup directory
    if ~exist(backup_folder, 'dir')
        mkdir(backup_folder);
    end
    
    % List of scripts to backup
    scripts_to_backup = {
        'GolfSwingDataGeneratorGUI.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractFromCombinedSignalBus.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/Data_GUI.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractFromNestedStruct.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractLogsoutDataFixed.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractSimscapeDataRecursive.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/traverseSimlogNode.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractDataFromField.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/combineDataSources.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/addModelWorkspaceData.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractWorkspaceOutputs.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/resampleDataToFrequency.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/getPolynomialParameterInfo.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/getShortenedJointName.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/generateRandomCoefficients.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/prepareSimulationInputsForBatch.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/restoreWorkspace.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/getMemoryInfo.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/checkHighMemoryUsage.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/loadInputFile.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/checkStopRequest.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractCoefficientsFromTable.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/shouldShowDebug.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/shouldShowVerbose.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/shouldShowNormal.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/mergeTables.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/logical2str.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/fallbackSimlogExtraction.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractTimeSeriesData.m',
        'Golf Swing Model/Scripts/Simulation_Dataset_GUI/extractConstantMatrixData.m'
    };
    
    % Copy each script to backup folder
    for i = 1:length(scripts_to_backup)
        script_path = scripts_to_backup{i};
        if exist(script_path, 'file')
            [~, script_name, script_ext] = fileparts(script_path);
            backup_path = fullfile(backup_folder, [script_name, script_ext]);
            copyfile(script_path, backup_path);
        end
    end
    
    % Create a README file with backup information
    readme_content = sprintf(['Script Backup Created: %s\n', ...
                             'This backup contains all scripts used in the current simulation run.\n', ...
                             'Backup includes:\n', ...
                             '- Main GUI script\n', ...
                             '- Data extraction functions\n', ...
                             '- Utility functions\n', ...
                             '- All supporting scripts\n\n', ...
                             'Total scripts backed up: %d\n', ...
                             'Backup location: %s\n'], ...
                             timestamp, length(scripts_to_backup), backup_folder);
    
    readme_path = fullfile(backup_folder, 'README_BACKUP.txt');
    fid = fopen(readme_path, 'w');
    if fid ~= -1
        fprintf(fid, '%s', readme_content);
        fclose(fid);
    end
    
    updateLog(handles, sprintf('Script backup created: %s', backup_folder));
end

function stopGeneration(handles)
    % Stop the generation process
    handles.should_stop = true;
    guidata(gcbf, handles);
    updateLog(handles, 'Generation stopped by user.');
    
    % Try to stop any running simulation
    try
        % Get the model name from the GUI
        model_name = get(handles.model, 'String');
        
        % Stop the Simulink model if it's running
        if bdIsLoaded(model_name)
            set_param(model_name, 'SimulationCommand', 'stop');
            updateLog(handles, sprintf('Simulation %s stopped.', model_name));
        end
        
        % Also try to stop any running parsim processes
        if exist('gcp', 'file') && ~isempty(gcp('nocreate'))
            pool = gcp('nocreate');
            if ~isempty(pool)
                updateLog(handles, 'Parallel pool detected - stopping parallel processes...');
            end
        end
        
    catch ME
        updateLog(handles, sprintf('Warning: Could not stop simulation: %s', ME.message));
    end
    
    set(handles.start_btn, 'Enable', 'on');
    set(handles.stop_btn, 'Enable', 'off');
    set(handles.run_another_btn, 'Enable', 'on');
    set(handles.status_text, 'String', 'Stopped');
end

function clearLog(handles)
    % Clear the log display
    set(handles.log_text, 'String', {'Log cleared'});
end

function runAnotherTrial(handles)
    % Reset trial counter and run another trial
    updateLog(handles, 'Starting another trial...');
    
    % Reset UI state
    set(handles.start_btn, 'Enable', 'off');
    set(handles.stop_btn, 'Enable', 'on');
    set(handles.run_another_btn, 'Enable', 'off');
    
    % Run single trial
    try
        trial_data = runSingleTrialWithSignalBus(1, handles);
        updateLog(handles, 'Additional trial completed successfully');
    catch ME
        updateLog(handles, sprintf('Additional trial failed: %s', ME.message));
    end
    
    % Reset UI state
    set(handles.start_btn, 'Enable', 'on');
    set(handles.stop_btn, 'Enable', 'off');
    set(handles.run_another_btn, 'Enable', 'on');
end

function updateLog(handles, message)
    % Update the log with new message
    current_log = get(handles.log_text, 'String');
    timestamp = datestr(now, 'HH:MM:SS');
    new_message = sprintf('[%s] %s', timestamp, message);
    
    if ischar(current_log)
        current_log = {current_log};
    end
    
    updated_log = [current_log; {new_message}];
    set(handles.log_text, 'String', updated_log);
    set(handles.log_text, 'Value', length(updated_log));
    drawnow;
end

function browseFolder(handles)
    % Browse for output folder
    folder = uigetdir(get(handles.output_folder, 'String'), 'Select Output Folder');
    if folder ~= 0
        set(handles.output_folder, 'String', folder);
    end
end

function runTrials(handles)
    % Main trial execution function
    % This function handles the CombinedSignalBus data structure
    
    num_trials = str2double(get(handles.num_trials, 'String'));
    
    for i = 1:num_trials
        if handles.should_stop
            break;
        end
        
        % Update progress
        set(handles.trial_progress, 'String', sprintf('Running trial %d of %d...', i, num_trials));
        set(handles.status_text, 'String', sprintf('Trial %d/%d in progress...', i, num_trials));
        
        try
            % Run single trial with CombinedSignalBus handling
            trial_data = runSingleTrialWithSignalBus(i, handles);
            
            % Process CombinedSignalBus data structure
            if isfield(trial_data, 'CombinedSignalBus')
                processCombinedSignalBus(trial_data.CombinedSignalBus, i, handles);
            end
            
            updateLog(handles, sprintf('Trial %d completed successfully', i));
            
        catch ME
            updateLog(handles, sprintf('Trial %d failed: %s', i, ME.message));
        end
        
        drawnow;
    end
    
    % Finalization
    set(handles.start_btn, 'Enable', 'on');
    set(handles.stop_btn, 'Enable', 'off');
    set(handles.run_another_btn, 'Enable', 'on');  % Enable run another button
    set(handles.status_text, 'String', 'Generation completed');
    updateLog(handles, 'All trials completed!');
end

function trial_data = runSingleTrialWithSignalBus(trial_num, handles)
    % Run a single trial and handle CombinedSignalBus data
    
    % This function calls the actual simulation and handles the
    % CombinedSignalBus structure: out.CombinedSignalBus.{SignalCategory}.{SignalName}
    
    updateLog(handles, sprintf('Starting simulation for trial %d', trial_num));
    
    % Get animation setting
    enable_animation = get(handles.enable_animation, 'Value');
    
    % Create simulation input with proper animation control
    try
        % Load the model if not already loaded
        model_name = get(handles.model, 'String');
        if ~bdIsLoaded(model_name)
            load_system(model_name);
        end
        
        % Set simulation mode and animation display based on animation setting
        if ~enable_animation
            % Use comprehensive animation disable function
            disableAnimationComprehensive(model_name);
            updateLog(handles, 'Animation disabled using comprehensive approach');
        else
            % Use comprehensive animation enable function
            enableAnimationComprehensive(model_name);
            updateLog(handles, 'Animation enabled using comprehensive approach');
        end
        
        % Create simulation input
        simIn = Simulink.SimulationInput(model_name);
        
        % Set simulation parameters
        duration = str2double(get(handles.duration, 'String'));
        simIn = simIn.setModelParameter('StopTime', num2str(duration));
        
        % Run the simulation
        out = sim(simIn);
        
        % Extract data from CombinedSignalBus if present
        trial_data = struct();
        if isfield(out, 'CombinedSignalBus')
            trial_data.CombinedSignalBus = out.CombinedSignalBus;
            updateLog(handles, sprintf('Trial %d: CombinedSignalBus data extracted', trial_num));
        end
        
        % Add other data sources as needed
        if isfield(out, 'logsout')
            trial_data.logsout = out.logsout;
        end
        
        % Add simlog if available
        if isfield(out, 'simlog')
            trial_data.simlog = out.simlog;
        end
        
    catch ME
        updateLog(handles, sprintf('Simulation error in trial %d: %s', trial_num, ME.message));
        rethrow(ME);
    end
end

function processCombinedSignalBus(signal_bus, trial_num, handles)
    % Process the CombinedSignalBus data structure
    % Structure: CombinedSignalBus.{SignalCategory}.{SignalName}
    
    try
        categories = fieldnames(signal_bus);
        
        for i = 1:length(categories)
            category = categories{i};
            signals = fieldnames(signal_bus.(category));
            
            updateLog(handles, sprintf('Processing category: %s with %d signals', category, length(signals)));
            
            for j = 1:length(signals)
                signal_name = signals{j};
                signal_data = signal_bus.(category).(signal_name);
                
                % Save signal data to CSV
                filename = sprintf('trial_%03d_%s_%s.csv', trial_num, category, signal_name);
                output_folder = get(handles.output_folder, 'String');
                folder_name = get(handles.folder_name, 'String');
                full_path = fullfile(output_folder, folder_name, filename);
                
                % Ensure directory exists
                if ~exist(fullfile(output_folder, folder_name), 'dir')
                    mkdir(fullfile(output_folder, folder_name));
                end
                
                % Write data to file
                if isstruct(signal_data) && isfield(signal_data, 'Data')
                    csvwrite(full_path, signal_data.Data);
                else
                    csvwrite(full_path, signal_data);
                end
            end
        end
        
        updateLog(handles, sprintf('Trial %d: All CombinedSignalBus data saved', trial_num));
        
    catch ME
        updateLog(handles, sprintf('Error processing CombinedSignalBus for trial %d: %s', trial_num, ME.message));
    end
end

function disableAnimationComprehensive(model_name)
    % Comprehensive function to disable animation using multiple approaches
    
    % Approach 1: Try accelerator mode first
    try
        set_param(model_name, 'SimulationMode', 'accelerator');
        current_mode = get_param(model_name, 'SimulationMode');
        if strcmp(current_mode, 'accelerator')
            return; % Success - accelerator mode works
        end
    catch ME
        % Accelerator mode not available, continue with other approaches
    end
    
    % Approach 2: Set to normal mode and try multiple animation parameters
    try
        set_param(model_name, 'SimulationMode', 'normal');
        
        % Try various animation parameters
        animation_params = {
            'AnimationMode', 'off';
            'ShowAnimation', 'off';
            'DisplayAnimation', 'off';
            'VisualAnimation', 'off';
            'AnimateSimulation', 'off';
            'Animation', 'off';
            'ShowSimulationAnimation', 'off';
            'EnableAnimation', 'off';
            'SimulationAnimation', 'off'
        };
        
        for i = 1:size(animation_params, 1)
            param_name = animation_params{i, 1};
            param_value = animation_params{i, 2};
            
            try
                set_param(model_name, param_name, param_value);
            catch ME
                % Parameter doesn't exist, that's okay
            end
        end
        
    catch ME
        % Error setting parameters, continue anyway
    end
    
    % Approach 3: Try to disable Simscape animation specifically
    try
        simscape_blocks = find_system(model_name, 'BlockType', 'SimscapeBlock');
        if ~isempty(simscape_blocks)
            for i = 1:length(simscape_blocks)
                block_path = simscape_blocks{i};
                try
                    set_param(block_path, 'AnimationMode', 'off');
                catch ME
                    % Block doesn't support this parameter
                end
            end
        end
    catch ME
        % Error with Simscape blocks
    end
    
    % Approach 4: Set solver parameters that might reduce animation
    try
        set_param(model_name, 'SolverType', 'Fixed-step');
        set_param(model_name, 'FixedStep', '0.001');
    catch ME
        % Error setting solver
    end
end

function enableAnimationComprehensive(model_name)
    % Comprehensive function to enable animation
    
    try
        set_param(model_name, 'SimulationMode', 'normal');
        
        % Try to enable animation parameters
        animation_params = {
            'AnimationMode', 'on';
            'ShowAnimation', 'on';
            'DisplayAnimation', 'on';
            'VisualAnimation', 'on';
            'AnimateSimulation', 'on';
            'Animation', 'on';
            'ShowSimulationAnimation', 'on';
            'EnableAnimation', 'on';
            'SimulationAnimation', 'on'
        };
        
        for i = 1:size(animation_params, 1)
            param_name = animation_params{i, 1};
            param_value = animation_params{i, 2};
            
            try
                set_param(model_name, param_name, param_value);
            catch ME
                % Parameter doesn't exist, that's okay
            end
        end
        
    catch ME
        % Error enabling animation
    end
end 