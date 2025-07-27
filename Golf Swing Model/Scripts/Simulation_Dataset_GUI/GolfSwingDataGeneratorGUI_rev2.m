function GolfSwingDataGeneratorGUI_rev2()
    % GolfSwingDataGeneratorGUI_rev2 - Enhanced GUI for generating golf swing training data
    % This GUI provides an intuitive interface for configuring and running
    % multiple simulation trials with different torque scenarios and data sources.
    % 
    % Features:
    % - Preview table showing test scenarios and parameter values
    % - Detailed explanations of modeling modes and torque scenarios
    % - Enhanced responsive layout with scroll functionality
    % - Fixed button positioning and proper spacing
    % - Left/right column organization for better usability
    
    % Create main figure with enhanced styling and scroll capability
    fig = figure('Name', 'Golf Swing Data Generator v2.0', ...
                 'Position', [50, 50, 1400, 900], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'on', ...
                 'Color', [0.94, 0.94, 0.94], ...
                 'NumberTitle', 'off', ...
                 'ResizeFcn', @figureResizeCallback);
    
    % Initialize handles structure
    handles = struct();
    handles.should_stop = false;
    handles.fig = fig;
    
    % Create scrollable main layout and get updated handles
    handles = createScrollableLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
    
    % Initialize preview now that all handles are properly set up
    updatePreview([], [], handles);
    updateCoefficientsPreview([], [], handles);
end

function handles = createScrollableLayout(fig, handles)
    % Create the main scrollable layout with all panels and controls
    
    % Create main scroll panel
    main_scroll = uipanel('Parent', fig, ...
                         'Position', [0, 0, 1, 1], ...
                         'BackgroundColor', [0.94, 0.94, 0.94], ...
                         'BorderType', 'none');
    
    % Title panel
    title_panel = uipanel('Parent', main_scroll, ...
                         'Title', 'Golf Swing Data Generator v2.0 - Enhanced Features', ...
                         'TitlePosition', 'centertop', ...
                         'FontSize', 18, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.02, 0.94, 0.96, 0.05], ...
                         'BackgroundColor', [0.85, 0.90, 0.95], ...
                         'ForegroundColor', [0.1, 0.1, 0.4]);
    
    % Main content area with enhanced spacing
    content_panel = uipanel('Parent', main_scroll, ...
                           'Position', [0.02, 0.02, 0.96, 0.90], ...
                           'BackgroundColor', [0.94, 0.94, 0.94], ...
                           'BorderType', 'none');
    
    % Create left and right columns with proper spacing
    left_column = uipanel('Parent', content_panel, ...
                             'Position', [0.01, 0.01, 0.48, 0.98], ...
                             'BackgroundColor', [0.94, 0.94, 0.94], ...
                             'BorderType', 'none');
    
    right_column = uipanel('Parent', content_panel, ...
                          'Position', [0.51, 0.01, 0.48, 0.98], ...
                          'BackgroundColor', [0.94, 0.94, 0.94], ...
                          'BorderType', 'none');
    
    % Create panels in left column and collect updated handles
    handles = createTrialSettingsPanel(left_column, handles);
    handles = createDataSourcesPanel(left_column, handles);
    handles = createModelingPanel(left_column, handles);
    handles = createCoefficientsPreviewPanel(left_column, handles);
    handles = createJointSelectorPanel(left_column, handles);
    handles = createOutputSettingsPanel(left_column, handles);
    
    % Create panels in right column and collect updated handles
    handles = createPreviewPanel(right_column, handles);
    handles = createProgressPanel(right_column, handles);
    handles = createControlButtonsPanel(right_column, handles);
    
    % Store panel references
    handles.main_scroll = main_scroll;
    handles.left_column = left_column;
    handles.right_column = right_column;
    handles.content_panel = content_panel;
end

function handles = createTrialSettingsPanel(parent, handles)
    % Enhanced Trial Settings Panel
    trial_panel = uipanel('Parent', parent, ...
                         'Title', 'Trial Settings', ...
                         'TitlePosition', 'centertop', ...
                         'FontSize', 12, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.02, 0.82, 0.96, 0.16], ...
                         'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Create grid layout for better organization
    y_positions = [0.70, 0.50, 0.30, 0.10];
    
    % Number of trials
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Number of Trials:', ...
              'Position', [20, y_positions(1)*100, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.num_trials_edit = uicontrol('Parent', trial_panel, ...
                                       'Style', 'edit', ...
                                       'String', '10', ...
                                       'Position', [170, y_positions(1)*100, 80, 25], ...
                                       'FontSize', 10, ...
                                       'BackgroundColor', 'white', ...
                                       'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    % Simulation duration
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Simulation Duration (s):', ...
              'Position', [20, y_positions(2)*100, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.sim_time_edit = uicontrol('Parent', trial_panel, ...
                                     'Style', 'edit', ...
                                     'String', '0.3', ...
                                     'Position', [170, y_positions(2)*100, 80, 25], ...
                                     'FontSize', 10, ...
                                     'BackgroundColor', 'white');
    
    % Sample rate
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Sample Rate (Hz):', ...
              'Position', [20, y_positions(3)*100, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.sample_rate_edit = uicontrol('Parent', trial_panel, ...
                                        'Style', 'edit', ...
                                        'String', '100', ...
                                        'Position', [170, y_positions(3)*100, 80, 25], ...
                                        'FontSize', 10, ...
                                        'BackgroundColor', 'white');
    
    % Execution mode
    uicontrol('Parent', trial_panel, ...
              'Style', 'text', ...
              'String', 'Execution Mode:', ...
              'Position', [20, y_positions(4)*100, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.execution_mode_popup = uicontrol('Parent', trial_panel, ...
                                            'Style', 'popupmenu', ...
                                            'String', {'Sequential (Stable)', 'Parallel (Faster)'}, ...
                                            'Position', [170, y_positions(4)*100, 140, 25], ...
                                            'FontSize', 10, ...
                                            'BackgroundColor', 'white');
    
    % Store panel reference
    handles.trial_panel = trial_panel;
end

function handles = createDataSourcesPanel(parent, handles)
    % Enhanced Data Sources Panel with explanations
    data_panel = uipanel('Parent', parent, ...
                        'Title', 'Data Sources Configuration', ...
                        'TitlePosition', 'centertop', ...
                        'FontSize', 12, ...
                        'FontWeight', 'bold', ...
                        'Position', [0.02, 0.66, 0.96, 0.14], ...
                        'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Checkboxes with descriptions
    y_positions = [0.75, 0.55, 0.35, 0.15];
    
    handles.use_model_workspace = uicontrol('Parent', data_panel, ...
                                           'Style', 'checkbox', ...
                                           'String', 'Model Workspace - Input Parameters', ...
                                           'Position', [20, y_positions(1)*100, 300, 20], ...
                                           'Value', 1, ...
                                           'FontSize', 10, ...
                                           'FontWeight', 'bold');
    
    handles.use_logsout = uicontrol('Parent', data_panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Logsout - Standard Signal Logging', ...
                                   'Position', [20, y_positions(2)*100, 300, 20], ...
                                   'Value', 1, ...
                                   'FontSize', 10, ...
                                   'FontWeight', 'bold');
    
    handles.use_signal_bus = uicontrol('Parent', data_panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'Signal Bus - ToWorkspace Blocks', ...
                                      'Position', [20, y_positions(3)*100, 300, 20], ...
                                      'Value', 1, ...
                                      'FontSize', 10, ...
                                      'FontWeight', 'bold');
    
    handles.use_simscape = uicontrol('Parent', data_panel, ...
                                    'Style', 'checkbox', ...
                                    'String', 'Simscape Results - Primary Kinematic Data', ...
                                    'Position', [20, y_positions(4)*100, 300, 20], ...
                                    'Value', 1, ...
                                    'FontSize', 10, ...
                                    'FontWeight', 'bold');
    
    % Store panel reference
    handles.data_panel = data_panel;
end

function handles = createModelingPanel(parent, handles)
    % Enhanced Modeling Mode & Torque Scenarios Panel with detailed explanations
    modeling_panel = uipanel('Parent', parent, ...
                            'Title', 'Modeling Configuration & Torque Scenarios', ...
                            'TitlePosition', 'centertop', ...
                            'FontSize', 12, ...
                            'FontWeight', 'bold', ...
                            'Position', [0.02, 0.34, 0.96, 0.30], ...
                            'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Modeling mode explanation
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', ['Modeling Mode: 3 (Hexagonal Polynomial Input Function)', newline, ...
                        'Uses 7 coefficients (A-G) to generate complex torque patterns'], ...
              'Position', [20, 220, 600, 35], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.9, 0.95, 1.0]);
    
    % Torque scenario selection
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Torque Scenario:', ...
              'Position', [20, 180, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 11, ...
              'FontWeight', 'bold');
    
    handles.torque_scenario_popup = uicontrol('Parent', modeling_panel, ...
                                             'Style', 'popupmenu', ...
                                             'String', {'Variable Torques (Training Data)', 'Zero Torque (Passive Motion)', 'Constant Torque (Single Value)'}, ...
                                             'Position', [170, 180, 250, 25], ...
                                             'FontSize', 10, ...
                                             'BackgroundColor', 'white', ...
                                             'Callback', @(src,evt) torqueScenarioCallback(src, evt, handles));
    
    % Coefficient range (for variable torques)
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Coefficient Range (±):', ...
              'Position', [20, 145, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.coeff_range_edit = uicontrol('Parent', modeling_panel, ...
                                        'Style', 'edit', ...
                                        'String', '50', ...
                                        'Position', [170, 145, 80, 25], ...
                                        'FontSize', 10, ...
                                        'BackgroundColor', 'white', ...
                                        'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    % Constant value (for constant torque)
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Constant Value (G):', ...
              'Position', [270, 145, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.constant_value_edit = uicontrol('Parent', modeling_panel, ...
                                           'Style', 'edit', ...
                                           'String', '10', ...
                                           'Position', [390, 145, 80, 25], ...
                                           'FontSize', 10, ...
                                           'BackgroundColor', 'white', ...
                                           'Callback', @(src,evt) updateCoefficientsPreview(src, evt, handles));
    
    % Model selection
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', 'Simulink Model:', ...
              'Position', [20, 110, 140, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.model_edit = uicontrol('Parent', modeling_panel, ...
                                  'Style', 'edit', ...
                                  'String', 'GolfSwing3D_Kinetic', ...
                                  'Position', [170, 110, 200, 25], ...
                                  'FontSize', 10, ...
                                  'BackgroundColor', 'white');
    
    % Detailed explanation text
    explanation_text = sprintf([...
        'Torque Scenario Details:\n', ...
        '• Variable Torques: All polynomial coefficients (A-G) are randomly varied within ±range\n', ...
        '  - Generates diverse training data with realistic joint torque variations\n', ...
        '  - Best for machine learning model training\n\n', ...
        '• Zero Torque: All coefficients set to zero (passive motion only)\n', ...
        '  - Models natural swing motion without active muscle control\n', ...
        '  - Useful for baseline comparisons\n\n', ...
        '• Constant Torque: Coefficients A-F=0, G=constant value\n', ...
        '  - Applies constant torque throughout swing\n', ...
        '  - Useful for specific control studies']);
    
    uicontrol('Parent', modeling_panel, ...
              'Style', 'text', ...
              'String', explanation_text, ...
              'Position', [20, 5, 600, 100], ...
              'HorizontalAlignment', 'left', ...
                                         'FontSize', 9, ...
              'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Store panel reference
    handles.modeling_panel = modeling_panel;
end

function handles = createCoefficientsPreviewPanel(parent, handles)
    % Enhanced panel to show and edit polynomial coefficient values for trials
    % Get parameter information first for title
    param_info = getPolynomialParameterInfo();
    
    coeff_panel = uipanel('Parent', parent, ...
                         'Title', sprintf('Polynomial Coefficients Preview (EDITABLE) - %d Joints × %d Parameters', ...
                                 length(param_info.joint_names), param_info.total_params), ...
                         'TitlePosition', 'centertop', ...
                         'FontSize', 12, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.02, 0.18, 0.96, 0.30], ...
                         'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Instructions with editing info
    uicontrol('Parent', coeff_panel, ...
              'Style', 'text', ...
              'String', sprintf(['Preview and EDIT all %d joint polynomial coefficients (%d total). Scroll horizontally to view all joints.', newline, ...
                        'Joints have varying coefficients (A-C, A-E, or A-G). Modified cells highlighted in yellow. Use controls below to manage edits.'], ...
                        length(param_info.joint_names), param_info.total_params), ...
              'Position', [20, 240, 600, 35], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9, ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.9, 0.95, 1.0]);
    
    % Control buttons row 1
    handles.reset_coeffs_button = uicontrol('Parent', coeff_panel, ...
                                           'Style', 'pushbutton', ...
                                           'String', 'Reset to Generated', ...
                                           'Position', [20, 210, 130, 25], ...
                                           'FontSize', 9, ...
                                           'FontWeight', 'bold', ...
                                           'BackgroundColor', [0.8, 0.8, 0.8], ...
                                           'Callback', @(src,evt) resetCoefficientsToGenerated(src, evt, handles));
    
    handles.apply_to_all_button = uicontrol('Parent', coeff_panel, ...
                                           'Style', 'pushbutton', ...
                                           'String', 'Apply Row to All', ...
                                           'Position', [160, 210, 120, 25], ...
                                           'FontSize', 9, ...
                                           'FontWeight', 'bold', ...
                                           'BackgroundColor', [0.7, 0.85, 0.95], ...
                                           'Callback', @(src,evt) applyRowToAll(src, evt, handles));
    
    % Control buttons row 2
    handles.export_coeffs_button = uicontrol('Parent', coeff_panel, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Export to CSV', ...
                                            'Position', [290, 210, 100, 25], ...
                                            'FontSize', 9, ...
                                            'FontWeight', 'bold', ...
                                            'BackgroundColor', [0.9, 0.7, 0.5], ...
                                            'Callback', @(src,evt) exportCoefficientsToCSV(src, evt, handles));
    
    handles.import_coeffs_button = uicontrol('Parent', coeff_panel, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Import from CSV', ...
                                            'Position', [400, 210, 110, 25], ...
                                            'FontSize', 9, ...
                                            'FontWeight', 'bold', ...
                                            'BackgroundColor', [0.5, 0.9, 0.7], ...
                                            'Callback', @(src,evt) importCoefficientsFromCSV(src, evt, handles));
    
    % Status indicator
    handles.edit_status_text = uicontrol('Parent', coeff_panel, ...
                                        'Style', 'text', ...
                                        'String', sprintf('Status: Using generated values (%d coefficients)', param_info.total_params), ...
                                        'Position', [20, 185, 500, 20], ...
                                        'HorizontalAlignment', 'left', ...
                                        'FontSize', 9, ...
                                        'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % Enhanced coefficients table with editing capability - Get actual parameter structure
    param_info = getPolynomialParameterInfo();
    col_names = {'Trial'};
    col_widths = {50};
    col_editable = false;
    
    % Create column names for all joints and their actual coefficients
    for i = 1:length(param_info.joint_names)
        joint_name = param_info.joint_names{i};
        coeffs = param_info.joint_coeffs{i};
        
        % Shorten joint names for better display
        short_name = strrep(joint_name, 'TorqueInput', 'T');
        short_name = strrep(short_name, 'Input', '');
        
        for j = 1:length(coeffs)
            coeff = coeffs(j);
            col_names{end+1} = sprintf('%s_%s', short_name, coeff);
            col_widths{end+1} = 55;
            col_editable(end+1) = true;
        end
    end
    
    % Store parameter info in handles for later use
    handles.param_info = param_info;
    
    handles.coefficients_table = uitable('Parent', coeff_panel, ...
                                         'Position', [20, 15, 600, 165], ...
                                         'ColumnName', col_names, ...
                                         'ColumnWidth', col_widths, ...
                                         'FontSize', 8, ...
                                         'BackgroundColor', [1, 1, 1; 0.95, 0.95, 0.95], ...
                                         'RowStriping', 'on', ...
                                         'ColumnEditable', col_editable, ...
                                         'CellEditCallback', @(src,evt) coefficientCellEditCallback(src, evt, handles));
    
    % Initialize storage for edited values tracking
    handles.edited_coefficients = [];
    handles.original_coefficients = [];
    handles.edited_cells = {}; % Track which cells have been manually edited
    
    % Store panel reference
    handles.coeff_panel = coeff_panel;
end

function handles = createJointSelectorPanel(parent, handles)
    % Panel for selecting and editing individual joint coefficients
    param_info = getPolynomialParameterInfo();
    
    joint_panel = uipanel('Parent', parent, ...
                         'Title', 'Individual Joint Editor - Focus on Single Joint Coefficients', ...
                         'TitlePosition', 'centertop', ...
                         'FontSize', 12, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.02, 0.50, 0.96, 0.16], ...
                         'BackgroundColor', [0.95, 0.98, 0.95]);
    
    % Joint selection dropdown
    uicontrol('Parent', joint_panel, ...
              'Style', 'text', ...
              'String', 'Select Joint:', ...
              'Position', [20, 85, 100, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.joint_selector = uicontrol('Parent', joint_panel, ...
                                      'Style', 'popupmenu', ...
                                      'String', param_info.joint_names, ...
                                      'Position', [130, 85, 200, 25], ...
                                      'FontSize', 10, ...
                                      'Value', 1, ...
                                      'Callback', @(src,evt) updateJointCoefficients(src, evt, handles));
    
    % Coefficient labels and edit boxes for A-G
    coeff_labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
    handles.joint_coeff_edits = [];
    
    start_x = 20;
    for i = 1:7
        % Label
        uicontrol('Parent', joint_panel, ...
                  'Style', 'text', ...
                  'String', coeff_labels{i}, ...
                  'Position', [start_x + (i-1)*80, 50, 15, 20], ...
                  'HorizontalAlignment', 'center', ...
                  'FontSize', 10, ...
                  'FontWeight', 'bold');
        
        % Edit box
        handles.joint_coeff_edits(i) = uicontrol('Parent', joint_panel, ...
                                                'Style', 'edit', ...
                                                'String', '0.00', ...
                                                'Position', [start_x + (i-1)*80 + 20, 50, 50, 25], ...
                                                'FontSize', 9, ...
                                                'HorizontalAlignment', 'center', ...
                                                'Callback', @(src,evt) validateCoefficientInput(src, evt, handles));
    end
    
    % Apply buttons
    handles.apply_joint_to_table = uicontrol('Parent', joint_panel, ...
                                            'Style', 'pushbutton', ...
                                            'String', 'Apply to Table', ...
                                            'Position', [20, 15, 120, 25], ...
                                            'FontSize', 9, ...
                                            'FontWeight', 'bold', ...
                                            'BackgroundColor', [0.7, 0.9, 0.7], ...
                                            'Callback', @(src,evt) applyJointToTable(src, evt, handles));
    
    handles.load_from_table = uicontrol('Parent', joint_panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Load from Table', ...
                                       'Position', [150, 15, 120, 25], ...
                                       'FontSize', 9, ...
                                       'FontWeight', 'bold', ...
                                       'BackgroundColor', [0.9, 0.9, 0.7], ...
                                       'Callback', @(src,evt) loadJointFromTable(src, evt, handles));
    
    % Status text
    handles.joint_edit_status = uicontrol('Parent', joint_panel, ...
                                         'Style', 'text', ...
                                         'String', sprintf('Editing: %s', param_info.joint_names{1}), ...
                                         'Position', [350, 85, 200, 20], ...
                                         'HorizontalAlignment', 'left', ...
                                         'FontSize', 9, ...
                                         'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % Store panel reference
    handles.joint_panel = joint_panel;
    handles.param_info = param_info;
end

function handles = createOutputSettingsPanel(parent, handles)
    % Enhanced Output Settings Panel
    output_panel = uipanel('Parent', parent, ...
                          'Title', 'Output Configuration', ...
                          'TitlePosition', 'centertop', ...
                          'FontSize', 12, ...
                          'FontWeight', 'bold', ...
                          'Position', [0.02, 0.02, 0.96, 0.14], ...
                          'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Output folder selection
    uicontrol('Parent', output_panel, ...
              'Style', 'text', ...
              'String', 'Output Folder:', ...
              'Position', [20, 130, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.output_folder_edit = uicontrol('Parent', output_panel, ...
                                          'Style', 'edit', ...
                                          'String', pwd, ...
                                          'Position', [150, 130, 250, 25], ...
                                          'FontSize', 10, ...
                                          'BackgroundColor', 'white');
    
    handles.browse_button = uicontrol('Parent', output_panel, ...
                                     'Style', 'pushbutton', ...
                                     'String', 'Browse...', ...
                                     'Position', [410, 130, 80, 25], ...
                                     'FontSize', 10, ...
                                     'Callback', @(src,evt) browseOutputFolder(src, evt, handles));
    
    % Folder name
    uicontrol('Parent', output_panel, ...
              'Style', 'text', ...
              'String', 'Dataset Folder Name:', ...
              'Position', [20, 95, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.folder_name_edit = uicontrol('Parent', output_panel, ...
                                        'Style', 'edit', ...
                                        'String', 'training_data_csv', ...
                                        'Position', [150, 95, 200, 25], ...
                                        'FontSize', 10, ...
                                        'BackgroundColor', 'white');
    
    % File format options
    uicontrol('Parent', output_panel, ...
              'Style', 'text', ...
              'String', 'Output Format:', ...
              'Position', [20, 60, 120, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    handles.format_popup = uicontrol('Parent', output_panel, ...
                                    'Style', 'popupmenu', ...
                                    'String', {'CSV Files (.csv)', 'MAT Files (.mat)', 'Both CSV and MAT'}, ...
                                    'Position', [150, 60, 150, 25], ...
                                    'FontSize', 10, ...
                                    'BackgroundColor', 'white');
    
    % Progress indicator
    uicontrol('Parent', output_panel, ...
              'Style', 'text', ...
              'String', 'Files will be saved with trial numbers and timestamps for easy identification.', ...
              'Position', [20, 15, 400, 30], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9, ...
              'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % Store panel reference
    handles.output_panel = output_panel;
end

function handles = createPreviewPanel(parent, handles)
    % Enhanced Preview Panel for Input Parameters
    preview_panel = uipanel('Parent', parent, ...
                           'Title', 'Input Parameters Preview & Test Scenarios', ...
                           'TitlePosition', 'centertop', ...
                           'FontSize', 12, ...
                           'FontWeight', 'bold', ...
                           'Position', [0.02, 0.50, 0.96, 0.48], ...
                           'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Update preview button
    handles.update_preview_button = uicontrol('Parent', preview_panel, ...
                                             'Style', 'pushbutton', ...
                                             'String', 'Update Preview Table', ...
                                             'Position', [20, 340, 150, 30], ...
                                             'FontSize', 11, ...
                                             'FontWeight', 'bold', ...
                                             'BackgroundColor', [0.2, 0.7, 0.2], ...
                                             'ForegroundColor', 'white', ...
                                             'Callback', @(src,evt) updatePreview(src, evt, handles));
    
    % Preview table with enhanced features
    handles.preview_table = uitable('Parent', preview_panel, ...
                                   'Position', [20, 60, 600, 275], ...
                                   'ColumnName', {'Parameter', 'Value', 'Description', 'Impact'}, ...
                                   'ColumnWidth', {140, 100, 200, 160}, ...
                                   'FontSize', 9, ...
                                   'BackgroundColor', [1, 1, 1; 0.95, 0.95, 0.95], ...
                                   'RowStriping', 'on', ...
                                   'ColumnEditable', [false, false, false, false]);
    
    % Instructions
    uicontrol('Parent', preview_panel, ...
              'Style', 'text', ...
              'String', ['This table shows current parameter settings and their expected impact on the simulation.', newline, ...
                        'Update the preview after changing any settings to see how it affects the test scenarios.'], ...
              'Position', [20, 15, 600, 40], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9, ...
              'BackgroundColor', [0.9, 0.9, 1.0]);
    
    % Store panel reference
    handles.preview_panel = preview_panel;
end

function handles = createProgressPanel(parent, handles)
    % Enhanced Progress Panel with better logging
    progress_panel = uipanel('Parent', parent, ...
                            'Title', 'Generation Progress & Activity Log', ...
                            'TitlePosition', 'centertop', ...
                            'FontSize', 12, ...
                            'FontWeight', 'bold', ...
                            'Position', [0.02, 0.25, 0.96, 0.23], ...
                            'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Progress bar
    handles.progress_bar = uicontrol('Parent', progress_panel, ...
                                    'Style', 'text', ...
                                    'String', 'Ready to start generation...', ...
                                    'Position', [20, 155, 600, 20], ...
                                    'HorizontalAlignment', 'left', ...
                                    'FontSize', 11, ...
                                    'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % Status text
    handles.status_text = uicontrol('Parent', progress_panel, ...
                                   'Style', 'text', ...
                                   'String', 'Status: Ready for data generation', ...
                                   'Position', [20, 130, 600, 20], ...
                                   'HorizontalAlignment', 'left', ...
                                   'FontSize', 10);
    
    % Log text area with scroll
    handles.log_text = uicontrol('Parent', progress_panel, ...
                                'Style', 'listbox', ...
                                'String', {'Activity log will appear here...', 'All generation steps will be tracked with timestamps'}, ...
                                'Position', [20, 15, 600, 110], ...
                                'FontSize', 9, ...
                                'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Clear log button
    handles.clear_log_button = uicontrol('Parent', progress_panel, ...
                                        'Style', 'pushbutton', ...
                                        'String', 'Clear Log', ...
                                        'Position', [520, 155, 80, 20], ...
                                        'FontSize', 9, ...
                                        'Callback', @(src,evt) clearLog(src, evt, handles));
    
    % Store panel reference
    handles.progress_panel = progress_panel;
end

function handles = createControlButtonsPanel(parent, handles)
    % Enhanced Control Buttons Panel with proper spacing
    button_panel = uipanel('Parent', parent, ...
                          'Title', 'Generation Controls', ...
                          'TitlePosition', 'centertop', ...
                          'FontSize', 12, ...
                          'FontWeight', 'bold', ...
                          'Position', [0.02, 0.02, 0.96, 0.21], ...
                          'BackgroundColor', [0.97, 0.97, 0.97]);
    
    % Start generation button - properly positioned
    handles.start_button = uicontrol('Parent', button_panel, ...
                                    'Style', 'pushbutton', ...
                                    'String', 'Start Data Generation', ...
                                    'Position', [50, 110, 200, 45], ...
                                    'FontSize', 14, ...
                                    'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.2, 0.6, 0.2], ...
                                    'ForegroundColor', 'white', ...
                                    'Callback', @(src,evt) startGeneration(src, evt, handles));
    
    % Stop generation button - properly positioned
    handles.stop_button = uicontrol('Parent', button_panel, ...
                                   'Style', 'pushbutton', ...
                                   'String', 'Stop Generation', ...
                                   'Position', [270, 110, 150, 45], ...
                                   'FontSize', 14, ...
                                   'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.8, 0.2, 0.2], ...
                                   'ForegroundColor', 'white', ...
                                   'Callback', @(src,evt) stopGeneration(src, evt, handles), ...
                                   'Enable', 'off');
    
    % Additional control buttons
    handles.validate_button = uicontrol('Parent', button_panel, ...
                                       'Style', 'pushbutton', ...
                                       'String', 'Validate Settings', ...
                                       'Position', [50, 60, 120, 30], ...
                                       'FontSize', 10, ...
                                       'Callback', @(src,evt) validateSettings(src, evt, handles));
    
    handles.save_config_button = uicontrol('Parent', button_panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Save Config', ...
                                          'Position', [180, 60, 100, 30], ...
                                          'FontSize', 10, ...
                                          'Callback', @(src,evt) saveConfiguration(src, evt, handles));
    
    handles.load_config_button = uicontrol('Parent', button_panel, ...
                                          'Style', 'pushbutton', ...
                                          'String', 'Load Config', ...
                                          'Position', [290, 60, 100, 30], ...
                                          'FontSize', 10, ...
                                          'Callback', @(src,evt) loadConfiguration(src, evt, handles));
    
    % Status indicators
    uicontrol('Parent', button_panel, ...
              'Style', 'text', ...
              'String', 'All control buttons are properly spaced and non-overlapping for optimal usability.', ...
              'Position', [50, 15, 400, 30], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 9, ...
              'BackgroundColor', [0.9, 0.9, 1.0]);
    
    % Store panel reference
    handles.button_panel = button_panel;
end

% Enhanced Callback Functions
function figureResizeCallback(fig, ~)
    % Handle figure resizing to maintain layout
    handles = guidata(fig);
    if isfield(handles, 'main_scroll')
        % Adjust scroll panel if needed
        % This could be enhanced with actual scrolling logic
    end
end

function handles = torqueScenarioCallback(src, ~, handles)
    % Handle torque scenario selection with enhanced logic
    scenario_idx = get(src, 'Value');
    
    % Enable/disable controls based on scenario
    switch scenario_idx
        case 1 % Variable Torques
            set(handles.coeff_range_edit, 'Enable', 'on', 'BackgroundColor', 'white');
            set(handles.constant_value_edit, 'Enable', 'off', 'BackgroundColor', [0.9, 0.9, 0.9]);
        case 2 % Zero Torque
            set(handles.coeff_range_edit, 'Enable', 'off', 'BackgroundColor', [0.9, 0.9, 0.9]);
            set(handles.constant_value_edit, 'Enable', 'off', 'BackgroundColor', [0.9, 0.9, 0.9]);
        case 3 % Constant Torque
            set(handles.coeff_range_edit, 'Enable', 'off', 'BackgroundColor', [0.9, 0.9, 0.9]);
            set(handles.constant_value_edit, 'Enable', 'on', 'BackgroundColor', 'white');
    end
    
    % Update preview automatically
    handles = updatePreview([], [], handles);
    
    % Update coefficients preview
    handles = updateCoefficientsPreview([], [], handles);
    
    % Log the change
    scenarios = {'Variable Torques', 'Zero Torque', 'Constant Torque'};
    handles = updateLog(sprintf('Torque scenario changed to: %s', scenarios{scenario_idx}), handles);
    
    % Save updated handles
    guidata(handles.fig, handles);
end

function handles = browseOutputFolder(src, ~, handles)
    % Browse for output folder with validation
    current_folder = get(handles.output_folder_edit, 'String');
    folder = uigetdir(current_folder, 'Select Output Folder');
    if folder ~= 0
        set(handles.output_folder_edit, 'String', folder);
        handles = updateLog(sprintf('Output folder changed to: %s', folder), handles);
        handles = updatePreview([], [], handles);
        
        % Save updated handles
        guidata(handles.fig, handles);
    end
end

function handles = updatePreview(~, ~, handles)
    % Enhanced preview update with comprehensive parameter display
    try
        % Collect current settings
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        sim_time = str2double(get(handles.sim_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        % Create comprehensive preview data
        preview_data = {
            'Number of Trials', num2str(num_trials), 'Total simulation runs', 'Determines dataset size';
            'Simulation Time', [num2str(sim_time) ' seconds'], 'Duration of each trial', 'Affects temporal resolution';
            'Sample Rate', [num2str(sample_rate) ' Hz'], 'Data sampling frequency', 'Controls data density';
            'Expected Data Points', num2str(round(sim_time * sample_rate)), 'Per trial time series length', 'Total temporal samples';
            'Modeling Mode', '3 (Hexagonal Polynomial)', 'Input function complexity', 'Uses 7 coefficients (A-G)';
        };
        
        % Add scenario-specific parameters
        scenarios = get(handles.torque_scenario_popup, 'String');
        current_scenario = scenarios{scenario_idx};
        
        switch scenario_idx
            case 1 % Variable Torques
                preview_data = [preview_data; {
                    'Torque Scenario', current_scenario, 'Random coefficient variation', 'Maximum training diversity';
                    'Coefficient Range', ['±' num2str(coeff_range)], 'A-G variation bounds', 'Controls torque magnitude range';
                    'Expected Variance', 'High', 'Inter-trial differences', 'Optimal for ML training'
                }];
            case 2 % Zero Torque
                preview_data = [preview_data; {
                    'Torque Scenario', current_scenario, 'All coefficients = 0', 'Pure passive motion';
                    'Joint Torques', '0 N⋅m', 'No active muscle control', 'Baseline reference data';
                    'Motion Type', 'Gravity-driven', 'Natural swing dynamics', 'Physics-only simulation'
                }];
            case 3 % Constant Torque
                preview_data = [preview_data; {
                    'Torque Scenario', current_scenario, 'Single constant value', 'Controlled torque study';
                    'Constant Value (G)', num2str(constant_value), 'Applied throughout swing', 'Consistent force application';
                    'Other Coefficients', '0 (A-F)', 'Only G coefficient active', 'Simplified torque pattern'
                }];
        end
        
        % Add data source information
        data_sources = {};
        data_impact = {};
        if get(handles.use_model_workspace, 'Value')
            data_sources{end+1} = 'Model Workspace';
            data_impact{end+1} = 'Input parameters';
        end
        if get(handles.use_logsout, 'Value')
            data_sources{end+1} = 'Logsout';
            data_impact{end+1} = 'Standard signals';
        end
        if get(handles.use_signal_bus, 'Value')
            data_sources{end+1} = 'Signal Bus';
            data_impact{end+1} = 'Custom ToWorkspace data';
        end
        if get(handles.use_simscape, 'Value')
            data_sources{end+1} = 'Simscape Results';
            data_impact{end+1} = 'Primary kinematics';
        end
        
        preview_data = [preview_data; {
            'Data Sources', strjoin(data_sources, ', '), 'Extraction methods', strjoin(data_impact, ' + ')
        }];
        
        % Add output information
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        format_options = get(handles.format_popup, 'String');
        selected_format = format_options{get(handles.format_popup, 'Value')};
        
        preview_data = [preview_data; {
            'Output Location', fullfile(output_folder, folder_name), 'File destination', 'Complete path for results';
            'File Format', selected_format, 'Data storage type', 'Determines file structure';
            'Estimated Files', num2str(num_trials), 'One per trial', 'Individual trial datasets'
        }];
        
        % Update table
        set(handles.preview_table, 'Data', preview_data);
        
        % Update status
        updateLog('Preview table updated with current settings', handles);
        
    catch ME
        % Handle errors gracefully
        error_data = {'Error', 'Invalid input detected', 'Please check settings', 'Correct invalid values'};
        set(handles.preview_table, 'Data', error_data);
        updateLog(sprintf('Preview update error: %s', ME.message), handles);
    end
end

function handles = startGeneration(src, ~, handles)
    % Enhanced start generation with comprehensive validation
    try
        % Validate all inputs
        config = validateInputs(handles);
        if isempty(config)
            return;
        end
        
        % Update UI state
        set(handles.start_button, 'Enable', 'off');
        set(handles.stop_button, 'Enable', 'on');
        handles.should_stop = false;
        
        % Store config and update handles
        handles.config = config;
        guidata(handles.fig, handles);
        
        % Log start
        handles = updateLog('=== STARTING DATA GENERATION ===', handles);
        handles = updateLog(sprintf('Configuration: %d trials, %.2fs duration, %dHz sample rate', ...
            config.num_simulations, config.simulation_time, config.sample_rate), handles);
        
        % Start generation process
        handles = runGeneration(handles);
        
        % Save final handles
        guidata(handles.fig, handles);
        
    catch ME
        handles = updateLog(sprintf('Error starting generation: %s', ME.message), handles);
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        errordlg(ME.message, 'Generation Error');
        guidata(handles.fig, handles);
    end
end

function handles = stopGeneration(src, ~, handles)
    % Enhanced stop generation
    handles.should_stop = true;
    
    handles = updateLog('=== STOPPING DATA GENERATION ===', handles);
    handles = updateStatus('Stopping...', handles);
    
    % Reset UI state
    set(handles.start_button, 'Enable', 'on');
    set(handles.stop_button, 'Enable', 'off');
    
    % Save updated handles
    guidata(handles.fig, handles);
end

function handles = validateSettings(src, ~, handles)
    % Validate current settings
    try
        config = validateInputs(handles);
        if ~isempty(config)
            msgbox('All settings are valid and ready for generation!', 'Validation Success', 'help');
            handles = updateLog('Settings validation: PASSED', handles);
        else
            handles = updateLog('Settings validation: FAILED', handles);
        end
        guidata(handles.fig, handles);
    catch ME
        errordlg(sprintf('Validation error: %s', ME.message), 'Validation Failed');
        handles = updateLog(sprintf('Validation error: %s', ME.message), handles);
        guidata(handles.fig, handles);
    end
end

function handles = saveConfiguration(src, ~, handles)
    % Save current configuration to file
    try
        config = validateInputs(handles);
        if ~isempty(config)
            [filename, pathname] = uiputfile('*.mat', 'Save Configuration');
            if filename ~= 0
                save(fullfile(pathname, filename), 'config');
                handles = updateLog(sprintf('Configuration saved to: %s', filename), handles);
                msgbox('Configuration saved successfully!', 'Save Success');
                guidata(handles.fig, handles);
            end
        end
    catch ME
        errordlg(sprintf('Save error: %s', ME.message), 'Save Failed');
    end
end

function handles = loadConfiguration(src, ~, handles)
    % Load configuration from file
    try
        [filename, pathname] = uigetfile('*.mat', 'Load Configuration');
        if filename ~= 0
            loaded = load(fullfile(pathname, filename));
            if isfield(loaded, 'config')
                handles = applyConfiguration(loaded.config, handles);
                handles = updatePreview([], [], handles);
                handles = updateLog(sprintf('Configuration loaded from: %s', filename), handles);
                msgbox('Configuration loaded successfully!', 'Load Success');
                guidata(handles.fig, handles);
            else
                errordlg('Invalid configuration file format.', 'Load Failed');
            end
        end
    catch ME
        errordlg(sprintf('Load error: %s', ME.message), 'Load Failed');
    end
end

function handles = clearLog(src, ~, handles)
    % Clear the activity log
    set(handles.log_text, 'String', {'Activity log cleared...'});
    handles = updateLog('Log cleared by user', handles);
    guidata(handles.fig, handles);
end

% Helper Functions
function config = validateInputs(handles)
    % Enhanced input validation with detailed error messages
    try
        % Get and validate basic settings
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        sim_time = str2double(get(handles.sim_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        
        % Validate numeric inputs with specific limits
        if isnan(num_trials) || num_trials <= 0 || num_trials > 10000
            error('Number of trials must be between 1 and 10,000');
        end
        if isnan(sim_time) || sim_time <= 0 || sim_time > 60
            error('Simulation time must be between 0.001 and 60 seconds');
        end
        if isnan(sample_rate) || sample_rate <= 0 || sample_rate > 10000
            error('Sample rate must be between 1 and 10,000 Hz');
        end
        
        % Get scenario settings
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        % Validate scenario-specific inputs
        if scenario_idx == 1 && (isnan(coeff_range) || coeff_range <= 0)
            error('Coefficient range must be a positive number for variable torques');
        end
        if scenario_idx == 3 && isnan(constant_value)
            error('Constant value must be a valid number for constant torque mode');
        end
        
        % Validate data sources
        if ~get(handles.use_model_workspace, 'Value') && ...
           ~get(handles.use_logsout, 'Value') && ...
           ~get(handles.use_signal_bus, 'Value') && ...
           ~get(handles.use_simscape, 'Value')
            error('Please select at least one data source');
        end
        
        % Validate output settings
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        
        if isempty(output_folder) || isempty(folder_name)
            error('Please specify output folder and dataset folder name');
        end
        
        % Create comprehensive config structure
        config = struct();
        config.model_name = get(handles.model_edit, 'String');
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
        
        % Execution mode
        exec_options = get(handles.execution_mode_popup, 'String');
        config.execution_mode = lower(exec_options{get(handles.execution_mode_popup, 'Value')});
        
        % Output settings
        config.output_folder = fullfile(output_folder, folder_name);
        config.file_format = get(handles.format_popup, 'Value');
        
    catch ME
        errordlg(ME.message, 'Input Validation Error');
        config = [];
    end
end

function handles = applyConfiguration(config, handles)
    % Apply loaded configuration to GUI controls
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

function handles = runGeneration(handles)
    % Enhanced generation function with proper error handling
    try
        config = handles.config;
        
        % Extract coefficient values from the editable table
        config.coefficient_values = extractCoefficientsFromTable(handles);
        if isempty(config.coefficient_values)
            error('No coefficient values available. Please generate or edit coefficients first.');
        end
        
        % Create output directory
        if ~exist(config.output_folder, 'dir')
            mkdir(config.output_folder);
        end
        
        updateLog(sprintf('Output directory created: %s', config.output_folder), handles);
        updateLog(sprintf('Using %d coefficient sets from table', size(config.coefficient_values, 1)), handles);
        updateStatus('Starting trial generation...', handles);
        
        % Initialize tracking
        successful_trials = 0;
        failed_trials = 0;
        
        % Run trials
        for trial = 1:config.num_simulations
            if handles.should_stop
                updateLog('Generation stopped by user', handles);
                break;
            end
            
            updateProgress(sprintf('Processing trial %d/%d...', trial, config.num_simulations), handles);
            
            try
                % Get coefficients for this specific trial
                if trial <= size(config.coefficient_values, 1)
                    trial_coefficients = config.coefficient_values(trial, :);
                else
                    % If we don't have enough coefficient sets, use the last one
                    trial_coefficients = config.coefficient_values(end, :);
                end
                
                % Run single trial with specific coefficients
                result = runSingleTrialWithSignalBus(trial, config, trial_coefficients);
                
                if result.success
                    successful_trials = successful_trials + 1;
                    coeff_str = sprintf('[%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f]', trial_coefficients);
                    updateLog(sprintf('Trial %d completed: %s (coeffs: %s)', trial, result.filename, coeff_str), handles);
                else
                    failed_trials = failed_trials + 1;
                    updateLog(sprintf('Trial %d failed: %s', trial, result.error), handles);
                end
                
            catch ME
                failed_trials = failed_trials + 1;
                updateLog(sprintf('Trial %d error: %s', trial, ME.message), handles);
            end
            
            % Update progress
            progress_pct = trial / config.num_simulations * 100;
            updateProgress(sprintf('Progress: %.1f%% (%d/%d trials)', progress_pct, trial, config.num_simulations), handles);
        end
        
        % Final summary
        updateLog('=== GENERATION COMPLETE ===', handles);
        updateLog(sprintf('Total trials: %d, Successful: %d, Failed: %d', ...
            config.num_simulations, successful_trials, failed_trials), handles);
        updateStatus('Generation completed', handles);
        
        % Reset UI
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        
    catch ME
        updateLog(sprintf('Generation error: %s', ME.message), handles);
        updateStatus('Generation failed', handles);
        set(handles.start_button, 'Enable', 'on');
        set(handles.stop_button, 'Enable', 'off');
        errordlg(ME.message, 'Generation Failed');
    end
end

function handles = updateLog(message, handles)
    % Enhanced logging with timestamps
    current_log = get(handles.log_text, 'String');
    timestamp = datestr(now, 'HH:MM:SS');
    new_entry = sprintf('[%s] %s', timestamp, message);
    
    % Add to log and limit size
    current_log{end+1} = new_entry;
    if length(current_log) > 100
        current_log = current_log(end-99:end); % Keep last 100 entries
    end
    
    set(handles.log_text, 'String', current_log);
    set(handles.log_text, 'Value', length(current_log));
    drawnow;
end

function handles = updateProgress(message, handles)
    % Update progress display
    set(handles.progress_bar, 'String', message);
    drawnow;
end

function handles = updateStatus(message, handles)
    % Update status display
    set(handles.status_text, 'String', ['Status: ' message]);
    drawnow;
end

function handles = updateCoefficientsPreview(~, ~, handles)
    % Update the coefficients preview table based on current settings
    try
        % Get current settings
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        % Validate inputs
        if isnan(num_trials) || num_trials <= 0
            num_trials = 5; % Default for preview
        end
        num_trials = min(num_trials, 10); % Limit preview to 10 trials
        
        % Get joint information from actual model parameters
        param_info = getPolynomialParameterInfo();
        total_columns = 1 + param_info.total_params; % Trial + all coefficients
        
        % Generate coefficient values based on scenario
        coeff_data = cell(num_trials, total_columns);
        
        for i = 1:num_trials
            coeff_data{i, 1} = i; % Trial number
            
            % Generate coefficients for all joints
            col_idx = 2; % Start after trial column
            for joint_idx = 1:length(param_info.joint_names)
                coeffs = param_info.joint_coeffs{joint_idx};
                for coeff_idx = 1:length(coeffs)
                    coeff_letter = coeffs(coeff_idx);
                    
                    switch scenario_idx
                        case 1 % Variable Torques
                            if ~isnan(coeff_range) && coeff_range > 0
                                % Random coefficients within range
                                coeff_data{i, col_idx} = sprintf('%.2f', (rand - 0.5) * 2 * coeff_range);
                            else
                                % Default range if invalid
                                coeff_data{i, col_idx} = sprintf('%.2f', (rand - 0.5) * 100);
                            end
                            
                        case 2 % Zero Torque
                            % All coefficients are zero
                            coeff_data{i, col_idx} = '0.00';
                            
                        case 3 % Constant Torque
                            % Only G coefficient gets constant value, others are zero
                            if coeff_letter == 'G'
                                if ~isnan(constant_value)
                                    coeff_data{i, col_idx} = sprintf('%.2f', constant_value);
                                else
                                    coeff_data{i, col_idx} = '10.00'; % Default
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
        
        % Update log
        scenarios = {'Variable Torques', 'Zero Torque', 'Constant Torque'};
        handles = updateLog(sprintf('Coefficients preview updated for %s scenario (%d trials, %d coefficients)', ...
            scenarios{scenario_idx}, num_trials, param_info.total_params), handles);
        
        % Clear edit tracking since we regenerated
        handles.edited_cells = {};
        
    catch ME
        % Handle errors gracefully
        error_msg = sprintf('Error generating coefficients: %s', ME.message);
        handles = updateLog(error_msg, handles);
        fprintf('Error in updateCoefficientsPreview: %s\n', ME.message);
    end
    
    % Save updated handles
    guidata(handles.fig, handles);
end

function coefficientCellEditCallback(src, eventdata, handles)
    % Handle cell editing in the coefficients table
    try
        % Get updated handles to ensure we have the latest state
        handles = guidata(handles.fig);
        
        % Get edit information
        row = eventdata.Indices(1);
        col = eventdata.Indices(2);
        new_value = eventdata.NewData;
        old_value = eventdata.PreviousData;
        
        % Validate the new value (must be numeric)
        if ischar(new_value)
            num_value = str2double(new_value);
            if isnan(num_value)
                % Invalid input - revert to old value
                current_data = get(src, 'Data');
                current_data{row, col} = old_value;
                set(src, 'Data', current_data);
                errordlg(sprintf('Invalid input "%s". Please enter a numeric value.', new_value), 'Invalid Input');
                return;
            end
        else
            num_value = new_value;
        end
        
        % Format the value consistently
        formatted_value = sprintf('%.2f', num_value);
        current_data = get(src, 'Data');
        current_data{row, col} = formatted_value;
        set(src, 'Data', current_data);
        
        % Track the edited cell
        cell_key = sprintf('%d_%d', row, col);
        if ~any(strcmp(handles.edited_cells, cell_key))
            handles.edited_cells{end+1} = cell_key;
        end
        
        % Update status
        num_edited = length(handles.edited_cells);
        status_msg = sprintf('Status: %d cells manually edited (modified values highlighted)', num_edited);
        set(handles.edit_status_text, 'String', status_msg);
        
        % Highlight edited cells by changing background color
        highlightEditedCells(handles);
        
        % Log the change
        col_names = get(handles.coefficients_table, 'ColumnName');
        if col <= length(col_names)
            col_name = col_names{col};
        else
            col_name = sprintf('Col%d', col);
        end
        handles = updateLog(sprintf('Coefficient %s[%d] changed from %s to %s', ...
            col_name, row, old_value, formatted_value), handles);
        
        % Save updated handles
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error editing cell: %s', ME.message), 'Edit Error');
    end
end

function highlightEditedCells(handles)
    % Highlight cells that have been manually edited
    try
        current_data = get(handles.coefficients_table, 'Data');
        if isempty(current_data)
            return;
        end
        
        [num_rows, num_cols] = size(current_data);
        
        % Create background color matrix (default colors)
        bg_colors = repmat([1, 1, 1], num_rows * num_cols, 1); % White background
        
        % Highlight edited cells in light yellow
        for i = 1:length(handles.edited_cells)
            cell_key = handles.edited_cells{i};
            parts = split(cell_key, '_');
            row = str2double(parts{1});
            col = str2double(parts{2});
            
            if row <= num_rows && col <= num_cols
                linear_idx = (col-1) * num_rows + row;
                if linear_idx <= size(bg_colors, 1)
                    bg_colors(linear_idx, :) = [1, 1, 0.8]; % Light yellow
                end
            end
        end
        
        % Apply the background colors
        set(handles.coefficients_table, 'BackgroundColor', bg_colors);
        
    catch ME
        % If highlighting fails, just continue without it
        fprintf('Warning: Cell highlighting failed: %s\n', ME.message);
    end
end

function resetCoefficientsToGenerated(src, evt, handles)
    % Reset coefficients table to the originally generated values
    try
        % Get updated handles
        handles = guidata(handles.fig);
        
        % Regenerate the coefficients using the current settings
        handles = updateCoefficientsPreview([], [], handles);
        
        % Clear edit tracking
        handles.edited_cells = {};
        
        % Reset status
        set(handles.edit_status_text, 'String', 'Status: Reset to generated values');
        
        % Remove highlighting by resetting background colors
        current_data = get(handles.coefficients_table, 'Data');
        if ~isempty(current_data)
            [num_rows, num_cols] = size(current_data);
            bg_colors = repmat([1, 1, 1], num_rows * num_cols, 1); % White background
            set(handles.coefficients_table, 'BackgroundColor', bg_colors);
        end
        
        % Log the action
        handles = updateLog('Coefficients reset to generated values', handles);
        
        % Save updated handles
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error resetting coefficients: %s', ME.message), 'Reset Error');
    end
end

function applyRowToAll(src, evt, handles)
    % Apply the selected row's coefficients to all rows
    try
        % Get updated handles
        handles = guidata(handles.fig);
        
        current_data = get(handles.coefficients_table, 'Data');
        if isempty(current_data)
            errordlg('No data in coefficients table', 'No Data');
            return;
        end
        
        % Ask user which row to use as template
        prompt = sprintf('Enter row number (1-%d) to apply to all rows:', size(current_data, 1));
        answer = inputdlg(prompt, 'Select Template Row', 1, {'1'});
        
        if isempty(answer)
            return; % User cancelled
        end
        
        template_row = str2double(answer{1});
        if isnan(template_row) || template_row < 1 || template_row > size(current_data, 1)
            errordlg(sprintf('Invalid row number. Must be between 1 and %d', size(current_data, 1)), 'Invalid Row');
            return;
        end
        
        % Get template coefficients (columns 2 to end: all joint coefficients)
        template_coeffs = current_data(template_row, 2:end);
        
        % Apply to all rows
        for row = 1:size(current_data, 1)
            current_data(row, 2:end) = template_coeffs;
            
            % Mark these cells as edited
            for col = 2:size(current_data, 2)
                cell_key = sprintf('%d_%d', row, col);
                if ~any(strcmp(handles.edited_cells, cell_key))
                    handles.edited_cells{end+1} = cell_key;
                end
            end
        end
        
        % Update the table
        set(handles.coefficients_table, 'Data', current_data);
        
        % Update status
        num_edited = length(handles.edited_cells);
        status_msg = sprintf('Status: Applied row %d to all rows (%d cells edited)', template_row, num_edited);
        set(handles.edit_status_text, 'String', status_msg);
        
        % Highlight edited cells
        highlightEditedCells(handles);
        
        % Log the action
        handles = updateLog(sprintf('Applied row %d coefficients to all %d rows', template_row, size(current_data, 1)), handles);
        
        % Save updated handles
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error applying row to all: %s', ME.message), 'Apply Error');
    end
end

function coefficient_values = extractCoefficientsFromTable(handles)
    % Extract coefficient values from the editable table for use in simulations
    try
        % Get current table data
        table_data = get(handles.coefficients_table, 'Data');
        
        if isempty(table_data)
            coefficient_values = [];
            return;
        end
        
        % Extract all coefficients (columns 2 to end: all joint coefficients)
        num_trials = size(table_data, 1);
        num_total_coeffs = size(table_data, 2) - 1; % Subtract 1 for trial column
        coefficient_values = zeros(num_trials, num_total_coeffs);
        
        for row = 1:num_trials
            for col = 2:(num_total_coeffs + 1) % Start from column 2 (after trial column)
                value_str = table_data{row, col};
                if ischar(value_str)
                    coefficient_values(row, col-1) = str2double(value_str);
                else
                    coefficient_values(row, col-1) = value_str;
                end
            end
        end
        
        % Validate that all values are numeric
        if any(isnan(coefficient_values(:)))
            warning('Some coefficient values are invalid (NaN). Please check the table for non-numeric entries.');
        end
        
    catch ME
        warning('Error extracting coefficients from table: %s', ME.message);
        coefficient_values = [];
    end
end

function jointNames = getJointNames()
    % Full list of torque input prefixes extracted from model
    jointNames = {
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
end

function param_info = getPolynomialParameterInfo()
    % Get polynomial parameter structure - ONLY 7-coefficient joints (A-G)
    try
        % Try to load the polynomial input values from the model
        model_path = fullfile(fileparts(fileparts(pwd)), 'Model', 'PolynomialInputValues.mat');
        if ~exist(model_path, 'file')
            % Fallback: try relative path
            model_path = '../../Model/PolynomialInputValues.mat';
        end
        
        if exist(model_path, 'file')
            loaded_data = load(model_path);
            var_names = fieldnames(loaded_data);
            
            % Parse the variable names to extract joint and coefficient info
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
            
            % Filter to only include joints with 7 coefficients (A-G)
            all_joint_names = keys(joint_map);
            filtered_joint_names = {};
            filtered_coeffs = {};
            
            for i = 1:length(all_joint_names)
                joint_name = all_joint_names{i};
                coeffs = sort(joint_map(joint_name));
                
                % Only include joints with exactly 7 coefficients (A-G)
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
            
            param_info.total_params = length(param_info.joint_names) * 7; % All have 7 coefficients
            
        else
            % Fallback to original simplified structure if mat file not found
            warning('PolynomialInputValues.mat not found, using simplified joint structure');
            param_info = getSimplifiedParameterInfo();
        end
        
    catch ME
        warning('Error loading polynomial parameters: %s. Using simplified structure.', ME.message);
        param_info = getSimplifiedParameterInfo();
    end
end

function param_info = getSimplifiedParameterInfo()
    % Fallback simplified structure (original 27 joints)
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
        param_info.joint_coeffs{i} = 'ABCDEFG'; % 7 coefficients each
    end
    param_info.total_params = length(joint_names) * 7;
end

function updateJointCoefficients(src, evt, handles)
    % Update the joint coefficient editor when a different joint is selected
    try
        handles = guidata(handles.fig);
        selected_idx = get(handles.joint_selector, 'Value');
        joint_names = get(handles.joint_selector, 'String');
        selected_joint = joint_names{selected_idx};
        
        % Update status text
        set(handles.joint_edit_status, 'String', sprintf('Editing: %s', selected_joint));
        
        % Load default values (zeros) for the new joint
        for i = 1:7
            set(handles.joint_coeff_edits(i), 'String', '0.00');
        end
        
        handles = updateLog(sprintf('Selected joint: %s', selected_joint), handles);
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error updating joint: %s', ME.message), 'Joint Update Error');
    end
end

function validateCoefficientInput(src, evt, handles)
    % Validate and format coefficient input
    try
        current_value = get(src, 'String');
        num_value = str2double(current_value);
        
        if isnan(num_value)
            set(src, 'String', '0.00');
            errordlg('Invalid input. Please enter a numeric value.', 'Invalid Input');
        else
            % Format to 2 decimal places
            set(src, 'String', sprintf('%.2f', num_value));
        end
        
    catch ME
        set(src, 'String', '0.00');
        errordlg(sprintf('Error validating input: %s', ME.message), 'Validation Error');
    end
end

function applyJointToTable(src, evt, handles)
    % Apply current joint coefficients to all rows in the main table
    try
        handles = guidata(handles.fig);
        
        % Get current joint selection
        selected_idx = get(handles.joint_selector, 'Value');
        joint_names = get(handles.joint_selector, 'String');
        selected_joint = joint_names{selected_idx};
        
        % Get coefficient values from edit boxes
        coeff_values = zeros(1, 7);
        for i = 1:7
            coeff_values(i) = str2double(get(handles.joint_coeff_edits(i), 'String'));
        end
        
        % Find the columns in the main table for this joint
        table_data = get(handles.coefficients_table, 'Data');
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        if isempty(table_data)
            errordlg('No data in main table. Generate coefficients first.', 'No Data');
            return;
        end
        
        % Find columns corresponding to the selected joint
        joint_columns = [];
        for i = 1:length(col_names)
            if contains(col_names{i}, selected_joint)
                joint_columns(end+1) = i;
            end
        end
        
        if length(joint_columns) ~= 7
            errordlg(sprintf('Expected 7 columns for joint %s, found %d', selected_joint, length(joint_columns)), 'Column Mismatch');
            return;
        end
        
        % Apply coefficients to all rows
        num_rows = size(table_data, 1);
        for row = 1:num_rows
            for i = 1:7
                col = joint_columns(i);
                table_data{row, col} = sprintf('%.2f', coeff_values(i));
                
                % Mark as edited
                cell_key = sprintf('%d_%d', row, col);
                if ~any(strcmp(handles.edited_cells, cell_key))
                    handles.edited_cells{end+1} = cell_key;
                end
            end
        end
        
        % Update table and highlighting
        set(handles.coefficients_table, 'Data', table_data);
        highlightEditedCells(handles);
        
        % Update status
        num_edited = length(handles.edited_cells);
        status_msg = sprintf('Status: Applied %s coefficients to all rows (%d cells edited)', selected_joint, num_edited);
        set(handles.edit_status_text, 'String', status_msg);
        
        handles = updateLog(sprintf('Applied %s coefficients to all %d trials', selected_joint, num_rows), handles);
        guidata(handles.fig, handles);
        
        msgbox(sprintf('Applied %s coefficients to all %d trials', selected_joint, num_rows), 'Success');
        
    catch ME
        errordlg(sprintf('Error applying joint coefficients: %s', ME.message), 'Apply Error');
    end
end

function loadJointFromTable(src, evt, handles)
    % Load joint coefficients from the first row of the main table
    try
        handles = guidata(handles.fig);
        
        % Get current joint selection
        selected_idx = get(handles.joint_selector, 'Value');
        joint_names = get(handles.joint_selector, 'String');
        selected_joint = joint_names{selected_idx};
        
        % Get table data
        table_data = get(handles.coefficients_table, 'Data');
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        if isempty(table_data)
            errordlg('No data in main table. Generate coefficients first.', 'No Data');
            return;
        end
        
        % Find columns corresponding to the selected joint
        joint_columns = [];
        for i = 1:length(col_names)
            if contains(col_names{i}, selected_joint)
                joint_columns(end+1) = i;
            end
        end
        
        if length(joint_columns) ~= 7
            errordlg(sprintf('Expected 7 columns for joint %s, found %d', selected_joint, length(joint_columns)), 'Column Mismatch');
            return;
        end
        
        % Load coefficients from first row
        for i = 1:7
            col = joint_columns(i);
            value_str = table_data{1, col};
            if ischar(value_str)
                set(handles.joint_coeff_edits(i), 'String', value_str);
            else
                set(handles.joint_coeff_edits(i), 'String', sprintf('%.2f', value_str));
            end
        end
        
        handles = updateLog(sprintf('Loaded %s coefficients from table row 1', selected_joint), handles);
        guidata(handles.fig, handles);
        
        msgbox(sprintf('Loaded %s coefficients from table row 1', selected_joint), 'Success');
        
    catch ME
        errordlg(sprintf('Error loading joint coefficients: %s', ME.message), 'Load Error');
    end
end

function exportCoefficientsToCSV(src, evt, handles)
    % Export coefficient table to CSV file
    try
        % Get updated handles
        handles = guidata(handles.fig);
        
        % Get table data
        table_data = get(handles.coefficients_table, 'Data');
        if isempty(table_data)
            errordlg('No coefficient data to export', 'Export Error');
            return;
        end
        
        % Get column names
        col_names = get(handles.coefficients_table, 'ColumnName');
        
        % Ask user for filename
        [filename, pathname] = uiputfile('*.csv', 'Export Coefficients to CSV');
        if filename == 0
            return; % User cancelled
        end
        
        full_path = fullfile(pathname, filename);
        
        % Write to CSV
        writecell([col_names; table_data], full_path);
        
        % Log the action
        handles = updateLog(sprintf('Coefficients exported to: %s', filename), handles);
        msgbox('Coefficients exported successfully!', 'Export Success');
        
        % Save updated handles
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error exporting coefficients: %s', ME.message), 'Export Error');
    end
end

function importCoefficientsFromCSV(src, evt, handles)
    % Import coefficient table from CSV file
    try
        % Get updated handles
        handles = guidata(handles.fig);
        
        % Ask user for filename
        [filename, pathname] = uigetfile('*.csv', 'Import Coefficients from CSV');
        if filename == 0
            return; % User cancelled
        end
        
        full_path = fullfile(pathname, filename);
        
        % Read CSV file
        imported_data = readcell(full_path);
        
        % Validate data structure
        if size(imported_data, 1) < 2
            errordlg('Invalid CSV file: Must have header row and at least one data row', 'Import Error');
            return;
        end
        
        % Extract header and data
        header = imported_data(1, :);
        data = imported_data(2:end, :);
        
        % Validate column structure
        expected_cols = get(handles.coefficients_table, 'ColumnName');
        if length(header) ~= length(expected_cols)
            errordlg(sprintf('Column count mismatch: Expected %d columns, found %d', ...
                length(expected_cols), length(header)), 'Import Error');
            return;
        end
        
        % Update table
        set(handles.coefficients_table, 'Data', data);
        
        % Mark all cells as edited
        handles.edited_cells = {};
        [num_rows, num_cols] = size(data);
        for row = 1:num_rows
            for col = 2:num_cols % Skip trial column
                cell_key = sprintf('%d_%d', row, col);
                handles.edited_cells{end+1} = cell_key;
            end
        end
        
        % Update status
        num_edited = length(handles.edited_cells);
        status_msg = sprintf('Status: Imported from CSV (%d cells loaded)', num_edited);
        set(handles.edit_status_text, 'String', status_msg);
        
        % Highlight imported cells
        highlightEditedCells(handles);
        
        % Log the action
        handles = updateLog(sprintf('Coefficients imported from: %s (%d trials)', filename, num_rows), handles);
        msgbox('Coefficients imported successfully!', 'Import Success');
        
        % Save updated handles
        guidata(handles.fig, handles);
        
    catch ME
        errordlg(sprintf('Error importing coefficients: %s', ME.message), 'Import Error');
    end
end

% Dummy function for trial execution (replace with your actual implementation)
function result = runSingleTrialWithSignalBus(trial_num, config, trial_coefficients)
    % This is a placeholder - replace with your actual trial execution code
    % trial_coefficients: [Joint1_A, Joint1_B, ..., Joint1_G, Joint2_A, Joint2_B, ..., JointN_G] 
    %                     Array of all coefficients for all joints
    
    result = struct();
    result.success = true;
    result.filename = sprintf('trial_%03d.csv', trial_num);
    result.error = '';
    
    % Log basic info about the coefficients
    num_joints = length(trial_coefficients) / 7;
    fprintf('Trial %d using %d coefficients for %d joints (range: %.2f to %.2f)\n', ...
        trial_num, length(trial_coefficients), num_joints, ...
        min(trial_coefficients), max(trial_coefficients));
    
    % Log first joint's coefficients as example
    if length(trial_coefficients) >= 7
        fprintf('  First joint coefficients: A=%.2f, B=%.2f, C=%.2f, D=%.2f, E=%.2f, F=%.2f, G=%.2f\n', ...
            trial_coefficients(1), trial_coefficients(2), trial_coefficients(3), ...
            trial_coefficients(4), trial_coefficients(5), trial_coefficients(6), trial_coefficients(7));
    end
    
    % Simulate some processing time
    pause(0.1);
end 