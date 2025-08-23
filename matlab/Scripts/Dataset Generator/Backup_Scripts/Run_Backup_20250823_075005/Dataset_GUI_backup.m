function Dataset_GUI()
% Forward Dynamics Dataset Generator - Modern GUI with tabbed interface
% Features: Tabbed structure, pause/resume, post-processing, multiple export formats

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

fig = figure('Name', 'Forward Dynamics Dataset Generator', ...
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
    'String', 'Forward Dynamics Dataset Generator', ...
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
% Process a batch of files
batch_data = struct();
batch_data.trials = cell(length(batch_files), 1);

for i = 1:length(batch_files)
    file_path = fullfile(processing_data.data_folder, batch_files{i});

    try
        % Load data
        data = load(file_path);

        % Process data with calculation options
        processed_trial = processTrialData(data, processing_data);

        batch_data.trials{i} = processed_trial;

    catch ME
        warning('Failed to process file %s: %s', batch_files{i}, ME.message);
    end
end

% Remove empty trials
batch_data.trials = batch_data.trials(~cellfun(@isempty, batch_data.trials));
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
        warning(ME.identifier, 'Failed to apply enhanced calculations: %s', ME.message);
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
% Load user preferences
try
    if exist('user_preferences.mat', 'file')
        prefs = load('user_preferences.mat');
        handles.preferences = prefs.preferences;
    end
catch
    handles.preferences = struct();
end
end

function applyUserPreferences(handles)
% Apply user preferences to UI
try
    % Set default number of trials to 2
    if isfield(handles, 'num_trials_edit')
        set(handles.num_trials_edit, 'String', '2');
    end

    % Set default execution mode to parallel (index 2)
    if isfield(handles, 'execution_mode_popup')
        set(handles.execution_mode_popup, 'Value', 2);
    end

    % Set default master dataset creation to enabled
    if isfield(handles, 'enable_master_dataset')
        set(handles.enable_master_dataset, 'Value', 1);
    end

    % Apply other preferences if they exist
    if isfield(handles, 'preferences')
        prefs = handles.preferences;

        % Apply any other saved preferences here
        if isfield(prefs, 'default_sim_time') && isfield(handles, 'sim_time_edit')
            set(handles.sim_time_edit, 'String', num2str(prefs.default_sim_time));
        end

        if isfield(prefs, 'default_sample_rate') && isfield(handles, 'sample_rate_edit')
            set(handles.sample_rate_edit, 'String', num2str(prefs.default_sample_rate));
        end

        if isfield(handles, 'enable_master_dataset') && isfield(prefs, 'enable_master_dataset')
            set(handles.enable_master_dataset, 'Value', prefs.enable_master_dataset);
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

% Check if already running
if isfield(handles, 'is_running') && handles.is_running
    msgbox('Generation is already running. Please wait for it to complete or use the Stop button.', 'Already Running', 'warn');
    return;
end

try
    % Set running state immediately
    handles.is_running = true;
    guidata(fig, handles);

    % Provide immediate visual feedback
    set(handles.play_pause_button, 'Enable', 'off', 'String', 'Running...');
    set(handles.stop_button, 'Enable', 'on');
    set(handles.status_text, 'String', 'Status: Starting generation...');
    set(handles.progress_text, 'String', 'Initializing...');
    drawnow; % Force immediate UI update

    % Validate inputs
    config = validateInputs(handles);
    if isempty(config)
        % Reset state on validation failure
        handles.is_running = false;
        set(handles.play_pause_button, 'Enable', 'on', 'String', 'Start');
        set(handles.stop_button, 'Enable', 'off');
        guidata(fig, handles);
        return;
    end

    % Store config
    handles.config = config;
    handles.should_stop = false;
    guidata(fig, handles);

    % Create script backup before starting generation
    backupScripts(handles);

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

    % Save only essential configuration data, not the entire handles structure
    config.input_file = get(handles.input_file_edit, 'String');
    config.output_folder = get(handles.output_folder_edit, 'String');
    config.folder_name = get(handles.folder_name_edit, 'String');
    config.num_trials = get(handles.num_trials_edit, 'String');
    config.sim_time = get(handles.sim_time_edit, 'String');
    config.sample_rate = get(handles.sample_rate_edit, 'String');
    config.use_logsout = get(handles.use_logsout, 'Value');
    config.model_path = handles.model_path;

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

        % Handle legacy config files that might contain the entire handles structure
        if isfield(config, 'config')
            config = config.config; % Extract from loaded structure
        end

        % Check if this is a legacy config file with handles structure
        if isfield(config, 'handles')
            warning('Legacy configuration file detected. This file contains the old format and may not load correctly. Please save a new configuration file.');
            % Try to extract any useful information from legacy format
            if isfield(config.handles, 'input_file_edit')
                try
                    input_file = get(config.handles.input_file_edit, 'String');
                    if ~isempty(input_file) && ~strcmp(input_file, 'No file selected')
                        set(handles.input_file_edit, 'String', input_file);
                    end
                catch
                    % Ignore if we can't extract this
                end
            end
            fprintf('Configuration loaded from %s (legacy format)\n', fullfile(pathname, filename));
            return;
        end

        % Restore configuration values to the GUI (new format)
        if isfield(config, 'input_file')
            set(handles.input_file_edit, 'String', config.input_file);
        end
        if isfield(config, 'output_folder')
            set(handles.output_folder_edit, 'String', config.output_folder);
        end
        if isfield(config, 'folder_name')
            set(handles.folder_name_edit, 'String', config.folder_name);
        end
        if isfield(config, 'num_trials')
            set(handles.num_trials_edit, 'String', config.num_trials);
        end
        if isfield(config, 'sim_time')
            set(handles.sim_time_edit, 'String', config.sim_time);
        end
        if isfield(config, 'sample_rate')
            set(handles.sample_rate_edit, 'String', config.sample_rate);
        end
        if isfield(config, 'use_logsout')
            set(handles.use_logsout, 'Value', config.use_logsout);
        end
        if isfield(config, 'model_path')
            handles.model_path = config.model_path;
        end

        % Update the handles structure
        guidata(gcbf, handles);

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
    'Callback', @autoUpdateSummary);

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
    'Callback', @updateCoefficientsPreview);

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
    'Callback', @autoUpdateSummary);

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
    'Callback', @autoUpdateSummary);

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
    'Callback', @updateCoefficientsPreview);

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

[filename, pathname] = uigetfile('*.mat', 'Select Input File');
if filename ~= 0
    set(handles.input_file_edit, 'String', fullfile(pathname, filename));
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
        set(handles.model_display, 'String', handles.model_name);
        guidata(handles.fig, handles);
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
        set(handles.model_display, 'String', handles.model_name);
        guidata(handles.fig, handles);
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
% Save user preferences to file
try
    preferences = struct();
    preferences.last_input_file_path = handles.selected_input_file;
    preferences.output_folder = get(handles.output_folder_edit, 'String');
    preferences.model_name = handles.model_name;

    if isfield(handles, 'enable_master_dataset')
        preferences.enable_master_dataset = get(handles.enable_master_dataset, 'Value');
    end

    save('user_preferences.mat', 'preferences');
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



% Extract coefficients from table
function coefficient_values = extractCoefficientsFromTable(handles)
try
    table_data = get(handles.coefficients_table, 'Data');

    if isempty(table_data)
        coefficient_values = [];
        return;
    end

    num_trials = size(table_data, 1);
    num_total_coeffs = size(table_data, 2) - 1;
    coefficient_values = zeros(num_trials, num_total_coeffs);

    for row = 1:num_trials
        for col = 2:(num_total_coeffs + 1)
            value_str = table_data{row, col};
            if ischar(value_str)
                coefficient_values(row, col-1) = str2double(value_str);
            else
                coefficient_values(row, col-1) = value_str;
            end
        end
    end

catch ME
    fprintf('Error extracting coefficients: %s\n', ME.message);
    coefficient_values = [];
end
end

% Run Generation Process
function runGeneration(handles)
try
    config = handles.config;

    % Ensure config has enhanced settings for maximum data extraction (1956 columns)
    config = ensureEnhancedConfig(config);

    % Extract coefficients from table
    config.coefficient_values = extractCoefficientsFromTable(handles);
    if isempty(config.coefficient_values)
        error('No coefficient values available');
    end

    % Create output directory
    if ~exist(config.output_folder, 'dir')
        mkdir(config.output_folder);
    end

    set(handles.status_text, 'String', 'Status: Running trials...');

    % Execute dataset generation
    execution_mode = get(handles.execution_mode_popup, 'Value');

    if execution_mode == 2 && license('test', 'Distrib_Computing_Toolbox')
        % Parallel execution
        successful_trials = runParallelSimulations(handles, config);
    else
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
        % Auto-detect optimal number of workers, but respect cluster limits
        max_cores = feature('numcores');

        % Check cluster limits
        try
            cluster = gcp('nocreate');
            if isempty(cluster)
                % Use local profile
                temp_cluster = parcluster('local');
                max_workers = temp_cluster.NumWorkers;
                fprintf('Using local profile with max %d workers\n', max_workers);
            else
                max_workers = cluster.NumWorkers;
            end
        catch
            max_workers = 6; % Default fallback
        end

        % Use the minimum of available cores and cluster limit
        num_workers = min(max_cores, max_workers);

        % Try to create the pool with timeout
        fprintf('Starting parallel pool with %d workers...\n', num_workers);

        % Start parallel pool with local profile
        parpool('local', num_workers);
        fprintf('Successfully started parallel pool with local profile (%d workers)\n', num_workers);
    end
catch ME
    warning(ME.identifier, 'Failed to start parallel pool: %s. Falling back to sequential execution.', ME.message);
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
            [~, result] = system('wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /Value');
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
% Get batch processing parameters
batch_size = config.batch_size;
save_interval = config.save_interval;
total_trials = config.num_simulations;

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

    % ENHANCED: Extract additional Simscape data if enabled
    if config.use_simscape && isfield(simOut, 'simlog') && ~isempty(simOut.simlog)
        fprintf('Extracting additional Simscape data...\n');
        simscape_data = extractSimscapeDataRecursive(simOut.simlog);

        if ~isempty(simscape_data) && width(simscape_data) > 1
            % Merge Simscape data with main data
            fprintf('Found %d additional Simscape columns\n', width(simscape_data) - 1);

            % Ensure both tables have the same number of rows
            if height(simscape_data) == height(data_table)
                % Merge tables
                data_table = [data_table, simscape_data(:, 2:end)]; % Skip time column (already exists)
                fprintf('Merged Simscape data: %d total columns\n', width(data_table));
            else
                fprintf('Warning: Row count mismatch - Simscape: %d, Main: %d\n', height(simscape_data), height(data_table));
            end
        else
            fprintf('No additional Simscape data found\n');
        end
    end

    if isempty(data_table)
        result.error = 'No data extracted from simulation';
        fprintf('No data extracted from simulation output\n');
        return;
    end

    fprintf('Extracted %d rows of data with %d total columns\n', height(data_table), width(data_table));

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
result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);

try
    % Create simulation input
    simIn = Simulink.SimulationInput(config.model_path);

    % Set model parameters
    simIn = setModelParameters(simIn, config);

    % Set polynomial coefficients for this trial
    try
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);
    catch ME
        fprintf('Warning: Could not set polynomial coefficients: %s\n', ME.message);
    end

    % Suppress specific warnings that are not critical
    warning_state = warning('off', 'Simulink:Bus:EditTimeBusPropNotAllowed');
    warning_state2 = warning('off', 'Simulink:Engine:BlockOutputNotUpdated');
    warning_state3 = warning('off', 'Simulink:Engine:OutputNotConnected');
    warning_state4 = warning('off', 'Simulink:Engine:InputNotConnected');
    warning_state5 = warning('off', 'Simulink:Blocks:UnconnectedOutputPort');
    warning_state6 = warning('off', 'Simulink:Blocks:UnconnectedInputPort');

    % Run simulation with progress indicator and visualization suppression
    fprintf('Running trial %d simulation...', trial_num);

    simOut = sim(simIn);
    fprintf(' Done.\n');

    % Restore warning state
    warning(warning_state);
    warning(warning_state2);
    warning(warning_state3);
    warning(warning_state4);
    warning(warning_state5);
    warning(warning_state6);

    % Process simulation output
    result = processSimulationOutput(trial_num, config, simOut, capture_workspace);

catch ME
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
            error('Simscape license not available. Please disable Simscape data extraction or obtain a Simscape license.');
        end

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
            rethrow(ME);
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
    warning(ME.identifier, 'Failed to create script backup: %s', ME.message);
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
    total_rows = sum(cellfun(@height, valid_tables));
    master_data = table();

    % Preallocate all columns in master table
    for col = 1:length(all_unique_columns)
        col_name = all_unique_columns{col};
        master_data.(col_name) = NaN(total_rows, 1);
    end

    % Fill master table efficiently
    current_row = 1;
    for i = 1:length(valid_tables)
        trial_data = valid_tables{i};
        num_rows = height(trial_data);

        % Copy data for all columns
        for col = 1:length(all_unique_columns)
            col_name = all_unique_columns{col};
            if ismember(col_name, trial_data.Properties.VariableNames)
                master_data.(col_name)(current_row:current_row+num_rows-1) = trial_data.(col_name);
            end
        end

        current_row = current_row + num_rows;
    end

    % Save master dataset
    master_file = fullfile(config.output_folder, 'master_dataset.csv');
    writetable(master_data, master_file);

    fprintf('Master dataset saved: %d rows, %d columns\n', height(master_data), width(master_data));
    if width(master_data) >= 1956
        fprintf('Target 1956 columns achieved: YES\n');
    else
        fprintf('Target 1956 columns achieved: NO\n');
    end

catch ME
    fprintf('Error compiling dataset: %s\n', ME.message);
    rethrow(ME);
end
end

function validateCoefficientBounds(handles, coeff_range)
% Enhanced signal extraction with comprehensive approach for 1956 columns
% This replaces the basic extractSignalsFromSimOut function

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

    % Initialize data collection with comprehensive approach
    all_data = {};
    extraction_methods = {};

    % Extract from CombinedSignalBus if enabled and available
    if options.extract_combined_bus && (isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus'))
        if options.verbose
            fprintf('Extracting from CombinedSignalBus...\n');
        end

        try
            combinedBus = simOut.CombinedSignalBus;
            if ~isempty(combinedBus)
                signal_bus_data = extractFromCombinedSignalBusEnhanced(combinedBus);

                if ~isempty(signal_bus_data)
                    all_data{end+1} = signal_bus_data;
                    extraction_methods{end+1} = 'CombinedSignalBus';
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
            logsout_data = extractLogsoutDataEnhanced(simOut.logsout);
            if ~isempty(logsout_data)
                all_data{end+1} = logsout_data;
                extraction_methods{end+1} = 'logsout';
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

            simscape_data = extractSimscapeDataEnhanced(simlog_data);
            if ~isempty(simscape_data)
                all_data{end+1} = simscape_data;
                extraction_methods{end+1} = 'simscape';
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

    % Try fallback extraction methods
    fallback_data = extractFallbackData(simOut, options);
    if ~isempty(fallback_data)
        all_data{end+1} = fallback_data;
        extraction_methods{end+1} = 'fallback';
        if options.verbose
            fprintf('Fallback: %d columns extracted\n', width(fallback_data));
        end
    end

    % Combine all data sources with enhanced merging
    if ~isempty(all_data)
        data_table = combineDataSourcesEnhanced(all_data, extraction_methods);
        signal_info.sources_found = length(all_data);
        signal_info.total_columns = width(data_table);
        signal_info.extraction_methods = extraction_methods;

        if options.verbose
            fprintf('Total columns extracted: %d (Target: 1956 per trial)\n', width(data_table));
            if width(data_table) >= 1956
                fprintf('✓ Target 1956 columns per trial ACHIEVED\n');
            else
                fprintf('✗ Target 1956 columns per trial MISSED (need %d more columns)\n', 1956 - width(data_table));
            end
        end
    else
        if options.verbose
            fprintf('Warning: No data extracted from any source\n');
        end
    end

catch ME
    if options.verbose
        fprintf('Error in extractSignalsFromSimOutEnhanced: %s\n', ME.message);
    end
    % Return empty results on error
    data_table = [];
    signal_info = struct();
end
end

% Enhanced CombinedSignalBus extraction
function data_table = extractFromCombinedSignalBusEnhanced(combinedBus)
data_table = [];

try
    % CombinedSignalBus should be a struct with time and signals
    if ~isstruct(combinedBus)
        return;
    end

    % Look for time field with enhanced detection
    bus_fields = fieldnames(combinedBus);
    time_field = '';
    time_data = [];

    % Enhanced time detection
    for i = 1:length(bus_fields)
        field_name = bus_fields{i};
        field_value = combinedBus.(field_name);

        % Check if this field contains time data
        if isstruct(field_value) && isfield(field_value, 'time')
            time_field = field_name;
            time_data = field_value.time(:);
            fprintf('Debug: Found time in %s.time (length: %d)\n', field_name, length(time_data));
            break;
        elseif isstruct(field_value) && isfield(field_value, 'Time')
            time_field = field_name;
            time_data = field_value.Time(:);
            fprintf('Debug: Found time in %s.Time (length: %d)\n', field_name, length(time_data));
            break;
        elseif contains(lower(field_name), 'time') && isnumeric(field_value)
            time_field = field_name;
            time_data = field_value(:);
            fprintf('Debug: Found time field: %s (length: %d)\n', field_name, length(time_data));
            break;
        end
    end

    % Enhanced signal extraction with comprehensive handling
    if ~isempty(time_data)
        data_cells = {time_data};
        var_names = {'time'};
        expected_length = length(time_data);

        fprintf('Debug: Starting enhanced data extraction with time vector length: %d\n', expected_length);

        % Process each field in the bus with enhanced extraction
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);

            if isstruct(field_value)
                % This field contains sub-signals
                sub_fields = fieldnames(field_value);

                for j = 1:length(sub_fields)
                    sub_field_name = sub_fields{j};
                    signal_data = field_value.(sub_field_name);

                    % Enhanced numeric data extraction
                    numeric_data = extractNumericDataEnhanced(signal_data);

                    % Add the data with comprehensive handling
                    if ~isempty(numeric_data)
                        data_size = size(numeric_data);
                        num_elements = numel(numeric_data);

                        if size(numeric_data, 1) == expected_length
                            % TIME SERIES DATA - matches expected length
                            if size(numeric_data, 2) == 1
                                % Single column time series
                                data_cells{end+1} = numeric_data(:);
                                var_names{end+1} = sprintf('%s_%s', field_name, sub_field_name);
                            elseif size(numeric_data, 2) > 1
                                % Multi-column time series
                                for col = 1:size(numeric_data, 2)
                                    data_cells{end+1} = numeric_data(:, col);
                                    var_names{end+1} = sprintf('%s_%s_%d', field_name, sub_field_name, col);
                                end
                            end
                        elseif num_elements == 3
                            % 3D VECTOR (e.g., COM position [x, y, z])
                            vector_data = numeric_data(:);
                            for dim = 1:3
                                replicated_data = repmat(vector_data(dim), expected_length, 1);
                                data_cells{end+1} = replicated_data;
                                dim_labels = {'x', 'y', 'z'};
                                var_names{end+1} = sprintf('%s_%s_%s', field_name, sub_field_name, dim_labels{dim});
                            end
                        elseif num_elements == 9
                            % 3x3 MATRIX (e.g., inertia matrix)
                            if isequal(data_size, [3, 3])
                                matrix_data = repmat(numeric_data, [1, 1, expected_length]);
                            else
                                matrix_data = reshape(numeric_data, 3, 3);
                                matrix_data = repmat(matrix_data, [1, 1, expected_length]);
                            end

                            n_steps = size(matrix_data,3);
                            flat_matrix = reshape(permute(matrix_data, [3 1 2]), n_steps, 9);
                            for idx = 1:9
                                [row, col] = ind2sub([3,3], idx);
                                data_cells{end+1} = flat_matrix(:,idx);
                                var_names{end+1} = sprintf('%s_%s_I%d%d', field_name, sub_field_name, row, col);
                            end
                        elseif num_elements == 1
                            % 1 ELEMENT DATA (scalar constants)
                            scalar_value = numeric_data(1);
                            replicated_data = repmat(scalar_value, expected_length, 1);
                            data_cells{end+1} = replicated_data;
                            var_names{end+1} = sprintf('%s_%s', field_name, sub_field_name);
                        elseif num_elements == 6
                            % 6 ELEMENT DATA (e.g., 6DOF pose/twist)
                            vector_data = numeric_data(:);
                            for dim = 1:6
                                replicated_data = repmat(vector_data(dim), expected_length, 1);
                                data_cells{end+1} = replicated_data;
                                var_names{end+1} = sprintf('%s_%s_dof%d', field_name, sub_field_name, dim);
                            end
                        elseif ndims(numeric_data) == 3 && all(size(numeric_data,1:2) == [3 1])
                            % Handle 3x1xN time series (3D vectors over time)
                            n_steps = size(numeric_data,3);
                            if n_steps == expected_length
                                for dim = 1:3
                                    data_cells{end+1} = squeeze(numeric_data(dim, 1, :));
                                    var_names{end+1} = sprintf('%s_%s_dim%d', field_name, sub_field_name, dim);
                                end
                            end
                        elseif ndims(numeric_data) == 3 && all(size(numeric_data,1:2) == [3 3])
                            % Handle 3x3xN time series (e.g., inertia over time)
                            n_steps = size(numeric_data,3);
                            if n_steps == expected_length
                                flat_matrix = reshape(permute(numeric_data, [3 1 2]), n_steps, 9);
                                for idx = 1:9
                                    [row, col] = ind2sub([3,3], idx);
                                    data_cells{end+1} = flat_matrix(:,idx);
                                    var_names{end+1} = sprintf('%s_%s_I%d%d', field_name, sub_field_name, row, col);
                                end
                            end
                        end
                    end
                end
            elseif isnumeric(field_value) && length(field_value) == expected_length
                % Direct numeric field
                data_cells{end+1} = field_value(:);
                var_names{end+1} = field_name;
            end
        end

        % Create table if we have data
        if length(data_cells) > 1
            data_table = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created enhanced CombinedSignalBus table with %d columns, %d rows\n', width(data_table), height(data_table));
        end
    end

catch ME
    fprintf('Error extracting enhanced CombinedSignalBus data: %s\n', ME.message);
end
end

% Enhanced numeric data extraction
function numeric_data = extractNumericDataEnhanced(signal_data)
numeric_data = [];

try
    if isa(signal_data, 'timeseries')
        numeric_data = signal_data.Data;
    elseif isstruct(signal_data) && isfield(signal_data, 'Data')
        numeric_data = signal_data.Data;
    elseif isstruct(signal_data) && isfield(signal_data, 'Values')
        numeric_data = signal_data.Values;
    elseif isnumeric(signal_data)
        numeric_data = signal_data;
    elseif isstruct(signal_data) && isfield(signal_data, 'time')
        % Handle nested time series structures
        if isfield(signal_data, 'data')
            numeric_data = signal_data.data;
        elseif isfield(signal_data, 'Data')
            numeric_data = signal_data.Data;
        end
    end
catch ME
    fprintf('Warning: Could not extract numeric data: %s\n', ME.message);
end
end

% Enhanced logsout extraction
function logsout_data = extractLogsoutDataEnhanced(logsout)
logsout_data = [];

try
    % Use the existing function but with enhanced error handling
    logsout_data = extractLogsoutDataFixed(logsout);

    % Add additional extraction if the basic method didn't get enough data
    if isempty(logsout_data) || width(logsout_data) < 1000
        fprintf('Debug: Basic logsout extraction insufficient, trying enhanced method...\n');
        % Add fallback extraction logic here if needed
    end
catch ME
    fprintf('Error in enhanced logsout extraction: %s\n', ME.message);
end
end

% Enhanced Simscape extraction
function simscape_data = extractSimscapeDataEnhanced(simlog_data)
simscape_data = [];

try
    % Use the existing function but with enhanced error handling
    simscape_data = extractSimscapeDataRecursive(simlog_data);

    % Add additional extraction if the basic method didn't get enough data
    if isempty(simscape_data) || width(simscape_data) < 500
        fprintf('Debug: Basic Simscape extraction insufficient, trying enhanced method...\n');
        % Add fallback extraction logic here if needed
    end
catch ME
    fprintf('Error in enhanced Simscape extraction: %s\n', ME.message);
end
end

% Fallback data extraction
function fallback_data = extractFallbackData(simOut, options)
fallback_data = [];

try
    % Try to extract any remaining data that might have been missed
    if options.verbose
        fprintf('Attempting fallback data extraction...\n');
    end

    % Check for any other data sources that might contain signals
    simOut_fields = fieldnames(simOut);
    for i = 1:length(simOut_fields)
        field_name = simOut_fields{i};
        field_value = simOut.(field_name);

        % Skip already processed fields
        if ismember(field_name, {'CombinedSignalBus', 'logsout', 'simlog'})
            continue;
        end

        % Try to extract data from other fields
        if isstruct(field_value) && ~isempty(field_value)
            try
                extracted = extractFromNestedStruct(field_value);
                if ~isempty(extracted)
                    fallback_data = [fallback_data, extracted];
                    if options.verbose
                        fprintf('Fallback: Extracted %d columns from %s\n', width(extracted), field_name);
                    end
                end
            catch
                % Continue to next field
            end
        end
    end
catch ME
    fprintf('Error in fallback data extraction: %s\n', ME.message);
end
end

% Enhanced data source combination
function combined_table = combineDataSourcesEnhanced(data_sources, extraction_methods)
combined_table = [];

try
    if isempty(data_sources)
        return;
    end

    % Start with the first data source
    combined_table = data_sources{1};

    % Merge additional data sources with enhanced error handling
    for i = 2:length(data_sources)
        if ~isempty(data_sources{i})
            try
                % Find common time column
                if ismember('time', combined_table.Properties.VariableNames) && ...
                        ismember('time', data_sources{i}.Properties.VariableNames)

                    % Merge on time column
                    combined_table = outerjoin(combined_table, data_sources{i}, 'Keys', 'time', 'MergeKeys', true);
                else
                    % Robust fallback for edge cases without time columns
                    common_vars = intersect(combined_table.Properties.VariableNames, ...
                        data_sources{i}.Properties.VariableNames);
                    if ~isempty(common_vars)
                        combined_table = [combined_table(:, common_vars); data_sources{i}(:, common_vars)];
                    else
                        % Add as new columns if no common variables
                        combined_table = [combined_table, data_sources{i}];
                    end
                end

                fprintf('Debug: Combined %s data: %d total columns\n', extraction_methods{i}, width(combined_table));
            catch ME
                fprintf('Warning: Could not combine %s data: %s\n', extraction_methods{i}, ME.message);
            end
        end
    end

catch ME
    fprintf('Error combining enhanced data sources: %s\n', ME.message);
end
end

% Helper function to extract from nested structs
function extracted_data = extractFromNestedStruct(struct_data)
extracted_data = [];

try
    if ~isstruct(struct_data)
        return;
    end

    fields = fieldnames(struct_data);
    data_cells = {};
    var_names = {};

    for i = 1:length(fields)
        field_name = fields{i};
        field_value = struct_data.(field_name);

        if isnumeric(field_value)
            data_cells{end+1} = field_value(:);
            var_names{end+1} = field_name;
        elseif isstruct(field_value)
            % Recursively extract from nested structs
            nested_data = extractFromNestedStruct(field_value);
            if ~isempty(nested_data)
                for j = 1:width(nested_data)
                    data_cells{end+1} = nested_data.(nested_data.Properties.VariableNames{j});
                    var_names{end+1} = sprintf('%s_%s', field_name, nested_data.Properties.VariableNames{j});
                end
            end
        end
    end

    if ~isempty(data_cells)
        extracted_data = table(data_cells{:}, 'VariableNames', var_names);
    end
catch ME
    fprintf('Error extracting from nested struct: %s\n', ME.message);
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
