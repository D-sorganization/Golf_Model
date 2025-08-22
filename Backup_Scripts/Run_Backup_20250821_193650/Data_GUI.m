%%
function Data_GUI()
% Enhanced Golf Swing Data Generator - Modern GUI with tabbed interface
% Features: Tabbed structure, pause/resume, post-processing, multiple export formats

% Add current directory to path to ensure all functions are accessible
current_dir = fileparts(mfilename('fullpath'));
if ~contains(path, current_dir)
    addpath(current_dir);
end

% Force MATLAB to refresh function cache for this directory
rehash('path');

% Verify critical functions are accessible
if ~exist('initializeLocalCluster', 'file')
    warning('initializeLocalCluster not found. Adding path and retrying...');
    addpath(genpath(current_dir));
    rehash('path');
end

% Professional color scheme - sharp, vibrant tones
colors = struct();
colors.primary = [0.2, 0.4, 0.8];        % Sharp blue
colors.secondary = [0.3, 0.5, 0.9];      % Bright blue
colors.success = [0.2, 0.7, 0.3];        % Sharp green
colors.danger = [0.8, 0.2, 0.2];         % Sharp red
colors.warning = [0.9, 0.6, 0.1];        % Sharp amber
colors.background = [0.95, 0.95, 0.97];  % Slightly cooler background
colors.panel = [1, 1, 1];                % White
colors.text = [0.1, 0.1, 0.1];           % Very dark gray
colors.textLight = [0.4, 0.4, 0.4];      % Darker medium gray
colors.border = [0.8, 0.8, 0.8];         % Darker gray border
colors.tabActive = [0.7, 0.8, 1.0];      % Bright blue for active tab
colors.tabInactive = [0.9, 0.9, 0.9];    % Light gray for inactive tab
colors.lightGrey = [0.85, 0.85, 0.85];   % Light grey for main text buttons

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

% Load performance preferences after ensuring UI is fully ready
handles = loadPerformancePreferencesWhenReady(handles);
guidata(fig, handles);

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
    'String', 'Start', ...
    'Units', 'normalized', ...
    'Position', [startX, buttonY, buttonWidth, buttonHeight], ...
    'BackgroundColor', colors.success, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @togglePlayPause);

% Stop button
handles.stop_button = uicontrol('Parent', titlePanel, ...
    'Style', 'pushbutton', ...
    'String', 'Stop', ...
    'Units', 'normalized', ...
    'Position', [startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, buttonHeight], ...
    'BackgroundColor', colors.danger, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @stopGeneration);

% Checkpoint button
handles.checkpoint_button = uicontrol('Parent', titlePanel, ...
    'Style', 'pushbutton', ...
    'String', 'Checkpoint', ...
    'Units', 'normalized', ...
    'Position', [startX + 2*(buttonWidth + buttonSpacing), buttonY, buttonWidth, buttonHeight], ...
    'BackgroundColor', colors.secondary, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @saveCheckpoint);

% Save config button
handles.save_config_button = uicontrol('Parent', titlePanel, ...
    'Style', 'pushbutton', ...
    'String', 'Save Config', ...
    'Units', 'normalized', ...
    'Position', [startX + 3*(buttonWidth + buttonSpacing), buttonY, buttonWidth + 0.02, buttonHeight], ...
    'BackgroundColor', colors.secondary, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @saveConfiguration);

% Load config button
handles.load_config_button = uicontrol('Parent', titlePanel, ...
    'Style', 'pushbutton', ...
    'String', 'Load Config', ...
    'Units', 'normalized', ...
    'Position', [startX + 4*(buttonWidth + buttonSpacing) + 0.02, buttonY, buttonWidth + 0.02, buttonHeight], ...
    'BackgroundColor', colors.secondary, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
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
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @switchToGenerationTab);

handles.postprocessing_tab = uicontrol('Parent', tabBarPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Post Simulation Processing', ...
    'Units', 'normalized', ...
    'Position', [0.02 + tabWidth + tabSpacing, 0.1, tabWidth, 0.8], ...
    'BackgroundColor', colors.tabInactive, ...
    'ForegroundColor', colors.textLight, ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @switchToPostProcessingTab);

handles.performance_tab = uicontrol('Parent', tabBarPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Performance Settings', ...
    'Units', 'normalized', ...
    'Position', [0.02 + 2*(tabWidth + tabSpacing), 0.1, tabWidth, 0.8], ...
    'BackgroundColor', colors.tabInactive, ...
    'ForegroundColor', colors.textLight, ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @switchToPerformanceTab);

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

handles.performance_panel = uipanel('Parent', contentPanel, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'BackgroundColor', colors.background, ...
    'BorderType', 'none', ...
    'Visible', 'off');

% Create content for each tab
handles = createGenerationTabContent(handles.generation_panel, handles);
handles = createPostProcessingTabContent(handles.postprocessing_panel, handles);
handles = createPerformanceTabContent(handles.performance_panel, handles);

% Load performance preferences after UI is created
try
    if isfield(handles, 'enable_parallel_checkbox') && ishandle(handles.enable_parallel_checkbox)
        handles = loadPerformancePreferencesToUI(handles);
    end
catch ME
    fprintf('Note: Performance preferences will be loaded when UI is ready\n');
end
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

function handles = createPerformanceTabContent(parent, handles)
% Create content for the Performance Monitoring and Settings tab
colors = handles.colors;

% Create main layout for performance settings
handles = createPerformanceSettingsLayout(parent, handles);

% Add real-time performance monitoring section
handles = createRealTimePerformanceSection(parent, handles);
end

function handles = createRealTimePerformanceSection(parent, handles)
% Create real-time performance monitoring section
colors = handles.colors;

% Create a panel for real-time performance monitoring
monitorPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.02, 0.96, 0.3], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 1, ...
    'HighlightColor', colors.border, ...
    'Title', '🔍 Real-Time Performance Monitor');

% Initialize performance tracker
if ~isfield(handles, 'performance_tracker')
    try
        handles.performance_tracker = performance_tracker();
        fprintf('🔍 Performance tracker initialized (Session: %s)\n', datestr(now, 'yyyy-mm-dd_HH-MM-SS'));
    catch ME
        fprintf('Warning: Could not initialize performance tracker: %s\n', ME.message);
        handles.performance_tracker = [];
    end
end

% Create real-time metrics display
handles = createRealTimeMetricsDisplay(monitorPanel, handles);

% Create performance control buttons
handles = createPerformanceControls(monitorPanel, handles);

% Create performance history chart
handles = createPerformanceHistoryChart(monitorPanel, handles);
end

function handles = createRealTimeMetricsDisplay(parent, handles)
% Create real-time performance metrics display
colors = handles.colors;

% Session info section
sessionPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.7, 0.48, 0.28], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'Title', 'Session Info');

% Session duration
uicontrol('Parent', sessionPanel, ...
    'Style', 'text', ...
    'String', 'Session Duration:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.8, 0.4, 0.15], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.session_duration_text = uicontrol('Parent', sessionPanel, ...
    'Style', 'text', ...
    'String', '00:00:00', ...
    'Units', 'normalized', ...
    'Position', [0.45, 0.8, 0.5, 0.15], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.primary);

% Active operations
uicontrol('Parent', sessionPanel, ...
    'Style', 'text', ...
    'String', 'Active Operations:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.6, 0.4, 0.15], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.active_operations_text = uicontrol('Parent', sessionPanel, ...
    'Style', 'text', ...
    'String', '0', ...
    'Units', 'normalized', ...
    'Position', [0.45, 0.6, 0.5, 0.15], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.success);

% Memory usage section
memoryPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.52, 0.7, 0.46, 0.28], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'Title', 'Memory Usage');

% Current memory
uicontrol('Parent', memoryPanel, ...
    'Style', 'text', ...
    'String', 'Current Memory:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.8, 0.4, 0.15], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.current_memory_text = uicontrol('Parent', memoryPanel, ...
    'Style', 'text', ...
    'String', '0 MB', ...
    'Units', 'normalized', ...
    'Position', [0.45, 0.8, 0.5, 0.15], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.primary);

% Memory change
uicontrol('Parent', memoryPanel, ...
    'Style', 'text', ...
    'String', 'Memory Change:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.6, 0.4, 0.15], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.memory_change_text = uicontrol('Parent', memoryPanel, ...
    'Style', 'text', ...
    'String', '0 MB', ...
    'Units', 'normalized', ...
    'Position', [0.45, 0.6, 0.5, 0.15], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.textLight);

% Recent operations section
operationsPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.4, 0.96, 0.28], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'Title', 'Recent Operations');

% Create listbox for recent operations
handles.recent_operations_list = uicontrol('Parent', operationsPanel, ...
    'Style', 'listbox', ...
    'String', {'No operations recorded yet'}, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.1, 0.96, 0.8], ...
    'BackgroundColor', [1, 1, 1], ...
    'FontName', 'Courier New', ...
    'FontSize', 9, ...
    'Max', 10);
end

function handles = createPerformanceControls(parent, handles)
% Create performance monitoring control buttons
colors = handles.colors;

% Control panel
controlPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.02, 0.96, 0.36], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'Title', 'Performance Controls');

% Start monitoring button
handles.start_monitoring_button = uicontrol('Parent', controlPanel, ...
    'Style', 'pushbutton', ...
    'String', '▶ Start Monitoring', ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.6, 0.23, 0.3], ...
    'BackgroundColor', colors.success, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'Callback', @startPerformanceMonitoring);

% Stop monitoring button
handles.stop_monitoring_button = uicontrol('Parent', controlPanel, ...
    'Style', 'pushbutton', ...
    'String', '⏹ Stop Monitoring', ...
    'Units', 'normalized', ...
    'Position', [0.27, 0.6, 0.23, 0.3], ...
    'BackgroundColor', colors.danger, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'Callback', @stopPerformanceMonitoring);

% Generate report button
handles.generate_report_button = uicontrol('Parent', controlPanel, ...
    'Style', 'pushbutton', ...
    'String', '📊 Generate Report', ...
    'Units', 'normalized', ...
    'Position', [0.52, 0.6, 0.23, 0.3], ...
    'BackgroundColor', colors.primary, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'Callback', @generatePerformanceReport);

% Clear history button
handles.clear_history_button = uicontrol('Parent', controlPanel, ...
    'Style', 'pushbutton', ...
    'String', '🗑 Clear History', ...
    'Units', 'normalized', ...
    'Position', [0.77, 0.6, 0.21, 0.3], ...
    'BackgroundColor', colors.warning, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'Callback', @clearPerformanceHistory);

% Auto-refresh checkbox
handles.auto_refresh_checkbox = uicontrol('Parent', controlPanel, ...
    'Style', 'checkbox', ...
    'String', 'Auto-refresh metrics', ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.3, 0.3, 0.2], ...
    'Value', 1, ...
    'BackgroundColor', colors.panel, ...
    'Callback', @toggleAutoRefresh);

% Refresh interval
uicontrol('Parent', controlPanel, ...
    'Style', 'text', ...
    'String', 'Refresh (sec):', ...
    'Units', 'normalized', ...
    'Position', [0.35, 0.3, 0.15, 0.2], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.refresh_interval_edit = uicontrol('Parent', controlPanel, ...
    'Style', 'edit', ...
    'String', '2', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.3, 0.1, 0.2], ...
    'BackgroundColor', [1, 1, 1], ...
    'Callback', @updateRefreshInterval);

% Status indicator
handles.monitoring_status_text = uicontrol('Parent', controlPanel, ...
    'Style', 'text', ...
    'String', 'Status: Ready', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.3, 0.33, 0.2], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.textLight);
end

function handles = createPerformanceHistoryChart(parent, handles)
% Create performance history chart
colors = handles.colors;

% Chart panel
chartPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.4, 0.96, 0.28], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'Title', 'Performance History');

% Create axes for performance chart
handles.performance_axes = axes('Parent', chartPanel, ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.1, 0.9, 0.8], ...
    'Color', [1, 1, 1], ...
    'Box', 'on', ...
    'GridLineStyle', ':', ...
    'GridAlpha', 0.3);

% Initialize empty chart
xlabel(handles.performance_axes, 'Time (s)');
ylabel(handles.performance_axes, 'Memory (MB)');
title(handles.performance_axes, 'Memory Usage Over Time');
grid(handles.performance_axes, 'on');

% Store chart data
handles.performance_chart_data = struct();
handles.performance_chart_data.times = [];
handles.performance_chart_data.memory = [];
handles.performance_chart_data.operations = {};
end

function handles = createPostProcessingTabContent(parent, handles)
% Create content for the Post-Processing tab
colors = handles.colors;

% Three columns layout for post-processing
columnPadding = 0.01;
columnWidth = (1 - 4*columnPadding) / 3;

% Left column - Export Settings
leftPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [columnPadding, columnPadding, columnWidth, 1-2*columnPadding], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'HighlightColor', colors.border, ...
    'Title', 'Export Settings');

% Middle column - Calculation Options
middlePanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [2*columnPadding + columnWidth, columnPadding, columnWidth, 1-2*columnPadding], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'HighlightColor', colors.border, ...
    'Title', 'Calculation Options');

% Right column - Progress & Results
rightPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [3*columnPadding + 2*columnWidth, columnPadding, columnWidth, 1-2*columnPadding], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 0.5, ...
    'HighlightColor', colors.border, ...
    'Title', 'Progress & Results');

% Create export settings content (includes data folder and selection mode)
handles = createExportSettingsContent(leftPanel, handles);

% Create calculation options content (middle panel)
handles = createCalculationOptionsContent(middlePanel, handles);

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
    'Position', [0.05, 0.95, 0.9, 0.04], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.folder_path_text = uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'No folder selected', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.91, 0.7, 0.03], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.textLight);

handles.browse_folder_button = uicontrol('Parent', parent, ...
    'Style', 'pushbutton', ...
    'String', 'Browse', ...
    'Units', 'normalized', ...
    'Position', [0.77, 0.91, 0.18, 0.03], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @browseDataFolder);

% File selection mode
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Selection Mode:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.87, 0.9, 0.04], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.selection_mode_group = uibuttongroup('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.82, 0.9, 0.05], ...
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
    'Position', [0.05, 0.76, 0.9, 0.04], ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.file_listbox = uicontrol('Parent', parent, ...
    'Style', 'listbox', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.66, 0.9, 0.1], ...
    'BackgroundColor', 'white', ...
    'Max', 2, ... % Allow multiple selection
    'Min', 0);

% Set default selection
set(handles.selection_mode_group, 'SelectedObject', handles.all_files_radio);
end

function handles = createCalculationOptionsContent(parent, handles)
% Create calculation options interface - completely redesigned from scratch
colors = handles.colors;

% Section spacing and positioning constants
sectionHeight = 0.06;
controlHeight = 0.04;
textHeight = 0.03;
spacing = 0.02;
margin = 0.05;

% Calculate positions from top down
currentY = 0.95;

% Calculation Options Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Calculation Options:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

% Work & Power Calculations
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Work & Power:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.calculate_work_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Calculate work', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 0, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Enable for meaningful time series, disable for random input data');

currentY = currentY - controlHeight - 0.005;

handles.calculate_power_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Calculate power', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Always calculated for all joints');

currentY = currentY - controlHeight - spacing;

% Angular Impulse Calculations
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Angular Impulse:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.calculate_joint_torque_impulse_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Joint Torque Angular Impulse', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Angular impulse from joint torques at proximal and distal ends');

currentY = currentY - controlHeight - 0.005;

handles.calculate_applied_torque_impulse_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Moment of Force Angular Impulse', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Angular impulse from applied torques at proximal and distal ends');

currentY = currentY - controlHeight - 0.005;

handles.calculate_total_angular_impulse_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Total Angular Impulse', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Total angular impulse combining all sources for each joint');

currentY = currentY - controlHeight - spacing;

% Linear Impulse Calculations
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Linear Impulse:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.calculate_linear_impulse_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Linear impulse from joint forces', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Linear impulse calculated from forces at each joint');

currentY = currentY - controlHeight - spacing;

% Moments of Force Calculations
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Moments of Force:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.calculate_proximal_on_distal_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Proximal on Distal', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Calculate moments of force from proximal on distal');

currentY = currentY - controlHeight - 0.005;

handles.calculate_distal_on_proximal_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Distal on Proximal', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1, ...
    'Callback', @updatePreviewTable, ...
    'TooltipString', 'Calculate moments of force from distal on proximal');

currentY = currentY - controlHeight - spacing;

% Additional Signals Preview Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Additional Signals Preview:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

% Create preview table
preview_data = createPreviewTableData(handles);
col_names = {'Signal Type', 'Joint', 'End', 'Description'};
col_widths = {120, 80, 60, 200};

handles.signals_preview_table = uitable('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [margin, 0.05, 0.9, currentY - 0.1], ...
    'ColumnName', col_names, ...
    'ColumnWidth', col_widths, ...
    'RowStriping', 'on', ...
    'ColumnEditable', false, ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Data', preview_data);
end

function preview_data = createPreviewTableData(handles)
% Create preview data for the signals table
preview_data = {};

% Define joint names and their ends
joints = {'Shoulder', 'Elbow', 'Wrist', 'Scapula', 'Spine', 'Torso', 'Hip'};
ends = {'Proximal', 'Distal', 'Total'};

% Work and Power signals
preview_data{end+1, 1} = 'Work';
preview_data{end, 2} = 'All';
preview_data{end, 3} = 'N/A';
preview_data{end, 4} = 'Integral of power over time';

preview_data{end+1, 1} = 'Power';
preview_data{end, 2} = 'All';
preview_data{end, 3} = 'N/A';
preview_data{end, 4} = 'Torque × angular velocity';

% Angular Impulse signals
for i = 1:length(joints)
    joint = joints{i};
    for j = 1:length(ends)
        end_name = ends{j};
        preview_data{end+1, 1} = 'Angular Impulse';
        preview_data{end, 2} = joint;
        preview_data{end, 3} = end_name;
        preview_data{end, 4} = sprintf('Angular impulse at %s %s end', joint, lower(end_name));
    end
end

% Linear Impulse signals
for i = 1:length(joints)
    joint = joints{i};
    for j = 1:length(ends)
        end_name = ends{j};
        preview_data{end+1, 1} = 'Linear Impulse';
        preview_data{end, 2} = joint;
        preview_data{end, 3} = end_name;
        preview_data{end, 4} = sprintf('Linear impulse at %s %s end', joint, lower(end_name));
    end
end

% Moments of Force signals
preview_data{end+1, 1} = 'Moment of Force';
preview_data{end, 2} = 'All';
preview_data{end, 3} = 'Proximal→Distal';
preview_data{end, 4} = 'Moments of force from proximal on distal';

preview_data{end+1, 1} = 'Moment of Force';
preview_data{end, 2} = 'All';
preview_data{end, 3} = 'Distal→Proximal';
preview_data{end, 4} = 'Moments of force from distal on proximal';
end

function handles = createExportSettingsContent(parent, handles)
% Create export settings interface - completely redesigned from scratch
colors = handles.colors;

% Section spacing and positioning constants
sectionHeight = 0.06;
controlHeight = 0.04;
textHeight = 0.03;
spacing = 0.02;
margin = 0.05;

% Calculate positions from top down
currentY = 0.95;

% Data Folder Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Data Folder:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.folder_path_text = uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'No folder selected', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.65, controlHeight], ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.textLight);

handles.browse_folder_button = uicontrol('Parent', parent, ...
    'Style', 'pushbutton', ...
    'String', 'Browse', ...
    'Units', 'normalized', ...
    'Position', [0.72, currentY, 0.23, controlHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @browseDataFolder);

currentY = currentY - controlHeight - spacing;

% Selection Mode Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Selection Mode:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.selection_mode_group = uibuttongroup('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.panel, ...
    'SelectionChangedFcn', @selectionModeChanged);

handles.all_files_radio = uicontrol('Parent', handles.selection_mode_group, ...
    'Style', 'radiobutton', ...
    'String', 'All files in folder', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.1, 0.4, 0.8], ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel);

handles.select_files_radio = uicontrol('Parent', handles.selection_mode_group, ...
    'Style', 'radiobutton', ...
    'String', 'Select specific files', ...
    'Units', 'normalized', ...
    'Position', [0.55, 0.1, 0.4, 0.8], ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel);

currentY = currentY - controlHeight - spacing;

% Selected Files Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Selected Files:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.file_listbox = uicontrol('Parent', parent, ...
    'Style', 'listbox', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, 0.08], ...
    'BackgroundColor', 'white', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Max', 2, ... % Allow multiple selection
    'Min', 0, ...
    'Value', []);

currentY = currentY - 0.08 - spacing;

% Export Format Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Export Format:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.export_format_popup = uicontrol('Parent', parent, ...
    'Style', 'popupmenu', ...
    'String', {'CSV', 'Parquet', 'MAT', 'JSON', 'PyTorch (.pt)', 'TensorFlow (.h5)', 'NumPy (.npz)', 'Pickle (.pkl)'}, ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', 'white', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 1);

currentY = currentY - controlHeight - spacing;

% Batch Size Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Batch Size (trials per file):', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.batch_size_popup = uicontrol('Parent', parent, ...
    'Style', 'popupmenu', ...
    'String', {'10', '25', '50', '100', '250', '500'}, ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', 'white', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'Value', 3); % Default to 50

currentY = currentY - controlHeight - spacing;

% Processing Options Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Processing Options:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.generate_features_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Generate feature list for ML', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'Value', 1);

currentY = currentY - controlHeight - 0.005;

handles.compress_data_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Compress output files', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'Value', 0);

currentY = currentY - controlHeight - 0.005;

handles.include_metadata_checkbox = uicontrol('Parent', parent, ...
    'Style', 'checkbox', ...
    'String', 'Include metadata', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'Value', 1);

currentY = currentY - controlHeight - spacing;

% Output Folder Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Output Folder:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.output_path_text = uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', fullfile(pwd, 'processed_data'), ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.65, controlHeight], ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text);

handles.browse_output_button = uicontrol('Parent', parent, ...
    'Style', 'pushbutton', ...
    'String', 'Browse', ...
    'Units', 'normalized', ...
    'Position', [0.72, currentY, 0.23, controlHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @browseOutputFolderPostProcessing);

currentY = currentY - controlHeight - spacing;

% Start Processing Button - positioned at bottom with proper spacing
handles.start_processing_button = uicontrol('Parent', parent, ...
    'Style', 'pushbutton', ...
    'String', 'Start Processing', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.05, 0.5, 0.06], ...
    'BackgroundColor', colors.success, ...
    'ForegroundColor', [1, 1, 1], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'Callback', @startPostProcessing);
end

function handles = createProgressResultsContent(parent, handles)
% Create progress and results interface - completely redesigned from scratch
colors = handles.colors;

% Section spacing and positioning constants
sectionHeight = 0.06;
controlHeight = 0.04;
textHeight = 0.03;
spacing = 0.02;
margin = 0.05;

% Calculate positions from top down
currentY = 0.95;

% Processing Status Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Processing Status:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.progress_text = uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Ready to process', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.textLight);

currentY = currentY - controlHeight - spacing;

% Progress Bar Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Progress:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.progress_bar = uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', '', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'BackgroundColor', colors.border, ...
    'ForegroundColor', colors.success, ...
    'FontName', 'Arial', ...
    'FontSize', 8);

currentY = currentY - controlHeight - spacing;

% Results Summary Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Results Summary:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

handles.results_text = uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'No results yet', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, controlHeight], ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Arial', ...
    'FontSize', 8, ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.textLight);

currentY = currentY - controlHeight - spacing;

% Processing Log Section
uicontrol('Parent', parent, ...
    'Style', 'text', ...
    'String', 'Processing Log:', ...
    'Units', 'normalized', ...
    'Position', [margin, currentY, 0.9, textHeight], ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

currentY = currentY - textHeight - 0.005;

% Log text area - takes remaining space
handles.log_text = uicontrol('Parent', parent, ...
    'Style', 'listbox', ...
    'Units', 'normalized', ...
    'Position', [margin, 0.05, 0.9, currentY - 0.1], ...
    'BackgroundColor', 'white', ...
    'FontName', 'Monospaced', ...
    'FontSize', 8);
end

% Tab switching functions
function switchToGenerationTab(~, ~)
handles = guidata(gcbf);
handles.current_tab = 1;

% Update tab appearances
set(handles.generation_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');
set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
set(handles.performance_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');

% Show/hide panels
set(handles.generation_panel, 'Visible', 'on');
set(handles.postprocessing_panel, 'Visible', 'off');
set(handles.performance_panel, 'Visible', 'off');

guidata(handles.fig, handles);
end

function switchToPostProcessingTab(~, ~)
handles = guidata(gcbf);
handles.current_tab = 2;

% Update tab appearances
set(handles.generation_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');
set(handles.performance_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');

% Show/hide panels
set(handles.generation_panel, 'Visible', 'off');
set(handles.postprocessing_panel, 'Visible', 'on');
set(handles.performance_panel, 'Visible', 'off');

guidata(handles.fig, handles);
end

function switchToPerformanceTab(~, ~)
handles = guidata(gcbf);
handles.current_tab = 3;

% Update tab appearances
set(handles.generation_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
set(handles.performance_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');

% Show/hide panels
set(handles.generation_panel, 'Visible', 'off');
set(handles.postprocessing_panel, 'Visible', 'off');
set(handles.performance_panel, 'Visible', 'on');

guidata(handles.fig, handles);
end

% Enhanced control functions
function togglePlayPause(~, ~)
handles = guidata(gcbf);

if handles.is_paused
    % Resume from pause
    handles.is_paused = false;
    set(handles.play_pause_button, 'String', 'Pause', 'BackgroundColor', handles.colors.warning);
    % Resume processing logic here
    resumeFromPause(handles);
else
    % Start or pause
    if isfield(handles, 'is_running') && handles.is_running
        % Pause current operation
        handles.is_paused = true;
        set(handles.play_pause_button, 'String', 'Resume', 'BackgroundColor', handles.colors.success);
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
set(handles.checkpoint_button, 'String', 'Saved', 'BackgroundColor', handles.colors.success);

% Reset button after 2 seconds
timer_obj = timer('ExecutionMode', 'singleShot', 'StartDelay', 2);
timer_obj.TimerFcn = @(src, event) resetCheckpointButton(handles);
start(timer_obj);

guidata(handles.fig, handles);
end

function resetCheckpointButton(handles)
set(handles.checkpoint_button, 'String', 'Checkpoint', 'BackgroundColor', handles.colors.warning);
end

function resumeFromPause(handles)
% Resume processing from checkpoint
if ~isempty(handles.checkpoint_data)
    % Restore state and continue processing
    % Implementation depends on specific processing logic
    updateProgressText(handles, 'Resuming from checkpoint...');
end
end

function progress = getCurrentProgress(handles)
% Get current progress state
progress = struct();
progress.current_trial = 0;
progress.total_trials = 0;
progress.current_step = '';
end

% Post-processing functions
function browseDataFolder(~, ~)
handles = guidata(gcbf);

folder_path = uigetdir('', 'Select Data Folder');
if folder_path ~= 0
    handles.data_folder = folder_path;
    set(handles.folder_path_text, 'String', folder_path, 'ForegroundColor', handles.colors.text);

    % Update output folder path to be in the selected data folder
    output_folder = fullfile(folder_path, 'processed_data');
    set(handles.output_path_text, 'String', output_folder, 'ForegroundColor', handles.colors.text);

    % Update file list
    updateFileList(handles);
end

guidata(handles.fig, handles);
end

function browseOutputFolderPostProcessing(~, ~)
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
else
    % No data folder set or folder doesn't exist
    set(handles.file_listbox, 'String', {'No data folder selected'});
    set(handles.file_listbox, 'Value', 1);
end
end

function selectSpecificFiles(handles)
% Check if data_folder is initialized
if ~isfield(handles, 'data_folder') || isempty(handles.data_folder)
    % If no data folder is set, start from current directory
    start_path = pwd;
else
    start_path = handles.data_folder;
end

[file_names, path] = uigetfile({'*.mat', 'MATLAB Data Files (*.mat)'}, ...
    'Select Files', start_path, 'MultiSelect', 'on');

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

% Get calculation options from checkboxes
calculate_work = get(handles.calculate_work_checkbox, 'Value');
calculate_power = get(handles.calculate_power_checkbox, 'Value');
calculate_joint_torque_impulse = get(handles.calculate_joint_torque_impulse_checkbox, 'Value');
calculate_applied_torque_impulse = get(handles.calculate_applied_torque_impulse_checkbox, 'Value');
calculate_total_angular_impulse = get(handles.calculate_total_angular_impulse_checkbox, 'Value');
calculate_linear_impulse = get(handles.calculate_linear_impulse_checkbox, 'Value');
calculate_proximal_on_distal = get(handles.calculate_proximal_on_distal_checkbox, 'Value');
calculate_distal_on_proximal = get(handles.calculate_distal_on_proximal_checkbox, 'Value');

% Get output folder
if isfield(handles, 'output_folder')
    output_folder = handles.output_folder;
else
    % Check if data_folder is available
    if isfield(handles, 'data_folder') && ~isempty(handles.data_folder)
        output_folder = fullfile(handles.data_folder, 'processed_data');
    else
        output_folder = fullfile(pwd, 'processed_data');
    end
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
end

% Start processing in background
processing_data = struct();
processing_data.selected_files = selected_files;
% Set data_folder safely
if isfield(handles, 'data_folder') && ~isempty(handles.data_folder)
    processing_data.data_folder = handles.data_folder;
else
    processing_data.data_folder = pwd;
end
processing_data.output_folder = output_folder;
processing_data.export_format = export_format;
processing_data.batch_size = batch_size;
processing_data.generate_features = generate_features;
processing_data.compress_data = compress_data;
processing_data.include_metadata = include_metadata;
processing_data.calculate_work = calculate_work;
processing_data.calculate_power = calculate_power;
processing_data.calculate_joint_torque_impulse = calculate_joint_torque_impulse;
processing_data.calculate_applied_torque_impulse = calculate_applied_torque_impulse;
processing_data.calculate_total_angular_impulse = calculate_total_angular_impulse;
processing_data.calculate_linear_impulse = calculate_linear_impulse;
processing_data.calculate_proximal_on_distal = calculate_proximal_on_distal;
processing_data.calculate_distal_on_proximal = calculate_distal_on_proximal;
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
% Process a batch of files with optimized preallocation
batch_data = struct();

% Preallocate trials array with known size
num_files = length(batch_files);
batch_data.trials = cell(num_files, 1);

% Preallocate success tracking array
successful_trials = false(num_files, 1);

for i = 1:num_files
    file_path = fullfile(processing_data.data_folder, batch_files{i});

    try
        % Load data
        data = load(file_path);

        % Process data with calculation options
        processed_trial = processTrialData(data, processing_data);

        batch_data.trials{i} = processed_trial;
        successful_trials(i) = true;

    catch ME
        warning('Failed to process file %s: %s', batch_files{i}, ME.message);
        batch_data.trials{i} = [];  % Mark as failed
        successful_trials(i) = false;
    end
end

% Remove empty trials efficiently using logical indexing
if any(~successful_trials)
    batch_data.trials = batch_data.trials(successful_trials);
    fprintf('Successfully processed %d/%d files in batch\n', sum(successful_trials), num_files);
end
end

function processed_trial = processTrialData(data, processing_data)
% Process individual trial data with calculation options
% This is a placeholder - implement actual data processing logic
processed_trial = data;

% Add calculation options to the processed trial
processed_trial.calculation_options = struct();
processed_trial.calculation_options.calculate_work = processing_data.calculate_work;

% If the data has the required structure, apply enhanced calculations
if isfield(data, 'ZTCFQ') && isfield(data, 'DELTAQ')
    try
        % Create options structure for the calculation function
        options = struct();
        options.calculate_work = processing_data.calculate_work;

        % Apply enhanced calculations with granular angular impulse
        [processed_trial.ZTCFQ_enhanced, processed_trial.DELTAQ_enhanced] = ...
            calculateWorkPowerAndGranularAngularImpulse3D(data.ZTCFQ, data.DELTAQ, options);

        fprintf('Enhanced calculations with granular angular impulse applied to trial data.\n');
    catch ME
        warning('Failed to apply enhanced calculations: %s', ME.message);
    end
end
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

% Essential functions from original Data_GUI.m
function handles = loadUserPreferences(handles)
% Load user preferences with safe defaults
script_dir = fileparts(mfilename('fullpath'));
pref_file = fullfile(script_dir, 'user_preferences.mat');

% Initialize default preferences
handles.preferences = struct();
handles.preferences.last_input_file = '';
handles.preferences.last_input_file_path = '';
handles.preferences.last_output_folder = pwd;
handles.preferences.default_num_trials = 10;
handles.preferences.default_sim_time = 0.3;
handles.preferences.default_sample_rate = 100;
handles.preferences.capture_workspace = true; % Default to capturing workspace data

% PERFORMANCE UPGRADES: Add last used model and input file preferences
handles.preferences.last_model_name = '';
handles.preferences.last_model_path = '';
handles.preferences.last_model_was_loaded = false;
handles.preferences.enable_model_caching = true;
handles.preferences.enable_preallocation = true;
handles.preferences.preallocation_buffer_size = 1000; % Default buffer size for preallocation

% Batch settings defaults
handles.preferences.default_batch_size = 50;
handles.preferences.default_save_interval = 25;
handles.preferences.enable_performance_monitoring = true;
handles.preferences.default_verbosity = 'Normal';
handles.preferences.enable_memory_monitoring = true;
handles.preferences.enable_master_dataset = true; % Default to creating master dataset

% PERFORMANCE UPGRADES: Add performance optimization settings
handles.preferences.enable_data_compression = true;
handles.preferences.compression_level = 6; % MATLAB's default compression level
handles.preferences.enable_parallel_processing = true;
handles.preferences.max_parallel_workers = 14; % Default to 14 workers for Local_Cluster
handles.preferences.cluster_profile = 'Local_Cluster'; % Default to Local_Cluster profile
handles.preferences.use_local_cluster = true; % Default to using local cluster
handles.preferences.enable_memory_pooling = true;
handles.preferences.memory_pool_size = 100; % MB

% Try to load saved preferences
if exist(pref_file, 'file')
    try
        loaded_prefs = load(pref_file);
        if isfield(loaded_prefs, 'preferences')
            % Merge loaded preferences with defaults
            pref_fields = fieldnames(loaded_prefs.preferences);
            for i = 1:length(pref_fields)
                field_name = pref_fields{i};
                handles.preferences.(field_name) = loaded_prefs.preferences.(field_name);
            end
        end
    catch
        % Use defaults if loading fails
        fprintf('Note: Could not load user preferences, using defaults.\n');
    end
end
end

function applyUserPreferences(handles)
% Apply user preferences to UI
try
    if isfield(handles, 'preferences')
        prefs = handles.preferences;

        % Apply last output folder
        if isfield(handles, 'output_folder_edit') && ~isempty(prefs.last_output_folder)
            set(handles.output_folder_edit, 'String', prefs.last_output_folder);
        end

        % Apply last input file
        if isfield(handles, 'input_file_edit') && ~isempty(prefs.last_input_file_path)
            if exist(prefs.last_input_file_path, 'file')
                handles.selected_input_file = prefs.last_input_file_path;
                [~, filename, ext] = fileparts(prefs.last_input_file_path);
                set(handles.input_file_edit, 'String', [filename ext]);
            end
        end

        % PERFORMANCE UPGRADES: Apply last used model
        if isfield(handles, 'model_display') && ~isempty(prefs.last_model_name)
            set(handles.model_display, 'String', prefs.last_model_name);
            handles.model_name = prefs.last_model_name;
            handles.model_path = prefs.last_model_path;
            handles.model_was_loaded = prefs.last_model_was_loaded;
        end

        % Apply default values
        if isfield(handles, 'num_trials_edit')
            if isfield(prefs, 'default_num_trials')
                set(handles.num_trials_edit, 'String', num2str(prefs.default_num_trials));
            else
                set(handles.num_trials_edit, 'String', '2'); % Default to 2
            end
        end

        if isfield(handles, 'sim_time_edit')
            if isfield(prefs, 'default_sim_time')
                set(handles.sim_time_edit, 'String', num2str(prefs.default_sim_time));
            else
                set(handles.sim_time_edit, 'String', '0.3'); % Default to 0.3
            end
        end

        if isfield(handles, 'sample_rate_edit')
            if isfield(prefs, 'default_sample_rate')
                set(handles.sample_rate_edit, 'String', num2str(prefs.default_sample_rate));
            else
                set(handles.sample_rate_edit, 'String', '100'); % Default to 100
            end
        end

        % Apply workspace capture setting
        if isfield(handles, 'capture_workspace_checkbox') && isfield(prefs, 'capture_workspace')
            set(handles.capture_workspace_checkbox, 'Value', double(prefs.capture_workspace));
        end

        % Apply batch settings
        if isfield(handles, 'batch_size_edit') && isfield(prefs, 'default_batch_size')
            set(handles.batch_size_edit, 'String', num2str(prefs.default_batch_size));
        end

        if isfield(handles, 'save_interval_edit') && isfield(prefs, 'default_save_interval')
            set(handles.save_interval_edit, 'String', num2str(prefs.default_save_interval));
        end

        if isfield(handles, 'enable_performance_monitoring') && isfield(prefs, 'enable_performance_monitoring')
            set(handles.enable_performance_monitoring, 'Value', prefs.enable_performance_monitoring);
        end

        if isfield(handles, 'verbosity_popup') && isfield(prefs, 'default_verbosity')
            % Map verbosity strings to popup indices
            verbosity_options = {'Quiet', 'Normal', 'Verbose'};
            verbosity_idx = find(strcmp(verbosity_options, prefs.default_verbosity));
            if ~isempty(verbosity_idx)
                set(handles.verbosity_popup, 'Value', verbosity_idx);
            end
        end

        % Apply master dataset setting
        if isfield(handles, 'enable_master_dataset') && isfield(prefs, 'enable_master_dataset')
            set(handles.enable_master_dataset, 'Value', prefs.enable_master_dataset);
        end

        % Set default execution mode to parallel (index 2)
        if isfield(handles, 'execution_mode_popup')
            set(handles.execution_mode_popup, 'Value', 2);
        end
    end

catch ME
    fprintf('Warning: Could not apply user preferences: %s\n', ME.message);
end
end

function closeGUICallback(~, ~)
% Close GUI callback
delete(gcf);
end

function startGeneration(~, ~, fig)
% Start generation
handles = guidata(fig);

fprintf('[DEBUG] === STARTING GENERATION ===\n');
fprintf('[DEBUG] Current working directory: %s\n', pwd);

% Check if already running
if isfield(handles, 'is_running') && handles.is_running
    msgbox('Generation is already running. Please wait for it to complete or use the Stop button.', 'Already Running', 'warn');
    return;
end

try
    fprintf('[DEBUG] Starting performance tracking...\n');
    % Start performance tracking for generation
    if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
            ismethod(handles.performance_tracker, 'start_timer')
        try
            handles.performance_tracker.start_timer('Data_Generation');
            fprintf('⏱️ Started timing: Data Generation\n');
        catch ME
            fprintf('Warning: Could not start performance timer: %s\n', ME.message);
        end
    end

    % Set running state immediately
    handles.is_running = true;
    guidata(fig, handles);

    % Provide immediate visual feedback
    set(handles.play_pause_button, 'Enable', 'off', 'String', 'Running...');
    set(handles.stop_button, 'Enable', 'on');
    set(handles.status_text, 'String', 'Status: Starting generation...');
    set(handles.progress_text, 'String', 'Initializing...');
    drawnow; % Force immediate UI update

    fprintf('[DEBUG] Validating inputs...\n');
    % Validate inputs
    config = validateInputs(handles);
    if isempty(config)
        fprintf('[DEBUG] Input validation failed!\n');
        % Reset state on validation failure
        handles.is_running = false;
        set(handles.play_pause_button, 'Enable', 'on', 'String', 'Start');
        set(handles.stop_button, 'Enable', 'off');
        guidata(fig, handles);
        return;
    end

    fprintf('[DEBUG] Input validation successful\n');
    fprintf('[DEBUG] Model path: %s\n', config.model_path);
    fprintf('[DEBUG] Number of simulations: %d\n', config.num_simulations);
    fprintf('[DEBUG] Output folder: %s\n', config.output_folder);

    % Store config
    handles.config = config;
    handles.should_stop = false;
    guidata(fig, handles);

    fprintf('[DEBUG] Creating script backup...\n');
    % Create script backup before starting generation
    backupScripts(handles);

    fprintf('[DEBUG] Starting runGeneration...\n');
    % Start generation
    runGeneration(handles);

catch ME
    % Reset state on error
    try
        handles.is_running = false;
        set(handles.play_pause_button, 'Enable', 'on', 'String', 'Start');
        set(handles.stop_button, 'Enable', 'off');
        set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
        guidata(fig, handles);
    catch
        % GUI might be destroyed, ignore the error
    end
    errordlg(ME.message, 'Generation Failed');
end
end

function stopGeneration(~, ~)
% Stop generation
handles = guidata(gcbf);
handles.should_stop = true;
guidata(handles.fig, handles);
set(handles.status_text, 'String', 'Status: Stopping...');
set(handles.progress_text, 'String', 'Generation stopped by user');

% Note: The actual cleanup will happen in runGeneration when it detects should_stop = true
end

function saveConfiguration(~, ~)
% Save configuration
handles = guidata(gcbf);

[filename, pathname] = uiputfile('*.mat', 'Save Configuration');
if filename ~= 0
    config = struct();
    config.timestamp = datestr(now);
    config.handles = handles;
    save(fullfile(pathname, filename), 'config');
    fprintf('Configuration saved to %s\n', fullfile(pathname, filename));
end
end

function loadConfiguration(~, ~)
% Load configuration
handles = guidata(gcbf);

[filename, pathname] = uigetfile('*.mat', 'Load Configuration');
if filename ~= 0
    try
        config = load(fullfile(pathname, filename));
        fprintf('Configuration loaded from %s\n', fullfile(pathname, filename));
    catch ME
        errordlg(sprintf('Error loading configuration: %s', ME.message), 'Load Error');
    end
end
end



% Panel creation functions
function handles = createTrialAndDataPanel(parent, handles, yPos, height)
% Configuration panel
colors = handles.colors;

panel = uipanel('Parent', parent, ...
    'Title', 'Configuration', ...
    'FontSize', 10, ...
    'FontWeight', 'normal', ...
    'Units', 'normalized', ...
    'Position', [0.01, yPos, 0.98, height], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text);

% Layout
rowHeight = 0.030;  % Slightly smaller to fit more elements
labelWidth = 0.22;
fieldSpacing = 0.02;
textBoxStart = 0.20;  % Move text boxes slightly to the right to avoid cutting off titles
textBoxWidth = 0.48;  % Consistent width
y = 0.95;  % Start higher to fit more elements

% Input File
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Input File:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'normal', ...
    'BackgroundColor', colors.panel);

handles.input_file_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', 'No file selected', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'Enable', 'inactive', ...
    'BackgroundColor', [0.97, 0.97, 0.97], ...
    'FontSize', 9);

handles.browse_input_btn = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Browse', ...
    'Units', 'normalized', ...
    'Position', [0.72, y, 0.12, rowHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @browseInputFile);

% Simulink Model
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Simulink Model:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.model_display = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', 'GolfSwing3D_Kinetic', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'Enable', 'inactive', ...
    'BackgroundColor', [0.97, 0.97, 0.97], ...
    'FontSize', 9);

handles.model_browse_btn = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Browse', ...
    'Units', 'normalized', ...
    'Position', [0.72, y, 0.12, rowHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @selectSimulinkModel);

% Output Folder
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Output Folder:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.output_folder_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', pwd, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'FontSize', 9);

handles.browse_button = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Browse', ...
    'Units', 'normalized', ...
    'Position', [0.72, y, 0.12, rowHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @browseOutputFolder);

% Dataset Name
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Dataset Name:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.folder_name_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', sprintf('golf_swing_dataset_%s', datestr(now, 'yyyymmdd')), ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'FontSize', 9);

% Output Format
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Output Format:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.format_popup = uicontrol('Parent', panel, ...
    'Style', 'popupmenu', ...
    'String', {'CSV Files', 'MAT Files', 'Both CSV and MAT'}, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white');

% Execution Mode
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Execution Mode:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

% Check if parallel computing toolbox is available
if license('test', 'Distrib_Computing_Toolbox')
    mode_options = {'Series', 'Parallel'};
else
    mode_options = {'Series', 'Parallel (Toolbox Required)'};
end

handles.execution_mode_popup = uicontrol('Parent', panel, ...
    'Style', 'popupmenu', ...
    'String', mode_options, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'Callback', @autoUpdateSummaryAndSave);

% Verbosity
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Verbosity:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.verbosity_popup = uicontrol('Parent', panel, ...
    'Style', 'popupmenu', ...
    'String', {'Minimal', 'Standard', 'Detailed', 'Debug'}, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white');

% Trial Parameters
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Trials:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.num_trials_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '2', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'Callback', @updateCoefficientsPreviewAndSave);

% Duration
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Duration (s):', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.sim_time_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '0.3', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'Callback', @autoUpdateSummaryAndSave);

% Sample Rate
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Sample Rate (Hz):', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.sample_rate_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '100', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'Callback', @autoUpdateSummaryAndSave);

% Torque Scenario
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Torque Scenario:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.torque_scenario_popup = uicontrol('Parent', panel, ...
    'Style', 'popupmenu', ...
    'String', {'Variable Torques', 'Zero Torque', 'Constant Torque'}, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'Callback', @torqueScenarioCallback);

% Coefficient Range
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Coefficient Range (±):', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, labelWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.coeff_range_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '50', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'Callback', @updateCoefficientsPreviewAndSave);

% Data Sources
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Data Sources:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.15, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

% First row of checkboxes
handles.use_signal_bus = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'CombinedSignalBus', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.30, rowHeight], ...
    'Value', 1, ...
    'BackgroundColor', colors.panel);

handles.use_logsout = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Logsout Dataset', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart + 0.24, y, 0.30, rowHeight], ...
    'Value', 1, ...
    'BackgroundColor', colors.panel);

% Second row of checkboxes
y = y - 0.025;
handles.use_simscape = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Simscape Results', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.30, rowHeight], ...
    'Value', 1, ...
    'BackgroundColor', colors.panel);

handles.capture_workspace_checkbox = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Model Workspace', ...
    'Value', 1, ... % Default to checked
    'Units', 'normalized', ...
    'Position', [textBoxStart + 0.24, y, 0.30, rowHeight], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text, ...
    'FontSize', 9, ...
    'TooltipString', 'Include model workspace variables (segment lengths, masses, inertias, etc.) in the output dataset');

% Animation and Monitoring Options
y = y - 0.05;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Options:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.15, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

% First row of options
handles.enable_animation = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Animation', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.30, rowHeight], ...
    'Value', 0, ...
    'BackgroundColor', colors.panel);

handles.enable_performance_monitoring = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Performance Monitoring', ...
    'Value', 1, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart + 0.24, y, 0.30, rowHeight], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text, ...
    'FontSize', 9, ...
    'TooltipString', 'Track execution times, memory usage, and performance metrics');

% Second row of options
y = y - 0.025;
handles.enable_memory_monitoring = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Memory Monitoring', ...
    'Value', 1, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.30, rowHeight], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text, ...
    'FontSize', 9, ...
    'TooltipString', 'Monitor system memory and automatically manage parallel workers');

% Third row of options - Checkpoint Resume
y = y - 0.025;
handles.enable_checkpoint_resume = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Resume from checkpoint', ...
    'Value', 0, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.30, rowHeight], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text, ...
    'FontSize', 9, ...
    'TooltipString', 'When checked, resume from existing checkpoint. When unchecked, always start fresh.');

% Fourth row of options - Master Dataset Creation
y = y - 0.025;
handles.enable_master_dataset = uicontrol('Parent', panel, ...
    'Style', 'checkbox', ...
    'String', 'Create master dataset', ...
    'Value', 1, ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.30, rowHeight], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text, ...
    'FontSize', 9, ...
    'TooltipString', 'When checked, combine all trials into a master dataset. Uncheck to skip this step for large datasets that may cause memory issues.');

% Clear Checkpoints Button
handles.clear_checkpoint_button = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Clear Checkpoints', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart + 0.24, y, 0.20, rowHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @clearAllCheckpoints, ...
    'TooltipString', 'Delete all checkpoint files to force fresh start');

% Batch Settings Section - Moved to more visible position
y = y - 0.04;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Batch Size:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.15, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold');  % Make it bold to be more visible

handles.batch_size_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '50', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.15, rowHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 9, ...
    'TooltipString', 'Number of simulations to process in each batch (recommended: 25-100)');

uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'trials', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart + 0.16, y, 0.08, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'FontSize', 9);

% Save Interval
y = y - 0.04;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Save Interval:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.15, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold');  % Make it bold to be more visible

handles.save_interval_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '25', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, 0.15, rowHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 9, ...
    'TooltipString', 'Save checkpoint every N batches (recommended: 10-50)');

uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'batches', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart + 0.16, y, 0.08, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'FontSize', 9);

% Progress Section
y = y - 0.04;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Progress:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.15, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.progress_text = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', 'Ready to start generation...', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'FontWeight', 'normal', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel, ...
    'Max', 2, ... % Allow multiple lines
    'Min', 0, ... % Allow selection
    'Enable', 'inactive'); % Read-only but selectable

% Status Section
y = y - 0.04;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Status:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.15, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.status_text = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', 'Status: Ready', ...
    'Units', 'normalized', ...
    'Position', [textBoxStart, y, textBoxWidth, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.97, 0.97, 0.97], ...
    'ForegroundColor', colors.success, ...
    'FontSize', 9, ...
    'Max', 2, ... % Allow multiple lines
    'Min', 0, ... % Allow selection
    'Enable', 'inactive'); % Read-only but selectable

% Initialize
handles.model_name = 'GolfSwing3D_Kinetic';
handles.model_path = '';
handles.selected_input_file = '';

% Try to find default model in multiple locations
possible_paths = {
    '../../Model/GolfSwing3D_Kinetic.slx',
    'Model/GolfSwing3D_Kinetic.slx',
    'GolfSwing3D_Kinetic.slx',
    fullfile(pwd, 'Model', 'GolfSwing3D_Kinetic.slx'),
    fullfile(pwd, 'GolfSwing3D_Kinetic.slx'),
    which('GolfSwing3D_Kinetic.slx'),
    which('GolfSwing3D_Kinetic')
    };

for i = 1:length(possible_paths)
    if ~isempty(possible_paths{i}) && exist(possible_paths{i}, 'file')
        handles.model_path = possible_paths{i};
        fprintf('Found model at: %s\n', handles.model_path);
        break;
    end
end

if isempty(handles.model_path)
    fprintf('Warning: Could not find model file automatically\n');
end
end

function handles = createPreviewPanel(parent, handles, yPos, height)
% Parameters Summary Panel
colors = handles.colors;

panel = uipanel('Parent', parent, ...
    'Title', 'Summary', ...
    'FontSize', 10, ...
    'FontWeight', 'normal', ...
    'Units', 'normalized', ...
    'Position', [0.01, yPos, 0.98, height], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text);

% Summary table (full height since no button needed)
handles.preview_table = uitable('Parent', panel, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.02, 0.96, 0.96], ...
    'ColumnName', {'Parameter', 'Value', 'Description'}, ...
    'ColumnWidth', {150, 150, 'auto'}, ...
    'RowStriping', 'on', ...
    'FontSize', 9);
end

function handles = createJointEditorPanel(parent, handles, yPos, height)
% Joint Editor Panel
colors = handles.colors;
param_info = getPolynomialParameterInfo();

panel = uipanel('Parent', parent, ...
    'Title', 'Joint Coefficient Editor', ...
    'FontSize', 10, ...
    'FontWeight', 'normal', ...
    'Units', 'normalized', ...
    'Position', [0.01, yPos, 0.98, height], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text);

% Selection row - leave more room for the panel title
y = 0.75;  % Moved down to give more space at top
rowHeight = 0.156;  % Increased by 30% (0.12 * 1.3) to prevent dropdown cutoff

uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Joint:', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.08, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.joint_selector = uicontrol('Parent', panel, ...
    'Style', 'popupmenu', ...
    'String', param_info.joint_names, ...
    'Units', 'normalized', ...
    'Position', [0.10, y+0.10, 0.35, 0.08], ...
    'BackgroundColor', 'white', ...
    'Callback', @updateJointCoefficients);

uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Apply to:', ...
    'Units', 'normalized', ...
    'Position', [0.48, y, 0.10, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.trial_selection_popup = uicontrol('Parent', panel, ...
    'Style', 'popupmenu', ...
    'String', {'All Trials', 'Specific Trial'}, ...
    'Units', 'normalized', ...
    'Position', [0.58, y+0.10, 0.20, 0.08], ...
    'BackgroundColor', 'white', ...
    'Callback', @updateTrialSelectionMode);

uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Trial:', ...
    'Units', 'normalized', ...
    'Position', [0.80, y, 0.06, rowHeight], ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', colors.panel);

handles.trial_number_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '1', ...
    'Units', 'normalized', ...
    'Position', [0.87, y+0.10, 0.08, 0.08], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'center', ...
    'Enable', 'off');

% Coefficient labels row
y = y - 0.15;  % Reduced spacing to move row up
coeff_labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
coeff_powers = {'t⁶', 't⁵', 't⁴', 't³', 't²', 't', '1'};  % Powers for each coefficient
handles.joint_coeff_edits = gobjects(1, 7);

coeffWidth = 0.12;
coeffSpacing = (0.96 - 7*coeffWidth) / 8;

for i = 1:7
    xPos = coeffSpacing + (i-1) * (coeffWidth + coeffSpacing);

    % Color code G coefficient (constant term)
    if i == 7
        labelColor = colors.success;  % Highlight G as constant
    else
        labelColor = colors.text;
    end

    % Coefficient label with power
    uicontrol('Parent', panel, ...
        'Style', 'text', ...
        'String', [coeff_labels{i} ' (' coeff_powers{i} ')'], ...
        'Units', 'normalized', ...
        'Position', [xPos, y, coeffWidth, 0.086], ...  % Increased by 30%
        'FontWeight', 'normal', ...
        'FontSize', 9, ...
        'ForegroundColor', labelColor, ...
        'BackgroundColor', colors.panel, ...
        'HorizontalAlignment', 'center');
end

% Coefficient text boxes row
y = y - 0.10;  % Reduced spacing between labels and text boxes

for i = 1:7
    xPos = coeffSpacing + (i-1) * (coeffWidth + coeffSpacing);

    handles.joint_coeff_edits(i) = uicontrol('Parent', panel, ...
        'Style', 'edit', ...
        'String', '0.00', ...
        'Units', 'normalized', ...
        'Position', [xPos, y, coeffWidth, 0.088], ...  % Increased by 10%
        'BackgroundColor', 'white', ...
        'HorizontalAlignment', 'center', ...
        'Callback', @validateCoefficientInput);
end

% Action buttons row
y = y - 0.195;  % Increased by 30%

% Action buttons
buttonHeight = 0.097;  % Increased by 10% (0.088 * 1.1 = 0.097)

handles.apply_joint_button = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Apply to Table', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.22, buttonHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @applyJointToTable);

handles.load_joint_button = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load from Table', ...
    'Units', 'normalized', ...
    'Position', [0.26, y, 0.22, buttonHeight], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @loadJointFromTable);

% Status
handles.joint_status = uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', sprintf('Ready - %s selected', param_info.joint_names{1}), ...
    'Units', 'normalized', ...
    'Position', [0.50, y, 0.48, buttonHeight], ...
    'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.97, 0.97, 0.97], ...
    'ForegroundColor', colors.textLight, ...
    'FontSize', 9);

% Equation display row
y = y - 0.195;  % Increased by 30%
handles.equation_display = uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'τ(t) = At⁶ + Bt⁵ + Ct⁴ + Dt³ + Et² + Ft + G', ...
    'Units', 'normalized', ...
    'Position', [0.02, y, 0.96, 0.114], ...  % Increased by 30%
    'FontSize', 11, ...
    'FontWeight', 'normal', ...
    'ForegroundColor', colors.primary, ...
    'BackgroundColor', [0.98, 0.98, 1], ...
    'HorizontalAlignment', 'center');

handles.param_info = param_info;
end

function handles = createCoefficientsPanel(parent, handles, yPos, height)
% Coefficients Table Panel
colors = handles.colors;
param_info = getPolynomialParameterInfo();

panel = uipanel('Parent', parent, ...
    'Title', 'Coefficients Table', ...
    'FontSize', 10, ...
    'FontWeight', 'normal', ...
    'Units', 'normalized', ...
    'Position', [0.01, yPos, 0.98, height], ...
    'BackgroundColor', colors.panel, ...
    'ForegroundColor', colors.text);

% Search bar
searchY = 0.88;
uicontrol('Parent', panel, ...
    'Style', 'text', ...
    'String', 'Search:', ...
    'Units', 'normalized', ...
    'Position', [0.02, searchY, 0.08, 0.10], ...
    'BackgroundColor', colors.panel);

handles.search_edit = uicontrol('Parent', panel, ...
    'Style', 'edit', ...
    'String', '', ...
    'Units', 'normalized', ...
    'Position', [0.11, searchY, 0.20, 0.10], ...
    'BackgroundColor', 'white', ...
    'FontSize', 9, ...
    'Callback', @searchCoefficients);

handles.clear_search_button = uicontrol('Parent', panel, ...
    'Style', 'pushbutton', ...
    'String', 'Clear', ...
    'Units', 'normalized', ...
    'Position', [0.32, searchY, 0.08, 0.10], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontName', 'Arial', ...
    'FontSize', 9, ...
    'Callback', @clearSearch);

% Control buttons
buttonY = 0.76;
buttonHeight = 0.09;
buttonWidth = 0.13;
buttonSpacing = 0.01;

% Button configuration
buttons = {
    {'Reset', 'reset_coeffs', colors.lightGrey, @resetCoefficientsToGenerated},
    {'Apply Row', 'apply_row', colors.lightGrey, @applyRowToAll},
    {'Export', 'export', colors.lightGrey, @exportCoefficientsToCSV},
    {'Import', 'import', colors.lightGrey, @importCoefficientsFromCSV},
    {'Save Set', 'save_scenario', colors.lightGrey, @saveScenario},
    {'Load Set', 'load_scenario', colors.lightGrey, @loadScenario}
    };

for i = 1:length(buttons)
    xPos = 0.02 + (i-1) * (buttonWidth + buttonSpacing);
    btn_name = [buttons{i}{2} '_button'];
    handles.(btn_name) = uicontrol('Parent', panel, ...
        'Style', 'pushbutton', ...
        'String', buttons{i}{1}, ...
        'Units', 'normalized', ...
        'Position', [xPos, buttonY, buttonWidth, buttonHeight], ...
        'BackgroundColor', buttons{i}{3}, ...
        'ForegroundColor', colors.text, ...
        'FontName', 'Arial', ...
        'FontSize', 9, ...
        'Callback', buttons{i}{4});
end

% Coefficients table
col_names = {'Trial'};
col_widths = {50};
col_editable = false;

% Add columns for joints
for i = 1:length(param_info.joint_names)
    joint_name = param_info.joint_names{i};
    coeffs = param_info.joint_coeffs{i};
    short_name = getShortenedJointName(joint_name);

    for j = 1:length(coeffs)
        coeff = coeffs(j);
        col_names{end+1} = sprintf('%s_%s', short_name, coeff);
        col_widths{end+1} = 55;
        col_editable(end+1) = true;
    end
end

handles.coefficients_table = uitable('Parent', panel, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.05, 0.96, 0.80], ...
    'ColumnName', col_names, ...
    'ColumnWidth', col_widths, ...
    'RowStriping', 'on', ...
    'ColumnEditable', col_editable, ...
    'FontSize', 8, ...
    'CellEditCallback', @coefficientCellEditCallback);

% Initialize tracking
handles.edited_cells = {};
handles.param_info = param_info;
end

% Additional callback functions
function browseInputFile(~, ~)
handles = guidata(gcbf);

% Determine starting directory - prefer last used or common project locations
start_dir = pwd;
if isfield(handles, 'preferences') && ~isempty(handles.preferences.last_input_file_path)
    [last_dir, ~, ~] = fileparts(handles.preferences.last_input_file_path);
    if exist(last_dir, 'dir')
        start_dir = last_dir;
    end
else
    % Try common project locations
    possible_dirs = {
        'Input Files',
        'Model',
        fullfile(pwd, 'Input Files'),
        fullfile(pwd, 'Model'),
        fullfile(pwd, '..', 'Input Files')
        };

    for i = 1:length(possible_dirs)
        if exist(possible_dirs{i}, 'dir')
            start_dir = possible_dirs{i};
            break;
        end
    end
end

[filename, pathname] = uigetfile({'*.mat', 'MAT Files'; '*.*', 'All Files'}, 'Select Input File', start_dir);

if filename ~= 0
    full_path = fullfile(pathname, filename);
    handles.selected_input_file = full_path;

    % Update display
    set(handles.input_file_edit, 'String', filename);

    % Save preferences with new input file
    saveUserPreferences(handles);

    guidata(handles.fig, handles);
end
end

function autoUpdateSummary(~, ~, fig)
if nargin < 3 || isempty(fig)
    fig = gcbf;
end
handles = guidata(fig);

% Update both summary and coefficients preview
updatePreview([], [], fig);
updateCoefficientsPreview([], [], fig);
end

function autoUpdateSummaryAndSave(~, ~, fig)
if nargin < 3 || isempty(fig)
    fig = gcbf;
end
handles = guidata(fig);

% Update both summary and coefficients preview
updatePreview([], [], fig);
updateCoefficientsPreview([], [], fig);

% Save preferences after updating
saveUserPreferences(handles);
end

function torqueScenarioCallback(src, ~)
handles = guidata(gcbf);
scenario_idx = get(src, 'Value');

% Enable/disable controls
switch scenario_idx
    case 1 % Variable Torques
        set(handles.coeff_range_edit, 'Enable', 'on');
    case 2 % Zero Torque
        set(handles.coeff_range_edit, 'Enable', 'off');
    case 3 % Constant Torque
        set(handles.coeff_range_edit, 'Enable', 'off');
end

autoUpdateSummary([], [], gcbf);
guidata(handles.fig, handles);
end

function browseOutputFolder(src, ~)
handles = guidata(gcbf);
folder = uigetdir(get(handles.output_folder_edit, 'String'), 'Select Output Folder');
if folder ~= 0
    set(handles.output_folder_edit, 'String', folder);
    autoUpdateSummary([], [], gcbf);
    guidata(handles.fig, handles);
    saveUserPreferences(handles);
end
end

function updatePreview(~, ~, fig)
if nargin < 3 || isempty(fig)
    fig = gcbf;
end
handles = guidata(fig);

try
    % Get current settings
    num_trials = str2double(get(handles.num_trials_edit, 'String'));
    sim_time = str2double(get(handles.sim_time_edit, 'String'));
    sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
    scenario_idx = get(handles.torque_scenario_popup, 'Value');

    % Create preview data
    scenarios = {'Variable Torques', 'Zero Torque', 'Constant Torque'};
    preview_data = {
        'Number of Trials', num2str(num_trials), 'Total simulation runs';
        'Simulation Time', [num2str(sim_time) ' s'], 'Duration per trial';
        'Sample Rate', [num2str(sample_rate) ' Hz'], 'Data sampling frequency';
        'Data Points', num2str(round(sim_time * sample_rate)), 'Per trial time series';
        'Torque Scenario', scenarios{scenario_idx}, 'Coefficient generation method';
        };

    % Add scenario-specific info
    if scenario_idx == 1
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        preview_data = [preview_data; {
            'Coefficient Range', ['±' num2str(coeff_range)], 'Random variation bounds'
            }];
    elseif scenario_idx == 3
        constant_value = 10.0; % Default constant value
        preview_data = [preview_data; {
            'Constant Value', num2str(constant_value), 'G coefficient value'
            }];
    end

    % Add data sampling info
    expected_points = round(sim_time * sample_rate);
    preview_data = [preview_data; {
        'Expected Data Points', num2str(expected_points), 'Per trial after resampling'
        }];

    % Add output info
    output_folder = get(handles.output_folder_edit, 'String');
    folder_name = get(handles.folder_name_edit, 'String');
    preview_data = [preview_data; {
        'Output Location', fullfile(output_folder, folder_name), 'File destination'
        }];

    set(handles.preview_table, 'Data', preview_data);

catch ME
    error_data = {'Error', 'Check inputs', ME.message};
    set(handles.preview_table, 'Data', error_data);
end
end

function updateCoefficientsPreview(~, ~, fig)
if nargin < 3 || isempty(fig)
    fig = gcbf;
end
handles = guidata(fig);

try
    % Get current settings
    num_trials = str2double(get(handles.num_trials_edit, 'String'));
    if isnan(num_trials) || num_trials <= 0
        num_trials = 5;
    end
    display_trials = num_trials; % Show all trials
    % Use actual num_trials for simulation, display_trials for preview

    scenario_idx = get(handles.torque_scenario_popup, 'Value');
    coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
    constant_value = 10.0; % Default constant value since we removed the input field

    % Get parameter info
    param_info = getPolynomialParameterInfo();
    total_columns = 1 + param_info.total_params;

    % Generate coefficient data for display (limited to 100 for performance)
    coeff_data = cell(display_trials, total_columns);

    for i = 1:display_trials
        coeff_data{i, 1} = i; % Trial number

        col_idx = 2;
        for joint_idx = 1:length(param_info.joint_names)
            coeffs = param_info.joint_coeffs{joint_idx};
            for coeff_idx = 1:length(coeffs)
                coeff_letter = coeffs(coeff_idx);

                switch scenario_idx
                    case 1 % Variable Torques
                        if ~isnan(coeff_range) && coeff_range > 0
                            % Generate random coefficient within specified range with bounds validation
                            random_value = (rand - 0.5) * 2 * coeff_range;
                            % Ensure value is within bounds [-coeff_range, +coeff_range]
                            random_value = max(-coeff_range, min(coeff_range, random_value));
                            coeff_data{i, col_idx} = sprintf('%.2f', random_value);
                        else
                            coeff_data{i, col_idx} = sprintf('%.2f', (rand - 0.5) * 100);
                        end
                    case 2 % Zero Torque
                        coeff_data{i, col_idx} = '0.00';
                    case 3 % Constant Torque
                        % FIXED: G is the constant term (last coefficient)
                        if coeff_letter == 'G'
                            if ~isnan(constant_value)
                                coeff_data{i, col_idx} = sprintf('%.2f', constant_value);
                            else
                                coeff_data{i, col_idx} = '10.00';
                            end
                        else
                            coeff_data{i, col_idx} = '0.00';
                        end
                end
                col_idx = col_idx + 1;
            end
        end
    end

    % Update table
    set(handles.coefficients_table, 'Data', coeff_data);
    handles.edited_cells = {}; % Clear edit tracking

    % Store original data
    handles.original_coefficients_data = coeff_data;
    handles.original_coefficients_columns = get(handles.coefficients_table, 'ColumnName');
    guidata(handles.fig, handles);

catch ME
    fprintf('Error in updateCoefficientsPreview: %s\n', ME.message);
end
end

function updateCoefficientsPreviewAndSave(~, ~, fig)
if nargin < 3 || isempty(fig)
    fig = gcbf;
end
handles = guidata(fig);

% Update coefficients preview
updateCoefficientsPreview([], [], fig);

% Save preferences after updating
saveUserPreferences(handles);
end

% Joint Editor callbacks
function updateJointCoefficients(src, evt)
handles = guidata(gcbf);
selected_idx = get(handles.joint_selector, 'Value');
joint_names = get(handles.joint_selector, 'String');

% Load coefficients from table if available
loadJointFromTable([], [], gcbf);

% Update status
set(handles.joint_status, 'String', sprintf('Ready - %s selected', joint_names{selected_idx}));
guidata(handles.fig, handles);
end

function updateTrialSelectionMode(src, evt)
handles = guidata(gcbf);
selection_idx = get(handles.trial_selection_popup, 'Value');

if selection_idx == 1 % All Trials
    set(handles.trial_number_edit, 'Enable', 'off');
else % Specific Trial
    set(handles.trial_number_edit, 'Enable', 'on');
end

guidata(handles.fig, handles);
end

function validateCoefficientInput(src, evt)
value = get(src, 'String');
num_value = str2double(value);

if isnan(num_value)
    set(src, 'String', '0.00');
    msgbox('Please enter a valid number', 'Invalid Input', 'warn');
else
    set(src, 'String', sprintf('%.2f', num_value));
end
end

function applyJointToTable(src, evt)
handles = guidata(gcbf);

try
    % Get selected joint
    joint_idx = get(handles.joint_selector, 'Value');
    param_info = handles.param_info;

    % Get coefficient values
    coeff_values = zeros(1, 7);
    for i = 1:7
        coeff_values(i) = str2double(get(handles.joint_coeff_edits(i), 'String'));
    end

    % Get current table data
    table_data = get(handles.coefficients_table, 'Data');

    % Determine which trials to apply to
    apply_mode = get(handles.trial_selection_popup, 'Value');
    if apply_mode == 1 % All Trials
        trials = 1:size(table_data, 1);
    else % Specific Trial
        trial_num = str2double(get(handles.trial_number_edit, 'String'));
        if isnan(trial_num) || trial_num < 1 || trial_num > size(table_data, 1)
            msgbox('Invalid trial number', 'Error', 'error');
            return;
        end
        trials = trial_num;
    end

    % Calculate column indices
    col_start = 2 + (joint_idx - 1) * 7;

    % Apply values
    for trial = trials
        for i = 1:7
            table_data{trial, col_start + i - 1} = sprintf('%.2f', coeff_values(i));
        end
    end

    % Update table
    set(handles.coefficients_table, 'Data', table_data);

    % Update status
    if apply_mode == 1
        status_msg = sprintf('Applied %s coefficients to all trials', param_info.joint_names{joint_idx});
    else
        status_msg = sprintf('Applied %s coefficients to trial %d', param_info.joint_names{joint_idx}, trials);
    end
    set(handles.joint_status, 'String', status_msg);

catch ME
    msgbox(['Error applying coefficients: ' ME.message], 'Error', 'error');
end
end

function loadJointFromTable(src, evt, fig)
if nargin < 3
    fig = gcbf;
end
handles = guidata(fig);

try
    % Get selected joint
    joint_idx = get(handles.joint_selector, 'Value');

    % Get table data
    table_data = get(handles.coefficients_table, 'Data');

    if isempty(table_data)
        return;
    end

    % Determine which trial to load from
    apply_mode = get(handles.trial_selection_popup, 'Value');
    if apply_mode == 2 % Specific Trial
        trial_num = str2double(get(handles.trial_number_edit, 'String'));
        if isnan(trial_num) || trial_num < 1 || trial_num > size(table_data, 1)
            trial_num = 1;
        end
    else
        trial_num = 1; % Default to first trial
    end

    % Calculate column indices
    col_start = 2 + (joint_idx - 1) * 7;

    % Load values
    for i = 1:7
        value_str = table_data{trial_num, col_start + i - 1};
        if ischar(value_str)
            value = str2double(value_str);
        else
            value = value_str;
        end
        set(handles.joint_coeff_edits(i), 'String', sprintf('%.2f', value));
    end

catch ME
    % Silently fail or set defaults
    for i = 1:7
        set(handles.joint_coeff_edits(i), 'String', '0.00');
    end
end
end

% Coefficients table callbacks
function resetCoefficientsToGenerated(src, evt)
handles = guidata(gcbf);

if isfield(handles, 'original_coefficients_data')
    set(handles.coefficients_table, 'Data', handles.original_coefficients_data);
    handles.edited_cells = {};
    guidata(handles.fig, handles);
    msgbox('Coefficients reset to generated values', 'Reset Complete', 'help');
else
    updateCoefficientsPreview([], [], gcbf);
end
end

function coefficientCellEditCallback(src, evt)
handles = guidata(gcbf);

if evt.Column > 1 % Only coefficient columns are editable
    % Validate input
    new_value = evt.NewData;
    if ischar(new_value)
        num_value = str2double(new_value);
    else
        num_value = new_value;
    end

    if isnan(num_value)
        % Revert to old value
        table_data = get(src, 'Data');
        table_data{evt.Row, evt.Column} = evt.PreviousData;
        set(src, 'Data', table_data);
        msgbox('Please enter a valid number', 'Invalid Input', 'warn');
    else
        % Format and update
        table_data = get(src, 'Data');
        table_data{evt.Row, evt.Column} = sprintf('%.2f', num_value);
        set(src, 'Data', table_data);

        % Track edit
        cell_id = sprintf('%d,%d', evt.Row, evt.Column);
        if ~ismember(cell_id, handles.edited_cells)
            handles.edited_cells{end+1} = cell_id;
        end
        guidata(handles.fig, handles);
    end
end
end

function applyRowToAll(src, evt)
handles = guidata(gcbf);

table_data = get(handles.coefficients_table, 'Data');
if isempty(table_data)
    return;
end

% Ask which row to copy
prompt = sprintf('Enter row number to copy (1-%d):', size(table_data, 1));
answer = inputdlg(prompt, 'Apply Row', 1, {'1'});

if ~isempty(answer)
    row_num = str2double(answer{1});
    if ~isnan(row_num) && row_num >= 1 && row_num <= size(table_data, 1)
        % Copy row to all others
        row_data = table_data(row_num, 2:end);
        for i = 1:size(table_data, 1)
            if i ~= row_num
                table_data(i, 2:end) = row_data;
            end
        end
        set(handles.coefficients_table, 'Data', table_data);
        msgbox(sprintf('Row %d applied to all trials', row_num), 'Success');
    else
        msgbox('Invalid row number', 'Error', 'error');
    end
end
end

function exportCoefficientsToCSV(src, evt)
handles = guidata(gcbf);

[filename, pathname] = uiputfile('*.csv', 'Save Coefficients As');
if filename ~= 0
    try
        % Get table data
        table_data = get(handles.coefficients_table, 'Data');
        col_names = get(handles.coefficients_table, 'ColumnName');

        % Convert to table
        T = cell2table(table_data, 'VariableNames', col_names);

        % Write to CSV
        writetable(T, fullfile(pathname, filename));
        msgbox('Coefficients exported successfully', 'Success');
    catch ME
        msgbox(['Error exporting: ' ME.message], 'Error', 'error');
    end
end
end

function importCoefficientsFromCSV(src, evt)
handles = guidata(gcbf);

[filename, pathname] = uigetfile('*.csv', 'Select Coefficients File');
if filename ~= 0
    try
        % Read CSV
        T = readtable(fullfile(pathname, filename));

        % Convert to cell array
        table_data = table2cell(T);

        % Update table
        set(handles.coefficients_table, 'Data', table_data);
        msgbox('Coefficients imported successfully', 'Success');
    catch ME
        msgbox(['Error importing: ' ME.message], 'Error', 'error');
    end
end
end

function saveScenario(src, evt)
handles = guidata(gcbf);

prompt = 'Enter name for this scenario:';
answer = inputdlg(prompt, 'Save Scenario', 1, {'My Scenario'});

if ~isempty(answer)
    try
        scenario.name = answer{1};
        scenario.coefficients = get(handles.coefficients_table, 'Data');
        scenario.settings = struct();
        scenario.settings.torque_scenario = get(handles.torque_scenario_popup, 'Value');
        scenario.settings.coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        scenario.settings.constant_value = 10.0; % Default constant value

        % Save to file
        filename = sprintf('scenario_%s.mat', matlab.lang.makeValidName(answer{1}));
        save(filename, 'scenario');
        msgbox(['Scenario saved as ' filename], 'Success');
    catch ME
        msgbox(['Error saving scenario: ' ME.message], 'Error', 'error');
    end
end
end

function loadScenario(src, evt)
handles = guidata(gcbf);

[filename, pathname] = uigetfile('scenario_*.mat', 'Select Scenario File');
if filename ~= 0
    try
        loaded = load(fullfile(pathname, filename));
        scenario = loaded.scenario;

        % Apply settings
        set(handles.coefficients_table, 'Data', scenario.coefficients);
        set(handles.torque_scenario_popup, 'Value', scenario.settings.torque_scenario);
        set(handles.coeff_range_edit, 'String', num2str(scenario.settings.coeff_range));
        % Note: constant_value_edit removed from GUI, using default value

        % Trigger scenario callback
        torqueScenarioCallback(handles.torque_scenario_popup, []);

        msgbox(['Loaded scenario: ' scenario.name], 'Success');
    catch ME
        msgbox(['Error loading scenario: ' ME.message], 'Error', 'error');
    end
end
end

function searchCoefficients(src, evt)
handles = guidata(gcbf);
search_term = lower(get(handles.search_edit, 'String'));

if isempty(search_term)
    return;
end

% Get column names
col_names = get(handles.coefficients_table, 'ColumnName');

% Find matching columns
matching_cols = [];
for i = 2:length(col_names) % Skip trial column
    if contains(lower(col_names{i}), search_term)
        matching_cols(end+1) = i;
    end
end

if ~isempty(matching_cols)
    msgbox(sprintf('Found %d matching columns', length(matching_cols)), 'Search Results');
    % Could add highlighting functionality here
else
    msgbox('No matching columns found', 'Search Results');
end
end

function clearSearch(src, evt)
handles = guidata(gcbf);
set(handles.search_edit, 'String', '');
end

% Additional helper functions
function selectSimulinkModel(src, evt)
handles = guidata(gcbf);

% Get list of open models
open_models = find_system('type', 'block_diagram');

if isempty(open_models)
    % No models open, try to find models in the project
    possible_models = {};
    possible_paths = {};

    % Check common locations
    search_paths = {
        'Model',
        '.',
        fullfile(pwd, 'Model'),
        fullfile(pwd, '..', 'Model')
        };

    for i = 1:length(search_paths)
        if exist(search_paths{i}, 'dir')
            slx_files = dir(fullfile(search_paths{i}, '*.slx'));
            mdl_files = dir(fullfile(search_paths{i}, '*.mdl'));

            for j = 1:length(slx_files)
                model_name = slx_files(j).name(1:end-4); % Remove .slx
                possible_models{end+1} = model_name;
                possible_paths{end+1} = fullfile(search_paths{i}, slx_files(j).name);
            end

            for j = 1:length(mdl_files)
                model_name = mdl_files(j).name(1:end-4); % Remove .mdl
                possible_models{end+1} = model_name;
                possible_paths{end+1} = fullfile(search_paths{i}, mdl_files(j).name);
            end
        end
    end

    if isempty(possible_models)
        msgbox('No Simulink models found. Please ensure you have .slx or .mdl files in the Model directory or current directory.', 'No Models Found', 'warn');
        return;
    end

    % Let user select from found models
    [selection, ok] = listdlg('ListString', possible_models, ...
        'SelectionMode', 'single', ...
        'Name', 'Select Model', ...
        'PromptString', 'Select a Simulink model:');

    if ok
        handles.model_name = possible_models{selection};
        handles.model_path = possible_paths{selection};
        handles.model_was_loaded = false; % Model was found but not loaded
        set(handles.model_display, 'String', handles.model_name);
        guidata(handles.fig, handles);
        saveUserPreferences(handles);
    end

else
    % Models are open, let user select from open models
    [selection, ok] = listdlg('ListString', open_models, ...
        'SelectionMode', 'single', ...
        'Name', 'Select Model', ...
        'PromptString', 'Select a Simulink model:');

    if ok
        handles.model_name = open_models{selection};
        handles.model_path = which(handles.model_name);
        handles.model_was_loaded = true; % Model is already loaded
        set(handles.model_display, 'String', handles.model_name);
        guidata(handles.fig, handles);
        saveUserPreferences(handles);
    end
end
end

function clearAllCheckpoints(~, ~)
handles = guidata(gcbf);

% Find all checkpoint files
checkpoint_files = dir('checkpoint_*.mat');

if isempty(checkpoint_files)
    msgbox('No checkpoint files found to clear.', 'No Checkpoints', 'help');
    return;
end

% Ask for confirmation
answer = questdlg(sprintf('Delete %d checkpoint files? This action cannot be undone.', length(checkpoint_files)), ...
    'Clear Checkpoints', 'Yes', 'No', 'No');

if strcmp(answer, 'Yes')
    try
        for i = 1:length(checkpoint_files)
            delete(checkpoint_files(i).name);
        end
        msgbox(sprintf('Deleted %d checkpoint files.', length(checkpoint_files)), 'Checkpoints Cleared', 'help');
    catch ME
        msgbox(['Error clearing checkpoints: ' ME.message], 'Error', 'error');
    end
end
end

function saveUserPreferences(handles)
% Save current settings as preferences
try
    % Ensure preferences exist
    if ~isfield(handles, 'preferences')
        handles.preferences = struct();
    end

    % Update preferences with current settings
    if isfield(handles, 'output_folder_edit')
        folder = get(handles.output_folder_edit, 'String');
        if ~isempty(folder)
            handles.preferences.last_output_folder = folder;
        end
    end

    % Save input file path if selected
    if isfield(handles, 'selected_input_file') && ~isempty(handles.selected_input_file)
        handles.preferences.last_input_file_path = handles.selected_input_file;
        [~, filename, ext] = fileparts(handles.selected_input_file);
        handles.preferences.last_input_file = [filename ext];
    end

    % Save model information if available
    if isfield(handles, 'model_name')
        handles.preferences.last_model_name = handles.model_name;
    end
    if isfield(handles, 'model_path')
        handles.preferences.last_model_path = handles.model_path;
    end
    if isfield(handles, 'model_was_loaded')
        handles.preferences.last_model_was_loaded = handles.model_was_loaded;
    end

    % Save other current settings
    if isfield(handles, 'num_trials_edit')
        value = str2double(get(handles.num_trials_edit, 'String'));
        if ~isnan(value)
            handles.preferences.default_num_trials = value;
        end
    end

    if isfield(handles, 'sim_time_edit')
        value = str2double(get(handles.sim_time_edit, 'String'));
        if ~isnan(value)
            handles.preferences.default_sim_time = value;
        end
    end

    if isfield(handles, 'sample_rate_edit')
        value = str2double(get(handles.sample_rate_edit, 'String'));
        if ~isnan(value)
            handles.preferences.default_sample_rate = value;
        end
    end

    if isfield(handles, 'enable_master_dataset')
        handles.preferences.enable_master_dataset = get(handles.enable_master_dataset, 'Value');
    end

    % Save to file
    script_dir = fileparts(mfilename('fullpath'));
    pref_file = fullfile(script_dir, 'user_preferences.mat');
    preferences = handles.preferences;  % Create local variable for saving
    save(pref_file, 'preferences');

catch ME
    fprintf('Warning: Could not save preferences: %s\n', ME.message);
end
end

% External functions are now used:
% - getPolynomialParameterInfo() calls the external getPolynomialParameterInfo.m
% - getShortenedJointName() calls the external getShortenedJointName.m

function handles = createLeftColumnContent(parent, handles)
% Create left column panels
panelSpacing = 0.015;
panelPadding = 0.01;

% Calculate heights
numPanels = 1;  % Just Configuration (includes modeling and progress)
totalSpacing = panelPadding + (numPanels-1)*panelSpacing + panelPadding;
availableHeight = 1 - totalSpacing;

h1 = 1.0 * availableHeight;  % Configuration panel takes full height (increased to show all elements)

% Calculate positions
y1 = panelPadding;

% Create panels
handles = createTrialAndDataPanel(parent, handles, y1, h1);
end

function handles = createRightColumnContent(parent, handles)
% Create right column panels
panelSpacing = 0.015;
panelPadding = 0.01;

% Calculate heights
numPanels = 4;
totalSpacing = panelPadding + (numPanels-1)*panelSpacing + panelPadding;
availableHeight = 1 - totalSpacing;

h1 = 0.35 * availableHeight;  % Summary section height
h2 = 0.252 * availableHeight;  % Joint editor height increased by 5% more (0.24 * 1.05 = 0.252)
h3 = 0.36 * availableHeight;  % Coefficients panel height increased by 20% (0.30 * 1.2 = 0.36)
h4 = 0.05 * availableHeight;  % Reduced batch settings to make room

% Calculate positions
y4 = panelPadding;
y3 = y4 + h4 + panelSpacing;
y2 = y3 + h3 + panelSpacing;
y1 = y2 + h2 + panelSpacing;

% Create panels
handles = createPreviewPanel(parent, handles, y1, h1);
handles = createJointEditorPanel(parent, handles, y2, h2);
handles = createCoefficientsPanel(parent, handles, y3, h3);
end

% Run Generation Process
function runGeneration(handles)
try
    fprintf('[DEBUG] === RUN GENERATION STARTED ===\n');
    config = handles.config;

    fprintf('[DEBUG] Extracting coefficients from table...\n');
    % Extract coefficients from table
    config.coefficient_values = extractCoefficientsFromTable(handles);
    if isempty(config.coefficient_values)
        fprintf('[DEBUG] ERROR: No coefficient values available!\n');
        error('No coefficient values available');
    end
    fprintf('[DEBUG] Extracted %d coefficient sets\n', size(config.coefficient_values, 1));

    fprintf('[DEBUG] Creating output directory: %s\n', config.output_folder);
    % Create output directory
    if ~exist(config.output_folder, 'dir')
        mkdir(config.output_folder);
        fprintf('[DEBUG] Created output directory\n');
    else
        fprintf('[DEBUG] Output directory already exists\n');
    end

    set(handles.status_text, 'String', 'Status: Running trials...');

    fprintf('[DEBUG] Checking execution mode...\n');
    % Execute dataset generation
    execution_mode = get(handles.execution_mode_popup, 'Value');
    fprintf('[DEBUG] Execution mode: %d (1=Sequential, 2=Parallel)\n', execution_mode);

    if execution_mode == 2 && license('test', 'Distrib_Computing_Toolbox')
        fprintf('[DEBUG] Using parallel execution\n');
        % Parallel execution
        successful_trials = runParallelSimulations(handles, config);
    else
        fprintf('[DEBUG] Using sequential execution\n');
        % Sequential execution
        successful_trials = runSequentialSimulations(handles, config);
    end

    % Check if user requested stop
    if handles.should_stop
        set(handles.status_text, 'String', 'Status: Generation stopped by user');
        set(handles.progress_text, 'String', 'Stopped');
        % Reset GUI state for next run
        resetGUIState(handles);
    else
        % Final status
        failed_trials = config.num_simulations - successful_trials;

        % Ensure is_running is reset
        handles.is_running = false;
        guidata(handles.fig, handles);
        final_msg = sprintf('Complete: %d successful, %d failed', successful_trials, failed_trials);
        set(handles.status_text, 'String', ['Status: ' final_msg]);
        set(handles.progress_text, 'String', final_msg);

        % Compile dataset (only if enabled)
        if successful_trials > 0
            enable_master_dataset = get(handles.enable_master_dataset, 'Value');
            if enable_master_dataset
                set(handles.status_text, 'String', 'Status: Compiling master dataset...');
                drawnow;
                try
                    compileDataset(config);
                    set(handles.status_text, 'String', ['Status: ' final_msg ' - Dataset compiled']);
                catch ME
                    fprintf('Warning: Master dataset compilation failed: %s\n', ME.message);
                    set(handles.status_text, 'String', ['Status: ' final_msg ' - Individual trials saved (master dataset failed)']);
                end
            else
                set(handles.status_text, 'String', ['Status: ' final_msg ' - Individual trials saved (master dataset disabled)']);
            end
        end

        % Save script and settings for reproducibility
        try
            saveScriptAndSettings(config);
        catch ME
            fprintf('Warning: Could not save script and settings: %s\n', ME.message);
        end

        % Reset GUI state for next run
        resetGUIState(handles);
    end

catch ME
    try
        set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
    catch
        % GUI might be destroyed, ignore the error
    end
    errordlg(ME.message, 'Generation Failed');
end

% Always cleanup state and UI (replaces finally block)
try
    % Stop performance tracking for generation
    if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
            ismethod(handles.performance_tracker, 'stop_timer')
        try
            handles.performance_tracker.stop_timer('Data_Generation');
            fprintf('⏱️ Completed: Data Generation\n');
        catch ME
            fprintf('Warning: Could not stop performance timer: %s\n', ME.message);
        end
    end

    handles.is_running = false;
    set(handles.play_pause_button, 'Enable', 'on', 'String', 'Start');
    set(handles.stop_button, 'Enable', 'off');
    guidata(handles.fig, handles);
catch
    % GUI might be destroyed, ignore the error
end
end

function successful_trials = runParallelSimulations(handles, config)
% Initialize parallel pool with better error handling

% Start performance tracking for parallel simulations
if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
        ismethod(handles.performance_tracker, 'start_timer')
    try
        handles.performance_tracker.start_timer('Parallel_Simulations');
        fprintf('⏱️ Started timing: Parallel Simulations\n');
    catch ME
        fprintf('Warning: Could not start parallel performance timer: %s\n', ME.message);
    end
end

try
    % First, check if there's an existing pool and clean it up if needed
    existing_pool = gcp('nocreate');
    if ~isempty(existing_pool)
        try
            % Check if the existing pool is healthy
            pool_info = existing_pool;
            fprintf('Found existing parallel pool with %d workers\n', pool_info.NumWorkers);

            % Test if the pool is responsive
            try
                spmd
                    test_var = 1;
                end
                fprintf('Existing pool is healthy, using it\n');
            catch
                fprintf('Existing pool appears unresponsive, deleting it\n');
                delete(existing_pool);
                existing_pool = [];
            end
        catch
            fprintf('Error checking existing pool, deleting it\n');
            delete(existing_pool);
            existing_pool = [];
        end
    end

    % Create new pool if needed
    if isempty(existing_pool)
        % Get cluster profile and worker count from user preferences
        cluster_profile = getFieldOrDefault(handles.preferences, 'cluster_profile', 'Local_Cluster');
        max_workers = getFieldOrDefault(handles.preferences, 'max_parallel_workers', 14);

        % Ensure cluster profile exists
        available_profiles = parallel.clusterProfiles();
        if ~ismember(cluster_profile, available_profiles)
            fprintf('Warning: Cluster profile "%s" not found, falling back to Local_Cluster\n', cluster_profile);
            cluster_profile = 'Local_Cluster';
            % Ensure Local_Cluster exists
            if ~ismember(cluster_profile, available_profiles)
                fprintf('Local_Cluster not found, creating it...\n');
                try
                    cluster = parallel.cluster.Local;
                    cluster.Profile = 'Local_Cluster';
                    cluster.saveProfile();
                    fprintf('Local_Cluster profile created successfully\n');
                catch ME
                    fprintf('Failed to create Local_Cluster profile: %s\n', ME.message);
                    cluster_profile = 'local';
                end
            end
        end

        % Get cluster object
        try
            cluster_obj = parcluster(cluster_profile);
            fprintf('Using cluster profile: %s\n', cluster_profile);

            % Check if cluster supports the requested number of workers
            if isfield(cluster_obj, 'NumWorkers') && cluster_obj.NumWorkers > 0
                cluster_max_workers = cluster_obj.NumWorkers;
                fprintf('Cluster supports max %d workers\n', cluster_max_workers);
                % Use the minimum of requested and cluster limit
                num_workers = min(max_workers, cluster_max_workers);
            else
                num_workers = max_workers;
            end

            fprintf('Starting parallel pool with %d workers using %s profile...\n', num_workers, cluster_profile);

            % Start parallel pool with specified cluster profile
            parpool(cluster_obj, num_workers);
            fprintf('Successfully started parallel pool with %s profile (%d workers)\n', cluster_profile, num_workers);

        catch ME
            fprintf('Failed to use cluster profile %s: %s\n', cluster_profile, ME.message);
            fprintf('Falling back to local profile...\n');

            % Fallback to local profile
            temp_cluster = parcluster('local');
            fallback_workers = min(max_workers, temp_cluster.NumWorkers);
            parpool('local', fallback_workers);
            fprintf('Successfully started parallel pool with local profile (%d workers)\n', fallback_workers);
        end
    end
catch ME
    warning('Failed to start parallel pool: %s. Falling back to sequential execution.', ME.message);
    successful_trials = runSequentialSimulations(handles, config);
    return;
end

% Get batch processing parameters
batch_size = config.batch_size;
save_interval = config.save_interval;
total_trials = config.num_simulations;

% Debug print to confirm settings
fprintf('[RUNTIME] Using batch size: %d, save interval: %d, verbosity: %s\n', config.batch_size, config.save_interval, config.verbosity);

if ~strcmp(config.verbosity, 'Silent')
    fprintf('Starting parallel batch processing:\n');
    fprintf('  Total trials: %d\n', total_trials);
    fprintf('  Batch size: %d\n', batch_size);
    fprintf('  Save interval: %d batches\n', save_interval);
end

% Calculate number of batches
num_batches = ceil(total_trials / batch_size);
successful_trials = 0;

% Store initial workspace state for restoration
initial_vars = who;

% Check for existing checkpoint
checkpoint_file = fullfile(config.output_folder, 'parallel_checkpoint.mat');
start_batch = 1;
if exist(checkpoint_file, 'file') && get(handles.enable_checkpoint_resume, 'Value')
    try
        checkpoint_data = load(checkpoint_file);
        if isfield(checkpoint_data, 'completed_trials')
            successful_trials = checkpoint_data.completed_trials;
            start_batch = checkpoint_data.next_batch;
            fprintf('Found checkpoint: %d trials completed, resuming from batch %d\n', successful_trials, start_batch);
        end
    catch ME
        fprintf('Warning: Could not load checkpoint: %s\n', ME.message);
    end
elseif exist(checkpoint_file, 'file') && ~get(handles.enable_checkpoint_resume, 'Value')
    fprintf('Checkpoint found but resume disabled - starting fresh\n');
end

% Ensure model is available on all parallel workers
try
    fprintf('Loading model on parallel workers...\n');
    spmd
        if ~bdIsLoaded(config.model_name)
            load_system(config.model_path);
        end
    end
    fprintf('Model loaded on all workers\n');
catch ME
    fprintf('Warning: Could not preload model on workers: %s\n', ME.message);
end

% Process batches
for batch_idx = start_batch:num_batches
    % Check for stop request
    if checkStopRequest(handles)
        fprintf('Parallel simulation stopped by user at batch %d\n', batch_idx);
        break;
    end

    % Calculate trials for this batch
    start_trial = (batch_idx - 1) * batch_size + 1;
    end_trial = min(batch_idx * batch_size, total_trials);
    batch_trials = end_trial - start_trial + 1;

    if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
        fprintf('\n--- Batch %d/%d (Trials %d-%d) ---\n', batch_idx, num_batches, start_trial, end_trial);
    end

    % Update progress
    progress_msg = sprintf('Batch %d/%d: Processing trials %d-%d...', batch_idx, num_batches, start_trial, end_trial);
    set(handles.progress_text, 'String', progress_msg);
    drawnow;

    % Prepare simulation inputs for this batch
    try
        batch_simInputs = prepareSimulationInputsForBatch(config, start_trial, end_trial);

        if isempty(batch_simInputs)
            fprintf('Failed to prepare simulation inputs for batch %d\n', batch_idx);
            continue;
        end

        if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
            fprintf('Prepared %d simulation inputs for batch %d\n', length(batch_simInputs), batch_idx);
        end

    catch ME
        fprintf('Error preparing batch %d inputs: %s\n', batch_idx, ME.message);
        continue;
    end

    % Run batch simulations
    try
        if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
            fprintf('Running batch %d with parsim...\n', batch_idx);
        end

        % Use parsim for parallel simulation with robust error handling
        % Attach all external functions needed by parallel workers
        attached_files = {
            config.model_path, ...
            'runSingleTrial.m', ...
            'processSimulationOutput.m', ...
            'setModelParameters.m', ...
            'setPolynomialCoefficients.m', ...
            'extractSignalsFromSimOut.m', ...
            'extractFromCombinedSignalBus.m', ...
            'extractFromNestedStruct.m', ...
            'extractLogsoutDataFixed.m', ...
            'extractSimscapeDataRecursive.m', ...
            'traverseSimlogNode.m', ...
            'extractDataFromField.m', ...
            'combineDataSources.m', ...
            'addModelWorkspaceData.m', ...
            'extractWorkspaceOutputs.m', ...
            'resampleDataToFrequency.m', ...
            'getPolynomialParameterInfo.m', ...
            'getShortenedJointName.m', ...
            'generateRandomCoefficients.m', ...
            'prepareSimulationInputsForBatch.m', ...
            'restoreWorkspace.m', ...
            'getMemoryInfo.m', ...
            'checkHighMemoryUsage.m', ...
            'loadInputFile.m', ...
            'checkStopRequest.m', ...
            'extractCoefficientsFromTable.m', ...
            'shouldShowDebug.m', ...
            'shouldShowVerbose.m', ...
            'shouldShowNormal.m', ...
            'mergeTables.m', ...
            'logical2str.m', ...
            'fallbackSimlogExtraction.m', ...
            'extractTimeSeriesData.m', ...
            'extractConstantMatrixData.m'
            };

        batch_simOuts = parsim(batch_simInputs, ...
            'TransferBaseWorkspaceVariables', 'on', ...
            'AttachedFiles', attached_files, ...
            'StopOnError', 'off');  % Don't stop on individual simulation errors

        % Check if parsim succeeded
        if isempty(batch_simOuts)
            fprintf('Batch %d failed - no results returned\n', batch_idx);
            continue;
        end

        % Process batch results
        batch_successful = 0;
        for i = 1:length(batch_simOuts)
            trial_num = start_trial + i - 1;

            try
                current_simOut = batch_simOuts(i);

                % Check if we got a valid single simulation output object
                if isempty(current_simOut)
                    fprintf('Trial %d: Empty simulation output\n', trial_num);
                    continue;
                end

                % Handle case where simOuts(i) returns multiple values (brace indexing issue)
                if ~isscalar(current_simOut)
                    fprintf('Trial %d: Multiple simulation outputs returned (brace indexing issue)\n', trial_num);
                    continue;
                end

                % Check if simulation completed successfully
                simulation_success = false;
                has_error = false;

                % Try multiple ways to check simulation status
                try
                    % Method 1: Check SimulationMetadata (standard way)
                    if isprop(current_simOut, 'SimulationMetadata') && ...
                            isfield(current_simOut.SimulationMetadata, 'ExecutionInfo')

                        execInfo = current_simOut.SimulationMetadata.ExecutionInfo;

                        if isfield(execInfo, 'StopEvent') && execInfo.StopEvent == "CompletedNormally"
                            simulation_success = true;
                        else
                            has_error = true;
                            fprintf('Trial %d simulation failed (metadata)\n', trial_num);

                            if isfield(execInfo, 'ErrorDiagnostic') && ~isempty(execInfo.ErrorDiagnostic)
                                fprintf('  Error: %s\n', execInfo.ErrorDiagnostic.message);
                            end
                        end
                    else
                        % Method 2: Check for ErrorMessage property (indicates failure)
                        if isprop(current_simOut, 'ErrorMessage') && ~isempty(current_simOut.ErrorMessage)
                            has_error = true;
                            fprintf('Trial %d simulation failed: %s\n', trial_num, current_simOut.ErrorMessage);
                        else
                            % Method 3: If no metadata but we have output data, assume success
                            % Check if we have expected output fields (logsout, simlog, etc.)
                            has_data = false;
                            if isprop(current_simOut, 'logsout') || isfield(current_simOut, 'logsout') || ...
                                    isprop(current_simOut, 'simlog') || isfield(current_simOut, 'simlog') || ...
                                    isprop(current_simOut, 'CombinedSignalBus') || isfield(current_simOut, 'CombinedSignalBus')
                                has_data = true;
                            end

                            if has_data
                                fprintf('Trial %d: Assuming success (has output data, no error message)\n', trial_num);
                                simulation_success = true;
                            else
                                fprintf('Trial %d: No metadata, no data, assuming failure\n', trial_num);
                                has_error = true;
                            end
                        end
                    end
                catch ME
                    fprintf('Trial %d: Error checking simulation status: %s\n', trial_num, ME.message);
                    has_error = true;
                end

                % Process simulation if it succeeded
                if simulation_success && ~has_error
                    try
                        result = processSimulationOutput(trial_num, config, current_simOut, config.capture_workspace);
                        if result.success
                            batch_successful = batch_successful + 1;
                            successful_trials = successful_trials + 1;
                            fprintf('Trial %d completed successfully\n', trial_num);
                        else
                            fprintf('Trial %d processing failed: %s\n', trial_num, result.error);
                        end
                    catch ME
                        fprintf('Error processing trial %d: %s\n', trial_num, ME.message);
                    end
                end

            catch ME
                % Handle brace indexing errors specifically
                if contains(ME.message, 'brace indexing') || contains(ME.message, 'comma separated list')
                    fprintf('Trial %d: Brace indexing error - simulation output corrupted\n', trial_num);
                    fprintf('  Error: %s\n', ME.message);
                else
                    fprintf('Trial %d: Unexpected error accessing simulation output: %s\n', trial_num, ME.message);
                end
            end
        end

        fprintf('Batch %d completed: %d/%d trials successful\n', batch_idx, batch_successful, batch_trials);

    catch ME
        fprintf('Batch %d failed: %s\n', batch_idx, ME.message);
    end

    % Memory cleanup after each batch
    fprintf('Performing memory cleanup after batch %d...\n', batch_idx);
    restoreWorkspace(initial_vars);
    java.lang.System.gc();  % Force garbage collection

    % Check memory usage if monitoring is enabled
    if config.enable_memory_monitoring
        try
            memoryInfo = getMemoryInfo();
            fprintf('Memory usage after batch %d: %.1f%%\n', batch_idx, memoryInfo.usage_percent);

            if memoryInfo.usage_percent > 85
                fprintf('Warning: High memory usage detected. Consider reducing batch size.\n');
            end
        catch ME
            fprintf('Warning: Could not check memory usage: %s\n', ME.message);
        end
    end

    % Save checkpoint if needed
    if mod(batch_idx, save_interval) == 0 || batch_idx == num_batches
        try
            checkpoint_data = struct();
            checkpoint_data.completed_trials = successful_trials;
            checkpoint_data.next_batch = batch_idx + 1;
            checkpoint_data.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            checkpoint_data.batch_idx = batch_idx;
            checkpoint_data.total_batches = num_batches;

            save(checkpoint_file, '-struct', 'checkpoint_data');
            fprintf('Checkpoint saved after batch %d (%d trials completed)\n', batch_idx, successful_trials);
        catch ME
            fprintf('Warning: Could not save checkpoint: %s\n', ME.message);
        end
    end

    % Small pause to let system recover
    pause(1);
end

% Final summary
fprintf('\n=== PARALLEL BATCH PROCESSING SUMMARY ===\n');
fprintf('Total trials: %d\n', total_trials);
fprintf('Successful: %d\n', successful_trials);
fprintf('Failed: %d\n', total_trials - successful_trials);
fprintf('Success rate: %.1f%%\n', (successful_trials / total_trials) * 100);

if successful_trials == 0
    fprintf('\nAll parallel simulations failed. Common causes:\n');
    fprintf('   • Model path not accessible on workers\n');
    fprintf('   • Missing workspace variables on workers\n');
    fprintf('   • Toolbox licensing issues on workers\n');
    fprintf('   • Model configuration conflicts in parallel mode\n');
    fprintf('   • Coefficient setting issues on workers\n');
    fprintf('\n Try sequential mode for detailed debugging\n');
end

% Clean up checkpoint file if completed successfully
if successful_trials == total_trials && exist(checkpoint_file, 'file')
    try
        delete(checkpoint_file);
        fprintf('Checkpoint file cleaned up (all trials completed)\n');
    catch ME
        fprintf('Warning: Could not clean up checkpoint file: %s\n', ME.message);
    end
end

% Stop performance tracking for parallel simulations
if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
        ismethod(handles.performance_tracker, 'stop_timer')
    try
        handles.performance_tracker.stop_timer('Parallel_Simulations');
        fprintf('⏱️ Completed: Parallel Simulations\n');
    catch ME
        fprintf('Warning: Could not stop parallel performance timer: %s\n', ME.message);
    end
end
end

% Helper function to check for stop requests and update progress
function shouldStop = checkStopRequest(handles)
shouldStop = false;
try
    % Get current handles
    current_handles = guidata(handles.fig);
    if isfield(current_handles, 'should_stop') && current_handles.should_stop
        shouldStop = true;
    end

    % Force UI update to prevent freezing
    drawnow;

catch
    % If we can't access handles, assume we should stop
    shouldStop = true;
end
end

% Helper function to update progress display
function updateProgress(handles, current, total, message)
try
    if nargin < 4
        message = 'Processing...';
    end

    progress_percent = round((current / total) * 100);
    progress_text = sprintf('%s (%d/%d - %d%%)', message, current, total, progress_percent);

    set(handles.progress_text, 'String', progress_text);
    drawnow;

catch
    % Silently fail if GUI is not available
end
end

% Helper function to monitor memory usage
function memoryInfo = getMemoryInfo()
try
    % Get MATLAB memory info
    memoryInfo = memory;

    % Calculate memory usage percentage
    memoryInfo.usage_percent = (memoryInfo.MemUsedMATLAB / memoryInfo.PhysicalMemory.Total) * 100;

    % Get system memory info if available
    if ispc
        try
            try
                [status, result] = system('wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /Value');
                if status ~= 0
                    result = '';
                end
            catch
                result = '';
            end
            lines = strsplit(result, '\n');
            total_mem = 0;
            free_mem = 0;

            for i = 1:length(lines)
                line = strtrim(lines{i});
                if startsWith(line, 'TotalVisibleMemorySize=')
                    total_mem = str2double(extractAfter(line, '='));
                elseif startsWith(line, 'FreePhysicalMemory=')
                    free_mem = str2double(extractAfter(line, '='));
                end
            end

            if total_mem > 0
                memoryInfo.system_total_mb = total_mem / 1024;
                memoryInfo.system_free_mb = free_mem / 1024;
                memoryInfo.system_usage_percent = ((total_mem - free_mem) / total_mem) * 100;
            end
        catch
            % Ignore system memory check errors
        end
    end

catch
    memoryInfo = struct('usage_percent', 0);
end
end

% Helper function to check if memory usage is high
function isHighMemory = checkHighMemoryUsage(threshold_percent)
if nargin < 1
    threshold_percent = 85; % Default threshold
end

try
    memoryInfo = getMemoryInfo();
    isHighMemory = memoryInfo.usage_percent > threshold_percent;

    if isHighMemory
        fprintf('Warning: High memory usage detected: %.1f%%\n', memoryInfo.usage_percent);
    end

catch
    isHighMemory = false;
end
end

% Helper function to generate random coefficients
function coefficients = generateRandomCoefficients(num_coefficients)
% Generate random coefficients with reasonable ranges for golf swing parameters
% These ranges are based on typical golf swing polynomial coefficients

% Different ranges for different coefficient types (A, B, C, D, E, F, G)
% A (t^6): Large range for major motion
% B (t^5): Large range for major motion
% C (t^4): Medium range for control
% D (t^3): Medium range for control
% E (t^2): Small range for fine control
% F (t^1): Small range for fine control
% G (constant): Small range for offset

coefficients = zeros(1, num_coefficients);

for i = 1:num_coefficients
    coeff_type = mod(i-1, 7) + 1; % A=1, B=2, C=3, D=4, E=5, F=6, G=7

    switch coeff_type
        case {1, 2} % A, B - Large range
            coefficients(i) = (rand() - 0.5) * 2000; % -1000 to 1000
        case {3, 4} % C, D - Medium range
            coefficients(i) = (rand() - 0.5) * 1000; % -500 to 500
        case {5, 6} % E, F - Small range
            coefficients(i) = (rand() - 0.5) * 200;  % -100 to 100
        case 7 % G - Very small range
            coefficients(i) = (rand() - 0.5) * 50;   % -25 to 25
    end
end
end

function successful_trials = runSequentialSimulations(handles, config)
fprintf('[DEBUG] === RUN SEQUENTIAL SIMULATIONS STARTED ===\n');

% Get batch processing parameters
batch_size = config.batch_size;
save_interval = config.save_interval;
total_trials = config.num_simulations;

fprintf('[DEBUG] Batch size: %d, Save interval: %d, Total trials: %d\n', batch_size, save_interval, total_trials);

% Start performance tracking for sequential simulations
if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
        ismethod(handles.performance_tracker, 'start_timer')
    try
        handles.performance_tracker.start_timer('Sequential_Simulations');
        fprintf('⏱️ Started timing: Sequential Simulations\n');
    catch ME
        fprintf('Warning: Could not start sequential performance timer: %s\n', ME.message);
    end
end

% Debug print to confirm settings
fprintf('[RUNTIME] Using batch size: %d, save interval: %d, verbosity: %s\n', config.batch_size, config.save_interval, config.verbosity);

if ~strcmp(config.verbosity, 'Silent')
    fprintf('Starting sequential batch processing:\n');
    fprintf('  Total trials: %d\n', total_trials);
    fprintf('  Batch size: %d\n', batch_size);
    fprintf('  Save interval: %d batches\n', save_interval);
end

% Calculate number of batches
num_batches = ceil(total_trials / batch_size);
successful_trials = 0;

% Store initial workspace state for restoration
initial_vars = who;

% Check for existing checkpoint
checkpoint_file = fullfile(config.output_folder, 'sequential_checkpoint.mat');
start_batch = 1;
if exist(checkpoint_file, 'file') && get(handles.enable_checkpoint_resume, 'Value')
    try
        checkpoint_data = load(checkpoint_file);
        if isfield(checkpoint_data, 'completed_trials')
            successful_trials = checkpoint_data.completed_trials;
            start_batch = checkpoint_data.next_batch;
            fprintf('Found checkpoint: %d trials completed, resuming from batch %d\n', successful_trials, start_batch);
        end
    catch ME
        fprintf('Warning: Could not load checkpoint: %s\n', ME.message);
    end
elseif exist(checkpoint_file, 'file') && ~get(handles.enable_checkpoint_resume, 'Value')
    fprintf('Checkpoint found but resume disabled - starting fresh\n');
end

% Process batches
for batch_idx = start_batch:num_batches
    % Check for stop request
    if checkStopRequest(handles)
        fprintf('Sequential simulation stopped by user at batch %d\n', batch_idx);
        break;
    end

    % Calculate trials for this batch
    start_trial = (batch_idx - 1) * batch_size + 1;
    end_trial = min(batch_idx * batch_size, total_trials);
    batch_trials = end_trial - start_trial + 1;

    if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
        fprintf('\n--- Batch %d/%d (Trials %d-%d) ---\n', batch_idx, num_batches, start_trial, end_trial);
    end

    % Update progress
    progress_msg = sprintf('Batch %d/%d: Processing trials %d-%d...', batch_idx, num_batches, start_trial, end_trial);
    set(handles.progress_text, 'String', progress_msg);
    drawnow;

    % Process trials in this batch
    batch_successful = 0;
    for trial = start_trial:end_trial
        % Check for stop request
        if checkStopRequest(handles)
            fprintf('Sequential simulation stopped by user at trial %d\n', trial);
            break;
        end

        % Update progress with percentage
        updateProgress(handles, trial, total_trials, 'Sequential simulation');

        try
            if trial <= size(config.coefficient_values, 1)
                trial_coefficients = config.coefficient_values(trial, :);
            else
                % Generate random coefficients for additional trials
                fprintf('Generating random coefficients for trial %d (beyond available data)\n', trial);
                trial_coefficients = generateRandomCoefficients(size(config.coefficient_values, 2));
            end

            result = runSingleTrial(trial, config, trial_coefficients, config.capture_workspace);

            if result.success
                batch_successful = batch_successful + 1;
                successful_trials = successful_trials + 1;
                fprintf('Trial %d completed successfully\n', trial);
            else
                fprintf('Trial %d failed: %s\n', trial, result.error);
            end

        catch ME
            fprintf('Trial %d error: %s\n', trial, ME.message);
        end
    end

    if strcmp(config.verbosity, 'Verbose') || strcmp(config.verbosity, 'Debug')
        fprintf('Batch %d completed: %d/%d trials successful\n', batch_idx, batch_successful, batch_trials);
    end

    % Memory cleanup after each batch
    fprintf('Performing memory cleanup after batch %d...\n', batch_idx);
    restoreWorkspace(initial_vars);
    java.lang.System.gc();  % Force garbage collection

    % Check memory usage if monitoring is enabled
    if config.enable_memory_monitoring
        try
            memoryInfo = getMemoryInfo();
            fprintf('Memory usage after batch %d: %.1f%%\n', batch_idx, memoryInfo.usage_percent);

            if memoryInfo.usage_percent > 85
                fprintf('Warning: High memory usage detected. Consider reducing batch size.\n');
            end
        catch ME
            fprintf('Warning: Could not check memory usage: %s\n', ME.message);
        end
    end

    % Save checkpoint if needed
    if mod(batch_idx, save_interval) == 0 || batch_idx == num_batches
        try
            checkpoint_data = struct();
            checkpoint_data.completed_trials = successful_trials;
            checkpoint_data.next_batch = batch_idx + 1;
            checkpoint_data.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            checkpoint_data.batch_idx = batch_idx;
            checkpoint_data.total_batches = num_batches;

            save(checkpoint_file, '-struct', 'checkpoint_data');
            fprintf('Checkpoint saved after batch %d (%d trials completed)\n', batch_idx, successful_trials);
        catch ME
            fprintf('Warning: Could not save checkpoint: %s\n', ME.message);
        end
    end

    % Small pause to let system recover
    pause(1);
end

% Final summary
fprintf('\n=== SEQUENTIAL BATCH PROCESSING SUMMARY ===\n');
fprintf('Total trials: %d\n', total_trials);
fprintf('Successful: %d\n', successful_trials);
fprintf('Failed: %d\n', total_trials - successful_trials);
fprintf('Success rate: %.1f%%\n', (successful_trials / total_trials) * 100);

% Clean up checkpoint file if completed successfully
if successful_trials == total_trials && exist(checkpoint_file, 'file')
    try
        delete(checkpoint_file);
        fprintf('Checkpoint file cleaned up (all trials completed)\n');
    catch ME
        fprintf('Warning: Could not clean up checkpoint file: %s\n', ME.message);
    end
end

% Stop performance tracking for sequential simulations
if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
        ismethod(handles.performance_tracker, 'stop_timer')
    try
        handles.performance_tracker.stop_timer('Sequential_Simulations');
        fprintf('⏱️ Completed: Sequential Simulations\n');
    catch ME
        fprintf('Warning: Could not stop sequential performance timer: %s\n', ME.message);
    end
end
end

% Add missing critical functions from original Data_GUI.m

function simInputs = prepareSimulationInputs(config, handles)
% Load the Simulink model
model_name = config.model_name;
if ~bdIsLoaded(model_name)
    try
        load_system(model_name);
    catch ME
        error('Could not load Simulink model "%s": %s', model_name, ME.message);
    end
end

% Create array of SimulationInput objects
simInputs = Simulink.SimulationInput.empty(0, config.num_simulations);

for trial = 1:config.num_simulations
    % Get coefficients for this trial
    if trial <= size(config.coefficient_values, 1)
        trial_coefficients = config.coefficient_values(trial, :);
    else
        % Generate random coefficients for additional trials
        trial_coefficients = generateRandomCoefficients(size(config.coefficient_values, 2));
    end

    % Ensure coefficients are numeric (fix for parallel execution)
    if iscell(trial_coefficients)
        trial_coefficients = cell2mat(trial_coefficients);
    end
    trial_coefficients = double(trial_coefficients);  % Ensure double precision

    % Create SimulationInput object
    simIn = Simulink.SimulationInput(model_name);

    % Set simulation parameters safely
    simIn = setModelParameters(simIn, config, handles);

    % Set polynomial coefficients
    try
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);
    catch ME
        fprintf('Warning: Could not set polynomial coefficients: %s\n', ME.message);
    end

    % Load input file if specified
    if ~isempty(config.input_file) && exist(config.input_file, 'file')
        simIn = loadInputFile(simIn, config.input_file);
    end

    simInputs(trial) = simIn;
end
end

function simIn = setModelParameters(simIn, config, handles)
% External function for setting model parameters - can be used in parallel processing
% This function accepts config as a parameter instead of relying on handles

% Set basic simulation parameters with careful error handling
try
    % Set stop time
    if isfield(config, 'simulation_time') && ~isempty(config.simulation_time)
        simIn = simIn.setModelParameter('StopTime', num2str(config.simulation_time));
    end

    % Set solver carefully
    try
        simIn = simIn.setModelParameter('Solver', 'ode23t');
    catch
        fprintf('Warning: Could not set solver to ode23t\n');
    end

    % Set tolerances carefully
    try
        simIn = simIn.setModelParameter('RelTol', '1e-3');
        simIn = simIn.setModelParameter('AbsTol', '1e-5');
    catch
        fprintf('Warning: Could not set solver tolerances\n');
    end

    % CRITICAL: Set output options for data logging
    try
        simIn = simIn.setModelParameter('SaveOutput', 'on');
        simIn = simIn.setModelParameter('SaveFormat', 'Structure');
        simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');
    catch ME
        fprintf('Warning: Could not set output options: %s\n', ME.message);
    end

    % Additional logging settings
    try
        simIn = simIn.setModelParameter('SignalLogging', 'on');
        simIn = simIn.setModelParameter('SaveTime', 'on');
    catch
        fprintf('Warning: Could not set logging options\n');
    end

    % To Workspace block settings
    try
        simIn = simIn.setModelParameter('LimitDataPoints', 'off');
    catch
        fprintf('Warning: Could not set LimitDataPoints\n');
    end

    % MINIMAL SIMSCAPE LOGGING CONFIGURATION (Essential Only)
    % Only set the essential parameter that actually works
    try
        simIn = simIn.setModelParameter('SimscapeLogType', 'all');
        fprintf('Debug: ✅ Set SimscapeLogType = all (essential parameter)\n');
    catch ME
        fprintf('Warning: Could not set essential SimscapeLogType parameter: %s\n', ME.message);
        fprintf('Warning: Simscape data extraction may not work without this parameter\n');
    end

    % Set simulation mode (animation control removed for now to fix data capture)
    try
        simIn = simIn.setModelParameter('SimulationMode', 'normal');
        fprintf('Debug: Set to normal simulation mode\n');
    catch ME
        fprintf('Warning: Could not set simulation mode: %s\n', ME.message);
    end

    % Set other model parameters to suppress unconnected port warnings
    try
        simIn = simIn.setModelParameter('UnconnectedInputMsg', 'none');
        simIn = simIn.setModelParameter('UnconnectedOutputMsg', 'none');
    catch
        % These parameters might not exist in all model types
    end

catch ME
    fprintf('Error setting model parameters: %s\n', ME.message);
    rethrow(ME);
end
end

function simIn = setPolynomialCoefficients(simIn, coefficients, config)
% Get parameter info for coefficient mapping
param_info = getPolynomialParameterInfo();

% Basic validation
if isempty(param_info.joint_names)
    error('No joint names found in polynomial parameter info');
end

% Handle parallel worker coefficient format issues
if iscell(coefficients)
    try
        % Check if cells contain strings or numbers
        if all(cellfun(@ischar, coefficients))
            % Convert string cells to numeric
            coefficients = cellfun(@str2double, coefficients);
        elseif all(cellfun(@isnumeric, coefficients))
            % Convert numeric cells to array
            coefficients = cell2mat(coefficients);
        else
            % Mixed content or other issues
            numeric_coeffs = zeros(size(coefficients));
            for i = 1:numel(coefficients)
                if ischar(coefficients{i})
                    numeric_coeffs(i) = str2double(coefficients{i});
                elseif isnumeric(coefficients{i})
                    numeric_coeffs(i) = coefficients{i};
                else
                    numeric_coeffs(i) = NaN;
                end
            end
            coefficients = numeric_coeffs;
        end
    catch ME
        fprintf('Error: Could not convert cell coefficients to numeric: %s\n', ME.message);
        % Try one more approach - flatten and convert
        try
            coefficients = str2double(coefficients(:));
        catch
            fprintf('Error: All conversion attempts failed\n');
            return;
        end
    end
end

% Ensure coefficients are numeric
if ~isnumeric(coefficients)
    fprintf('Error: Coefficients must be numeric, got %s\n', class(coefficients));
    return;
end

% Ensure coefficients are a row vector if needed
if size(coefficients, 1) > 1 && size(coefficients, 2) == 1
    coefficients = coefficients';
end

% Set coefficients as model variables
global_coeff_idx = 1;
variables_set = 0;

for joint_idx = 1:length(param_info.joint_names)
    joint_name = param_info.joint_names{joint_idx};
    coeffs = param_info.joint_coeffs{joint_idx};

    for local_coeff_idx = 1:length(coeffs)
        coeff_letter = coeffs(local_coeff_idx);
        var_name = sprintf('%s%s', joint_name, coeff_letter);

        if global_coeff_idx <= length(coefficients)
            try
                simIn = simIn.setVariable(var_name, coefficients(global_coeff_idx));
                variables_set = variables_set + 1;
            catch ME
                fprintf('  Warning: Failed to set %s: %s\n', var_name, ME.message);
            end
        else
            fprintf('  Warning: Not enough coefficients for %s (need %d, have %d)\n', var_name, global_coeff_idx, length(coefficients));
        end
        global_coeff_idx = global_coeff_idx + 1;
    end
end
end

function simIn = loadInputFile(simIn, input_file)
try
    % Load input data
    input_data = load(input_file);

    % Get field names and set as model variables
    field_names = fieldnames(input_data);
    for i = 1:length(field_names)
        field_name = field_names{i};
        field_value = input_data.(field_name);

        % Only set scalar values or small arrays
        if isscalar(field_value) || (isnumeric(field_value) && numel(field_value) <= 100)
            simIn = simIn.setVariable(field_name, field_value);
        end
    end
catch ME
    warning('Could not load input file %s: %s', input_file, ME.message);
end
end

function result = processSimulationOutput(trial_num, config, simOut, capture_workspace)
result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);

try
    fprintf('Processing simulation output for trial %d...\n', trial_num);

    % Extract data using the enhanced signal extraction system
    options = struct();
    options.extract_combined_bus = config.use_signal_bus;
    options.extract_logsout = config.use_logsout;
    options.extract_simscape = config.use_simscape;
    options.verbose = false; % Set to true for debugging

    [data_table, signal_info] = extractSignalsFromSimOut(simOut, options);

    if isempty(data_table)
        result.error = 'No data extracted from simulation';
        fprintf('No data extracted from simulation output\n');
        return;
    end

    fprintf('Extracted %d rows of data\n', height(data_table));

    % Resample data to desired frequency if specified
    if isfield(config, 'sample_rate') && ~isempty(config.sample_rate) && config.sample_rate > 0
        data_table = resampleDataToFrequency(data_table, config.sample_rate, config.simulation_time);
        fprintf('Resampled to %d rows at %g Hz\n', height(data_table), config.sample_rate);
    end

    % Add trial metadata
    num_rows = height(data_table);
    data_table.trial_id = repmat(trial_num, num_rows, 1);

    % Add coefficient columns
    param_info = getPolynomialParameterInfo();
    coeff_idx = 1;
    for j = 1:length(param_info.joint_names)
        joint_name = param_info.joint_names{j};
        coeffs = param_info.joint_coeffs{j};
        for k = 1:length(coeffs)
            coeff_name = sprintf('input_%s_%s', getShortenedJointName(joint_name), coeffs(k));
            if coeff_idx <= size(config.coefficient_values, 2)
                data_table.(coeff_name) = repmat(config.coefficient_values(trial_num, coeff_idx), num_rows, 1);
            end
            coeff_idx = coeff_idx + 1;
        end
    end

    % Add model workspace variables (segment lengths, masses, inertias, etc.)
    % Use the capture_workspace parameter passed to this function
    if nargin < 4
        capture_workspace = true; % Default to true if not provided
    end

    if capture_workspace
        data_table = addModelWorkspaceData(data_table, simOut, num_rows);
    else
        fprintf('Debug: Model workspace capture disabled by user setting\n');
    end

    % Save to file in selected format(s)
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    saved_files = {};

    % Determine file format from config (handle both field names for compatibility)
    file_format = 1; % Default to CSV
    if isfield(config, 'file_format')
        file_format = config.file_format;
    elseif isfield(config, 'format')
        file_format = config.format;
    end

    % Save based on selected format
    switch file_format
        case 1 % CSV Files
            filename = sprintf('trial_%03d_%s.csv', trial_num, timestamp);
            filepath = fullfile(config.output_folder, filename);
            writetable(data_table, filepath);
            saved_files{end+1} = filename;

        case 2 % MAT Files
            filename = sprintf('trial_%03d_%s.mat', trial_num, timestamp);
            filepath = fullfile(config.output_folder, filename);
            save(filepath, 'data_table', 'config');
            saved_files{end+1} = filename;

        case 3 % Both CSV and MAT
            % Save CSV
            csv_filename = sprintf('trial_%03d_%s.csv', trial_num, timestamp);
            csv_filepath = fullfile(config.output_folder, csv_filename);
            writetable(data_table, csv_filepath);
            saved_files{end+1} = csv_filename;

            % Save MAT
            mat_filename = sprintf('trial_%03d_%s.mat', trial_num, timestamp);
            mat_filepath = fullfile(config.output_folder, mat_filename);
            save(mat_filepath, 'data_table', 'config');
            saved_files{end+1} = mat_filename;
    end

    % Update result with primary filename
    filename = saved_files{1};

    result.success = true;
    result.filename = filename;
    result.data_points = num_rows;
    result.columns = width(data_table);

    fprintf('Trial %d completed: %d data points, %d columns\n', trial_num, num_rows, width(data_table));

catch ME
    result.success = false;
    result.error = ME.message;
    fprintf('Error processing trial %d output: %s\n', trial_num, ME.message);

    % Print stack trace for debugging
    fprintf('Processing error details:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end
end

function [time_data, signals] = traverseSimlogNode(node, parent_path, handles)
% External function for traversing Simscape log nodes - can be used in parallel processing
% This function doesn't rely on handles

time_data = [];
signals = {};

try
    % Get current node name
    node_name = '';
    if all(isprop(node, 'Name')) && all(~isempty(node.Name))
        node_name = node.Name;
    elseif all(isprop(node, 'id')) && all(~isempty(node.id))
        node_name = node.id;
    else
        node_name = 'UnnamedNode';
    end
    current_path = fullfile(parent_path, node_name);

    % SIMSCAPE MULTIBODY APPROACH: Try multiple extraction methods
    node_has_data = false;

    % Method 1: Check if node has direct data (time series)
    if all(isprop(node, 'time')) && all(isprop(node, 'values'))
        try
            extracted_time = node.time;
            extracted_data = node.values;

            if all(~isempty(extracted_time)) && all(~isempty(extracted_data)) && numel(extracted_time) > 0
                if isempty(time_data)
                    time_data = extracted_time;
                end

                % Create meaningful signal name
                signal_name = matlab.lang.makeValidName(sprintf('%s_data', current_path));
                signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                node_has_data = true;
            end
        catch ME
            % Method 1 failed - this is normal for non-data nodes
        end
    end

    % Method 2: Extract data from 5-level Multibody hierarchy (regardless of exportable flag)
    if ~node_has_data && all(isprop(node, 'series'))
        try
            % Get the signal ID (e.g., 'w' for angular velocity, 'q' for position)
            signal_id = 'data';
            if all(isprop(node, 'id')) && all(~isempty(node.id))
                signal_id = node.id;
            end

            % Try to get time and data directly from node.series (the correct API)
            try
                extracted_time = node.series.time;
                extracted_data = node.series.values;
            catch
                % Fallback: try to access as properties
                if all(isprop(node.series, 'time'))
                    extracted_time = node.series.time;
                else
                    extracted_time = [];
                end
                if all(isprop(node.series, 'values'))
                    extracted_data = node.series.values;
                else
                    extracted_data = [];
                end
            end

            if all(~isempty(extracted_time)) && all(~isempty(extracted_data)) && numel(extracted_time) > 0
                if isempty(time_data)
                    time_data = extracted_time;
                end

                % Create meaningful signal name: Body_Joint_Component_Axis_Signal
                signal_name = matlab.lang.makeValidName(sprintf('%s_%s', current_path, signal_id));
                signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                node_has_data = true;
            end
        catch ME
            % Series access failed - this is normal for non-data nodes
        end
    end

    % Method 3: Try to get children and recurse
    if ~node_has_data
        try
            % Try different methods to get children
            child_ids = {};

            % Method 3a: Try properties() approach
            try
                props = properties(node);
                child_ids = props;
            catch
                % Method 3b: Try direct children access
                try
                    if all(isprop(node, 'children'))
                        child_ids = node.children;
                    end
                catch
                    % Method 3c: Try series.children() if available
                    try
                        if all(isprop(node, 'series')) && all(isprop(node.series, 'children'))
                            child_ids = node.series.children;
                        end
                    catch
                        % No children method available
                    end
                end
            end

            % Process children
            for i = 1:length(child_ids)
                try
                    child_node = node.(child_ids{i});
                    [child_time, child_signals] = traverseSimlogNode(child_node, current_path, handles);

                    % Merge time (use first valid)
                    if isempty(time_data) && all(~isempty(child_time))
                        time_data = child_time;
                    end

                    % Merge signals
                    signals = [signals, child_signals];

                catch ME
                    % Skip this child if there's an error
                end
            end

        catch ME
            % No children method available - this is normal for leaf nodes
        end
    end

catch ME
    % Only show error if it's not a normal "no data" case
    if ~contains(ME.message, 'brace indexing') && ~contains(ME.message, 'comma separated list')
        fprintf('Error traversing Simscape node: %s\n', ME.message);
    end
end
end

function restoreWorkspace(initial_vars)
% Restore workspace to initial state by clearing new variables
current_vars = who;
new_vars = setdiff(current_vars, initial_vars);

if ~isempty(new_vars)
    clear(new_vars{:});
end
end

% Real Simulation Function - Replaces Mock
function result = runSingleTrial(trial_num, config, trial_coefficients, capture_workspace)
fprintf('[DEBUG] === RUN SINGLE TRIAL %d STARTED ===\n', trial_num);
fprintf('[DEBUG] Model path: %s\n', config.model_path);
fprintf('[DEBUG] Trial coefficients: [%s]\n', num2str(trial_coefficients));

result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);

try
    fprintf('[DEBUG] Creating Simulink.SimulationInput...\n');
    % Create simulation input
    simIn = Simulink.SimulationInput(config.model_path);
    fprintf('[DEBUG] SimulationInput created successfully\n');

    fprintf('[DEBUG] Setting model parameters...\n');
    % Set model parameters
    simIn = setModelParameters(simIn, config);
    fprintf('[DEBUG] Model parameters set successfully\n');

    fprintf('[DEBUG] Setting polynomial coefficients...\n');
    % Set polynomial coefficients for this trial
    try
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);
        fprintf('[DEBUG] Polynomial coefficients set successfully\n');
    catch ME
        fprintf('Warning: Could not set polynomial coefficients: %s\n', ME.message);
        fprintf('[DEBUG] Polynomial coefficients failed: %s\n', ME.message);
    end

    fprintf('[DEBUG] Suppressing warnings...\n');
    % Suppress specific warnings that are not critical
    warning_state = warning('off', 'Simulink:Bus:EditTimeBusPropNotAllowed');
    warning_state2 = warning('off', 'Simulink:Engine:BlockOutputNotUpdated');
    warning_state3 = warning('off', 'Simulink:Engine:OutputNotConnected');
    warning_state4 = warning('off', 'Simulink:Engine:InputNotConnected');
    warning_state5 = warning('off', 'Simulink:Blocks:UnconnectedOutputPort');
    warning_state6 = warning('off', 'Simulink:Blocks:UnconnectedInputPort');

    % Run simulation with progress indicator and visualization suppression
    fprintf('[DEBUG] Starting Simulink simulation...\n');
    fprintf('Running trial %d simulation...', trial_num);

    simOut = sim(simIn);
    fprintf(' Done.\n');
    fprintf('[DEBUG] Simulink simulation completed successfully\n');

    % Restore warning state
    warning(warning_state);
    warning(warning_state2);
    warning(warning_state3);
    warning(warning_state4);
    warning(warning_state5);
    warning(warning_state6);

    fprintf('[DEBUG] Processing simulation output...\n');
    % Process simulation output
    result = processSimulationOutput(trial_num, config, simOut, capture_workspace);
    fprintf('[DEBUG] Simulation output processed successfully\n');

catch ME
    fprintf('[DEBUG] ERROR in runSingleTrial: %s\n', ME.message);

    % Restore warning state in case of error
    if exist('warning_state', 'var')
        warning(warning_state);
    end
    if exist('warning_state2', 'var')
        warning(warning_state2);
    end
    if exist('warning_state3', 'var')
        warning(warning_state3);
    end
    if exist('warning_state4', 'var')
        warning(warning_state4);
    end
    if exist('warning_state5', 'var')
        warning(warning_state5);
    end
    if exist('warning_state6', 'var')
        warning(warning_state6);
    end

    fprintf(' Failed.\n');
    result.success = false;
    result.error = ME.message;
    fprintf('Trial %d simulation failed: %s\n', trial_num, ME.message);

    % Print stack trace for debugging
    fprintf('Error details:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('[DEBUG] === RUN SINGLE TRIAL %d COMPLETED ===\n', trial_num);
fprintf('[DEBUG] Result success: %s\n', mat2str(result.success));
end

function [data_table, signal_info] = extractSignalsFromSimOut(simOut, options)
% Extract signals from simulation output based on specified options
% This replaces the missing extractAllSignalsFromBus function

data_table = [];
signal_info = struct();

try
    % Validate simOut input to prevent brace indexing errors
    if isempty(simOut)
        if options.verbose
            fprintf('Warning: Empty simulation output provided\n');
        end
        return;
    end

    % Check if simOut is a valid simulation output object
    if ~isobject(simOut) && ~isstruct(simOut)
        if options.verbose
            fprintf('Warning: Invalid simulation output type: %s\n', class(simOut));
        end
        return;
    end

    % Initialize data collection
    all_data = {};

    % Extract from CombinedSignalBus if enabled and available
    if options.extract_combined_bus && (isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus'))
        if options.verbose
            fprintf('Extracting from CombinedSignalBus...\n');
        end

        try
            combinedBus = simOut.CombinedSignalBus;
            if ~isempty(combinedBus)
                signal_bus_data = extractFromCombinedSignalBus(combinedBus);

                if ~isempty(signal_bus_data)
                    all_data{end+1} = signal_bus_data;
                    if options.verbose
                        fprintf('CombinedSignalBus: %d columns extracted\n', width(signal_bus_data));
                    end
                end
            end
        catch ME
            if contains(ME.message, 'brace indexing') || contains(ME.message, 'comma separated list')
                if options.verbose
                    fprintf('Warning: Brace indexing error accessing CombinedSignalBus: %s\n', ME.message);
                end
            else
                if options.verbose
                    fprintf('Warning: Error extracting CombinedSignalBus: %s\n', ME.message);
                end
            end
        end
    end

    % Extract from logsout if enabled and available
    if options.extract_logsout && (isprop(simOut, 'logsout') || isfield(simOut, 'logsout'))
        if options.verbose
            fprintf('Extracting from logsout...\n');
        end

        try
            logsout_data = extractLogsoutDataFixed(simOut.logsout);
            if ~isempty(logsout_data)
                all_data{end+1} = logsout_data;
                if options.verbose
                    fprintf('Logsout: %d columns extracted\n', width(logsout_data));
                end
            end
        catch ME
            if contains(ME.message, 'brace indexing') || contains(ME.message, 'comma separated list')
                if options.verbose
                    fprintf('Warning: Brace indexing error accessing logsout: %s\n', ME.message);
                end
            else
                if options.verbose
                    fprintf('Warning: Error extracting logsout: %s\n', ME.message);
                end
            end
        end
    end

    % Extract from Simscape if enabled and available
    if options.extract_simscape
        if options.verbose
            fprintf('Checking for Simscape simlog...\n');
        end

        % Enhanced simlog access for parallel execution
        simlog_available = false;
        simlog_data = [];

        if isprop(simOut, 'simlog') || isfield(simOut, 'simlog')
            try
                simlog_data = simOut.simlog;
                if ~isempty(simlog_data)
                    simlog_available = true;
                    if options.verbose
                        fprintf('Found simlog (type: %s)\n', class(simlog_data));
                    end
                end
            catch ME
                if contains(ME.message, 'brace indexing') || contains(ME.message, 'comma separated list')
                    if options.verbose
                        fprintf('Warning: Brace indexing error accessing simlog: %s\n', ME.message);
                    end
                else
                    if options.verbose
                        fprintf('Warning: Could not access simlog: %s\n', ME.message);
                    end
                end
            end
        end

        % Try alternative access methods for parallel workers
        if ~simlog_available
            try
                if isprop(simOut, 'SimulationMetadata') && isfield(simOut.SimulationMetadata, 'SimscapeLoggingInfo')
                    if options.verbose
                        fprintf('Attempting alternative simlog access...\n');
                    end
                end
            catch
                % Continue
            end
        end

        if simlog_available
            if options.verbose
                fprintf('Extracting from Simscape simlog...\n');
            end

            simscape_data = extractSimscapeDataRecursive(simlog_data);
            if ~isempty(simscape_data)
                all_data{end+1} = simscape_data;
                if options.verbose
                    fprintf('Simscape: %d columns extracted\n', width(simscape_data));
                end
            else
                if options.verbose
                    fprintf('Warning: No Simscape data extracted despite simlog being available\n');
                end
            end
        else
            if options.verbose
                fprintf('Warning: No simlog found in simulation output\n');
            end
        end
    end

    % Combine all data sources
    if ~isempty(all_data)
        data_table = combineDataSources(all_data);
        signal_info.sources_found = length(all_data);
        signal_info.total_columns = width(data_table);
    else
        if options.verbose
            fprintf('Warning: No data extracted from any source\n');
        end
    end

catch ME
    if options.verbose
        fprintf('Error in extractSignalsFromSimOut: %s\n', ME.message);
    end
    % Return empty results on error
    data_table = [];
    signal_info = struct();
end
end

function data_table = addModelWorkspaceData(data_table, simOut, num_rows)
% Extract model workspace variables and add as constant columns
% These include segment lengths, masses, inertias, and other model parameters

try
    % Get model workspace from simulation output
    model_name = simOut.SimulationMetadata.ModelInfo.ModelName;

    % Check if model is loaded
    if ~bdIsLoaded(model_name)
        fprintf('Warning: Model %s not loaded, skipping workspace data\n', model_name);
        return;
    end

    model_workspace = get_param(model_name, 'ModelWorkspace');
    try
        variables = model_workspace.getVariableNames;
    catch
        % For older MATLAB versions, try alternative method
        try
            variables = model_workspace.whos;
            variables = {variables.name};
        catch
            fprintf('Warning: Could not retrieve model workspace variable names\n');
            return;
        end
    end

    if length(variables) > 0
        fprintf('Adding %d model workspace variables to CSV...\n', length(variables));
    else
        fprintf('No model workspace variables found\n');
        return;
    end

    for i = 1:length(variables)
        var_name = variables{i};

        try
            var_value = model_workspace.getVariable(var_name);

            % Handle different variable types
            if isnumeric(var_value) && isscalar(var_value)
                % Scalar numeric values (lengths, masses, etc.)
                column_name = sprintf('model_%s', var_name);
                data_table.(column_name) = repmat(var_value, num_rows, 1);

            elseif isnumeric(var_value) && isvector(var_value)
                % Vector values (3D coordinates, etc.)
                for j = 1:length(var_value)
                    column_name = sprintf('model_%s_%d', var_name, j);
                    data_table.(column_name) = repmat(var_value(j), num_rows, 1);
                end

            elseif isnumeric(var_value) && ismatrix(var_value)
                % Matrix values (inertia matrices, etc.)
                [rows, cols] = size(var_value);
                for r = 1:rows
                    for c = 1:cols
                        column_name = sprintf('model_%s_%d_%d', var_name, r, c);
                        data_table.(column_name) = repmat(var_value(r,c), num_rows, 1);
                    end
                end

            elseif isa(var_value, 'Simulink.Parameter')
                % Handle Simulink Parameters
                param_val = var_value.Value;
                if isnumeric(param_val) && isscalar(param_val)
                    column_name = sprintf('model_%s', var_name);
                    data_table.(column_name) = repmat(param_val, num_rows, 1);
                end
            end

        catch ME
            % Skip variables that can't be extracted
            fprintf('Warning: Could not extract variable %s: %s\n', var_name, ME.message);
        end
    end

catch ME
    fprintf('Warning: Could not access model workspace: %s\n', ME.message);
end
end

% Validate inputs
function config = validateInputs(handles)
try
    num_trials = str2double(get(handles.num_trials_edit, 'String'));
    sim_time = str2double(get(handles.sim_time_edit, 'String'));
    sample_rate = str2double(get(handles.sample_rate_edit, 'String'));

    if isnan(num_trials) || num_trials <= 0 || num_trials > 10000
        error('Number of trials must be between 1 and 10,000');
    end
    if isnan(sim_time) || sim_time <= 0 || sim_time > 60
        error('Simulation time must be between 0.001 and 60 seconds');
    end
    if isnan(sample_rate) || sample_rate <= 0 || sample_rate > 10000
        error('Sample rate must be between 1 and 10,000 Hz');
    end

    scenario_idx = get(handles.torque_scenario_popup, 'Value');
    coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
    constant_value = 10.0; % Default constant value

    if scenario_idx == 1 && (isnan(coeff_range) || coeff_range <= 0)
        error('Coefficient range must be positive for variable torques');
    end

    % Additional validation: check coefficient table bounds
    if scenario_idx == 1
        validateCoefficientBounds(handles, coeff_range);
    end
    if scenario_idx == 3 && isnan(constant_value)
        error('Constant value must be numeric for constant torque');
    end

    if ~get(handles.use_signal_bus, 'Value') && ...
            ~get(handles.use_logsout, 'Value') && ...
            ~get(handles.use_simscape, 'Value')
        error('Please select at least one data source');
    end

    output_folder = get(handles.output_folder_edit, 'String');
    folder_name = get(handles.folder_name_edit, 'String');

    if isempty(output_folder) || isempty(folder_name)
        error('Please specify output folder and dataset name');
    end

    % Validate model exists
    model_name = handles.model_name;
    model_path = handles.model_path;

    if isempty(model_path)
        % Try to find model in current directory or path
        if exist([model_name '.slx'], 'file')
            model_path = which([model_name '.slx']);
        elseif exist([model_name '.mdl'], 'file')
            model_path = which([model_name '.mdl']);
        else
            error('Simulink model "%s" not found. Please select a valid model.', model_name);
        end
    end

    % Validate input file if specified
    input_file = handles.selected_input_file;
    if ~isempty(input_file) && ~exist(input_file, 'file')
        error('Input file "%s" not found', input_file);
    end

    % Grok's Simscape validation: Check if Simscape is enabled but model lacks Simscape blocks
    if get(handles.use_simscape, 'Value')
        % Check Simscape license
        if ~license('test', 'Simscape')
            warning('Simscape license not available. Disabling Simscape data extraction.');
            set(handles.use_simscape, 'Value', 0);
        else
            % Check if model has Simscape blocks
            try
                if ~bdIsLoaded(model_name)
                    load_system(model_path);
                    model_was_loaded = true;
                else
                    model_was_loaded = false;
                end

                % Look for Simscape blocks including those in referenced subsystems
                simscape_blocks = [];

                % Method 1: Direct Simscape blocks in main model
                try
                    simscape_blocks = find_system(model_name, 'SimulinkSubDomain', 'Simscape');
                catch
                    % SimulinkSubDomain might not work in all MATLAB versions
                end

                % Method 2: Look for Simscape Multibody specific blocks
                if isempty(simscape_blocks)
                    try
                        % Look for common Simscape Multibody blocks
                        multibody_blocks = [
                            find_system(model_name, 'BlockType', 'SubSystem', 'ReferenceBlock', 'sm_lib/Bodies/Solid');
                            find_system(model_name, 'BlockType', 'SubSystem', 'ReferenceBlock', 'sm_lib/Joints/Revolute Joint');
                            find_system(model_name, 'BlockType', 'SubSystem', 'ReferenceBlock', 'sm_lib/Joints/Prismatic Joint');
                            find_system(model_name, 'BlockType', 'SubSystem', 'ReferenceBlock', 'sm_lib/Joints/Spherical Joint');
                            find_system(model_name, 'MaskType', 'Solid');
                            find_system(model_name, 'MaskType', 'Revolute Joint');
                            find_system(model_name, 'MaskType', 'Prismatic Joint')
                            ];
                        simscape_blocks = [simscape_blocks; multibody_blocks];
                    catch
                        % Ignore errors in Multibody block search
                    end
                end

                % Method 3: Look for Subsystem Reference blocks (your case!)
                subsystem_refs = [];
                try
                    subsystem_refs = find_system(model_name, 'BlockType', 'SubsystemReference');
                    if ~isempty(subsystem_refs)
                        fprintf('Debug: Found %d Subsystem Reference blocks (may contain Simscape components)\n', length(subsystem_refs));
                        simscape_blocks = [simscape_blocks; subsystem_refs];
                    end
                catch
                    % Ignore subsystem reference search errors
                end

                % Method 4: Look for any blocks that suggest Simscape presence
                if isempty(simscape_blocks)
                    try
                        % Look for Simscape solver configuration blocks
                        solver_blocks = find_system(model_name, 'BlockType', 'SimscapeSolver');
                        simscape_blocks = [simscape_blocks; solver_blocks];
                    catch
                        % Ignore solver block search errors
                    end
                end

                % Method 5: Check model configuration for Simscape settings
                has_simscape_config = false;
                try
                    solver_type = get_param(model_name, 'SolverType');
                    if contains(lower(solver_type), 'variable') || contains(lower(solver_type), 'fixed')
                        has_simscape_config = true;

                    end
                catch
                    % Ignore configuration check errors
                end

                % Final validation
                total_indicators = length(simscape_blocks);
                if has_simscape_config
                    total_indicators = total_indicators + 1;
                end

                if total_indicators == 0
                    if model_was_loaded
                        close_system(model_name, 0);
                    end
                    warning('Simscape data extraction is enabled, but no clear Simscape indicators found in model "%s". Simscape logging may still work if components are in referenced subsystems.', model_name);
                else
                    if shouldShowDebug(handles)
                        fprintf('Debug: Found %d Simscape indicators in model (blocks + references + config)\n', total_indicators);
                    end
                    if ~isempty(subsystem_refs)
                        if shouldShowDebug(handles)
                            fprintf('Debug: Model uses referenced subsystems - Simscape components may be inside references\n');
                        end
                    end
                end

                if model_was_loaded
                    close_system(model_name, 0);
                end

            catch ME
                if exist('model_was_loaded', 'var') && model_was_loaded
                    try
                        close_system(model_name, 0);
                    catch
                        % Ignore close errors
                    end
                end
                warning(ME.identifier, '%s', sprintf('Simscape validation failed: %s. Continuing without Simscape validation.', ME.message));
            end
        end
    end

    % Create config structure
    config = struct();
    config.model_name = model_name;
    config.model_path = model_path;
    config.input_file = input_file;
    config.num_simulations = num_trials;
    config.simulation_time = sim_time;
    config.sample_rate = sample_rate;
    config.modeling_mode = 3;
    config.torque_scenario = scenario_idx;
    config.coeff_range = coeff_range;
    config.constant_value = constant_value;
    config.use_logsout = get(handles.use_logsout, 'Value');
    config.use_signal_bus = get(handles.use_signal_bus, 'Value');
    config.use_simscape = get(handles.use_simscape, 'Value');
    config.enable_animation = get(handles.enable_animation, 'Value');
    config.capture_workspace = logical(get(handles.capture_workspace_checkbox, 'Value'));
    config.output_folder = fullfile(output_folder, folder_name);
    config.file_format = get(handles.format_popup, 'Value');

    % Batch settings validation and configuration
    batch_size = str2double(get(handles.batch_size_edit, 'String'));
    save_interval = str2double(get(handles.save_interval_edit, 'String'));

    if isnan(batch_size) || batch_size <= 0 || batch_size > 1000
        error('Batch size must be between 1 and 1,000');
    end
    if isnan(save_interval) || save_interval <= 0 || save_interval > 1000
        error('Save interval must be between 1 and 1,000');
    end

    % Get verbosity level
    verbosity_options = {'Normal', 'Silent', 'Verbose', 'Debug'};
    verbosity_idx = get(handles.verbosity_popup, 'Value');
    verbosity_level = verbosity_options{verbosity_idx};

    % Add batch settings to config
    config.batch_size = batch_size;
    config.save_interval = save_interval;
    config.enable_performance_monitoring = get(handles.enable_performance_monitoring, 'Value');
    config.verbosity = verbosity_level;
    config.enable_memory_monitoring = get(handles.enable_memory_monitoring, 'Value');
    config.enable_master_dataset = get(handles.enable_master_dataset, 'Value');

catch ME
    errordlg(ME.message, 'Input Validation Error');
    config = [];
end
end

function backupScripts(handles)
% Create backup of current scripts before generation
try
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    backup_dir = fullfile(pwd, 'Backup_Scripts', sprintf('Run_Backup_%s', timestamp));

    if ~exist(backup_dir, 'dir')
        mkdir(backup_dir);
    end

    % Get the directory where this script is located
    [script_dir, ~, ~] = fileparts(mfilename('fullpath'));

    % List of scripts to backup (all .m files in the Simulation_Dataset_GUI folder)
    script_files = dir(fullfile(script_dir, '*.m'));

    % Copy each script to backup folder
    copied_count = 0;
    for i = 1:length(script_files)
        script_path = fullfile(script_dir, script_files(i).name);
        if exist(script_path, 'file')
            backup_path = fullfile(backup_dir, script_files(i).name);
            copyfile(script_path, backup_path);
            copied_count = copied_count + 1;
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
        timestamp, copied_count, backup_dir);

    readme_path = fullfile(backup_dir, 'README_BACKUP.txt');
    fid = fopen(readme_path, 'w');
    if fid ~= -1
        fprintf(fid, '%s', readme_content);
        fclose(fid);
    end

    fprintf('Script backup created: %s (%d files)\n', backup_dir, copied_count);

catch ME
    warning('Failed to create script backup: %s', ME.message);
end
end

% ENHANCED: Extract from Simscape with detailed diagnostics
function simscape_data = extractSimscapeDataRecursive(simlog)
simscape_data = table();  % Empty table if no data

try
    % DETAILED DIAGNOSTICS
    fprintf('=== SIMSCAPE DIAGNOSTIC START ===\n');

    if isempty(simlog)
        fprintf('❌ simlog is EMPTY\n');
        fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');
        return;
    end

    fprintf('✅ simlog exists, class: %s\n', class(simlog));

    if ~isa(simlog, 'simscape.logging.Node')
        fprintf('❌ simlog is not a simscape.logging.Node\n');
        fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');
        return;
    end

    fprintf('✅ simlog is valid simscape.logging.Node\n');

    % Try to inspect the simlog structure
    try
        fprintf(' Inspecting simlog properties...\n');
        props = properties(simlog);
        fprintf('   Properties: %s\n', strjoin(props, ', '));
    catch
        fprintf('❌ Could not get simlog properties\n');
    end

    % Try to get children (properties ARE the children in Multibody)
    try
        children_ids = simlog.children();
        fprintf('✅ Found %d top-level children: %s\n', length(children_ids), strjoin(children_ids, ', '));
    catch ME
        fprintf('❌ Could not get children method: %s\n', ME.message);
        fprintf(' Using properties as children (Multibody approach)\n');

        % Get properties excluding system properties
        all_props = properties(simlog);
        children_ids = {};
        for i = 1:length(all_props)
            prop_name = all_props{i};
            % Skip system properties, keep actual joint/body names
            if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                children_ids{end+1} = prop_name;
            end
        end
        fprintf('✅ Found %d children from properties: %s\n', length(children_ids), strjoin(children_ids, ', '));
    end

    % Try to inspect first child
    if ~isempty(children_ids)
        try
            first_child_id = children_ids{1};
            first_child = simlog.(first_child_id);
            fprintf(' First child (%s) class: %s\n', first_child_id, class(first_child));

            % Try to get series from first child
            try
                series_children = first_child.series.children();
                fprintf('✅ First child has %d series: %s\n', length(series_children), strjoin(series_children, ', '));
            catch ME2
                fprintf('❌ First child series access failed: %s\n', ME2.message);
            end

        catch ME
            fprintf('❌ Could not inspect first child: %s\n', ME.message);
        end
    end

    fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');

    % Recursively collect all series data using primary traversal method
    [time_data, all_signals] = traverseSimlogNode(simlog, '', []);

    if isempty(time_data) || isempty(all_signals)
        fprintf('⚠️  Primary method found no data. Trying fallback methods...\n');

        % FALLBACK METHOD: Simple property inspection
        [time_data, all_signals] = fallbackSimlogExtraction(simlog);

        if isempty(time_data) || isempty(all_signals)
            fprintf('❌ All extraction methods failed. No usable Simscape data found.\n');
            return;
        else
            fprintf('✅ Fallback method found data!\n');
        end
    else
        fprintf('✅ Primary traversal method found data!\n');
    end

    % Build table
    data_cells = {time_data};
    var_names = {'time'};
    expected_length = length(time_data);

    for i = 1:length(all_signals)
        signal = all_signals{i};
        if length(signal.data) == expected_length
            data_cells{end+1} = signal.data(:);
            var_names{end+1} = signal.name;
            fprintf('Debug: Added Simscape signal: %s (length: %d)\n', signal.name, expected_length);
        else
            fprintf('Debug: Skipped %s (length mismatch: %d vs %d)\n', signal.name, length(signal.data), expected_length);
        end
    end

    if length(data_cells) > 1
        simscape_data = table(data_cells{:}, 'VariableNames', var_names);
        fprintf('Debug: Created Simscape table with %d columns, %d rows.\n', width(simscape_data), height(simscape_data));
    else
        fprintf('Debug: Only time data found in Simscape log.\n');
    end

catch ME
    fprintf('Error extracting Simscape data recursively: %s\n', ME.message);
end
end

% FALLBACK SIMSCAPE EXTRACTION - Simple property inspection method
function [time_data, all_signals] = fallbackSimlogExtraction(simlog)
time_data = [];
all_signals = {};

try
    % Method 1: Try direct property enumeration
    try
        props = properties(simlog);

        for i = 1:length(props)
            prop_name = props{i};
            if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                try
                    prop_value = simlog.(prop_name);
                    if isa(prop_value, 'simscape.logging.Node')
                        % Recursively extract from child nodes
                        [child_time, child_signals] = fallbackSimlogExtraction(prop_value);
                        if isempty(time_data) && ~isempty(child_time)
                            time_data = child_time;
                        end
                        all_signals = [all_signals, child_signals];
                    elseif isstruct(prop_value) || isa(prop_value, 'timeseries')
                        % Try to extract time series data
                        [extracted_time, extracted_data] = extractTimeSeriesData(prop_value, prop_name);
                        if ~isempty(extracted_time) && ~isempty(extracted_data)
                            if isempty(time_data)
                                time_data = extracted_time;
                            end
                            signal_name = matlab.lang.makeValidName(prop_name);
                            all_signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                            fprintf('Debug: Fallback found data in %s\n', prop_name);
                        end
                    elseif isstruct(prop_value)
                        % Try to extract constant matrix/vector data from struct
                        [constant_signals] = extractConstantMatrixData(prop_value, prop_name, []);
                        if ~isempty(constant_signals)
                            all_signals = [all_signals, constant_signals];
                            fprintf('Debug: Fallback found constant data in struct %s\n', prop_name);
                        end
                    elseif isnumeric(prop_value)
                        % Handle numeric arrays directly (constant matrices/vectors)
                        [constant_signals] = extractConstantMatrixData(prop_value, prop_name, []);
                        if ~isempty(constant_signals)
                            all_signals = [all_signals, constant_signals];
                            fprintf('Debug: Fallback found numeric data in %s\n', prop_name);
                        end
                    end
                catch
                    continue;
                end
            end
        end
    catch ME
        fprintf('Debug: Property enumeration failed: %s\n', ME.message);
    end

    % Method 2: Try common Simscape Multibody patterns
    if isempty(time_data) || isempty(all_signals)
        try
            % Look for common joint/body properties
            common_props = {'Px', 'Py', 'Pz', 'Vx', 'Vy', 'Vz', 'q', 'w', 'f', 't'};
            for i = 1:length(common_props)
                prop = common_props{i};
                if isprop(simlog, prop) || isfield(simlog, prop)
                    try
                        prop_data = simlog.(prop);
                        if isstruct(prop_data) && isfield(prop_data, 'series')
                            series_data = prop_data.series;
                            if isstruct(series_data) && isfield(series_data, 'time') && isfield(series_data, 'values')
                                if isempty(time_data)
                                    time_data = series_data.time;
                                end
                                signal_name = matlab.lang.makeValidName(['fallback_' prop]);
                                all_signals{end+1} = struct('name', signal_name, 'data', series_data.values);
                                fprintf('Debug: Fallback found %s data\n', prop);
                            end
                        end
                    catch
                        continue;
                    end
                end
            end
        catch ME
            fprintf('Debug: Common property search failed: %s\n', ME.message);
        end
    end

catch ME
    fprintf('Debug: Fallback extraction failed: %s\n', ME.message);
end

if ~isempty(time_data) && ~isempty(all_signals)
    fprintf('Debug: Fallback extraction successful - found %d signals\n', length(all_signals));
else
    fprintf('Debug: Fallback extraction found no data\n');
end
end

% Compile dataset
function compileDataset(config)
try
    fprintf('Compiling dataset from trials...\n');

    % Find all trial CSV files
    csv_files = dir(fullfile(config.output_folder, 'trial_*.csv'));

    if isempty(csv_files)
        warning('No trial CSV files found in output folder');
        return;
    end

    % OPTIMIZED THREE-PASS ALGORITHM with proper preallocation
    fprintf('Using optimized 3-pass algorithm with preallocation...\n');

    % PASS 1: Discover all unique column names across all files
    fprintf('Pass 1: Discovering columns...\n');

    % Preallocate with estimated size (most trials have similar column counts)
    estimated_columns = 2000;  % Updated to handle typical 1956 columns with buffer
    all_unique_columns = cell(estimated_columns, 1);
    valid_files = cell(length(csv_files), 1);
    column_count = 0;
    valid_file_count = 0;

    for i = 1:length(csv_files)
        file_path = fullfile(config.output_folder, csv_files(i).name);
        try
            trial_data = readtable(file_path);
            if ~isempty(trial_data)
                valid_file_count = valid_file_count + 1;
                valid_files{valid_file_count} = file_path;

                trial_columns = trial_data.Properties.VariableNames;

                % Add new columns efficiently
                for j = 1:length(trial_columns)
                    col_name = trial_columns{j};
                    if ~ismember(col_name, all_unique_columns(1:column_count))
                        column_count = column_count + 1;
                        if column_count > length(all_unique_columns)
                            % Expand array if needed (rare case)
                            all_unique_columns = [all_unique_columns; cell(estimated_columns, 1)];
                        end
                        all_unique_columns{column_count} = col_name;
                    end
                end

                fprintf('  Pass 1 - %s: %d columns found\n', csv_files(i).name, length(trial_columns));
            end
        catch ME
            warning('Failed to read %s during discovery: %s', csv_files(i).name, ME.message);
        end
    end

    % Trim arrays to actual size
    all_unique_columns = all_unique_columns(1:column_count);
    valid_files = valid_files(1:valid_file_count);

    fprintf('  Total unique columns discovered: %d\n', length(all_unique_columns));
    fprintf('  Valid files found: %d\n', valid_file_count);

    % PASS 2: Standardize each trial to have all columns (with NaN for missing)
    fprintf('Pass 2: Standardizing trials...\n');

    % Preallocate standardized tables array
    standardized_tables = cell(valid_file_count, 1);

    for i = 1:valid_file_count
        file_path = valid_files{i};
        [~, filename, ~] = fileparts(file_path);

        try
            trial_data = readtable(file_path);

            % Preallocate standardized data table with known size
            num_rows = height(trial_data);
            standardized_data = table();

            % Preallocate all columns at once for efficiency
            for col = 1:length(all_unique_columns)
                col_name = all_unique_columns{col};
                if ismember(col_name, trial_data.Properties.VariableNames)
                    standardized_data.(col_name) = trial_data.(col_name);
                else
                    % Fill missing column with NaN - preallocate entire column
                    standardized_data.(col_name) = NaN(num_rows, 1);
                end
            end

            standardized_tables{i} = standardized_data;
            fprintf('  Pass 2 - %s: standardized to %d columns\n', filename, width(standardized_data));

        catch ME
            warning('Failed to standardize %s: %s', filename, ME.message);
            standardized_tables{i} = [];  % Mark as failed
        end
    end

    % PASS 3: Concatenate all standardized tables efficiently
    fprintf('Pass 3: Concatenating data...\n');

    % Remove failed trials
    valid_tables = standardized_tables(~cellfun(@isempty, standardized_tables));

    if isempty(valid_tables)
        warning('No valid tables to concatenate');
        return;
    end

    % Preallocate master data with known dimensions
    total_rows = sum(cellfun(@(t) height(t), valid_tables));
    num_cols = length(all_unique_columns);

    fprintf('  Preallocating master data: %d rows × %d columns\n', total_rows, num_cols);

    % Create master table with preallocated size
    master_data = table();
    for col = 1:num_cols
        col_name = all_unique_columns{col};
        % Preallocate entire column with NaN
        master_data.(col_name) = NaN(total_rows, 1);
    end

    % Fill data efficiently
    current_row = 1;
    for i = 1:length(valid_tables)
        table_data = valid_tables{i};
        if ~isempty(table_data)
            num_rows = height(table_data);
            row_indices = current_row:(current_row + num_rows - 1);

            % Copy data for each column
            for col = 1:num_cols
                col_name = all_unique_columns{col};
                if ismember(col_name, table_data.Properties.VariableNames)
                    master_data.(col_name)(row_indices) = table_data.(col_name);
                end
            end

            current_row = current_row + num_rows;
        end
    end

    fprintf('✅ Optimized 3-pass compilation complete - preserved ALL %d columns!\n', width(master_data));

    if ~isempty(master_data)
        % Save master dataset
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        master_filename = sprintf('master_dataset_%s.csv', timestamp);
        master_path = fullfile(config.output_folder, master_filename);

        writetable(master_data, master_path);
        fprintf('Master dataset saved: %s\n', master_filename);
        fprintf('  Total rows: %d\n', height(master_data));
        fprintf('  Total columns: %d\n', width(master_data));

        % Also save as MAT file if requested
        if config.file_format == 2 || config.file_format == 3
            mat_filename = sprintf('master_dataset_%s.mat', timestamp);
            mat_path = fullfile(config.output_folder, mat_filename);
            save(mat_path, 'master_data', 'config');
            fprintf('Master dataset saved as MAT: %s\n', mat_filename);
        end
    end

catch ME
    fprintf('Error compiling dataset: %s\n', ME.message);
end
end

function validateCoefficientBounds(handles, coeff_range)
% Validate that coefficient table values are within specified bounds
try
    coeff_data = get(handles.coefficients_table, 'Data');
    if isempty(coeff_data)
        return;
    end

    % Check each coefficient value
    out_of_bounds_count = 0;
    for i = 1:size(coeff_data, 1)
        for j = 1:size(coeff_data, 2)
            cell_value = coeff_data{i, j};
            if ischar(cell_value) || isstring(cell_value)
                numeric_value = str2double(cell_value);
                if ~isnan(numeric_value)
                    if abs(numeric_value) > coeff_range
                        out_of_bounds_count = out_of_bounds_count + 1;
                    end
                end
            end
        end
    end

    if out_of_bounds_count > 0
        warning('Found %d coefficient values outside the specified range [±%.2f]. Consider regenerating coefficients.', ...
            out_of_bounds_count, coeff_range);
    end

catch ME
    fprintf('Warning: Could not validate coefficient bounds: %s\n', ME.message);
end
end

% Helper function to check if debug output should be shown
function should_show_debug = shouldShowDebug(handles)
if ~isfield(handles, 'verbosity_popup')
    should_show_debug = true; % Default to showing if no verbosity control
    return;
end

verbosity_options = {'Normal', 'Silent', 'Verbose', 'Debug'};
verbosity_idx = get(handles.verbosity_popup, 'Value');
if verbosity_idx <= length(verbosity_options)
    verbosity_level = verbosity_options{verbosity_idx};
else
    verbosity_level = 'Normal';
end

% Only show debug output for Debug verbosity level
should_show_debug = strcmp(verbosity_level, 'Debug');
end

function resetGUIState(handles)
% Reset GUI state for next run
try
    % Reset running state
    handles.is_running = false;
    handles.is_paused = false;
    handles.should_stop = false;

    % Reset button states
    set(handles.play_pause_button, 'Enable', 'on', 'String', 'Start');
    set(handles.stop_button, 'Enable', 'off');

    % Clear checkpoint data
    handles.checkpoint_data = struct();

    % Update status
    set(handles.status_text, 'String', 'Status: Ready');
    set(handles.progress_text, 'String', 'Ready to start');

    % Store updated handles
    guidata(handles.fig, handles);

catch ME
    fprintf('Warning: Could not reset GUI state: %s\n', ME.message);
end
end

% Save script and settings for reproducibility
function saveScriptAndSettings(config)
try
    % Create timestamped filename
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    script_filename = sprintf('Data_GUI_run_%s.m', timestamp);
    script_path = fullfile(config.output_folder, script_filename);

    % Get the current script content
    current_script_path = mfilename('fullpath');
    current_script_path = [current_script_path '.m']; % Add .m extension

    if ~exist(current_script_path, 'file')
        fprintf('Warning: Could not find current script file: %s\n', current_script_path);
        return;
    end

    % Read current script content
    fid_in = fopen(current_script_path, 'r');
    if fid_in == -1
        fprintf('Warning: Could not open current script file for reading\n');
        return;
    end

    script_content = fread(fid_in, '*char')';
    fclose(fid_in);

    % Create output file with settings header
    fid_out = fopen(script_path, 'w');
    if fid_out == -1
        fprintf('Warning: Could not create script copy file: %s\n', script_path);
        return;
    end

    % Write settings header
    fprintf(fid_out, '%% GOLF SWING DATA GENERATION RUN RECORD\n');
    fprintf(fid_out, '%% Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid_out, '%% This file contains the exact script and settings used for this data generation run\n');
    fprintf(fid_out, '%%\n');
    fprintf(fid_out, '%% =================================================================\n');
    fprintf(fid_out, '%% RUN CONFIGURATION SETTINGS\n');
    fprintf(fid_out, '%% =================================================================\n');
    fprintf(fid_out, '%%\n');

    % Write all configuration settings
    fprintf(fid_out, '%% SIMULATION PARAMETERS:\n');
    fprintf(fid_out, '%% Number of trials: %d\n', config.num_simulations);
    if isfield(config, 'simulation_time')
        fprintf(fid_out, '%% Simulation time: %.3f seconds\n', config.simulation_time);
    end
    if isfield(config, 'sample_rate')
        fprintf(fid_out, '%% Sample rate: %.1f Hz\n', config.sample_rate);
    end
    fprintf(fid_out, '%%\n');

    % Torque scenario
    fprintf(fid_out, '%% TORQUE CONFIGURATION:\n');
    if isfield(config, 'torque_scenario')
        scenarios = {'Variable Torque', 'Zero Torque', 'Constant Torque'};
        if config.torque_scenario >= 1 && config.torque_scenario <= length(scenarios)
            fprintf(fid_out, '%% Torque scenario: %s\n', scenarios{config.torque_scenario});
        end
    end
    if isfield(config, 'coeff_range')
        fprintf(fid_out, '%% Coefficient range: %.3f\n', config.coeff_range);
    end
    if isfield(config, 'constant_torque_value')
        fprintf(fid_out, '%% Constant torque value: %.3f\n', config.constant_torque_value);
    end
    fprintf(fid_out, '%%\n');

    % Model information
    fprintf(fid_out, '%% MODEL INFORMATION:\n');
    if isfield(config, 'model_name')
        fprintf(fid_out, '%% Model name: %s\n', config.model_name);
    end
    if isfield(config, 'model_path')
        fprintf(fid_out, '%% Model path: %s\n', config.model_path);
    end
    fprintf(fid_out, '%%\n');

    % Data sources
    fprintf(fid_out, '%% DATA SOURCES ENABLED:\n');
    if isfield(config, 'use_signal_bus')
        fprintf(fid_out, '%% CombinedSignalBus: %s\n', logical2str(config.use_signal_bus));
    end
    if isfield(config, 'use_logsout')
        fprintf(fid_out, '%% Logsout Dataset: %s\n', logical2str(config.use_logsout));
    end
    if isfield(config, 'use_simscape')
        fprintf(fid_out, '%% Simscape Results: %s\n', logical2str(config.use_simscape));
    end
    fprintf(fid_out, '%%\n');

    % Output settings
    fprintf(fid_out, '%% OUTPUT SETTINGS:\n');
    if isfield(config, 'output_folder')
        fprintf(fid_out, '%% Output folder: %s\n', config.output_folder);
    end
    if isfield(config, 'dataset_name')
        fprintf(fid_out, '%% Dataset name: %s\n', config.dataset_name);
    end
    if isfield(config, 'file_format')
        formats = {'CSV Files', 'MAT Files', 'Both CSV and MAT'};
        if config.file_format >= 1 && config.file_format <= length(formats)
            fprintf(fid_out, '%% File format: %s\n', formats{config.file_format});
        end
    end
    fprintf(fid_out, '%%\n');

    % System information
    fprintf(fid_out, '%% SYSTEM INFORMATION:\n');
    fprintf(fid_out, '%% MATLAB version: %s\n', version);
    fprintf(fid_out, '%% Computer: %s\n', computer);
    try
        try
            [status, hostname] = system('hostname');
            if status ~= 0
                hostname = 'Unknown';
            end
        catch
            hostname = 'Unknown';
        end
        fprintf(fid_out, '%% Hostname: %s', hostname); % hostname already includes newline
    catch
        fprintf(fid_out, '%% Hostname: Unknown\n');
    end
    fprintf(fid_out, '%%\n');

    % Coefficient information if available
    if isfield(config, 'coefficient_values') && ~isempty(config.coefficient_values)
        fprintf(fid_out, '%% POLYNOMIAL COEFFICIENTS:\n');
        fprintf(fid_out, '%% Coefficient matrix size: %d trials x %d coefficients\n', ...
            size(config.coefficient_values, 1), size(config.coefficient_values, 2));

        % Show first few coefficients as example
        if size(config.coefficient_values, 1) > 0
            fprintf(fid_out, '%% First trial coefficients (first 10): ');
            coeffs_to_show = min(10, size(config.coefficient_values, 2));
            for i = 1:coeffs_to_show
                fprintf(fid_out, '%.3f', config.coefficient_values(1, i));
                if i < coeffs_to_show
                    fprintf(fid_out, ', ');
                end
            end
            fprintf(fid_out, '\n');
        end
        fprintf(fid_out, '%%\n');
    end

    fprintf(fid_out, '%% =================================================================\n');
    fprintf(fid_out, '%% END OF CONFIGURATION - ORIGINAL SCRIPT FOLLOWS\n');
    fprintf(fid_out, '%% =================================================================\n');
    fprintf(fid_out, '\n');

    % Write the original script content
    fprintf(fid_out, '%s', script_content);

    fclose(fid_out);

    fprintf('Script and settings saved to: %s\n', script_path);

catch ME
    fprintf('Error saving script and settings: %s\n', ME.message);
end
end

function updatePreviewTable(~, ~)
% Update the preview table based on current checkbox selections
handles = guidata(gcbf);

try
    % Get current checkbox states
    calculate_work = get(handles.calculate_work_checkbox, 'Value');
    calculate_power = get(handles.calculate_power_checkbox, 'Value');
    calculate_joint_torque_impulse = get(handles.calculate_joint_torque_impulse_checkbox, 'Value');
    calculate_applied_torque_impulse = get(handles.calculate_applied_torque_impulse_checkbox, 'Value');
    calculate_total_angular_impulse = get(handles.calculate_total_angular_impulse_checkbox, 'Value');
    calculate_linear_impulse = get(handles.calculate_linear_impulse_checkbox, 'Value');
    calculate_proximal_on_distal = get(handles.calculate_proximal_on_distal_checkbox, 'Value');
    calculate_distal_on_proximal = get(handles.calculate_distal_on_proximal_checkbox, 'Value');

    % Create updated preview data
    preview_data = {};

    % Define joint names and their ends
    joints = {'Shoulder', 'Elbow', 'Wrist', 'Scapula', 'Spine', 'Torso', 'Hip'};
    ends = {'Proximal', 'Distal', 'Total'};

    % Work and Power signals
    if calculate_work
        preview_data{end+1, 1} = 'Work';
        preview_data{end, 2} = 'All';
        preview_data{end, 3} = 'N/A';
        preview_data{end, 4} = 'Integral of power over time';
    end

    if calculate_power
        preview_data{end+1, 1} = 'Power';
        preview_data{end, 2} = 'All';
        preview_data{end, 3} = 'N/A';
        preview_data{end, 4} = 'Torque × angular velocity';
    end

    % Angular Impulse signals
    if calculate_joint_torque_impulse || calculate_applied_torque_impulse || calculate_total_angular_impulse
        for i = 1:length(joints)
            joint = joints{i};
            for j = 1:length(ends)
                end_name = ends{j};
                preview_data{end+1, 1} = 'Angular Impulse';
                preview_data{end, 2} = joint;
                preview_data{end, 3} = end_name;
                preview_data{end, 4} = sprintf('Angular impulse at %s %s end', joint, lower(end_name));
            end
        end
    end

    % Linear Impulse signals
    if calculate_linear_impulse
        for i = 1:length(joints)
            joint = joints{i};
            for j = 1:length(ends)
                end_name = ends{j};
                preview_data{end+1, 1} = 'Linear Impulse';
                preview_data{end, 2} = joint;
                preview_data{end, 3} = end_name;
                preview_data{end, 4} = sprintf('Linear impulse at %s %s end', joint, lower(end_name));
            end
        end
    end

    % Moments of Force signals
    if calculate_proximal_on_distal
        preview_data{end+1, 1} = 'Moment of Force';
        preview_data{end, 2} = 'All';
        preview_data{end, 3} = 'Proximal→Distal';
        preview_data{end, 4} = 'Moments of force from proximal on distal';
    end

    if calculate_distal_on_proximal
        preview_data{end+1, 1} = 'Moment of Force';
        preview_data{end, 2} = 'All';
        preview_data{end, 3} = 'Distal→Proximal';
        preview_data{end, 4} = 'Moments of force from distal on proximal';
    end

    % Update the table
    if isfield(handles, 'signals_preview_table') && ishandle(handles.signals_preview_table)
        set(handles.signals_preview_table, 'Data', preview_data);
    end

catch ME
    fprintf('Error updating preview table: %s\n', ME.message);
end
end

% ============================================================================
% PERFORMANCE SETTINGS INTERFACE
% ============================================================================

function handles = createPerformanceSettingsLayout(parent, handles)
% Create comprehensive performance settings interface
colors = handles.colors;

% Create scrollable panel for performance settings
scrollPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'BackgroundColor', colors.background, ...
    'BorderType', 'none');

% Create overview description panel
handles = createPerformanceOverviewSection(scrollPanel, handles);

% Create sections for different performance categories
handles = createParallelProcessingSection(scrollPanel, handles);
handles = createMemoryManagementSection(scrollPanel, handles);
handles = createOptimizationSection(scrollPanel, handles);
handles = createMonitoringSection(scrollPanel, handles);
handles = createActionButtons(scrollPanel, handles);

% Load current preferences into UI (will be done after UI creation)
end

function handles = createPerformanceOverviewSection(parent, handles)
% Create overview description section for performance settings
colors = handles.colors;

% Overview panel
overviewPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.88, 0.96, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 1, ...
    'HighlightColor', colors.border, ...
    'Title', 'Performance Settings Overview', ...
    'FontWeight', 'bold', ...
    'FontSize', 11);

% Overview description
uicontrol('Parent', overviewPanel, ...
    'Style', 'text', ...
    'String', 'This tab allows you to configure performance optimization settings for the golf swing simulation GUI. Adjust these parameters to optimize simulation speed, memory usage, and overall system performance based on your hardware capabilities and workload requirements.', ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.1, 0.96, 0.8], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);
end

function handles = createParallelProcessingSection(parent, handles)
% Create parallel processing settings section
colors = handles.colors;

% Section title
sectionPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.77, 0.96, 0.22], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 1, ...
    'HighlightColor', colors.border, ...
    'Title', 'Parallel Processing Settings', ...
    'FontWeight', 'bold', ...
    'FontSize', 11);

% Left side - Controls
% Enable parallel processing checkbox
handles.enable_parallel_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Parallel Processing', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.75, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateParallelSettings);

% Number of workers input
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Max Parallel Workers:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.55, 0.3, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

handles.workers_edit = uicontrol('Parent', sectionPanel, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.55, 0.2, 0.1], ...
    'String', '1', ...
    'BackgroundColor', 'white', ...
    'Callback', @updateWorkersInput);

% Cluster profile selection
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Cluster Profile:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.35, 0.3, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

handles.cluster_profile_popup = uicontrol('Parent', sectionPanel, ...
    'Style', 'popupmenu', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.35, 0.2, 0.1], ...
    'String', getAvailableClusterProfiles(), ...
    'Callback', @updateClusterProfile);

% Use local cluster checkbox
handles.use_local_cluster_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Use Local Cluster Profile', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.15, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateClusterSettings);

% Test cluster button
handles.test_cluster_button = uicontrol('Parent', sectionPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Test Cluster', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.15, 0.2, 0.1], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @testClusterConnection);

% Right side - Descriptions
% Parallel processing description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Parallel Processing distributes simulation workload across multiple CPU cores, significantly reducing total computation time for large datasets.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.75, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Workers description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Max Parallel Workers: Set the maximum number of CPU cores to use. Higher values increase speed but require more memory. Recommended: 50-80% of available cores.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.55, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Cluster profile description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Cluster Profile: Select the parallel computing profile to use. Local_Cluster is recommended for single-machine processing.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.35, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Local cluster description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Use Local Cluster Profile: When enabled, forces the use of the selected local cluster profile for better performance control.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.15, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);
end

function handles = createMemoryManagementSection(parent, handles)
% Create memory management settings section
colors = handles.colors;

% Section title
sectionPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.54, 0.96, 0.22], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 1, ...
    'HighlightColor', colors.border, ...
    'Title', 'Memory Management', ...
    'FontWeight', 'bold', ...
    'FontSize', 11);

% Left side - Controls
% Enable preallocation checkbox
handles.enable_preallocation_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Preallocation', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.75, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updatePreallocationSettings);

% Preallocation buffer size
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Buffer Size:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.55, 0.2, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

handles.buffer_size_edit = uicontrol('Parent', sectionPanel, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.55, 0.2, 0.1], ...
    'String', '1000', ...
    'BackgroundColor', 'white', ...
    'Callback', @updateBufferSize);

% Enable data compression checkbox
handles.enable_compression_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Data Compression', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.35, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateCompressionSettings);

% Compression level input
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Compression Level (1-9):', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.15, 0.3, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

handles.compression_edit = uicontrol('Parent', sectionPanel, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.15, 0.2, 0.1], ...
    'String', '6', ...
    'BackgroundColor', 'white', ...
    'Callback', @updateCompressionInput);

% Right side - Descriptions
% Preallocation description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Preallocation reserves memory blocks in advance, preventing frequent memory reallocation during simulation execution. This significantly improves performance for large datasets.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.75, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Buffer size description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Buffer Size: Number of simulation trials to preallocate memory for. Larger buffers improve performance but use more memory. Recommended: 1000-5000 for typical workloads.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.55, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Compression description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Data Compression reduces memory usage by compressing simulation results. Higher levels save more memory but require more CPU time for compression/decompression.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.35, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Compression level description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Compression Level: 1=fast/less compression, 9=slow/maximum compression. Level 6 provides good balance between memory savings and performance.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.15, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);
end

function handles = createOptimizationSection(parent, handles)
% Create optimization settings section
colors = handles.colors;

% Section title
sectionPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.31, 0.96, 0.22], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 1, ...
    'HighlightColor', colors.border, ...
    'Title', 'Optimization Settings', ...
    'FontWeight', 'bold', ...
    'FontSize', 11);

% Left side - Controls
% Enable model caching checkbox
handles.enable_caching_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Model Caching', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.75, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateCachingSettings);

% Enable memory pooling checkbox
handles.enable_memory_pooling_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Memory Pooling', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.55, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateMemoryPoolingSettings);

% Memory pool size
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Memory Pool Size (MB):', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.35, 0.3, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

handles.memory_pool_edit = uicontrol('Parent', sectionPanel, ...
    'Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.35, 0.2, 0.1], ...
    'String', '100', ...
    'BackgroundColor', 'white', ...
    'Callback', @updateMemoryPoolSize);

% Performance analysis button
handles.performance_analysis_button = uicontrol('Parent', sectionPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Run Performance Analysis', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.15, 0.2, 0.1], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @runPerformanceAnalysis);

% Right side - Descriptions
% Model caching description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Model Caching stores compiled Simulink models in memory, eliminating the need to recompile models between simulation runs. This dramatically reduces startup time for repeated simulations.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.75, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Memory pooling description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Memory Pooling pre-allocates and reuses memory blocks for simulation data, reducing memory fragmentation and improving overall system performance during long simulation sessions.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.55, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Memory pool size description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Memory Pool Size: Total memory allocated for the memory pool in MB. Larger pools provide better performance but use more system memory. Recommended: 100-500 MB for typical workloads.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.35, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Performance analysis description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Performance Analysis: Runs comprehensive diagnostics to identify bottlenecks, analyze memory usage patterns, and provide optimization recommendations for your specific system configuration.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.15, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);
end

function handles = createMonitoringSection(parent, handles)
% Create monitoring settings section
colors = handles.colors;

% Section title
sectionPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.08, 0.96, 0.22], ...
    'BackgroundColor', colors.panel, ...
    'BorderType', 'line', ...
    'BorderWidth', 1, ...
    'HighlightColor', colors.border, ...
    'Title', 'Performance Monitoring', ...
    'FontWeight', 'bold', ...
    'FontSize', 11);

% Left side - Controls
% Enable performance monitoring checkbox
handles.enable_performance_monitoring_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Performance Monitoring', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.75, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateMonitoringSettings);

% Enable memory monitoring checkbox
handles.enable_memory_monitoring_checkbox = uicontrol('Parent', sectionPanel, ...
    'Style', 'checkbox', ...
    'String', 'Enable Memory Monitoring', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.55, 0.4, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'FontWeight', 'bold', ...
    'Callback', @updateMemoryMonitoringSettings);

% Current memory usage display
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Current Memory Usage:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.35, 0.3, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

handles.memory_usage_text = uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Calculating...', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.35, 0.2, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold');

% Refresh memory button
handles.refresh_memory_button = uicontrol('Parent', sectionPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Refresh Memory Info', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.15, 0.2, 0.1], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @refreshMemoryInfo);

% Right side - Descriptions
% Performance monitoring description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Performance Monitoring tracks simulation execution times, identifies bottlenecks, and provides real-time feedback on optimization effectiveness. Essential for tuning performance parameters.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.75, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Memory monitoring description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Memory Monitoring tracks system memory usage, helps identify memory leaks, and ensures optimal memory allocation for simulation workloads. Critical for long-running simulation sessions.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.55, 0.45, 0.15], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Memory usage display description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Current Memory Usage: Real-time display of system memory consumption. Shows both physical and virtual memory usage to help optimize memory allocation settings.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.35, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);

% Refresh memory description
uicontrol('Parent', sectionPanel, ...
    'Style', 'text', ...
    'String', 'Refresh Memory Info: Updates the memory usage display with current system information. Use this to monitor memory changes during simulation execution.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.15, 0.45, 0.1], ...
    'BackgroundColor', colors.panel, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 9);
end

function handles = createActionButtons(parent, handles)
% Create action buttons for performance settings
colors = handles.colors;

% Button panel
buttonPanel = uipanel('Parent', parent, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.01, 0.96, 0.04], ...
    'BackgroundColor', colors.background, ...
    'BorderType', 'none');

% Save settings button
handles.save_performance_button = uicontrol('Parent', buttonPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Save Performance Settings', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @savePerformanceSettings);

% Reset to defaults button
handles.reset_performance_button = uicontrol('Parent', buttonPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Reset to Defaults', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @resetPerformanceSettings);

% Apply settings button
handles.apply_performance_button = uicontrol('Parent', buttonPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Apply Settings', ...
    'Units', 'normalized', ...
    'Position', [0.75, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @applyPerformanceSettings);

% Setup Local Cluster button
handles.setup_cluster_button = uicontrol('Parent', buttonPanel, ...
    'Style', 'pushbutton', ...
    'String', 'Setup Local Cluster', ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.lightGrey, ...
    'ForegroundColor', colors.text, ...
    'FontWeight', 'bold', ...
    'Callback', @setupLocalCluster);

% Right side - Action button descriptions
% Setup Local Cluster button description
uicontrol('Parent', buttonPanel, ...
    'Style', 'text', ...
    'String', 'Setup: Creates Local_Cluster profile for parallel processing. Run this first if you get cluster errors.', ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.background, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 8);

% Save button description
uicontrol('Parent', buttonPanel, ...
    'Style', 'text', ...
    'String', 'Save: Stores current performance settings to user preferences file for future sessions. Settings persist between GUI launches.', ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.background, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 8);

% Reset button description
uicontrol('Parent', buttonPanel, ...
    'Style', 'text', ...
    'String', 'Reset: Restores all performance settings to their default values. Use this if you encounter performance issues.', ...
    'Units', 'normalized', ...
    'Position', [0.5, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.background, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 8);

% Apply button description
uicontrol('Parent', buttonPanel, ...
    'Style', 'text', ...
    'String', 'Apply: Immediately applies current performance settings to the current session without saving.', ...
    'Units', 'normalized', ...
    'Position', [0.75, 0.1, 0.2, 0.8], ...
    'BackgroundColor', colors.background, ...
    'HorizontalAlignment', 'left', ...
    'FontSize', 8);
end

% ============================================================================
% PERFORMANCE SETTINGS CALLBACK FUNCTIONS
% ============================================================================

function updateParallelSettings(~, ~)
% Update parallel processing settings
handles = guidata(gcbf);
enabled = get(handles.enable_parallel_checkbox, 'Value');

% Enable/disable related controls
if enabled
    enable_state = 'on';
else
    enable_state = 'off';
end

set(handles.workers_edit, 'Enable', enable_state);
set(handles.cluster_profile_popup, 'Enable', enable_state);
set(handles.use_local_cluster_checkbox, 'Enable', enable_state);
set(handles.test_cluster_button, 'Enable', enable_state);

guidata(handles.fig, handles);
end

function updateWorkersInput(~, ~)
% Update workers setting when edit box changes
handles = guidata(gcbf);
try
    value = str2double(get(handles.workers_edit, 'String'));
    if ~isnan(value) && value >= 1 && value <= feature('numcores')
        handles.preferences.max_parallel_workers = round(value);
    else
        % Reset to current preference if invalid
        set(handles.workers_edit, 'String', num2str(handles.preferences.max_parallel_workers));
    end
catch
    % Reset to current preference if error
    set(handles.workers_edit, 'String', num2str(handles.preferences.max_parallel_workers));
end
guidata(handles.fig, handles);
end

function updateClusterProfile(~, ~)
% Update cluster profile selection
handles = guidata(gcbf);
profiles = get(handles.cluster_profile_popup, 'String');
selected = get(handles.cluster_profile_popup, 'Value');
selected_profile = profiles{selected};

% Update preferences
handles.preferences.cluster_profile = selected_profile;
guidata(handles.fig, handles);
end

function updateClusterSettings(~, ~)
% Update cluster settings
handles = guidata(gcbf);
use_local = get(handles.use_local_cluster_checkbox, 'Value');
handles.preferences.use_local_cluster = use_local;
guidata(handles.fig, handles);
end

function updatePreallocationSettings(~, ~)
% Update preallocation settings
handles = guidata(gcbf);
enabled = get(handles.enable_preallocation_checkbox, 'Value');

if enabled
    enable_state = 'on';
else
    enable_state = 'off';
end

set(handles.buffer_size_edit, 'Enable', enable_state);
guidata(handles.fig, handles);
end

function updateBufferSize(~, ~)
% Update buffer size setting
handles = guidata(gcbf);
try
    value = str2double(get(handles.buffer_size_edit, 'String'));
    if ~isnan(value) && value > 0
        handles.preferences.preallocation_buffer_size = value;
    else
        set(handles.buffer_size_edit, 'String', num2str(handles.preferences.preallocation_buffer_size));
    end
catch
    set(handles.buffer_size_edit, 'String', num2str(handles.preferences.preallocation_buffer_size));
end
guidata(handles.fig, handles);
end

function updateCompressionSettings(~, ~)
% Update compression settings
handles = guidata(gcbf);
enabled = get(handles.enable_compression_checkbox, 'Value');

if enabled
    enable_state = 'on';
else
    enable_state = 'off';
end

set(handles.compression_edit, 'Enable', enable_state);
guidata(handles.fig, handles);
end

function updateCompressionInput(~, ~)
% Update compression level when edit box changes
handles = guidata(gcbf);
try
    value = str2double(get(handles.compression_edit, 'String'));
    if ~isnan(value) && value >= 1 && value <= 9
        handles.preferences.compression_level = round(value);
    else
        % Reset to current preference if invalid
        set(handles.compression_edit, 'String', num2str(handles.preferences.compression_level));
    end
catch
    % Reset to current preference if error
    set(handles.compression_edit, 'String', num2str(handles.preferences.compression_level));
end
guidata(handles.fig, handles);
end

function updateCachingSettings(~, ~)
% Update caching settings
handles = guidata(gcbf);
enabled = get(handles.enable_caching_checkbox, 'Value');
handles.preferences.enable_model_caching = enabled;
guidata(handles.fig, handles);
end

function updateMemoryPoolingSettings(~, ~)
% Update memory pooling settings
handles = guidata(gcbf);
enabled = get(handles.enable_memory_pooling_checkbox, 'Value');

if enabled
    enable_state = 'on';
else
    enable_state = 'off';
end

set(handles.memory_pool_edit, 'Enable', enable_state);
guidata(handles.fig, handles);
end

function updateMemoryPoolSize(~, ~)
% Update memory pool size
handles = guidata(gcbf);
try
    value = str2double(get(handles.memory_pool_edit, 'String'));
    if ~isnan(value) && value > 0
        handles.preferences.memory_pool_size = value;
    else
        set(handles.memory_pool_edit, 'String', num2str(handles.preferences.memory_pool_size));
    end
catch
    set(handles.memory_pool_edit, 'String', num2str(handles.preferences.memory_pool_size));
end
guidata(handles.fig, handles);
end

function updateMonitoringSettings(~, ~)
% Update performance monitoring settings
handles = guidata(gcbf);
enabled = get(handles.enable_performance_monitoring_checkbox, 'Value');
handles.preferences.enable_performance_monitoring = enabled;
guidata(handles.fig, handles);
end

function updateMemoryMonitoringSettings(~, ~)
% Update memory monitoring settings
handles = guidata(gcbf);
enabled = get(handles.enable_memory_monitoring_checkbox, 'Value');
handles.preferences.enable_memory_monitoring = enabled;
guidata(handles.fig, handles);
end

% ============================================================================
% PERFORMANCE SETTINGS ACTION FUNCTIONS
% ============================================================================

function testClusterConnection(~, ~)
% Test cluster connection
handles = guidata(gcbf);

try
    % Get selected cluster profile
    profiles = get(handles.cluster_profile_popup, 'String');
    selected = get(handles.cluster_profile_popup, 'Value');
    cluster_name = profiles{selected};

    % Check if initializeLocalCluster function exists
    if ~exist('initializeLocalCluster', 'file')
        error('initializeLocalCluster function not found. Please ensure initializeLocalCluster.m is in the MATLAB path.');
    end

    % Test cluster
    fprintf('Calling initializeLocalCluster...\n');
    cluster_info = initializeLocalCluster(handles.preferences);
    fprintf('Function call completed successfully\n');

    % Check if cluster_info is a valid struct with required fields
    if ~isstruct(cluster_info)
        error('Invalid cluster info returned: not a struct (got %s)', class(cluster_info));
    end

    if ~isfield(cluster_info, 'status')
        error('Invalid cluster info: missing status field');
    end

    if strcmp(cluster_info.status, 'ready')
        if isfield(cluster_info, 'num_workers')
            msgbox(sprintf('✓ Cluster "%s" test successful!\nWorkers: %d', cluster_name, cluster_info.num_workers), ...
                'Cluster Test', 'modal');
        else
            msgbox(sprintf('✓ Cluster "%s" test successful!', cluster_name), ...
                'Cluster Test', 'modal');
        end
    else
        if isfield(cluster_info, 'error_message')
            msgbox(sprintf('✗ Cluster "%s" test failed:\n%s', cluster_name, cluster_info.error_message), ...
                'Cluster Test', 'modal');
        else
            msgbox(sprintf('✗ Cluster "%s" test failed:\nUnknown error', cluster_name), ...
                'Cluster Test', 'modal');
        end
    end

catch ME
    % Provide detailed error information
    error_msg = sprintf('Error testing cluster: %s\n\nFunction: %s\nLine: %d', ...
        ME.message, ME.stack(1).name, ME.stack(1).line);
    msgbox(error_msg, 'Cluster Test Error', 'modal');
    fprintf('Cluster test error details: %s\n', ME.message);
    fprintf('Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);

    % Additional debugging info
    fprintf('Current working directory: %s\n', pwd);
    fprintf('MATLAB path contains current directory: %s\n', ...
        mat2str(contains(path, pwd)));
end
end

function setupLocalCluster(~, ~)
% Setup Local_Cluster profile for parallel processing
try
    fprintf('Setting up Local_Cluster profile...\n');

    % Check if Parallel Computing Toolbox is available
    if ~license('test', 'Distrib_Computing_Toolbox')
        error('Parallel Computing Toolbox not available. Please install it first.');
    end

    % Get current cluster profiles
    current_profiles = parallel.clusterProfiles();
    fprintf('Current cluster profiles: %s\n', strjoin(current_profiles, ', '));

    % Check if Local_Cluster already exists
    if ismember('Local_Cluster', current_profiles)
        fprintf('Local_Cluster profile already exists.\n');
        msgbox('Local_Cluster profile already exists and is ready to use.', 'Setup Complete', 'modal');
        return;
    end

    % Create Local_Cluster profile
    fprintf('Creating Local_Cluster profile...\n');

    % Get number of available cores
    num_cores = feature('numcores');
    fprintf('Available cores: %d\n', num_cores);

    % Create cluster profile
    cluster_profile = parallel.importProfile('local');
    cluster_profile.Name = 'Local_Cluster';
    cluster_profile.NumWorkers = num_cores;

    % Save the profile
    parallel.saveProfile(cluster_profile);

    % Verify the profile was created
    new_profiles = parallel.clusterProfiles();
    if ismember('Local_Cluster', new_profiles)
        fprintf('✓ Local_Cluster profile created successfully!\n');
        fprintf('Profile configured with %d workers\n', num_cores);

        % Update the cluster profile popup in the GUI
        handles = guidata(gcbf);
        if isfield(handles, 'cluster_profile_popup')
            profiles = getAvailableClusterProfiles();
            set(handles.cluster_profile_popup, 'String', profiles);

            % Set Local_Cluster as selected
            local_idx = find(strcmp(profiles, 'Local_Cluster'));
            if ~isempty(local_idx)
                set(handles.cluster_profile_popup, 'Value', local_idx);
            end

            % Update preferences
            handles.preferences.cluster_profile = 'Local_Cluster';
            guidata(handles.fig, handles);
        end

        msgbox(sprintf('Local_Cluster profile created successfully!\n\nProfile: Local_Cluster\nWorkers: %d\n\nYou can now use this profile for parallel processing.', num_cores), ...
            'Setup Complete', 'modal');
    else
        error('Failed to create Local_Cluster profile');
    end

catch ME
    error_msg = sprintf('Error setting up Local_Cluster profile:\n%s\n\nFunction: %s\nLine: %d', ...
        ME.message, ME.stack(1).name, ME.stack(1).line);
    msgbox(error_msg, 'Setup Error', 'modal');
    fprintf('Setup error details: %s\n', ME.message);
end
end

function runPerformanceAnalysis(~, ~)
% Run performance analysis
handles = guidata(gcbf);

try
    % Run the performance analysis
    performance_analysis();

    msgbox('Performance analysis completed. Check the command window for detailed results.', ...
        'Performance Analysis', 'modal');

catch ME
    msgbox(sprintf('Error running performance analysis: %s', ME.message), 'Error', 'modal');
end
end

function refreshMemoryInfo(~, ~)
% Refresh memory usage information
handles = guidata(gcbf);

try
    % Get memory usage
    memory_info = getMemoryUsage();

    % Check if required fields exist and are valid
    if isfield(memory_info, 'usage_percent') && isfield(memory_info, 'used_gb') && ...
            isfield(memory_info, 'total_gb') && ~isnan(memory_info.usage_percent) && ...
            ~isnan(memory_info.used_gb) && ~isnan(memory_info.total_gb)
        memory_text = sprintf('%.1f%% used (%.1f GB / %.1f GB)', ...
            memory_info.usage_percent, ...
            memory_info.used_gb, ...
            memory_info.total_gb);
    else
        memory_text = 'Memory info unavailable';
    end

    set(handles.memory_usage_text, 'String', memory_text);

catch ME
    set(handles.memory_usage_text, 'String', 'Error getting memory info');
    fprintf('Warning: Could not refresh memory info: %s\n', ME.message);
end
end

function savePerformanceSettings(~, ~)
% Save performance settings to preferences
handles = guidata(gcbf);

try
    % Collect all settings from UI
    handles.preferences.enable_parallel_processing = get(handles.enable_parallel_checkbox, 'Value');
    handles.preferences.max_parallel_workers = round(str2double(get(handles.workers_edit, 'String')));

    % Get cluster profile from popup
    profiles = getAvailableClusterProfiles();
    selected_idx = get(handles.cluster_profile_popup, 'Value');
    if selected_idx <= length(profiles)
        handles.preferences.cluster_profile = profiles{selected_idx};
    else
        handles.preferences.cluster_profile = 'Local_Cluster';
    end

    handles.preferences.use_local_cluster = get(handles.use_local_cluster_checkbox, 'Value');
    handles.preferences.enable_preallocation = get(handles.enable_preallocation_checkbox, 'Value');
    handles.preferences.preallocation_buffer_size = round(str2double(get(handles.buffer_size_edit, 'String')));
    handles.preferences.enable_data_compression = get(handles.enable_compression_checkbox, 'Value');
    handles.preferences.compression_level = round(str2double(get(handles.compression_edit, 'String')));
    handles.preferences.enable_model_caching = get(handles.enable_caching_checkbox, 'Value');
    handles.preferences.enable_memory_pooling = get(handles.enable_memory_pooling_checkbox, 'Value');
    handles.preferences.memory_pool_size = round(str2double(get(handles.memory_pool_edit, 'String')));
    handles.preferences.enable_performance_monitoring = get(handles.enable_performance_monitoring_checkbox, 'Value');
    handles.preferences.enable_memory_monitoring = get(handles.enable_memory_monitoring_checkbox, 'Value');

    % Save preferences
    saveUserPreferences(handles);

    msgbox('Performance settings saved successfully!', 'Success', 'modal');

catch ME
    msgbox(sprintf('Error saving performance settings: %s', ME.message), 'Error', 'modal');
end
end

function resetPerformanceSettings(~, ~)
% Reset performance settings to defaults
handles = guidata(gcbf);

try
    % Reset to default values
    handles.preferences.enable_parallel_processing = true;
    handles.preferences.max_parallel_workers = feature('numcores');
    handles.preferences.cluster_profile = 'Local_Cluster';
    handles.preferences.use_local_cluster = true;
    handles.preferences.enable_preallocation = true;
    handles.preferences.preallocation_buffer_size = 1000;
    handles.preferences.enable_data_compression = true;
    handles.preferences.compression_level = 6;
    handles.preferences.enable_model_caching = true;
    handles.preferences.enable_memory_pooling = true;
    handles.preferences.memory_pool_size = 100;
    handles.preferences.enable_performance_monitoring = true;
    handles.preferences.enable_memory_monitoring = true;

    % Update UI
    handles = loadPerformancePreferencesToUI(handles);

    msgbox('Performance settings reset to defaults!', 'Success', 'modal');

catch ME
    msgbox(sprintf('Error resetting performance settings: %s', ME.message), 'Error', 'modal');
end
end

function applyPerformanceSettings(~, ~)
% Apply performance settings immediately
handles = guidata(gcbf);

try
    % Save settings first
    savePerformanceSettings([], []);

    % Apply settings to current session
    handles = applyUserPreferences(handles);

    msgbox('Performance settings applied successfully!', 'Success', 'modal');

catch ME
    msgbox(sprintf('Error applying performance settings: %s', ME.message), 'Error', 'modal');
end
end

% ============================================================================
% UTILITY FUNCTIONS FOR PERFORMANCE SETTINGS
% ============================================================================

function profiles = getAvailableClusterProfiles()
% Get available cluster profiles
try
    profiles = parallel.clusterProfiles();
    if isempty(profiles)
        profiles = {'local'};
    end

    % Ensure Local_Cluster is always available and first in the list
    if ~ismember('Local_Cluster', profiles)
        profiles = ['Local_Cluster', profiles];
    else
        % Move Local_Cluster to the front
        profiles = ['Local_Cluster', profiles(~strcmp(profiles, 'Local_Cluster'))];
    end
catch
    profiles = {'Local_Cluster', 'local'};
end
end

function handles = loadPerformancePreferencesWhenReady(handles)
% LOADPERFORMANCEPREFERENCESWHENREADY - Load performance preferences when UI is fully ready
%
% This function ensures all performance UI elements are created and ready
% before attempting to load preferences. It's called after the main layout
% is created to avoid timing issues.

try
    % Wait a moment for UI elements to be fully rendered
    pause(0.1);

    % Check if all critical performance UI elements exist and are valid
    required_elements = {
        'enable_parallel_checkbox'
        'workers_edit'
        'cluster_profile_popup'
        'use_local_cluster_checkbox'
        'enable_preallocation_checkbox'
        'buffer_size_edit'
        'enable_compression_checkbox'
        'compression_edit'
        'enable_caching_checkbox'
        'enable_memory_pooling_checkbox'
        'memory_pool_edit'
        'enable_performance_monitoring_checkbox'
        'enable_memory_monitoring_checkbox'
        };

    % Verify all elements exist and are valid handles
    all_elements_ready = true;
    for i = 1:length(required_elements)
        element_name = required_elements{i};
        if ~isfield(handles, element_name) || ~ishandle(handles.(element_name))
            all_elements_ready = false;
            break;
        end
    end

    if all_elements_ready
        fprintf('All performance UI elements ready, loading preferences...\n');
        handles = loadPerformancePreferencesToUI(handles);
        fprintf('Performance preferences loaded successfully!\n');
    else
        fprintf('Performance UI elements not ready yet, will load preferences later\n');
        % Schedule a retry with a timer as fallback
        timer_obj = timer('ExecutionMode', 'singleShot', 'StartDelay', 0.5);
        timer_obj.TimerFcn = @(src, event) loadPerformancePreferencesDelayed(handles.fig);
        start(timer_obj);
    end

catch ME
    fprintf('Error in loadPerformancePreferencesWhenReady: %s\n', ME.message);
    % Fallback to timer-based approach
    timer_obj = timer('ExecutionMode', 'singleShot', 'StartDelay', 0.5);
    timer_obj.TimerFcn = @(src, event) loadPerformancePreferencesDelayed(handles.fig);
    start(timer_obj);
end
end

function handles = loadPerformancePreferencesToUI(handles)
% Load performance preferences into UI elements
try
    % Enhanced validation - check if UI elements exist and are valid
    if ~isfield(handles, 'enable_parallel_checkbox') || ~ishandle(handles.enable_parallel_checkbox)
        fprintf('Performance UI elements not ready yet, skipping preference loading\n');
        return;
    end

    % Additional validation - ensure all critical elements are ready
    critical_elements = {'workers_edit', 'cluster_profile_popup', 'enable_preallocation_checkbox'};
    for i = 1:length(critical_elements)
        if ~isfield(handles, critical_elements{i}) || ~ishandle(handles.(critical_elements{i}))
            fprintf('Critical performance UI element %s not ready, skipping preference loading\n', critical_elements{i});
            return;
        end
    end

    % Set parallel processing settings
    set(handles.enable_parallel_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_parallel_processing', true));

    max_workers = getFieldOrDefault(handles.preferences, 'max_parallel_workers', feature('numcores'));
    set(handles.workers_edit, 'String', num2str(max_workers));

    % Set cluster profile
    cluster_profile = getFieldOrDefault(handles.preferences, 'cluster_profile', 'Local_Cluster');
    profiles = getAvailableClusterProfiles();
    profile_idx = find(strcmp(profiles, cluster_profile), 1);
    if isempty(profile_idx)
        profile_idx = 1;
    end
    set(handles.cluster_profile_popup, 'Value', profile_idx);

    set(handles.use_local_cluster_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'use_local_cluster', true));

    % Set preallocation settings
    set(handles.enable_preallocation_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_preallocation', true));

    buffer_size = getFieldOrDefault(handles.preferences, 'preallocation_buffer_size', 1000);
    set(handles.buffer_size_edit, 'String', num2str(buffer_size));

    % Set compression settings
    set(handles.enable_compression_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_data_compression', true));

    compression_level = getFieldOrDefault(handles.preferences, 'compression_level', 6);
    set(handles.compression_edit, 'String', num2str(compression_level));

    % Set caching settings
    set(handles.enable_caching_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_model_caching', true));

    % Set memory pooling settings
    set(handles.enable_memory_pooling_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_memory_pooling', true));

    memory_pool_size = getFieldOrDefault(handles.preferences, 'memory_pool_size', 100);
    set(handles.memory_pool_edit, 'String', num2str(memory_pool_size));

    % Set monitoring settings
    set(handles.enable_performance_monitoring_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_performance_monitoring', true));

    set(handles.enable_memory_monitoring_checkbox, 'Value', ...
        getFieldOrDefault(handles.preferences, 'enable_memory_monitoring', true));

    % Update control states - wrap each in try-catch for better error isolation
    try
        % Update parallel settings inline to avoid callback context issues
        if isfield(handles, 'enable_parallel_checkbox') && ishandle(handles.enable_parallel_checkbox)
            enabled = get(handles.enable_parallel_checkbox, 'Value');
            if enabled
                enable_state = 'on';
            else
                enable_state = 'off';
            end

            if isfield(handles, 'workers_edit') && ishandle(handles.workers_edit)
                set(handles.workers_edit, 'Enable', enable_state);
            end
            if isfield(handles, 'cluster_profile_popup') && ishandle(handles.cluster_profile_popup)
                set(handles.cluster_profile_popup, 'Enable', enable_state);
            end
            if isfield(handles, 'use_local_cluster_checkbox') && ishandle(handles.use_local_cluster_checkbox)
                set(handles.use_local_cluster_checkbox, 'Enable', enable_state);
            end
            if isfield(handles, 'test_cluster_button') && ishandle(handles.test_cluster_button)
                set(handles.test_cluster_button, 'Enable', enable_state);
            end
        end
    catch ME
        fprintf('Warning: Could not update parallel settings: %s\n', ME.message);
    end

    try
        % Update preallocation settings inline to avoid callback context issues
        if isfield(handles, 'enable_preallocation_checkbox') && ishandle(handles.enable_preallocation_checkbox)
            enabled = get(handles.enable_preallocation_checkbox, 'Value');
            if enabled
                enable_state = 'on';
            else
                enable_state = 'off';
            end

            if isfield(handles, 'buffer_size_edit') && ishandle(handles.buffer_size_edit)
                set(handles.buffer_size_edit, 'Enable', enable_state);
            end
        end
    catch ME
        fprintf('Warning: Could not update preallocation settings: %s\n', ME.message);
    end

    try
        % Update compression settings inline to avoid callback context issues
        if isfield(handles, 'enable_compression_checkbox') && ishandle(handles.enable_compression_checkbox)
            enabled = get(handles.enable_compression_checkbox, 'Value');
            if enabled
                enable_state = 'on';
            else
                enable_state = 'off';
            end

            if isfield(handles, 'compression_edit') && ishandle(handles.compression_edit)
                set(handles.compression_edit, 'Enable', enable_state);
            end
        end
    catch ME
        fprintf('Warning: Could not update compression settings: %s\n', ME.message);
    end

    try
        % Update memory pooling settings inline to avoid callback context issues
        if isfield(handles, 'enable_memory_pooling_checkbox') && ishandle(handles.enable_memory_pooling_checkbox)
            enabled = get(handles.enable_memory_pooling_checkbox, 'Value');
            if enabled
                enable_state = 'on';
            else
                enable_state = 'off';
            end

            if isfield(handles, 'memory_pool_edit') && ishandle(handles.memory_pool_edit)
                set(handles.memory_pool_edit, 'Enable', enable_state);
            end
        end
    catch ME
        fprintf('Warning: Could not update memory pooling settings: %s\n', ME.message);
    end

    % Refresh memory info
    try
        if isfield(handles, 'memory_usage_text') && ishandle(handles.memory_usage_text)
            memory_info = getMemoryUsage();

            if ~isnan(memory_info.usage_percent)
                memory_text = sprintf('%.1f%% used (%.1f GB / %.1f GB)', ...
                    memory_info.usage_percent, ...
                    memory_info.used_gb, ...
                    memory_info.total_gb);
            else
                memory_text = 'Memory info unavailable';
            end

            set(handles.memory_usage_text, 'String', memory_text);
        end
    catch ME
        fprintf('Warning: Could not refresh memory info: %s\n', ME.message);
    end

catch ME
    fprintf('Error loading performance preferences to UI: %s\n', ME.message);
    fprintf('Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
end
end

function value = getFieldOrDefault(struct_obj, field_name, default_value)
% Get field value with default fallback
if isfield(struct_obj, field_name)
    value = struct_obj.(field_name);
else
    value = default_value;
end
end

function loadPerformancePreferencesDelayed(fig_handle)
% LOADPERFORMANCEPREFERENCESDELAYED - Load performance preferences after GUI is ready
%
% This function is called by a timer as a fallback to ensure the GUI is fully initialized
% before attempting to load performance preferences

try
    % Wait a bit more to ensure GUI is fully ready
    pause(0.5);

    % Get the current handles
    handles = guidata(fig_handle);

    % Enhanced validation - check multiple critical elements
    critical_elements = {'enable_parallel_checkbox', 'workers_edit', 'cluster_profile_popup'};
    all_elements_ready = true;

    for i = 1:length(critical_elements)
        if ~isfield(handles, critical_elements{i}) || ~ishandle(handles.(critical_elements{i}))
            all_elements_ready = false;
            break;
        end
    end

    if all_elements_ready
        fprintf('Loading performance preferences to UI (delayed)...\n');
        handles = loadPerformancePreferencesToUI(handles);
        guidata(fig_handle, handles);
        fprintf('Performance preferences loaded successfully!\n');
    else
        fprintf('Performance UI elements still not ready, retrying in 1 second...\n');
        % Retry after another delay, but limit retries to avoid infinite loops
        if ~isfield(handles, 'performance_load_retry_count')
            handles.performance_load_retry_count = 1;
        else
            handles.performance_load_retry_count = handles.performance_load_retry_count + 1;
        end

        if handles.performance_load_retry_count <= 3  % Max 3 retries
            timer_obj = timer('ExecutionMode', 'singleShot', 'StartDelay', 1.0);
            timer_obj.TimerFcn = @(src, event) loadPerformancePreferencesDelayed(fig_handle);
            start(timer_obj);
            guidata(fig_handle, handles);
        else
            fprintf('Maximum retries reached. Performance preferences will be loaded when manually accessed.\n');
        end
    end

catch ME
    fprintf('Error in loadPerformancePreferencesDelayed: %s\n', ME.message);
    fprintf('Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
end
end

% ============================================================================
% PERFORMANCE MONITORING CALLBACK FUNCTIONS
% ============================================================================

function startPerformanceMonitoring(~, ~)
% Start performance monitoring
handles = guidata(gcbo);
if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
        ismethod(handles.performance_tracker, 'enable_tracking')
    try
        handles.performance_tracker.enable_tracking();
        set(handles.monitoring_status_text, 'String', 'Status: Monitoring Active', ...
            'ForegroundColor', handles.colors.success);

        % Start auto-refresh timer if enabled
        if get(handles.auto_refresh_checkbox, 'Value')
            startPerformanceRefreshTimer(handles);
        end

        fprintf('🔍 Performance monitoring started\n');
    catch ME
        fprintf('Warning: Could not enable performance tracking: %s\n', ME.message);
        set(handles.monitoring_status_text, 'String', 'Status: Monitoring Failed', ...
            'ForegroundColor', handles.colors.danger);
    end
else
    set(handles.monitoring_status_text, 'String', 'Status: Performance Tracker Unavailable', ...
        'ForegroundColor', handles.colors.warning);
    fprintf('Error: Performance tracker not initialized\n');
end
guidata(handles.fig, handles);
end

function stopPerformanceMonitoring(~, ~)
% Stop performance monitoring
handles = guidata(gcbo);
if isfield(handles, 'performance_tracker') && ~isempty(handles.performance_tracker) && ...
        ismethod(handles.performance_tracker, 'disable_tracking')
    try
        handles.performance_tracker.disable_tracking();
        set(handles.monitoring_status_text, 'String', 'Status: Monitoring Stopped', ...
            'ForegroundColor', handles.colors.danger);
    catch ME
        fprintf('Warning: Could not disable performance tracking: %s\n', ME.message);
        set(handles.monitoring_status_text, 'String', 'Status: Disable Failed', ...
            'ForegroundColor', handles.colors.danger);
    end
else
    set(handles.monitoring_status_text, 'String', 'Status: Performance Tracker Unavailable', ...
        'ForegroundColor', handles.colors.warning);
end

% Stop auto-refresh timer
stopPerformanceRefreshTimer(handles);

fprintf('🔍 Performance monitoring stopped\n');
guidata(handles.fig, handles);
end

function generatePerformanceReport(~, ~)
% Generate and display performance report
handles = guidata(gcbo);
if isfield(handles, 'performance_tracker')
    try
        % Generate report
        handles.performance_tracker.display_performance_report();

        % Save report to file
        timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
        filename = sprintf('performance_report_%s.mat', timestamp);
        handles.performance_tracker.save_performance_report(filename);

        % Export CSV
        csv_filename = sprintf('performance_data_%s.csv', timestamp);
        handles.performance_tracker.export_performance_csv(csv_filename);

        msgbox(sprintf('Performance report generated and saved:\n%s\n%s', filename, csv_filename), ...
            'Performance Report', 'modal');

    catch ME
        msgbox(sprintf('Error generating performance report: %s', ME.message), ...
            'Error', 'modal');
    end
else
    msgbox('Performance tracker not initialized', 'Error', 'modal');
end
guidata(handles.fig, handles);
end

function clearPerformanceHistory(~, ~)
% Clear performance history
handles = guidata(gcbo);
if isfield(handles, 'performance_tracker')
    handles.performance_tracker.clear_history();

    % Clear UI displays
    set(handles.session_duration_text, 'String', '00:00:00');
    set(handles.active_operations_text, 'String', '0');
    set(handles.current_memory_text, 'String', '0 MB');
    set(handles.memory_change_text, 'String', '0 MB');
    set(handles.recent_operations_list, 'String', {'No operations recorded yet'});

    % Clear chart
    cla(handles.performance_axes);
    xlabel(handles.performance_axes, 'Time (s)');
    ylabel(handles.performance_axes, 'Memory (MB)');
    title(handles.performance_axes, 'Memory Usage Over Time');
    grid(handles.performance_axes, 'on');

    % Reset chart data
    handles.performance_chart_data.times = [];
    handles.performance_chart_data.memory = [];
    handles.performance_chart_data.operations = {};

    set(handles.monitoring_status_text, 'String', 'Status: History Cleared', ...
        'ForegroundColor', handles.colors.warning);

    fprintf('🗑️ Performance history cleared\n');
else
    fprintf('Error: Performance tracker not initialized\n');
end
guidata(handles.fig, handles);
end

function toggleAutoRefresh(~, ~)
% Toggle auto-refresh functionality
handles = guidata(gcbo);
if get(handles.auto_refresh_checkbox, 'Value')
    startPerformanceRefreshTimer(handles);
else
    stopPerformanceRefreshTimer(handles);
end
guidata(handles.fig, handles);
end

function updateRefreshInterval(~, ~)
% Update refresh interval
handles = guidata(gcbo);
try
    interval = str2double(get(handles.refresh_interval_edit, 'String'));
    if isnan(interval) || interval < 0.5
        set(handles.refresh_interval_edit, 'String', '2');
        interval = 2;
    end

    % Restart timer with new interval if active
    if get(handles.auto_refresh_checkbox, 'Value')
        stopPerformanceRefreshTimer(handles);
        startPerformanceRefreshTimer(handles);
    end
catch ME
    fprintf('Error updating refresh interval: %s\n', ME.message);
    set(handles.refresh_interval_edit, 'String', '2');
end
guidata(handles.fig, handles);
end

function startPerformanceRefreshTimer(handles)
% Start the performance refresh timer
try
    % Stop existing timer if any
    stopPerformanceRefreshTimer(handles);

    % Get refresh interval
    interval = str2double(get(handles.refresh_interval_edit, 'String'));
    if isnan(interval) || interval < 0.5
        interval = 2;
    end

    % Create and start timer
    handles.performance_refresh_timer = timer('ExecutionMode', 'fixedRate', ...
        'Period', interval, ...
        'TimerFcn', @(src, event) updatePerformanceMetrics(handles.fig));

    start(handles.performance_refresh_timer);
    fprintf('⏱️ Performance refresh timer started (%.1f sec interval)\n', interval);
catch ME
    fprintf('Error starting performance refresh timer: %s\n', ME.message);
end
end

function stopPerformanceRefreshTimer(handles)
% Stop the performance refresh timer
try
    if isfield(handles, 'performance_refresh_timer') && isvalid(handles.performance_refresh_timer)
        stop(handles.performance_refresh_timer);
        delete(handles.performance_refresh_timer);
        handles = rmfield(handles, 'performance_refresh_timer');
        fprintf('⏱️ Performance refresh timer stopped\n');
    end
catch ME
    fprintf('Error stopping performance refresh timer: %s\n', ME.message);
end
end

function updatePerformanceMetrics(fig)
% Update performance metrics display
try
    handles = guidata(fig);
    if ~isfield(handles, 'performance_tracker')
        return;
    end

    % Update session duration
    session_duration = toc(handles.performance_tracker.session_start_time);
    duration_str = sprintf('%02d:%02d:%02d', ...
        floor(session_duration/3600), ...
        floor(mod(session_duration, 3600)/60), ...
        floor(mod(session_duration, 60)));
    set(handles.session_duration_text, 'String', duration_str);

    % Update memory usage
    try
        memory_usage = getMemoryUsage();
        memory_mb = memory_usage / (1024 * 1024);
        set(handles.current_memory_text, 'String', sprintf('%.1f MB', memory_mb));

        % Update memory change
        if isfield(handles, 'initial_memory')
            memory_change = memory_usage - handles.initial_memory;
            change_mb = memory_change / (1024 * 1024);
            set(handles.memory_change_text, 'String', sprintf('%.1f MB', change_mb));
        else
            handles.initial_memory = memory_usage;
        end
    catch
        set(handles.current_memory_text, 'String', 'N/A');
        set(handles.memory_change_text, 'String', 'N/A');
    end

    % Update active operations count
    if isfield(handles.performance_tracker, 'start_times')
        active_count = length(handles.performance_tracker.start_times);
        set(handles.active_operations_text, 'String', num2str(active_count));
    end

    % Update recent operations list
    updateRecentOperationsList(handles);

    % Update performance chart
    updatePerformanceChart(handles);

    guidata(fig, handles);
catch ME
    fprintf('Error updating performance metrics: %s\n', ME.message);
end
end

function updateRecentOperationsList(handles)
% Update the recent operations list
try
    if ~isfield(handles.performance_tracker, 'timers') || isempty(handles.performance_tracker.timers)
        return;
    end

    % Get recent operations (last 10)
    operation_names = handles.performance_tracker.timers.keys();
    if isempty(operation_names)
        return;
    end

    % Create operation strings
    operation_strings = {};
    for i = 1:min(length(operation_names), 10)
        op_name = operation_names{i};
        if handles.performance_tracker.timers.isKey(op_name)
            timer_data = handles.performance_tracker.timers(op_name);
            time_str = sprintf('%.3fs', timer_data.elapsed_time);
            memory_str = sprintf('%.1fMB', timer_data.memory_delta / (1024 * 1024));
            operation_strings{end+1} = sprintf('%-20s | %8s | %8s', op_name, time_str, memory_str);
        end
    end

    if isempty(operation_strings)
        operation_strings = {'No operations recorded yet'};
    end

    set(handles.recent_operations_list, 'String', operation_strings);
catch ME
    fprintf('Error updating recent operations list: %s\n', ME.message);
end
end

function updatePerformanceChart(handles)
% Update the performance history chart
try
    if ~isfield(handles, 'performance_axes') || ~ishandle(handles.performance_axes)
        return;
    end

    % Get current time and memory
    current_time = toc(handles.performance_tracker.session_start_time);
    try
        current_memory = getMemoryUsage() / (1024 * 1024); % Convert to MB
    catch
        current_memory = 0;
    end

    % Add to chart data
    handles.performance_chart_data.times(end+1) = current_time;
    handles.performance_chart_data.memory(end+1) = current_memory;

    % Keep only last 100 points
    if length(handles.performance_chart_data.times) > 100
        handles.performance_chart_data.times = handles.performance_chart_data.times(end-99:end);
        handles.performance_chart_data.memory = handles.performance_chart_data.memory(end-99:end);
    end

    % Update chart
    plot(handles.performance_axes, handles.performance_chart_data.times, ...
        handles.performance_chart_data.memory, 'b-', 'LineWidth', 1.5);
    xlabel(handles.performance_axes, 'Time (s)');
    ylabel(handles.performance_axes, 'Memory (MB)');
    title(handles.performance_axes, 'Memory Usage Over Time');
    grid(handles.performance_axes, 'on');

    % Auto-scale axes
    if length(handles.performance_chart_data.times) > 1
        xlim(handles.performance_axes, [min(handles.performance_chart_data.times), ...
            max(handles.performance_chart_data.times)]);
        ylim(handles.performance_axes, [min(handles.performance_chart_data.memory), ...
            max(handles.performance_chart_data.memory)]);
    end
catch ME
    fprintf('Error updating performance chart: %s\n', ME.message);
end
end
