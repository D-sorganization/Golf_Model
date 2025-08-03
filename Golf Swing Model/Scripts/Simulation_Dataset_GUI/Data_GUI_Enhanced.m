%% 
function Data_GUI_Enhanced()
    % Enhanced Golf Swing Data Generator - Modern GUI with tabbed interface
    % Features: Tabbed structure, pause/resume, post-processing, multiple export formats
    
    % Professional color scheme - softer, muted tones
    colors = struct();
    colors.primary = [0.4, 0.5, 0.6];        % Muted blue-gray
    colors.secondary = [0.5, 0.6, 0.7];      % Lighter blue-gray
    colors.success = [0.4, 0.6, 0.5];        % Muted green
    colors.danger = [0.7, 0.5, 0.5];         % Muted red
    colors.warning = [0.7, 0.6, 0.4];        % Muted amber
    colors.background = [0.96, 0.96, 0.97];  % Very light gray
    colors.panel = [1, 1, 1];                % White
    colors.text = [0.2, 0.2, 0.2];           % Dark gray
    colors.textLight = [0.6, 0.6, 0.6];      % Medium gray
    colors.border = [0.9, 0.9, 0.9];         % Light gray border
    colors.tabActive = [0.8, 0.85, 0.9];     % Light blue for active tab
    colors.tabInactive = [0.95, 0.95, 0.95]; % Light gray for inactive tab
    
    % Create main figure
    screenSize = get(0, 'ScreenSize');
    figWidth = min(1800, screenSize(3) * 0.9);
    figHeight = min(1000, screenSize(4) * 0.9);
    
    fig = figure('Name', 'Enhanced Golf Swing Data Generator', ...
                 'Position', [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'Color', colors.background, ...
                 'CloseRequestFcn', @closeGUICallback);
    
    % Initialize handles structure with preferences
    handles = struct();
    handles.should_stop = false;
    handles.is_paused = false;
    handles.fig = fig;
    handles.colors = colors;
    handles.preferences = struct(); % Initialize empty preferences
    handles.current_tab = 1; % 1 = Generation, 2 = Post-Processing
    handles.checkpoint_data = struct(); % Store checkpoint information
    
    % Load user preferences
    handles = loadUserPreferences(handles);
    
    % Create main layout
    handles = createMainLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
    
    % Apply loaded preferences to UI
    applyUserPreferences(handles);
    
    % Initialize preview
    updatePreview([], [], handles.fig);
    updateCoefficientsPreview([], [], handles.fig);
end

function handles = createMainLayout(fig, handles)
    % Create main layout with professional design and tabbed interface
    colors = handles.colors;
    
    % Main container
    mainPanel = uipanel('Parent', fig, ...
                       'Units', 'normalized', ...
                       'Position', [0, 0, 1, 1], ...
                       'BorderType', 'none', ...
                       'BackgroundColor', colors.background);
    
    % Title bar
    titleHeight = 0.06;
    titlePanel = uipanel('Parent', mainPanel, ...
                        'Units', 'normalized', ...
                        'Position', [0, 1-titleHeight, 1, titleHeight], ...
                        'BackgroundColor', colors.primary, ...
                        'BorderType', 'none');
    
    uicontrol('Parent', titlePanel, ...
              'Style', 'text', ...
              'String', 'Enhanced Golf Swing Data Generator', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.2, 0.4, 0.6], ...
              'FontSize', 14, ...
              'FontWeight', 'normal', ...
              'ForegroundColor', 'white', ...
              'BackgroundColor', colors.primary, ...
              'HorizontalAlignment', 'left');
    
    % Control buttons in title bar
    buttonWidth = 0.07;
    buttonHeight = 0.6;
    buttonSpacing = 0.01;
    buttonY = 0.2;
    
    % Calculate positions to right-align buttons
    totalButtonWidth = 6 * buttonWidth + 5 * buttonSpacing + 0.04;  % 6 buttons + spacing + extra width
    startX = 1.0 - totalButtonWidth - 0.02;  % Right-align with 0.02 margin
    
    % Play/Pause button
    handles.play_pause_button = uicontrol('Parent', titlePanel, ...
                                         'Style', 'pushbutton', ...
                                         'String', '▶ Start', ...
                                         'Units', 'normalized', ...
                                         'Position', [startX, buttonY, buttonWidth, buttonHeight], ...
                                         'BackgroundColor', colors.success, ...
                                         'ForegroundColor', 'white', ...
                                         'FontWeight', 'bold', ...
                                         'Callback', @togglePlayPause);
    
    % Stop button
    handles.stop_button = uicontrol('Parent', titlePanel, ...
                                   'Style', 'pushbutton', ...
                                   'String', '⏹ Stop', ...
                                   'Units', 'normalized', ...
                                   'Position', [startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, buttonHeight], ...
                                   'BackgroundColor', colors.danger, ...
                                   'ForegroundColor', 'white', ...
                                   'FontWeight', 'bold', ...
                                   'Callback', @stopGeneration);
    
    % Checkpoint button
    handles.checkpoint_button = uicontrol('Parent', titlePanel, ...
                                         'Style', 'pushbutton', ...
                                         'String', '💾 Checkpoint', ...
                                         'Units', 'normalized', ...
                                         'Position', [startX + 2*(buttonWidth + buttonSpacing), buttonY, buttonWidth, buttonHeight], ...
                                         'BackgroundColor', colors.warning, ...
                                         'ForegroundColor', 'white', ...
                                         'FontWeight', 'bold', ...
                                         'Callback', @saveCheckpoint);
    
    % Save config button
    handles.save_config_button = uicontrol('Parent', titlePanel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Save Config', ...
                                          'Units', 'normalized', ...
                                          'Position', [startX + 3*(buttonWidth + buttonSpacing), buttonY, buttonWidth + 0.02, buttonHeight], ...
                                          'BackgroundColor', colors.secondary, ...
                                          'ForegroundColor', 'white', ...
                                          'FontWeight', 'bold', ...
                                          'Callback', @saveConfiguration);
    
    % Load config button
    handles.load_config_button = uicontrol('Parent', titlePanel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Load Config', ...
                                          'Units', 'normalized', ...
                                          'Position', [startX + 4*(buttonWidth + buttonSpacing) + 0.02, buttonY, buttonWidth + 0.02, buttonHeight], ...
                                          'BackgroundColor', colors.secondary, ...
                                          'ForegroundColor', 'white', ...
                                          'FontWeight', 'bold', ...
                                          'Callback', @loadConfiguration);
    
    % Tab bar
    tabHeight = 0.04;
    tabBarPanel = uipanel('Parent', mainPanel, ...
                         'Units', 'normalized', ...
                         'Position', [0, 1-titleHeight-tabHeight, 1, tabHeight], ...
                         'BackgroundColor', colors.background, ...
                         'BorderType', 'none');
    
    % Tab buttons
    tabWidth = 0.15;
    tabSpacing = 0.01;
    
    handles.generation_tab = uicontrol('Parent', tabBarPanel, ...
                                      'Style', 'pushbutton', ...
                                      'String', 'Data Generation', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.02, 0.1, tabWidth, 0.8], ...
                                      'BackgroundColor', colors.tabActive, ...
                                      'ForegroundColor', colors.text, ...
                                      'FontWeight', 'bold', ...
                                      'Callback', @switchToGenerationTab);
    
    handles.postprocessing_tab = uicontrol('Parent', tabBarPanel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Post-Processing', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.02 + tabWidth + tabSpacing, 0.1, tabWidth, 0.8], ...
                                          'BackgroundColor', colors.tabInactive, ...
                                          'ForegroundColor', colors.textLight, ...
                                          'FontWeight', 'normal', ...
                                          'Callback', @switchToPostProcessingTab);
    
    % Content area
    contentTop = 1 - titleHeight - tabHeight - 0.01;
    contentPanel = uipanel('Parent', mainPanel, ...
                          'Units', 'normalized', ...
                          'Position', [0.01, 0.01, 0.98, contentTop - 0.01], ...
                          'BorderType', 'none', ...
                          'BackgroundColor', colors.background);
    
    % Create tab content panels
    handles.generation_panel = uipanel('Parent', contentPanel, ...
                                      'Units', 'normalized', ...
                                      'Position', [0, 0, 1, 1], ...
                                      'BackgroundColor', colors.background, ...
                                      'BorderType', 'none', ...
                                      'Visible', 'on');
    
    handles.postprocessing_panel = uipanel('Parent', contentPanel, ...
                                          'Units', 'normalized', ...
                                          'Position', [0, 0, 1, 1], ...
                                          'BackgroundColor', colors.background, ...
                                          'BorderType', 'none', ...
                                          'Visible', 'off');
    
    % Create content for each tab
    handles = createGenerationTabContent(handles.generation_panel, handles);
    handles = createPostProcessingTabContent(handles.postprocessing_panel, handles);
end

function handles = createGenerationTabContent(parent, handles)
    % Create content for the Data Generation tab (similar to original layout)
    colors = handles.colors;
    
    % Two columns - left 10% narrower, right 10% wider
    columnPadding = 0.01;
    columnWidth = (1 - 3*columnPadding) / 2;
    leftColumnWidth = columnWidth * 0.9;  % 10% narrower
    rightColumnWidth = columnWidth * 1.1; % 10% wider
    
    leftPanel = uipanel('Parent', parent, ...
                       'Units', 'normalized', ...
                       'Position', [columnPadding, columnPadding, leftColumnWidth, 1-2*columnPadding], ...
                       'BackgroundColor', colors.panel, ...
                       'BorderType', 'line', ...
                       'BorderWidth', 0.5, ...
                       'HighlightColor', colors.border);
    
    rightPanel = uipanel('Parent', parent, ...
                        'Units', 'normalized', ...
                        'Position', [columnPadding + leftColumnWidth + columnPadding, columnPadding, rightColumnWidth, 1-2*columnPadding], ...
                        'BackgroundColor', colors.panel, ...
                        'BorderType', 'line', ...
                        'BorderWidth', 0.5, ...
                        'HighlightColor', colors.border);
    
    % Store panel references
    handles.generation_leftPanel = leftPanel;
    handles.generation_rightPanel = rightPanel;
    
    % Create content (reuse existing functions)
    handles = createLeftColumnContent(leftPanel, handles);
    handles = createRightColumnContent(rightPanel, handles);
end

function handles = createPostProcessingTabContent(parent, handles)
    % Create content for the Post-Processing tab
    colors = handles.colors;
    
    % Three columns layout for post-processing
    columnPadding = 0.01;
    columnWidth = (1 - 4*columnPadding) / 3;
    
    % Left column - File Selection
    leftPanel = uipanel('Parent', parent, ...
                       'Units', 'normalized', ...
                       'Position', [columnPadding, columnPadding, columnWidth, 1-2*columnPadding], ...
                       'BackgroundColor', colors.panel, ...
                       'BorderType', 'line', ...
                       'BorderWidth', 0.5, ...
                       'HighlightColor', colors.border, ...
                       'Title', 'File Selection');
    
    % Middle column - Processing Options
    middlePanel = uipanel('Parent', parent, ...
                         'Units', 'normalized', ...
                         'Position', [2*columnPadding + columnWidth, columnPadding, columnWidth, 1-2*columnPadding], ...
                         'BackgroundColor', colors.panel, ...
                         'BorderType', 'line', ...
                         'BorderWidth', 0.5, ...
                         'HighlightColor', colors.border, ...
                         'Title', 'Processing Options');
    
    % Right column - Progress & Results
    rightPanel = uipanel('Parent', parent, ...
                        'Units', 'normalized', ...
                        'Position', [3*columnPadding + 2*columnWidth, columnPadding, columnWidth, 1-2*columnPadding], ...
                        'BackgroundColor', colors.panel, ...
                        'BorderType', 'line', ...
                        'BorderWidth', 0.5, ...
                        'HighlightColor', colors.border, ...
                        'Title', 'Progress & Results');
    
    % Create file selection content
    handles = createFileSelectionContent(leftPanel, handles);
    
    % Create processing options content
    handles = createProcessingOptionsContent(middlePanel, handles);
    
    % Create progress and results content
    handles = createProgressResultsContent(rightPanel, handles);
end

function handles = createFileSelectionContent(parent, handles)
    % Create file selection interface
    colors = handles.colors;
    
    % Folder selection
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Data Folder:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.9, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.folder_path_text = uicontrol('Parent', parent, ...
                                        'Style', 'text', ...
                                        'String', 'No folder selected', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05, 0.85, 0.7, 0.04], ...
                                        'HorizontalAlignment', 'left', ...
                                        'BackgroundColor', colors.panel, ...
                                        'ForegroundColor', colors.textLight);
    
    handles.browse_folder_button = uicontrol('Parent', parent, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Browse', ...
                                            'Units', 'normalized', ...
                                            'Position', [0.77, 0.85, 0.18, 0.04], ...
                                            'BackgroundColor', colors.secondary, ...
                                            'ForegroundColor', 'white', ...
                                            'Callback', @browseDataFolder);
    
    % File selection mode
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Selection Mode:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.75, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.selection_mode_group = uibuttongroup('Parent', parent, ...
                                                'Units', 'normalized', ...
                                                'Position', [0.05, 0.6, 0.9, 0.15], ...
                                                'BackgroundColor', colors.panel, ...
                                                'SelectionChangedFcn', @selectionModeChanged);
    
    handles.all_files_radio = uicontrol('Parent', handles.selection_mode_group, ...
                                       'Style', 'radiobutton', ...
                                       'String', 'All files in folder', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.1, 0.6, 0.8, 0.3], ...
                                       'BackgroundColor', colors.panel);
    
    handles.select_files_radio = uicontrol('Parent', handles.selection_mode_group, ...
                                          'Style', 'radiobutton', ...
                                          'String', 'Select specific files', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.1, 0.1, 0.8, 0.3], ...
                                          'BackgroundColor', colors.panel);
    
    % File list
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Selected Files:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.5, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.file_listbox = uicontrol('Parent', parent, ...
                                    'Style', 'listbox', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.05, 0.1, 0.9, 0.4], ...
                                    'BackgroundColor', 'white', ...
                                    'Max', 2, ... % Allow multiple selection
                                    'Min', 0);
    
    % Set default selection
    set(handles.selection_mode_group, 'SelectedObject', handles.all_files_radio);
end

function handles = createProcessingOptionsContent(parent, handles)
    % Create processing options interface
    colors = handles.colors;
    
    % Export format selection
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Export Format:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.9, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.export_format_popup = uicontrol('Parent', parent, ...
                                           'Style', 'popupmenu', ...
                                           'String', {'CSV', 'Parquet', 'MAT', 'JSON'}, ...
                                           'Units', 'normalized', ...
                                           'Position', [0.05, 0.85, 0.9, 0.04], ...
                                           'BackgroundColor', 'white', ...
                                           'Value', 1);
    
    % Batch size selection
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Batch Size (trials per file):', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.75, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.batch_size_popup = uicontrol('Parent', parent, ...
                                        'Style', 'popupmenu', ...
                                        'String', {'10', '25', '50', '100', '250', '500'}, ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05, 0.7, 0.9, 0.04], ...
                                        'BackgroundColor', 'white', ...
                                        'Value', 3); % Default to 50
    
    % Processing options
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Processing Options:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.6, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.generate_features_checkbox = uicontrol('Parent', parent, ...
                                                 'Style', 'checkbox', ...
                                                 'String', 'Generate feature list for ML', ...
                                                 'Units', 'normalized', ...
                                                 'Position', [0.05, 0.55, 0.9, 0.04], ...
                                                 'BackgroundColor', colors.panel, ...
                                                 'Value', 1);
    
    handles.compress_data_checkbox = uicontrol('Parent', parent, ...
                                              'Style', 'checkbox', ...
                                              'String', 'Compress output files', ...
                                              'Units', 'normalized', ...
                                              'Position', [0.05, 0.5, 0.9, 0.04], ...
                                              'BackgroundColor', colors.panel, ...
                                              'Value', 0);
    
    handles.include_metadata_checkbox = uicontrol('Parent', parent, ...
                                                 'Style', 'checkbox', ...
                                                 'String', 'Include metadata', ...
                                                 'Units', 'normalized', ...
                                                 'Position', [0.05, 0.45, 0.9, 0.04], ...
                                                 'BackgroundColor', colors.panel, ...
                                                 'Value', 1);
    
    % Output folder selection
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.35, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.output_path_text = uicontrol('Parent', parent, ...
                                        'Style', 'text', ...
                                        'String', 'Auto-generated', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.05, 0.3, 0.7, 0.04], ...
                                        'HorizontalAlignment', 'left', ...
                                        'BackgroundColor', colors.panel, ...
                                        'ForegroundColor', colors.textLight);
    
    handles.browse_output_button = uicontrol('Parent', parent, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Browse', ...
                                            'Units', 'normalized', ...
                                            'Position', [0.77, 0.3, 0.18, 0.04], ...
                                            'BackgroundColor', colors.secondary, ...
                                            'ForegroundColor', 'white', ...
                                            'Callback', @browseOutputFolder);
    
    % Start processing button
    handles.start_processing_button = uicontrol('Parent', parent, ...
                                               'Style', 'pushbutton', ...
                                               'String', 'Start Processing', ...
                                               'Units', 'normalized', ...
                                               'Position', [0.05, 0.15, 0.9, 0.08], ...
                                               'BackgroundColor', colors.success, ...
                                               'ForegroundColor', 'white', ...
                                               'FontWeight', 'bold', ...
                                               'FontSize', 12, ...
                                               'Callback', @startPostProcessing);
end

function handles = createProgressResultsContent(parent, handles)
    % Create progress and results interface
    colors = handles.colors;
    
    % Progress section
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Processing Progress:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.9, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.progress_text = uicontrol('Parent', parent, ...
                                     'Style', 'text', ...
                                     'String', 'Ready to process', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.05, 0.85, 0.9, 0.04], ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', colors.panel, ...
                                     'ForegroundColor', colors.textLight);
    
    handles.progress_bar = uicontrol('Parent', parent, ...
                                    'Style', 'text', ...
                                    'String', '', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.05, 0.8, 0.9, 0.03], ...
                                    'BackgroundColor', colors.border, ...
                                    'ForegroundColor', colors.success);
    
    % Results section
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Processing Results:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.7, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.results_text = uicontrol('Parent', parent, ...
                                    'Style', 'text', ...
                                    'String', 'No results yet', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.05, 0.65, 0.9, 0.04], ...
                                    'HorizontalAlignment', 'left', ...
                                    'BackgroundColor', colors.panel, ...
                                    'ForegroundColor', colors.textLight);
    
    % Log section
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Processing Log:', ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.55, 0.9, 0.05], ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);
    
    handles.log_text = uicontrol('Parent', parent, ...
                                'Style', 'listbox', ...
                                'Units', 'normalized', ...
                                'Position', [0.05, 0.1, 0.9, 0.45], ...
                                'BackgroundColor', 'white', ...
                                'FontName', 'Monospaced', ...
                                'FontSize', 9);
end

% Tab switching functions
function switchToGenerationTab(~, ~)
    handles = guidata(gcbf);
    handles.current_tab = 1;
    
    % Update tab appearances
    set(handles.generation_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');
    set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
    
    % Show/hide panels
    set(handles.generation_panel, 'Visible', 'on');
    set(handles.postprocessing_panel, 'Visible', 'off');
    
    guidata(handles.fig, handles);
end

function switchToPostProcessingTab(~, ~)
    handles = guidata(gcbf);
    handles.current_tab = 2;
    
    % Update tab appearances
    set(handles.generation_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
    set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');
    
    % Show/hide panels
    set(handles.generation_panel, 'Visible', 'off');
    set(handles.postprocessing_panel, 'Visible', 'on');
    
    guidata(handles.fig, handles);
end

% Enhanced control functions
function togglePlayPause(~, ~)
    handles = guidata(gcbf);
    
    if handles.is_paused
        % Resume from pause
        handles.is_paused = false;
        set(handles.play_pause_button, 'String', '⏸ Pause', 'BackgroundColor', handles.colors.warning);
        % Resume processing logic here
        resumeFromPause(handles);
    else
        % Start or pause
        if ~handles.should_stop && ~isempty(handles.checkpoint_data)
            % Pause current operation
            handles.is_paused = true;
            set(handles.play_pause_button, 'String', '▶ Resume', 'BackgroundColor', handles.colors.success);
        else
            % Start new operation
            startGeneration([], [], handles.fig);
        end
    end
    
    guidata(handles.fig, handles);
end

function saveCheckpoint(~, ~)
    handles = guidata(gcbf);
    
    % Create checkpoint data
    checkpoint = struct();
    checkpoint.timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    checkpoint.gui_state = handles;
    checkpoint.progress = getCurrentProgress(handles);
    
    % Save to file
    checkpoint_file = sprintf('checkpoint_%s.mat', checkpoint.timestamp);
    save(checkpoint_file, 'checkpoint');
    
    % Update GUI
    handles.checkpoint_data = checkpoint;
    set(handles.checkpoint_button, 'String', '💾 Saved', 'BackgroundColor', handles.colors.success);
    
    % Reset button after 2 seconds
    timer_obj = timer('ExecutionMode', 'singleShot', 'StartDelay', 2);
    timer_obj.TimerFcn = @(src, event) resetCheckpointButton(handles);
    start(timer_obj);
    
    guidata(handles.fig, handles);
end

function resetCheckpointButton(handles)
    set(handles.checkpoint_button, 'String', '💾 Checkpoint', 'BackgroundColor', handles.colors.warning);
end

function resumeFromPause(handles)
    % Resume processing from checkpoint
    if ~isempty(handles.checkpoint_data)
        % Restore state and continue processing
        % Implementation depends on specific processing logic
        updateProgressText(handles, 'Resuming from checkpoint...');
    end
end

function getCurrentProgress(handles)
    % Get current progress state
    progress = struct();
    progress.current_trial = 0;
    progress.total_trials = 0;
    progress.current_step = '';
    return progress;
end

% Post-processing functions
function browseDataFolder(~, ~)
    handles = guidata(gcbf);
    
    folder_path = uigetdir('', 'Select Data Folder');
    if folder_path ~= 0
        handles.data_folder = folder_path;
        set(handles.folder_path_text, 'String', folder_path, 'ForegroundColor', handles.colors.text);
        
        % Update file list
        updateFileList(handles);
    end
    
    guidata(handles.fig, handles);
end

function browseOutputFolder(~, ~)
    handles = guidata(gcbf);
    
    folder_path = uigetdir('', 'Select Output Folder');
    if folder_path ~= 0
        handles.output_folder = folder_path;
        set(handles.output_path_text, 'String', folder_path, 'ForegroundColor', handles.colors.text);
    end
    
    guidata(handles.fig, handles);
end

function selectionModeChanged(~, event)
    handles = guidata(gcbf);
    
    if event.NewValue == handles.all_files_radio
        % Show all files in folder
        updateFileList(handles);
    else
        % Allow manual file selection
        selectSpecificFiles(handles);
    end
    
    guidata(handles.fig, handles);
end

function updateFileList(handles)
    if isfield(handles, 'data_folder') && exist(handles.data_folder, 'dir')
        % Get all .mat files in the folder
        files = dir(fullfile(handles.data_folder, '*.mat'));
        file_names = {files.name};
        
        set(handles.file_listbox, 'String', file_names);
        
        if get(handles.selection_mode_group, 'SelectedObject') == handles.all_files_radio
            set(handles.file_listbox, 'Value', 1:length(file_names));
        end
    end
end

function selectSpecificFiles(handles)
    [file_names, path] = uigetfile({'*.mat', 'MATLAB Data Files (*.mat)'}, ...
                                  'Select Files', handles.data_folder, 'MultiSelect', 'on');
    
    if iscell(file_names)
        set(handles.file_listbox, 'String', file_names);
        set(handles.file_listbox, 'Value', 1:length(file_names));
    elseif file_names ~= 0
        set(handles.file_listbox, 'String', {file_names});
        set(handles.file_listbox, 'Value', 1);
    end
end

function startPostProcessing(~, ~)
    handles = guidata(gcbf);
    
    % Get selected files
    file_list = get(handles.file_listbox, 'String');
    selected_indices = get(handles.file_listbox, 'Value');
    
    if isempty(file_list) || isempty(selected_indices)
        errordlg('Please select files to process.', 'No Files Selected');
        return;
    end
    
    selected_files = file_list(selected_indices);
    
    % Get processing options
    export_format = get(handles.export_format_popup, 'String');
    export_format = export_format{get(handles.export_format_popup, 'Value')};
    
    batch_size_str = get(handles.batch_size_popup, 'String');
    batch_size = str2double(batch_size_str{get(handles.batch_size_popup, 'Value')});
    
    generate_features = get(handles.generate_features_checkbox, 'Value');
    compress_data = get(handles.compress_data_checkbox, 'Value');
    include_metadata = get(handles.include_metadata_checkbox, 'Value');
    
    % Get output folder
    if isfield(handles, 'output_folder')
        output_folder = handles.output_folder;
    else
        output_folder = fullfile(handles.data_folder, 'processed_data');
        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end
    end
    
    % Start processing in background
    processing_data = struct();
    processing_data.selected_files = selected_files;
    processing_data.data_folder = handles.data_folder;
    processing_data.output_folder = output_folder;
    processing_data.export_format = export_format;
    processing_data.batch_size = batch_size;
    processing_data.generate_features = generate_features;
    processing_data.compress_data = compress_data;
    processing_data.include_metadata = include_metadata;
    processing_data.handles = handles;
    
    % Start background processing
    startBackgroundProcessing(processing_data);
end

function startBackgroundProcessing(processing_data)
    % Start processing in a separate thread/background
    % This is a simplified version - in practice, you might want to use
    % parallel processing or a timer-based approach
    
    % Update GUI to show processing started
    handles = processing_data.handles;
    set(handles.progress_text, 'String', 'Processing started...', 'ForegroundColor', handles.colors.text);
    set(handles.start_processing_button, 'Enable', 'off');
    
    % Simulate processing (replace with actual processing logic)
    processFiles(processing_data);
end

function processFiles(processing_data)
    % Process files according to specifications
    handles = processing_data.handles;
    
    try
        total_files = length(processing_data.selected_files);
        batch_size = processing_data.batch_size;
        num_batches = ceil(total_files / batch_size);
        
        % Initialize feature list if requested
        if processing_data.generate_features
            feature_list = initializeFeatureList();
        end
        
        for batch_idx = 1:num_batches
            % Update progress
            progress_msg = sprintf('Processing batch %d/%d...', batch_idx, num_batches);
            set(handles.progress_text, 'String', progress_msg);
            
            % Calculate batch indices
            start_idx = (batch_idx - 1) * batch_size + 1;
            end_idx = min(batch_idx * batch_size, total_files);
            batch_files = processing_data.selected_files(start_idx:end_idx);
            
            % Process batch
            batch_data = processBatch(batch_files, processing_data);
            
            % Export batch
            exportBatch(batch_data, batch_idx, processing_data);
            
            % Update feature list
            if processing_data.generate_features
                feature_list = updateFeatureList(feature_list, batch_data);
            end
            
            % Update progress bar
            progress_ratio = batch_idx / num_batches;
            updateProgressBar(handles, progress_ratio);
            
            % Add to log
            addToLog(handles, sprintf('Completed batch %d/%d (%d files)', batch_idx, num_batches, length(batch_files)));
        end
        
        % Finalize processing
        if processing_data.generate_features
            exportFeatureList(feature_list, processing_data.output_folder);
        end
        
        % Update results
        set(handles.results_text, 'String', sprintf('Processing complete! %d files processed in %d batches.', total_files, num_batches));
        set(handles.progress_text, 'String', 'Processing complete');
        set(handles.start_processing_button, 'Enable', 'on');
        
        addToLog(handles, 'Processing completed successfully');
        
    catch ME
        % Handle errors
        set(handles.results_text, 'String', sprintf('Error: %s', ME.message));
        set(handles.progress_text, 'String', 'Processing failed');
        set(handles.start_processing_button, 'Enable', 'on');
        
        addToLog(handles, sprintf('ERROR: %s', ME.message));
    end
end

function batch_data = processBatch(batch_files, processing_data)
    % Process a batch of files
    batch_data = struct();
    batch_data.trials = cell(length(batch_files), 1);
    
    for i = 1:length(batch_files)
        file_path = fullfile(processing_data.data_folder, batch_files{i});
        
        try
            % Load data
            data = load(file_path);
            
            % Process data (simplified - replace with actual processing)
            processed_trial = processTrialData(data);
            
            batch_data.trials{i} = processed_trial;
            
        catch ME
            warning('Failed to process file %s: %s', batch_files{i}, ME.message);
        end
    end
    
    % Remove empty trials
    batch_data.trials = batch_data.trials(~cellfun(@isempty, batch_data.trials));
end

function processed_trial = processTrialData(data)
    % Process individual trial data
    % This is a placeholder - implement actual data processing logic
    processed_trial = data;
end

function exportBatch(batch_data, batch_idx, processing_data)
    % Export batch data in specified format
    output_file = fullfile(processing_data.output_folder, ...
                          sprintf('batch_%03d.%s', batch_idx, lower(processing_data.export_format)));
    
    switch lower(processing_data.export_format)
        case 'csv'
            exportToCSV(batch_data, output_file);
        case 'parquet'
            exportToParquet(batch_data, output_file);
        case 'mat'
            exportToMAT(batch_data, output_file);
        case 'json'
            exportToJSON(batch_data, output_file);
    end
end

function exportToCSV(batch_data, output_file)
    % Export to CSV format
    % Implementation depends on data structure
    warning('CSV export not yet implemented');
end

function exportToParquet(batch_data, output_file)
    % Export to Parquet format
    % Implementation depends on data structure
    warning('Parquet export not yet implemented');
end

function exportToMAT(batch_data, output_file)
    % Export to MAT format
    save(output_file, '-struct', 'batch_data');
end

function exportToJSON(batch_data, output_file)
    % Export to JSON format
    % Implementation depends on data structure
    warning('JSON export not yet implemented');
end

function feature_list = initializeFeatureList()
    % Initialize feature list for machine learning
    feature_list = struct();
    feature_list.features = {};
    feature_list.descriptions = {};
    feature_list.units = {};
    feature_list.ranges = {};
    feature_list.categories = {};
end

function feature_list = updateFeatureList(feature_list, batch_data)
    % Update feature list with new data
    % This is a placeholder - implement actual feature extraction
    return feature_list;
end

function exportFeatureList(feature_list, output_folder)
    % Export feature list for Python/ML use
    feature_file = fullfile(output_folder, 'feature_list.json');
    
    % Convert to JSON-compatible format
    feature_data = struct();
    feature_data.features = feature_list.features;
    feature_data.descriptions = feature_list.descriptions;
    feature_data.units = feature_list.units;
    feature_data.ranges = feature_list.ranges;
    feature_data.categories = feature_list.categories;
    
    % Write to JSON file
    feature_json = jsonencode(feature_data, 'PrettyPrint', true);
    fid = fopen(feature_file, 'w');
    fprintf(fid, '%s', feature_json);
    fclose(fid);
end

function updateProgressBar(handles, ratio)
    % Update progress bar
    bar_width = ratio * 0.9;
    set(handles.progress_bar, 'Position', [0.05, 0.8, bar_width, 0.03]);
end

function addToLog(handles, message)
    % Add message to log
    current_log = get(handles.log_text, 'String');
    if ischar(current_log)
        current_log = {current_log};
    end
    
    timestamp = datestr(now, 'HH:MM:SS');
    new_entry = sprintf('[%s] %s', timestamp, message);
    
    updated_log = [current_log; {new_entry}];
    
    % Keep only last 100 entries
    if length(updated_log) > 100
        updated_log = updated_log(end-99:end);
    end
    
    set(handles.log_text, 'String', updated_log);
    set(handles.log_text, 'Value', length(updated_log));
    drawnow;
end

function updateProgressText(handles, message)
    % Update progress text
    set(handles.progress_text, 'String', message);
    drawnow;
end

% Include all the existing functions from the original Data_GUI.m
% (These would be copied from the original file)

% Placeholder for existing functions - these need to be copied from the original
function handles = loadUserPreferences(handles)
    % Load user preferences
    % Implementation from original Data_GUI.m
end

function applyUserPreferences(handles)
    % Apply user preferences to UI
    % Implementation from original Data_GUI.m
end

function closeGUICallback(~, ~)
    % Close GUI callback
    % Implementation from original Data_GUI.m
end

function startGeneration(~, ~, fig)
    % Start generation
    % Implementation from original Data_GUI.m
end

function stopGeneration(~, ~)
    % Stop generation
    % Implementation from original Data_GUI.m
end

function saveConfiguration(~, ~)
    % Save configuration
    % Implementation from original Data_GUI.m
end

function loadConfiguration(~, ~)
    % Load configuration
    % Implementation from original Data_GUI.m
end

function updatePreview(~, ~, fig)
    % Update preview
    % Implementation from original Data_GUI.m
end

function updateCoefficientsPreview(~, ~, fig)
    % Update coefficients preview
    % Implementation from original Data_GUI.m
end

function handles = createLeftColumnContent(parent, handles)
    % Create left column content
    % Implementation from original Data_GUI.m
end

function handles = createRightColumnContent(parent, handles)
    % Create right column content
    % Implementation from original Data_GUI.m
end 