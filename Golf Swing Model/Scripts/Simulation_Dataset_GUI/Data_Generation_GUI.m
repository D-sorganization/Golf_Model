function Data_Generation_GUI()
    % GolfSwingDataGenerator - Improved GUI for generating golf swing training data
    
    % Create main figure with proper sizing
    screenSize = get(0, 'ScreenSize');
    figWidth = min(1400, screenSize(3) * 0.9);
    figHeight = min(800, screenSize(4) * 0.85);
    
    fig = figure('Name', 'Golf Swing Data Generator', ...
                 'Position', [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'ResizeFcn', @resizeCallback, ...
                 'CloseRequestFcn', @(src,evt) closeGUICallback(src, evt));
    
    % Initialize handles structure
    handles = struct();
    handles.should_stop = false;
    handles.fig = fig;
    
    % Load user preferences
    handles = loadUserPreferences(handles);
    
    % Create main layout
    handles = createMainLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
    
    % Apply loaded preferences to UI
    applyUserPreferences(handles);
    
    % Initialize preview
    updatePreview([], [], handles);
    updateCoefficientsPreview([], [], handles);
end

function handles = createMainLayout(fig, handles)
    % Create main layout with proper spacing
    
    % Main container panel
    mainPanel = uipanel('Parent', fig, ...
                       'Units', 'normalized', ...
                       'Position', [0, 0, 1, 1], ...
                       'BorderType', 'none', ...
                       'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Title panel
    titlePanel = uipanel('Parent', mainPanel, ...
                        'Units', 'normalized', ...
                        'Position', [0.005, 0.96, 0.99, 0.035], ...
                        'BackgroundColor', [0.2, 0.3, 0.5], ...
                        'BorderType', 'none');
    
    uicontrol('Parent', titlePanel, ...
              'Style', 'text', ...
              'String', 'Golf Swing Data Generator', ...
              'Units', 'normalized', ...
              'Position', [0.01, 0.1, 0.98, 0.8], ...
              'FontSize', 14, ...
              'FontWeight', 'bold', ...
              'ForegroundColor', 'white', ...
              'BackgroundColor', [0.2, 0.3, 0.5], ...
              'HorizontalAlignment', 'center');
    
    % Create two-column layout
    leftPanel = uipanel('Parent', mainPanel, ...
                       'Units', 'normalized', ...
                       'Position', [0.005, 0.005, 0.49, 0.95], ...
                       'BackgroundColor', [0.96, 0.96, 0.96], ...
                       'BorderType', 'line');
    
    rightPanel = uipanel('Parent', mainPanel, ...
                        'Units', 'normalized', ...
                        'Position', [0.505, 0.005, 0.49, 0.95], ...
                        'BackgroundColor', [0.96, 0.96, 0.96], ...
                        'BorderType', 'line');
    
    % Store panel references
    handles.leftPanel = leftPanel;
    handles.rightPanel = rightPanel;
    
    % Create content in both columns
    handles = createLeftColumnContent(leftPanel, handles);
    handles = createRightColumnContent(rightPanel, handles);
end

function handles = createLeftColumnContent(parent, handles)
    % Create all content for the left column
    
    % Define panel heights with proper spacing - adjusted for better visibility
    panelHeight1 = 0.22;  % Trial & Data Sources
    panelHeight2 = 0.22;  % Modeling Configuration  
    panelHeight3 = 0.27;  % Individual Joint Editor (taller for polynomial)
    panelHeight4 = 0.23;  % Output Configuration
    spacing = 0.01;
    yPositions = [0.76, 0.53, 0.25, 0.01];  % Adjusted positions to prevent overlap
    
    % Trial Settings & Data Sources Panel
    handles = createTrialAndDataPanel(parent, handles, yPositions(1), panelHeight1);
    
    % Modeling Configuration Panel
    handles = createModelingPanel(parent, handles, yPositions(2), panelHeight2);
    
    % Individual Joint Editor Panel
    handles = createJointEditorPanel(parent, handles, yPositions(3), panelHeight3);
    
    % Output Settings Panel
    handles = createOutputPanel(parent, handles, yPositions(4), panelHeight4);
end

function handles = createRightColumnContent(parent, handles)
    % Create all content for the right column
    
    % Preview Panel
    handles = createPreviewPanel(parent, handles, 0.60, 0.38);
    
    % Coefficients Table Panel
    handles = createCoefficientsPanel(parent, handles, 0.30, 0.28);
    
    % Progress Panel
    handles = createProgressPanel(parent, handles, 0.16, 0.12);
    
    % Control Buttons Panel
    handles = createControlPanel(parent, handles, 0.02, 0.12);
end

function handles = createTrialAndDataPanel(parent, handles, yPos, height)
    % Combined Trial Settings & Data Sources Configuration
    panel = uipanel('Parent', parent, ...
                   'Title', 'Trial Settings & Data Sources', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.75;  % Starting point file
    y2 = 0.58;  % Trial parameters  
    y3 = 0.38;  % Data sources
    y4 = 0.18;  % Model selection
    
    % === STARTING POINT FILE SELECTION ===
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Starting Point File:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y1, 0.18, 0.06], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold');
    
    handles.input_file_edit = uicontrol('Parent', panel, ...
                                       'Style', 'edit', ...
                                       'String', 'Select a .mat input file...', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.21, y1, 0.5, 0.06], ...
                                       'Enable', 'inactive', ...
                                       'TooltipString', 'Selected starting point .mat file (hover to see full path)');
    
    handles.browse_input_btn = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Browse File...', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.73, y1, 0.12, 0.06], ...
                                        'Callback', @(src,evt) browseInputFile(src, evt, handles), ...
                                        'TooltipString', 'Select starting point .mat file');
    
    handles.clear_input_btn = uicontrol('Parent', panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Clear', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.86, y1, 0.08, 0.06], ...
                                       'Callback', @(src,evt) clearInputFile(src, evt, handles), ...
                                       'TooltipString', 'Clear file selection');
    
    % File status indicator (will be updated by preferences system)
    handles.file_status_text = uicontrol('Parent', panel, ...
                                         'Style', 'text', ...
                                         'String', '', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.21, y1-0.08, 0.7, 0.06], ...
                                         'FontSize', 8, ...
                                         'ForegroundColor', [0.5, 0.5, 0.5], ...
                                         'HorizontalAlignment', 'left', ...
                                         'BackgroundColor', get(panel, 'BackgroundColor'));
    
    % === TRIAL PARAMETERS ===
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Trials:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y2, 0.08, 0.06], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold');
    
    handles.num_trials_edit = uicontrol('Parent', panel, ...
                                       'Style', 'edit', ...
                                       'String', '10', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.11, y2, 0.08, 0.06], ...
                                       'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles), ...
                                       'TooltipString', 'Number of simulation trials');
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Duration (s):', ...
              'Units', 'normalized', ...
              'Position', [0.21, y2, 0.12, 0.06], ...
              'HorizontalAlignment', 'left');
    
    handles.sim_time_edit = uicontrol('Parent', panel, ...
                                     'Style', 'edit', ...
                                     'String', '0.3', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.34, y2, 0.08, 0.06], ...
                                     'TooltipString', 'Simulation duration in seconds');
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Sample Rate (Hz):', ...
              'Units', 'normalized', ...
              'Position', [0.44, y2, 0.14, 0.06], ...
              'HorizontalAlignment', 'left');
    
    handles.sample_rate_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', '100', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.59, y2, 0.08, 0.06], ...
                                        'TooltipString', 'Data sampling rate');
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Mode:', ...
              'Units', 'normalized', ...
              'Position', [0.69, y2, 0.08, 0.06], ...
              'HorizontalAlignment', 'left');
    
    handles.execution_mode_popup = uicontrol('Parent', panel, ...
                                            'Style', 'popupmenu', ...
                                            'String', {'Sequential', 'Parallel'}, ...
                                            'Units', 'normalized', ...
                                            'Position', [0.78, y2, 0.16, 0.06], ...
                                            'TooltipString', 'Execution mode for trials');
    
    % === DATA SOURCES ===
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Data Sources:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y3, 0.15, 0.06], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold');
    
    handles.use_model_workspace = uicontrol('Parent', panel, ...
                                           'Style', 'checkbox', ...
                                           'String', 'Model Workspace', ...
                                           'Units', 'normalized', ...
                                           'Position', [0.18, y3, 0.18, 0.06], ...
                                           'Value', 1, ...
                                           'TooltipString', 'Extract model parameters and variables');
    
    handles.use_logsout = uicontrol('Parent', panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Logsout', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.37, y3, 0.12, 0.06], ...
                                   'Value', 1, ...
                                   'TooltipString', 'Extract logged signals');
    
    handles.use_signal_bus = uicontrol('Parent', panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'Signal Bus', ...
                                      'Units', 'normalized', ...
                                      'Position', [0.50, y3, 0.15, 0.06], ...
                                      'Value', 1, ...
                                      'TooltipString', 'Extract ToWorkspace block data');
    
    handles.use_simscape = uicontrol('Parent', panel, ...
                                    'Style', 'checkbox', ...
                                    'String', 'Simscape Results', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.66, y3, 0.18, 0.06], ...
                                    'Value', 1, ...
                                    'TooltipString', 'Extract primary simulation data');
    
    % === MODEL SELECTION ===
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Simulink Model:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y4, 0.18, 0.06], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold');
    
    handles.model_display = uicontrol('Parent', panel, ...
                                     'Style', 'text', ...
                                     'String', 'GolfSwing3D_Kinetic', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.21, y4, 0.4, 0.06], ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', [1, 1, 1], ...
                                     'TooltipString', 'Selected Simulink model file');
    
    handles.model_browse_btn = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Browse Model...', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.63, y4, 0.15, 0.06], ...
                                        'Callback', @(src,evt) selectSimulinkModel(src, evt, handles), ...
                                        'TooltipString', 'Select Simulink model file');
    

    
    % Initialize model name
    handles.model_name = 'GolfSwing3D_Kinetic';
    handles.model_path = '';
    handles.selected_input_file = '';
end

function handles = createModelingPanel(parent, handles, yPos, height)
    % Modeling Configuration Panel
    panel = uipanel('Parent', parent, ...
                   'Title', 'Modeling Configuration', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.70;
    y2 = 0.40;
    y3 = 0.10;
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Torque Scenario:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y1, 0.2, 0.1], ...
              'HorizontalAlignment', 'left');
    
    handles.torque_scenario_popup = uicontrol('Parent', panel, ...
                                             'Style', 'popupmenu', ...
                                             'String', {'Variable Torques', 'Zero Torque', 'Constant Torque'}, ...
                                             'Units', 'normalized', ...
                                             'Position', [0.22, y1, 0.3, 0.1], ...
                                             'Callback', @(src,evt) torqueScenarioCallback(src, evt, handles));
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Coefficient Range (±):', ...
              'Units', 'normalized', ...
              'Position', [0.02, y2, 0.2, 0.1], ...
              'HorizontalAlignment', 'left');
    
    handles.coeff_range_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', '50', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.22, y2, 0.12, 0.1], ...
                                        'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Constant Value (G):', ...
              'Units', 'normalized', ...
              'Position', [0.40, y2, 0.2, 0.1], ...
              'HorizontalAlignment', 'left');
    
    handles.constant_value_edit = uicontrol('Parent', panel, ...
                                           'Style', 'edit', ...
                                           'String', '10', ...
                                           'Units', 'normalized', ...
                                           'Position', [0.60, y2, 0.12, 0.1], ...
                                           'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Simulink Model:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y3, 0.2, 0.1], ...
              'HorizontalAlignment', 'left');
    
    handles.model_display = uicontrol('Parent', panel, ...
                                     'Style', 'text', ...
                                     'String', 'GolfSwing3D_Kinetic', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.22, y3, 0.25, 0.1], ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', [1, 1, 1]);
    
    handles.model_browse_btn = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Browse...', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.48, y3, 0.09, 0.1], ...
                                        'Callback', @(src,evt) selectSimulinkModel(src, evt, handles));
    
    % Store the current model name in handles
    handles.model_name = 'GolfSwing3D_Kinetic';
    handles.model_path = '';  % Initialize empty, will be set when user selects a model
    
    % Remove the Mode 3 comment - no longer needed here
end

function handles = createJointEditorPanel(parent, handles, yPos, height)
    % Individual Joint Editor with trial selection capability
    param_info = getPolynomialParameterInfo();
    
    panel = uipanel('Parent', parent, ...
                   'Title', 'Individual Joint Editor', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.75;
    y2 = 0.45;
    y3 = 0.15;
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Select Joint:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y1, 0.12, 0.075], ...
              'HorizontalAlignment', 'left');
    
    handles.joint_selector = uicontrol('Parent', panel, ...
                                      'Style', 'popupmenu', ...
                                      'String', param_info.joint_names, ...
                                      'Units', 'normalized', ...
                                      'Position', [0.14, y1, 0.3, 0.075], ...
                                      'Callback', @(src,evt) updateJointCoefficients(src, evt, handles));
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Apply to:', ...
              'Units', 'normalized', ...
              'Position', [0.46, y1, 0.1, 0.075], ...
              'HorizontalAlignment', 'left');
    
    handles.trial_selection_popup = uicontrol('Parent', panel, ...
                                             'Style', 'popupmenu', ...
                                             'String', {'All Trials', 'Specific Trial'}, ...
                                             'Units', 'normalized', ...
                                             'Position', [0.56, y1, 0.18, 0.075], ...
                                             'Callback', @(src,evt) updateTrialSelectionMode(src, evt, handles));
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Trial #:', ...
              'Units', 'normalized', ...
              'Position', [0.75, y1, 0.08, 0.075], ...
              'HorizontalAlignment', 'left');
    
    handles.trial_number_edit = uicontrol('Parent', panel, ...
                                         'Style', 'edit', ...
                                         'String', '1', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.83, y1, 0.08, 0.075], ...
                                         'Enable', 'off');
    
    % Coefficient edit boxes (A-G)
    coeff_labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
    handles.joint_coeff_edits = [];
    
    for i = 1:7
        xPos = 0.02 + (i-1) * 0.13;
        
        % Label
        uicontrol('Parent', panel, ...
                  'Style', 'text', ...
                  'String', coeff_labels{i}, ...
                  'Units', 'normalized', ...
                  'Position', [xPos, y2+0.05, 0.04, 0.1], ...
                  'FontWeight', 'bold', ...
                  'HorizontalAlignment', 'center');
        
        % Edit box
        handles.joint_coeff_edits(i) = uicontrol('Parent', panel, ...
                                                'Style', 'edit', ...
                                                'String', '0.00', ...
                                                'Units', 'normalized', ...
                                                'Position', [xPos+0.04, y2, 0.08, 0.075], ...
                                                'HorizontalAlignment', 'center', ...
                                                'Callback', @(src,evt) validateCoefficientInput(src, evt, handles));
    end
    
    % Action buttons
    handles.apply_joint_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Apply to Table', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.02, y3, 0.2, 0.1], ...
                                          'FontWeight', 'bold', ...
                                          'BackgroundColor', [0.7, 0.9, 0.7], ...
                                          'Callback', @(src,evt) applyJointToTable(src, evt, handles));
    
    handles.load_joint_button = uicontrol('Parent', panel, ...
                                         'Style', 'pushbutton', ...
                                         'String', 'Load from Table', ...
                                         'Units', 'normalized', ...
                                         'Position', [0.24, y3, 0.2, 0.1], ...
                                         'FontWeight', 'bold', ...
                                         'BackgroundColor', [0.9, 0.9, 0.7], ...
                                         'Callback', @(src,evt) loadJointFromTable(src, evt, handles));
    
    % Status
    handles.joint_status = uicontrol('Parent', panel, ...
                                    'Style', 'text', ...
                                    'String', sprintf('Ready - %s selected', param_info.joint_names{1}), ...
                                    'Units', 'normalized', ...
                                    'Position', [0.46, y3, 0.52, 0.075], ...
                                    'HorizontalAlignment', 'left', ...
                                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Polynomial equation display - more prominent and visible
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Polynomial Equation:', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.08, 0.25, 0.06], ...
              'FontSize', 9, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    handles.equation_display = uicontrol('Parent', panel, ...
                                       'Style', 'text', ...
                                       'String', 'τ(t) = A + Bt + Ct² + Dt³ + Et⁴ + Ft⁵ + Gt⁶', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.02, 0.02, 0.96, 0.08], ...
                                       'FontSize', 11, ...
                                       'FontWeight', 'bold', ...
                                       'ForegroundColor', [0.1, 0.1, 0.7], ...
                                       'BackgroundColor', [0.95, 0.95, 1], ...
                                       'HorizontalAlignment', 'center');
    
    handles.param_info = param_info;
end

function handles = createOutputPanel(parent, handles, yPos, height)
    % Output Configuration Panel
    panel = uipanel('Parent', parent, ...
                   'Title', 'Output Configuration', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.70;
    y2 = 0.45;
    y3 = 0.20;
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y1, 0.15, 0.075], ...
              'HorizontalAlignment', 'left');
    
    handles.output_folder_edit = uicontrol('Parent', panel, ...
                                          'Style', 'edit', ...
                                          'String', pwd, ...
                                          'Units', 'normalized', ...
                                          'Position', [0.17, y1, 0.6, 0.075]);
    
    handles.browse_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Browse', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.78, y1, 0.15, 0.075], ...
                                     'Callback', @(src,evt) browseOutputFolder(src, evt, handles));
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Dataset Folder:', ...
              'Units', 'normalized', ...
              'Position', [0.02, y2, 0.15, 0.075], ...
              'HorizontalAlignment', 'left');
    
    handles.folder_name_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', 'training_data_csv', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.17, y2, 0.35, 0.075]);
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'File Format:', ...
              'Units', 'normalized', ...
              'Position', [0.55, y2, 0.12, 0.075], ...
              'HorizontalAlignment', 'left');
    
    handles.format_popup = uicontrol('Parent', panel, ...
                                    'Style', 'popupmenu', ...
                                    'String', {'CSV Files', 'MAT Files', 'Both CSV and MAT'}, ...
                                    'Units', 'normalized', ...
                                    'Position', [0.67, y2, 0.26, 0.075]);
    
    % Info text
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Files saved with trial numbers and timestamps for identification.', ...
              'Units', 'normalized', ...
              'Position', [0.02, y3-0.05, 0.9, 0.075], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.98, 0.98, 0.98]);
end

function handles = createPreviewPanel(parent, handles, yPos, height)
    % Input Parameters Preview Panel
    panel = uipanel('Parent', parent, ...
                   'Title', 'Input Parameters Preview', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Update button
    handles.update_preview_button = uicontrol('Parent', panel, ...
                                             'Style', 'pushbutton', ...
                                             'String', 'Update Preview', ...
                                             'Units', 'normalized', ...
                                             'Position', [0.02, 0.88, 0.2, 0.10], ...
                                             'FontWeight', 'bold', ...
                                             'BackgroundColor', [0.2, 0.7, 0.1], ...
                                             'ForegroundColor', 'white', ...
                                             'Callback', @(src,evt) updatePreview(src, evt, handles));
    
    % Preview table
    handles.preview_table = uitable('Parent', panel, ...
                                   'Units', 'normalized', ...
                                   'Position', [0.02, 0.12, 0.96, 0.74], ...
                                   'ColumnName', {'Parameter', 'Value', 'Description'}, ...
                                   'ColumnWidth', {'auto', 'auto', 'auto'}, ...
                                   'RowStriping', 'on');
    
    % Instruction text
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Current parameter settings and expected simulation configuration.', ...
              'Units', 'normalized', ...
              'Position', [0.02, 0.02, 0.96, 0.08], ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.98, 0.98, 0.98]);
end

function handles = createCoefficientsPanel(parent, handles, yPos, height)
    % Polynomial Coefficients Table Panel
    param_info = getPolynomialParameterInfo();
    
    panel = uipanel('Parent', parent, ...
                   'Title', 'Polynomial Coefficients Table', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Search functionality
    searchY = 0.90;
    searchHeight = 0.08;
    
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Search:', ...
              'Units', 'normalized', ...
              'Position', [0.02, searchY, 0.08, searchHeight], ...
              'HorizontalAlignment', 'left');
    
    handles.search_edit = uicontrol('Parent', panel, ...
                                   'Style', 'edit', ...
                                   'String', '', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.10, searchY, 0.20, searchHeight], ...
                                   'Callback', @(src,evt) searchCoefficients(src, evt, handles), ...
                                   'KeyPressFcn', @(src,evt) searchCoefficients(src, evt, handles));
    
    handles.clear_search_button = uicontrol('Parent', panel, ...
                                           'Style', 'pushbutton', ...
                                           'String', 'Clear', ...
                                           'Units', 'normalized', ...
                                           'Position', [0.31, searchY, 0.08, searchHeight], ...
                                           'Callback', @(src,evt) clearSearch(src, evt, handles));
    
    % Control buttons
    buttonY = 0.82;
    buttonHeight = 0.08;
    buttonWidth = 0.12;
    
    handles.reset_coeffs_button = uicontrol('Parent', panel, ...
                                           'Style', 'pushbutton', ...
                                           'String', 'Reset', ...
                                           'Units', 'normalized', ...
                                           'Position', [0.02, buttonY, buttonWidth, buttonHeight], ...
                                           'Callback', @(src,evt) resetCoefficientsToGenerated(src, evt, handles));
    
    handles.apply_row_button = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Apply Row', ...
                                        'Units', 'normalized', ...
                                        'Position', [0.15, buttonY, buttonWidth, buttonHeight], ...
                                        'Callback', @(src,evt) applyRowToAll(src, evt, handles));
    
    handles.export_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Export CSV', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.28, buttonY, buttonWidth, buttonHeight], ...
                                     'Callback', @(src,evt) exportCoefficientsToCSV(src, evt, handles));
    
    handles.import_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Import CSV', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.41, buttonY, buttonWidth, buttonHeight], ...
                                     'Callback', @(src,evt) importCoefficientsFromCSV(src, evt, handles));
    
    handles.save_scenario_button = uicontrol('Parent', panel, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Save Scenario', ...
                                            'Units', 'normalized', ...
                                            'Position', [0.54, buttonY, buttonWidth, buttonHeight], ...
                                            'Callback', @(src,evt) saveScenario(src, evt, handles), ...
                                            'TooltipString', 'Save current torque coefficients as an experimental scenario');
    
    handles.load_scenario_button = uicontrol('Parent', panel, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Load Scenario', ...
                                            'Units', 'normalized', ...
                                            'Position', [0.67, buttonY, buttonWidth, buttonHeight], ...
                                            'Callback', @(src,evt) loadScenario(src, evt, handles), ...
                                            'TooltipString', 'Load saved experimental scenario coefficients');
    
    % Create table with proper column structure
    col_names = {'Trial'};
    col_widths = {60};
    col_editable = false;
    
    % Add columns for all joints and their coefficients
    for i = 1:length(param_info.joint_names)
        joint_name = param_info.joint_names{i};
        coeffs = param_info.joint_coeffs{i};
        
        % Shorten joint names for display
        short_name = getShortenedJointName(joint_name);
        
        for j = 1:length(coeffs)
            coeff = coeffs(j);
            col_names{end+1} = sprintf('%s_%s', short_name, coeff);
            col_widths{end+1} = 60;
            col_editable(end+1) = true;
        end
    end
    
    % Coefficients table
    handles.coefficients_table = uitable('Parent', panel, ...
                                        'Units', 'normalized', ...
                                        'Position', [0.02, 0.05, 0.96, 0.72], ...
                                        'ColumnName', col_names, ...
                                        'ColumnWidth', col_widths, ...
                                        'RowStriping', 'on', ...
                                        'ColumnEditable', col_editable, ...
                                        'CellEditCallback', @(src,evt) coefficientCellEditCallback(src, evt, handles));
    
    % Initialize edit tracking
    handles.edited_cells = {};
    handles.param_info = param_info;
end

function handles = createProgressPanel(parent, handles, yPos, height)
    % Progress and Activity Log Panel
    panel = uipanel('Parent', parent, ...
                   'Title', 'Generation Progress', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Progress bar
    handles.progress_text = uicontrol('Parent', panel, ...
                                     'Style', 'text', ...
                                     'String', 'Ready to start generation...', ...
                                     'Units', 'normalized', ...
                                     'Position', [0.02, 0.55, 0.96, 0.35], ...
                                     'FontWeight', 'bold', ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Status
    handles.status_text = uicontrol('Parent', panel, ...
                                   'Style', 'text', ...
                                   'String', 'Status: Ready', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.02, 0.10, 0.96, 0.35], ...
                                   'HorizontalAlignment', 'left', ...
                                   'BackgroundColor', [0.98, 0.98, 0.98]);
end

function handles = createControlPanel(parent, handles, yPos, height)
    % Control Buttons Panel
    panel = uipanel('Parent', parent, ...
                   'Title', 'Generation Controls', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.01, yPos, 0.98, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Main control buttons
    buttonY = 0.25;
    buttonHeight = 0.50;
    
    handles.start_button = uicontrol('Parent', panel, ...
                                    'Style', 'pushbutton', ...
                                    'String', 'Start Generation', ...
                                    'Units', 'normalized', ...
                                    'Position', [0.02, buttonY, 0.20, buttonHeight], ...
                                    'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.2, 0.6, 0.1], ...
                                    'ForegroundColor', 'white', ...
                                    'Callback', @(src,evt) startGeneration(src, evt, handles));
    
    handles.stop_button = uicontrol('Parent', panel, ...
                                   'Style', 'pushbutton', ...
                                   'String', 'Stop', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.24, buttonY, 0.12, buttonHeight], ...
                                   'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.8, 0.2, 0.1], ...
                                   'ForegroundColor', 'white', ...
                                   'Enable', 'off', ...
                                   'Callback', @(src,evt) stopGeneration(src, evt, handles));
    
    % Utility buttons
    handles.validate_button = uicontrol('Parent', panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Validate', ...
                                       'Units', 'normalized', ...
                                       'Position', [0.40, buttonY, 0.12, buttonHeight], ...
                                       'Callback', @(src,evt) validateSettings(src, evt, handles));
    
    handles.save_config_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Save Config', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.54, buttonY, 0.15, buttonHeight], ...
                                          'Callback', @(src,evt) saveConfiguration(src, evt, handles));
    
    handles.load_config_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Load Config', ...
                                          'Units', 'normalized', ...
                                          'Position', [0.71, buttonY, 0.15, buttonHeight], ...
                                          'Callback', @(src,evt) loadConfiguration(src, evt, handles));
end

function resizeCallback(src, evt)
    % Handle window resize events
    % This is called automatically when the window is resized
    % The normalized units ensure proper scaling
end

function closeGUICallback(src, evt)
    % Handle GUI close event - save preferences before closing
    try
        handles = guidata(src);
        % Save current preferences
        saveUserPreferences(handles);
    catch
        % If there's an error, still allow closing
    end
    
    % Close the figure
    delete(src);
end

% ==================== CALLBACK FUNCTIONS ====================
% (Include all the callback functions from the original code)

function handles = torqueScenarioCallback(src, ~, handles)
    scenario_idx = get(src, 'Value');
    
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
    
    updatePreview([], [], handles);
    updateCoefficientsPreview([], [], handles);
    guidata(handles.fig, handles);
end

function handles = browseOutputFolder(src, ~, handles)
    folder = uigetdir(get(handles.output_folder_edit, 'String'), 'Select Output Folder');
    if folder ~= 0
        set(handles.output_folder_edit, 'String', folder);
        updatePreview([], [], handles);
        guidata(handles.fig, handles);
        
        % Save preferences automatically
        saveUserPreferences(handles);
    end
end

function handles = updatePreview(~, ~, handles)
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
            'Modeling Mode', '3 (Hex Polynomial)', '7 coefficients per joint';
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

function handles = updateCoefficientsPreview(~, ~, handles)
    try
        % Get current settings
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        if isnan(num_trials) || num_trials <= 0
            num_trials = 5;
        end
        % Remove artificial limit - show all trials
        num_trials = min(num_trials, 100); % Reasonable limit for display performance
        
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
        
        % Store original data for search functionality
        handles.original_coefficients_data = coeff_data;
        handles.original_coefficients_columns = get(handles.coefficients_table, 'ColumnName');
        handles.original_column_widths = get(handles.coefficients_table, 'ColumnWidth');
        handles.original_column_editable = get(handles.coefficients_table, 'ColumnEditable');
        guidata(handles.fig, handles);
        
    catch ME
        fprintf('Error in updateCoefficientsPreview: %s\n', ME.message);
    end
    
    guidata(handles.fig, handles);
end

function updateJointCoefficients(src, evt, handles)
    try
        handles = guidata(handles.fig);
        selected_idx = get(handles.joint_selector, 'Value');
        joint_names = get(handles.joint_selector, 'String');
        selected_joint = joint_names{selected_idx};
        
        % Reset coefficient values
        for i = 1:7
            set(handles.joint_coeff_edits(i), 'String', '0.00');
        end
        
        % Update status
        set(handles.joint_status, 'String', sprintf('Ready - %s selected', selected_joint));
        
        guidata(handles.fig, handles);
        
    catch ME
        fprintf('Error updating joint: %s\n', ME.message);
    end
end

function updateTrialSelectionMode(src, evt, handles)
    try
        handles = guidata(handles.fig);
        selection_idx = get(handles.trial_selection_popup, 'Value');
        
        if selection_idx == 1 % All Trials
            set(handles.trial_number_edit, 'Enable', 'off');
            set(handles.trial_number_edit, 'BackgroundColor', [0.94, 0.94, 0.94]);
        else % Specific Trial
            set(handles.trial_number_edit, 'Enable', 'on');
            set(handles.trial_number_edit, 'BackgroundColor', 'white');
        end
        
        guidata(handles.fig, handles);
        
    catch ME
        fprintf('Error updating trial selection mode: %s\n', ME.message);
    end
end

function validateCoefficientInput(src, evt, handles)
    try
        current_value = get(src, 'String');
        num_value = str2double(current_value);
        
        if isnan(num_value)
            set(src, 'String', '0.00');
        else
            set(src, 'String', sprintf('%.2f', num_value));
        end
        
    catch ME
        set(src, 'String', '0.00');
    end
end

function applyJointToTable(src, evt, handles)
    try
        handles = guidata(handles.fig);
        
        % Get selections
        selected_joint_idx = get(handles.joint_selector, 'Value');
        joint_names = get(handles.joint_selector, 'String');
        selected_joint = joint_names{selected_joint_idx};
        
        trial_selection_idx = get(handles.trial_selection_popup, 'Value');
        trial_number_str = get(handles.trial_number_edit, 'String');
        
        % Get coefficient values
        coeff_values = zeros(1, 7);
        for i = 1:7
            coeff_values(i) = str2double(get(handles.joint_coeff_edits(i), 'String'));
        end
        
        % Get table data and find joint columns
        table_data = get(handles.coefficients_table, 'Data');
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        if isempty(table_data)
            errordlg('No data in table. Generate coefficients first.', 'No Data');
            return;
        end
        
        % Find columns for this joint using shortened name
        short_joint_name = getShortenedJointName(selected_joint);
        joint_columns = [];
        for i = 1:length(col_names)
            if contains(col_names{i}, short_joint_name)
                joint_columns(end+1) = i;
            end
        end
        
        if length(joint_columns) ~= 7
            errordlg(sprintf('Expected 7 columns for %s, found %d', selected_joint, length(joint_columns)), 'Error');
            return;
        end
        
        % Apply coefficients
        if trial_selection_idx == 1 % All Trials
            target_rows = 1:size(table_data, 1);
        else % Specific trial
            target_trial = str2double(trial_number_str);
            if isnan(target_trial) || target_trial < 1 || target_trial > size(table_data, 1)
                errordlg(sprintf('Invalid trial number. Please enter a number between 1 and %d.', size(table_data, 1)), 'Error');
                return;
            end
            target_rows = target_trial;
        end
        
        % Apply to target rows
        for row = target_rows
            for i = 1:7
                col = joint_columns(i);
                table_data{row, col} = sprintf('%.2f', coeff_values(i));
                
                % Track as edited
                cell_key = sprintf('%d_%d', row, col);
                if ~any(strcmp(handles.edited_cells, cell_key))
                    handles.edited_cells{end+1} = cell_key;
                end
            end
        end
        
        % Update table
        set(handles.coefficients_table, 'Data', table_data);
        
        % Update status
        if length(target_rows) == 1
            status_msg = sprintf('Applied %s coefficients to trial %d', selected_joint, target_rows);
        else
            status_msg = sprintf('Applied %s coefficients to all %d trials', selected_joint, length(target_rows));
        end
        set(handles.joint_status, 'String', status_msg);
        
        guidata(handles.fig, handles);
        msgbox(status_msg, 'Success');
        
    catch ME
        errordlg(sprintf('Error applying coefficients: %s', ME.message), 'Apply Error');
    end
end

function loadJointFromTable(src, evt, handles)
    try
        handles = guidata(handles.fig);
        
        % Get selections
        selected_joint_idx = get(handles.joint_selector, 'Value');
        joint_names = get(handles.joint_selector, 'String');
        selected_joint = joint_names{selected_joint_idx};
        
        trial_selection_idx = get(handles.trial_selection_popup, 'Value');
        trial_number_str = get(handles.trial_number_edit, 'String');
        
        % Get table data
        table_data = get(handles.coefficients_table, 'Data');
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        if isempty(table_data)
            errordlg('No data in table.', 'No Data');
            return;
        end
        
        % Determine source row
        if trial_selection_idx == 1 % All Trials - use first trial
            source_row = 1;
        else % Specific trial
            source_row = str2double(trial_number_str);
            if isnan(source_row) || source_row < 1 || source_row > size(table_data, 1)
                errordlg(sprintf('Invalid trial number. Please enter a number between 1 and %d.', size(table_data, 1)), 'Error');
                return;
            end
        end
        
        % Find joint columns using shortened name
        short_joint_name = getShortenedJointName(selected_joint);
        joint_columns = [];
        for i = 1:length(col_names)
            if contains(col_names{i}, short_joint_name)
                joint_columns(end+1) = i;
            end
        end
        
        if length(joint_columns) ~= 7
            errordlg(sprintf('Expected 7 columns for %s', selected_joint), 'Error');
            return;
        end
        
        % Load coefficients
        for i = 1:7
            col = joint_columns(i);
            value_str = table_data{source_row, col};
            if ischar(value_str)
                set(handles.joint_coeff_edits(i), 'String', value_str);
            else
                set(handles.joint_coeff_edits(i), 'String', sprintf('%.2f', value_str));
            end
        end
        
        % Update status
        status_msg = sprintf('Loaded %s coefficients from trial %d', selected_joint, source_row);
        set(handles.joint_status, 'String', status_msg);
        
        guidata(handles.fig, handles);
        msgbox(status_msg, 'Success');
        
    catch ME
        errordlg(sprintf('Error loading coefficients: %s', ME.message), 'Load Error');
    end
end

% Utility functions for coefficient table management
function coefficientCellEditCallback(src, eventdata, handles)
    try
        handles = guidata(handles.fig);
        
        row = eventdata.Indices(1);
        col = eventdata.Indices(2);
        new_value = eventdata.NewData;
        old_value = eventdata.PreviousData;
        
        % Validate numeric input
        if ischar(new_value)
            num_value = str2double(new_value);
            if isnan(num_value)
                current_data = get(src, 'Data');
                current_data{row, col} = old_value;
                set(src, 'Data', current_data);
                errordlg('Invalid input. Please enter a number.', 'Invalid Input');
                return;
            end
        else
            num_value = new_value;
        end
        
        % Format value
        formatted_value = sprintf('%.2f', num_value);
        current_data = get(src, 'Data');
        current_data{row, col} = formatted_value;
        set(src, 'Data', current_data);
        
        % Track edited cell
        cell_key = sprintf('%d_%d', row, col);
        if ~any(strcmp(handles.edited_cells, cell_key))
            handles.edited_cells{end+1} = cell_key;
        end
        
        % Update original data to preserve user edits during search
        if isfield(handles, 'original_coefficients_data')
            % Check if we're viewing filtered data or full data
            current_col_names = get(src, 'ColumnName');
            original_col_names = handles.original_coefficients_columns;
            
            if length(current_col_names) == length(original_col_names)
                % Full table is displayed, update directly
                handles.original_coefficients_data{row, col} = formatted_value;
            else
                % Filtered table is displayed, find correct column in original data
                current_col_name = current_col_names{col};
                original_col_idx = find(strcmp(original_col_names, current_col_name), 1);
                if ~isempty(original_col_idx)
                    handles.original_coefficients_data{row, original_col_idx} = formatted_value;
                end
            end
        end
        
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error editing cell: %s', ME.message), 'Edit Error');
    end
end

function resetCoefficientsToGenerated(src, evt, handles)
    handles = guidata(handles.fig);
    updateCoefficientsPreview([], [], handles);
    handles.edited_cells = {};
    guidata(handles.fig, handles);
end

function selectSimulinkModel(src, evt, handles)
    % Callback function to open a file dialog for selecting Simulink model
    handles = guidata(handles.fig);
    
    % Get the current model name to use as default
    current_model = handles.model_name;
    
    % Open file selection dialog for Simulink models
    [filename, pathname] = uigetfile({'*.slx;*.mdl', 'Simulink Models (*.slx, *.mdl)'; ...
                                      '*.slx', 'Simulink Files (*.slx)'; ...
                                      '*.mdl', 'MDL Files (*.mdl)'; ...
                                      '*.*', 'All Files (*.*)'}, ...
                                     'Select Simulink Model', current_model);
    
    % Check if user cancelled
    if isequal(filename, 0) || isequal(pathname, 0)
        return;
    end
    
    % Extract model name without extension
    [~, model_name, ~] = fileparts(filename);
    
    % Update the display and store the model name
    set(handles.model_display, 'String', model_name);
    handles.model_name = model_name;
    handles.model_path = fullfile(pathname, filename);
    
    % Save updated handles
    guidata(handles.fig, handles);
    
    % Optional: Display confirmation
    fprintf('Selected Simulink model: %s\n', model_name);
    fprintf('Model path: %s\n', handles.model_path);
end

function applyRowToAll(src, evt, handles)
    try
        % Get the latest handles structure
        if isfield(handles, 'fig')
            handles = guidata(handles.fig);
        else
            % If handles doesn't have fig, get it from the source
            fig = ancestor(src, 'figure');
            handles = guidata(fig);
        end
        
        % Check if coefficients_table exists
        if ~isfield(handles, 'coefficients_table')
            errordlg('Coefficients table not found. Please update preview first.', 'Error');
            return;
        end
        
        current_data = get(handles.coefficients_table, 'Data');
        if isempty(current_data)
            errordlg('No data in table', 'No Data');
            return;
        end
        
        prompt = sprintf('Enter row number (1-%d) to apply to all:', size(current_data, 1));
        answer = inputdlg(prompt, 'Select Row', 1, {'1'});
        
        if isempty(answer)
            return;
        end
        
        template_row = str2double(answer{1});
        if isnan(template_row) || template_row < 1 || template_row > size(current_data, 1)
            errordlg('Invalid row number', 'Error');
            return;
        end
        
        % Apply template row to all rows
        template_coeffs = current_data(template_row, 2:end);
        for row = 1:size(current_data, 1)
            current_data(row, 2:end) = template_coeffs;
            
            % Mark as edited
            for col = 2:size(current_data, 2)
                cell_key = sprintf('%d_%d', row, col);
                if ~any(strcmp(handles.edited_cells, cell_key))
                    handles.edited_cells{end+1} = cell_key;
                end
            end
        end
        
        set(handles.coefficients_table, 'Data', current_data);
        guidata(handles.fig, handles);
        
        msgbox(sprintf('Applied row %d to all rows', template_row), 'Success');
        
    catch ME
        errordlg(sprintf('Error: %s', ME.message), 'Error');
    end
end

function exportCoefficientsToCSV(src, evt, handles)
    try
        handles = guidata(handles.fig);
        
        table_data = get(handles.coefficients_table, 'Data');
        if isempty(table_data)
            errordlg('No data to export', 'No Data');
            return;
        end
        
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        [filename, pathname] = uiputfile('*.csv', 'Export Coefficients');
        if filename == 0
            return;
        end
        
        full_path = fullfile(pathname, filename);
        writecell([col_names; table_data], full_path);
        
        msgbox('Coefficients exported successfully!', 'Export Success');
        
    catch ME
        errordlg(sprintf('Export error: %s', ME.message), 'Export Error');
    end
end

function importCoefficientsFromCSV(src, evt, handles)
    try
        handles = guidata(handles.fig);
        
        [filename, pathname] = uigetfile('*.csv', 'Import Coefficients');
        if filename == 0
            return;
        end
        
        full_path = fullfile(pathname, filename);
        imported_data = readcell(full_path);
        
        if size(imported_data, 1) < 2
            errordlg('Invalid CSV file format', 'Import Error');
            return;
        end
        
        header = imported_data(1, :);
        data = imported_data(2:end, :);
        
        expected_cols = get(handles.coefficients_table, 'ColumnName');
        if length(header) ~= length(expected_cols)
            errordlg('Column count mismatch', 'Import Error');
            return;
        end
        
        set(handles.coefficients_table, 'Data', data);
        
        % Mark all data cells as edited
        handles.edited_cells = {};
        [num_rows, num_cols] = size(data);
        for row = 1:num_rows
            for col = 2:num_cols
                cell_key = sprintf('%d_%d', row, col);
                handles.edited_cells{end+1} = cell_key;
            end
        end
        
        guidata(handles.fig, handles);
        msgbox('Coefficients imported successfully!', 'Import Success');
        
    catch ME
        errordlg(sprintf('Import error: %s', ME.message), 'Import Error');
    end
end

% Main control functions
function startGeneration(src, evt, handles)
    try
        handles = guidata(handles.fig);
        
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
        
        % Start generation
        runGeneration(handles);
        
    catch ME
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
        errordlg(ME.message, 'Generation Error');
    end
end

function stopGeneration(src, evt, handles)
    handles = guidata(handles.fig);
    handles.should_stop = true;
    
    set(handles.status_text, 'String', 'Status: Stopping...');
    set(handles.start_button, 'Enable', 'on');
    set(handles.stop_button, 'Enable', 'off');
    
    guidata(handles.fig, handles);
end

function validateSettings(src, evt, handles)
    try
        config = validateInputs(handles);
        if ~isempty(config)
            msgbox('All settings are valid!', 'Validation Success');
        end
    catch ME
        errordlg(ME.message, 'Validation Failed');
    end
end

function saveConfiguration(src, evt, handles)
    try
        config = validateInputs(handles);
        if ~isempty(config)
            [filename, pathname] = uiputfile('*.mat', 'Save Configuration');
            if filename ~= 0
                save(fullfile(pathname, filename), 'config');
                msgbox('Configuration saved successfully!', 'Save Success');
            end
        end
    catch ME
        errordlg(sprintf('Save error: %s', ME.message), 'Save Failed');
    end
end

function loadConfiguration(src, evt, handles)
    try
        [filename, pathname] = uigetfile('*.mat', 'Load Configuration');
        if filename ~= 0
            loaded = load(fullfile(pathname, filename));
            if isfield(loaded, 'config')
                applyConfiguration(loaded.config, handles);
                updatePreview([], [], handles);
                msgbox('Configuration loaded successfully!', 'Load Success');
            else
                errordlg('Invalid configuration file', 'Load Failed');
            end
        end
    catch ME
        errordlg(sprintf('Load error: %s', ME.message), 'Load Failed');
    end
end

% Helper functions
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
        
        % Create config structure
        config = struct();
        config.model_name = handles.model_name;
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

function applyConfiguration(config, handles)
    set(handles.num_trials_edit, 'String', num2str(config.num_simulations));
    set(handles.sim_time_edit, 'String', num2str(config.simulation_time));
    set(handles.sample_rate_edit, 'String', num2str(config.sample_rate));
    set(handles.torque_scenario_popup, 'Value', config.torque_scenario);
    set(handles.coeff_range_edit, 'String', num2str(config.coeff_range));
    set(handles.constant_value_edit, 'String', num2str(config.constant_value));
    set(handles.use_model_workspace, 'Value', config.use_model_workspace);
    set(handles.use_logsout, 'Value', config.use_logsout);
    set(handles.use_signal_bus, 'Value', config.use_signal_bus);
    set(handles.use_simscape, 'Value', config.use_simscape);
    
    % Update model name if present in config
    if isfield(config, 'model_name')
        handles.model_name = config.model_name;
        set(handles.model_display, 'String', config.model_name);
        guidata(handles.fig, handles);
    end
    
    [folder, name] = fileparts(config.output_folder);
    set(handles.output_folder_edit, 'String', folder);
    set(handles.folder_name_edit, 'String', name);
end

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
        
        successful_trials = 0;
        failed_trials = 0;
        
        for trial = 1:config.num_simulations
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
                
                result = runSingleTrialWithSignalBus(trial, config, trial_coefficients);
                
                if result.success
                    successful_trials = successful_trials + 1;
                else
                    failed_trials = failed_trials + 1;
                end
                
            catch ME
                failed_trials = failed_trials + 1;
                fprintf('Trial %d error: %s\n', trial, ME.message);
            end
        end
        
        % Final status
        final_msg = sprintf('Complete: %d successful, %d failed', successful_trials, failed_trials);
        set(handles.status_text, 'String', ['Status: ' final_msg]);
        set(handles.progress_text, 'String', final_msg);
        
        % Compile all trials into master dataset if successful trials exist
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

function param_info = getPolynomialParameterInfo()
    % Get polynomial parameter structure - ONLY 7-coefficient joints (A-G)
    try
        % Try to load from model folder
        model_path = fullfile(fileparts(fileparts(pwd)), 'Model', 'PolynomialInputValues.mat');
        if ~exist(model_path, 'file')
            model_path = '../../Model/PolynomialInputValues.mat';
        end
        
        if exist(model_path, 'file')
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
            
            % Filter to only 7-coefficient joints (A-G)
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
            
            % Reorder coeffs to match sorted joint names
            for i = 1:length(param_info.joint_names)
                joint_name = param_info.joint_names{i};
                idx = find(strcmp(filtered_joint_names, joint_name));
                param_info.joint_coeffs{i} = filtered_coeffs{idx};
            end
            
            param_info.total_params = length(param_info.joint_names) * 7;
            
        else
            warning('PolynomialInputValues.mat not found, using simplified structure');
            param_info = getSimplifiedParameterInfo();
        end
        
    catch ME
        warning('Error loading polynomial parameters: %s. Using simplified structure.', ME.message);
        param_info = getSimplifiedParameterInfo();
    end
end

function param_info = getSimplifiedParameterInfo()
    % Fallback simplified structure
    joint_names = {
        'BaseTorqueInputX', 'BaseTorqueInputY', 'BaseTorqueInputZ',
        'HipInputX', 'HipInputY', 'HipInputZ',
        'LSInputX', 'LSInputY', 'LSInputZ',
        'LScapInputX', 'LScapInputY', 'LScapInputZ',
        'LTiltInputX', 'LTiltInputY', 'LTiltInputZ',
        'NeckInputX', 'NeckInputY', 'NeckInputZ',
        'RSInputX', 'RSInputY', 'RSInputZ',
        'RScapInputX', 'RScapInputY', 'RScapInputZ',
        'RTiltInputX', 'RTiltInputY', 'RTiltInputZ'
    };
    
    param_info.joint_names = joint_names;
    param_info.joint_coeffs = cell(size(joint_names));
    for i = 1:length(joint_names)
        param_info.joint_coeffs{i} = 'ABCDEFG';
    end
    param_info.total_params = length(joint_names) * 7;
end

function short_name = getShortenedJointName(joint_name)
    % Create consistent shortened joint names for display
    short_name = strrep(joint_name, 'TorqueInput', 'T');
    short_name = strrep(short_name, 'Input', '');
end

% Placeholder for actual trial execution
function result = runSingleTrialWithSignalBus(trial_num, config, trial_coefficients)
    % Enhanced trial execution with proper data labeling for ML
    result = struct();
    
    try
        % Run the actual simulation
        simResult = runSingleTrial(trial_num, config);
        
        if simResult.success
            % Read the generated CSV file
            csv_path = fullfile(config.output_folder, simResult.filename);
            if exist(csv_path, 'file')
                % Read existing data
                data_table = readtable(csv_path);
                
                % Add trial metadata columns for ML labeling
                num_rows = height(data_table);
                
                % Add trial ID column
                data_table.trial_id = repmat(trial_num, num_rows, 1);
                
                % Add coefficient columns as features
                param_info = getPolynomialParameterInfo();
                col_idx = 1;
                for j = 1:length(param_info.joint_names)
                    joint_name = param_info.joint_names{j};
                    coeffs = param_info.joint_coeffs{j};
                    for k = 1:length(coeffs)
                        coeff_name = sprintf('input_%s_%s', getShortenedJointName(joint_name), coeffs(k));
                        data_table.(coeff_name) = repmat(trial_coefficients(col_idx), num_rows, 1);
                        col_idx = col_idx + 1;
                    end
                end
                
                % Add scenario metadata
                data_table.torque_scenario = repmat(config.torque_scenario, num_rows, 1);
                data_table.coeff_range = repmat(config.coeff_range, num_rows, 1);
                data_table.constant_value = repmat(config.constant_value, num_rows, 1);
                
                % Add timestamp for data versioning
                data_table.generation_timestamp = repmat(datestr(now, 'yyyy-mm-dd HH:MM:SS'), num_rows, 1);
                
                % Reorder columns for better organization
                % Put metadata first, then inputs, then simulation outputs
                metadata_cols = {'trial_id', 'time', 'simulation_id', 'torque_scenario', ...
                                'coeff_range', 'constant_value', 'generation_timestamp'};
                input_cols = data_table.Properties.VariableNames(contains(data_table.Properties.VariableNames, 'input_'));
                output_cols = setdiff(data_table.Properties.VariableNames, [metadata_cols, input_cols]);
                
                ordered_cols = [metadata_cols, input_cols, output_cols];
                existing_cols = intersect(ordered_cols, data_table.Properties.VariableNames, 'stable');
                data_table = data_table(:, existing_cols);
                
                % Save enhanced CSV with ML-ready format
                enhanced_filename = sprintf('ml_trial_%03d_%s.csv', trial_num, datestr(now, 'yyyymmdd_HHMMSS'));
                enhanced_path = fullfile(config.output_folder, enhanced_filename);
                writetable(data_table, enhanced_path);
                
                % Also save a metadata file for this trial
                metadata = struct();
                metadata.trial_id = trial_num;
                metadata.coefficients = trial_coefficients;
                metadata.joint_names = param_info.joint_names;
                metadata.joint_coeffs = param_info.joint_coeffs;
                metadata.config = config;
                metadata.timestamp = datetime('now');
                
                metadata_filename = sprintf('ml_trial_%03d_metadata.mat', trial_num);
                metadata_path = fullfile(config.output_folder, metadata_filename);
                save(metadata_path, 'metadata');
                
                result.success = true;
                result.filename = enhanced_filename;
                result.data_points = num_rows;
                result.columns = width(data_table);
                result.metadata_file = metadata_filename;
            else
                result.success = false;
                result.error = 'CSV file not found after simulation';
            end
        else
            result = simResult;
        end
        
    catch ME
        result.success = false;
        result.error = ME.message;
        result.filename = '';
    end
end

function searchCoefficients(src, evt, handles)
    try
        % Get the latest handles structure
        if isfield(handles, 'fig')
            handles = guidata(handles.fig);
        else
            fig = ancestor(src, 'figure');
            handles = guidata(fig);
        end
        
        if ~isfield(handles, 'coefficients_table')
            return;
        end
        
        search_text = get(handles.search_edit, 'String');
        
        % Store original data if not already stored
        if ~isfield(handles, 'original_coefficients_data') || isempty(handles.original_coefficients_data)
            handles.original_coefficients_data = get(handles.coefficients_table, 'Data');
            handles.original_coefficients_columns = get(handles.coefficients_table, 'ColumnName');
            guidata(handles.fig, handles);
        end
        
        if isempty(search_text)
            % Restore original data without regenerating
            restoreOriginalTable(handles);
            return;
        end
        
        % Use stored original data for filtering
        table_data = handles.original_coefficients_data;
        col_names = handles.original_coefficients_columns;
        
        % Find matching columns
        matching_cols = [];
        for i = 2:length(col_names) % Skip trial number column
            if contains(col_names{i}, search_text, 'IgnoreCase', true)
                matching_cols = [matching_cols, i];
            end
        end
        
        if ~isempty(matching_cols)
            % Update status
            if isfield(handles, 'joint_status')
                set(handles.joint_status, 'String', sprintf('Found %d matching columns', length(matching_cols)));
            end
            
            % Include trial column and matching columns
            display_cols = [1, matching_cols]; % Always include trial column (index 1)
            filtered_data = table_data(:, display_cols);
            filtered_names = col_names(display_cols);
            
            % Update table to show only matching columns
            set(handles.coefficients_table, 'Data', filtered_data);
            set(handles.coefficients_table, 'ColumnName', filtered_names);
        else
            if isfield(handles, 'joint_status')
                set(handles.joint_status, 'String', 'No matching columns found');
            end
            
            % Show only trial column when no matches
            set(handles.coefficients_table, 'Data', table_data(:,1));
            set(handles.coefficients_table, 'ColumnName', col_names(1));
        end
        
    catch ME
        fprintf('Error in searchCoefficients: %s\n', ME.message);
    end
end

function restoreOriginalTable(handles)
    % Restore original table data without regenerating coefficients
    if isfield(handles, 'original_coefficients_data') && ~isempty(handles.original_coefficients_data)
        set(handles.coefficients_table, 'Data', handles.original_coefficients_data);
        set(handles.coefficients_table, 'ColumnName', handles.original_coefficients_columns);
        
        % Restore original table properties if available
        if isfield(handles, 'original_column_widths') && ~isempty(handles.original_column_widths)
            set(handles.coefficients_table, 'ColumnWidth', handles.original_column_widths);
        end
        if isfield(handles, 'original_column_editable') && ~isempty(handles.original_column_editable)
            set(handles.coefficients_table, 'ColumnEditable', handles.original_column_editable);
        end
        
        % Reset status
        if isfield(handles, 'joint_status')
            set(handles.joint_status, 'String', 'Showing all coefficients');
        end
    else
        % If no original data, regenerate the table
        fprintf('No original data found, regenerating coefficients table...\n');
        updateCoefficientsPreview([], [], handles);
    end
end

function clearSearch(src, evt, handles)
    try
        % Get the latest handles structure
        if isfield(handles, 'fig')
            handles = guidata(handles.fig);
        else
            fig = ancestor(src, 'figure');
            handles = guidata(fig);
        end
        
        % Clear search text
        if isfield(handles, 'search_edit')
            set(handles.search_edit, 'String', '');
        end
        
        % Restore original table data WITHOUT regenerating coefficients
        restoreOriginalTable(handles);
        
    catch ME
        fprintf('Error in clearSearch: %s\n', ME.message);
    end
end

function compileDataset(config)
    % Compile all individual trial CSV files into a master dataset
    try
        fprintf('Compiling dataset from trials...\n');
        
        % Find all ML trial CSV files
        csv_files = dir(fullfile(config.output_folder, 'ml_trial_*.csv'));
        
        if isempty(csv_files)
            warning('No ML trial CSV files found in output folder');
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
                    master_data = [master_data(:, common_vars); trial_data(:, common_vars)];
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
            fprintf('✓ Master dataset saved: %s\n', master_filename);
            fprintf('  Total rows: %d\n', height(master_data));
            fprintf('  Total columns: %d\n', width(master_data));
            
            % Also save in MAT format for faster loading
            master_mat_filename = sprintf('master_dataset_%s.mat', timestamp);
            master_mat_path = fullfile(config.output_folder, master_mat_filename);
            save(master_mat_path, 'master_data');
            fprintf('✓ MAT format saved: %s\n', master_mat_filename);
            
            % Create summary statistics
            createDatasetSummary(master_data, config.output_folder, timestamp);
        end
        
    catch ME
        fprintf('Error compiling dataset: %s\n', ME.message);
    end
end

function createDatasetSummary(data, output_folder, timestamp)
    % Create a summary report of the dataset
    try
        summary_filename = sprintf('dataset_summary_%s.txt', timestamp);
        summary_path = fullfile(output_folder, summary_filename);
        
        fid = fopen(summary_path, 'w');
        if fid == -1
            warning('Could not create summary file');
            return;
        end
        
        fprintf(fid, 'Golf Swing Dataset Summary\n');
        fprintf(fid, '==========================\n\n');
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        
        fprintf(fid, 'Dataset Statistics:\n');
        fprintf(fid, '- Total samples: %d\n', height(data));
        fprintf(fid, '- Total features: %d\n', width(data));
        fprintf(fid, '- Unique trials: %d\n', length(unique(data.trial_id)));
        
        fprintf(fid, '\nColumn Types:\n');
        metadata_cols = data.Properties.VariableNames(contains(data.Properties.VariableNames, {'trial_', 'time', 'simulation_', 'scenario', 'timestamp'}));
        input_cols = data.Properties.VariableNames(contains(data.Properties.VariableNames, 'input_'));
        output_cols = setdiff(data.Properties.VariableNames, [metadata_cols, input_cols]);
        
        fprintf(fid, '- Metadata columns: %d\n', length(metadata_cols));
        fprintf(fid, '- Input features: %d\n', length(input_cols));
        fprintf(fid, '- Output variables: %d\n', length(output_cols));
        
        fprintf(fid, '\nInput Features:\n');
        for i = 1:length(input_cols)
            fprintf(fid, '  - %s\n', input_cols{i});
        end
        
        fprintf(fid, '\nOutput Variables (first 20):\n');
        for i = 1:min(20, length(output_cols))
            fprintf(fid, '  - %s\n', output_cols{i});
        end
        
        fclose(fid);
        fprintf('✓ Summary saved: %s\n', summary_filename);
        
    catch ME
        warning('Error creating summary: %s', ME.message);
    end
end

% ==================== MISSING CALLBACK FUNCTIONS ====================

function browseInputFile(~, ~, handles)
    % Browse for input file
    [filename, pathname] = uigetfile({'*.mat', 'MAT files'; '*.csv', 'CSV files'}, 'Select Input File');
    if filename ~= 0
        handles = guidata(handles.fig);
        fullPath = fullfile(pathname, filename);
        
        % Update GUI displays - show filename in edit box, store full path
        set(handles.input_file_edit, 'String', filename);
        set(handles.input_file_edit, 'TooltipString', sprintf('Full path: %s', fullPath));
        
        % Store the selected file path
        handles.selected_input_file = fullPath;
        
        % Clear status message since user manually selected a new file
        if isfield(handles, 'file_status_text')
            set(handles.file_status_text, 'String', '');
        end
        
        guidata(handles.fig, handles);
        
        % Save preferences automatically
        saveUserPreferences(handles);
        
        % Validate the file
        validateInputFile(fullPath, handles);
    end
end

function clearInputFile(~, ~, handles)
    % Clear the selected input file
    handles = guidata(handles.fig);
    set(handles.input_file_edit, 'String', 'Select a .mat input file...');
    set(handles.input_file_edit, 'TooltipString', 'Selected starting point .mat file (hover to see full path)');
    
    % Clear the selected file path
    handles.selected_input_file = '';
    guidata(handles.fig, handles);
end









function validateInputFile(file_path, handles)
    % Validate the selected input file
    try
        % Try to load the file to check if it's valid
        file_info = whos('-file', file_path);
        
        if isempty(file_info)
            warndlg('Selected file appears to be empty or invalid.', 'File Warning');
        else
            % Show basic file information
            [~, name, ~] = fileparts(file_path);
            var_count = length(file_info);
            
            fprintf('✓ Input file loaded: %s (%d variables)\n', name, var_count);
        end
        
    catch ME
        errordlg(sprintf('Error validating input file: %s', ME.message), 'File Error');
        clearInputFile([], [], handles);
    end
end

function saveScenario(~, ~, handles)
    % Save current torque coefficient scenario
    try
        % Get current table data
        data = get(handles.coefficients_table, 'Data');
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        if isempty(data)
            errordlg('No coefficient data to save. Please generate coefficients first.', 'Save Error');
            return;
        end
        
        % Create scenario structure
        scenario = struct();
        scenario.name = inputdlg('Enter scenario name:', 'Save Scenario', 1, {datestr(now, 'yyyy-mm-dd_HH-MM-SS')});
        if isempty(scenario.name) || isempty(scenario.name{1})
            return; % User cancelled
        end
        scenario.name = scenario.name{1};
        
        scenario.description = inputdlg('Enter scenario description (optional):', 'Save Scenario', 1, {''});
        if isempty(scenario.description)
            scenario.description = {''};
        end
        scenario.description = scenario.description{1};
        
        scenario.coefficients_data = data;
        scenario.column_names = col_names;
        scenario.timestamp = datestr(now);
        scenario.torque_scenario = get(handles.torque_scenario_popup, 'Value');
        scenario.coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        scenario.constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        % Save to file
        [filename, pathname] = uiputfile('*.mat', 'Save Scenario', ...
            sprintf('scenario_%s.mat', regexprep(scenario.name, '[^a-zA-Z0-9_]', '_')));
        
        if filename ~= 0
            save(fullfile(pathname, filename), 'scenario');
            msgbox(sprintf('Scenario "%s" saved successfully!', scenario.name), 'Save Success');
        end
        
    catch ME
        errordlg(sprintf('Error saving scenario: %s', ME.message), 'Save Error');
    end
end

function loadScenario(~, ~, handles)
    % Load saved torque coefficient scenario
    try
        [filename, pathname] = uigetfile('*.mat', 'Load Scenario');
        if filename == 0
            return; % User cancelled
        end
        
        loaded = load(fullfile(pathname, filename));
        if ~isfield(loaded, 'scenario')
            errordlg('Invalid scenario file. File must contain a "scenario" structure.', 'Load Error');
            return;
        end
        
        scenario = loaded.scenario;
        
        % Validate scenario structure
        if ~isfield(scenario, 'coefficients_data') || ~isfield(scenario, 'column_names')
            errordlg('Invalid scenario file. Missing required fields.', 'Load Error');
            return;
        end
        
        % Apply scenario to GUI
        set(handles.coefficients_table, 'Data', scenario.coefficients_data);
        set(handles.coefficients_table, 'ColumnName', scenario.column_names);
        
        % Apply scenario settings if available
        if isfield(scenario, 'torque_scenario')
            set(handles.torque_scenario_popup, 'Value', scenario.torque_scenario);
            torqueScenarioCallback(handles.torque_scenario_popup, [], handles);
        end
        if isfield(scenario, 'coeff_range')
            set(handles.coeff_range_edit, 'String', num2str(scenario.coeff_range));
        end
        if isfield(scenario, 'constant_value')
            set(handles.constant_value_edit, 'String', num2str(scenario.constant_value));
        end
        
        % Store as full data for search functionality
        handles.coefficients_data_full = scenario.coefficients_data;
        guidata(handles.fig, handles);
        
        % Show success message
        name_str = '';
        if isfield(scenario, 'name')
            name_str = sprintf(' "%s"', scenario.name);
        end
        msgbox(sprintf('Scenario%s loaded successfully!', name_str), 'Load Success');
        
    catch ME
        errordlg(sprintf('Error loading scenario: %s', ME.message), 'Load Error');
    end
end

% ==================== USER PREFERENCES ====================

function handles = loadUserPreferences(handles)
    % Load user preferences from file
    pref_file = fullfile(pwd, 'Scripts', 'Simulation_Dataset_GUI', 'user_preferences.mat');
    
    % Default preferences
    handles.preferences = struct();
    handles.preferences.last_input_file = '';
    handles.preferences.last_output_folder = pwd;
    handles.preferences.last_simulink_model = '';
    handles.preferences.default_num_trials = 50;
    handles.preferences.default_sim_time = 1.5;
    handles.preferences.default_sample_rate = 1000;
    
    % Load saved preferences if they exist
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
            % If loading fails, use defaults
            fprintf('Warning: Could not load user preferences, using defaults.\n');
        end
    end
end

function applyUserPreferences(handles)
    % Apply loaded preferences to the UI controls
    try
        prefs = handles.preferences;
        
        % Apply last input file if it exists and is valid
        if ~isempty(prefs.last_input_file) && exist(prefs.last_input_file, 'file')
            [~, filename, ext] = fileparts(prefs.last_input_file);
            set(handles.input_file_edit, 'String', [filename, ext]);
            set(handles.input_file_edit, 'TooltipString', sprintf('Last used file: %s', prefs.last_input_file));
            handles.selected_input_file = prefs.last_input_file;
            
            % Show status message
            if isfield(handles, 'file_status_text')
                set(handles.file_status_text, 'String', '✓ Last used file automatically loaded');
            end
            
            guidata(handles.fig, handles);
        end
        
        % Apply other preferences
        if isfield(handles, 'output_folder_edit') && ~isempty(prefs.last_output_folder)
            set(handles.output_folder_edit, 'String', prefs.last_output_folder);
        end
        
        if isfield(handles, 'num_trials_edit')
            set(handles.num_trials_edit, 'String', num2str(prefs.default_num_trials));
        end
        
        if isfield(handles, 'sim_time_edit')
            set(handles.sim_time_edit, 'String', num2str(prefs.default_sim_time));
        end
        
        if isfield(handles, 'sample_rate_edit')
            set(handles.sample_rate_edit, 'String', num2str(prefs.default_sample_rate));
        end
        
    catch ME
        fprintf('Warning: Error applying user preferences: %s\n', ME.message);
    end
end

function saveUserPreferences(handles)
    % Save current settings as user preferences
    try
        pref_file = fullfile(pwd, 'Scripts', 'Simulation_Dataset_GUI', 'user_preferences.mat');
        
        % Update preferences with current settings
        if isfield(handles, 'selected_input_file') && ~isempty(handles.selected_input_file)
            handles.preferences.last_input_file = handles.selected_input_file;
        end
        
        if isfield(handles, 'output_folder_edit')
            folder = get(handles.output_folder_edit, 'String');
            if ~isempty(folder)
                handles.preferences.last_output_folder = folder;
            end
        end
        
        if isfield(handles, 'num_trials_edit')
            trials = str2double(get(handles.num_trials_edit, 'String'));
            if ~isnan(trials)
                handles.preferences.default_num_trials = trials;
            end
        end
        
        if isfield(handles, 'sim_time_edit')
            sim_time = str2double(get(handles.sim_time_edit, 'String'));
            if ~isnan(sim_time)
                handles.preferences.default_sim_time = sim_time;
            end
        end
        
        if isfield(handles, 'sample_rate_edit')
            sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
            if ~isnan(sample_rate)
                handles.preferences.default_sample_rate = sample_rate;
            end
        end
        
        % Save preferences to file
        preferences = handles.preferences; %#ok<NASGU>
        save(pref_file, 'preferences');
        
    catch ME
        fprintf('Warning: Could not save user preferences: %s\n', ME.message);
    end
end