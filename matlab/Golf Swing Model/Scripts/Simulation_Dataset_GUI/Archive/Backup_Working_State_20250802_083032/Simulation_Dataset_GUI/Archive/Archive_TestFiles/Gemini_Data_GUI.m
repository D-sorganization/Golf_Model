%% Data_Generation_GUI.m
%
% Author: (Original author if known, otherwise Gemini)
% Date: 2025-07-26
%
% Description:
% This script creates an improved Graphical User Interface (GUI) for generating
% training data from a Simulink model of a golf swing. The GUI allows users to
% configure simulation parameters, manage torque input coefficients, and run
% batch simulations to produce datasets ready for machine learning.
%
% --- Summary of Improvements ---
% 1.  **Repaired Functionality:**
%     - Added a functional placeholder for the missing `runSingleTrial` function.
%       This mock function allows the GUI to run end-to-end and demonstrates
%       where to integrate the actual Simulink call.
%
% 2.  **Cleaned-Up UI & Layout:**
%     - Removed redundant Simulink model selection controls to avoid confusion.
%     - Systematically adjusted panel and control spacing for a cleaner, more
%       professional, and less cluttered appearance.
%     - The polynomial equation display now uses a LaTeX interpreter for
%       clear and accurate mathematical rendering.
%
% 3.  **Improved Robustness:**
%     - Replaced fragile `pwd`-based file paths with paths relative to the
%       script's location using `mfilename('fullpath')`. The GUI is no longer
%       dependent on the directory from which it is run.
%     - Added more informative error handling when essential files (like model
%       parameters or preferences) cannot be found.
%
% 4.  **Enhanced Usability:**
%     - Improved tooltips and status messages for better user feedback.
%     - The logical flow from configuration (left) to preview and execution
%       (right) is now more visually apparent.
%
function Data_Generation_GUI()
    % GolfSwingDataGenerator - Improved GUI for generating golf swing training data
    
    % Create main figure with proper sizing
    screenSize = get(groot, 'ScreenSize'); % Use groot for modern MATLAB
    figWidth = min(1400, screenSize(3) * 0.9);
    figHeight = min(800, screenSize(4) * 0.85);
    
    fig = figure('Name', 'Golf Swing Data Generator', ...
                 'Position', [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'CloseRequestFcn', @closeGUICallback);
    
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
    
    % Initialize previews
    updatePreview([], [], handles);
    updateCoefficientsPreview([], [], handles);
end

function handles = createMainLayout(fig, handles)
    % Create main layout with consistent margins and spacing
    
    figColor = [0.94, 0.94, 0.94];
    set(fig, 'Color', figColor);

    % Main container using a grid layout for robustness (conceptual)
    % Here we will use normalized units but with better spacing
    margin = 0.015;
    
    % Title panel
    titlePanel = uipanel('Parent', fig, ...
                        'Units', 'normalized', ...
                        'Position', [margin, 0.94, 1 - 2*margin, 0.05], ...
                        'BackgroundColor', [0.2, 0.3, 0.5], ...
                        'BorderType', 'none');
    
    uicontrol('Parent', titlePanel, ...
              'Style', 'text', ...
              'String', 'Golf Swing Data Generator', ...
              'Units', 'normalized', ...
              'Position', [0, 0, 1, 1], ...
              'FontSize', 16, ...
              'FontWeight', 'bold', ...
              'ForegroundColor', 'white', ...
              'BackgroundColor', [0.2, 0.3, 0.5], ...
              'HorizontalAlignment', 'center');
    
    % Create two-column layout
    leftPanelWidth = 0.48;
    rightPanelWidth = 0.48;
    panelSpacing = 0.015;

    leftPanel = uipanel('Parent', fig, ...
                       'Units', 'normalized', ...
                       'Position', [margin, margin, leftPanelWidth, 0.94 - 2*margin], ...
                       'BackgroundColor', figColor, ...
                       'BorderType', 'line');
    
    rightPanel = uipanel('Parent', fig, ...
                        'Units', 'normalized', ...
                        'Position', [margin + leftPanelWidth + panelSpacing, margin, rightPanelWidth, 0.94 - 2*margin], ...
                        'BackgroundColor', figColor, ...
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
    
    % Define panel heights with proper spacing
    panelHeight1 = 0.23; % Trial & Data Sources
    panelHeight2 = 0.18; % Modeling Configuration  
    panelHeight3 = 0.3;  % Individual Joint Editor (taller for polynomial)
    panelHeight4 = 0.23; % Output Configuration
    spacing = 0.015;
    
    yPos1 = 1 - panelHeight1 - spacing;
    yPos2 = yPos1 - panelHeight2 - spacing;
    yPos3 = yPos2 - panelHeight3 - spacing;
    yPos4 = margin; % Fill remaining space
    
    % Trial Settings & Data Sources Panel
    handles = createTrialAndDataPanel(parent, handles, yPos1, panelHeight1);
    
    % Modeling Configuration Panel
    handles = createModelingPanel(parent, handles, yPos2, panelHeight2);
    
    % Individual Joint Editor Panel
    handles = createJointEditorPanel(parent, handles, yPos3, panelHeight3);
    
    % Output Settings Panel
    handles = createOutputPanel(parent, handles, yPos4, panelHeight4);
end

function handles = createRightColumnContent(parent, handles)
    % Create all content for the right column
    spacing = 0.015;

    % Define panel heights
    panelHeight1 = 0.38; % Preview Panel
    panelHeight2 = 0.32; % Coefficients Table Panel
    panelHeight3 = 0.12; % Progress Panel
    panelHeight4 = 0.12; % Control Buttons Panel

    yPos1 = 1 - panelHeight1 - spacing;
    yPos2 = yPos1 - panelHeight2 - spacing;
    yPos3 = yPos2 - panelHeight3 - spacing;
    yPos4 = margin;

    % Preview Panel
    handles = createPreviewPanel(parent, handles, yPos1, panelHeight1);
    
    % Coefficients Table Panel
    handles = createCoefficientsPanel(parent, handles, yPos2, panelHeight2);
    
    % Progress Panel
    handles = createProgressPanel(parent, handles, yPos3, panelHeight3);
    
    % Control Buttons Panel
    handles = createControlPanel(parent, handles, yPos4, panelHeight4);
end

function handles = createTrialAndDataPanel(parent, handles, yPos, height)
    panel = uipanel('Parent', parent, ...
                   'Title', 'Trial Settings & Data Sources', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.82; h1 = 0.15;
    y2 = 0.62; h2 = 0.15;  
    y3 = 0.42; h3 = 0.15;
    y4 = 0.22; h4 = 0.15;
    
    % === STARTING POINT FILE SELECTION ===
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Starting Point File:', 'Units', 'normalized', 'Position', [0.02, y1, 0.2, h1], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    handles.input_file_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', 'Select a .mat input file...', 'Units', 'normalized', 'Position', [0.23, y1, 0.48, h1], 'Enable', 'inactive', 'TooltipString', 'Selected starting point .mat file');
    handles.browse_input_btn = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Browse...', 'Units', 'normalized', 'Position', [0.73, y1, 0.12, h1], 'Callback', {@browseInputFile, handles}, 'TooltipString', 'Select starting point .mat file');
    handles.clear_input_btn = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Clear', 'Units', 'normalized', 'Position', [0.86, y1, 0.1, h1], 'Callback', {@clearInputFile, handles}, 'TooltipString', 'Clear file selection');
    handles.file_status_text = uicontrol('Parent', panel, 'Style', 'text', 'String', '', 'Units', 'normalized', 'Position', [0.23, y1-0.1, 0.7, h1], 'FontSize', 8, 'ForegroundColor', [0.5, 0.5, 0.5], 'HorizontalAlignment', 'left');
    
    % === TRIAL PARAMETERS ===
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Trials:', 'Units', 'normalized', 'Position', [0.02, y2, 0.08, h2], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    handles.num_trials_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '10', 'Units', 'normalized', 'Position', [0.11, y2, 0.08, h2], 'Callback', {@updateCoefficientsPreview, handles}, 'TooltipString', 'Number of simulation trials');
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Duration (s):', 'Units', 'normalized', 'Position', [0.21, y2, 0.12, h2], 'HorizontalAlignment', 'left');
    handles.sim_time_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '0.3', 'Units', 'normalized', 'Position', [0.34, y2, 0.08, h2], 'TooltipString', 'Simulation duration in seconds');
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Sample Rate (Hz):', 'Units', 'normalized', 'Position', [0.44, y2, 0.14, h2], 'HorizontalAlignment', 'left');
    handles.sample_rate_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '100', 'Units', 'normalized', 'Position', [0.59, y2, 0.08, h2], 'TooltipString', 'Data sampling rate');
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Mode:', 'Units', 'normalized', 'Position', [0.69, y2, 0.08, h2], 'HorizontalAlignment', 'left');
    handles.execution_mode_popup = uicontrol('Parent', panel, 'Style', 'popupmenu', 'String', {'Sequential', 'Parallel'}, 'Units', 'normalized', 'Position', [0.78, y2, 0.16, h2], 'TooltipString', 'Execution mode for trials');
    
    % === DATA SOURCES ===
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Data Sources:', 'Units', 'normalized', 'Position', [0.02, y3, 0.15, h3], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    handles.use_model_workspace = uicontrol('Parent', panel, 'Style', 'checkbox', 'String', 'Model Workspace', 'Units', 'normalized', 'Position', [0.18, y3, 0.18, h3], 'Value', 1, 'TooltipString', 'Extract model parameters and variables');
    handles.use_logsout = uicontrol('Parent', panel, 'Style', 'checkbox', 'String', 'Logsout', 'Units', 'normalized', 'Position', [0.37, y3, 0.12, h3], 'Value', 1, 'TooltipString', 'Extract logged signals');
    handles.use_signal_bus = uicontrol('Parent', panel, 'Style', 'checkbox', 'String', 'Signal Bus', 'Units', 'normalized', 'Position', [0.50, y3, 0.15, h3], 'Value', 1, 'TooltipString', 'Extract ToWorkspace block data');
    handles.use_simscape = uicontrol('Parent', panel, 'Style', 'checkbox', 'String', 'Simscape Results', 'Units', 'normalized', 'Position', [0.66, y3, 0.22, h3], 'Value', 1, 'TooltipString', 'Extract primary simulation data');
    
    % === MODEL SELECTION ===
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Simulink Model:', 'Units', 'normalized', 'Position', [0.02, y4, 0.2, h4], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    handles.model_display = uicontrol('Parent', panel, 'Style', 'text', 'String', 'GolfSwing3D_Kinetic', 'Units', 'normalized', 'Position', [0.23, y4, 0.48, h4], 'HorizontalAlignment', 'left', 'BackgroundColor', [1, 1, 1], 'TooltipString', 'Selected Simulink model file');
    handles.model_browse_btn = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Browse...', 'Units', 'normalized', 'Position', [0.73, y4, 0.23, h4], 'Callback', {@selectSimulinkModel, handles}, 'TooltipString', 'Select Simulink model file');
    
    % Initialize model name
    handles.model_name = 'GolfSwing3D_Kinetic';
    handles.model_path = '';
    handles.selected_input_file = '';
end

function handles = createModelingPanel(parent, handles, yPos, height)
    % Modeling Configuration Panel
    % --- IMPROVEMENT: Removed redundant Simulink model selection ---
    panel = uipanel('Parent', parent, ...
                   'Title', 'Modeling Configuration', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.65; h1 = 0.25;
    y2 = 0.25; h2 = 0.25;
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Torque Scenario:', 'Units', 'normalized', 'Position', [0.02, y1, 0.25, h1], 'HorizontalAlignment', 'left');
    handles.torque_scenario_popup = uicontrol('Parent', panel, 'Style', 'popupmenu', 'String', {'Variable Torques', 'Zero Torque', 'Constant Torque'}, 'Units', 'normalized', 'Position', [0.3, y1, 0.6, h1], 'Callback', {@torqueScenarioCallback, handles});
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Coefficient Range (±):', 'Units', 'normalized', 'Position', [0.02, y2, 0.25, h2], 'HorizontalAlignment', 'left');
    handles.coeff_range_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '50', 'Units', 'normalized', 'Position', [0.3, y2, 0.15, h2], 'Callback', {@updateCoefficientsPreview, handles});
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Constant Value (G):', 'Units', 'normalized', 'Position', [0.5, y2, 0.25, h2], 'HorizontalAlignment', 'left');
    handles.constant_value_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '10', 'Units', 'normalized', 'Position', [0.75, y2, 0.15, h2], 'Callback', {@updateCoefficientsPreview, handles}, 'Enable', 'off');
end

function handles = createJointEditorPanel(parent, handles, yPos, height)
    % Individual Joint Editor with trial selection capability
    param_info = getPolynomialParameterInfo();
    
    panel = uipanel('Parent', parent, ...
                   'Title', 'Individual Joint Editor', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % --- IMPROVEMENT: Use LaTeX for the equation for a professional look ---
    handles.equation_display = uicontrol('Parent', panel, 'Style', 'text', ...
                                       'String', '$$\tau(t) = A + Bt + Ct^2 + Dt^3 + Et^4 + Ft^5 + Gt^6$$', ...
                                       'Interpreter', 'latex', ...
                                       'Units', 'normalized', 'Position', [0.02, 0.02, 0.96, 0.12], ...
                                       'FontSize', 12, 'FontWeight', 'bold', ...
                                       'ForegroundColor', [0.1, 0.1, 0.7], ...
                                       'BackgroundColor', [0.95, 0.95, 1], ...
                                       'HorizontalAlignment', 'center');

    y1 = 0.85; h1 = 0.1;
    y2 = 0.60; h2 = 0.1;
    y3 = 0.45; h3 = 0.1;
    y4 = 0.25; h4 = 0.12;

    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Select Joint:', 'Units', 'normalized', 'Position', [0.02, y1, 0.12, h1], 'HorizontalAlignment', 'left');
    handles.joint_selector = uicontrol('Parent', panel, 'Style', 'popupmenu', 'String', param_info.joint_names, 'Units', 'normalized', 'Position', [0.15, y1, 0.3, h1], 'Callback', {@updateJointCoefficients, handles});
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Apply to:', 'Units', 'normalized', 'Position', [0.47, y1, 0.1, h1], 'HorizontalAlignment', 'left');
    handles.trial_selection_popup = uicontrol('Parent', panel, 'Style', 'popupmenu', 'String', {'All Trials', 'Specific Trial'}, 'Units', 'normalized', 'Position', [0.58, y1, 0.18, h1], 'Callback', {@updateTrialSelectionMode, handles});
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Trial #:', 'Units', 'normalized', 'Position', [0.77, y1, 0.08, h1], 'HorizontalAlignment', 'left');
    handles.trial_number_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '1', 'Units', 'normalized', 'Position', [0.85, y1, 0.1, h1], 'Enable', 'off');
    
    % Coefficient edit boxes (A-G)
    coeff_labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
    handles.joint_coeff_edits = gobjects(1, 7);
    for i = 1:7
        xPos = 0.02 + (i-1) * 0.138;
        uicontrol('Parent', panel, 'Style', 'text', 'String', coeff_labels{i}, 'Units', 'normalized', 'Position', [xPos, y2+0.05, 0.13, h2], 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        handles.joint_coeff_edits(i) = uicontrol('Parent', panel, 'Style', 'edit', 'String', '0.00', 'Units', 'normalized', 'Position', [xPos, y2, 0.13, h2], 'HorizontalAlignment', 'center', 'Callback', {@validateCoefficientInput, handles});
    end
    
    % Action buttons
    handles.apply_joint_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Apply to Table', 'Units', 'normalized', 'Position', [0.02, y4, 0.22, h4], 'FontWeight', 'bold', 'BackgroundColor', [0.7, 0.9, 0.7], 'Callback', {@applyJointToTable, handles});
    handles.load_joint_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Load from Table', 'Units', 'normalized', 'Position', [0.26, y4, 0.22, h4], 'FontWeight', 'bold', 'BackgroundColor', [0.9, 0.9, 0.7], 'Callback', {@loadJointFromTable, handles});
    
    % Status
    handles.joint_status = uicontrol('Parent', panel, 'Style', 'text', 'String', sprintf('Ready - %s selected', param_info.joint_names{1}), 'Units', 'normalized', 'Position', [0.5, y4, 0.48, h4], 'HorizontalAlignment', 'left');
    
    handles.param_info = param_info;
end

function handles = createOutputPanel(parent, handles, yPos, height)
    panel = uipanel('Parent', parent, ...
                   'Title', 'Output Configuration', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    y1 = 0.75; h1 = 0.18;
    y2 = 0.45; h2 = 0.18;
    y3 = 0.15; h3 = 0.18;
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Output Folder:', 'Units', 'normalized', 'Position', [0.02, y1, 0.15, h1], 'HorizontalAlignment', 'left');
    handles.output_folder_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', pwd, 'Units', 'normalized', 'Position', [0.2, y1, 0.6, h1]);
    handles.browse_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Browse', 'Units', 'normalized', 'Position', [0.82, y1, 0.15, h1], 'Callback', {@browseOutputFolder, handles});
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Dataset Folder:', 'Units', 'normalized', 'Position', [0.02, y2, 0.15, h2], 'HorizontalAlignment', 'left');
    handles.folder_name_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', 'training_data_csv', 'Units', 'normalized', 'Position', [0.2, y2, 0.35, h2]);
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'File Format:', 'Units', 'normalized', 'Position', [0.58, y2, 0.12, h2], 'HorizontalAlignment', 'left');
    handles.format_popup = uicontrol('Parent', panel, 'Style', 'popupmenu', 'String', {'CSV Files', 'MAT Files', 'Both CSV and MAT'}, 'Units', 'normalized', 'Position', [0.7, y2, 0.27, h2]);
    
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Files are saved with trial numbers and timestamps for easy identification.', 'Units', 'normalized', 'Position', [0.02, y3, 0.9, h3], 'HorizontalAlignment', 'left');
end

function handles = createPreviewPanel(parent, handles, yPos, height)
    panel = uipanel('Parent', parent, ...
                   'Title', 'Input Parameters Preview', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.update_preview_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Update Preview', 'Units', 'normalized', 'Position', [0.02, 0.9, 0.25, 0.08], 'FontWeight', 'bold', 'BackgroundColor', [0.2, 0.7, 0.1], 'ForegroundColor', 'white', 'Callback', {@updatePreview, handles});
    handles.preview_table = uitable('Parent', panel, 'Units', 'normalized', 'Position', [0.02, 0.1, 0.96, 0.78], 'ColumnName', {'Parameter', 'Value', 'Description'}, 'ColumnWidth', {'auto', 'auto', 300}, 'RowStriping', 'on');
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'A summary of the current settings and expected simulation configuration.', 'Units', 'normalized', 'Position', [0.02, 0.01, 0.96, 0.08], 'HorizontalAlignment', 'left');
end

function handles = createCoefficientsPanel(parent, handles, yPos, height)
    param_info = getPolynomialParameterInfo();
    
    panel = uipanel('Parent', parent, ...
                   'Title', 'Polynomial Coefficients Table', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    % Controls
    y_controls = 0.88; h_controls = 0.1;
    uicontrol('Parent', panel, 'Style', 'text', 'String', 'Search:', 'Units', 'normalized', 'Position', [0.02, y_controls, 0.08, h_controls], 'HorizontalAlignment', 'left');
    handles.search_edit = uicontrol('Parent', panel, 'Style', 'edit', 'String', '', 'Units', 'normalized', 'Position', [0.10, y_controls, 0.20, h_controls], 'Callback', {@searchCoefficients, handles}, 'KeyPressFcn', {@searchCoefficients, handles});
    handles.clear_search_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Clear', 'Units', 'normalized', 'Position', [0.31, y_controls, 0.08, h_controls], 'Callback', {@clearSearch, handles});
    
    % Group buttons in a sub-panel for better organization
    btnPanel = uipanel('Parent', panel, 'Units', 'normalized', 'Position', [0.4, 0.88, 0.58, h_controls+0.02], 'BorderType', 'none', 'BackgroundColor', [0.98, 0.98, 0.98]);
    handles.reset_coeffs_button = uicontrol('Parent', btnPanel, 'Style', 'pushbutton', 'String', 'Reset', 'Units', 'normalized', 'Position', [0.01, 0, 0.15, 1], 'Callback', {@resetCoefficientsToGenerated, handles});
    handles.apply_row_button = uicontrol('Parent', btnPanel, 'Style', 'pushbutton', 'String', 'Apply Row', 'Units', 'normalized', 'Position', [0.17, 0, 0.15, 1], 'Callback', {@applyRowToAll, handles});
    handles.export_button = uicontrol('Parent', btnPanel, 'Style', 'pushbutton', 'String', 'Export', 'Units', 'normalized', 'Position', [0.33, 0, 0.15, 1], 'Callback', {@exportCoefficientsToCSV, handles}, 'TooltipString', 'Export coefficients to a CSV file');
    handles.import_button = uicontrol('Parent', btnPanel, 'Style', 'pushbutton', 'String', 'Import', 'Units', 'normalized', 'Position', [0.49, 0, 0.15, 1], 'Callback', {@importCoefficientsFromCSV, handles}, 'TooltipString', 'Import coefficients from a CSV file');
    handles.save_scenario_button = uicontrol('Parent', btnPanel, 'Style', 'pushbutton', 'String', 'Save', 'Units', 'normalized', 'Position', [0.65, 0, 0.15, 1], 'Callback', {@saveScenario, handles}, 'TooltipString', 'Save current torque coefficients as a scenario file (.mat)');
    handles.load_scenario_button = uicontrol('Parent', btnPanel, 'Style', 'pushbutton', 'String', 'Load', 'Units', 'normalized', 'Position', [0.81, 0, 0.15, 1], 'Callback', {@loadScenario, handles}, 'TooltipString', 'Load a saved coefficient scenario file (.mat)');

    % Create table with proper column structure
    col_names = {'Trial'}; col_widths = {40}; col_editable = false;
    for i = 1:length(param_info.joint_names)
        short_name = getShortenedJointName(param_info.joint_names{i});
        for j = 1:length(param_info.joint_coeffs{i})
            coeff = param_info.joint_coeffs{i}(j);
            col_names{end+1} = sprintf('%s_%s', short_name, coeff);
            col_widths{end+1} = 50;
            col_editable(end+1) = true;
        end
    end
    
    handles.coefficients_table = uitable('Parent', panel, 'Units', 'normalized', 'Position', [0.02, 0.05, 0.96, 0.8], 'ColumnName', col_names, 'ColumnWidth', col_widths, 'RowStriping', 'on', 'ColumnEditable', col_editable, 'CellEditCallback', {@coefficientCellEditCallback, handles});
    
    handles.edited_cells = {};
    handles.param_info = param_info;
end

function handles = createProgressPanel(parent, handles, yPos, height)
    panel = uipanel('Parent', parent, ...
                   'Title', 'Generation Progress', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    handles.progress_text = uicontrol('Parent', panel, 'Style', 'text', 'String', 'Ready to start generation...', 'Units', 'normalized', 'Position', [0.02, 0.55, 0.96, 0.35], 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    handles.status_text = uicontrol('Parent', panel, 'Style', 'text', 'String', 'Status: Ready', 'Units', 'normalized', 'Position', [0.02, 0.10, 0.96, 0.35], 'HorizontalAlignment', 'left');
end

function handles = createControlPanel(parent, handles, yPos, height)
    panel = uipanel('Parent', parent, ...
                   'Title', 'Generation Controls', ...
                   'FontSize', 11, ...
                   'FontWeight', 'bold', ...
                   'Units', 'normalized', ...
                   'Position', [0.02, yPos, 0.96, height], ...
                   'BackgroundColor', [0.98, 0.98, 0.98]);
    
    buttonY = 0.15; buttonHeight = 0.70;
    
    handles.start_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Start Generation', 'Units', 'normalized', 'Position', [0.02, buttonY, 0.25, buttonHeight], 'FontWeight', 'bold', 'FontSize', 11, 'BackgroundColor', [0.2, 0.6, 0.1], 'ForegroundColor', 'white', 'Callback', {@startGeneration, handles});
    handles.stop_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Stop', 'Units', 'normalized', 'Position', [0.29, buttonY, 0.15, buttonHeight], 'FontWeight', 'bold', 'BackgroundColor', [0.8, 0.2, 0.1], 'ForegroundColor', 'white', 'Enable', 'off', 'Callback', {@stopGeneration, handles});
    handles.validate_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Validate', 'Units', 'normalized', 'Position', [0.48, buttonY, 0.15, buttonHeight], 'Callback', {@validateSettings, handles});
    handles.save_config_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Save Config', 'Units', 'normalized', 'Position', [0.65, buttonY, 0.15, buttonHeight], 'Callback', {@saveConfiguration, handles});
    handles.load_config_button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Load Config', 'Units', 'normalized', 'Position', [0.82, buttonY, 0.15, buttonHeight], 'Callback', {@loadConfiguration, handles});
end

function closeGUICallback(src, ~)
    try
        handles = guidata(src);
        saveUserPreferences(handles);
    catch
        disp('Could not save preferences on close.');
    end
    delete(src);
end

% ==================== CALLBACK FUNCTIONS ====================

function torqueScenarioCallback(src, ~, handles)
    scenario_idx = get(src, 'Value');
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
end

function browseOutputFolder(~, ~, handles)
    folder = uigetdir(get(handles.output_folder_edit, 'String'), 'Select Output Folder');
    if folder ~= 0
        set(handles.output_folder_edit, 'String', folder);
        updatePreview([], [], handles);
        saveUserPreferences(handles);
    end
end

function updatePreview(~, ~, handles)
    try
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        sim_time = str2double(get(handles.sim_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        scenarios = get(handles.torque_scenario_popup, 'String');
        
        preview_data = {
            'Number of Trials', num2str(num_trials), 'Total simulation runs';
            'Simulation Time', [num2str(sim_time) ' s'], 'Duration per trial';
            'Sample Rate', [num2str(sample_rate) ' Hz'], 'Data sampling frequency';
            'Data Points per Trial', num2str(round(sim_time * sample_rate)), 'Time series length';
            'Torque Scenario', scenarios{scenario_idx}, 'Coefficient generation method';
        };
        
        if scenario_idx == 1
            coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
            preview_data = [preview_data; {'Coefficient Range', ['±' num2str(coeff_range)], 'Random variation bounds'}];
        elseif scenario_idx == 3
            constant_value = str2double(get(handles.constant_value_edit, 'String'));
            preview_data = [preview_data; {'Constant Value', num2str(constant_value), 'Value for coefficient G'}];
        end
        
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        preview_data = [preview_data; {'Output Location', fullfile(output_folder, folder_name), 'File destination'}];
        
        set(handles.preview_table, 'Data', preview_data);
    catch ME
        set(handles.preview_table, 'Data', {'Error', 'Check inputs', ME.message});
    end
end

function updateCoefficientsPreview(~, ~, handles)
    try
        num_trials = round(str2double(get(handles.num_trials_edit, 'String')));
        if isnan(num_trials) || num_trials <= 0, num_trials = 10; end
        
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        constant_value = str2double(get(handles.constant_value_edit, 'String'));
        
        param_info = handles.param_info;
        total_columns = 1 + param_info.total_params;
        coeff_data = cell(num_trials, total_columns);
        
        for i = 1:num_trials
            coeff_data{i, 1} = i; % Trial number
            col_idx = 2;
            for joint_idx = 1:length(param_info.joint_names)
                coeffs = param_info.joint_coeffs{joint_idx};
                for coeff_idx = 1:length(coeffs)
                    coeff_letter = coeffs(coeff_idx);
                    val = 0;
                    switch scenario_idx
                        case 1 % Variable Torques
                            val = (rand - 0.5) * 2 * coeff_range;
                        case 2 % Zero Torque
                            val = 0;
                        case 3 % Constant Torque
                            if coeff_letter == 'G'
                                val = constant_value;
                            else
                                val = 0;
                            end
                    end
                    coeff_data{i, col_idx} = sprintf('%.2f', val);
                    col_idx = col_idx + 1;
                end
            end
        end
        
        set(handles.coefficients_table, 'Data', coeff_data);
        handles.edited_cells = {}; % Clear edit tracking
        
        % Store original data for search/reset functionality
        handles.original_coefficients_data = coeff_data;
        handles.original_coefficients_columns = get(handles.coefficients_table, 'ColumnName');
        guidata(handles.fig, handles);
    catch ME
        fprintf('Error in updateCoefficientsPreview: %s\n', ME.message);
    end
end

function updateJointCoefficients(~, ~, handles)
    selected_idx = get(handles.joint_selector, 'Value');
    joint_names = get(handles.joint_selector, 'String');
    set(handles.joint_status, 'String', sprintf('Ready - %s selected', joint_names{selected_idx}));
    for i = 1:7, set(handles.joint_coeff_edits(i), 'String', '0.00'); end
end

function updateTrialSelectionMode(src, ~, handles)
    selection_idx = get(src, 'Value');
    if selection_idx == 1 % All Trials
        set(handles.trial_number_edit, 'Enable', 'off', 'BackgroundColor', [0.94, 0.94, 0.94]);
    else % Specific Trial
        set(handles.trial_number_edit, 'Enable', 'on', 'BackgroundColor', 'white');
    end
end

function validateCoefficientInput(src, ~, ~)
    current_value = get(src, 'String');
    num_value = str2double(current_value);
    if isnan(num_value)
        set(src, 'String', '0.00');
    else
        set(src, 'String', sprintf('%.2f', num_value));
    end
end

function applyJointToTable(~, ~, handles)
    try
        selected_joint_idx = get(handles.joint_selector, 'Value');
        selected_joint = handles.joint_selector.String{selected_joint_idx};
        trial_selection_idx = get(handles.trial_selection_popup, 'Value');
        
        coeff_values = arrayfun(@(x) str2double(get(x, 'String')), handles.joint_coeff_edits);
        table_data = get(handles.coefficients_table, 'Data');
        if isempty(table_data), errordlg('Coefficient table is empty.', 'Error'); return; end
        
        short_joint_name = getShortenedJointName(selected_joint);
        joint_columns = find(contains(handles.coefficients_table.ColumnName, short_joint_name));
        if length(joint_columns) ~= 7, errordlg('Could not find 7 columns for the selected joint.', 'Error'); return; end
        
        if trial_selection_idx == 1 % All Trials
            target_rows = 1:size(table_data, 1);
            status_msg = sprintf('Applied %s coefficients to all %d trials', selected_joint, length(target_rows));
        else % Specific trial
            target_trial = str2double(get(handles.trial_number_edit, 'String'));
            if isnan(target_trial) || target_trial < 1 || target_trial > size(table_data, 1)
                errordlg(sprintf('Invalid trial number. Must be between 1 and %d.', size(table_data, 1)), 'Error');
                return;
            end
            target_rows = target_trial;
            status_msg = sprintf('Applied %s coefficients to trial %d', selected_joint, target_rows);
        end
        
        for row = target_rows
            for i = 1:7
                table_data{row, joint_columns(i)} = sprintf('%.2f', coeff_values(i));
            end
        end
        
        set(handles.coefficients_table, 'Data', table_data);
        handles.original_coefficients_data = table_data; % Update base data
        set(handles.joint_status, 'String', status_msg);
        guidata(handles.fig, handles);
        msgbox(status_msg, 'Success');
    catch ME
        errordlg(sprintf('Error applying coefficients: %s', ME.message), 'Apply Error');
    end
end

function loadJointFromTable(~, ~, handles)
    try
        selected_joint_idx = get(handles.joint_selector, 'Value');
        selected_joint = handles.joint_selector.String{selected_joint_idx};
        
        table_data = get(handles.coefficients_table, 'Data');
        if isempty(table_data), errordlg('Coefficient table is empty.', 'Error'); return; end

        source_row = 1;
        if get(handles.trial_selection_popup, 'Value') == 2 % Specific Trial
            source_row = str2double(get(handles.trial_number_edit, 'String'));
            if isnan(source_row) || source_row < 1 || source_row > size(table_data, 1)
                errordlg(sprintf('Invalid trial number for loading. Must be between 1 and %d.', size(table_data, 1)), 'Error');
                return;
            end
        end
        
        short_joint_name = getShortenedJointName(selected_joint);
        joint_columns = find(contains(handles.coefficients_table.ColumnName, short_joint_name));
        if length(joint_columns) ~= 7, errordlg('Could not find 7 columns for the selected joint.', 'Error'); return; end

        for i = 1:7
            value_str = table_data{source_row, joint_columns(i)};
            if ischar(value_str)
                set(handles.joint_coeff_edits(i), 'String', value_str);
            else
                set(handles.joint_coeff_edits(i), 'String', sprintf('%.2f', value_str));
            end
        end
        
        status_msg = sprintf('Loaded %s coefficients from trial %d', selected_joint, source_row);
        set(handles.joint_status, 'String', status_msg);
        msgbox(status_msg, 'Success');
    catch ME
        errordlg(sprintf('Error loading coefficients: %s', ME.message), 'Load Error');
    end
end

function coefficientCellEditCallback(src, eventdata, handles)
    row = eventdata.Indices(1);
    col = eventdata.Indices(2);
    new_value_str = eventdata.NewData;
    
    num_value = str2double(new_value_str);
    if isnan(num_value)
        errordlg('Invalid input. Please enter a number.', 'Invalid Input');
        % Revert change
        current_data = get(src, 'Data');
        current_data{row, col} = eventdata.PreviousData;
        set(src, 'Data', current_data);
        return;
    end
    
    % Format and update table
    formatted_value = sprintf('%.2f', num_value);
    current_data = get(src, 'Data');
    current_data{row, col} = formatted_value;
    set(src, 'Data', current_data);
    
    % Update the underlying "original" data so edits are not lost on search/reset
    handles.original_coefficients_data{row, col} = formatted_value;
    guidata(handles.fig, handles);
end

function resetCoefficientsToGenerated(~, ~, handles)
    answer = questdlg('This will discard all manual edits to the table. Are you sure?', 'Confirm Reset', 'Yes', 'No', 'No');
    if strcmp(answer, 'Yes')
        updateCoefficientsPreview([], [], handles);
        set(handles.joint_status, 'String', 'Table reset to generated values.');
    end
end

function selectSimulinkModel(~, ~, handles)
    [filename, pathname] = uigetfile({'*.slx;*.mdl', 'Simulink Models (*.slx, *.mdl)'}, 'Select Simulink Model');
    if isequal(filename, 0), return; end
    [~, model_name] = fileparts(filename);
    
    set(handles.model_display, 'String', model_name);
    handles.model_name = model_name;
    handles.model_path = fullfile(pathname, filename);
    guidata(handles.fig, handles);
    fprintf('Selected Simulink model: %s\n', handles.model_name);
end

function applyRowToAll(~, ~, handles)
    current_data = get(handles.coefficients_table, 'Data');
    if isempty(current_data), errordlg('No data in table.', 'Error'); return; end
    
    prompt = sprintf('Enter row number (1-%d) to apply to all other rows:', size(current_data, 1));
    answer = inputdlg(prompt, 'Select Template Row', 1, {'1'});
    if isempty(answer), return; end
    
    template_row_idx = str2double(answer{1});
    if isnan(template_row_idx) || template_row_idx < 1 || template_row_idx > size(current_data, 1)
        errordlg('Invalid row number.', 'Error');
        return;
    end
    
    template_coeffs = current_data(template_row_idx, 2:end);
    for row = 1:size(current_data, 1)
        current_data(row, 2:end) = template_coeffs;
    end
    
    set(handles.coefficients_table, 'Data', current_data);
    handles.original_coefficients_data = current_data; % Update base data
    guidata(handles.fig, handles);
    msgbox(sprintf('Applied row %d to all rows.', template_row_idx), 'Success');
end

function exportCoefficientsToCSV(~, ~, handles)
    table_data = get(handles.coefficients_table, 'Data');
    if isempty(table_data), errordlg('No data to export.', 'Error'); return; end
    
    col_names = get(handles.coefficients_table, 'ColumnName');
    
    [filename, pathname] = uiputfile('*.csv', 'Export Coefficients', 'coefficients.csv');
    if isequal(filename, 0), return; end
    
    try
        T = cell2table(table_data, 'VariableNames', col_names);
        writetable(T, fullfile(pathname, filename));
        msgbox('Coefficients exported successfully!', 'Export Success');
    catch ME
        errordlg(sprintf('Export error: %s', ME.message), 'Export Error');
    end
end

function importCoefficientsFromCSV(~, ~, handles)
    [filename, pathname] = uigetfile('*.csv', 'Import Coefficients');
    if isequal(filename, 0), return; end
    
    try
        T = readtable(fullfile(pathname, filename));
        imported_data = table2cell(T);
        
        expected_cols = get(handles.coefficients_table, 'ColumnName');
        if size(T, 2) ~= length(expected_cols)
            errordlg(sprintf('Column count mismatch. Expected %d, found %d.', length(expected_cols), size(T, 2)), 'Import Error');
            return;
        end
        
        set(handles.coefficients_table, 'ColumnName', T.Properties.VariableNames);
        set(handles.coefficients_table, 'Data', imported_data);
        
        handles.original_coefficients_data = imported_data;
        handles.original_coefficients_columns = T.Properties.VariableNames;
        guidata(handles.fig, handles);
        msgbox('Coefficients imported successfully!', 'Import Success');
    catch ME
        errordlg(sprintf('Import error: %s', ME.message), 'Import Error');
    end
end

% ==================== Main control functions ====================
function startGeneration(~, ~, handles)
    config = validateInputs(handles);
    if isempty(config), return; end
    
    set(handles.start_button, 'Enable', 'off');
    set(handles.stop_button, 'Enable', 'on');
    handles.should_stop = false;
    handles.config = config;
    guidata(handles.fig, handles);
    
    set(handles.status_text, 'String', 'Status: Starting generation...');
    set(handles.progress_text, 'String', 'Initializing simulation...');
    drawnow;
    
    runGeneration(handles);
end

function stopGeneration(~, ~, handles)
    handles.should_stop = true;
    set(handles.status_text, 'String', 'Status: Stopping...');
    set(handles.stop_button, 'Enable', 'off');
    guidata(handles.fig, handles);
end

function validateSettings(~, ~, handles)
    config = validateInputs(handles);
    if ~isempty(config)
        msgbox('All settings are valid!', 'Validation Success', 'modal');
    end
end

function saveConfiguration(~, ~, handles)
    config = validateInputs(handles);
    if ~isempty(config)
        [filename, pathname] = uiputfile('*.mat', 'Save Configuration', 'gui_config.mat');
        if ~isequal(filename, 0)
            save(fullfile(pathname, filename), 'config');
            msgbox('Configuration saved successfully!', 'Save Success');
        end
    end
end

function loadConfiguration(~, ~, handles)
    [filename, pathname] = uigetfile('*.mat', 'Load Configuration');
    if ~isequal(filename, 0)
        try
            loaded = load(fullfile(pathname, filename));
            if isfield(loaded, 'config')
                applyConfiguration(loaded.config, handles);
                updatePreview([], [], handles);
                updateCoefficientsPreview([],[],handles); % Also update table
                msgbox('Configuration loaded successfully!', 'Load Success');
            else
                errordlg('Invalid configuration file.', 'Load Failed');
            end
        catch ME
             errordlg(sprintf('Load error: %s', ME.message), 'Load Failed');
        end
    end
end

% ==================== Helper functions ====================
function config = validateInputs(handles)
    config = [];
    try
        num_trials = str2double(get(handles.num_trials_edit, 'String'));
        if isnan(num_trials) || num_trials <= 0 || num_trials > 10000
            error('Number of trials must be a positive integer (max 10,000).');
        end
        
        sim_time = str2double(get(handles.sim_time_edit, 'String'));
        if isnan(sim_time) || sim_time <= 0 || sim_time > 300
            error('Simulation time must be a positive number (max 300s).');
        end

        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        if isnan(sample_rate) || sample_rate <= 0 || sample_rate > 10000
             error('Sample rate must be a positive number (max 10,000 Hz).');
        end
        
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        if isempty(output_folder) || isempty(folder_name)
            error('Please specify a valid output folder and dataset name.');
        end
        if ~exist(output_folder, 'dir'), error('The specified output folder does not exist.'); end

        % Create config structure
        config.model_name = handles.model_name;
        config.num_simulations = num_trials;
        config.simulation_time = sim_time;
        config.sample_rate = sample_rate;
        config.torque_scenario = get(handles.torque_scenario_popup, 'Value');
        config.coeff_range = str2double(get(handles.coeff_range_edit, 'String'));
        config.constant_value = str2double(get(handles.constant_value_edit, 'String'));
        config.use_model_workspace = get(handles.use_model_workspace, 'Value');
        config.use_logsout = get(handles.use_logsout, 'Value');
        config.use_signal_bus = get(handles.use_signal_bus, 'Value');
        config.use_simscape = get(handles.use_simscape, 'Value');
        config.output_folder = fullfile(output_folder, folder_name);
        config.file_format = get(handles.format_popup, 'Value');
        config.execution_mode = get(handles.execution_mode_popup, 'Value');
        
    catch ME
        errordlg(ME.message, 'Input Validation Error');
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
    set(handles.execution_mode_popup, 'Value', config.execution_mode);
    set(handles.format_popup, 'Value', config.file_format);
    
    if isfield(config, 'model_name')
        handles.model_name = config.model_name;
        set(handles.model_display, 'String', config.model_name);
    end
    
    [folder, name, ext] = fileparts(config.output_folder);
    set(handles.output_folder_edit, 'String', folder);
    set(handles.folder_name_edit, 'String', [name, ext]);
    
    torqueScenarioCallback(handles.torque_scenario_popup, [], handles);
    guidata(handles.fig, handles);
end

function runGeneration(handles)
    try
        config = handles.config;
        config.coefficient_values = extractCoefficientsFromTable(handles);
        if isempty(config.coefficient_values), error('No coefficient values in table.'); end
        
        if ~exist(config.output_folder, 'dir'), mkdir(config.output_folder); end
        
        set(handles.status_text, 'String', 'Status: Running trials...');
        successful_trials = 0;
        failed_trials = 0;
        
        for trial = 1:config.num_simulations
            handles = guidata(handles.fig);
            if handles.should_stop, break; end
            
            progress_msg = sprintf('Processing trial %d of %d...', trial, config.num_simulations);
            set(handles.progress_text, 'String', progress_msg);
            drawnow;
            
            try
                trial_coefficients = config.coefficient_values(trial, :);
                result = runSingleTrialWithSignalBus(trial, config, trial_coefficients);
                if result.success
                    successful_trials = successful_trials + 1;
                else
                    failed_trials = failed_trials + 1;
                    fprintf('Trial %d failed: %s\n', trial, result.error);
                end
            catch ME
                failed_trials = failed_trials + 1;
                fprintf('Trial %d error: %s\n', trial, ME.message);
            end
        end
        
        final_msg = sprintf('Complete: %d successful, %d failed.', successful_trials, failed_trials);
        set(handles.status_text, 'String', ['Status: ' final_msg]);
        set(handles.progress_text, 'String', final_msg);
        
        if successful_trials > 0
            set(handles.status_text, 'String', 'Status: Compiling master dataset...');
            drawnow;
            compileDataset(config);
            set(handles.status_text, 'String', ['Status: ' final_msg ' Dataset compiled.']);
        end
        
    catch ME
        set(handles.status_text, 'String', ['Status: Error - ' ME.message]);
        errordlg(ME.message, 'Generation Failed');
    end
    
    set(handles.start_button, 'Enable', 'on');
    set(handles.stop_button, 'Enable', 'off');
end

function coefficient_values = extractCoefficientsFromTable(handles)
    table_data = get(handles.coefficients_table, 'Data');
    if isempty(table_data), coefficient_values = []; return; end
    
    % Exclude the first column (Trial #)
    coeff_data_cell = table_data(:, 2:end);
    
    % Convert cell of strings to numeric matrix
    coefficient_values = cellfun(@str2double, coeff_data_cell);
    
    if any(isnan(coefficient_values(:)))
        warning('Some coefficient values in the table are invalid (NaN) and were converted to NaN.');
    end
end

function param_info = getPolynomialParameterInfo()
    % --- IMPROVEMENT: Use robust path relative to this m-file ---
    param_info = getSimplifiedParameterInfo(); % Start with fallback
    try
        gui_path = fileparts(mfilename('fullpath'));
        % Assumes Model folder is at ../../Model relative to the GUI script folder
        model_path = fullfile(gui_path, '..', '..', 'Model', 'PolynomialInputValues.mat');

        if exist(model_path, 'file')
            loaded_data = load(model_path);
            var_names = fieldnames(loaded_data);
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
            
            if ~isempty(filtered_joint_names)
                param_info.joint_names = sort(filtered_joint_names);
                param_info.joint_coeffs = cell(size(param_info.joint_names));
                for i = 1:length(param_info.joint_names)
                    joint_name = param_info.joint_names{i};
                    idx = find(strcmp(filtered_joint_names, joint_name), 1);
                    param_info.joint_coeffs{i} = filtered_coeffs{idx};
                end
                param_info.total_params = length(param_info.joint_names) * 7;
            end
        else
            warning('PolynomialInputValues.mat not found at expected path: %s. Using simplified structure.', model_path);
        end
    catch ME
        warning('Error loading polynomial parameters: %s. Using simplified structure.', ME.message);
    end
end

function param_info = getSimplifiedParameterInfo()
    % Fallback simplified structure
    joint_names = {
        'BaseTorqueInputX', 'BaseTorqueInputY', 'BaseTorqueInputZ',
        'HipInputX', 'HipInputY', 'HipInputZ',
        'LSInputX', 'LSInputY', 'LSInputZ'
    };
    param_info.joint_names = joint_names;
    param_info.joint_coeffs = cell(1, length(joint_names));
    [param_info.joint_coeffs{:}] = deal('ABCDEFG');
    param_info.total_params = length(joint_names) * 7;
end

function short_name = getShortenedJointName(joint_name)
    % Create consistent shortened joint names for display
    short_name = strrep(joint_name, 'TorqueInput', 'T');
    short_name = strrep(short_name, 'Input', '');
end

% ==================== MISSING/BROKEN LINK FUNCTIONS (REPAIRED) ====================

function result = runSingleTrialWithSignalBus(trial_num, config, trial_coefficients)
    % This function now calls the placeholder 'runSingleTrial'
    result = struct('success', false, 'error', 'Unknown error');
    try
        % ================================================================
        % This is the primary simulation call. It passes trial-specific
        % parameters to the simulation function.
        % ================================================================
        simResult = runSingleTrial(trial_num, config, trial_coefficients);
        
        if simResult.success
            % If the simulation was successful, process the output file
            csv_path = fullfile(config.output_folder, simResult.filename);
            if exist(csv_path, 'file')
                data_table = readtable(csv_path);
                num_rows = height(data_table);
                
                % Add trial metadata for ML labeling
                data_table.trial_id = repmat(trial_num, num_rows, 1);
                
                % Add input coefficients as features
                param_info = getPolynomialParameterInfo();
                col_idx = 1;
                for j = 1:length(param_info.joint_names)
                    for k = 1:length(param_info.joint_coeffs{j})
                        coeff_name = sprintf('input_%s_%s', getShortenedJointName(param_info.joint_names{j}), param_info.joint_coeffs{j}(k));
                        data_table.(coeff_name) = repmat(trial_coefficients(col_idx), num_rows, 1);
                        col_idx = col_idx + 1;
                    end
                end
                
                % Reorder columns for better organization
                metadata_cols = data_table.Properties.VariableNames(contains(data_table.Properties.VariableNames, {'trial_id', 'time'}));
                input_cols = data_table.Properties.VariableNames(contains(data_table.Properties.VariableNames, 'input_'));
                output_cols = setdiff(data_table.Properties.VariableNames, [metadata_cols, input_cols], 'stable');
                data_table = data_table(:, [metadata_cols, input_cols, output_cols]);
                
                % Save enhanced CSV
                enhanced_filename = sprintf('ml_trial_%04d.csv', trial_num);
                writetable(data_table, fullfile(config.output_folder, enhanced_filename));
                
                % Delete the temporary raw file from the mock simulation
                delete(csv_path);
                
                result.success = true;
                result.filename = enhanced_filename;
            else
                result.error = 'Simulation reported success, but output file was not found.';
            end
        else
            result = simResult;
        end
    catch ME
        result.error = ME.message;
    end
end

function simResult = runSingleTrial(trial_num, config, trial_coefficients)
    % --- MOCK FUNCTION ---
    % This is a placeholder for the actual Simulink simulation runner.
    % It simulates a successful run by creating a dummy CSV file.
    %
    % REPLACE THIS with your actual call to `sim()` or other simulation script.
    %
    % Your real function should:
    % 1. Load the Simulink model (`config.model_name`).
    % 2. Set the input parameters (the `trial_coefficients`) in the model workspace.
    % 3. Run the simulation for `config.simulation_time`.
    % 4. Collect the output data (e.g., from a 'To Workspace' or 'To File' block).
    % 5. Save the raw data to a file and return the filename.
    % 6. Return a `simResult` struct with `success` (true/false) and `filename`.
    
    fprintf('--- MOCK RUN: Simulating trial %d ---\n', trial_num);
    simResult = struct('success', false, 'filename', '');
    
    try
        % Simulate some work
        pause(0.1); 
        
        % Create a dummy data table
        num_points = config.simulation_time * config.sample_rate;
        time_vector = linspace(0, config.simulation_time, num_points)';
        
        % Generate some fake output signals
        output_signal_1 = sin(time_vector * trial_coefficients(1)/10) + randn(num_points, 1)*0.1;
        output_signal_2 = cos(time_vector * trial_coefficients(2)/10) + randn(num_points, 1)*0.1;
        
        T = table(time_vector, output_signal_1, output_signal_2);
        T.Properties.VariableNames = {'time', 'Joint1_Angle', 'Joint2_Velocity'};
        
        % Save to a temporary file
        temp_filename = sprintf('raw_trial_%04d_temp.csv', trial_num);
        temp_filepath = fullfile(config.output_folder, temp_filename);
        writetable(T, temp_filepath);
        
        % Report success
        simResult.success = true;
        simResult.filename = temp_filename;
        
    catch ME
        simResult.success = false;
        simResult.error = ME.message;
        fprintf('--- MOCK RUN FAILED for trial %d: %s ---\n', trial_num, ME.message);
    end
end

function browseInputFile(~, ~, handles)
    [filename, pathname] = uigetfile({'*.mat', 'MAT-files (*.mat)'}, 'Select Input File');
    if isequal(filename, 0), return; end
    
    fullPath = fullfile(pathname, filename);
    set(handles.input_file_edit, 'String', filename, 'TooltipString', fullPath);
    handles.selected_input_file = fullPath;
    set(handles.file_status_text, 'String', '✓ File selected by user.');
    guidata(handles.fig, handles);
    saveUserPreferences(handles);
end

function clearInputFile(~, ~, handles)
    set(handles.input_file_edit, 'String', 'Select a .mat input file...', 'TooltipString', 'Selected starting point .mat file');
    handles.selected_input_file = '';
    set(handles.file_status_text, 'String', '');
    guidata(handles.fig, handles);
end

function saveScenario(~, ~, handles)
    data = get(handles.coefficients_table, 'Data');
    if isempty(data), errordlg('No coefficient data to save.', 'Save Error'); return; end
    
    [filename, pathname] = uiputfile('*.mat', 'Save Scenario', 'scenario.mat');
    if isequal(filename, 0), return; end
    
    scenario.coefficients_data = data;
    scenario.column_names = get(handles.coefficients_table, 'ColumnName');
    scenario.description = inputdlg('Enter scenario description (optional):', 'Save Scenario', 1, {''});
    scenario.timestamp = datetime('now');
    
    save(fullfile(pathname, filename), 'scenario');
    msgbox(sprintf('Scenario saved to %s', filename), 'Save Success');
end

function loadScenario(~, ~, handles)
    [filename, pathname] = uigetfile('*.mat', 'Load Scenario');
    if isequal(filename, 0), return; end
    
    try
        loaded = load(fullfile(pathname, filename));
        if ~isfield(loaded, 'scenario') || ~isfield(loaded.scenario, 'coefficients_data')
            errordlg('Invalid scenario file.', 'Load Error');
            return;
        end
        
        scenario = loaded.scenario;
        set(handles.coefficients_table, 'Data', scenario.coefficients_data);
        set(handles.coefficients_table, 'ColumnName', scenario.column_names);
        
        handles.original_coefficients_data = scenario.coefficients_data;
        handles.original_coefficients_columns = scenario.column_names;
        guidata(handles.fig, handles);
        
        msgbox(sprintf('Scenario "%s" loaded successfully!', filename), 'Load Success');
    catch ME
        errordlg(sprintf('Error loading scenario: %s', ME.message), 'Load Error');
    end
end

% ==================== SEARCH FUNCTIONS ====================
function searchCoefficients(src, evt, handles)
    search_text = get(handles.search_edit, 'String');
    
    if ~isfield(handles, 'original_coefficients_data') || isempty(handles.original_coefficients_data)
        return; % Nothing to search
    end
    
    if isempty(search_text)
        restoreOriginalTable(handles);
        return;
    end
    
    table_data = handles.original_coefficients_data;
    col_names = handles.original_coefficients_columns;
    
    matching_cols = find(contains(col_names, search_text, 'IgnoreCase', true));
    if ~isempty(matching_cols)
        % Always include trial column (index 1)
        display_cols = unique([1, matching_cols]); 
        set(handles.coefficients_table, 'Data', table_data(:, display_cols));
        set(handles.coefficients_table, 'ColumnName', col_names(display_cols));
        set(handles.joint_status, 'String', sprintf('Filtered to %d matching columns.', length(matching_cols)));
    else
        set(handles.coefficients_table, 'Data', table_data(:,1));
        set(handles.coefficients_table, 'ColumnName', col_names(1));
        set(handles.joint_status, 'String', 'No matching columns found.');
    end
end

function restoreOriginalTable(handles)
    if isfield(handles, 'original_coefficients_data') && ~isempty(handles.original_coefficients_data)
        set(handles.coefficients_table, 'Data', handles.original_coefficients_data);
        set(handles.coefficients_table, 'ColumnName', handles.original_coefficients_columns);
        set(handles.joint_status, 'String', 'Showing all coefficients.');
    end
end

function clearSearch(~, ~, handles)
    set(handles.search_edit, 'String', '');
    restoreOriginalTable(handles);
end

% ==================== DATASET COMPILATION ====================
function compileDataset(config)
    % Compile all individual trial CSV files into a master dataset
    csv_files = dir(fullfile(config.output_folder, 'ml_trial_*.csv'));
    if isempty(csv_files), warning('No ML trial CSV files found to compile.'); return; end
    
    all_data = cell(length(csv_files), 1);
    for i = 1:length(csv_files)
        try
            all_data{i} = readtable(fullfile(config.output_folder, csv_files(i).name));
        catch ME
            warning('Failed to read %s: %s', csv_files(i).name, ME.message);
        end
    end
    
    % Combine all tables
    master_data = vertcat(all_data{:});
    
    if ~isempty(master_data)
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        master_filename_csv = sprintf('master_dataset_%s.csv', timestamp);
        master_filename_mat = sprintf('master_dataset_%s.mat', timestamp);
        
        writetable(master_data, fullfile(config.output_folder, master_filename_csv));
        save(fullfile(config.output_folder, master_filename_mat), 'master_data', '-v7.3');
        fprintf('✓ Master dataset with %d rows saved.\n', height(master_data));
    end
end

% ==================== USER PREFERENCES ====================
function handles = loadUserPreferences(handles)
    % --- IMPROVEMENT: Use robust path relative to this m-file ---
    pref_file = fullfile(fileparts(mfilename('fullpath')), 'user_preferences.mat');
    
    handles.preferences = struct(...
        'last_output_folder', pwd, ...
        'default_num_trials', 50, ...
        'default_sim_time', 1.5, ...
        'default_sample_rate', 1000 ...
    );
    
    if exist(pref_file, 'file')
        try
            loaded_prefs = load(pref_file);
            if isfield(loaded_prefs, 'preferences')
                % Merge loaded preferences, overwriting defaults
                f = fieldnames(loaded_prefs.preferences);
                for i = 1:length(f)
                    handles.preferences.(f{i}) = loaded_prefs.preferences.(f{i});
                end
            end
        catch ME
            fprintf('Warning: Could not load user preferences: %s\n', ME.message);
        end
    end
end

function applyUserPreferences(handles)
    prefs = handles.preferences;
    set(handles.output_folder_edit, 'String', prefs.last_output_folder);
    set(handles.num_trials_edit, 'String', num2str(prefs.default_num_trials));
    set(handles.sim_time_edit, 'String', num2str(prefs.default_sim_time));
    set(handles.sample_rate_edit, 'String', num2str(prefs.default_sample_rate));
end

function saveUserPreferences(handles)
    % --- IMPROVEMENT: Use robust path relative to this m-file ---
    pref_file = fullfile(fileparts(mfilename('fullpath')), 'user_preferences.mat');
    
    try
        preferences = handles.preferences;
        preferences.last_output_folder = get(handles.output_folder_edit, 'String');
        preferences.default_num_trials = str2double(get(handles.num_trials_edit, 'String'));
        preferences.default_sim_time = str2double(get(handles.sim_time_edit, 'String'));
        preferences.default_sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        save(pref_file, 'preferences');
    catch ME
        fprintf('Warning: Could not save user preferences: %s\n', ME.message);
    end
end