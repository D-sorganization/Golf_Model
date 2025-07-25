function GolfSwingDataGeneratorGUI()
    % GolfSwingDataGeneratorGUI - Modern GUI for generating golf swing training data
    % This GUI provides an intuitive interface for configuring and running
    % multiple simulation trials with different torque scenarios and data sources.
    
    % Create main figure with modern styling
    fig = figure('Name', 'Golf Swing Data Generator', ...
                 'Position', [100, 100, 1200, 800], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'on', ...
                 'Color', [0.94, 0.94, 0.94]);
    
    % Initialize handles structure
    handles = struct();
    handles.should_stop = false;
    
    % Create main layout with panels
    createMainLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
end

function createMainLayout(fig, handles)
    % Create the main layout with all panels and controls
    
    % Title panel
    title_panel = uipanel('Parent', fig, ...
                         'Title', 'Golf Swing Data Generator', ...
                         'TitlePosition', 'centertop', ...
                         'FontSize', 16, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.02, 0.92, 0.96, 0.07], ...
                         'BackgroundColor', [0.9, 0.9, 0.95]);
    
    % Main content area with scrollable panels
    main_panel = uipanel('Parent', fig, ...
                        'Position', [0.02, 0.05, 0.96, 0.85], ...
                        'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Create left and right columns
    left_column = uipanel('Parent', main_panel, ...
                         'Position', [0.02, 0.02, 0.48, 0.96], ...
                         'BackgroundColor', [0.94, 0.94, 0.94]);
    
    right_column = uipanel('Parent', main_panel, ...
                          'Position', [0.52, 0.02, 0.46, 0.96], ...
                          'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Create panels in left column
    createTrialSettingsPanel(left_column, handles);
    createDataSourcesPanel(left_column, handles);
    createModelingPanel(left_column, handles);
    
    % Create panels in right column
    createOutputSettingsPanel(right_column, handles);
    createPreviewPanel(right_column, handles);
    createProgressPanel(right_column, handles);
    
    % Store panel references
    handles.left_column = left_column;
    handles.right_column = right_column;
    handles.main_panel = main_panel;
end

function createTrialSettingsPanel(parent, handles)
    % Trial Settings Panel
    trial_panel = uipanel('Parent', parent, ...
                         'Title', 'Trial Settings', ...
                         'TitlePosition', 'centertop', ...
                         'FontSize', 12, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.02, 0.75, 0.96, 0.23], ...
                         'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Number of trials
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Number of Trials:', ...
              'Position', [10, 120, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.num_trials_edit = uicontrol('Parent', trial_panel, ...
                                       'Style', 'edit', ...
                                       'String', '10', ...
                                       'Position', [140, 120, 80, 25], ...
                                       'FontSize', 10);
    
    % Simulation duration
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Simulation Duration (s):', ...
              'Position', [10, 85, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.sim_time_edit = uicontrol('Parent', trial_panel, ...
                                     'Style', 'edit', ...
                                     'String', '0.3', ...
                                     'Position', [140, 85, 80, 25], ...
                                     'FontSize', 10);
    
    % Sample rate
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Sample Rate (Hz):', ...
              'Position', [10, 50, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.sample_rate_edit = uicontrol('Parent', trial_panel, ...
                                        'Style', 'edit', ...
                                        'String', '100', ...
                                        'Position', [140, 50, 80, 25], ...
                                        'FontSize', 10);
    
    % Execution mode
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Execution Mode:', ...
              'Position', [10, 15, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.execution_mode_popup = uicontrol('Parent', trial_panel, ...
                                            'Style', 'popupmenu', ...
                                            'String', {'Sequential', 'Parallel'}, ...
                                            'Position', [140, 15, 100, 25], ...
                                            'FontSize', 10);
    
    % Store panel reference
    handles.trial_panel = trial_panel;
end

function createDataSourcesPanel(parent, handles)
    % Data Sources Panel
    data_panel = uipanel('Parent', parent, ...
                        'Title', 'Data Sources', ...
                        'TitlePosition', 'centertop', ...
                        'FontSize', 12, ...
                        'FontWeight', 'bold', ...
                        'Position', [0.02, 0.50, 0.96, 0.23], ...
                        'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Checkboxes for data sources
    handles.use_model_workspace = uicontrol('Parent', data_panel, ...
                                           'Style', 'checkbox', ...
                                           'String', 'Model Workspace (Parameters)', ...
                                           'Position', [10, 120, 200, 25], ...
                                           'Value', 1, ...
                                           'FontSize', 10);
    
    handles.use_logsout = uicontrol('Parent', data_panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Logsout (Standard Logging)', ...
                                   'Position', [10, 90, 200, 25], ...
                                   'Value', 1, ...
                                   'FontSize', 10);
    
    handles.use_signal_bus = uicontrol('Parent', data_panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'Signal Bus (ToWorkspace Blocks)', ...
                                      'Position', [10, 60, 200, 25], ...
                                      'Value', 1, ...
                                      'FontSize', 10);
    
    handles.use_simscape = uicontrol('Parent', data_panel, ...
                                    'Style', 'checkbox', ...
                                    'String', 'Simscape Results (Primary Data)', ...
                                    'Position', [10, 30, 200, 25], ...
                                    'Value', 1, ...
                                    'FontSize', 10);
    
    % Store panel reference
    handles.data_panel = data_panel;
end

function createModelingPanel(parent, handles)
    % Modeling Mode & Torque Scenarios Panel
    modeling_panel = uipanel('Parent', parent, ...
                            'Title', 'Modeling Mode & Torque Scenarios', ...
                            'TitlePosition', 'centertop', ...
                            'FontSize', 12, ...
                            'FontWeight', 'bold', ...
                            'Position', [0.02, 0.25, 0.96, 0.23], ...
                            'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Torque scenario selection
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Torque Scenario:', ...
              'Position', [10, 120, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.torque_scenario_popup = uicontrol('Parent', modeling_panel, ...
                                             'Style', 'popupmenu', ...
                                             'String', {'Variable Torques', 'Zero Torque', 'Constant Torque'}, ...
                                             'Position', [140, 120, 150, 25], ...
                                             'FontSize', 10, ...
                                             'Callback', @torqueScenarioCallback);
    
    % Coefficient range (for variable torques)
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Coefficient Range:', ...
              'Position', [10, 85, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.coeff_range_edit = uicontrol('Parent', modeling_panel, ...
                                        'Style', 'edit', ...
                                        'String', '0.1', ...
                                        'Position', [140, 85, 80, 25], ...
                                        'FontSize', 10);
    
    % Constant value (for constant torque)
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Constant Value:', ...
              'Position', [10, 50, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.constant_value_edit = uicontrol('Parent', modeling_panel, ...
                                           'Style', 'edit', ...
                                           'String', '1.0', ...
                                           'Position', [140, 50, 80, 25], ...
                                           'FontSize', 10);
    
    % Explanation text
    explanation_text = sprintf(['Torque Scenarios:\n', ...
                               '• Variable Torques: All polynomial coefficients (A-G) are randomly varied\n', ...
                               '• Zero Torque: All coefficients set to zero (no joint torques)\n', ...
                               '• Constant Torque: Coefficients A-F=0, G=constant value']);
    
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', explanation_text, ...
              'Position', [10, 5, 280, 40], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9, ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Store panel reference
    handles.modeling_panel = modeling_panel;
end

function createOutputSettingsPanel(parent, handles)
    % Output Settings Panel
    output_panel = uipanel('Parent', parent, ...
                          'Title', 'Output Settings', ...
                          'TitlePosition', 'centertop', ...
                          'FontSize', 12, ...
                          'FontWeight', 'bold', ...
                          'Position', [0.02, 0.75, 0.96, 0.23], ...
                          'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Output folder selection
    uicontrol('Parent', output_panel, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Position', [10, 120, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.output_folder_edit = uicontrol('Parent', output_panel, ...
                                          'Style', 'edit', ...
                                          'String', pwd, ...
                                          'Position', [140, 120, 200, 25], ...
                                          'FontSize', 10);
    
    handles.browse_button = uicontrol('Parent', output_panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Browse...', ...
                                     'Position', [350, 120, 80, 25], ...
                                     'FontSize', 10, ...
                                     'Callback', @browseOutputFolder);
    
    % Folder name
    uicontrol('Parent', output_panel, ...
              'Style', 'text', ...
              'String', 'Folder Name:', ...
              'Position', [10, 85, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10);
    
    handles.folder_name_edit = uicontrol('Parent', output_panel, ...
                                        'Style', 'edit', ...
                                        'String', 'training_data_csv', ...
                                        'Position', [140, 85, 200, 25], ...
                                        'FontSize', 10);
    
    % Start generation button
    handles.start_button = uicontrol('Parent', output_panel, ...
                                    'Style', 'pushbutton', ...
                                    'String', 'Start Generation', ...
                                    'Position', [140, 50, 120, 35], ...
                                    'FontSize', 12, ...
                                    'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.2, 0.6, 0.2], ...
                                    'ForegroundColor', 'white', ...
                                    'Callback', @startGeneration);
    
    % Stop generation button
    handles.stop_button = uicontrol('Parent', output_panel, ...
                                   'Style', 'pushbutton', ...
                                   'String', 'Stop', ...
                                   'Position', [270, 50, 80, 35], ...
                                   'FontSize', 12, ...
                                   'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.8, 0.2, 0.2], ...
                                   'ForegroundColor', 'white', ...
                                   'Callback', @stopGeneration, ...
                                   'Enable', 'off');
    
    % Store panel reference
    handles.output_panel = output_panel;
end

function createPreviewPanel(parent, handles)
    % Preview Panel for Input Parameters
    preview_panel = uipanel('Parent', parent, ...
                           'Title', 'Input Parameters Preview', ...
                           'TitlePosition', 'centertop', ...
                           'FontSize', 12, ...
                           'FontWeight', 'bold', ...
                           'Position', [0.02, 0.25, 0.96, 0.48], ...
                           'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Preview table
    handles.preview_table = uitable('Parent', preview_panel, ...
                                   'Position', [10, 10, 460, 200], ...
                                   'ColumnName', {'Parameter', 'Value', 'Description'}, ...
                                   'ColumnWidth', {150, 100, 200}, ...
                                   'FontSize', 9);
    
    % Update preview button
    handles.update_preview_button = uicontrol('Parent', preview_panel, ...
                                             'Style', 'pushbutton', ...
                                             'String', 'Update Preview', ...
                                             'Position', [10, 220, 120, 25], ...
                                             'FontSize', 10, ...
                                             'Callback', @updatePreview);
    
    % Store panel reference
    handles.preview_panel = preview_panel;
end

function createProgressPanel(parent, handles)
    % Progress Panel
    progress_panel = uipanel('Parent', parent, ...
                            'Title', 'Progress & Log', ...
                            'TitlePosition', 'centertop', ...
                            'FontSize', 12, ...
                            'FontWeight', 'bold', ...
                            'Position', [0.02, 0.02, 0.96, 0.21], ...
                            'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Progress bar
    handles.progress_bar = uicontrol('Parent', progress_panel, ...
                                    'Style', 'text', ...
                                    'String', 'Ready to start', ...
                                    'Position', [10, 120, 460, 20], ...
                                    'HorizontalAlignment', 'left', ...
                                    'FontSize', 10, ...
                                    'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % Status text
    handles.status_text = uicontrol('Parent', progress_panel, ...
                                   'Style', 'text', ...
                                   'String', 'Status: Ready', ...
                                   'Position', [10, 95, 460, 20], ...
                                   'HorizontalAlignment', 'left', ...
                                   'FontSize', 10);
    
    % Log text area
    handles.log_text = uicontrol('Parent', progress_panel, ...
                                'Style', 'listbox', ...
                                'String', {'Log will appear here...'}, ...
                                'Position', [10, 10, 460, 80], ...
                                'FontSize', 9, ...
                                'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Store panel reference
    handles.progress_panel = progress_panel;
end

% Callback functions
function torqueScenarioCallback(hObject, ~)
    % Handle torque scenario selection
    fig = ancestor(hObject, 'figure');
    handles = guidata(fig);
    
    scenario_idx = get(hObject, 'Value');
    
    % Enable/disable controls based on scenario
    switch scenario_idx
        case 1 % Variable Torques
            set(handles.coeff_range_edit, 'Enable', 'on');
            set(handles.constant_value_edit, 'Enable', 'off');
        case 2 % Zero Torque
            set(handles.coeff_range_edit, 'Enable', 'off');
            set(handles.constant_value_edit, 'Enable', 'off');
        case 3 % Constant Torque
            set(handles.coeff_range_edit, 'Enable', 'off');
            set(handles.constant_value_edit, 'Enable', 'on');
    end
    
    % Update preview
    updatePreview(handles.update_preview_button, []);
end

function browseOutputFolder(hObject, ~)
    % Browse for output folder
    fig = ancestor(hObject, 'figure');
    handles = guidata(fig);
    
    folder = uigetdir(get(handles.output_folder_edit, 'String'), 'Select Output Folder');
    if folder ~= 0
        set(handles.output_folder_edit, 'String', folder);
    end
end

function updatePreview(hObject, ~)
    % Update the preview table with current settings
    fig = ancestor(hObject, 'figure');
    handles = guidata(fig);
    
    try
        % Collect current settings
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        sim_time = str2double(get(handles.sim_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        % Create preview data
        preview_data = {
            'Number of Trials', num2str(num_trials), 'Total simulations to run';
            'Simulation Time', [num2str(sim_time) ' s'], 'Duration of each simulation';
            'Sample Rate', [num2str(sample_rate) ' Hz'], 'Data sampling frequency';
            'Modeling Mode', '3 (Hex Polynomial)', 'Polynomial input function mode';
            'Torque Scenario', get(handles.torque_scenario_popup, 'String'), 'Joint torque generation method';
        };
        
        % Add scenario-specific parameters
        switch scenario_idx
            case 1 % Variable Torques
                preview_data = [preview_data; {'Coefficient Range', num2str(coeff_range), 'Random variation range for all coefficients'}];
            case 2 % Zero Torque
                preview_data = [preview_data; {'All Coefficients', '0', 'No joint torques applied'}];
            case 3 % Constant Torque
                preview_data = [preview_data; {'Constant Value', num2str(constant_value), 'G coefficient value (A-F=0)'}];
        end
        
        % Add data sources
        data_sources = {};
        if get(handles.use_model_workspace, 'Value')
            data_sources{end+1} = 'Model Workspace';
        end
        if get(handles.use_logsout, 'Value')
            data_sources{end+1} = 'Logsout';
        end
        if get(handles.use_signal_bus, 'Value')
            data_sources{end+1} = 'Signal Bus';
        end
        if get(handles.use_simscape, 'Value')
            data_sources{end+1} = 'Simscape Results';
        end
        
        preview_data = [preview_data; {'Data Sources', strjoin(data_sources, ', '), 'Data extraction methods'}];
        
        % Update table
        set(handles.preview_table, 'Data', preview_data);
        
    catch ME
        % Handle errors gracefully
        set(handles.preview_table, 'Data', {'Error', 'Invalid input', 'Please check your settings'});
    end
end

function startGeneration(hObject, ~)
    % Start the data generation process
    fig = ancestor(hObject, 'figure');
    handles = guidata(fig);
    
    try
        % Validate inputs
        config = validateInputs(handles);
        if isempty(config)
            return;
        end
        
        % Update UI state
        set(handles.start_button, 'Enable', 'off');
        set(handles.stop_button, 'Enable', 'on');
        handles.should_stop = false;
        
        % Store config in handles
        handles.config = config;
        guidata(fig, handles);
        
        % Start generation in background
        run_generation(handles);
        
    catch ME
        update_log(sprintf('Error starting generation: %s', ME.message), handles);
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
    end
end

function stopGeneration(hObject, ~)
    % Stop the data generation process
    fig = ancestor(hObject, 'figure');
    handles = guidata(fig);
    
    handles.should_stop = true;
    guidata(fig, handles);
    
    update_log('Stopping generation...', handles);
end

function config = validateInputs(handles)
    % Validate user inputs and create config structure
    try
        % Get basic settings
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        sim_time = str2double(get(handles.sim_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        
        % Validate numeric inputs
        if isnan(num_trials) || num_trials <= 0
            error('Number of trials must be a positive number');
        end
        if isnan(sim_time) || sim_time <= 0
            error('Simulation time must be a positive number');
        end
        if isnan(sample_rate) || sample_rate <= 0
            error('Sample rate must be a positive number');
        end
        
        % Get torque scenario settings
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        if scenario_idx == 1 && (isnan(coeff_range) || coeff_range <= 0)
            error('Coefficient range must be a positive number for variable torques');
        end
        if scenario_idx == 3 && isnan(constant_value)
            error('Constant value must be a valid number');
        end
        
        % Get output settings
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        
        if isempty(output_folder) || isempty(folder_name)
            error('Please specify output folder and folder name');
        end
        
        % Create config structure
        config = struct();
        config.model_name = 'GolfSwing3D_Kinetic';
        config.num_simulations = num_trials;
        config.simulation_time = sim_time;
        config.sample_rate = sample_rate;
        config.modeling_mode = 3; % Always use hex polynomial mode
        config.torque_scenario = scenario_idx;
        config.coeff_range = coeff_range;
        config.constant_value = constant_value;
        config.use_model_workspace = get(handles.use_model_workspace, 'Value');
        config.use_logsout = get(handles.use_logsout, 'Value');
        config.use_signal_bus = get(handles.use_signal_bus, 'Value');
        config.use_simscape = get(handles.use_simscape, 'Value');
        config.execution_mode = get(handles.execution_mode_popup, 'String');
        config.execution_mode = config.execution_mode{get(handles.execution_mode_popup, 'Value')};
        config.output_folder = fullfile(output_folder, folder_name);
        
        % Validate that at least one data source is selected
        if ~config.use_model_workspace && ~config.use_logsout && ~config.use_signal_bus && ~config.use_simscape
            error('Please select at least one data source');
        end
        
    catch ME
        errordlg(ME.message, 'Validation Error');
        config = [];
    end
end

function run_generation(handles)
    % Main generation function
    try
        config = handles.config;
        
        % Create output folder
        if ~exist(config.output_folder, 'dir')
            mkdir(config.output_folder);
            update_log(sprintf('✓ Created output folder: %s', config.output_folder), handles);
        else
            update_log(sprintf('✓ Using existing folder: %s', config.output_folder), handles);
        end
        
        % Initialize results
        results = cell(config.num_simulations, 1);
        successful_trials = 0;
        failed_trials = 0;
        
        update_log(sprintf('Starting generation of %d trials...', config.num_simulations), handles);
        update_status('Initializing...', handles);
        
        % Run trials based on execution mode
        if strcmp(config.execution_mode, 'parallel')
            update_log('Running trials in parallel...', handles);
            
            % Use parfor for parallel execution
            parfor sim_idx = 1:config.num_simulations
                try
                    result = runSingleTrial(sim_idx, config);
                    results{sim_idx} = result;
                catch ME
                    results{sim_idx} = struct('success', false, 'error', ME.message);
                end
            end
            
            % Process results after parallel execution
            for sim_idx = 1:config.num_simulations
                if handles.should_stop
                    update_log('Generation stopped by user', handles);
                    break;
                end
                
                result = results{sim_idx};
                if result.success
                    successful_trials = successful_trials + 1;
                    update_log(sprintf('Trial %d: Success (%d rows, %d columns)', ...
                        sim_idx, result.data_points, result.columns), handles);
                else
                    failed_trials = failed_trials + 1;
                    update_log(sprintf('Trial %d: Failed - %s', sim_idx, result.error), handles);
                end
                
                % Update progress
                progress = sim_idx / config.num_simulations * 100;
                update_progress(sprintf('Trial %d/%d (%.1f%%)', sim_idx, config.num_simulations, progress), handles);
                update_status(sprintf('Processing trial %d...', sim_idx), handles);
            end
        else
            update_log('Running trials sequentially...', handles);
            for sim_idx = 1:config.num_simulations
                if handles.should_stop
                    update_log('Generation stopped by user', handles);
                    break;
                end
                
                % Update progress
                progress = (sim_idx - 1) / config.num_simulations * 100;
                update_progress(sprintf('Trial %d/%d (%.1f%%)', sim_idx, config.num_simulations, progress), handles);
                update_status(sprintf('Processing trial %d...', sim_idx), handles);
                
                try
                    result = runSingleTrial(sim_idx, config);
                    results{sim_idx} = result;
                    
                    if result.success
                        successful_trials = successful_trials + 1;
                        update_log(sprintf('Trial %d: Success (%d rows, %d columns)', ...
                            sim_idx, result.data_points, result.columns), handles);
                    else
                        failed_trials = failed_trials + 1;
                        update_log(sprintf('Trial %d: Failed - %s', sim_idx, result.error), handles);
                    end
                    
                catch ME
                    failed_trials = failed_trials + 1;
                    results{sim_idx} = struct('success', false, 'error', ME.message);
                    update_log(sprintf('Trial %d: Error - %s', sim_idx, ME.message), handles);
                end
            end
        end
        
        % Final summary
        update_log(sprintf('Generation complete! Success: %d, Failed: %d', successful_trials, failed_trials), handles);
        update_progress(sprintf('Complete! Success rate: %.1f%%', 100 * successful_trials / config.num_simulations), handles);
        update_status('Generation complete', handles);
        
    catch ME
        update_log(sprintf('Generation error: %s', ME.message), handles);
        update_status('Error occurred', handles);
    end
    
    % Reset UI state
    fig = ancestor(handles.start_button, 'figure');
    set(handles.start_button, 'Enable', 'on');
    set(handles.stop_button, 'Enable', 'off');
    handles.should_stop = false;
    guidata(fig, handles);
end

% Helper functions for UI updates
function update_log(message, handles)
    % Add message to log
    current_log = get(handles.log_text, 'String');
    if ischar(current_log)
        current_log = {current_log};
    end
    
    % Add timestamp
    timestamp = datestr(now, 'HH:MM:SS');
    new_message = sprintf('[%s] %s', timestamp, message);
    
    % Add to log (keep last 100 messages)
    current_log{end+1} = new_message;
    if length(current_log) > 100
        current_log = current_log(end-99:end);
    end
    
    set(handles.log_text, 'String', current_log);
    set(handles.log_text, 'Value', length(current_log));
    drawnow;
end

function update_progress(message, handles)
    % Update progress display
    set(handles.progress_bar, 'String', message);
    drawnow;
end

function update_status(message, handles)
    % Update status display
    set(handles.status_text, 'String', sprintf('Status: %s', message));
    drawnow;
end

% Note: The following functions have been moved to standalone files to enable parallel execution:
% - runSingleTrial.m
% - generatePolynomialCoefficients.m  
% - setPolynomialVariables.m
% - extractCompleteTrialData.m
% - GolfSwingDataGeneratorHelpers.m (contains all helper functions)

% Include helper functions from GolfSwingDataGeneratorHelpers.m
% These functions are defined in the separate helper file
end 