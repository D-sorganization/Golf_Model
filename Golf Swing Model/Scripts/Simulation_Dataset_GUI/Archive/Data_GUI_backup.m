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
    
    h1 = 0.22 * availableHeight;
    h2 = 0.20 * availableHeight;
    h3 = 0.33 * availableHeight;
    h4 = 0.25 * availableHeight;
    
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
    
    % File status
    handles.file_status_text = uicontrol('Parent', panel, ...
                                       'Style', 'text', ...
                                       'String', '', ...
                                       'Units', 'normalized', ...
                                       'Position', [labelWidth + fieldSpacing, y-0.12, 0.6, 0.08], ...
                                       'FontSize', 8, ...
                                       'ForegroundColor', colors.success, ...
                                       'HorizontalAlignment', 'left', ...
                                       'BackgroundColor', colors.panel);
    
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
    
    handles.use_model_workspace = uicontrol('Parent', panel, ...
                                           'Style', 'checkbox', ...
                                           'String', 'Workspace', ...
                                           'Units', 'normalized', ...
                                           'Position', [0.18, y, 0.19, rowHeight], ...
                                           'Value', 1, ...
                                           'BackgroundColor', colors.panel);
    
    handles.use_logsout = uicontrol('Parent', panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Logsout', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.37, y, 0.19, rowHeight], ...
                                   'Value', 1, ...
                                   'BackgroundColor', colors.panel);
    
    handles.use_signal_bus = uicontrol('Parent', panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'Signal Bus', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.56, y, 0.19, rowHeight], ...
                                      'Value', 1, ...
                                      'BackgroundColor', colors.panel);
    
    handles.use_simscape = uicontrol('Parent', panel, ...
                                    'Style', 'checkbox', ...
                                    'String', 'Simscape', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.75, y, 0.19, rowHeight], ...
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
        num_trials = min(num_trials, 100); % Limit for display
        
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        % Get parameter info
        param_info = getPolynomialParameterInfo();
        total_columns = 1 + param_info.total_params;
        
        % Generate coefficient data
        coeff_data = cell(num_trials, total_columns);
        
        for i = 1:num_trials
            coeff_data{i, 1} = i; % Trial number
            
            col_idx = 2;
            for joint_idx = 1:length(param_info.joint_names)
                coeffs = param_info.joint_coeffs{joint_idx};
                for coeff_idx = 1:length(coeffs)
                    coeff_letter = coeffs(coeff_idx);
                    
                    switch scenario_idx
                        case 1 % Variable Torques
                            if ~isnan(coeff_range) && coeff_range > 0
                                coeff_data{i, col_idx} = sprintf('%.2f', (rand - 0.5) * 2 * coeff_range);
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
        set(handles.file_status_text, 'String', 'File loaded successfully');
        
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
    set(handles.file_status_text, 'String', '');
    
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
    config.use_model_workspace = get(handles.use_model_workspace, 'Value');
    config.use_logsout = get(handles.use_logsout, 'Value');
    config.use_signal_bus = get(handles.use_signal_bus, 'Value');
    config.use_simscape = get(handles.use_simscape, 'Value');
    config.enable_animation = get(handles.enable_animation, 'Value');
    config.output_folder = get(handles.output_folder_edit, 'String');
    config.folder_name = get(handles.folder_name_edit, 'String');
    config.format = get(handles.format_popup, 'Value');
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
    if isfield(config, 'use_model_workspace')
        set(handles.use_model_workspace, 'Value', config.use_model_workspace);
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
    if isfield(config, 'format')
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
    
    % Run parallel simulations
    set(handles.progress_text, 'String', 'Running parallel simulations...');
    drawnow;
    
    try
        % Use parsim for parallel simulation with model transfer
        simOuts = parsim(simInputs, 'ShowProgress', true, 'ShowSimulationManager', 'off', ...
                        'TransferBaseWorkspaceVariables', 'on', ...
                        'AttachedFiles', {config.model_path});
        
        % Process results
        successful_trials = 0;
        for i = 1:length(simOuts)
            if ~isempty(simOuts(i)) && simOuts(i).SimulationMetadata.ExecutionInfo.StopEvent == 'CompletedNormally'
                try
                    result = processSimulationOutput(i, config, simOuts(i));
                    if result.success
                        successful_trials = successful_trials + 1;
                    end
                catch ME
                    fprintf('Error processing trial %d: %s\n', i, ME.message);
                end
            end
        end
        
    catch ME
        fprintf('Parallel simulation failed: %s\n', ME.message);
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
    
    % Set coefficients as model variables
    global_coeff_idx = 1;
    for joint_idx = 1:length(param_info.joint_names)
        joint_name = param_info.joint_names{joint_idx};
        coeffs = param_info.joint_coeffs{joint_idx};
        
        for local_coeff_idx = 1:length(coeffs)
            coeff_letter = coeffs(local_coeff_idx);
            var_name = sprintf('%s%s', joint_name, coeff_letter);
            
            if global_coeff_idx <= length(coefficients)
                simIn = simIn.setVariable(var_name, coefficients(global_coeff_idx));
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
        
        % Run simulation with progress indicator
        fprintf('Running trial %d simulation...', trial_num);
        simOut = sim(simIn);
        fprintf(' Done.\n');
        
        % Add inspection for debugging
        inspectSimulationOutput(simOut);
        
        % Restore warning state
        warning(warning_state);
        warning(warning_state2);
        
        % Process simulation output
        result = processSimulationOutput(trial_num, config, simOut);
        
    catch ME
        % Restore warning state in case of error
        if exist('warning_state', 'var')
            warning(warning_state);
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
    % Set basic simulation parameters
    try
        % Set stop time
        if isfield(config, 'simulation_time') && ~isempty(config.simulation_time)
            simIn = simIn.setModelParameter('StopTime', num2str(config.simulation_time));
        end
        
        % Set solver
        simIn = simIn.setModelParameter('Solver', 'ode23t');
        
        % Set tolerances
        simIn = simIn.setModelParameter('RelTol', '1e-3');
        simIn = simIn.setModelParameter('AbsTol', '1e-5');
        
        % CRITICAL: Set output options for data logging
        simIn = simIn.setModelParameter('SaveOutput', 'on');
        simIn = simIn.setModelParameter('SaveFormat', 'Structure'); % Changed to Structure for To Workspace blocks
        simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');
        
        % Additional settings that might help
        simIn = simIn.setModelParameter('SignalLogging', 'on');
        simIn = simIn.setModelParameter('SaveTime', 'on');
        
        % If using To Workspace blocks, ensure they're configured properly
        simIn = simIn.setModelParameter('LimitDataPoints', 'off');
        
        % FIXED: Ensure To Workspace blocks save to 'out' variable
        
        % Apply animation setting
        if isfield(config, 'enable_animation')
            if config.enable_animation
                simIn = simIn.setModelParameter('SimMechanicsOpenGL', 'on');
                fprintf('Animation enabled for simulation\n');
            else
                simIn = simIn.setModelParameter('SimMechanicsOpenGL', 'off');
            end
        end
        
        % Debug messages removed to clean up output
        
    catch ME
        fprintf('Error setting model parameters: %s\n', ME.message);
        rethrow(ME);
    end
end
function result = processSimulationOutput(trial_num, config, simOut)
    result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);
    
    try
        fprintf('Processing simulation output for trial %d...\n', trial_num);
        
        % Extract data based on selected sources
        data_table = extractSimulationData(simOut, config);
        
        if isempty(data_table)
            result.error = 'No data extracted from simulation';
            fprintf('No data extracted from simulation output\n');
            return;
        end
        
        fprintf('Extracted %d rows of data\n', height(data_table));
        
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
        
        % Save to file
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        filename = sprintf('trial_%03d_%s.csv', trial_num, timestamp);
        filepath = fullfile(config.output_folder, filename);
        
        writetable(data_table, filepath);
        
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
function data_table = extractSimulationData(simOut, config)
    data_table = [];
    
    try
        fprintf('Debug: Simulation output type: %s\n', class(simOut));
        
        % Check for simulation errors
        if isprop(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
            fprintf('Debug: Simulation error: %s\n', simOut.ErrorMessage);
            return;
        end
        
        fprintf('Debug: Extracting data from simulation output\n');
        all_data = {};
        
        % FIXED: Extract from CombinedSignalBus (this is the key fix!)
        if config.use_signal_bus && (isprop(simOut, 'CombinedSignalBus') || isfield(simOut, 'CombinedSignalBus'))
            fprintf('Debug: Extracting CombinedSignalBus data...\n');
            if isprop(simOut, 'CombinedSignalBus')
                combinedBus = simOut.CombinedSignalBus;
            else
                combinedBus = simOut.CombinedSignalBus;
            end
            
            if ~isempty(combinedBus)
                signal_bus_data = extractFromCombinedSignalBus(combinedBus);
                if ~isempty(signal_bus_data)
                    all_data{end+1} = signal_bus_data;
                    fprintf('Debug: CombinedSignalBus data extracted successfully (%d columns)\n', width(signal_bus_data));
                end
            end
        end
        
        % FIXED: Extract from logsout (improved handling of Signal objects)
        if config.use_logsout && (isprop(simOut, 'logsout') || isfield(simOut, 'logsout'))
            fprintf('Debug: Extracting logsout data from simOut...\n');
            if isprop(simOut, 'logsout')
                logsout = simOut.logsout;
            else
                logsout = simOut.logsout;
            end
            
            logsout_data = extractLogsoutDataFixed(logsout);
            if ~isempty(logsout_data)
                all_data{end+1} = logsout_data;
                fprintf('Debug: Logsout data extracted successfully (%d columns)\n', width(logsout_data));
            end
        end
        
        % FIXED: Extract from Simscape data (corrected method calls)
        if config.use_simscape && (isprop(simOut, 'simlog') || isfield(simOut, 'simlog'))
            fprintf('Debug: Extracting Simscape data from simOut...\n');
            if isprop(simOut, 'simlog')
                simlog = simOut.simlog;
            else
                simlog = simOut.simlog;
            end
            
            simscape_data = extractSimscapeDataFixed(simlog);
            if ~isempty(simscape_data)
                all_data{end+1} = simscape_data;
                fprintf('Debug: Simscape data extracted successfully (%d columns)\n', width(simscape_data));
            end
        end
        
        % Extract from workspace outputs (tout, xout, etc.)
        if config.use_model_workspace
            fprintf('Debug: Extracting workspace outputs...\n');
            workspace_data = extractWorkspaceOutputs(simOut);
            if ~isempty(workspace_data)
                all_data{end+1} = workspace_data;
                fprintf('Debug: Workspace data extracted successfully (%d columns)\n', width(workspace_data));
            end
        end
        
        % Combine all data sources
        if ~isempty(all_data)
            data_table = combineDataSources(all_data);
            fprintf('Debug: Combined data table created with %d rows, %d columns\n', height(data_table), width(data_table));
        else
            fprintf('Debug: No data extracted from any source\n');
        end
        
    catch ME
        fprintf('Error extracting simulation data: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end
function workspace_data = extractWorkspaceData(out)
    workspace_data = [];
    
    try
        fprintf('Debug: Extracting workspace data from out structure\n');
        
        % Get all fields from the out structure
        if isstruct(out)
            fields = fieldnames(out);
            fprintf('Debug: Available fields in out: %s\n', strjoin(fields, ', '));
            
            % Look for time data first
            time_field = '';
            time_data = [];
            
            % Common time field names
            time_field_names = {'time', 'tout', 'Time', 'TIME'};
            for i = 1:length(time_field_names)
                if ismember(time_field_names{i}, fields)
                    time_field = time_field_names{i};
                    time_data = out.(time_field);
                    fprintf('Debug: Found time field: %s (length: %d)\n', time_field, length(time_data));
                    break;
                end
            end
            
            if isempty(time_data)
                fprintf('Debug: No time field found, cannot extract workspace data\n');
                return;
            end
            
            % Extract all numeric data fields
            data_cells = {time_data};
            var_names = {'time'};
            
            for i = 1:length(fields)
                field_name = fields{i};
                
                % Skip time field and non-numeric fields
                if strcmp(field_name, time_field) || strcmp(field_name, 'logsout') || strcmp(field_name, 'simlog')
                    continue;
                end
                
                field_value = out.(field_name);
                
                % Handle different data types
                if isnumeric(field_value)
                    if length(field_value) == length(time_data)
                        data_cells{end+1} = field_value(:);  % Ensure column vector
                        var_names{end+1} = field_name;
                        fprintf('Debug: Added numeric field %s (length: %d)\n', field_name, length(field_value));
                    else
                        fprintf('Debug: Skipping field %s (length mismatch: %d vs %d)\n', field_name, length(field_value), length(time_data));
                    end
                elseif isstruct(field_value)
                    % Handle struct fields (e.g., signal buses)
                    struct_data = extractFromStructField(field_value, field_name, time_data);
                    if ~isempty(struct_data)
                        % Merge the struct data
                        if isempty(workspace_data)
                            workspace_data = struct_data;
                        else
                            workspace_data = mergeTables(workspace_data, struct_data);
                        end
                    end
                elseif isa(field_value, 'timeseries')
                    % Handle timeseries objects
                    if length(field_value.Data) == length(time_data)
                        data_cells{end+1} = field_value.Data(:);
                        var_names{end+1} = field_name;
                        fprintf('Debug: Added timeseries field %s\n', field_name);
                    end
                end
            end
            
            % Create table if we have data
            if length(data_cells) > 1
                workspace_data = table(data_cells{:}, 'VariableNames', var_names);
                fprintf('Debug: Created workspace table with %d columns\n', width(workspace_data));
            else
                fprintf('Debug: No valid workspace data found\n');
            end
        else
            fprintf('Debug: Out is not a struct, cannot extract workspace data\n');
        end
        
    catch ME
        fprintf('Error extracting workspace data: %s\n', ME.message);
    end
end
function struct_data = extractFromStructField(struct_value, struct_name, time_data)
    struct_data = [];
    
    try
        if ~isstruct(struct_value)
            return;
        end
        
        struct_fields = fieldnames(struct_value);
        data_cells = {};
        var_names = {};
        
        for i = 1:length(struct_fields)
            field_name = struct_fields{i};
            field_value = struct_value.(field_name);
            
            if isnumeric(field_value) && length(field_value) == length(time_data)
                data_cells{end+1} = field_value(:);
                var_names{end+1} = sprintf('%s_%s', struct_name, field_name);
            elseif isstruct(field_value)
                % Recursively extract nested struct data
                nested_data = extractFromStructField(field_value, sprintf('%s_%s', struct_name, field_name), time_data);
                if ~isempty(nested_data)
                    if isempty(struct_data)
                        struct_data = nested_data;
                    else
                        struct_data = mergeTables(struct_data, nested_data);
                    end
                end
            end
        end
        
        if ~isempty(data_cells)
            struct_data = table(data_cells{:}, 'VariableNames', var_names);
        end
        
    catch ME
        fprintf('Error extracting from struct field %s: %s\n', struct_name, ME.message);
    end
end
function merged_table = mergeTables(table1, table2)
    merged_table = table1;
    
    try
        if isempty(table1)
            merged_table = table2;
            return;
        end
        
        if isempty(table2)
            return;
        end
        
        % Find common time column
        time_col1 = find(contains(lower(table1.Properties.VariableNames), 'time'), 1);
        time_col2 = find(contains(lower(table2.Properties.VariableNames), 'time'), 1);
        
        if ~isempty(time_col1) && ~isempty(time_col2)
            % Merge on time column
            merged_table = outerjoin(table1, table2, 'Keys', {table1.Properties.VariableNames{time_col1}, table2.Properties.VariableNames{time_col2}}, 'MergeKeys', true);
        else
            % Simple concatenation
            merged_table = [table1, table2];
        end
        
    catch ME
        fprintf('Error merging tables: %s\n', ME.message);
        merged_table = table1;  % Return original if merge fails
    end
end
function data_table = extractSignalBusStructs(out)
    data_table = [];
    
    try
        % Define expected signal bus structs based on the model
        % FIXED: More flexible naming patterns
        expectedLogStructs = {
            'HipLogs', 'SpineLogs', 'TorsoLogs', ...
            'LSLogs', 'RSLogs', 'LELogs', 'RELogs', ...
            'LWLogs', 'RWLogs', 'LScapLogs', 'RScapLogs', ...
            'LFLogs', 'RFLogs', 'CombinedSignalBus'
        };
        
        % Also check for common variations
        alternativeNames = {
            'Hip_Logs', 'Spine_Logs', 'Torso_Logs', ...
            'LS_Logs', 'RS_Logs', 'LE_Logs', 'RE_Logs', ...
            'LW_Logs', 'RW_Logs', 'LScap_Logs', 'RScap_Logs', ...
            'LF_Logs', 'RF_Logs', ...
            'HipLog', 'SpineLog', 'TorsoLog', ...
            'LSLog', 'RSLog', 'LELog', 'RELog', ...
            'LWLog', 'RWLog', 'LScapLog', 'RScapLog', ...
            'LFLog', 'RFLog', ...
            'CombinedSignalBus', 'SignalBus', 'BusCreator'
        };
        
        all_data = {};
        found_structs = {};
        
        % Get all available fields in the out structure
        if isstruct(out)
            available_fields = fieldnames(out);
            fprintf('Debug: Available fields in out structure: %s\n', strjoin(available_fields, ', '));
            
            % Check for exact matches first
            for i = 1:length(expectedLogStructs)
                structName = expectedLogStructs{i};
                
                if isfield(out, structName) && ~isempty(out.(structName))
                    fprintf('Debug: Found exact match %s\n', structName);
                    found_structs{end+1} = structName;
                    
                    logStruct = out.(structName);
                    if isstruct(logStruct)
                        struct_data = extractFromLogStruct(logStruct, structName);
                        if ~isempty(struct_data)
                            all_data{end+1} = struct_data;
                        end
                    elseif isa(logStruct, 'timeseries')
                        % Handle timeseries directly
                        fprintf('Debug: Found timeseries %s\n', structName);
                        time = logStruct.Time;
                        data = logStruct.Data;
                        if isnumeric(data) && length(data) == length(time)
                            struct_data = table(time, data, 'VariableNames', {'time', structName});
                            all_data{end+1} = struct_data;
                        end
                    end
                end
            end
            
            % Check for alternative names
            for i = 1:length(alternativeNames)
                structName = alternativeNames{i};
                
                if isfield(out, structName) && ~isempty(out.(structName))
                    fprintf('Debug: Found alternative match %s\n', structName);
                    found_structs{end+1} = structName;
                    
                    logStruct = out.(structName);
                    if isstruct(logStruct)
                        struct_data = extractFromLogStruct(logStruct, structName);
                        if ~isempty(struct_data)
                            all_data{end+1} = struct_data;
                        end
                    elseif isa(logStruct, 'timeseries')
                        % Handle timeseries directly
                        fprintf('Debug: Found timeseries %s\n', structName);
                        time = logStruct.Time;
                        data = logStruct.Data;
                        if isnumeric(data) && length(data) == length(time)
                            struct_data = table(time, data, 'VariableNames', {'time', structName});
                            all_data{end+1} = struct_data;
                        end
                    end
                end
            end
            
            % Check for any field ending with 'Logs' or 'Log' or containing 'Bus'
            for i = 1:length(available_fields)
                fieldName = available_fields{i};
                
                % Skip if already processed
                if ismember(fieldName, found_structs)
                    continue;
                end
                
                % Check if field name suggests it's a log structure or bus
                if ((endsWith(fieldName, 'Logs') || endsWith(fieldName, 'Log') || contains(fieldName, 'Bus')) && ...
                   ~isempty(out.(fieldName)) && (isstruct(out.(fieldName)) || isa(out.(fieldName), 'timeseries')))
                    fprintf('Debug: Found log/bus-like field %s\n', fieldName);
                    found_structs{end+1} = fieldName;
                    
                    logStruct = out.(fieldName);
                    if isstruct(logStruct)
                        struct_data = extractFromLogStruct(logStruct, fieldName);
                        if ~isempty(struct_data)
                            all_data{end+1} = struct_data;
                        end
                    elseif isa(logStruct, 'timeseries')
                        % Handle timeseries directly
                        fprintf('Debug: Found timeseries %s\n', fieldName);
                        time = logStruct.Time;
                        data = logStruct.Data;
                        if isnumeric(data) && length(data) == length(time)
                            struct_data = table(time, data, 'VariableNames', {'time', fieldName});
                            all_data{end+1} = struct_data;
                        end
                    end
                end
            end
        end
        
        fprintf('Debug: Found signal bus structs: %s\n', strjoin(found_structs, ', '));
        
        % Combine all signal bus data
        if ~isempty(all_data)
            data_table = combineDataSources(all_data);
            fprintf('Debug: Combined signal bus data into table with %d columns\n', width(data_table));
        else
            fprintf('Debug: No signal bus data found\n');
        end
        
    catch ME
        fprintf('Error extracting signal bus structs: %s\n', ME.message);
    end
end
function data_table = extractFromLogStruct(logStruct, structName)
    data_table = [];
    try
        % Find time field (existing code is fine, but make robust)
        structFields = fieldnames(logStruct);
        time_field = '';
        for i = 1:length(structFields)
            if contains(lower(structFields{i}), 'time')
                time_field = structFields{i};
                break;
            end
        end
        if isempty(time_field)
            fprintf('Debug: No time field in %s\n', structName);
            return;
        end
        time = logStruct.(time_field);
        data_cells = {time};
        var_names = {'time'};
        % Special handling for 'signals' struct array (key fix)
        if isfield(logStruct, 'signals') && isstruct(logStruct.signals)
            signals = logStruct.signals;
            fprintf('Debug: Found %d signals in %s\n', length(signals), structName);
            for k = 1:length(signals)
                if isfield(signals(k), 'values') && isfield(signals(k), 'label')
                    data = signals(k).values;
                    
                    % Handle multi-dimensional data
                    if isnumeric(data)
                        % Check dimensions
                        data_size = size(data);
                        if data_size(1) == length(time)
                            % Data is time x dimensions
                            if length(data_size) == 2 && data_size(2) > 1
                                % Multiple columns (e.g., XYZ data)
                                dim_labels = {'X', 'Y', 'Z', 'W'};
                                for dim = 1:data_size(2)
                                    dim_label = '';
                                    if dim <= length(dim_labels)
                                        dim_label = ['_' dim_labels{dim}];
                                    else
                                        dim_label = sprintf('_dim%d', dim);
                                    end
                                    
                                    name = signals(k).label;
                                    if isempty(name)
                                        name = sprintf('signal%d', k);
                                    end
                                    full_name = sprintf('%s_%s%s', structName, name, dim_label);
                                    
                                    data_cells{end+1} = data(:, dim);
                                    var_names{end+1} = full_name;
                                    fprintf('Debug: Added multi-dim signal %s to %s\n', full_name, structName);
                                end
                            else
                                % Single column
                                name = signals(k).label;
                                if isempty(name)
                                    name = sprintf('signal%d', k);
                                end
                                full_name = sprintf('%s_%s', structName, name);
                                data_cells{end+1} = data(:);
                                var_names{end+1} = full_name;
                                fprintf('Debug: Added signal %s to %s\n', full_name, structName);
                            end
                        else
                            fprintf('Debug: Skipping signal %d in %s (dimension mismatch: %s vs time: %d)\n', k, structName, mat2str(data_size), length(time));
                        end
                    else
                        fprintf('Debug: Skipping non-numeric signal %d in %s\n', k, structName);
                    end
                else
                    fprintf('Debug: Signal %d in %s missing values or label field\n', k, structName);
                end
            end
        end
        % Existing loop for other fields (e.g., non-bus data)
        for i = 1:length(structFields)
            fieldName = structFields{i};
            if strcmp(fieldName, time_field) || strcmp(fieldName, 'signals')
                continue;  % Skip time and signals (already handled)
            end
            
            fieldValue = logStruct.(fieldName);
            
            % Handle timeseries objects
            if isa(fieldValue, 'timeseries')
                data = fieldValue.Data;
                if isnumeric(data) && length(data) == length(time)
                    data_cells{end+1} = data;
                    var_names{end+1} = sprintf('%s_%s', structName, fieldName);
                end
            % Handle structs with .Data field
            elseif isstruct(fieldValue) && isfield(fieldValue, 'Data')
                data = fieldValue.Data;
                if isnumeric(data) && length(data) == length(time)
                    data_cells{end+1} = data;
                    var_names{end+1} = sprintf('%s_%s', structName, fieldName);
                end
            % Handle numeric arrays
            elseif isnumeric(fieldValue) && length(fieldValue) == length(time)
                data_cells{end+1} = fieldValue;
                var_names{end+1} = sprintf('%s_%s', structName, fieldName);
            end
        end
        if length(data_cells) > 1
            data_table = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created table with %d columns from %s\n', width(data_table), structName);
        else
            fprintf('Debug: No valid data found in %s (only time column)\n', structName);
        end
    catch ME
        fprintf('Error extracting from %s: %s\n', structName, ME.message);
    end
end
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
function simscape_data = extractSimscapeDataFixed(simlog)
    simscape_data = [];
    
    try
        fprintf('Debug: Extracting Simscape data\n');
        
        if ~isempty(simlog) && isa(simlog, 'simscape.logging.Node')
            % Get series data - this is the correct way to access Simscape data
            try
                series_info = simlog.series();
                if ~isempty(series_info)
                    time = series_info.time;
                    fprintf('Debug: Found Simscape time series, length: %d\n', length(time));
                    
                    data_cells = {time};
                    var_names = {'time'};
                    
                    % Get all logged variables
                    logged_vars = simlog.listVariables('-all');
                    fprintf('Debug: Found %d Simscape variables\n', length(logged_vars));
                    
                    for i = 1:length(logged_vars)
                        var_name = logged_vars{i};
                        try
                            var_data = simlog.find(var_name);
                            if ~isempty(var_data) && isprop(var_data, 'series')
                                var_series = var_data.series();
                                if ~isempty(var_series) && length(var_series.values) == length(time)
                                    data_cells{end+1} = var_series.values;
                                    var_names{end+1} = strrep(var_name, '.', '_');
                                    fprintf('Debug: Added Simscape variable %s\n', var_name);
                                end
                            end
                        catch
                            % Skip variables that can't be accessed
                            continue;
                        end
                    end
                    
                    if length(data_cells) > 1
                        simscape_data = table(data_cells{:}, 'VariableNames', var_names);
                        fprintf('Debug: Created Simscape table with %d columns\n', width(simscape_data));
                    end
                end
            catch ME2
                fprintf('Debug: Could not access Simscape series data: %s\n', ME2.message);
            end
        else
            fprintf('Debug: Simlog is not a valid Simscape logging node\n');
        end
        
    catch ME
        fprintf('Error extracting Simscape data: %s\n', ME.message);
    end
end



function data_table = addModelWorkspaceData(data_table, simOut, num_rows)
    % Extract model workspace variables and add as constant columns
    % These include segment lengths, masses, inertias, and other model parameters
    
    try
        % Get model workspace from simulation output
        model_name = simOut.SimulationMetadata.ModelInfo.ModelName;
        model_workspace = get_param(model_name, 'ModelWorkspace');
        variables = model_workspace.getVariableNames;
        
        fprintf('Adding %d model workspace variables to CSV...\n', length(variables));
        
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

function combined_table = combineDataSources(data_sources)
    combined_table = [];
    
    try
        if isempty(data_sources)
            return;
        end
        
        % Start with the first data source
        combined_table = data_sources{1};
        
        % Merge additional data sources
        for i = 2:length(data_sources)
            if ~isempty(data_sources{i})
                % Find common time column
                if ismember('time', combined_table.Properties.VariableNames) && ...
                   ismember('time', data_sources{i}.Properties.VariableNames)
                    
                    % Merge on time column
                    combined_table = outerjoin(combined_table, data_sources{i}, 'Keys', 'time', 'MergeKeys', true);
                else
                    % Simple concatenation if no common time
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
        if scenario_idx == 3 && isnan(constant_value)
            error('Constant value must be numeric for constant torque');
        end
        
        if ~get(handles.use_model_workspace, 'Value') && ...
           ~get(handles.use_logsout, 'Value') && ...
           ~get(handles.use_signal_bus, 'Value') && ...
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
        config.use_model_workspace = get(handles.use_model_workspace, 'Value');
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
        
        % Initialize master table
        master_data = [];
        
        for i = 1:length(csv_files)
            file_path = fullfile(config.output_folder, csv_files(i).name);
            fprintf('Reading %s...\n', csv_files(i).name);
            
            try
                trial_data = readtable(file_path);
                
                if isempty(master_data)
                    master_data = trial_data;
                else
                    % Ensure consistent columns
                    common_vars = intersect(master_data.Properties.VariableNames, ...
                                          trial_data.Properties.VariableNames);
                    if ~isempty(common_vars)
                        master_data = [master_data(:, common_vars); trial_data(:, common_vars)];
                    end
                end
                
            catch ME
                warning('Failed to read %s: %s', csv_files(i).name, ME.message);
            end
        end
        
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
                set(handles.file_status_text, 'String', 'File loaded from preferences');
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
function inspectSimulationOutput(simOut)
    fprintf('\n=== Simulation Output Inspection ===\n');
    fprintf('Type: %s\n', class(simOut));
    
    if isa(simOut, 'Simulink.SimulationOutput')
        fprintf('Available data:\n');
        available = simOut.who;
        for i = 1:length(available)
            fprintf('  - %s\n', available{i});
        end
        
        % Check for 'out' specifically
        if ismember('out', available)
            out = simOut.get('out');
            fprintf('\n''out'' structure type: %s\n', class(out));
            
            if isstruct(out)
                fields = fieldnames(out);
                fprintf('Number of fields: %d\n', length(fields));
                
                for i = 1:min(10, length(fields))  % Show first 10 fields
                    field_data = out.(fields{i});
                    fprintf('  - %s (type: %s, size: %s', fields{i}, ...
                            class(field_data), mat2str(size(field_data)));
                    
                    % Additional info for specific types
                    if isstruct(field_data) && isfield(field_data, 'signals')
                        fprintf(', has signals: %d', length(field_data.signals));
                    end
                    fprintf(')\n');
                end
                
                if length(fields) > 10
                    fprintf('  ... and %d more fields\n', length(fields) - 10);
                end
            end
        end
        
        % Check for logsout
        if ismember('logsout', available)
            logsout = simOut.get('logsout');
            if isa(logsout, 'Simulink.SimulationData.Dataset')
                fprintf('\nLogsout Dataset with %d elements\n', logsout.numElements);
            end
        end
        
        % Check for simlog (Simscape)
        if ismember('simlog', available)
            fprintf('\nSimscape logging data available\n');
        end
    end
    fprintf('=================================\n\n');
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
        
        % Find time data
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            field_value = combinedBus.(field_name);
            
            if contains(lower(field_name), 'time') && isnumeric(field_value)
                time_field = field_name;
                time_data = field_value(:);  % Ensure column vector
                fprintf('Debug: Found time field: %s (length: %d)\n', field_name, length(time_data));
                break;
            end
        end
        
        if isempty(time_data)
            fprintf('Debug: No time field found in CombinedSignalBus\n');
            return;
        end
        
        % Extract all other numeric fields
        data_cells = {time_data};
        var_names = {'time'};
        
        for i = 1:length(bus_fields)
            field_name = bus_fields{i};
            
            % Skip time field
            if strcmp(field_name, time_field)
                continue;
            end
            
            field_value = combinedBus.(field_name);
            
            % Handle different data types
            if isnumeric(field_value)
                % Check if it's the right length
                if length(field_value) == length(time_data)
                    data_cells{end+1} = field_value(:);  % Ensure column vector
                    var_names{end+1} = field_name;
                    fprintf('Debug: Added field %s\n', field_name);
                elseif numel(field_value) > 1 && size(field_value, 1) == length(time_data)
                    % Multi-dimensional data
                    for col = 1:size(field_value, 2)
                        data_cells{end+1} = field_value(:, col);
                        var_names{end+1} = sprintf('%s_%d', field_name, col);
                        fprintf('Debug: Added multi-dim field %s_%d\n', field_name, col);
                    end
                else
                    fprintf('Debug: Skipping field %s (length mismatch: %d vs %d)\n', field_name, length(field_value), length(time_data));
                end
            elseif isstruct(field_value)
                % Handle nested structs
                nested_data = extractFromNestedStruct(field_value, field_name, time_data);
                if ~isempty(nested_data)
                    % Add nested data
                    nested_vars = nested_data.Properties.VariableNames;
                    for j = 1:length(nested_vars)
                        if ~strcmp(nested_vars{j}, 'time')  % Don't duplicate time
                            data_cells{end+1} = nested_data.(nested_vars{j});
                            var_names{end+1} = nested_vars{j};
                        end
                    end
                end
            end
        end
        
        % Create table if we have data
        if length(data_cells) > 1
            data_table = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created CombinedSignalBus table with %d columns\n', width(data_table));
        else
            fprintf('Debug: No valid data found in CombinedSignalBus\n');
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

% FIXED: Extract from Simscape with corrected API calls
function simscape_data = extractSimscapeDataFixed(simlog)
    simscape_data = [];
    
    try
        fprintf('Debug: Extracting Simscape data\n');
        
        if ~isempty(simlog) && isa(simlog, 'simscape.logging.Node')
            % Get series data - this is the correct way to access Simscape data
            try
                series_info = simlog.series();
                if ~isempty(series_info)
                    time = series_info.time;
                    fprintf('Debug: Found Simscape time series, length: %d\n', length(time));
                    
                    data_cells = {time};
                    var_names = {'time'};
                    
                    % Get all logged variables
                    logged_vars = simlog.listVariables('-all');
                    fprintf('Debug: Found %d Simscape variables\n', length(logged_vars));
                    
                    for i = 1:length(logged_vars)
                        var_name = logged_vars{i};
                        try
                            var_data = simlog.find(var_name);
                            if ~isempty(var_data) && isprop(var_data, 'series')
                                var_series = var_data.series();
                                if ~isempty(var_series) && length(var_series.values) == length(time)
                                    data_cells{end+1} = var_series.values;
                                    var_names{end+1} = strrep(var_name, '.', '_');
                                    fprintf('Debug: Added Simscape variable %s\n', var_name);
                                end
                            end
                        catch
                            % Skip variables that can't be accessed
                            continue;
                        end
                    end
                    
                    if length(data_cells) > 1
                        simscape_data = table(data_cells{:}, 'VariableNames', var_names);
                        fprintf('Debug: Created Simscape table with %d columns\n', width(simscape_data));
                    end
                end
            catch ME2
                fprintf('Debug: Could not access Simscape series data: %s\n', ME2.message);
            end
        else
            fprintf('Debug: Simlog is not a valid Simscape logging node\n');
        end
        
    catch ME
        fprintf('Error extracting Simscape data: %s\n', ME.message);
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
