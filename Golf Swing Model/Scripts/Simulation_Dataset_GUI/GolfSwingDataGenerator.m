function GolfSwingDataGenerator()
    % GolfSwingDataGenerator - Enhanced GUI for generating golf swing training data
    % This GUI provides an intuitive interface for configuring and running
    % multiple simulation trials with different torque scenarios and data sources.
    
         % Create main figure with proper sizing
     fig = figure('Name', 'Golf Swing Data Generator', ...
                  'Position', [50, 50, 1600, 900], ...
                  'MenuBar', 'none', ...
                  'ToolBar', 'none', ...
                  'Resize', 'on', ...
                  'Color', [0.94, 0.94, 0.94], ...
                  'NumberTitle', 'off');
    
    % Initialize handles structure
    handles = struct();
    handles.should_stop = false;
    handles.fig = fig;
    
    % Create main layout with scroll bars
    handles = createMainLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
    
    % Initialize preview now that all handles are properly set up
    updatePreview([], [], handles);
    updateCoefficientsPreview([], [], handles);
end

function handles = createMainLayout(fig, handles)
    % Create main layout with proper two columns and scroll bars
    
         % Title panel
     title_panel = uipanel('Parent', fig, ...
                          'Title', 'Golf Swing Data Generator', ...
                          'TitlePosition', 'centertop', ...
                          'FontSize', 18, ...
                          'FontWeight', 'bold', ...
                          'Position', [0.01, 0.93, 0.98, 0.06], ...
                          'BackgroundColor', [0.85, 0.90, 0.95], ...
                          'ForegroundColor', [0.1, 0.1, 0.4]);
    
    % Left column with scroll capability
    left_panel = uipanel('Parent', fig, ...
                        'Position', [0.01, 0.01, 0.49, 0.91], ...
                        'BackgroundColor', [0.96, 0.96, 0.96], ...
                        'BorderType', 'line');
    
         left_scroll = uicontrol('Parent', left_panel, ...
                            'Style', 'slider', ...
                            'Position', [765, 10, 15, 800], ...
                            'Min', 0, 'Max', 1, ...
                            'Value', 1, ...
                            'Callback', @(src,evt) scrollLeftColumn(src, evt, handles));
     
     % Left content panel (scrollable)
     left_content = uipanel('Parent', left_panel, ...
                           'Position', [5, 5, 755, 810], ...
                           'BackgroundColor', [0.96, 0.96, 0.96], ...
                           'BorderType', 'none');
    
    % Right column with scroll capability
    right_panel = uipanel('Parent', fig, ...
                         'Position', [0.51, 0.01, 0.48, 0.91], ...
                         'BackgroundColor', [0.96, 0.96, 0.96], ...
                         'BorderType', 'line');
    
         right_scroll = uicontrol('Parent', right_panel, ...
                             'Style', 'slider', ...
                             'Position', [750, 10, 15, 780], ...
                             'Min', 0, 'Max', 1, ...
                             'Value', 1, ...
                             'Callback', @(src,evt) scrollRightColumn(src, evt, handles));
     
     % Right content panel (scrollable)
     right_content = uipanel('Parent', right_panel, ...
                            'Position', [5, 5, 740, 790], ...
                            'BackgroundColor', [0.96, 0.96, 0.96], ...
                            'BorderType', 'none');
    
    % Store panel references
    handles.left_content = left_content;
    handles.right_content = right_content;
    handles.left_scroll = left_scroll;
    handles.right_scroll = right_scroll;
    
    % Create content in both columns
    handles = createLeftColumnContent(left_content, handles);
    handles = createRightColumnContent(right_content, handles);
end

function handles = createLeftColumnContent(parent, handles)
    % Create all content for the left column
    
    % Combined Trial Settings & Data Sources Panel
    handles = createTrialAndDataPanel(parent, handles);
    
    % Modeling Configuration Panel
    handles = createModelingPanel(parent, handles);
    
    % Individual Joint Editor Panel
    handles = createJointEditorPanel(parent, handles);
    
    % Output Settings Panel
    handles = createOutputPanel(parent, handles);
end

function handles = createRightColumnContent(parent, handles)
    % Create all content for the right column
    
    % Preview Panel
    handles = createPreviewPanel(parent, handles);
    
    % Coefficients Table Panel
    handles = createCoefficientsPanel(parent, handles);
    
    % Progress Panel
    handles = createProgressPanel(parent, handles);
    
    % Control Buttons Panel
    handles = createControlPanel(parent, handles);
end

function handles = createTrialAndDataPanel(parent, handles)
         % Combined Trial Settings and Data Sources Configuration
     panel = uipanel('Parent', parent, ...
                    'Title', 'Trial Settings & Data Sources', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 620, 730, 150], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Trial Settings section
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'TRIAL SETTINGS', ...
              'Position', [20, 135, 150, 20], ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    % Number of trials
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Number of Trials:', ...
              'Position', [20, 110, 120, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.num_trials_edit = uicontrol('Parent', panel, ...
                                       'Style', 'edit', ...
                                       'String', '10', ...
                                       'Position', [150, 110, 60, 22], ...
                                       'FontSize', 10, ...
                                       'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    % Simulation duration
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Duration (s):', ...
              'Position', [220, 110, 80, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.sim_time_edit = uicontrol('Parent', panel, ...
                                     'Style', 'edit', ...
                                     'String', '0.3', ...
                                     'Position', [300, 110, 60, 22], ...
                                     'FontSize', 10);
    
    % Sample rate
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Sample Rate (Hz):', ...
              'Position', [20, 85, 120, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.sample_rate_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', '100', ...
                                        'Position', [150, 85, 60, 22], ...
                                        'FontSize', 10);
    
    % Execution mode
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Execution Mode:', ...
              'Position', [220, 85, 100, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.execution_mode_popup = uicontrol('Parent', panel, ...
                                            'Style', 'popupmenu', ...
                                            'String', {'Sequential', 'Parallel'}, ...
                                            'Position', [320, 85, 100, 22], ...
                                            'FontSize', 10);
    
    % Data Sources section
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'DATA SOURCES', ...
              'Position', [20, 55, 150, 20], ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    % Data source checkboxes
    handles.use_model_workspace = uicontrol('Parent', panel, ...
                                           'Style', 'checkbox', ...
                                           'String', 'Model Workspace', ...
                                           'Position', [20, 30, 150, 20], ...
                                           'Value', 1, ...
                                           'FontSize', 10);
    
    handles.use_logsout = uicontrol('Parent', panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Logsout', ...
                                   'Position', [180, 30, 100, 20], ...
                                   'Value', 1, ...
                                   'FontSize', 10);
    
    handles.use_signal_bus = uicontrol('Parent', panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'Signal Bus', ...
                                      'Position', [290, 30, 100, 20], ...
                                      'Value', 1, ...
                                      'FontSize', 10);
    
    handles.use_simscape = uicontrol('Parent', panel, ...
                                    'Style', 'checkbox', ...
                                    'String', 'Simscape Results', ...
                                    'Position', [400, 30, 130, 20], ...
                                    'Value', 1, ...
                                    'FontSize', 10);
    
    handles.trial_data_panel = panel;
end

function handles = createModelingPanel(parent, handles)
         % Modeling Configuration Panel (without blue boxes)
     panel = uipanel('Parent', parent, ...
                    'Title', 'Modeling Configuration', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 460, 730, 150], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Torque scenario
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Torque Scenario:', ...
              'Position', [20, 120, 120, 20], ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    handles.torque_scenario_popup = uicontrol('Parent', panel, ...
                                             'Style', 'popupmenu', ...
                                             'String', {'Variable Torques', 'Zero Torque', 'Constant Torque'}, ...
                                             'Position', [150, 120, 180, 25], ...
                                             'FontSize', 10, ...
                                             'Callback', @(src,evt) torqueScenarioCallback(src, evt, handles));
    
    % Coefficient range
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Coefficient Range (±):', ...
              'Position', [20, 90, 130, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.coeff_range_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', '50', ...
                                        'Position', [160, 90, 70, 22], ...
                                        'FontSize', 10, ...
                                        'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    % Constant value
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Constant Value (G):', ...
              'Position', [250, 90, 120, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.constant_value_edit = uicontrol('Parent', panel, ...
                                           'Style', 'edit', ...
                                           'String', '10', ...
                                           'Position', [370, 90, 70, 22], ...
                                           'FontSize', 10, ...
                                           'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    % Model selection
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Simulink Model:', ...
              'Position', [20, 60, 120, 20], ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'left');
    
    handles.model_edit = uicontrol('Parent', panel, ...
                                  'Style', 'edit', ...
                                  'String', 'GolfSwing3D_Kinetic', ...
                                  'Position', [150, 60, 200, 22], ...
                                  'FontSize', 10);
    
    % Mode info (simple text, no blue box)
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Mode 3: Hexagonal Polynomial (7 coefficients A-G per joint)', ...
              'Position', [20, 25, 400, 20], ...
              'FontSize', 9, ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.modeling_panel = panel;
end

function handles = createJointEditorPanel(parent, handles)
    % Individual Joint Editor with trial selection capability
    param_info = getPolynomialParameterInfo();
    
         panel = uipanel('Parent', parent, ...
                    'Title', 'Individual Joint Editor', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 300, 730, 150], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Joint selection
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Select Joint:', ...
              'Position', [20, 120, 80, 20], ...
              'FontSize', 10, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    handles.joint_selector = uicontrol('Parent', panel, ...
                                      'Style', 'popupmenu', ...
                                      'String', param_info.joint_names, ...
                                      'Position', [110, 120, 180, 25], ...
                                      'FontSize', 10, ...
                                      'Callback', @(src,evt) updateJointCoefficients(src, evt, handles));
    
         % Trial selection (NEW FEATURE)
     uicontrol('Parent', panel, ...
               'Style', 'text', ...
               'String', 'Apply to:', ...
               'Position', [300, 120, 60, 20], ...
               'FontSize', 10, ...
               'FontWeight', 'bold', ...
               'HorizontalAlignment', 'left');
     
     handles.trial_selection_popup = uicontrol('Parent', panel, ...
                                              'Style', 'popupmenu', ...
                                              'String', {'All Trials', 'Specific Trial'}, ...
                                              'Position', [360, 120, 100, 25], ...
                                              'FontSize', 10, ...
                                              'Callback', @(src,evt) updateTrialSelectionMode(src, evt, handles));
     
     % Trial number input box
     uicontrol('Parent', panel, ...
               'Style', 'text', ...
               'String', '#:', ...
               'Position', [470, 120, 15, 20], ...
               'FontSize', 10, ...
               'HorizontalAlignment', 'left');
     
     handles.trial_number_edit = uicontrol('Parent', panel, ...
                                          'Style', 'edit', ...
                                          'String', '1', ...
                                          'Position', [485, 120, 40, 22], ...
                                          'FontSize', 10, ...
                                          'Enable', 'off');
    
    % Coefficient edit boxes (A-G)
    coeff_labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
    handles.joint_coeff_edits = [];
    
    for i = 1:7
        % Label
        uicontrol('Parent', panel, ...
                  'Style', 'text', ...
                  'String', coeff_labels{i}, ...
                  'Position', [20 + (i-1)*60, 80, 15, 20], ...
                  'FontSize', 10, ...
                  'FontWeight', 'bold', ...
                  'HorizontalAlignment', 'center');
        
        % Edit box
        handles.joint_coeff_edits(i) = uicontrol('Parent', panel, ...
                                                'Style', 'edit', ...
                                                'String', '0.00', ...
                                                'Position', [35 + (i-1)*60, 80, 45, 22], ...
                                                'FontSize', 9, ...
                                                'HorizontalAlignment', 'center', ...
                                                'Callback', @(src,evt) validateCoefficientInput(src, evt, handles));
    end
    
    % Action buttons
    handles.apply_joint_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Apply to Table', ...
                                          'Position', [20, 40, 120, 30], ...
                                          'FontSize', 10, ...
                                          'FontWeight', 'bold', ...
                                          'BackgroundColor', [0.7, 0.9, 0.7], ...
                                          'Callback', @(src,evt) applyJointToTable(src, evt, handles));
    
    handles.load_joint_button = uicontrol('Parent', panel, ...
                                         'Style', 'pushbutton', ...
                                         'String', 'Load from Table', ...
                                         'Position', [150, 40, 120, 30], ...
                                         'FontSize', 10, ...
                                         'FontWeight', 'bold', ...
                                         'BackgroundColor', [0.9, 0.9, 0.7], ...
                                         'Callback', @(src,evt) loadJointFromTable(src, evt, handles));
    
    % Status
    handles.joint_status = uicontrol('Parent', panel, ...
                                    'Style', 'text', ...
                                    'String', sprintf('Ready - %s selected', param_info.joint_names{1}), ...
                                    'Position', [20, 15, 400, 20], ...
                                    'FontSize', 9, ...
                                    'HorizontalAlignment', 'left', ...
                                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.joint_editor_panel = panel;
    handles.param_info = param_info;
end

function handles = createOutputPanel(parent, handles)
         % Output Configuration Panel
     panel = uipanel('Parent', parent, ...
                    'Title', 'Output Configuration', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 10, 730, 280], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Output folder
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Position', [20, 200, 100, 20], ...
              'FontSize', 10, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    handles.output_folder_edit = uicontrol('Parent', panel, ...
                                          'Style', 'edit', ...
                                          'String', pwd, ...
                                          'Position', [130, 200, 250, 22], ...
                                          'FontSize', 9);
    
    handles.browse_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Browse', ...
                                     'Position', [390, 200, 60, 22], ...
                                     'FontSize', 10, ...
                                     'Callback', @(src,evt) browseOutputFolder(src, evt, handles));
    
    % Dataset folder name
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Dataset Folder:', ...
              'Position', [20, 170, 100, 20], ...
              'FontSize', 10, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    handles.folder_name_edit = uicontrol('Parent', panel, ...
                                        'Style', 'edit', ...
                                        'String', 'training_data_csv', ...
                                        'Position', [130, 170, 200, 22], ...
                                        'FontSize', 10);
    
    % File format
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'File Format:', ...
              'Position', [20, 140, 100, 20], ...
              'FontSize', 10, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left');
    
    handles.format_popup = uicontrol('Parent', panel, ...
                                    'Style', 'popupmenu', ...
                                    'String', {'CSV Files', 'MAT Files', 'Both CSV and MAT'}, ...
                                    'Position', [130, 140, 140, 25], ...
                                    'FontSize', 10);
    
    % Info text (simple, no blue box)
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Files saved with trial numbers and timestamps for identification.', ...
              'Position', [20, 25, 400, 30], ...
              'FontSize', 9, ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.output_panel = panel;
end

function handles = createPreviewPanel(parent, handles)
         % Input Parameters Preview Panel
     panel = uipanel('Parent', parent, ...
                    'Title', 'Input Parameters Preview', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 440, 720, 360], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Update button
    handles.update_preview_button = uicontrol('Parent', panel, ...
                                             'Style', 'pushbutton', ...
                                             'String', 'Update Preview', ...
                                             'Position', [20, 360, 120, 30], ...
                                             'FontSize', 11, ...
                                             'FontWeight', 'bold', ...
                                             'BackgroundColor', [0.2, 0.7, 0.2], ...
                                             'ForegroundColor', 'white', ...
                                             'Callback', @(src,evt) updatePreview(src, evt, handles));
    
    % Preview table
    handles.preview_table = uitable('Parent', panel, ...
                                   'Position', [20, 60, 580, 295], ...
                                   'ColumnName', {'Parameter', 'Value', 'Description'}, ...
                                   'ColumnWidth', {140, 120, 320}, ...
                                   'FontSize', 9, ...
                                   'RowStriping', 'on');
    
    % Simple instruction text
    uicontrol('Parent', panel, ...
              'Style', 'text', ...
              'String', 'Current parameter settings and expected simulation configuration.', ...
              'Position', [20, 25, 580, 25], ...
              'FontSize', 9, ...
              'HorizontalAlignment', 'left', ...
              'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.preview_panel = panel;
end

function handles = createCoefficientsPanel(parent, handles)
    % Polynomial Coefficients Table Panel
    param_info = getPolynomialParameterInfo();
    
         panel = uipanel('Parent', parent, ...
                    'Title', sprintf('Polynomial Coefficients (%d Joints, %d Parameters)', ...
                            length(param_info.joint_names), param_info.total_params), ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 240, 720, 190], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Control buttons
    handles.reset_coeffs_button = uicontrol('Parent', panel, ...
                                           'Style', 'pushbutton', ...
                                           'String', 'Reset', ...
                                           'Position', [20, 160, 70, 25], ...
                                           'FontSize', 9, ...
                                           'Callback', @(src,evt) resetCoefficientsToGenerated(src, evt, handles));
    
    handles.apply_row_button = uicontrol('Parent', panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Apply Row', ...
                                        'Position', [100, 160, 80, 25], ...
                                        'FontSize', 9, ...
                                        'Callback', @(src,evt) applyRowToAll(src, evt, handles));
    
    handles.export_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Export CSV', ...
                                     'Position', [190, 160, 80, 25], ...
                                     'FontSize', 9, ...
                                     'Callback', @(src,evt) exportCoefficientsToCSV(src, evt, handles));
    
    handles.import_button = uicontrol('Parent', panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Import CSV', ...
                                     'Position', [280, 160, 80, 25], ...
                                     'FontSize', 9, ...
                                     'Callback', @(src,evt) importCoefficientsFromCSV(src, evt, handles));
    
    % Create table with proper column structure
    col_names = {'Trial'};
    col_widths = {50};
    col_editable = false;
    
         % Add columns for all joints and their coefficients
     for i = 1:length(param_info.joint_names)
         joint_name = param_info.joint_names{i};
         coeffs = param_info.joint_coeffs{i};
         
         % Shorten joint names for display (use consistent helper function)
         short_name = getShortenedJointName(joint_name);
         
         for j = 1:length(coeffs)
             coeff = coeffs(j);
             col_names{end+1} = sprintf('%s_%s', short_name, coeff);
             col_widths{end+1} = 55;
             col_editable(end+1) = true;
         end
     end
    
    % Coefficients table
    handles.coefficients_table = uitable('Parent', panel, ...
                                         'Position', [20, 20, 580, 135], ...
                                         'ColumnName', col_names, ...
                                         'ColumnWidth', col_widths, ...
                                         'FontSize', 8, ...
                                         'RowStriping', 'on', ...
                                         'ColumnEditable', col_editable, ...
                                         'CellEditCallback', @(src,evt) coefficientCellEditCallback(src, evt, handles));
    
    % Initialize edit tracking
    handles.edited_cells = {};
    handles.param_info = param_info;
    
    handles.coefficients_panel = panel;
end

function handles = createProgressPanel(parent, handles)
         % Progress and Activity Log Panel
     panel = uipanel('Parent', parent, ...
                    'Title', 'Generation Progress', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 130, 720, 100], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Progress bar
    handles.progress_text = uicontrol('Parent', panel, ...
                                     'Style', 'text', ...
                                     'String', 'Ready to start generation...', ...
                                     'Position', [20, 50, 580, 20], ...
                                     'FontSize', 11, ...
                                     'FontWeight', 'bold', ...
                                     'HorizontalAlignment', 'left', ...
                                     'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Status
    handles.status_text = uicontrol('Parent', panel, ...
                                   'Style', 'text', ...
                                   'String', 'Status: Ready', ...
                                   'Position', [20, 25, 580, 20], ...
                                   'FontSize', 10, ...
                                   'HorizontalAlignment', 'left', ...
                                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.progress_panel = panel;
end

function handles = createControlPanel(parent, handles)
         % Control Buttons Panel
     panel = uipanel('Parent', parent, ...
                    'Title', 'Generation Controls', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold', ...
                    'Position', [10, 10, 720, 110], ...
                    'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Main control buttons
    handles.start_button = uicontrol('Parent', panel, ...
                                    'Style', 'pushbutton', ...
                                    'String', 'Start Generation', ...
                                    'Position', [20, 35, 140, 35], ...
                                    'FontSize', 12, ...
                                    'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.2, 0.6, 0.2], ...
                                    'ForegroundColor', 'white', ...
                                    'Callback', @(src,evt) startGeneration(src, evt, handles));
    
    handles.stop_button = uicontrol('Parent', panel, ...
                                   'Style', 'pushbutton', ...
                                   'String', 'Stop', ...
                                   'Position', [170, 35, 80, 35], ...
                                   'FontSize', 12, ...
                                   'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.8, 0.2, 0.2], ...
                                   'ForegroundColor', 'white', ...
                                   'Enable', 'off', ...
                                   'Callback', @(src,evt) stopGeneration(src, evt, handles));
    
    % Utility buttons
    handles.validate_button = uicontrol('Parent', panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Validate', ...
                                       'Position', [270, 35, 80, 35], ...
                                       'FontSize', 10, ...
                                       'Callback', @(src,evt) validateSettings(src, evt, handles));
    
    handles.save_config_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Save Config', ...
                                          'Position', [360, 35, 90, 35], ...
                                          'FontSize', 10, ...
                                          'Callback', @(src,evt) saveConfiguration(src, evt, handles));
    
    handles.load_config_button = uicontrol('Parent', panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Load Config', ...
                                          'Position', [460, 35, 90, 35], ...
                                          'FontSize', 10, ...
                                          'Callback', @(src,evt) loadConfiguration(src, evt, handles));
    
    handles.control_panel = panel;
end

% Scroll functions
function scrollLeftColumn(src, evt, handles)
    % Handle left column scrolling
    scroll_val = get(src, 'Value');
    % Implement scrolling logic here if needed
end

function scrollRightColumn(src, evt, handles)
    % Handle right column scrolling
    scroll_val = get(src, 'Value');
    % Implement scrolling logic here if needed
end

% Enhanced callback functions
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
        num_trials = min(num_trials, 10); % Limit preview
        
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

function applyRowToAll(src, evt, handles)
    try
        handles = guidata(handles.fig);
        
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
        config.model_name = get(handles.model_edit, 'String');
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
     result = struct();
     result.success = true;
     result.filename = sprintf('trial_%03d.csv', trial_num);
     result.error = '';
     
     % Simulate processing time
     pause(0.1);
 end 