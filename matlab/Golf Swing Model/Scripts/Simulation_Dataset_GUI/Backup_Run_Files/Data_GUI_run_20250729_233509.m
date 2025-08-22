% GOLF SWING DATA GENERATION RUN RECORD
% Generated: 2025-07-29 23:35:09
% This file contains the exact script and settings used for this data generation run
%
% =================================================================
% RUN CONFIGURATION SETTINGS
% =================================================================
%
% SIMULATION PARAMETERS:
% Number of trials: 2
% Simulation time: 0.300 seconds
% Sample rate: 100.0 Hz
%
% TORQUE CONFIGURATION:
% Torque scenario: Variable Torque
% Coefficient range: 50.000
%
% MODEL INFORMATION:
% Model name: GolfSwing3D_Kinetic
% Model path: Model/GolfSwing3D_Kinetic.slx
%
% DATA SOURCES ENABLED:
% CombinedSignalBus: enabled
% Logsout Dataset: enabled
% Simscape Results: enabled
%
% OUTPUT SETTINGS:
% Output folder: C:\Users\diete\Golf_Model\Golf Swing Model\Scripts\Simulation_Dataset_GUI\golf_swing_dataset_20250729
% File format: CSV Files
%
% SYSTEM INFORMATION:
% MATLAB version: 25.1.0.2943329 (R2025a)
% Computer: PCWIN64
% Hostname: DeskComputer
%
% POLYNOMIAL COEFFICIENTS:
% Coefficient matrix size: 2 trials x 189 coefficients
% First trial coefficients (first 10): -25.540, 42.090, 42.620, -19.010, -42.350, 28.090, -36.930, -3.850, -5.980, 10.500
%
% =================================================================
% END OF CONFIGURATION - ORIGINAL SCRIPT FOLLOWS
% =================================================================

function Data_GUI()
    % GolfSwingDataGenerator - Modern GUI for generating golf swing training data
    % Fixed polynomial order: At^6 + Bt^5 + Ct^4 + Dt^3 + Et^2 + Ft + G

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

    % Create main figure
    screenSize = get(0, 'ScreenSize');
    figWidth = min(1600, screenSize(3) * 0.85);
    figHeight = min(900, screenSize(4) * 0.85);

    fig = figure('Name', 'Golf Swing Data Generator', ...
                 'Position', [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'Color', colors.background, ...
                 'CloseRequestFcn', @closeGUICallback);

    % Initialize handles structure with preferences
    handles = struct();
    handles.should_stop = false;
    handles.fig = fig;
    handles.colors = colors;
    handles.preferences = struct(); % Initialize empty preferences

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
    % Create main layout with professional design
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
              'String', 'Golf Swing Data Generator', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.2, 0.96, 0.6], ...
              'FontSize', 14, ...
              'FontWeight', 'normal', ...
              'ForegroundColor', 'white', ...
              'BackgroundColor', colors.primary, ...
              'HorizontalAlignment', 'left');

    % Version text
    uicontrol('Parent', titlePanel, ...
              'Style', 'text', ...
              'String', 'v2.0', ...
              'Units', 'normalized', ...
              'Position', [0.85, 0.2, 0.13, 0.6], ...
              'FontSize', 10, ...
              'ForegroundColor', [0.9, 0.9, 0.9], ...
              'BackgroundColor', colors.primary, ...
              'HorizontalAlignment', 'right');

    % Content area
    contentTop = 1 - titleHeight - 0.01;
    contentPanel = uipanel('Parent', mainPanel, ...
                          'Units', 'normalized', ...
                          'Position', [0.01, 0.01, 0.98, contentTop - 0.01], ...
                          'BorderType', 'none', ...
                          'BackgroundColor', colors.background);

    % Two columns
    columnPadding = 0.01;
    columnWidth = (1 - 3*columnPadding) / 2;

    leftPanel = uipanel('Parent', contentPanel, ...
                       'Units', 'normalized', ...
                       'Position', [columnPadding, columnPadding, columnWidth, 1-2*columnPadding], ...
                       'BackgroundColor', colors.panel, ...
                       'BorderType', 'line', ...
                       'BorderWidth', 0.5, ...
                       'HighlightColor', colors.border);

    rightPanel = uipanel('Parent', contentPanel, ...
                        'Units', 'normalized', ...
                        'Position', [2*columnPadding + columnWidth, columnPadding, columnWidth, 1-2*columnPadding], ...
                        'BackgroundColor', colors.panel, ...
                        'BorderType', 'line', ...
                        'BorderWidth', 0.5, ...
                        'HighlightColor', colors.border);

    % Store panel references
    handles.leftPanel = leftPanel;
    handles.rightPanel = rightPanel;

    % Create content
    handles = createLeftColumnContent(leftPanel, handles);
    handles = createRightColumnContent(rightPanel, handles);
end
function handles = createLeftColumnContent(parent, handles)
    % Create left column panels
    panelSpacing = 0.015;
    panelPadding = 0.01;

    % Calculate heights
    numPanels = 4;
    totalSpacing = panelPadding + (numPanels-1)*panelSpacing + panelPadding;
    availableHeight = 1 - totalSpacing;

    h1 = 0.28 * availableHeight;  % Increased from 0.22 to provide more space for Simulink model selection
    h2 = 0.20 * availableHeight;
    h3 = 0.33 * availableHeight;
    h4 = 0.19 * availableHeight;  % Reduced from 0.25 to compensate for h1 increase

    % Calculate positions
    y4 = panelPadding;
    y3 = y4 + h4 + panelSpacing;
    y2 = y3 + h3 + panelSpacing;
    y1 = y2 + h2 + panelSpacing;

    % Create panels
    handles = createTrialAndDataPanel(parent, handles, y1, h1);
    handles = createModelingPanel(parent, handles, y2, h2);
    handles = createJointEditorPanel(parent, handles, y3, h3);
    handles = createOutputPanel(parent, handles, y4, h4);
end
function handles = createRightColumnContent(parent, handles)
    % Create right column panels
    panelSpacing = 0.015;
    panelPadding = 0.01;

    % Calculate heights
    numPanels = 4;
    totalSpacing = panelPadding + (numPanels-1)*panelSpacing + panelPadding;
    availableHeight = 1 - totalSpacing;

    h1 = 0.40 * availableHeight;
    h2 = 0.30 * availableHeight;
    h3 = 0.15 * availableHeight;
    h4 = 0.15 * availableHeight;

    % Calculate positions
    y4 = panelPadding;
    y3 = y4 + h4 + panelSpacing;
    y2 = y3 + h3 + panelSpacing;
    y1 = y2 + h2 + panelSpacing;

    % Create panels
    handles = createPreviewPanel(parent, handles, y1, h1);
    handles = createCoefficientsPanel(parent, handles, y2, h2);
    handles = createProgressPanel(parent, handles, y3, h3);
    handles = createControlPanel(parent, handles, y4, h4);
end
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
    rowHeight = 0.15;
    labelWidth = 0.22;
    fieldSpacing = 0.02;
    y = 0.80;

    % Starting Point File
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Starting Point:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, labelWidth, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'normal', ...
              'BackgroundColor', colors.panel);

    handles.input_file_edit = uicontrol('Parent', panel, ...
                                       'Style', 'edit', ...
                                       'String', 'No file selected', ...
                                       'Units', 'normalized', ...
                                       'Position', [labelWidth + fieldSpacing, y, 0.48, rowHeight], ...
                                       'Enable', 'inactive', ...
                                       'BackgroundColor', [0.97, 0.97, 0.97], ...
                                       'FontSize', 9);

    handles.browse_input_btn = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Browse', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.72, y, 0.12, rowHeight], ...
                                        'BackgroundColor', colors.secondary, ...
                                        'ForegroundColor', 'white', ...
                                        'Callback', @browseInputFile);

    handles.clear_input_btn = uicontrol('Parent', panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Clear', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.85, y, 0.08, rowHeight], ...
                                       'BackgroundColor', colors.danger, ...
                                       'ForegroundColor', 'white', ...
                                       'Callback', @clearInputFile);



    % Trial Parameters
    y = y - 0.20;
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Trials:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, 0.08, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.num_trials_edit = uicontrol('Parent', panel, ...
                                       'Style', 'edit', ...
                                       'String', '10', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.11, y, 0.08, rowHeight], ...
                                       'BackgroundColor', 'white', ...
                                       'HorizontalAlignment', 'center', ...
                                       'Callback', @updateCoefficientsPreview);

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Duration:', ...
              'Units', 'normalized', ...
              'Position', [0.21, y, 0.10, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.sim_time_edit = uicontrol('Parent', panel, ...
                                     'Style', 'edit', ...
                                     'String', '0.3', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.32, y, 0.08, rowHeight], ...
                                     'BackgroundColor', 'white', ...
                                     'HorizontalAlignment', 'center');

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 's', ...
              'Units', 'normalized', ...
              'Position', [0.41, y, 0.02, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Rate:', ...
              'Units', 'normalized', ...
              'Position', [0.46, y, 0.06, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.sample_rate_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', '100', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.53, y, 0.08, rowHeight], ...
                                        'BackgroundColor', 'white', ...
                                        'HorizontalAlignment', 'center');

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Hz', ...
              'Units', 'normalized', ...
              'Position', [0.62, y, 0.03, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Mode:', ...
              'Units', 'normalized', ...
              'Position', [0.68, y, 0.06, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    % Check if parallel computing toolbox is available
    if license('test', 'Distrib_Computing_Toolbox')
        mode_options = {'Sequential', 'Parallel'};
    else
        mode_options = {'Sequential', 'Parallel (Toolbox Required)'};
    end

    handles.execution_mode_popup = uicontrol('Parent', panel, ...
                                            'Style', 'popupmenu', ...
                                            'String', mode_options, ...
                                            'Units', 'normalized', ...
                                            'Position', [0.75, y, 0.18, rowHeight], ...
                                            'BackgroundColor', 'white');

    % Data Sources
    y = y - 0.25;
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Data Sources:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, 0.15, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.use_signal_bus = uicontrol('Parent', panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'CombinedSignalBus', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.18, y, 0.25, rowHeight], ...
                                      'Value', 1, ...
                                      'BackgroundColor', colors.panel);

    handles.use_logsout = uicontrol('Parent', panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Logsout Dataset', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.44, y, 0.25, rowHeight], ...
                                   'Value', 1, ...
                                   'BackgroundColor', colors.panel);

    handles.use_simscape = uicontrol('Parent', panel, ...
                                    'Style', 'checkbox', ...
                                    'String', 'Simscape Results', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.70, y, 0.25, rowHeight], ...
                                    'Value', 1, ...
                                    'BackgroundColor', colors.panel);

    % Animation Option
    y = y - 0.20;
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Animation:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, 0.15, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.enable_animation = uicontrol('Parent', panel, ...
                                        'Style', 'checkbox', ...
                                        'String', 'Enable Animation (slower)', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.18, y, 0.35, rowHeight], ...
                                        'Value', 0, ...
                                        'BackgroundColor', colors.panel);

    % Model Selection
    y = y - 0.20;
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Simulink Model:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, 0.18, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.model_display = uicontrol('Parent', panel, ...
                                     'Style', 'text', ...
                                     'String', 'GolfSwing3D_Kinetic', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.21, y, 0.48, rowHeight], ...
                                     'HorizontalAlignment', 'center', ...
                                     'BackgroundColor', [0.97, 0.97, 0.97], ...
                                     'ForegroundColor', colors.text);

    handles.model_browse_btn = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Select Model', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.71, y, 0.22, rowHeight], ...
                                        'BackgroundColor', colors.secondary, ...
                                        'ForegroundColor', 'white', ...
                                        'Callback', @selectSimulinkModel);

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
function handles = createModelingPanel(parent, handles, yPos, height)
    % Torque Modeling Panel
    colors = handles.colors;

    panel = uipanel('Parent', parent, ...
                   'Title', 'Torque Modeling', ...
                   'FontSize', 10, ...
                   'FontWeight', 'normal', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', colors.panel, ...
                   'ForegroundColor', colors.text);

    rowHeight = 0.18;
    labelWidth = 0.25;
    y = 0.65;

    % Torque Scenario
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
                                             'Position', [labelWidth + 0.02, y, 0.35, rowHeight], ...
                                             'BackgroundColor', 'white', ...
                                             'Callback', @torqueScenarioCallback);

    % Parameters
    y = y - 0.35;
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
                                        'Position', [labelWidth + 0.02, y, 0.15, rowHeight], ...
                                        'BackgroundColor', 'white', ...
                                        'HorizontalAlignment', 'center', ...
                                        'Callback', @updateCoefficientsPreview);

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Constant Value (G):', ...
              'Units', 'normalized', ...
              'Position', [0.50, y, labelWidth, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.constant_value_edit = uicontrol('Parent', panel, ...
                                           'Style', 'edit', ...
                                           'String', '10', ...
                                           'Units', 'normalized', ...
                                           'Position', [0.75, y, 0.15, rowHeight], ...
                                           'BackgroundColor', 'white', ...
                                           'HorizontalAlignment', 'center', ...
                                           'Enable', 'off', ...
                                           'Callback', @updateCoefficientsPreview);
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

    % Selection row
    y = 0.80;
    rowHeight = 0.12;

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
                                      'Position', [0.10, y, 0.35, rowHeight], ...
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
                                             'Position', [0.58, y, 0.20, rowHeight], ...
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
                                         'Position', [0.87, y, 0.08, rowHeight], ...
                                         'BackgroundColor', 'white', ...
                                         'HorizontalAlignment', 'center', ...
                                         'Enable', 'off');

    % Coefficient edit boxes
    y = 0.48;
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
                  'Position', [xPos, y+0.08, coeffWidth, 0.08], ...
                  'FontWeight', 'normal', ...
                  'FontSize', 9, ...
                  'ForegroundColor', labelColor, ...
                  'BackgroundColor', colors.panel, ...
                  'HorizontalAlignment', 'center');

        handles.joint_coeff_edits(i) = uicontrol('Parent', panel, ...
                                                'Style', 'edit', ...
                                                'String', '0.00', ...
                                                'Units', 'normalized', ...
                                                'Position', [xPos, y, coeffWidth, 0.10], ...
                                                'BackgroundColor', 'white', ...
                                                'HorizontalAlignment', 'center', ...
                                                'Callback', @validateCoefficientInput);
    end

    % Action buttons
    y = 0.22;
    buttonHeight = 0.12;

    handles.apply_joint_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Apply to Table', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.02, y, 0.22, buttonHeight], ...
                                          'BackgroundColor', colors.success, ...
                                          'ForegroundColor', 'white', ...
                                          'Callback', @applyJointToTable);

    handles.load_joint_button = uicontrol('Parent', panel, ...
                                         'Style', 'pushbutton', ...
                                         'String', 'Load from Table', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.26, y, 0.22, buttonHeight], ...
                                         'BackgroundColor', colors.warning, ...
                                         'ForegroundColor', 'white', ...
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

    % Equation display - FIXED POLYNOMIAL ORDER
    handles.equation_display = uicontrol('Parent', panel, ...
                                       'Style', 'text', ...
                                       'String', 'τ(t) = At⁶ + Bt⁵ + Ct⁴ + Dt³ + Et² + Ft + G', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.02, 0.02, 0.96, 0.12], ...
                                       'FontSize', 11, ...
                                       'FontWeight', 'normal', ...
                                       'ForegroundColor', colors.primary, ...
                                       'BackgroundColor', [0.98, 0.98, 1], ...
                                       'HorizontalAlignment', 'center');

    handles.param_info = param_info;
end
function handles = createOutputPanel(parent, handles, yPos, height)
    % Output Settings Panel
    colors = handles.colors;

    panel = uipanel('Parent', parent, ...
                   'Title', 'Output Settings', ...
                   'FontSize', 10, ...
                   'FontWeight', 'normal', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', colors.panel, ...
                   'ForegroundColor', colors.text);

    rowHeight = 0.20;
    y = 0.65;

    % Output folder
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, 0.15, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.output_folder_edit = uicontrol('Parent', panel, ...
                                          'Style', 'edit', ...
                                          'String', pwd, ...
                                          'Units', 'normalized', ...
                                          'Position', [0.18, y, 0.60, rowHeight], ...
                                          'BackgroundColor', 'white', ...
                                          'FontSize', 9);

    handles.browse_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Browse', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.80, y, 0.16, rowHeight], ...
                                     'BackgroundColor', colors.secondary, ...
                                     'ForegroundColor', 'white', ...
                                     'Callback', @browseOutputFolder);

    % Dataset name
    y = 0.30;
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Dataset Name:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y, 0.15, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.folder_name_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', sprintf('golf_swing_dataset_%s', datestr(now, 'yyyymmdd')), ...
                                        'Units', 'normalized', ...
                                        'Position', [0.18, y, 0.35, rowHeight], ...
                                        'BackgroundColor', 'white', ...
                                        'FontSize', 9);

    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Format:', ...
              'Units', 'normalized', ...
              'Position', [0.56, y, 0.08, rowHeight], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', colors.panel);

    handles.format_popup = uicontrol('Parent', panel, ...
                                    'Style', 'popupmenu', ...
                                    'String', {'CSV Files', 'MAT Files', 'Both CSV and MAT'}, ...
                                    'Units', 'normalized', ...
                                    'Position', [0.65, y, 0.31, rowHeight], ...
                                    'BackgroundColor', 'white');
end
function handles = createPreviewPanel(parent, handles, yPos, height)
    % Parameters Preview Panel
    colors = handles.colors;

    panel = uipanel('Parent', parent, ...
                   'Title', 'Parameters Preview', ...
                   'FontSize', 10, ...
                   'FontWeight', 'normal', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', colors.panel, ...
                   'ForegroundColor', colors.text);

    % Update button
    handles.update_preview_button = uicontrol('Parent', panel, ...
                                             'Style', 'pushbutton', ...
                                             'String', 'Update Preview', ...
                                             'Units', 'normalized', ...
                                             'Position', [0.02, 0.88, 0.25, 0.10], ...
                                             'BackgroundColor', colors.success, ...
                                             'ForegroundColor', 'white', ...
                                             'Callback', @updatePreview);

    % Preview table
    handles.preview_table = uitable('Parent', panel, ...
                                   'Units', 'normalized', ...
                                   'Position', [0.02, 0.05, 0.96, 0.80], ...
                                   'ColumnName', {'Parameter', 'Value', 'Description'}, ...
                                   'ColumnWidth', {150, 150, 'auto'}, ...
                                   'RowStriping', 'on', ...
                                   'FontSize', 9);
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
                                           'BackgroundColor', colors.danger, ...
                                           'ForegroundColor', 'white', ...
                                           'Callback', @clearSearch);

    % Control buttons
    buttonY = 0.76;
    buttonHeight = 0.09;
    buttonWidth = 0.13;
    buttonSpacing = 0.01;

    % Button configuration
    buttons = {
        {'Reset', 'reset_coeffs', colors.danger, @resetCoefficientsToGenerated},
        {'Apply Row', 'apply_row', colors.primary, @applyRowToAll},
        {'Export', 'export', colors.success, @exportCoefficientsToCSV},
        {'Import', 'import', colors.warning, @importCoefficientsFromCSV},
        {'Save Set', 'save_scenario', colors.secondary, @saveScenario},
        {'Load Set', 'load_scenario', colors.secondary, @loadScenario}
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
                                      'ForegroundColor', 'white', ...
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
                                        'Position', [0.02, 0.05, 0.96, 0.68], ...
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
function handles = createProgressPanel(parent, handles, yPos, height)
    % Progress Panel
    colors = handles.colors;

    panel = uipanel('Parent', parent, ...
                   'Title', 'Progress', ...
                   'FontSize', 10, ...
                   'FontWeight', 'normal', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', colors.panel, ...
                   'ForegroundColor', colors.text);

    % Progress text
    handles.progress_text = uicontrol('Parent', panel, ...
                                     'Style', 'text', ...
                                     'String', 'Ready to start generation...', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.02, 0.55, 0.96, 0.35], ...
                                     'FontWeight', 'normal', ...
                                     'FontSize', 10, ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', colors.panel);

    % Status
    handles.status_text = uicontrol('Parent', panel, ...
                                   'Style', 'text', ...
                                   'String', 'Status: Ready', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.02, 0.15, 0.96, 0.35], ...
                                   'HorizontalAlignment', 'left', ...
                                   'BackgroundColor', [0.97, 0.97, 0.97], ...
                                   'ForegroundColor', colors.success, ...
                                   'FontSize', 9);
end
function handles = createControlPanel(parent, handles, yPos, height)
    % Control Buttons Panel
    colors = handles.colors;

    panel = uipanel('Parent', parent, ...
                   'Title', 'Controls', ...
                   'FontSize', 10, ...
                   'FontWeight', 'normal', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', colors.panel, ...
                   'ForegroundColor', colors.text);

    % Main control buttons
    buttonY = 0.25;
    buttonHeight = 0.50;

    handles.start_button = uicontrol('Parent', panel, ...
                                    'Style', 'pushbutton', ...
                                    'String', 'START', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.02, buttonY, 0.20, buttonHeight], ...
                                    'BackgroundColor', colors.success, ...
                                    'ForegroundColor', 'white', ...
                                    'FontSize', 11, ...
                                    'Callback', @startGeneration);

    handles.stop_button = uicontrol('Parent', panel, ...
                                   'Style', 'pushbutton', ...
                                   'String', 'STOP', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.24, buttonY, 0.15, buttonHeight], ...
                                   'BackgroundColor', colors.danger, ...
                                   'ForegroundColor', 'white', ...
                                   'FontSize', 11, ...
                                   'Enable', 'off', ...
                                   'Callback', @stopGeneration);

    % Utility buttons
    handles.validate_button = uicontrol('Parent', panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Validate', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.42, buttonY, 0.15, buttonHeight], ...
                                       'BackgroundColor', colors.primary, ...
                                       'ForegroundColor', 'white', ...
                                       'Callback', @validateSettings);

    handles.save_config_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Save', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.59, buttonY, 0.13, buttonHeight], ...
                                          'BackgroundColor', colors.secondary, ...
                                          'ForegroundColor', 'white', ...
                                          'Callback', @saveConfiguration);

    handles.load_config_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Load', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.74, buttonY, 0.13, buttonHeight], ...
                                          'BackgroundColor', colors.secondary, ...
                                          'ForegroundColor', 'white', ...
                                          'Callback', @loadConfiguration);
end
% ==================== CALLBACK FUNCTIONS ====================
function torqueScenarioCallback(src, ~)
    handles = guidata(gcbf);
    scenario_idx = get(src, 'Value');

    % Enable/disable controls
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

    updatePreview([], [], gcbf);
    updateCoefficientsPreview([], [], gcbf);
    guidata(handles.fig, handles);
end
function browseOutputFolder(src, ~)
    handles = guidata(gcbf);
    folder = uigetdir(get(handles.output_folder_edit, 'String'), 'Select Output Folder');
    if folder ~= 0
        set(handles.output_folder_edit, 'String', folder);
        updatePreview([], [], gcbf);
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
            constant_value = str2double(get(handles.constant_value_edit, 'String'));
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
        display_trials = min(num_trials, 100); % Limit for display only
        % Use actual num_trials for simulation, display_trials for preview

        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));

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
% [All other callback functions remain the same as in the original code...]
% Start Generation
function startGeneration(src, evt)
    handles = guidata(gcbf);

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

        % Store config
        handles.config = config;
        guidata(handles.fig, handles);

        % Update status
        set(handles.status_text, 'String', 'Status: Starting generation...');
        set(handles.progress_text, 'String', 'Initializing simulation...');
        drawnow;

        % Start generation
        runGeneration(handles);

    catch ME
        try
            set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
            set(handles.start_button, 'Enable', 'on');
            set(handles.stop_button, 'Enable', 'off');
        catch
            % GUI might be destroyed, ignore the error
        end
        errordlg(ME.message, 'Generation Failed');
    end
end
% Stop Generation
function stopGeneration(src, evt)
    handles = guidata(gcbf);
    handles.should_stop = true;
    guidata(handles.fig, handles);
    set(handles.status_text, 'String', 'Status: Stopping...');
    set(handles.progress_text, 'String', 'Generation stopped by user');
end
% Browse Input File
function browseInputFile(src, evt)
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
% Clear Input File
function clearInputFile(src, evt)
    handles = guidata(gcbf);
    handles.selected_input_file = '';
    set(handles.input_file_edit, 'String', 'No file selected');

    % Clear saved preference
    if isfield(handles, 'preferences')
        handles.preferences.last_input_file = '';
        handles.preferences.last_input_file_path = '';
        saveUserPreferences(handles);
    end

    guidata(handles.fig, handles);
end
% Select Simulink Model
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
% Update Joint Coefficients
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
% Update Trial Selection Mode
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
% Validate Coefficient Input
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
% Apply Joint to Table
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
% Load Joint from Table
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
% Reset Coefficients
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
% Coefficient Cell Edit Callback
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
% Apply Row to All
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
% Export Coefficients to CSV
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
% Import Coefficients from CSV
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
% Save/Load Scenario
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
            scenario.settings.constant_value = str2double(get(handles.constant_value_edit, 'String'));

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
            set(handles.constant_value_edit, 'String', num2str(scenario.settings.constant_value));

            % Trigger scenario callback
            torqueScenarioCallback(handles.torque_scenario_popup, []);

            msgbox(['Loaded scenario: ' scenario.name], 'Success');
        catch ME
            msgbox(['Error loading scenario: ' ME.message], 'Error', 'error');
        end
    end
end
% Search/Clear Search
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
% Validate Settings
function validateSettings(src, evt)
    handles = guidata(gcbf);

    config = validateInputs(handles);
    if ~isempty(config)
        % Check Simscape logging if enabled
        if get(handles.use_simscape, 'Value')
            checkSimscapeLoggingEnabled(config.model_name);
        end
        msgbox('All settings are valid!', 'Validation Successful', 'help');
    end
end
% Save/Load Configuration
function saveConfiguration(src, evt)
    handles = guidata(gcbf);

    [filename, pathname] = uiputfile('*.mat', 'Save Configuration');
    if filename ~= 0
        try
            config = gatherConfiguration(handles);
            save(fullfile(pathname, filename), 'config');
            msgbox('Configuration saved successfully', 'Success');
        catch ME
            msgbox(['Error saving: ' ME.message], 'Error', 'error');
        end
    end
end
function loadConfiguration(src, evt)
    handles = guidata(gcbf);

    [filename, pathname] = uigetfile('*.mat', 'Load Configuration');
    if filename ~= 0
        try
            loaded = load(fullfile(pathname, filename));
            applyConfiguration(handles, loaded.config);
            msgbox('Configuration loaded successfully', 'Success');
        catch ME
            msgbox(['Error loading: ' ME.message], 'Error', 'error');
        end
    end
end
% Helper function to gather configuration
function config = gatherConfiguration(handles)
    config = struct();

    % Get all UI values
    config.num_trials = get(handles.num_trials_edit, 'String');
    config.sim_time = get(handles.sim_time_edit, 'String');
    config.sample_rate = get(handles.sample_rate_edit, 'String');
    config.execution_mode = get(handles.execution_mode_popup, 'Value');
    config.torque_scenario = get(handles.torque_scenario_popup, 'Value');
    config.coeff_range = get(handles.coeff_range_edit, 'String');
    config.constant_value = get(handles.constant_value_edit, 'String');
    config.use_logsout = get(handles.use_logsout, 'Value');
    config.use_signal_bus = get(handles.use_signal_bus, 'Value');
    config.use_simscape = get(handles.use_simscape, 'Value');
    config.enable_animation = get(handles.enable_animation, 'Value');
    config.output_folder = get(handles.output_folder_edit, 'String');
    config.folder_name = get(handles.folder_name_edit, 'String');
    config.file_format = get(handles.format_popup, 'Value');
    config.coefficients_data = get(handles.coefficients_table, 'Data');
end
% Helper function to apply configuration
function applyConfiguration(handles, config)
    % Apply all UI values
    if isfield(config, 'num_trials')
        set(handles.num_trials_edit, 'String', config.num_trials);
    end
    if isfield(config, 'sim_time')
        set(handles.sim_time_edit, 'String', config.sim_time);
    end
    if isfield(config, 'sample_rate')
        set(handles.sample_rate_edit, 'String', config.sample_rate);
    end
    if isfield(config, 'execution_mode')
        set(handles.execution_mode_popup, 'Value', config.execution_mode);
    end
    if isfield(config, 'torque_scenario')
        set(handles.torque_scenario_popup, 'Value', config.torque_scenario);
    end
    if isfield(config, 'coeff_range')
        set(handles.coeff_range_edit, 'String', config.coeff_range);
    end
    if isfield(config, 'constant_value')
        set(handles.constant_value_edit, 'String', config.constant_value);
    end
    if isfield(config, 'use_logsout')
        set(handles.use_logsout, 'Value', config.use_logsout);
    end
    if isfield(config, 'use_signal_bus')
        set(handles.use_signal_bus, 'Value', config.use_signal_bus);
    end
    if isfield(config, 'use_simscape')
        set(handles.use_simscape, 'Value', config.use_simscape);
    end
    if isfield(config, 'enable_animation')
        set(handles.enable_animation, 'Value', config.enable_animation);
    end
    if isfield(config, 'output_folder')
        set(handles.output_folder_edit, 'String', config.output_folder);
    end
    if isfield(config, 'folder_name')
        set(handles.folder_name_edit, 'String', config.folder_name);
    end
    if isfield(config, 'file_format')
        set(handles.format_popup, 'Value', config.file_format);
    elseif isfield(config, 'format')
        set(handles.format_popup, 'Value', config.format);
    end
    if isfield(config, 'coefficients_data')
        set(handles.coefficients_table, 'Data', config.coefficients_data);
    end

    % Update UI state
    torqueScenarioCallback(handles.torque_scenario_popup, []);
    updatePreview([], [], handles.fig);
end
% [Previous helper functions remain the same...]
% Run Generation Process
function runGeneration(handles)
    try
        config = handles.config;

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

        % Check execution mode and implement parallel processing
        execution_mode = get(handles.execution_mode_popup, 'Value');

        if execution_mode == 2 && license('test', 'Distrib_Computing_Toolbox')
            % Parallel execution
            successful_trials = runParallelSimulations(handles, config);
        else
            % Sequential execution
            successful_trials = runSequentialSimulations(handles, config);
        end

        % Final status
        failed_trials = config.num_simulations - successful_trials;
        final_msg = sprintf('Complete: %d successful, %d failed', successful_trials, failed_trials);
        set(handles.status_text, 'String', ['Status: ' final_msg]);
        set(handles.progress_text, 'String', final_msg);

        % Compile dataset
        if successful_trials > 0
            set(handles.status_text, 'String', 'Status: Compiling master dataset...');
            drawnow;
            compileDataset(config);
            set(handles.status_text, 'String', ['Status: ' final_msg ' - Dataset compiled']);
        end

        % Save script and settings for reproducibility
        try
            saveScriptAndSettings(config);
        catch ME
            fprintf('Warning: Could not save script and settings: %s\n', ME.message);
        end

        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');

    catch ME
        try
            set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
            set(handles.start_button, 'Enable', 'on');
            set(handles.stop_button, 'Enable', 'off');
        catch
            % GUI might be destroyed, ignore the error
        end
        errordlg(ME.message, 'Generation Failed');
    end
end
function successful_trials = runParallelSimulations(handles, config)
    % Initialize parallel pool
    try
        if isempty(gcp('nocreate'))
            % Auto-detect optimal number of workers
            max_cores = feature('numcores');
            num_workers = min(max_cores, 6); % Limit to 6 workers to match MATLAB cluster configuration
            parpool('local', num_workers);
            fprintf('Started parallel pool with %d workers\n', num_workers);
        else
            current_pool = gcp;
            fprintf('Using existing parallel pool with %d workers\n', current_pool.NumWorkers);
        end
    catch ME
        warning('Failed to start parallel pool: %s. Falling back to sequential execution.', ME.message);
        successful_trials = runSequentialSimulations(handles, config);
        return;
    end

    % Prepare simulation inputs
    simInputs = prepareSimulationInputs(config);

    % Validate simulation inputs before running
    if isempty(simInputs)
        error('No simulation inputs prepared');
    end
    fprintf('Prepared %d simulation inputs\n', length(simInputs));

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

    % Run parallel simulations
    set(handles.progress_text, 'String', 'Running parallel simulations...');
    drawnow;

    try
        % Add extra error handling for parallel Simscape parameter issues
        fprintf('Debug: Running %d simulations in parallel with Simscape logging\n', length(simInputs));

        % Use parsim for parallel simulation with robust error handling
        simOuts = parsim(simInputs, 'ShowProgress', true, 'ShowSimulationManager', 'off', ...
                        'TransferBaseWorkspaceVariables', 'on', ...
                        'AttachedFiles', {config.model_path}, ...
                        'StopOnError', 'off');  % Don't stop on individual simulation errors

        % Process results
        successful_trials = 0;

        % Check if parsim succeeded
        if isempty(simOuts)
            error('Parallel simulation failed - no results returned');
        end

        for i = 1:length(simOuts)
            if ~isempty(simOuts(i))
                % Check if simulation completed successfully
                simulation_success = false;
                has_error = false;

                % Try multiple ways to check simulation status
                try
                    % Method 1: Check SimulationMetadata (standard way)
                    if isprop(simOuts(i), 'SimulationMetadata') && ...
                       isfield(simOuts(i).SimulationMetadata, 'ExecutionInfo')

                        execInfo = simOuts(i).SimulationMetadata.ExecutionInfo;

                        if isfield(execInfo, 'StopEvent') && execInfo.StopEvent == "CompletedNormally"
                            simulation_success = true;
                        else
                            has_error = true;
                            fprintf('✗ Trial %d simulation failed (metadata)\n', i);

                            if isfield(execInfo, 'ErrorDiagnostic') && ~isempty(execInfo.ErrorDiagnostic)
                                fprintf('  Error: %s\n', execInfo.ErrorDiagnostic.message);
                            end
                        end
                    else
                        % Method 2: Check for ErrorMessage property (indicates failure)
                        if isprop(simOuts(i), 'ErrorMessage') && ~isempty(simOuts(i).ErrorMessage)
                            has_error = true;
                            fprintf('✗ Trial %d simulation failed: %s\n', i, simOuts(i).ErrorMessage);
                        else
                            % Method 3: If no metadata but we have output data, assume success
                            % Check if we have expected output fields (logsout, simlog, etc.)
                            has_data = false;
                            if isprop(simOuts(i), 'logsout') || isfield(simOuts(i), 'logsout') || ...
                               isprop(simOuts(i), 'simlog') || isfield(simOuts(i), 'simlog') || ...
                               isprop(simOuts(i), 'CombinedSignalBus') || isfield(simOuts(i), 'CombinedSignalBus')
                                has_data = true;
                            end

                            if has_data
                                fprintf('✓ Trial %d: Assuming success (has output data, no error message)\n', i);
                                simulation_success = true;
                            else
                                fprintf('✗ Trial %d: No metadata, no data, assuming failure\n', i);
                                has_error = true;
                            end
                        end
                    end
                catch ME
                    fprintf('✗ Trial %d: Error checking simulation status: %s\n', i, ME.message);
                    has_error = true;
                end

                % Process simulation if it succeeded
                if simulation_success && ~has_error
                    try
                        result = processSimulationOutput(i, config, simOuts(i));
                        if result.success
                            successful_trials = successful_trials + 1;
                            fprintf('✓ Trial %d completed successfully\n', i);
                        else
                            fprintf('✗ Trial %d processing failed: %s\n', i, result.error);
                        end
                    catch ME
                        fprintf('Error processing trial %d: %s\n', i, ME.message);
                    end
                end
            else
                fprintf('✗ Trial %d: Empty simulation output\n', i);
            end
        end

        % Summary
        fprintf('\n=== PARALLEL SIMULATION SUMMARY ===\n');
        fprintf('Total trials: %d\n', length(simOuts));
        fprintf('Successful: %d\n', successful_trials);
        fprintf('Failed: %d\n', length(simOuts) - successful_trials);

        if successful_trials == 0
            fprintf('\n⚠️  All parallel simulations failed. Common causes:\n');
            fprintf('   • Model path not accessible on workers\n');
            fprintf('   • Missing workspace variables on workers\n');
            fprintf('   • Toolbox licensing issues on workers\n');
            fprintf('   • Model configuration conflicts in parallel mode\n');
            fprintf('   • Coefficient setting issues on workers\n');
            fprintf('\n Try sequential mode for detailed debugging\n');
        end

    catch ME
        fprintf('\n❌ PARALLEL SIMULATION FRAMEWORK ERROR: %s\n', ME.message);

        fprintf('Attempting to diagnose the issue...\n');

        % Try running one simulation sequentially to get detailed error
        try
            if ~isempty(simInputs) && length(simInputs) >= 1
                fprintf('\nRunning single simulation sequentially for debugging...\n');

                % Ensure model is loaded
                if ~bdIsLoaded(config.model_name)
                    load_system(config.model_path);
                end

                single_simOut = sim(simInputs(1));
                fprintf('Single simulation succeeded - issue may be parallel-specific\n');

                % Check if Simscape logging worked
                if isprop(single_simOut, 'simlog') || isfield(single_simOut, 'simlog')
                    fprintf('Simscape logging is available in sequential mode\n');
                else
                    fprintf('Warning: No Simscape logging even in sequential mode\n');
                end
            end
        catch singleME
            fprintf('Single simulation also failed: %s\n', singleME.message);
            if ~isempty(singleME.cause)
                for j = 1:length(singleME.cause)
                    fprintf('  Cause %d: %s\n', j, singleME.cause{j}.message);
                end
            end
        end

        successful_trials = 0;
    end
end
function successful_trials = runSequentialSimulations(handles, config)
    successful_trials = 0;

    for trial = 1:config.num_simulations
        handles = guidata(handles.fig); % Refresh handles
        if handles.should_stop
            break;
        end

        progress_msg = sprintf('Processing trial %d/%d...', trial, config.num_simulations);
        set(handles.progress_text, 'String', progress_msg);
        drawnow;

        try
            if trial <= size(config.coefficient_values, 1)
                trial_coefficients = config.coefficient_values(trial, :);
            else
                trial_coefficients = config.coefficient_values(end, :);
            end

            result = runSingleTrial(trial, config, trial_coefficients);

            if result.success
                successful_trials = successful_trials + 1;
            end

        catch ME
            fprintf('Trial %d error: %s\n', trial, ME.message);
        end
    end
end
function simInputs = prepareSimulationInputs(config)
    % Load the Simulink model
    model_name = config.model_name;
    if ~bdIsLoaded(model_name)
        try
            load_system(model_name);
        catch ME
            error('Could not load Simulink model "%s": %s', model_name, ME.message);
        end
    end

    % Add model directory to path for parallel workers
    [model_dir, ~, ~] = fileparts(config.model_path);
    if ~isempty(model_dir)
        addpath(model_dir);
        fprintf('Added model directory to path: %s\n', model_dir);
    end

    % Create array of SimulationInput objects
    simInputs = Simulink.SimulationInput.empty(0, config.num_simulations);

    for trial = 1:config.num_simulations
        % Get coefficients for this trial
        if trial <= size(config.coefficient_values, 1)
            trial_coefficients = config.coefficient_values(trial, :);
        else
            trial_coefficients = config.coefficient_values(end, :);
        end

        % Create SimulationInput object
        simIn = Simulink.SimulationInput(model_name);

        % Set simulation parameters safely
        simIn = setModelParameters(simIn, config);

        % Set polynomial coefficients
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);

        % Load input file if specified
        if ~isempty(config.input_file) && exist(config.input_file, 'file')
            simIn = loadInputFile(simIn, config.input_file);
        end

        simInputs(trial) = simIn;
    end
end
function simIn = setPolynomialCoefficients(simIn, coefficients, config)
    % Get parameter info for coefficient mapping
    param_info = getPolynomialParameterInfo();

    % Basic validation
    if isempty(param_info.joint_names)
        error('No joint names found in polynomial parameter info');
    end

    fprintf('Setting %d coefficients for %d joints\n', length(coefficients), length(param_info.joint_names));

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

                    % Show first few for debugging (but not too verbose)
                    if global_coeff_idx <= 3
                        fprintf('  Set %s = %.3f\n', var_name, coefficients(global_coeff_idx));
                    elseif global_coeff_idx == 4
                        fprintf('  ... (and %d more variables)\n', length(coefficients) - 3);
                    end
                catch ME
                    fprintf('  Warning: Failed to set %s: %s\n', var_name, ME.message);
                end
            else
                fprintf('  Warning: Not enough coefficients for %s (need %d, have %d)\n', var_name, global_coeff_idx, length(coefficients));
            end
            global_coeff_idx = global_coeff_idx + 1;
        end
    end

    fprintf('Successfully set %d model variables\n', variables_set);
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
% Real Simulation Function - Replaces Mock
function result = runSingleTrial(trial_num, config, trial_coefficients)
    result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);

    try
        % Create simulation input
        simIn = Simulink.SimulationInput(config.model_path);

        % Set model parameters
        simIn = setModelParameters(simIn, config);

        % Set polynomial coefficients for this trial
        simIn = setPolynomialCoefficients(simIn, trial_coefficients, config);

        % Suppress specific warnings that are not critical
        warning_state = warning('off', 'Simulink:Bus:EditTimeBusPropNotAllowed');
        warning_state2 = warning('off', 'Simulink:Engine:BlockOutputNotUpdated');
        warning_state3 = warning('off', 'Simulink:Engine:OutputNotConnected');
        warning_state4 = warning('off', 'Simulink:Engine:InputNotConnected');
        warning_state5 = warning('off', 'Simulink:Blocks:UnconnectedOutputPort');
        warning_state6 = warning('off', 'Simulink:Blocks:UnconnectedInputPort');

        % Run simulation with progress indicator
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
        result = processSimulationOutput(trial_num, config, simOut);

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
function simIn = setModelParameters(simIn, config)
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
function result = processSimulationOutput(trial_num, config, simOut)
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
        % Note: Model workspace data is always captured as it contains essential model parameters
        data_table = addModelWorkspaceData(data_table, simOut, num_rows);

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

function [data_table, signal_info] = extractSignalsFromSimOut(simOut, options)
    % Extract signals from simulation output based on specified options
    % This replaces the missing extractAllSignalsFromBus function

    data_table = [];
    signal_info = struct();

    try
        % Initialize data collection
        all_data = {};

        % Extract from CombinedSignalBus if enabled and available
        if options.extract_combined_bus && (isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus'))
            if options.verbose
                fprintf('Extracting from CombinedSignalBus...\n');
            end

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
        end

        % Extract from logsout if enabled and available
        if options.extract_logsout && (isprop(simOut, 'logsout') || isfield(simOut, 'logsout'))
            if options.verbose
                fprintf('Extracting from logsout...\n');
            end

            logsout_data = extractLogsoutDataFixed(simOut.logsout);
            if ~isempty(logsout_data)
                all_data{end+1} = logsout_data;
                if options.verbose
                    fprintf('Logsout: %d columns extracted\n', width(logsout_data));
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
                    if options.verbose
                        fprintf('Warning: Could not access simlog: %s\n', ME.message);
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

function combined_table = combineDataSources(data_sources)
    % Combine multiple data tables into one
    combined_table = [];

    try
        if isempty(data_sources)
            return;
        end

        % Start with the first data source
        combined_table = data_sources{1};

        % Merge additional data sources
        % Alternative: Use Grok's cleaner mergeTables function if all sources have time:
        % combined_table = mergeTables(data_sources{:});

        for i = 2:length(data_sources)
            if ~isempty(data_sources{i})
                % Find common time column
                if ismember('time', combined_table.Properties.VariableNames) && ...
                   ismember('time', data_sources{i}.Properties.VariableNames)

                    % Merge on time column (same as Grok's mergeTables)
                    combined_table = outerjoin(combined_table, data_sources{i}, 'Keys', 'time', 'MergeKeys', true);
                else
                    % Robust fallback for edge cases without time columns
                    common_vars = intersect(combined_table.Properties.VariableNames, ...
                                          data_sources{i}.Properties.VariableNames);
                    if ~isempty(common_vars)
                        combined_table = [combined_table(:, common_vars); data_sources{i}(:, common_vars)];
                    end
                end
            end
        end

    catch ME
        fprintf('Error combining data sources: %s\n', ME.message);
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
                fprintf('  Warning: Could not extract variable %s: %s\n', var_name, ME.message);
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
        constant_value = str2double(get(handles.constant_value_edit, 'String'));

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
                        fprintf('Debug: Model has Simscape-compatible solver configuration\n');
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
                    fprintf('Debug: Found %d Simscape indicators in model (blocks + references + config)\n', total_indicators);
                    if ~isempty(subsystem_refs)
                        fprintf('Debug: Model uses referenced subsystems - Simscape components may be inside references\n');
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
        config.output_folder = fullfile(output_folder, folder_name);
        config.file_format = get(handles.format_popup, 'Value');

    catch ME
        errordlg(ME.message, 'Input Validation Error');
        config = [];
    end
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

        if any(isnan(coefficient_values(:)))
            warning('Some coefficient values are invalid (NaN)');
        end

    catch ME
        warning('Error extracting coefficients: %s', ME.message);
        coefficient_values = [];
    end
end
% Helper functions
function param_info = getPolynomialParameterInfo()
    % Get polynomial parameter structure with dynamic path resolution
    try
        % Try multiple possible locations for the parameter file
        possible_paths = {
            'Model/PolynomialInputValues.mat',
            'PolynomialInputValues.mat',
            fullfile(pwd, 'Model', 'PolynomialInputValues.mat'),
            fullfile(pwd, 'PolynomialInputValues.mat')
        };

        model_path = '';
        for i = 1:length(possible_paths)
            if exist(possible_paths{i}, 'file')
                model_path = possible_paths{i};
                break;
            end
        end

        if ~isempty(model_path)
            loaded_data = load(model_path);
            var_names = fieldnames(loaded_data);

            % Parse variable names
            joint_map = containers.Map();

            for i = 1:length(var_names)
                name = var_names{i};
                if length(name) > 1
                    coeff = name(end);
                    base_name = name(1:end-1);

                    if isKey(joint_map, base_name)
                        joint_map(base_name) = [joint_map(base_name), coeff];
                    else
                        joint_map(base_name) = coeff;
                    end
                end
            end

            % Filter to only 7-coefficient joints
            all_joint_names = keys(joint_map);
            filtered_joint_names = {};
            filtered_coeffs = {};

            for i = 1:length(all_joint_names)
                joint_name = all_joint_names{i};
                coeffs = sort(joint_map(joint_name));

                if length(coeffs) == 7 && strcmp(coeffs, 'ABCDEFG')
                    filtered_joint_names{end+1} = joint_name;
                    filtered_coeffs{end+1} = coeffs;
                end
            end

            param_info.joint_names = sort(filtered_joint_names);
            param_info.joint_coeffs = cell(size(param_info.joint_names));

            for i = 1:length(param_info.joint_names)
                joint_name = param_info.joint_names{i};
                idx = find(strcmp(filtered_joint_names, joint_name));
                param_info.joint_coeffs{i} = filtered_coeffs{idx};
            end

            param_info.total_params = length(param_info.joint_names) * 7;

        else
            param_info = getSimplifiedParameterInfo();
        end

    catch
        param_info = getSimplifiedParameterInfo();
    end
end
function param_info = getSimplifiedParameterInfo()
    % Fallback structure
    joint_names = {
        'BaseTorqueInputX', 'BaseTorqueInputY', 'BaseTorqueInputZ',
        'HipInputX', 'HipInputY', 'HipInputZ',
        'LSInputX', 'LSInputY', 'LSInputZ'
    };

    param_info.joint_names = joint_names;
    param_info.joint_coeffs = cell(size(joint_names));
    for i = 1:length(joint_names)
        param_info.joint_coeffs{i} = 'ABCDEFG';
    end
    param_info.total_params = length(joint_names) * 7;
end
function short_name = getShortenedJointName(joint_name)
    % Create shortened joint names for display
    short_name = strrep(joint_name, 'TorqueInput', 'T');
    short_name = strrep(short_name, 'Input', '');
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

        % THREE-PASS ALGORITHM to preserve ALL columns (union approach)
        fprintf('Using 3-pass algorithm to preserve all columns...\n');

        % PASS 1: Discover all unique column names across all files
        all_unique_columns = {};
        valid_files = {};

        for i = 1:length(csv_files)
            file_path = fullfile(config.output_folder, csv_files(i).name);
            try
                trial_data = readtable(file_path);
                if ~isempty(trial_data)
                    valid_files{end+1} = file_path;
                    trial_columns = trial_data.Properties.VariableNames;
                    all_unique_columns = union(all_unique_columns, trial_columns);
                    fprintf('  Pass 1 - %s: %d columns found\n', csv_files(i).name, length(trial_columns));
                end
            catch ME
                warning('Failed to read %s during discovery: %s', csv_files(i).name, ME.message);
            end
        end

        fprintf('  Total unique columns discovered: %d\n', length(all_unique_columns));

        % PASS 2: Standardize each trial to have all columns (with NaN for missing)
        standardized_tables = {};

        for i = 1:length(valid_files)
            file_path = valid_files{i};
            [~, filename, ~] = fileparts(file_path);

            try
                trial_data = readtable(file_path);

                % Create standardized table with all columns
                standardized_data = table();
                for col = 1:length(all_unique_columns)
                    col_name = all_unique_columns{col};
                    if ismember(col_name, trial_data.Properties.VariableNames)
                        standardized_data.(col_name) = trial_data.(col_name);
                    else
                        % Fill missing column with NaN
                        standardized_data.(col_name) = NaN(height(trial_data), 1);
                    end
                end

                standardized_tables{end+1} = standardized_data;
                fprintf('  Pass 2 - %s: standardized to %d columns\n', filename, width(standardized_data));

            catch ME
                warning('Failed to standardize %s: %s', filename, ME.message);
            end
        end

        % PASS 3: Concatenate all standardized tables
        master_data = [];
        for i = 1:length(standardized_tables)
            if isempty(master_data)
                master_data = standardized_tables{i};
            else
                master_data = [master_data; standardized_tables{i}];
            end
        end

        fprintf('✅ 3-pass compilation complete - preserved ALL %d columns!\n', width(master_data));

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
% Preferences functions
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

    % Try to load saved preferences
    if exist(pref_file, 'file')
        try
            loaded_prefs = load(pref_file);
            if isfield(loaded_prefs, 'preferences')
                % Merge loaded preferences
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
    % Apply preferences to UI
    try
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

        % Apply default values
        if isfield(handles, 'num_trials_edit')
            set(handles.num_trials_edit, 'String', num2str(prefs.default_num_trials));
        end

        if isfield(handles, 'sim_time_edit')
            set(handles.sim_time_edit, 'String', num2str(prefs.default_sim_time));
        end

        if isfield(handles, 'sample_rate_edit')
            set(handles.sample_rate_edit, 'String', num2str(prefs.default_sample_rate));
        end

    catch
        % Silently fail if preferences can't be applied
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

        % Save to file
        script_dir = fileparts(mfilename('fullpath'));
        pref_file = fullfile(script_dir, 'user_preferences.mat');
        preferences = handles.preferences;
        save(pref_file, 'preferences');

    catch
        % Silently fail if can't save
    end
end
% GUI callbacks
function closeGUICallback(src, evt)
    % Handle GUI close
    try
        handles = guidata(src);
        if isstruct(handles) && isfield(handles, 'preferences')
            saveUserPreferences(handles);
        end
    catch
        % Silently fail
    end

    % Close the figure
    delete(src);
end
function data_array = extractDataFromField(field_value, expected_length)
    % Extract numeric data from various field formats
    data_array = [];

    try
        if isa(field_value, 'timeseries')
            data_array = field_value.Data;
        elseif isa(field_value, 'Simulink.SimulationData.Signal')
            data_array = field_value.Values.Data;
        elseif isstruct(field_value)
            if isfield(field_value, 'Data')
                data_array = field_value.Data;
            elseif isfield(field_value, 'signals')
                % Handle nested signal structure
                return; % Let specialized function handle this
            elseif isfield(field_value, 'Values')
                data_array = field_value.Values;
            end
        elseif isnumeric(field_value)
            data_array = field_value;
        end

        % Validate data length
        if ~isempty(data_array) && size(data_array, 1) ~= expected_length
            data_array = [];
        end
    catch
        data_array = [];
    end
end

% FIXED: Extract from CombinedSignalBus
function data_table = extractFromCombinedSignalBus(combinedBus)
    data_table = [];

    try
        fprintf('Debug: Processing CombinedSignalBus\n');

        % CombinedSignalBus should be a struct with time and signals
        if ~isstruct(combinedBus)
            fprintf('Debug: CombinedSignalBus is not a struct\n');
            return;
        end

        % Look for time field
        bus_fields = fieldnames(combinedBus);
        fprintf('Debug: CombinedSignalBus fields: %s\n', strjoin(bus_fields, ', '));

        time_field = '';
        time_data = [];

        % Find time data - check common time field patterns
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);

            % Check if this field contains time data
            if isstruct(field_value) && isfield(field_value, 'time')
                time_field = field_name;
                time_data = field_value.time(:);  % Extract time from struct
                fprintf('Debug: Found time in %s.time (length: %d)\n', field_name, length(time_data));
                break;
            elseif isstruct(field_value) && isfield(field_value, 'Time')
                time_field = field_name;
                time_data = field_value.Time(:);  % Extract Time from struct
                fprintf('Debug: Found time in %s.Time (length: %d)\n', field_name, length(time_data));
                break;
            elseif contains(lower(field_name), 'time') && isnumeric(field_value)
                time_field = field_name;
                time_data = field_value(:);  % Ensure column vector
                fprintf('Debug: Found time field: %s (length: %d)\n', field_name, length(time_data));
                break;
            end
        end

        % If still no time found, try the first field that looks like it has time data
        if isempty(time_data)
            for i = 1:length(bus_fields)
                field_name = bus_fields{i};
                field_value = combinedBus.(field_name);

                if isstruct(field_value)
                    sub_fields = fieldnames(field_value);
                    for j = 1:length(sub_fields)
                        if contains(lower(sub_fields{j}), 'time')
                            time_field = field_name;
                            time_data = field_value.(sub_fields{j})(:);
                            fprintf('Debug: Found time in %s.%s (length: %d)\n', field_name, sub_fields{j}, length(time_data));
                            break;
                        end
                    end
                    if ~isempty(time_data)
                        break;
                    end
                end
            end
        end

        % First, try to find time data by examining the signal structures
        for i = 1:length(bus_fields)
            if ~isempty(time_data)
                break;
            end

            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);

            if isstruct(field_value)
                % This field contains sub-signals
                sub_fields = fieldnames(field_value);

                % Try to get time from the first valid signal
                for j = 1:length(sub_fields)
                    sub_field_name = sub_fields{j};
                    signal_data = field_value.(sub_field_name);

                    % Check if this is a timeseries or signal structure with time
                    if isa(signal_data, 'timeseries')
                        time_data = signal_data.Time(:);
                        fprintf('Debug: Found time in %s.%s (timeseries), length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    elseif isstruct(signal_data) && isfield(signal_data, 'time')
                        time_data = signal_data.time(:);
                        fprintf('Debug: Found time in %s.%s.time, length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    elseif isstruct(signal_data) && isfield(signal_data, 'Time')
                        time_data = signal_data.Time(:);
                        fprintf('Debug: Found time in %s.%s.Time, length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    elseif isstruct(signal_data) && isfield(signal_data, 'Values')
                        % Could be a Simulink.SimulationData.Signal format
                        if isnumeric(signal_data.Values) && size(signal_data.Values, 1) > 1
                            % Assume first column is time if it exists
                            time_data = (0:size(signal_data.Values, 1)-1)' * 0.001; % Default 1ms sampling
                            fprintf('Debug: Generated time vector for %s.%s, length: %d\n', field_name, sub_field_name, length(time_data));
                            break;
                        end
                    elseif isnumeric(signal_data) && length(signal_data) > 1
                        % Just numeric data, we'll need to generate time
                        time_data = (0:length(signal_data)-1)' * 0.001; % Default 1ms sampling
                        fprintf('Debug: Generated time vector from %s.%s numeric data, length: %d\n', field_name, sub_field_name, length(time_data));
                        break;
                    end
                end
            end
        end

        if isempty(time_data)
            fprintf('Debug: No time data found in any signals\n');
            return;
        end

        % Now extract all signals using this time reference
        data_cells = {time_data};
        var_names = {'time'};
        expected_length = length(time_data);

        fprintf('Debug: Starting data extraction with time vector length: %d\n', expected_length);

        % Process each field in the bus
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);

            if isstruct(field_value)
                % This field contains sub-signals
                sub_fields = fieldnames(field_value);

                for j = 1:length(sub_fields)
                    sub_field_name = sub_fields{j};
                    signal_data = field_value.(sub_field_name);

                    % Extract numeric data from various formats
                    numeric_data = [];

                    if isa(signal_data, 'timeseries')
                        numeric_data = signal_data.Data;
                    elseif isstruct(signal_data) && isfield(signal_data, 'Data')
                        numeric_data = signal_data.Data;
                    elseif isstruct(signal_data) && isfield(signal_data, 'Values')
                        numeric_data = signal_data.Values;
                    elseif isnumeric(signal_data)
                        numeric_data = signal_data;
                    end

                    % Add the data - handle both time series and constant properties
                    if ~isempty(numeric_data)
                        data_size = size(numeric_data);
                        num_elements = numel(numeric_data);

                        if size(numeric_data, 1) == expected_length
                            % TIME SERIES DATA - matches expected length
                            if size(numeric_data, 2) == 1
                                % Single column time series
                                data_cells{end+1} = numeric_data(:);
                                var_names{end+1} = sprintf('%s_%s', field_name, sub_field_name);
                                fprintf('Debug: Added time series %s_%s\n', field_name, sub_field_name);
                            elseif size(numeric_data, 2) > 1
                                % Multi-column time series
                                for col = 1:size(numeric_data, 2)
                                    data_cells{end+1} = numeric_data(:, col);
                                    var_names{end+1} = sprintf('%s_%s_%d', field_name, sub_field_name, col);
                                    fprintf('Debug: Added time series %s_%s_%d\n', field_name, sub_field_name, col);
                                end
                            end

                        elseif num_elements == 3
                            % 3D VECTOR (e.g., COM position [x, y, z])
                            vector_data = numeric_data(:);  % Ensure column vector
                            for dim = 1:3
                                % Replicate constant value for all time steps
                                replicated_data = repmat(vector_data(dim), expected_length, 1);
                                data_cells{end+1} = replicated_data;
                                dim_labels = {'x', 'y', 'z'};
                                var_names{end+1} = sprintf('%s_%s_%s', field_name, sub_field_name, dim_labels{dim});
                                fprintf('Debug: Added 3D vector %s_%s_%s (replicated %g for %d timesteps)\n', ...
                                    field_name, sub_field_name, dim_labels{dim}, vector_data(dim), expected_length);
                            end

                        elseif num_elements == 9
                            % 3x3 MATRIX (e.g., inertia matrix)
                            if isequal(data_size, [3, 3])
                                % Already 3x3 matrix
                                matrix_data = numeric_data;
                            else
                                % Reshape to 3x3 if it's a 9x1 vector
                                matrix_data = reshape(numeric_data, 3, 3);
                            end

                            % Extract all 9 elements and replicate for each time step
                            for row = 1:3
                                for col = 1:3
                                    matrix_element = matrix_data(row, col);
                                    replicated_data = repmat(matrix_element, expected_length, 1);
                                    data_cells{end+1} = replicated_data;
                                    var_names{end+1} = sprintf('%s_%s_I%d%d', field_name, sub_field_name, row, col);
                                    fprintf('Debug: Added 3x3 matrix %s_%s_I%d%d (replicated %g for %d timesteps)\n', ...
                                        field_name, sub_field_name, row, col, matrix_element, expected_length);
                                end
                            end

                        elseif num_elements == 6
                            % 6 ELEMENT DATA (e.g., 6DOF pose/twist)
                            vector_data = numeric_data(:);  % Ensure column vector
                            for dim = 1:6
                                replicated_data = repmat(vector_data(dim), expected_length, 1);
                                data_cells{end+1} = replicated_data;
                                var_names{end+1} = sprintf('%s_%s_dof%d', field_name, sub_field_name, dim);
                                fprintf('Debug: Added 6DOF data %s_%s_dof%d (replicated %g for %d timesteps)\n', ...
                                    field_name, sub_field_name, dim, vector_data(dim), expected_length);
                            end

                        else
                            % UNHANDLED SIZE - still skip but with better diagnostic
                            fprintf('Debug: Skipping %s.%s (size [%s] not supported - need time series, 3D vector, 3x3 matrix, or 6DOF)\n', ...
                                field_name, sub_field_name, num2str(data_size));
                        end
                    end
                end
            elseif isnumeric(field_value) && length(field_value) == expected_length
                % Direct numeric field
                data_cells{end+1} = field_value(:);
                var_names{end+1} = field_name;
                fprintf('Debug: Added direct field %s\n', field_name);
            end
        end

        % Create table if we have data
        if length(data_cells) > 1
            data_table = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created CombinedSignalBus table with %d columns, %d rows\n', width(data_table), height(data_table));
        else
            fprintf('Debug: No valid data found in CombinedSignalBus\n');
            fprintf('Debug: Total data_cells collected: %d\n', length(data_cells));
            fprintf('Debug: Variable names: %s\n', strjoin(var_names, ', '));
        end

    catch ME
        fprintf('Error extracting CombinedSignalBus data: %s\n', ME.message);
    end
end

% FIXED: Extract from nested struct
function data_table = extractFromNestedStruct(nested_struct, struct_name, time_data)
    data_table = [];

    try
        if ~isstruct(nested_struct)
            return;
        end

        nested_fields = fieldnames(nested_struct);
        data_cells = {};
        var_names = {};

        for i = 1:length(nested_fields)
            field_name = nested_fields{i};
            field_value = nested_struct.(field_name);

            if isnumeric(field_value) && length(field_value) == length(time_data)
                data_cells{end+1} = field_value(:);
                var_names{end+1} = sprintf('%s_%s', struct_name, field_name);
            elseif isstruct(field_value)
                % Recursively handle deeper nesting
                deeper_data = extractFromNestedStruct(field_value, sprintf('%s_%s', struct_name, field_name), time_data);
                if ~isempty(deeper_data)
                    deeper_vars = deeper_data.Properties.VariableNames;
                    for j = 1:length(deeper_vars)
                        data_cells{end+1} = deeper_data.(deeper_vars{j});
                        var_names{end+1} = deeper_vars{j};
                    end
                end
            end
        end

        if ~isempty(data_cells)
            % Add time column
            data_cells = [{time_data}, data_cells];
            var_names = [{'time'}, var_names];
            data_table = table(data_cells{:}, 'VariableNames', var_names);
        end

    catch ME
        fprintf('Error extracting nested struct %s: %s\n', struct_name, ME.message);
    end
end

% FIXED: Extract from logsout with proper Signal handling
function logsout_data = extractLogsoutDataFixed(logsout)
    logsout_data = [];

    try
        fprintf('Debug: Extracting logsout data, type: %s\n', class(logsout));

        % Handle modern Simulink.SimulationData.Dataset format
        if isa(logsout, 'Simulink.SimulationData.Dataset')
            fprintf('Debug: Processing Dataset format with %d elements\n', logsout.numElements);

            if logsout.numElements == 0
                fprintf('Debug: Dataset is empty\n');
                return;
            end

            % Get time from first element
            first_element = logsout.getElement(1);  % Use getElement instead of {}

            % Handle Signal objects properly
            if isa(first_element, 'Simulink.SimulationData.Signal')
                time = first_element.Values.Time;
                fprintf('Debug: Using time from Signal object, length: %d\n', length(time));
            elseif isa(first_element, 'timeseries')
                time = first_element.Time;
                fprintf('Debug: Using time from timeseries, length: %d\n', length(time));
            else
                fprintf('Debug: Unknown first element type: %s\n', class(first_element));
                return;
            end

            data_cells = {time};
            var_names = {'time'};
            expected_length = length(time);

            % Process each element in the dataset
            for i = 1:logsout.numElements
                element = logsout.getElement(i);  % Use getElement

                if isa(element, 'Simulink.SimulationData.Signal')
                    signalName = element.Name;
                    if isempty(signalName)
                        signalName = sprintf('Signal_%d', i);
                    end

                    % Extract data from Signal object
                    data = element.Values.Data;
                    signal_time = element.Values.Time;

                    % Ensure data matches time length and is valid
                    if isnumeric(data) && length(signal_time) == expected_length && ~isempty(data)
                        % Check if data has the right dimensions
                        if size(data, 1) == expected_length
                            if size(data, 2) > 1
                                % Multi-dimensional signal
                                for col = 1:size(data, 2)
                                    col_data = data(:, col);
                                    % Ensure the column data is the right length
                                    if length(col_data) == expected_length
                                        data_cells{end+1} = col_data;
                                        var_names{end+1} = sprintf('%s_%d', signalName, col);
                                        fprintf('Debug: Added multi-dim signal %s_%d (length: %d)\n', signalName, col, length(col_data));
                                    else
                                        fprintf('Debug: Skipping column %d of signal %s (length mismatch: %d vs %d)\n', col, signalName, length(col_data), expected_length);
                                    end
                                end
                            else
                                % Single column signal
                                flat_data = data(:);
                                if length(flat_data) == expected_length
                                    data_cells{end+1} = flat_data;
                                    var_names{end+1} = signalName;
                                    fprintf('Debug: Added signal %s (length: %d)\n', signalName, length(flat_data));
                                else
                                    fprintf('Debug: Skipping signal %s (flattened length mismatch: %d vs %d)\n', signalName, length(flat_data), expected_length);
                                end
                            end
                        else
                            fprintf('Debug: Skipping signal %s (row dimension mismatch: %d vs %d)\n', signalName, size(data, 1), expected_length);
                        end
                    else
                        fprintf('Debug: Skipping signal %s (time length mismatch: %d vs %d, or empty data)\n', signalName, length(signal_time), expected_length);
                    end

                elseif isa(element, 'timeseries')
                    signalName = element.Name;
                    data = element.Data;
                    if isnumeric(data) && length(data) == expected_length && ~isempty(data)
                        flat_data = data(:);
                        if length(flat_data) == expected_length
                            data_cells{end+1} = flat_data;
                            var_names{end+1} = signalName;
                            fprintf('Debug: Added timeseries %s (length: %d)\n', signalName, length(flat_data));
                        else
                            fprintf('Debug: Skipping timeseries %s (flattened length mismatch: %d vs %d)\n', signalName, length(flat_data), expected_length);
                        end
                    else
                        fprintf('Debug: Skipping timeseries %s (length mismatch: %d vs %d, or empty data)\n', signalName, length(data), expected_length);
                    end
                else
                    fprintf('Debug: Element %d is type: %s\n', i, class(element));
                end
            end

            % Validate all data vectors have the same length before creating table
            if length(data_cells) > 1
                % Check that all vectors have the same length
                lengths = cellfun(@length, data_cells);
                if all(lengths == expected_length)
                    logsout_data = table(data_cells{:}, 'VariableNames', var_names);
                    fprintf('Debug: Created logsout table with %d columns, all vectors length %d\n', width(logsout_data), expected_length);
                else
                    fprintf('Debug: Cannot create table - vector length mismatch. Lengths: ');
                    fprintf('%d ', lengths);
                    fprintf('\n');
                    % Try to create table with only vectors of the correct length
                    valid_indices = find(lengths == expected_length);
                    if length(valid_indices) > 1
                        valid_cells = data_cells(valid_indices);
                        valid_names = var_names(valid_indices);
                        logsout_data = table(valid_cells{:}, 'VariableNames', valid_names);
                        fprintf('Debug: Created logsout table with %d valid columns (length %d)\n', width(logsout_data), expected_length);
                    else
                        fprintf('Debug: Not enough valid vectors to create table\n');
                    end
                end
            else
                fprintf('Debug: No valid data found in logsout Dataset\n');
            end

        else
            fprintf('Debug: Logsout format not supported: %s\n', class(logsout));
        end

    catch ME
        fprintf('Error extracting logsout data: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
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
            fprintf(' Inspecting simlog properties...\n');
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
            fprintf(' Using properties as children (Multibody approach)\n');

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
                fprintf(' First child (%s) class: %s\n', first_child_id, class(first_child));

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

        fprintf('Debug: Starting recursive Simscape extraction from root node.\n');

        % Recursively collect all series data using primary traversal method
        [time_data, all_signals] = traverseSimlogNode(simlog, '');

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
        fprintf('Debug: Attempting fallback Simscape extraction...\n');

        % Method 1: Try direct property enumeration
        try
            props = properties(simlog);
            fprintf('Debug: Simlog has %d properties\n', length(props));

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

% Extract constant matrix/vector data and replicate for time series
function [constant_signals] = extractConstantMatrixData(data_value, signal_name, reference_time)
    constant_signals = {};

    try
        if isstruct(data_value)
            % Extract numeric data from struct fields
            fields = fieldnames(data_value);
            for i = 1:length(fields)
                field_name = fields{i};
                field_value = data_value.(field_name);

                % Recursively process struct fields
                if isnumeric(field_value)
                    sub_signals = extractConstantMatrixData(field_value, sprintf('%s_%s', signal_name, field_name), reference_time);
                    constant_signals = [constant_signals, sub_signals];
                end
            end

        elseif isnumeric(data_value)
            % Process numeric data directly
            num_elements = numel(data_value);
            data_size = size(data_value);

            % Determine reference length (use 3006 as default if no reference provided)
            if isempty(reference_time)
                expected_length = 3006;  % Default length based on typical simulation
            else
                expected_length = length(reference_time);
            end

            if num_elements == 3
                % 3D VECTOR (e.g., COM position [x, y, z])
                vector_data = data_value(:);  % Ensure column vector
                dim_labels = {'x', 'y', 'z'};
                for dim = 1:3
                    replicated_data = repmat(vector_data(dim), expected_length, 1);
                    signal_name_full = matlab.lang.makeValidName(sprintf('%s_%s', signal_name, dim_labels{dim}));
                    constant_signals{end+1} = struct('name', signal_name_full, 'data', replicated_data);
                    fprintf('Debug: Added 3D vector %s (replicated %g for %d timesteps)\n', signal_name_full, vector_data(dim), expected_length);
                end

            elseif num_elements == 6
                % 6DOF DATA (e.g., pose/twist [x,y,z,rx,ry,rz])
                vector_data = data_value(:);  % Ensure column vector
                dof_labels = {'x', 'y', 'z', 'rx', 'ry', 'rz'};
                for dim = 1:6
                    replicated_data = repmat(vector_data(dim), expected_length, 1);
                    signal_name_full = matlab.lang.makeValidName(sprintf('%s_%s', signal_name, dof_labels{dim}));
                    constant_signals{end+1} = struct('name', signal_name_full, 'data', replicated_data);
                    fprintf('Debug: Added 6DOF data %s (replicated %g for %d timesteps)\n', signal_name_full, vector_data(dim), expected_length);
                end

            elseif num_elements == 9 && isequal(data_size, [3, 3])
                % 3x3 MATRIX (e.g., inertia matrix, rotation matrix)
                matrix_data = data_value;
                for row = 1:3
                    for col = 1:3
                        matrix_element = matrix_data(row, col);
                        replicated_data = repmat(matrix_element, expected_length, 1);
                        signal_name_full = matlab.lang.makeValidName(sprintf('%s_R%d%d', signal_name, row, col));
                        constant_signals{end+1} = struct('name', signal_name_full, 'data', replicated_data);
                        fprintf('Debug: Added 3x3 matrix %s (replicated %g for %d timesteps)\n', signal_name_full, matrix_element, expected_length);
                    end
                end

            elseif num_elements == 9 && ~isequal(data_size, [3, 3])
                % 9-ELEMENT VECTOR (flattened 3x3 matrix)
                vector_data = data_value(:);  % Ensure column vector
                for elem = 1:9
                    row = ceil(elem/3);
                    col = mod(elem-1, 3) + 1;
                    replicated_data = repmat(vector_data(elem), expected_length, 1);
                    signal_name_full = matlab.lang.makeValidName(sprintf('%s_I%d%d', signal_name, row, col));
                    constant_signals{end+1} = struct('name', signal_name_full, 'data', replicated_data);
                    fprintf('Debug: Added 9-element vector %s (replicated %g for %d timesteps)\n', signal_name_full, vector_data(elem), expected_length);
                end

            elseif num_elements == 1
                % SCALAR CONSTANT
                replicated_data = repmat(data_value, expected_length, 1);
                signal_name_full = matlab.lang.makeValidName(signal_name);
                constant_signals{end+1} = struct('name', signal_name_full, 'data', replicated_data);
                fprintf('Debug: Added scalar constant %s (replicated %g for %d timesteps)\n', signal_name_full, data_value, expected_length);

            else
                % UNSUPPORTED SIZE - log for debugging
                fprintf('Debug: Skipping %s (unsupported size [%s] - need 1, 3, 6, or 9 elements)\n', signal_name, num2str(data_size));
            end
        end

    catch ME
        fprintf('Debug: Error processing constant data %s: %s\n', signal_name, ME.message);
    end
end

% Simscape Multibody specific traversal (different API than generic Simscape)
function [time_data, signals] = traverseSimlogNode(node, parent_path)
    time_data = [];
    signals = {};

    try
        % Get current node name
        node_name = '';
        try
            node_name = node.id;  % Preferred for simscape.logging.Node
        catch
            node_name = 'UnnamedNode';
        end
        current_path = fullfile(parent_path, node_name);
        fprintf('Debug: Traversing Multibody node: %s\n', current_path);

        % SIMSCAPE MULTIBODY APPROACH: Try multiple extraction methods
        node_has_data = false;

        % Method 1: Try direct data extraction from leaf nodes (5-layer deep approach)
        try
            % Check if this node directly contains time series data (leaf node)
            if isprop(node, 'time') && isprop(node, 'values')
                time = node.time;
                values = node.values;
                if ~isempty(time) && ~isempty(values) && isnumeric(time) && isnumeric(values)
                    if isempty(time_data)
                        time_data = time(:);
                        fprintf('Debug: ✅ FOUND TIME DATA at %s (length: %d)\n', current_path, length(time_data));
                    end
                    signal_name = matlab.lang.makeValidName(current_path);
                    signals{end+1} = struct('name', signal_name, 'data', values(:));
                    fprintf('Debug: ✅ EXTRACTED LEAF DATA from %s (length: %d)\n', current_path, length(values));
                    node_has_data = true;
                end
            end

            % If no direct data, try series API
            if ~node_has_data
                series_names = node.series.children();  % Standard Simscape series API
                for i = 1:length(series_names)
                    series_node = node.series.(series_names{i});
                    if series_node.hasData()
                        [data, time] = series_node.values('');
                        if ~isempty(data) && ~isempty(time)
                            if isempty(time_data)
                                time_data = time;
                                fprintf('Debug: Using time from %s (length: %d)\n', current_path, length(time_data));
                            end
                            signal_name = matlab.lang.makeValidName(fullfile(current_path, series_names{i}));
                            signals{end+1} = struct('name', signal_name, 'data', data);
                            fprintf('Debug: Found series data in %s.%s (length: %d)\n', current_path, series_names{i}, length(data));
                            node_has_data = true;
                        end
                    end
                end
            end
        catch
            % Series API failed - this is expected for Multibody
        end

        % Method 2: Simscape Multibody specific - direct property access
        if ~node_has_data
            try
                props = properties(node);
                for i = 1:length(props)
                    prop_name = props{i};
                    % Skip non-data properties
                    if ismember(prop_name, {'id', 'series', 'children'})
                        continue;
                    end

                    try
                        prop_value = node.(prop_name);
                        if isa(prop_value, 'simscape.logging.Node')
                            % This is another node - will be handled by recursion
                            continue;
                        elseif isstruct(prop_value) || isa(prop_value, 'timeseries')
                            % Try to extract time series data
                            [extracted_time, extracted_data] = extractTimeSeriesData(prop_value, sprintf('%s_%s', current_path, prop_name));
                            if ~isempty(extracted_time) && ~isempty(extracted_data)
                                if isempty(time_data)
                                    time_data = extracted_time;
                                    fprintf('Debug: Using time from %s.%s (length: %d)\n', current_path, prop_name, length(time_data));
                                end
                                signal_name = matlab.lang.makeValidName(sprintf('%s_%s', current_path, prop_name));
                                signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                                fprintf('Debug: Found Multibody data in %s.%s (length: %d)\n', current_path, prop_name, length(extracted_data));
                                node_has_data = true;
                            end
                        elseif isnumeric(prop_value) && length(prop_value) > 1
                            % Direct numeric property (could be time series data)
                            if isempty(time_data) && strcmp(prop_name, 'time')
                                time_data = prop_value(:);
                                fprintf('Debug: ✅ FOUND TIME PROPERTY at %s.%s (length: %d)\n', current_path, prop_name, length(time_data));
                            elseif ~isempty(time_data) && strcmp(prop_name, 'values')
                                signal_name = matlab.lang.makeValidName(current_path);
                                signals{end+1} = struct('name', signal_name, 'data', prop_value(:));
                                fprintf('Debug: ✅ EXTRACTED VALUES PROPERTY from %s.%s (length: %d)\n', current_path, prop_name, length(prop_value));
                                node_has_data = true;
                            elseif ~strcmp(prop_name, 'time') && ~strcmp(prop_name, 'values')
                                % Other numeric data - replicate time reference
                                if ~isempty(time_data) && length(prop_value) == length(time_data)
                                    signal_name = matlab.lang.makeValidName(sprintf('%s_%s', current_path, prop_name));
                                    signals{end+1} = struct('name', signal_name, 'data', prop_value(:));
                                    fprintf('Debug: ✅ EXTRACTED NUMERIC PROPERTY %s.%s (length: %d)\n', current_path, prop_name, length(prop_value));
                                    node_has_data = true;
                                end
                            end
                        end
                    catch
                        % Skip properties that can't be accessed
                        continue;
                    end
                end
            catch
                % Property enumeration failed
            end
        end

        % Recurse into child nodes
        child_ids = [];
        try
            child_ids = node.children();
        catch
            % children() method doesn't exist - use properties as children (Multibody)
            try
                all_props = properties(node);
                child_ids = {};
                for i = 1:length(all_props)
                    prop_name = all_props{i};
                    % Skip system properties, keep actual joint/body names
                    if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                        % Check if this property is actually a child node
                        try
                            prop_value = node.(prop_name);
                            if isa(prop_value, 'simscape.logging.Node')
                                child_ids{end+1} = prop_name;
                            end
                        catch
                            % Skip properties that can't be accessed
                        end
                    end
                end
            catch
                % Property enumeration failed
                child_ids = [];
            end
        end

        % Process child nodes
        if ~isempty(child_ids)
            for i = 1:length(child_ids)
                try
                    child_node = node.(child_ids{i});
                    [child_time, child_signals] = traverseSimlogNode(child_node, current_path);
                    % Merge time (use first valid)
                    if isempty(time_data) && ~isempty(child_time)
                        time_data = child_time;
                    end
                    % Append child signals
                    signals = [signals, child_signals];
                catch ME
                    fprintf('Debug: Error accessing child %s: %s\n', child_ids{i}, ME.message);
                end
            end
        end

    catch ME
        fprintf('Debug: Error traversing Multibody node %s: %s\n', current_path, ME.message);
    end
end

% Helper function to extract time series data from various formats
function [time_data, values_data] = extractTimeSeriesData(data_obj, signal_path)
    time_data = [];
    values_data = [];

    try
        if isa(data_obj, 'timeseries')
            % MATLAB timeseries object
            time_data = data_obj.Time;
            values_data = data_obj.Data;
            fprintf('Debug: Extracted timeseries from %s\n', signal_path);
        elseif isstruct(data_obj)
            % Struct with time/data fields
            if isfield(data_obj, 'time') && isfield(data_obj, 'signals')
                time_data = data_obj.time;
                if isstruct(data_obj.signals) && isfield(data_obj.signals, 'values')
                    values_data = data_obj.signals.values;
                    fprintf('Debug: Extracted struct time/signals from %s\n', signal_path);
                end
            elseif isfield(data_obj, 'Time') && isfield(data_obj, 'Data')
                time_data = data_obj.Time;
                values_data = data_obj.Data;
                fprintf('Debug: Extracted struct Time/Data from %s\n', signal_path);
            else
                % Check for direct numeric data in struct (constant matrices/vectors)
                fields = fieldnames(data_obj);
                for i = 1:length(fields)
                    field_name = fields{i};
                    field_value = data_obj.(field_name);
                    if isnumeric(field_value)
                        % Found numeric data - treat as constant and create mock time
                        num_elements = numel(field_value);
                        if num_elements >= 1 && num_elements <= 9
                            % Create a default time vector for constant data
                            time_data = linspace(0, 3, 3006)';  % Default 3 second simulation
                            values_data = field_value;
                            fprintf('Debug: Extracted constant numeric data from %s.%s (%d elements)\n', signal_path, field_name, num_elements);
                            break;  % Use first numeric field found
                        end
                    end
                end
            end
        elseif isnumeric(data_obj)
            % Direct numeric data (constant values)
            num_elements = numel(data_obj);
            if num_elements >= 1 && num_elements <= 9
                % Create a default time vector for constant data
                time_data = linspace(0, 3, 3006)';  % Default 3 second simulation
                values_data = data_obj;
                fprintf('Debug: Extracted direct numeric data from %s (%d elements)\n', signal_path, num_elements);
            end
        end

        % Ensure column vectors
        if ~isempty(time_data)
            time_data = time_data(:);
        end
        if ~isempty(values_data)
            if isvector(values_data)
                values_data = values_data(:);
            end
        end

    catch ME
        fprintf('Debug: Error extracting time series from %s: %s\n', signal_path, ME.message);
    end
end

% Extract all signals from Simscape Multibody using proper Children API
function [time_data, all_signals] = extractMultibodySignals(simlog)
    time_data = [];
    all_signals = {};

    try
        % Try to access child nodes using proper API
        child_nodes = [];
        try
            child_nodes = simlog.Children;
            fprintf('Debug: Found %d child nodes using Children property\n', length(child_nodes));
        catch
            try
                child_nodes = simlog.children;
                fprintf('Debug: Found %d child nodes using children property\n', length(child_nodes));
            catch
                try
                    child_nodes = simlog.Nodes;
                    fprintf('Debug: Found %d child nodes using Nodes property\n', length(child_nodes));
                catch
                    fprintf('Debug: Cannot access child nodes from simlog\n');
                    return;
                end
            end
        end

        if isempty(child_nodes)
            fprintf('Debug: No child nodes found in simlog\n');
            return;
        end

        % Process each child node (bodies, joints, etc.)
        for i = 1:length(child_nodes)
            try
                child_node = child_nodes(i);
                node_name = '';

                % Get node name
                try
                    node_name = child_node.Name;
                catch
                    try
                        node_name = child_node.name;
                    catch
                        node_name = sprintf('Node_%d', i);
                    end
                end

                fprintf('Debug: Processing node: %s\n', node_name);

                % Extract signals from this node
                [node_time, node_signals] = extractNodeSignals(child_node, node_name);

                % Use first time vector found
                if isempty(time_data) && ~isempty(node_time)
                    time_data = node_time;
                    fprintf('Debug: Using time from node: %s (length: %d)\n', node_name, length(time_data));
                end

                % Collect signals
                all_signals = [all_signals, node_signals];

            catch ME_child
                fprintf('Debug: Error processing child node %d: %s\n', i, ME_child.message);
                continue;
            end
        end

        fprintf('Debug: Total signals extracted: %d\n', length(all_signals));

    catch ME
        fprintf('Debug: Error in extractMultibodySignals: %s\n', ME.message);
    end
end

% Extract signals from a single node (joint, body, etc.)
function [time_data, signals] = extractNodeSignals(node, node_name)
    time_data = [];
    signals = {};

    try
        % Try to get signals from this node
        node_signals = [];
        try
            node_signals = node.Children;
        catch
            try
                node_signals = node.children;
            catch
                try
                    node_signals = node.Signals;
                catch
                    % This node might be a signal itself
                    if hasMethod(node, 'hasData')
                        try
                            if node.hasData()
                                [data, time] = node.getData();
                                if ~isempty(data) && ~isempty(time)
                                    time_data = time;
                                    safe_name = matlab.lang.makeValidName(node_name);
                                    signals{end+1} = struct('name', safe_name, 'data', data);
                                end
                            end
                        catch
                            % Skip this signal
                        end
                    end
                    return;
                end
            end
        end

        % Process each signal in this node
        for j = 1:length(node_signals)
            try
                signal = node_signals(j);
                signal_name = '';

                % Get signal name
                try
                    signal_name = signal.Name;
                catch
                    try
                        signal_name = signal.name;
                    catch
                        signal_name = sprintf('Signal_%d', j);
                    end
                end

                % Extract data from signal
                if hasMethod(signal, 'hasData')
                    try
                        if signal.hasData()
                            [data, time] = signal.getData();
                            if ~isempty(data) && ~isempty(time)
                                % Use first time vector
                                if isempty(time_data)
                                    time_data = time;
                                end

                                % Create safe variable name
                                full_name = sprintf('%s_%s', node_name, signal_name);
                                safe_name = matlab.lang.makeValidName(full_name);
                                safe_name = strrep(safe_name, '__', '_');

                                signals{end+1} = struct('name', safe_name, 'data', data);
                            end
                        end
                    catch ME_data
                        fprintf('Debug: Could not extract data from %s.%s: %s\n', node_name, signal_name, ME_data.message);
                    end
                end

            catch ME_signal
                fprintf('Debug: Error processing signal %d in node %s: %s\n', j, node_name, ME_signal.message);
                continue;
            end
        end

    catch ME
        fprintf('Debug: Error in extractNodeSignals for %s: %s\n', node_name, ME.message);
    end
end

% Check if an object has a specific method
function result = hasMethod(obj, method_name)
    result = false;
    try
        if isobject(obj)
            methods_list = methods(obj);
            result = any(strcmp(methods_list, method_name));
        end
    catch
        result = false;
    end
end

% FIXED: Extract workspace outputs (tout, xout, etc.)
function workspace_data = extractWorkspaceOutputs(simOut)
    workspace_data = [];

    try
        fprintf('Debug: Extracting workspace outputs\n');

        % Get available properties
        if isa(simOut, 'Simulink.SimulationOutput')
            available = simOut.who;
        else
            available = fieldnames(simOut);
        end

        fprintf('Debug: Available outputs: %s\n', strjoin(available, ', '));

        % Look for tout (time output)
        time_data = [];
        if ismember('tout', available)
            if isa(simOut, 'Simulink.SimulationOutput')
                time_data = simOut.get('tout');
            else
                time_data = simOut.tout;
            end
            fprintf('Debug: Found tout with length: %d\n', length(time_data));
        end

        if isempty(time_data)
            fprintf('Debug: No time output found\n');
            return;
        end

        data_cells = {time_data(:)};
        var_names = {'time'};

        % Look for xout (state output)
        if ismember('xout', available)
            if isa(simOut, 'Simulink.SimulationOutput')
                xout = simOut.get('xout');
            else
                xout = simOut.xout;
            end

            if ~isempty(xout) && size(xout, 1) == length(time_data)
                for i = 1:size(xout, 2)
                    data_cells{end+1} = xout(:, i);
                    var_names{end+1} = sprintf('x%d', i);
                end
                fprintf('Debug: Added xout with %d states\n', size(xout, 2));
            end
        end

        % Look for other numeric outputs
        for i = 1:length(available)
            var_name = available{i};

            % Skip already processed variables
            if ismember(var_name, {'tout', 'xout', 'logsout', 'simlog', 'CombinedSignalBus'})
                continue;
            end

            try
                if isa(simOut, 'Simulink.SimulationOutput')
                    var_data = simOut.get(var_name);
                else
                    var_data = simOut.(var_name);
                end

                if isnumeric(var_data) && length(var_data) == length(time_data)
                    data_cells{end+1} = var_data(:);
                    var_names{end+1} = var_name;
                    fprintf('Debug: Added workspace output %s\n', var_name);
                end
            catch
                % Skip variables that can't be accessed
                continue;
            end
        end

        if length(data_cells) > 1
            workspace_data = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created workspace outputs table with %d columns\n', width(workspace_data));
        end

    catch ME
        fprintf('Error extracting workspace outputs: %s\n', ME.message);
    end
end

% Resample data to desired frequency
function resampled_table = resampleDataToFrequency(data_table, target_freq, sim_time)
    resampled_table = data_table;

    try
        % Find time column
        time_col = find(contains(lower(data_table.Properties.VariableNames), 'time'), 1);
        if isempty(time_col)
            fprintf('Warning: No time column found, cannot resample\n');
            return;
        end

        original_time = data_table.(data_table.Properties.VariableNames{time_col});
        original_freq = 1 / mean(diff(original_time));

        fprintf('Original data: %d points at ~%.1f Hz\n', length(original_time), original_freq);
        fprintf('Target frequency: %.1f Hz\n', target_freq);

        % If target frequency is higher than original, no need to resample
        if target_freq >= original_freq
            fprintf('Target frequency >= original frequency, keeping original data\n');
            return;
        end

        % Calculate new time vector
        target_dt = 1 / target_freq;
        new_time = 0:target_dt:sim_time;

        % Ensure we don't exceed simulation time
        if new_time(end) > sim_time
            new_time = new_time(new_time <= sim_time);
        end

        fprintf('Resampling to %d points at %.1f Hz\n', length(new_time), target_freq);

        % Create new table with resampled data
        resampled_data = cell(1, width(data_table));
        resampled_data{time_col} = new_time';

        % Resample each column
        for col = 1:width(data_table)
            if col == time_col
                continue; % Already handled
            end

            original_data = data_table.(data_table.Properties.VariableNames{col});

            % Use interpolation for smooth resampling
            if isnumeric(original_data) && length(original_data) == length(original_time)
                try
                    % Use interp1 for interpolation
                    resampled_data{col} = interp1(original_time, original_data, new_time, 'linear', 'extrap')';
                catch
                    % Fallback to nearest neighbor if interpolation fails
                    fprintf('Warning: Using nearest neighbor interpolation for column %s\n', data_table.Properties.VariableNames{col});
                    resampled_data{col} = interp1(original_time, original_data, new_time, 'nearest', 'extrap')';
                end
            else
                % For non-numeric or mismatched data, use nearest neighbor
                resampled_data{col} = interp1(original_time, original_data, new_time, 'nearest', 'extrap')';
            end
        end

        % Create resampled table
        resampled_table = table(resampled_data{:}, 'VariableNames', data_table.Properties.VariableNames);

        fprintf('Successfully resampled data from %d to %d points (%.1f%% reduction)\n', ...
                length(original_time), length(new_time), ...
                100 * (1 - length(new_time) / length(original_time)));

    catch ME
        fprintf('Error resampling data: %s\n', ME.message);
        fprintf('Returning original data\n');
        resampled_table = data_table;
    end
end

% Enhanced CombinedSignalBus extraction for golf swing model
function data_table = extractFromCombinedSignalBusEnhanced(combinedBus, config)
    data_table = [];

    try
        fprintf('Debug: Processing CombinedSignalBus (enhanced method)\n');

        if ~isstruct(combinedBus)
            fprintf('Debug: CombinedSignalBus is not a struct\n');
            return;
        end

        bus_fields = fieldnames(combinedBus);
        fprintf('Debug: CombinedSignalBus fields: %s\n', strjoin(bus_fields, ', '));

        % Try to extract time from Simscape-style bus structure
        % Typically, one of the log structures should contain time
        time_data = [];
        time_source = '';

        % Look for any log structure that might contain valid data
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);

            if isstruct(field_value) && ~isempty(fieldnames(field_value))
                % This could be a log structure
                sub_fields = fieldnames(field_value);

                % Look for any numeric field that could be time or data
                for j = 1:length(sub_fields)
                    sub_field = field_value.(sub_fields{j});

                    % Check if this is numeric data with reasonable length
                    if isnumeric(sub_field) && length(sub_field) > 10
                        if isempty(time_data) || length(sub_field) > length(time_data)
                            % Assume this could be our time reference
                            time_data = (0:length(sub_field)-1)' * (config.simulation_time / (length(sub_field)-1));
                            time_source = sprintf('%s.%s', field_name, sub_fields{j});
                            fprintf('Debug: Generated time from %s (length: %d)\n', time_source, length(time_data));
                            break;
                        end
                    end
                end
            end

            if ~isempty(time_data)
                break;
            end
        end

        if isempty(time_data)
            % If we still don't have time, generate a default time vector
            fprintf('Debug: No suitable data found for time reference, cannot proceed\n');
            return;
        end

        % Now extract all data using this time reference
        data_cells = {time_data};
        var_names = {'time'};
        expected_length = length(time_data);

        % Extract all signals that match our time length
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);

            if isstruct(field_value)
                sub_fields = fieldnames(field_value);

                for j = 1:length(sub_fields)
                    sub_field_name = sub_fields{j};
                    sub_field_value = field_value.(sub_field_name);

                    if isnumeric(sub_field_value) && length(sub_field_value) == expected_length
                        % Single column data
                        data_cells{end+1} = sub_field_value(:);
                        var_names{end+1} = sprintf('%s_%s', field_name, sub_field_name);
                    elseif isnumeric(sub_field_value) && size(sub_field_value, 1) == expected_length
                        % Multi-column data
                        for col = 1:size(sub_field_value, 2)
                            data_cells{end+1} = sub_field_value(:, col);
                            var_names{end+1} = sprintf('%s_%s_%d', field_name, sub_field_name, col);
                        end
                    end
                end
            end
        end

        if length(data_cells) > 1
            data_table = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created enhanced CombinedSignalBus table with %d columns\n', width(data_table));
        end

    catch ME
        fprintf('Error in enhanced CombinedSignalBus extraction: %s\n', ME.message);
    end
end

% Check model configuration for data logging
function checkModelConfiguration(model_name)
    % Check if model is configured for proper data logging
    try
        fprintf('\n=== Checking Model Configuration ===\n');

        % Check if model is loaded
        if ~bdIsLoaded(model_name)
            fprintf('Model %s is not loaded\n', model_name);
            return;
        end

        % Check solver settings
        solver = get_param(model_name, 'Solver');
        fprintf('Solver: %s\n', solver);

        % Check logging settings
        signal_logging = get_param(model_name, 'SignalLogging');
        fprintf('Signal Logging: %s\n', signal_logging);

        % Check Simscape settings if available
        try
            simscape_log_type = get_param(model_name, 'SimscapeLogType');
            fprintf('Simscape Log Type: %s\n', simscape_log_type);
        catch
            fprintf('Simscape Log Type: Not available or not a Simscape model\n');
        end

        % Check for To Workspace blocks
        to_workspace_blocks = find_system(model_name, 'BlockType', 'ToWorkspace');
        fprintf('Found %d To Workspace blocks\n', length(to_workspace_blocks));

        % Check for Bus Creator blocks (for CombinedSignalBus)
        bus_creators = find_system(model_name, 'BlockType', 'BusCreator');
        fprintf('Found %d Bus Creator blocks\n', length(bus_creators));

        % Look for a bus named CombinedSignalBus
        for i = 1:length(bus_creators)
            try
                output_signal = get_param(bus_creators{i}, 'OutputSignalNames');
                if contains(output_signal, 'CombinedSignalBus')
                    fprintf('Found CombinedSignalBus at: %s\n', bus_creators{i});
                end
            catch
                % Some bus creators might not have output signal names
            end
        end

        fprintf('=================================\n\n');

    catch ME
        fprintf('Error checking model configuration: %s\n', ME.message);
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
            [~, hostname] = system('hostname');
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

% Check if Simscape logging is properly configured in the model
function checkSimscapeLoggingEnabled(model_name)
    try
        fprintf('\n=== Checking Simscape Logging Configuration ===\n');

        % Check if model is loaded
        if ~bdIsLoaded(model_name)
            load_system(model_name);
        end

        % Check Simscape logging parameters
        try
            log_type = get_param(model_name, 'SimscapeLogType');
            fprintf('SimscapeLogType: %s\n', log_type);

            if strcmp(log_type, 'none')
                fprintf('WARNING: Simscape logging is disabled!\n');
                fprintf('To enable: set_param(''%s'', ''SimscapeLogType'', ''all'')\n', model_name);
            end
        catch
            fprintf('SimscapeLogType parameter not found (might not be a Simscape model)\n');
        end

        % Check for Simscape blocks
        simscape_blocks = find_system(model_name, 'SimulinkSubDomain', 'Simscape');
        fprintf('Found %d Simscape blocks\n', length(simscape_blocks));

        % Check for Simscape Multibody blocks specifically
        multibody_blocks = find_system(model_name, 'ReferenceBlock', 'sm_lib/');
        fprintf('Found %d potential Simscape Multibody blocks\n', length(multibody_blocks));

        fprintf('=====================================\n\n');

    catch ME
        fprintf('Error checking Simscape configuration: %s\n', ME.message);
    end
end

% Quick test to verify Simscape logging
function testSimscapeLogging(model_name)
    try
        % Load and configure model
        load_system(model_name);
        set_param(model_name, 'SimscapeLogType', 'all');

        % Run a short simulation
        simOut = sim(model_name, 'StopTime', '0.1');

        % Check for simlog
        if isfield(simOut, 'simlog') || isprop(simOut, 'simlog')
            fprintf('✓ Simscape logging is working!\n');
            simlog = simOut.simlog;
            fprintf('  Simlog type: %s\n', class(simlog));

            % Try to list some nodes
            if isa(simlog, 'simscape.logging.Node')
                props = properties(simlog);
                fprintf('  Top-level nodes: %s\n', strjoin(props, ', '));
            end
        else
            fprintf('✗ No simlog found in simulation output\n');
        end

    catch ME
        fprintf('Error testing Simscape logging: %s\n', ME.message);
    end
end

% Grok's table merger function for cleaner data merging
function merged = mergeTables(varargin)
    merged = table();
    for i = 1:nargin
        if ~isempty(varargin{i})
            if isempty(merged)
                merged = varargin{i};
            else
                % Outer join on 'time', assuming time is consistent
                merged = outerjoin(merged, varargin{i}, 'Keys', 'time', 'MergeKeys', true);
            end
        end
    end
end

% Helper function to convert logical to string
function str = logical2str(logical_val)
    if logical_val
        str = 'enabled';
    else
        str = 'disabled';
    end
end
