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
    y = y - 0.20;
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
    
    % Try to find default model
    if exist('Model/GolfSwing3D_Kinetic.slx', 'file')
        handles.model_path = fullfile(pwd, 'Model', 'GolfSwing3D_Kinetic.slx');
    elseif exist('GolfSwing3D_Kinetic.slx', 'file')
        handles.model_path = fullfile(pwd, 'GolfSwing3D_Kinetic.slx');
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
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
        errordlg(ME.message, 'Generation Error');
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
        set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        errordlg(ME.message, 'Generation Failed');
    end
end

function successful_trials = runParallelSimulations(handles, config)
    % Initialize parallel pool
    try
        if isempty(gcp('nocreate'))
            % Auto-detect optimal number of workers
            max_cores = feature('numcores');
            num_workers = min(max_cores, 8); % Limit to 8 workers to avoid overwhelming system
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
        % Use parsim for parallel simulation
        simOuts = parsim(simInputs, 'ShowProgress', 'on', 'ShowSimulationManager', 'off');
        
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
        simIn = setSimulationParameters(simIn, config);
        
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
    coeff_idx = 1;
    for joint_idx = 1:length(param_info.joint_names)
        joint_name = param_info.joint_names{joint_idx};
        coeffs = param_info.joint_coeffs{joint_idx};
        
        for coeff_idx = 1:length(coeffs)
            coeff_letter = coeffs(coeff_idx);
            var_name = sprintf('%s%s', joint_name, coeff_letter);
            
            if coeff_idx <= length(coefficients)
                simIn = simIn.setVariable(var_name, coefficients(coeff_idx));
            end
            coeff_idx = coeff_idx + 1;
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
        
        % Suppress Bus Creator warnings more comprehensively
        warning_state = warning('off', 'all');  % Suppress all warnings temporarily
        
        % Run simulation with progress indicator
        fprintf('Running trial %d simulation...', trial_num);
        simOut = sim(simIn);
        fprintf(' Done.\n');
        
        % Restore warning state
        warning(warning_state);
        
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
    end
end

function result = processSimulationOutput(trial_num, config, simOut)
    result = struct('success', false, 'filename', '', 'data_points', 0, 'columns', 0);
    
    try
        % Extract data based on selected sources
        data_table = extractSimulationData(simOut, config);
        
        if isempty(data_table)
            result.error = 'No data extracted from simulation';
            return;
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
    end
end

function data_table = extractSimulationData(simOut, config)
    data_table = [];
    
    try
        % Extract data from different sources based on configuration
        all_data = {};
        
        % Model workspace data
        if config.use_model_workspace && isfield(simOut, 'yout')
            workspace_data = extractWorkspaceData(simOut.yout);
            if ~isempty(workspace_data)
                all_data{end+1} = workspace_data;
            end
        end
        
        % Logsout data
        if config.use_logsout && isfield(simOut, 'logsout')
            logsout_data = extractLogsoutData(simOut.logsout);
            if ~isempty(logsout_data)
                all_data{end+1} = logsout_data;
            end
        end
        
        % Signal bus data
        if config.use_signal_bus && isfield(simOut, 'yout')
            signal_data = extractSignalBusData(simOut.yout);
            if ~isempty(signal_data)
                all_data{end+1} = signal_data;
            end
        end
        
        % Simscape data
        if config.use_simscape && isfield(simOut, 'simscape_logging')
            simscape_data = extractSimscapeData(simOut.simscape_logging);
            if ~isempty(simscape_data)
                all_data{end+1} = simscape_data;
            end
        end
        
        % Combine all data sources
        if ~isempty(all_data)
            data_table = combineDataSources(all_data);
        end
        
    catch ME
        fprintf('Error extracting simulation data: %s\n', ME.message);
    end
end

function workspace_data = extractWorkspaceData(yout)
    workspace_data = [];
    
    try
        if ~isempty(yout)
            % Extract time series data from workspace
            time = yout.time;
            
            % Get signal names
            signal_names = yout.signals.name;
            
            % Create table
            data_cells = {time};
            var_names = {'time'};
            
            for i = 1:length(signal_names)
                if isfield(yout.signals, 'values') && length(yout.signals) >= i
                    values = yout.signals(i).values;
                    if isnumeric(values) && length(values) == length(time)
                        data_cells{end+1} = values;
                        var_names{end+1} = signal_names{i};
                    end
                end
            end
            
            if length(data_cells) > 1
                workspace_data = table(data_cells{:}, 'VariableNames', var_names);
            end
        end
    catch ME
        fprintf('Error extracting workspace data: %s\n', ME.message);
    end
end

function logsout_data = extractLogsoutData(logsout)
    logsout_data = [];
    
    try
        if ~isempty(logsout)
            % Extract data from logsout structure
            time = logsout.time;
            
            % Get all logged signals
            signal_names = fieldnames(logsout);
            signal_names = signal_names(~strcmp(signal_names, 'time'));
            
            data_cells = {time};
            var_names = {'time'};
            
            for i = 1:length(signal_names)
                signal_name = signal_names{i};
                signal_data = logsout.(signal_name);
                
                if isstruct(signal_data) && isfield(signal_data, 'values')
                    values = signal_data.values;
                    if isnumeric(values) && length(values) == length(time)
                        data_cells{end+1} = values;
                        var_names{end+1} = signal_name;
                    end
                end
            end
            
            if length(data_cells) > 1
                logsout_data = table(data_cells{:}, 'VariableNames', var_names);
            end
        end
    catch ME
        fprintf('Error extracting logsout data: %s\n', ME.message);
    end
end

function signal_data = extractSignalBusData(yout)
    signal_data = [];
    
    try
        if ~isempty(yout) && isfield(yout, 'signals')
            % Extract signal bus data
            time = yout.time;
            
            data_cells = {time};
            var_names = {'time'};
            
            for i = 1:length(yout.signals)
                signal = yout.signals(i);
                if isfield(signal, 'values') && isnumeric(signal.values)
                    values = signal.values;
                    if length(values) == length(time)
                        data_cells{end+1} = values;
                        var_names{end+1} = signal.name;
                    end
                end
            end
            
            if length(data_cells) > 1
                signal_data = table(data_cells{:}, 'VariableNames', var_names);
            end
        end
    catch ME
        fprintf('Error extracting signal bus data: %s\n', ME.message);
    end
end

function simscape_data = extractSimscapeData(simscape_logging)
    simscape_data = [];
    
    try
        if ~isempty(simscape_logging)
            % Extract Simscape logging data
            % This is a simplified extraction - may need customization based on specific model
            time = simscape_logging.time;
            
            data_cells = {time};
            var_names = {'time'};
            
            % Extract common Simscape variables
            common_vars = {'position', 'velocity', 'force', 'torque', 'energy'};
            
            for i = 1:length(common_vars)
                var_name = common_vars{i};
                if isfield(simscape_logging, var_name)
                    values = simscape_logging.(var_name);
                    if isnumeric(values) && length(values) == length(time)
                        data_cells{end+1} = values;
                        var_names{end+1} = var_name;
                    end
                end
            end
            
            if length(data_cells) > 1
                simscape_data = table(data_cells{:}, 'VariableNames', var_names);
            end
        end
    catch ME
        fprintf('Error extracting Simscape data: %s\n', ME.message);
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

function simIn = setSimulationParameters(simIn, config)
    % Safely set simulation parameters with error handling
    try
        simIn = simIn.setModelParameter('StopTime', num2str(config.simulation_time));
    catch
        warning('Could not set StopTime parameter');
    end
    
    try
        simIn = simIn.setModelParameter('Solver', 'ode23t');
    catch
        warning('Could not set Solver parameter');
    end
    
    try
        simIn = simIn.setModelParameter('RelTol', '1e-3');
    catch
        warning('Could not set RelTol parameter');
    end
    
    try
        simIn = simIn.setModelParameter('AbsTol', '1e-5');
    catch
        warning('Could not set AbsTol parameter');
    end
    
    try
        simIn = simIn.setModelParameter('SaveOutput', 'on');
    catch
        warning('Could not set SaveOutput parameter');
    end
    
    try
        simIn = simIn.setModelParameter('SaveFormat', 'Dataset');
    catch
        warning('Could not set SaveFormat parameter');
    end
    
    try
        simIn = simIn.setModelParameter('SaveState', 'on');
    catch
        warning('Could not set SaveState parameter');
    end
end