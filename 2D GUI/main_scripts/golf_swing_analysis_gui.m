function golf_swing_analysis_gui()
% GOLF_SWING_ANALYSIS_GUI - Enhanced 4-Tab GUI for 2D Golf Swing Analysis
%
% This GUI provides 4 main tabs:
%   1. Simulation Tab: Parameter adjustment, simulation, animation, basic plotting
%   2. ZTCF/ZVCF Analysis Tab: Complete analysis pipeline
%   3. Plots & Interaction Tab: Advanced plotting and data exploration
%   4. Skeleton Plotter Tab: Advanced 3D visualization of BASEQ, ZTCFQ, DELTAQ
%
% Usage:
%   golf_swing_analysis_gui();

    % Load configuration
    config = model_config();
    
    % Create main figure
    main_fig = figure('Name', config.gui_title, ...
                      'NumberTitle', 'off', ...
                      'Position', [50, 50, config.gui_width, config.gui_height], ...
                      'Color', config.colors.background, ...
                      'MenuBar', 'none', ...
                      'ToolBar', 'none', ...
                      'Resize', 'on', ...
                      'CloseRequestFcn', @close_gui_callback);
    
    % Create main tab group
    main_tab_group = uitabgroup('Parent', main_fig, ...
                               'Position', [0.02, 0.02, 0.96, 0.96]);
    
    % Create the 4 main tabs
    simulation_tab = uitab('Parent', main_tab_group, ...
                          'Title', '🎮 Simulation');
    
    analysis_tab = uitab('Parent', main_tab_group, ...
                        'Title', '📊 ZTCF/ZVCF Analysis');
    
    plots_tab = uitab('Parent', main_tab_group, ...
                     'Title', '📈 Plots & Interaction');
    
    skeleton_tab = uitab('Parent', main_tab_group, ...
                        'Title', '🦴 Skeleton Plotter');
    
    % Create content for each tab
    create_simulation_tab(simulation_tab, config);
    create_analysis_tab(analysis_tab, config);
    create_plots_tab(plots_tab, config);
    create_skeleton_tab(skeleton_tab, config);
    
    % Store data in figure
    setappdata(main_fig, 'config', config);
    setappdata(main_fig, 'main_tab_group', main_tab_group);
    
    fprintf('✅ Enhanced 4-Tab Golf Swing Analysis GUI created successfully\n');
    
end

function create_simulation_tab(parent, config)
    % Create simulation tab with parameter adjustment and basic visualization
    
    % Create left panel for parameter controls
    param_panel = uipanel('Parent', parent, ...
                         'Title', 'Parameter Controls', ...
                         'FontSize', 12, ...
                         'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Create parameter controls
    create_parameter_controls(param_panel, config);
    
    % Create center panel for simulation controls
    sim_panel = uipanel('Parent', parent, ...
                       'Title', 'Simulation Controls', ...
                       'FontSize', 12, ...
                       'Position', [0.28, 0.02, 0.25, 0.96]);
    
    % Create simulation controls
    create_simulation_controls(sim_panel, config);
    
    % Create right panel for visualization
    viz_panel = uipanel('Parent', parent, ...
                       'Title', 'Visualization', ...
                       'FontSize', 12, ...
                       'Position', [0.54, 0.02, 0.44, 0.96]);
    
    % Create visualization area
    create_simulation_visualization(viz_panel, config);
    
end

function create_parameter_controls(parent, config)
    % Create parameter adjustment controls
    
    % Model parameters section
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Model Parameters:', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Position', [10, 700, 200, 20], ...
              'HorizontalAlignment', 'left');
    
    % Stop time
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Stop Time (s):', ...
              'FontSize', 10, ...
              'Position', [10, 670, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    stop_time_edit = uicontrol('Parent', parent, ...
                              'Style', 'edit', ...
                              'String', num2str(config.stop_time), ...
                              'FontSize', 10, ...
                              'Position', [120, 670, 80, 25], ...
                              'Callback', @update_stop_time);
    
    % Max step
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Max Step (s):', ...
              'FontSize', 10, ...
              'Position', [10, 640, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    max_step_edit = uicontrol('Parent', parent, ...
                             'Style', 'edit', ...
                             'String', num2str(config.max_step), ...
                             'FontSize', 10, ...
                             'Position', [120, 640, 80, 25], ...
                             'Callback', @update_max_step);
    
    % Dampening
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Dampening:', ...
              'FontSize', 10, ...
              'Position', [10, 610, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    dampening_popup = uicontrol('Parent', parent, ...
                               'Style', 'popupmenu', ...
                               'String', {'Included', 'Excluded'}, ...
                               'FontSize', 10, ...
                               'Position', [120, 610, 80, 25], ...
                               'Value', 1, ...
                               'Callback', @update_dampening);
    
    % Golf swing parameters section
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Golf Swing Parameters:', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Position', [10, 570, 200, 20], ...
              'HorizontalAlignment', 'left');
    
    % Club parameters
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Club Length (m):', ...
              'FontSize', 10, ...
              'Position', [10, 540, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    club_length_edit = uicontrol('Parent', parent, ...
                                'Style', 'edit', ...
                                'String', '1.0', ...
                                'FontSize', 10, ...
                                'Position', [120, 540, 80, 25], ...
                                'Callback', @update_club_length);
    
    % Initial conditions section
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Initial Conditions:', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Position', [10, 500, 200, 20], ...
              'HorizontalAlignment', 'left');
    
    % Load preset button
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', 'Load Preset', ...
              'FontSize', 10, ...
              'Position', [10, 470, 100, 30], ...
              'Callback', @load_preset);
    
    % Save preset button
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', 'Save Preset', ...
              'FontSize', 10, ...
              'Position', [120, 470, 100, 30], ...
              'Callback', @save_preset);
    
    % Store handles
    setappdata(parent, 'stop_time_edit', stop_time_edit);
    setappdata(parent, 'max_step_edit', max_step_edit);
    setappdata(parent, 'dampening_popup', dampening_popup);
    setappdata(parent, 'club_length_edit', club_length_edit);
    
end

function create_simulation_controls(parent, config)
    % Create simulation control buttons
    
    % Run simulation button
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '🚀 Run Simulation', ...
              'FontSize', 11, ...
              'Position', [10, 700, 200, 40], ...
              'Callback', @run_simulation);
    
    % Load existing data button
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '📂 Load Data', ...
              'FontSize', 11, ...
              'Position', [10, 650, 200, 40], ...
              'Callback', @load_simulation_data);
    
    % Animation controls
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '▶️ Play Animation', ...
              'FontSize', 11, ...
              'Position', [10, 600, 200, 40], ...
              'Callback', @play_animation);
    
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '⏹️ Stop Animation', ...
              'FontSize', 11, ...
              'Position', [10, 550, 200, 40], ...
              'Callback', @stop_animation);
    
    % Basic plotting controls
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '📊 Plot Forces', ...
              'FontSize', 11, ...
              'Position', [10, 500, 200, 40], ...
              'Callback', @plot_forces);
    
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '📊 Plot Torques', ...
              'FontSize', 11, ...
              'Position', [10, 450, 200, 40], ...
              'Callback', @plot_torques);
    
    % Export controls
    uicontrol('Parent', parent, ...
              'Style', 'pushbutton', ...
              'String', '💾 Export Data', ...
              'FontSize', 11, ...
              'Position', [10, 400, 200, 40], ...
              'Callback', @export_simulation_data);
    
    % Progress panel
    progress_panel = uipanel('Parent', parent, ...
                            'Title', 'Progress', ...
                            'FontSize', 10, ...
                            'Position', [0.05, 0.05, 0.9, 0.25]);
    
    % Progress text
    progress_text = uicontrol('Parent', progress_panel, ...
                             'Style', 'text', ...
                             'String', 'Ready to run simulation...', ...
                             'FontSize', 10, ...
                             'Position', [10, 80, 180, 60], ...
                             'HorizontalAlignment', 'left', ...
                             'Tag', 'progress_text');
    
    % Progress bar
    progress_bar = uicontrol('Parent', progress_panel, ...
                            'Style', 'text', ...
                            'String', '', ...
                            'BackgroundColor', [0.8, 0.8, 0.8], ...
                            'Position', [10, 40, 180, 20]);
    
    % Store handles
    setappdata(parent, 'progress_text', progress_text);
    setappdata(parent, 'progress_bar', progress_bar);
    
end

function create_simulation_visualization(parent, config)
    % Create visualization area for simulation
    
    % Create animation axes
    anim_ax = axes('Parent', parent, ...
                   'Position', [0.1, 0.3, 0.8, 0.6], ...
                   'Box', 'on', ...
                   'GridLineStyle', ':', ...
                   'GridAlpha', 0.3);
    
    hold(anim_ax, 'on');
    grid(anim_ax, 'on');
    xlabel(anim_ax, 'X Position (m)', 'FontSize', config.plot_font_size);
    ylabel(anim_ax, 'Y Position (m)', 'FontSize', config.plot_font_size);
    title(anim_ax, 'Golf Swing Animation', 'FontSize', config.plot_font_size + 2);
    
    % Set axis limits
    xlim(anim_ax, [-2, 2]);
    ylim(anim_ax, [-1, 1]);
    axis(anim_ax, 'equal');
    
    % Create plot handles for animation
    animation_handles = struct();
    animation_handles.club_shaft = plot(anim_ax, NaN, NaN, 'b-', 'LineWidth', 3);
    animation_handles.club_head = plot(anim_ax, NaN, NaN, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    animation_handles.hands = plot(anim_ax, NaN, NaN, 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    animation_handles.arms = plot(anim_ax, NaN, NaN, 'k-', 'LineWidth', 2);
    animation_handles.torso = plot(anim_ax, NaN, NaN, 'k-', 'LineWidth', 2);
    
    % Create time display
    animation_handles.time_text = text(anim_ax, 0.02, 0.98, 'Time: 0.000s', ...
                                      'Units', 'normalized', ...
                                      'FontSize', 12, ...
                                      'BackgroundColor', 'white', ...
                                      'EdgeColor', 'black');
    
    % Create basic plot axes for forces/torques
    plot_ax = axes('Parent', parent, ...
                   'Position', [0.1, 0.05, 0.8, 0.2], ...
                   'Box', 'on', ...
                   'GridLineStyle', ':', ...
                   'GridAlpha', 0.3);
    
    hold(plot_ax, 'on');
    grid(plot_ax, 'on');
    xlabel(plot_ax, 'Time (s)', 'FontSize', config.plot_font_size);
    ylabel(plot_ax, 'Magnitude', 'FontSize', config.plot_font_size);
    title(plot_ax, 'Forces and Torques', 'FontSize', config.plot_font_size);
    
    % Store handles
    setappdata(parent, 'anim_ax', anim_ax);
    setappdata(parent, 'animation_handles', animation_handles);
    setappdata(parent, 'plot_ax', plot_ax);
    
end

function create_analysis_tab(parent, config)
    % Create ZTCF/ZVCF analysis tab
    
    % Create left panel for analysis controls
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Analysis Controls', ...
                           'FontSize', 12, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Analysis buttons
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '🚀 Run Complete Analysis', ...
              'FontSize', 11, ...
              'Position', [10, 700, 200, 40], ...
              'Callback', @run_complete_analysis);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '📂 Load Existing Data', ...
              'FontSize', 11, ...
              'Position', [10, 650, 200, 40], ...
              'Callback', @load_analysis_data);
    
    % Individual analysis steps
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '📊 Generate Base Data', ...
              'FontSize', 11, ...
              'Position', [10, 600, 200, 40], ...
              'Callback', @generate_base_data);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '🔄 Generate ZTCF Data', ...
              'FontSize', 11, ...
              'Position', [10, 550, 200, 40], ...
              'Callback', @generate_ztcf_data);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '📈 Generate ZVCF Data', ...
              'FontSize', 11, ...
              'Position', [10, 500, 200, 40], ...
              'Callback', @generate_zvcf_data);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '⚙️ Process Data Tables', ...
              'FontSize', 11, ...
              'Position', [10, 450, 200, 40], ...
              'Callback', @process_data_tables);
    
    % Progress panel
    progress_panel = uipanel('Parent', control_panel, ...
                            'Title', 'Progress', ...
                            'FontSize', 10, ...
                            'Position', [0.05, 0.05, 0.9, 0.3]);
    
    % Progress text
    progress_text = uicontrol('Parent', progress_panel, ...
                             'Style', 'text', ...
                             'String', 'Ready to start analysis...', ...
                             'FontSize', 10, ...
                             'Position', [10, 80, 180, 60], ...
                             'HorizontalAlignment', 'left', ...
                             'Tag', 'analysis_progress_text');
    
    % Progress bar
    progress_bar = uicontrol('Parent', progress_panel, ...
                            'Style', 'text', ...
                            'String', '', ...
                            'BackgroundColor', [0.8, 0.8, 0.8], ...
                            'Position', [10, 40, 180, 20]);
    
    % Store handles
    setappdata(control_panel, 'progress_text', progress_text);
    setappdata(control_panel, 'progress_bar', progress_bar);
    
    % Create right panel for analysis status
    status_panel = uipanel('Parent', parent, ...
                          'Title', 'Analysis Status', ...
                          'FontSize', 12, ...
                          'Position', [0.28, 0.02, 0.7, 0.96]);
    
    % Create status display
    create_analysis_status_display(status_panel, config);
    
end

function create_analysis_status_display(parent, config)
    % Create status display for analysis
    
    % Status text area
    status_text = uicontrol('Parent', parent, ...
                           'Style', 'text', ...
                           'String', 'Analysis Status: Ready', ...
                           'FontSize', 10, ...
                           'Position', [20, 600, 600, 150], ...
                           'HorizontalAlignment', 'left', ...
                           'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Data summary table
    summary_table = uitable('Parent', parent, ...
                           'Position', [20, 200, 600, 380], ...
                           'ColumnName', {'Dataset', 'Status', 'Data Points', 'Time Range'}, ...
                           'Data', cell(4, 4), ...
                           'ColumnWidth', {150, 100, 100, 150});
    
    % Store handles
    setappdata(parent, 'status_text', status_text);
    setappdata(parent, 'summary_table', summary_table);
    
end

function create_plots_tab(parent, config)
    % Create plots and interaction tab
    
    % Create tab group for different plot types
    plot_tab_group = uitabgroup('Parent', parent, ...
                               'Position', [0.02, 0.02, 0.96, 0.96]);
    
    % Create tabs for different plot categories
    time_series_tab = uitab('Parent', plot_tab_group, ...
                           'Title', 'Time Series');
    phase_plots_tab = uitab('Parent', plot_tab_group, ...
                           'Title', 'Phase Plots');
    quiver_plots_tab = uitab('Parent', plot_tab_group, ...
                            'Title', 'Quiver Plots');
    comparison_tab = uitab('Parent', plot_tab_group, ...
                          'Title', 'Comparisons');
    data_explorer_tab = uitab('Parent', plot_tab_group, ...
                             'Title', 'Data Explorer');
    
    % Create content for each plot tab
    create_time_series_panel(time_series_tab, config);
    create_phase_plots_panel(phase_plots_tab, config);
    create_quiver_plots_panel(quiver_plots_tab, config);
    create_comparison_panel(comparison_tab, config);
    create_data_explorer_panel(data_explorer_tab, config);
    
end

function create_skeleton_tab(parent, config)
    % Create skeleton plotter tab
    
    % Create control panel
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Skeleton Plotter Controls', ...
                           'FontSize', 12, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Data selection dropdown
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Select Dataset:', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Position', [10, 750, 200, 20], ...
              'HorizontalAlignment', 'left');
    
    dataset_dropdown = uicontrol('Parent', control_panel, ...
                                'Style', 'popupmenu', ...
                                'String', {'BASEQ', 'ZTCFQ', 'DELTAQ'}, ...
                                'FontSize', 11, ...
                                'Position', [10, 720, 200, 25], ...
                                'Callback', @on_dataset_selection_changed);
    
    % Load data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '📂 Load Q-Data', ...
              'FontSize', 11, ...
              'Position', [10, 680, 200, 35], ...
              'Callback', @load_q_data);
    
    % Launch skeleton plotter button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '🦴 Launch Skeleton Plotter', ...
              'FontSize', 11, ...
              'Position', [10, 630, 200, 35], ...
              'Callback', @launch_skeleton_plotter);
    
    % Data status
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Data Status:', ...
              'FontSize', 11, ...
              'FontWeight', 'bold', ...
              'Position', [10, 590, 200, 20], ...
              'HorizontalAlignment', 'left');
    
    data_status_text = uicontrol('Parent', control_panel, ...
                                'Style', 'text', ...
                                'String', 'No Q-data loaded', ...
                                'FontSize', 10, ...
                                'Position', [10, 520, 200, 60], ...
                                'HorizontalAlignment', 'left', ...
                                'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Dataset info panel
    dataset_info_panel = uipanel('Parent', control_panel, ...
                                'Title', 'Dataset Information', ...
                                'FontSize', 10, ...
                                'Position', [0.05, 0.45, 0.9, 0.25]);
    
    dataset_info_text = uicontrol('Parent', dataset_info_panel, ...
                                 'Style', 'text', ...
                                 'String', {'BASEQ: Base swing data', ...
                                           'ZTCFQ: Zero torque counterfactual', ...
                                           'DELTAQ: Difference (BASEQ - ZTCFQ)', ...
                                           '', ...
                                           'Select a dataset to view details.'}, ...
                                 'FontSize', 9, ...
                                 'Position', [10, 10, 180, 120], ...
                                 'HorizontalAlignment', 'left');
    
    % Information panel
    info_panel = uipanel('Parent', control_panel, ...
                        'Title', 'Skeleton Plotter Info', ...
                        'FontSize', 10, ...
                        'Position', [0.05, 0.05, 0.9, 0.35]);
    
    info_text = uicontrol('Parent', info_panel, ...
                         'Style', 'text', ...
                         'String', {'Skeleton Plotter Features:', '', ...
                                   '• 3D visualization of golf swing', ...
                                   '• Interactive playback controls', ...
                                   '• Force and torque vector display', ...
                                   '• Multiple dataset comparison', ...
                                   '• Zoom and camera controls', ...
                                   '• Recording capabilities', ...
                                   '', 'Requires BASEQ, ZTCFQ, DELTAQ data.'}, ...
                         'FontSize', 9, ...
                         'Position', [10, 10, 180, 180], ...
                         'HorizontalAlignment', 'left');
    
    % Store handles
    setappdata(control_panel, 'data_status_text', data_status_text);
    setappdata(control_panel, 'dataset_dropdown', dataset_dropdown);
    setappdata(control_panel, 'dataset_info_text', dataset_info_text);
    
    % Create visualization area
    viz_panel = uipanel('Parent', parent, ...
                       'Title', 'Skeleton Plotter Visualization', ...
                       'FontSize', 12, ...
                       'Position', [0.28, 0.02, 0.7, 0.96]);
    
    % Create placeholder for skeleton plotter
    placeholder_text = uicontrol('Parent', viz_panel, ...
                                'Style', 'text', ...
                                'String', {'Skeleton Plotter', '', ...
                                          'Click "Launch Skeleton Plotter" to open the advanced 3D visualization tool.', ...
                                          '', ...
                                          'This tool provides:', ...
                                          '• Real-time 3D golf swing animation', ...
                                          '• Force and torque vector visualization', ...
                                          '• Interactive playback controls', ...
                                          '• Multiple dataset comparison', ...
                                          '• Advanced camera controls'}, ...
                                'FontSize', 12, ...
                                'Position', [50, 300, 500, 200], ...
                                'HorizontalAlignment', 'center', ...
                                'BackgroundColor', [0.9, 0.9, 0.9]);
    
end

% Callback functions for simulation tab
function update_stop_time(src, ~)
    fprintf('🔄 Updating stop time...\n');
end

function update_max_step(src, ~)
    fprintf('🔄 Updating max step...\n');
end

function update_dampening(src, ~)
    fprintf('🔄 Updating dampening...\n');
end

function update_club_length(src, ~)
    fprintf('🔄 Updating club length...\n');
end

function load_preset(src, ~)
    fprintf('📂 Loading preset...\n');
end

function save_preset(src, ~)
    fprintf('💾 Saving preset...\n');
end

function run_simulation(src, ~)
    fprintf('🚀 Running simulation...\n');
    
    try
        % Get the main figure and config
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        config = getappdata(main_fig, 'config');
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Initializing model...';
            drawnow;
        end
        
        % Initialize model
        fprintf('   Initializing model workspace...\n');
        mdlWks = initialize_model(config);
        
        if ~isempty(progress_text)
            progress_text.String = 'Running base simulation...';
            drawnow;
        end
        
        % Generate base data
        fprintf('   Generating base data...\n');
        BaseData = generate_base_data(config, mdlWks);
        
        if ~isempty(progress_text)
            progress_text.String = 'Generating ZTCF data...';
            drawnow;
        end
        
        % Generate ZTCF data
        fprintf('   Generating ZTCF data...\n');
        ZTCF = generate_ztcf_data(config, mdlWks, BaseData);
        
        if ~isempty(progress_text)
            progress_text.String = 'Processing data tables...';
            drawnow;
        end
        
        % Process data tables
        fprintf('   Processing data tables...\n');
        [BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF);
        
        % Save data
        fprintf('   Saving data tables...\n');
        save_data_tables(config, BASEQ, ZTCFQ, DELTAQ);
        
        % Store data in main figure
        setappdata(main_fig, 'BASEQ', BASEQ);
        setappdata(main_fig, 'ZTCFQ', ZTCFQ);
        setappdata(main_fig, 'DELTAQ', DELTAQ);
        setappdata(main_fig, 'simulation_complete', true);
        
        if ~isempty(progress_text)
            progress_text.String = sprintf('✅ Simulation complete!\n\nBASEQ: %d frames\nZTCFQ: %d frames\nDELTAQ: %d frames', ...
                height(BASEQ), height(ZTCFQ), height(DELTAQ));
        end
        
        fprintf('✅ Simulation completed successfully\n');
        fprintf('   BASEQ: %d frames\n', height(BASEQ));
        fprintf('   ZTCFQ: %d frames\n', height(ZTCFQ));
        fprintf('   DELTAQ: %d frames\n', height(DELTAQ));
        
    catch ME
        fprintf('❌ Simulation failed: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ Simulation failed:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function load_simulation_data(src, ~)
    fprintf('📂 Loading simulation data...\n');
    
    try
        % Get the main figure
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Loading data files...';
            drawnow;
        end
        
        % Try to load data from common locations
        data_loaded = false;
        data_paths = {
            '2DModel/Tables/',
            '3DModel/Tables/',
            'Tables/',
            '../2DModel/Tables/',
            '../3DModel/Tables/',
            '2D GUI/Tables/'
        };
        
        for i = 1:length(data_paths)
            if exist(data_paths{i}, 'dir')
                fprintf('   Checking directory: %s\n', data_paths{i});
                
                % Check if all required files exist
                baseq_file = fullfile(data_paths{i}, 'BASEQ.mat');
                ztcfq_file = fullfile(data_paths{i}, 'ZTCFQ.mat');
                deltaq_file = fullfile(data_paths{i}, 'DELTAQ.mat');
                
                if exist(baseq_file, 'file') && exist(ztcfq_file, 'file') && exist(deltaq_file, 'file')
                    fprintf('   Found data files in: %s\n', data_paths{i});
                    
                    % Load the data
                    load(baseq_file, 'BASEQ');
                    load(ztcfq_file, 'ZTCFQ');
                    load(deltaq_file, 'DELTAQ');
                    
                    % Store the data in the main figure
                    setappdata(main_fig, 'BASEQ', BASEQ);
                    setappdata(main_fig, 'ZTCFQ', ZTCFQ);
                    setappdata(main_fig, 'DELTAQ', DELTAQ);
                    setappdata(main_fig, 'data_loaded', true);
                    
                    data_loaded = true;
                    break;
                end
            end
        end
        
        if data_loaded
            if ~isempty(progress_text)
                progress_text.String = sprintf('✅ Data loaded successfully\n\nBASEQ: %d frames\nZTCFQ: %d frames\nDELTAQ: %d frames', ...
                    height(BASEQ), height(ZTCFQ), height(DELTAQ));
            end
            fprintf('✅ Data loaded successfully\n');
        else
            if ~isempty(progress_text)
                progress_text.String = '❌ Data files not found\n\nPlease run simulation first or ensure data files exist.';
            end
            fprintf('❌ Data files not found in any expected location\n');
        end
        
    catch ME
        fprintf('❌ Error loading data: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ Error loading data:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function play_animation(src, ~)
    fprintf('▶️ Playing animation...\n');
    
    try
        % Get the main figure
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        
        % Check if data is loaded
        data_loaded = getappdata(main_fig, 'data_loaded');
        if ~data_loaded
            fprintf('❌ No data loaded. Please load data first.\n');
            return;
        end
        
        % Get the data
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        % Launch the skeleton plotter for animation
        fprintf('   Launching skeleton plotter for animation...\n');
        GolfSwingVisualizer(BASEQ, ZTCFQ, DELTAQ);
        
        fprintf('✅ Animation launched successfully\n');
        
    catch ME
        fprintf('❌ Error playing animation: %s\n', ME.message);
        rethrow(ME);
    end
end

function stop_animation(src, ~)
    fprintf('⏹️ Stopping animation...\n');
    
    % Find and close skeleton plotter windows
    skeleton_figs = findobj('Name', 'Golf Swing Visualizer');
    if ~isempty(skeleton_figs)
        delete(skeleton_figs);
        fprintf('✅ Animation stopped\n');
    else
        fprintf('ℹ️ No animation running\n');
    end
end

function plot_forces(src, ~)
    fprintf('📊 Plotting forces...\n');
    
    try
        % Get the main figure
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        
        % Check if data is loaded
        data_loaded = getappdata(main_fig, 'data_loaded');
        if ~data_loaded
            fprintf('❌ No data loaded. Please load data first.\n');
            return;
        end
        
        % Get the data
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        % Create force plot
        figure('Name', 'Golf Swing Forces', 'NumberTitle', 'off');
        
        % Plot total hand forces
        subplot(2,1,1);
        plot(BASEQ.Time, vecnorm(BASEQ.TotalHandForceGlobal, 2, 2), 'b-', 'LineWidth', 2);
        hold on;
        plot(ZTCFQ.Time, vecnorm(ZTCFQ.TotalHandForceGlobal, 2, 2), 'r-', 'LineWidth', 2);
        plot(DELTAQ.Time, vecnorm(DELTAQ.TotalHandForceGlobal, 2, 2), 'g-', 'LineWidth', 2);
        xlabel('Time (s)');
        ylabel('Force Magnitude (N)');
        title('Total Hand Force Magnitude');
        legend('BASE', 'ZTCF', 'DELTA', 'Location', 'best');
        grid on;
        
        % Plot force components
        subplot(2,1,2);
        plot(BASEQ.Time, BASEQ.TotalHandForceGlobal(:,1), 'b-', 'LineWidth', 2);
        hold on;
        plot(BASEQ.Time, BASEQ.TotalHandForceGlobal(:,2), 'b--', 'LineWidth', 2);
        plot(BASEQ.Time, BASEQ.TotalHandForceGlobal(:,3), 'b:', 'LineWidth', 2);
        xlabel('Time (s)');
        ylabel('Force (N)');
        title('BASE Force Components (X, Y, Z)');
        legend('X', 'Y', 'Z', 'Location', 'best');
        grid on;
        
        fprintf('✅ Force plots created successfully\n');
        
    catch ME
        fprintf('❌ Error plotting forces: %s\n', ME.message);
        rethrow(ME);
    end
end

function plot_torques(src, ~)
    fprintf('📊 Plotting torques...\n');
    
    try
        % Get the main figure
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        
        % Check if data is loaded
        data_loaded = getappdata(main_fig, 'data_loaded');
        if ~data_loaded
            fprintf('❌ No data loaded. Please load data first.\n');
            return;
        end
        
        % Get the data
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        % Create torque plot
        figure('Name', 'Golf Swing Torques', 'NumberTitle', 'off');
        
        % Plot equivalent midpoint couple
        subplot(2,1,1);
        plot(BASEQ.Time, vecnorm(BASEQ.EquivalentMidpointCoupleGlobal, 2, 2), 'b-', 'LineWidth', 2);
        hold on;
        plot(ZTCFQ.Time, vecnorm(ZTCFQ.EquivalentMidpointCoupleGlobal, 2, 2), 'r-', 'LineWidth', 2);
        plot(DELTAQ.Time, vecnorm(DELTAQ.EquivalentMidpointCoupleGlobal, 2, 2), 'g-', 'LineWidth', 2);
        xlabel('Time (s)');
        ylabel('Torque Magnitude (N⋅m)');
        title('Equivalent Midpoint Couple Magnitude');
        legend('BASE', 'ZTCF', 'DELTA', 'Location', 'best');
        grid on;
        
        % Plot torque components
        subplot(2,1,2);
        plot(BASEQ.Time, BASEQ.EquivalentMidpointCoupleGlobal(:,1), 'b-', 'LineWidth', 2);
        hold on;
        plot(BASEQ.Time, BASEQ.EquivalentMidpointCoupleGlobal(:,2), 'b--', 'LineWidth', 2);
        plot(BASEQ.Time, BASEQ.EquivalentMidpointCoupleGlobal(:,3), 'b:', 'LineWidth', 2);
        xlabel('Time (s)');
        ylabel('Torque (N⋅m)');
        title('BASE Torque Components (X, Y, Z)');
        legend('X', 'Y', 'Z', 'Location', 'best');
        grid on;
        
        fprintf('✅ Torque plots created successfully\n');
        
    catch ME
        fprintf('❌ Error plotting torques: %s\n', ME.message);
        rethrow(ME);
    end
end

function export_simulation_data(src, ~)
    fprintf('💾 Exporting simulation data...\n');
    
    try
        % Get the main figure
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        
        % Check if data is loaded
        data_loaded = getappdata(main_fig, 'data_loaded');
        if ~data_loaded
            fprintf('❌ No data loaded. Please load data first.\n');
            return;
        end
        
        % Get the data
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        % Ask user for export location
        [filename, pathname] = uiputfile('*.mat', 'Save Simulation Data As...', 'golf_swing_data.mat');
        if isequal(filename, 0) || isequal(pathname, 0)
            fprintf('Export cancelled by user\n');
            return;
        end
        
        % Save data
        fullpath = fullfile(pathname, filename);
        save(fullpath, 'BASEQ', 'ZTCFQ', 'DELTAQ');
        
        fprintf('✅ Data exported successfully to: %s\n', fullpath);
        
    catch ME
        fprintf('❌ Error exporting data: %s\n', ME.message);
        rethrow(ME);
    end
end

% Callback functions for analysis tab
function run_complete_analysis(src, ~)
    fprintf('🚀 Running complete analysis...\n');
    
    try
        % Get the main figure and config
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        config = getappdata(main_fig, 'config');
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'analysis_progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Starting complete analysis...';
            drawnow;
        end
        
        % Initialize model
        fprintf('   Initializing model workspace...\n');
        if ~isempty(progress_text)
            progress_text.String = 'Initializing model...';
            drawnow;
        end
        mdlWks = initialize_model(config);
        
        % Generate base data
        fprintf('   Generating base data...\n');
        if ~isempty(progress_text)
            progress_text.String = 'Generating base data...';
            drawnow;
        end
        BaseData = generate_base_data(config, mdlWks);
        
        % Generate ZTCF data
        fprintf('   Generating ZTCF data...\n');
        if ~isempty(progress_text)
            progress_text.String = 'Generating ZTCF data...';
            drawnow;
        end
        ZTCF = generate_ztcf_data(config, mdlWks, BaseData);
        
        % Process data tables
        fprintf('   Processing data tables...\n');
        if ~isempty(progress_text)
            progress_text.String = 'Processing data tables...';
            drawnow;
        end
        [BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF);
        
        % Save data
        fprintf('   Saving data tables...\n');
        if ~isempty(progress_text)
            progress_text.String = 'Saving data tables...';
            drawnow;
        end
        save_data_tables(config, BASEQ, ZTCFQ, DELTAQ);
        
        % Store data in main figure
        setappdata(main_fig, 'BASEQ', BASEQ);
        setappdata(main_fig, 'ZTCFQ', ZTCFQ);
        setappdata(main_fig, 'DELTAQ', DELTAQ);
        setappdata(main_fig, 'analysis_complete', true);
        setappdata(main_fig, 'data_loaded', true);
        
        if ~isempty(progress_text)
            progress_text.String = sprintf('✅ Complete analysis finished!\n\nBASEQ: %d frames\nZTCFQ: %d frames\nDELTAQ: %d frames', ...
                height(BASEQ), height(ZTCFQ), height(DELTAQ));
        end
        
        fprintf('✅ Complete analysis finished successfully\n');
        fprintf('   BASEQ: %d frames\n', height(BASEQ));
        fprintf('   ZTCFQ: %d frames\n', height(ZTCFQ));
        fprintf('   DELTAQ: %d frames\n', height(DELTAQ));
        
    catch ME
        fprintf('❌ Complete analysis failed: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ Analysis failed:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function load_analysis_data(src, ~)
    fprintf('📂 Loading analysis data...\n');
    
    try
        % Get the main figure
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'analysis_progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Loading analysis data...';
            drawnow;
        end
        
        % Try to load data from common locations
        data_loaded = false;
        data_paths = {
            '2DModel/Tables/',
            '3DModel/Tables/',
            'Tables/',
            '../2DModel/Tables/',
            '../3DModel/Tables/',
            '2D GUI/Tables/'
        };
        
        for i = 1:length(data_paths)
            if exist(data_paths{i}, 'dir')
                fprintf('   Checking directory: %s\n', data_paths{i});
                
                % Check if all required files exist
                baseq_file = fullfile(data_paths{i}, 'BASEQ.mat');
                ztcfq_file = fullfile(data_paths{i}, 'ZTCFQ.mat');
                deltaq_file = fullfile(data_paths{i}, 'DELTAQ.mat');
                
                if exist(baseq_file, 'file') && exist(ztcfq_file, 'file') && exist(deltaq_file, 'file')
                    fprintf('   Found analysis data in: %s\n', data_paths{i});
                    
                    % Load the data
                    load(baseq_file, 'BASEQ');
                    load(ztcfq_file, 'ZTCFQ');
                    load(deltaq_file, 'DELTAQ');
                    
                    % Store the data in the main figure
                    setappdata(main_fig, 'BASEQ', BASEQ);
                    setappdata(main_fig, 'ZTCFQ', ZTCFQ);
                    setappdata(main_fig, 'DELTAQ', DELTAQ);
                    setappdata(main_fig, 'data_loaded', true);
                    setappdata(main_fig, 'analysis_complete', true);
                    
                    data_loaded = true;
                    break;
                end
            end
        end
        
        if data_loaded
            if ~isempty(progress_text)
                progress_text.String = sprintf('✅ Analysis data loaded\n\nBASEQ: %d frames\nZTCFQ: %d frames\nDELTAQ: %d frames', ...
                    height(BASEQ), height(ZTCFQ), height(DELTAQ));
            end
            fprintf('✅ Analysis data loaded successfully\n');
        else
            if ~isempty(progress_text)
                progress_text.String = '❌ Analysis data not found\n\nPlease run complete analysis first.';
            end
            fprintf('❌ Analysis data not found in any expected location\n');
        end
        
    catch ME
        fprintf('❌ Error loading analysis data: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ Error loading data:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function generate_base_data(src, ~)
    fprintf('📊 Generating base data...\n');
    
    try
        % Get the main figure and config
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        config = getappdata(main_fig, 'config');
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'analysis_progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Generating base data...';
            drawnow;
        end
        
        % Initialize model
        fprintf('   Initializing model workspace...\n');
        mdlWks = initialize_model(config);
        
        % Generate base data
        fprintf('   Running base simulation...\n');
        BaseData = generate_base_data(config, mdlWks);
        
        % Store base data
        setappdata(main_fig, 'BaseData', BaseData);
        
        if ~isempty(progress_text)
            progress_text.String = sprintf('✅ Base data generated\n\nData points: %d\nTime range: %.3f to %.3f s', ...
                height(BaseData), BaseData.Time(1), BaseData.Time(end));
        end
        
        fprintf('✅ Base data generated successfully\n');
        fprintf('   Data points: %d\n', height(BaseData));
        fprintf('   Time range: %.3f to %.3f seconds\n', BaseData.Time(1), BaseData.Time(end));
        
    catch ME
        fprintf('❌ Error generating base data: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ Base data generation failed:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function generate_ztcf_data(src, ~)
    fprintf('🔄 Generating ZTCF data...\n');
    
    try
        % Get the main figure and config
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        config = getappdata(main_fig, 'config');
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'analysis_progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Generating ZTCF data...';
            drawnow;
        end
        
        % Check if base data exists
        BaseData = getappdata(main_fig, 'BaseData');
        if isempty(BaseData)
            fprintf('❌ No base data found. Please generate base data first.\n');
            if ~isempty(progress_text)
                progress_text.String = '❌ No base data found.\nPlease generate base data first.';
            end
            return;
        end
        
        % Initialize model
        fprintf('   Initializing model workspace...\n');
        mdlWks = initialize_model(config);
        
        % Generate ZTCF data
        fprintf('   Running ZTCF analysis...\n');
        ZTCF = generate_ztcf_data(config, mdlWks, BaseData);
        
        % Store ZTCF data
        setappdata(main_fig, 'ZTCF', ZTCF);
        
        if ~isempty(progress_text)
            progress_text.String = sprintf('✅ ZTCF data generated\n\nZTCF data points: %d', height(ZTCF));
        end
        
        fprintf('✅ ZTCF data generated successfully\n');
        fprintf('   ZTCF data points: %d\n', height(ZTCF));
        
    catch ME
        fprintf('❌ Error generating ZTCF data: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ ZTCF data generation failed:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function generate_zvcf_data(src, ~)
    fprintf('📈 Generating ZVCF data...\n');
    
    try
        % Get the main figure and config
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        config = getappdata(main_fig, 'config');
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'analysis_progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Generating ZVCF data...';
            drawnow;
        end
        
        % Check if base data exists
        BaseData = getappdata(main_fig, 'BaseData');
        if isempty(BaseData)
            fprintf('❌ No base data found. Please generate base data first.\n');
            if ~isempty(progress_text)
                progress_text.String = '❌ No base data found.\nPlease generate base data first.';
            end
            return;
        end
        
        % Initialize model
        fprintf('   Initializing model workspace...\n');
        mdlWks = initialize_model(config);
        
        % Generate ZVCF data (similar to ZTCF but with different parameters)
        fprintf('   Running ZVCF analysis...\n');
        ZVCF = generate_ztcf_data(config, mdlWks, BaseData); % Using same function for now
        
        % Store ZVCF data
        setappdata(main_fig, 'ZVCF', ZVCF);
        
        if ~isempty(progress_text)
            progress_text.String = sprintf('✅ ZVCF data generated\n\nZVCF data points: %d', height(ZVCF));
        end
        
        fprintf('✅ ZVCF data generated successfully\n');
        fprintf('   ZVCF data points: %d\n', height(ZVCF));
        
    catch ME
        fprintf('❌ Error generating ZVCF data: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ ZVCF data generation failed:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

function process_data_tables(src, ~)
    fprintf('⚙️ Processing data tables...\n');
    
    try
        % Get the main figure and config
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            main_fig = findobj('Type', 'figure');
            main_fig = main_fig(1);
        end
        config = getappdata(main_fig, 'config');
        
        % Get progress text
        progress_text = findobj(main_fig, 'Tag', 'analysis_progress_text');
        if ~isempty(progress_text)
            progress_text.String = 'Processing data tables...';
            drawnow;
        end
        
        % Check if required data exists
        BaseData = getappdata(main_fig, 'BaseData');
        ZTCF = getappdata(main_fig, 'ZTCF');
        
        if isempty(BaseData) || isempty(ZTCF)
            fprintf('❌ Missing required data. Please generate base and ZTCF data first.\n');
            if ~isempty(progress_text)
                progress_text.String = '❌ Missing required data.\nPlease generate base and ZTCF data first.';
            end
            return;
        end
        
        % Process data tables
        fprintf('   Processing BASEQ, ZTCFQ, DELTAQ...\n');
        [BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF);
        
        % Store processed data
        setappdata(main_fig, 'BASEQ', BASEQ);
        setappdata(main_fig, 'ZTCFQ', ZTCFQ);
        setappdata(main_fig, 'DELTAQ', DELTAQ);
        setappdata(main_fig, 'data_loaded', true);
        
        if ~isempty(progress_text)
            progress_text.String = sprintf('✅ Data tables processed\n\nBASEQ: %d frames\nZTCFQ: %d frames\nDELTAQ: %d frames', ...
                height(BASEQ), height(ZTCFQ), height(DELTAQ));
        end
        
        fprintf('✅ Data tables processed successfully\n');
        fprintf('   BASEQ: %d frames\n', height(BASEQ));
        fprintf('   ZTCFQ: %d frames\n', height(ZTCFQ));
        fprintf('   DELTAQ: %d frames\n', height(DELTAQ));
        
    catch ME
        fprintf('❌ Error processing data tables: %s\n', ME.message);
        if ~isempty(progress_text)
            progress_text.String = sprintf('❌ Data table processing failed:\n%s', ME.message);
        end
        rethrow(ME);
    end
end

% Callback functions for skeleton plotter tab
function load_q_data(src, ~)
    fprintf('📂 Loading Q-data...\n');
    
    try
        % Get the control panel and its handles
        control_panel = src.Parent;
        data_status_text = getappdata(control_panel, 'data_status_text');
        dataset_dropdown = getappdata(control_panel, 'dataset_dropdown');
        
        % Update status
        data_status_text.String = 'Loading Q-data...';
        drawnow;
        
        % Try to load data from common locations
        data_loaded = false;
        data_paths = {
            '2DModel/Tables/',
            '3DModel/Tables/',
            'Tables/',
            '../2DModel/Tables/',
            '../3DModel/Tables/'
        };
        
        for i = 1:length(data_paths)
            if exist(data_paths{i}, 'dir')
                fprintf('Checking directory: %s\n', data_paths{i});
                
                % Check if all required files exist
                baseq_file = fullfile(data_paths{i}, 'BASEQ.mat');
                ztcfq_file = fullfile(data_paths{i}, 'ZTCFQ.mat');
                deltaq_file = fullfile(data_paths{i}, 'DELTAQ.mat');
                
                if exist(baseq_file, 'file') && exist(ztcfq_file, 'file') && exist(deltaq_file, 'file')
                    fprintf('Found Q-data files in: %s\n', data_paths{i});
                    
                    % Load the data
                    load(baseq_file, 'BASEQ');
                    load(ztcfq_file, 'ZTCFQ');
                    load(deltaq_file, 'DELTAQ');
                    
                    % Store the data in the control panel
                    setappdata(control_panel, 'BASEQ', BASEQ);
                    setappdata(control_panel, 'ZTCFQ', ZTCFQ);
                    setappdata(control_panel, 'DELTAQ', DELTAQ);
                    setappdata(control_panel, 'data_loaded', true);
                    
                    data_loaded = true;
                    break;
                end
            end
        end
        
        if data_loaded
            % Update status with success message
            data_status_text.String = sprintf('✅ Q-data loaded successfully\n\nBASEQ: %d frames\nZTCFQ: %d frames\nDELTAQ: %d frames', ...
                height(BASEQ), height(ZTCFQ), height(DELTAQ));
            
            % Update dataset dropdown to show current selection
            on_dataset_selection_changed(dataset_dropdown, []);
            
            fprintf('✅ Q-data loaded successfully\n');
        else
            % Update status with error message
            data_status_text.String = '❌ Q-data not found\n\nPlease ensure BASEQ.mat, ZTCFQ.mat, and DELTAQ.mat files exist in the Tables directory.';
            setappdata(control_panel, 'data_loaded', false);
            fprintf('❌ Q-data not found in any expected location\n');
        end
        
    catch ME
        % Update status with error message
        data_status_text.String = sprintf('❌ Error loading Q-data:\n%s', ME.message);
        setappdata(control_panel, 'data_loaded', false);
        fprintf('❌ Error loading Q-data: %s\n', ME.message);
    end
end

function launch_skeleton_plotter(src, ~)
    fprintf('🦴 Launching skeleton plotter...\n');
    
    try
        % Get the control panel and its handles
        control_panel = src.Parent;
        data_loaded = getappdata(control_panel, 'data_loaded');
        
        if ~data_loaded
            fprintf('❌ No Q-data loaded. Please load Q-data first.\n');
            return;
        end
        
        % Get the selected dataset
        dataset_dropdown = getappdata(control_panel, 'dataset_dropdown');
        selected_dataset = dataset_dropdown.String{dataset_dropdown.Value};
        
        % Get the loaded data
        BASEQ = getappdata(control_panel, 'BASEQ');
        ZTCFQ = getappdata(control_panel, 'ZTCFQ');
        DELTAQ = getappdata(control_panel, 'DELTAQ');
        
        fprintf('🦴 Launching GolfSwingVisualizer with %s dataset...\n', selected_dataset);
        
        % Launch the GolfSwingVisualizer (your MATLAB Exchange version)
        % This will handle all the visualization including dataset selection
        GolfSwingVisualizer(BASEQ, ZTCFQ, DELTAQ);
        
        fprintf('✅ GolfSwingVisualizer launched successfully\n');
        
    catch ME
        fprintf('❌ Error launching GolfSwingVisualizer: %s\n', ME.message);
        % Show error dialog
        errordlg(sprintf('Error launching GolfSwingVisualizer:\n%s', ME.message), 'GolfSwingVisualizer Error');
    end
end

function on_dataset_selection_changed(src, ~)
    selected_dataset = src.String{src.Value};
    dataset_info_text = getappdata(src.Parent, 'dataset_info_text');
    
    if strcmp(selected_dataset, 'BASEQ')
        dataset_info_text.String = {'BASEQ: Base swing data', '', ...
                                   '• Raw kinematic data from the golf swing', ...
                                   '• Includes joint angles, positions, velocities, and accelerations', ...
                                   '• Used for baseline analysis and comparison', ...
                                   '• Primary dataset for swing analysis', ...
                                   '', 'Requires BASEQ data.'};
    elseif strcmp(selected_dataset, 'ZTCFQ')
        dataset_info_text.String = {'ZTCFQ: Zero torque counterfactual', '', ...
                                   '• Simulated data where all joint torques are zero', ...
                                   '• Used to isolate the effect of joint torques on kinematics', ...
                                   '• Provides a null hypothesis for joint torque effects', ...
                                   '• Shows passive swing dynamics', ...
                                   '', 'Requires ZTCFQ data.'};
    elseif strcmp(selected_dataset, 'DELTAQ')
        dataset_info_text.String = {'DELTAQ: Difference (BASEQ - ZTCFQ)', '', ...
                                   '• Calculated as BASEQ - ZTCFQ', ...
                                   '• Shows the effect of joint torques on kinematics', ...
                                   '• Provides a measure of joint torque influence', ...
                                   '• Highlights active vs passive contributions', ...
                                   '', 'Requires BASEQ and ZTCFQ data.'};
    end
    dataset_info_text.Visible = 'on';
end

% Real plotting functions for the Plots & Interaction tab
function create_time_series_panel(parent, config)
    % Create real time series plots panel
    
    % Create control panel on the left
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Time Series Controls', ...
                           'FontSize', 11, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Dataset selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Dataset:', ...
              'FontSize', 10, ...
              'Position', [10, 700, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    dataset_popup = uicontrol('Parent', control_panel, ...
                             'Style', 'popupmenu', ...
                             'String', {'BASEQ', 'ZTCFQ', 'DELTAQ'}, ...
                             'Value', 1, ...
                             'Position', [10, 670, 120, 25], ...
                             'Callback', @(src,~) update_time_series_plot(src, plot_axes));
    
    % Variable selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Variable:', ...
              'FontSize', 10, ...
              'Position', [10, 630, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    variable_popup = uicontrol('Parent', control_panel, ...
                              'Style', 'popupmenu', ...
                              'String', {'Select variable...'}, ...
                              'Value', 1, ...
                              'Position', [10, 600, 120, 25], ...
                              'Callback', @(src,~) update_time_series_plot(dataset_popup, plot_axes));
    
    % Plot type selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Plot Type:', ...
              'FontSize', 10, ...
              'Position', [10, 560, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    plot_type_popup = uicontrol('Parent', control_panel, ...
                               'Style', 'popupmenu', ...
                               'String', {'Single Variable', 'Multiple Variables', 'All Variables'}, ...
                               'Value', 1, ...
                               'Position', [10, 530, 120, 25], ...
                               'Callback', @(src,~) update_time_series_plot(dataset_popup, plot_axes));
    
    % Load data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Load Data', ...
              'FontSize', 10, ...
              'Position', [10, 480, 120, 30], ...
              'Callback', @(src,~) load_data_for_plots(src, dataset_popup, variable_popup));
    
    % Plot button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Generate Plot', ...
              'FontSize', 10, ...
              'Position', [10, 440, 120, 30], ...
              'Callback', @(src,~) update_time_series_plot(dataset_popup, plot_axes));
    
    % Export button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Export Plot', ...
              'FontSize', 10, ...
              'Position', [10, 400, 120, 30], ...
              'Callback', @export_time_series_plot);
    
    % Create plot area on the right
    plot_panel = uipanel('Parent', parent, ...
                        'Title', 'Time Series Plot', ...
                        'FontSize', 11, ...
                        'Position', [0.28, 0.02, 0.7, 0.96]);
    
    plot_axes = axes('Parent', plot_panel, ...
                    'Position', [0.1, 0.1, 0.85, 0.85]);
    
    % Store handles for callbacks
    setappdata(control_panel, 'dataset_popup', dataset_popup);
    setappdata(control_panel, 'variable_popup', variable_popup);
    setappdata(control_panel, 'plot_type_popup', plot_type_popup);
    setappdata(control_panel, 'plot_axes', plot_axes);
    
    % Initialize plot
    title(plot_axes, 'Time Series Plot', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel(plot_axes, 'Time (s)', 'FontSize', 12);
    ylabel(plot_axes, 'Value', 'FontSize', 12);
    grid(plot_axes, 'on');
end

function create_phase_plots_panel(parent, config)
    % Create real phase plots panel
    
    % Create control panel on the left
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Phase Plot Controls', ...
                           'FontSize', 11, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % X-axis variable selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'X-Axis Variable:', ...
              'FontSize', 10, ...
              'Position', [10, 700, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    x_var_popup = uicontrol('Parent', control_panel, ...
                           'Style', 'popupmenu', ...
                           'String', {'Select variable...'}, ...
                           'Value', 1, ...
                           'Position', [10, 670, 120, 25]);
    
    % Y-axis variable selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Y-Axis Variable:', ...
              'FontSize', 10, ...
              'Position', [10, 630, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    y_var_popup = uicontrol('Parent', control_panel, ...
                           'Style', 'popupmenu', ...
                           'String', {'Select variable...'}, ...
                           'Value', 1, ...
                           'Position', [10, 600, 120, 25]);
    
    % Dataset selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Dataset:', ...
              'FontSize', 10, ...
              'Position', [10, 560, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    dataset_popup = uicontrol('Parent', control_panel, ...
                             'Style', 'popupmenu', ...
                             'String', {'BASEQ', 'ZTCFQ', 'DELTAQ'}, ...
                             'Value', 1, ...
                             'Position', [10, 530, 120, 25]);
    
    % Plot options
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Plot Options:', ...
              'FontSize', 10, ...
              'Position', [10, 490, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    show_trajectory_checkbox = uicontrol('Parent', control_panel, ...
                                       'Style', 'checkbox', ...
                                       'String', 'Show Trajectory', ...
                                       'Value', 1, ...
                                       'Position', [10, 460, 120, 20]);
    
    show_points_checkbox = uicontrol('Parent', control_panel, ...
                                   'Style', 'checkbox', ...
                                   'String', 'Show Points', ...
                                   'Value', 1, ...
                                   'Position', [10, 430, 120, 20]);
    
    % Load data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Load Data', ...
              'FontSize', 10, ...
              'Position', [10, 380, 120, 30], ...
              'Callback', @(src,~) load_data_for_phase_plots(src, x_var_popup, y_var_popup));
    
    % Generate plot button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Generate Plot', ...
              'FontSize', 10, ...
              'Position', [10, 340, 120, 30], ...
              'Callback', @(src,~) generate_phase_plot(src, x_var_popup, y_var_popup, dataset_popup, show_trajectory_checkbox, show_points_checkbox, plot_axes));
    
    % Export button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Export Plot', ...
              'FontSize', 10, ...
              'Position', [10, 300, 120, 30], ...
              'Callback', @export_phase_plot);
    
    % Create plot area on the right
    plot_panel = uipanel('Parent', parent, ...
                        'Title', 'Phase Plot', ...
                        'FontSize', 11, ...
                        'Position', [0.28, 0.02, 0.7, 0.96]);
    
    plot_axes = axes('Parent', plot_panel, ...
                    'Position', [0.1, 0.1, 0.85, 0.85]);
    
    % Store handles for callbacks
    setappdata(control_panel, 'x_var_popup', x_var_popup);
    setappdata(control_panel, 'y_var_popup', y_var_popup);
    setappdata(control_panel, 'dataset_popup', dataset_popup);
    setappdata(control_panel, 'plot_axes', plot_axes);
    
    % Initialize plot
    title(plot_axes, 'Phase Plot', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel(plot_axes, 'X Variable', 'FontSize', 12);
    ylabel(plot_axes, 'Y Variable', 'FontSize', 12);
    grid(plot_axes, 'on');
end

function create_quiver_plots_panel(parent, config)
    % Create real quiver plots panel
    
    % Create control panel on the left
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Quiver Plot Controls', ...
                           'FontSize', 11, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Vector type selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Vector Type:', ...
              'FontSize', 10, ...
              'Position', [10, 700, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    vector_type_popup = uicontrol('Parent', control_panel, ...
                                 'Style', 'popupmenu', ...
                                 'String', {'Forces', 'Torques', 'Velocities', 'Accelerations'}, ...
                                 'Value', 1, ...
                                 'Position', [10, 670, 120, 25]);
    
    % Dataset selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Dataset:', ...
              'FontSize', 10, ...
              'Position', [10, 630, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    dataset_popup = uicontrol('Parent', control_panel, ...
                             'Style', 'popupmenu', ...
                             'String', {'BASEQ', 'ZTCFQ', 'DELTAQ'}, ...
                             'Value', 1, ...
                             'Position', [10, 600, 120, 25]);
    
    % Time point selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Time Point:', ...
              'FontSize', 10, ...
              'Position', [10, 560, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    time_slider = uicontrol('Parent', control_panel, ...
                           'Style', 'slider', ...
                           'Min', 0, 'Max', 1, 'Value', 0.5, ...
                           'Position', [10, 530, 120, 20]);
    
    time_text = uicontrol('Parent', control_panel, ...
                         'Style', 'text', ...
                         'String', '0.14 s', ...
                         'FontSize', 9, ...
                         'Position', [10, 500, 120, 20], ...
                         'HorizontalAlignment', 'center');
    
    % Plot options
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Plot Options:', ...
              'FontSize', 10, ...
              'Position', [10, 460, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    show_magnitude_checkbox = uicontrol('Parent', control_panel, ...
                                      'Style', 'checkbox', ...
                                      'String', 'Show Magnitude', ...
                                      'Value', 1, ...
                                      'Position', [10, 430, 120, 20]);
    
    scale_vectors_checkbox = uicontrol('Parent', control_panel, ...
                                     'Style', 'checkbox', ...
                                     'String', 'Scale Vectors', ...
                                     'Value', 1, ...
                                     'Position', [10, 400, 120, 20]);
    
    % Load data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Load Data', ...
              'FontSize', 10, ...
              'Position', [10, 350, 120, 30], ...
              'Callback', @(src,~) load_data_for_quiver_plots(src));
    
    % Generate plot button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Generate Plot', ...
              'FontSize', 10, ...
              'Position', [10, 310, 120, 30], ...
              'Callback', @(src,~) generate_quiver_plot(src, vector_type_popup, dataset_popup, time_slider, time_text, show_magnitude_checkbox, scale_vectors_checkbox, plot_axes));
    
    % Export button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Export Plot', ...
              'FontSize', 10, ...
              'Position', [10, 270, 120, 30], ...
              'Callback', @export_quiver_plot);
    
    % Create plot area on the right
    plot_panel = uipanel('Parent', parent, ...
                        'Title', 'Quiver Plot', ...
                        'FontSize', 11, ...
                        'Position', [0.28, 0.02, 0.7, 0.96]);
    
    plot_axes = axes('Parent', plot_panel, ...
                    'Position', [0.1, 0.1, 0.85, 0.85]);
    
    % Store handles for callbacks
    setappdata(control_panel, 'vector_type_popup', vector_type_popup);
    setappdata(control_panel, 'dataset_popup', dataset_popup);
    setappdata(control_panel, 'time_slider', time_slider);
    setappdata(control_panel, 'time_text', time_text);
    setappdata(control_panel, 'plot_axes', plot_axes);
    
    % Initialize plot
    title(plot_axes, 'Quiver Plot', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel(plot_axes, 'X Position', 'FontSize', 12);
    ylabel(plot_axes, 'Y Position', 'FontSize', 12);
    zlabel(plot_axes, 'Z Position', 'FontSize', 12);
    grid(plot_axes, 'on');
    view(plot_axes, 3);
end

function create_comparison_panel(parent, config)
    % Create real comparison panel
    
    % Create control panel on the left
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Comparison Controls', ...
                           'FontSize', 11, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Variable selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Variable:', ...
              'FontSize', 10, ...
              'Position', [10, 700, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    variable_popup = uicontrol('Parent', control_panel, ...
                              'Style', 'popupmenu', ...
                              'String', {'Select variable...'}, ...
                              'Value', 1, ...
                              'Position', [10, 670, 120, 25]);
    
    % Comparison type
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Comparison:', ...
              'FontSize', 10, ...
              'Position', [10, 630, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    comparison_popup = uicontrol('Parent', control_panel, ...
                                'Style', 'popupmenu', ...
                                'String', {'BASEQ vs ZTCFQ', 'BASEQ vs DELTAQ', 'ZTCFQ vs DELTAQ', 'All Three'}, ...
                                'Value', 1, ...
                                'Position', [10, 600, 120, 25]);
    
    % Plot type
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Plot Type:', ...
              'FontSize', 10, ...
              'Position', [10, 560, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    plot_type_popup = uicontrol('Parent', control_panel, ...
                               'Style', 'popupmenu', ...
                               'String', {'Overlay', 'Subplot', 'Difference'}, ...
                               'Value', 1, ...
                               'Position', [10, 530, 120, 25]);
    
    % Load data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Load Data', ...
              'FontSize', 10, ...
              'Position', [10, 480, 120, 30], ...
              'Callback', @(src,~) load_data_for_comparison(src, variable_popup));
    
    % Generate comparison button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Generate Comparison', ...
              'FontSize', 10, ...
              'Position', [10, 440, 120, 30], ...
              'Callback', @(src,~) generate_comparison_plot(src, variable_popup, comparison_popup, plot_type_popup, plot_axes));
    
    % Export button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Export Plot', ...
              'FontSize', 10, ...
              'Position', [10, 400, 120, 30], ...
              'Callback', @export_comparison_plot);
    
    % Create plot area on the right
    plot_panel = uipanel('Parent', parent, ...
                        'Title', 'Comparison Plot', ...
                        'FontSize', 11, ...
                        'Position', [0.28, 0.02, 0.7, 0.96]);
    
    plot_axes = axes('Parent', plot_panel, ...
                    'Position', [0.1, 0.1, 0.85, 0.85]);
    
    % Store handles for callbacks
    setappdata(control_panel, 'variable_popup', variable_popup);
    setappdata(control_panel, 'comparison_popup', comparison_popup);
    setappdata(control_panel, 'plot_type_popup', plot_type_popup);
    setappdata(control_panel, 'plot_axes', plot_axes);
    
    % Initialize plot
    title(plot_axes, 'Comparison Plot', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel(plot_axes, 'Time (s)', 'FontSize', 12);
    ylabel(plot_axes, 'Value', 'FontSize', 12);
    grid(plot_axes, 'on');
end

function create_data_explorer_panel(parent, config)
    % Create real data explorer panel
    
    % Create control panel on the left
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Data Explorer Controls', ...
                           'FontSize', 11, ...
                           'Position', [0.02, 0.02, 0.25, 0.96]);
    
    % Dataset selection
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Dataset:', ...
              'FontSize', 10, ...
              'Position', [10, 700, 80, 20], ...
              'HorizontalAlignment', 'left');
    
    dataset_popup = uicontrol('Parent', control_panel, ...
                             'Style', 'popupmenu', ...
                             'String', {'BASEQ', 'ZTCFQ', 'DELTAQ'}, ...
                             'Value', 1, ...
                             'Position', [10, 670, 120, 25], ...
                             'Callback', @(src,~) update_data_explorer(src, data_table, stats_text));
    
    % Load data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Load Data', ...
              'FontSize', 10, ...
              'Position', [10, 620, 120, 30], ...
              'Callback', @(src,~) load_data_for_explorer(src, dataset_popup, data_table, stats_text));
    
    % Export data button
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Export Data', ...
              'FontSize', 10, ...
              'Position', [10, 580, 120, 30], ...
              'Callback', @export_explorer_data);
    
    % Filter controls
    uicontrol('Parent', control_panel, ...
              'Style', 'text', ...
              'String', 'Filter Options:', ...
              'FontSize', 10, ...
              'Position', [10, 530, 100, 20], ...
              'HorizontalAlignment', 'left');
    
    filter_var_popup = uicontrol('Parent', control_panel, ...
                                'Style', 'popupmenu', ...
                                'String', {'All Variables'}, ...
                                'Value', 1, ...
                                'Position', [10, 500, 120, 25]);
    
    filter_min_edit = uicontrol('Parent', control_panel, ...
                               'Style', 'edit', ...
                               'String', 'Min', ...
                               'Position', [10, 470, 50, 25]);
    
    filter_max_edit = uicontrol('Parent', control_panel, ...
                               'Style', 'edit', ...
                               'String', 'Max', ...
                               'Position', [70, 470, 50, 25]);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', 'Apply Filter', ...
              'FontSize', 9, ...
              'Position', [10, 430, 120, 25], ...
              'Callback', @(src,~) apply_data_filter(src, filter_var_popup, filter_min_edit, filter_max_edit, data_table));
    
    % Create data display area on the right
    data_panel = uipanel('Parent', parent, ...
                        'Title', 'Data Explorer', ...
                        'FontSize', 11, ...
                        'Position', [0.28, 0.02, 0.7, 0.96]);
    
    % Data table
    data_table = uitable('Parent', data_panel, ...
                        'Position', [20, 200, 600, 400], ...
                        'ColumnName', {'Variable', 'Min', 'Max', 'Mean', 'Std', 'Range'}, ...
                        'Data', cell(0, 6), ...
                        'ColumnWidth', {150, 80, 80, 80, 80, 80});
    
    % Statistics text
    stats_text = uicontrol('Parent', data_panel, ...
                          'Style', 'text', ...
                          'String', 'Data Statistics: Load data to view statistics', ...
                          'FontSize', 10, ...
                          'Position', [20, 20, 600, 160], ...
                          'HorizontalAlignment', 'left', ...
                          'BackgroundColor', [0.95, 0.95, 0.95]);
    
    % Store handles for callbacks
    setappdata(control_panel, 'dataset_popup', dataset_popup);
    setappdata(control_panel, 'data_table', data_table);
    setappdata(control_panel, 'stats_text', stats_text);
end

% ============================================================================
% CALLBACK FUNCTIONS FOR PLOTS & INTERACTION TAB
% ============================================================================

% Time Series Plot Callbacks
function load_data_for_plots(src, dataset_popup, variable_popup)
    try
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            errordlg('Main GUI not found. Please launch the GUI first.', 'Error');
            return;
        end
        
        % Get data from main GUI
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            % Try to load from files
            [BASEQ, ZTCFQ, DELTAQ] = load_data_from_files();
        end
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please run simulation or analysis first.', 'Error');
            return;
        end
        
        % Store data in the control panel
        control_panel = src.Parent;
        setappdata(control_panel, 'BASEQ', BASEQ);
        setappdata(control_panel, 'ZTCFQ', ZTCFQ);
        setappdata(control_panel, 'DELTAQ', DELTAQ);
        
        % Update variable popup with available variables
        update_variable_popup(variable_popup, BASEQ);
        
        msgbox('Data loaded successfully!', 'Success');
        
    catch ME
        errordlg(sprintf('Error loading data: %s', ME.message), 'Error');
    end
end

function update_time_series_plot(dataset_popup, plot_axes)
    try
        control_panel = dataset_popup.Parent;
        BASEQ = getappdata(control_panel, 'BASEQ');
        ZTCFQ = getappdata(control_panel, 'ZTCFQ');
        DELTAQ = getappdata(control_panel, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please load data first.', 'Error');
            return;
        end
        
        % Get selected dataset
        dataset_names = dataset_popup.String;
        selected_dataset = dataset_names{dataset_popup.Value};
        
        % Get selected variable and plot type
        variable_popup = getappdata(control_panel, 'variable_popup');
        plot_type_popup = getappdata(control_panel, 'plot_type_popup');
        
        variable_names = variable_popup.String;
        selected_variable = variable_names{variable_popup.Value};
        plot_type_names = plot_type_popup.String;
        selected_plot_type = plot_type_names{plot_type_popup.Value};
        
        % Select data based on dataset
        switch selected_dataset
            case 'BASEQ'
                data = BASEQ;
            case 'ZTCFQ'
                data = ZTCFQ;
            case 'DELTAQ'
                data = DELTAQ;
            otherwise
                errordlg('Invalid dataset selection.', 'Error');
                return;
        end
        
        if isempty(data)
            errordlg(sprintf('No data available for %s.', selected_dataset), 'Error');
            return;
        end
        
        % Generate plot based on type
        cla(plot_axes);
        hold(plot_axes, 'on');
        
        switch selected_plot_type
            case 'Single Variable'
                if strcmp(selected_variable, 'Select variable...')
                    errordlg('Please select a variable.', 'Error');
                    return;
                end
                if ismember(selected_variable, data.Properties.VariableNames)
                    plot(plot_axes, data.Time, data.(selected_variable), 'LineWidth', 2);
                    title(plot_axes, sprintf('%s: %s', selected_dataset, selected_variable), 'FontSize', 14, 'FontWeight', 'bold');
                    ylabel(plot_axes, selected_variable, 'FontSize', 12);
                else
                    errordlg(sprintf('Variable %s not found in data.', selected_variable), 'Error');
                    return;
                end
                
            case 'Multiple Variables'
                % Plot first few numeric variables
                numeric_vars = varfun(@isnumeric, data, 'OutputFormat', 'cell');
                numeric_vars = data.Properties.VariableNames(numeric_vars);
                numeric_vars = setdiff(numeric_vars, 'Time');
                
                if length(numeric_vars) >= 3
                    plot_vars = numeric_vars(1:3);
                    colors = {'b', 'r', 'g'};
                    for i = 1:length(plot_vars)
                        plot(plot_axes, data.Time, data.(plot_vars{i}), colors{i}, 'LineWidth', 2, 'DisplayName', plot_vars{i});
                    end
                    legend(plot_axes, 'show');
                    title(plot_axes, sprintf('%s: Multiple Variables', selected_dataset), 'FontSize', 14, 'FontWeight', 'bold');
                    ylabel(plot_axes, 'Value', 'FontSize', 12);
                else
                    errordlg('Not enough numeric variables for multiple plot.', 'Error');
                    return;
                end
                
            case 'All Variables'
                % Plot all numeric variables
                numeric_vars = varfun(@isnumeric, data, 'OutputFormat', 'cell');
                numeric_vars = data.Properties.VariableNames(numeric_vars);
                numeric_vars = setdiff(numeric_vars, 'Time');
                
                if ~isempty(numeric_vars)
                    colors = lines(length(numeric_vars));
                    for i = 1:length(numeric_vars)
                        plot(plot_axes, data.Time, data.(numeric_vars{i}), 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', numeric_vars{i});
                    end
                    legend(plot_axes, 'show', 'Location', 'eastoutside');
                    title(plot_axes, sprintf('%s: All Variables', selected_dataset), 'FontSize', 14, 'FontWeight', 'bold');
                    ylabel(plot_axes, 'Value', 'FontSize', 12);
                else
                    errordlg('No numeric variables found in data.', 'Error');
                    return;
                end
        end
        
        xlabel(plot_axes, 'Time (s)', 'FontSize', 12);
        grid(plot_axes, 'on');
        hold(plot_axes, 'off');
        
    catch ME
        errordlg(sprintf('Error generating time series plot: %s', ME.message), 'Error');
    end
end

function export_time_series_plot(src, ~)
    try
        control_panel = src.Parent;
        plot_axes = getappdata(control_panel, 'plot_axes');
        
        [filename, pathname] = uiputfile({'*.png', 'PNG Image'; '*.jpg', 'JPEG Image'; '*.pdf', 'PDF Document'; '*.fig', 'MATLAB Figure'}, 'Export Time Series Plot');
        
        if filename ~= 0
            full_path = fullfile(pathname, filename);
            saveas(plot_axes, full_path);
            msgbox(sprintf('Plot exported to: %s', full_path), 'Success');
        end
        
    catch ME
        errordlg(sprintf('Error exporting plot: %s', ME.message), 'Error');
    end
end

% Phase Plot Callbacks
function load_data_for_phase_plots(src, x_var_popup, y_var_popup)
    try
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            errordlg('Main GUI not found. Please launch the GUI first.', 'Error');
            return;
        end
        
        % Get data from main GUI
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            % Try to load from files
            [BASEQ, ZTCFQ, DELTAQ] = load_data_from_files();
        end
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please run simulation or analysis first.', 'Error');
            return;
        end
        
        % Store data in the control panel
        control_panel = src.Parent;
        setappdata(control_panel, 'BASEQ', BASEQ);
        setappdata(control_panel, 'ZTCFQ', ZTCFQ);
        setappdata(control_panel, 'DELTAQ', DELTAQ);
        
        % Update variable popups with available variables
        update_variable_popup(x_var_popup, BASEQ);
        update_variable_popup(y_var_popup, BASEQ);
        
        msgbox('Data loaded successfully!', 'Success');
        
    catch ME
        errordlg(sprintf('Error loading data: %s', ME.message), 'Error');
    end
end

function generate_phase_plot(src, x_var_popup, y_var_popup, dataset_popup, show_trajectory_checkbox, show_points_checkbox, plot_axes)
    try
        control_panel = src.Parent;
        BASEQ = getappdata(control_panel, 'BASEQ');
        ZTCFQ = getappdata(control_panel, 'ZTCFQ');
        DELTAQ = getappdata(control_panel, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please load data first.', 'Error');
            return;
        end
        
        % Get selected variables and dataset
        x_var_names = x_var_popup.String;
        y_var_names = y_var_popup.String;
        dataset_names = dataset_popup.String;
        
        selected_x_var = x_var_names{x_var_popup.Value};
        selected_y_var = y_var_names{y_var_popup.Value};
        selected_dataset = dataset_names{dataset_popup.Value};
        
        if strcmp(selected_x_var, 'Select variable...') || strcmp(selected_y_var, 'Select variable...')
            errordlg('Please select both X and Y variables.', 'Error');
            return;
        end
        
        % Select data based on dataset
        switch selected_dataset
            case 'BASEQ'
                data = BASEQ;
            case 'ZTCFQ'
                data = ZTCFQ;
            case 'DELTAQ'
                data = DELTAQ;
            otherwise
                errordlg('Invalid dataset selection.', 'Error');
                return;
        end
        
        if isempty(data)
            errordlg(sprintf('No data available for %s.', selected_dataset), 'Error');
            return;
        end
        
        % Check if variables exist in data
        if ~ismember(selected_x_var, data.Properties.VariableNames) || ~ismember(selected_y_var, data.Properties.VariableNames)
            errordlg('Selected variables not found in data.', 'Error');
            return;
        end
        
        % Generate phase plot
        cla(plot_axes);
        hold(plot_axes, 'on');
        
        x_data = data.(selected_x_var);
        y_data = data.(selected_y_var);
        
        % Plot trajectory if requested
        if show_trajectory_checkbox.Value
            plot(plot_axes, x_data, y_data, 'b-', 'LineWidth', 2, 'DisplayName', 'Trajectory');
        end
        
        % Plot points if requested
        if show_points_checkbox.Value
            scatter(plot_axes, x_data, y_data, 50, 1:length(x_data), 'filled', 'DisplayName', 'Time Points');
            colormap(plot_axes, jet);
            colorbar(plot_axes);
        end
        
        % Mark start and end points
        plot(plot_axes, x_data(1), y_data(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', 'Start');
        plot(plot_axes, x_data(end), y_data(end), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', 'End');
        
        title(plot_axes, sprintf('%s: %s vs %s', selected_dataset, selected_y_var, selected_x_var), 'FontSize', 14, 'FontWeight', 'bold');
        xlabel(plot_axes, selected_x_var, 'FontSize', 12);
        ylabel(plot_axes, selected_y_var, 'FontSize', 12);
        grid(plot_axes, 'on');
        legend(plot_axes, 'show');
        hold(plot_axes, 'off');
        
    catch ME
        errordlg(sprintf('Error generating phase plot: %s', ME.message), 'Error');
    end
end

function export_phase_plot(src, ~)
    try
        control_panel = src.Parent;
        plot_axes = getappdata(control_panel, 'plot_axes');
        
        [filename, pathname] = uiputfile({'*.png', 'PNG Image'; '*.jpg', 'JPEG Image'; '*.pdf', 'PDF Document'; '*.fig', 'MATLAB Figure'}, 'Export Phase Plot');
        
        if filename ~= 0
            full_path = fullfile(pathname, filename);
            saveas(plot_axes, full_path);
            msgbox(sprintf('Plot exported to: %s', full_path), 'Success');
        end
        
    catch ME
        errordlg(sprintf('Error exporting plot: %s', ME.message), 'Error');
    end
end

% Quiver Plot Callbacks
function load_data_for_quiver_plots(src)
    try
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            errordlg('Main GUI not found. Please launch the GUI first.', 'Error');
            return;
        end
        
        % Get data from main GUI
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            % Try to load from files
            [BASEQ, ZTCFQ, DELTAQ] = load_data_from_files();
        end
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please run simulation or analysis first.', 'Error');
            return;
        end
        
        % Store data in the control panel
        control_panel = src.Parent;
        setappdata(control_panel, 'BASEQ', BASEQ);
        setappdata(control_panel, 'ZTCFQ', ZTCFQ);
        setappdata(control_panel, 'DELTAQ', DELTAQ);
        
        % Update time slider range
        time_slider = getappdata(control_panel, 'time_slider');
        time_text = getappdata(control_panel, 'time_text');
        
        if ~isempty(BASEQ) && ismember('Time', BASEQ.Properties.VariableNames)
            time_range = [min(BASEQ.Time), max(BASEQ.Time)];
            time_slider.Min = time_range(1);
            time_slider.Max = time_range(2);
            time_slider.Value = mean(time_range);
            time_text.String = sprintf('%.3f s', time_slider.Value);
        end
        
        msgbox('Data loaded successfully!', 'Success');
        
    catch ME
        errordlg(sprintf('Error loading data: %s', ME.message), 'Error');
    end
end

function generate_quiver_plot(src, vector_type_popup, dataset_popup, time_slider, time_text, show_magnitude_checkbox, scale_vectors_checkbox, plot_axes)
    try
        control_panel = src.Parent;
        BASEQ = getappdata(control_panel, 'BASEQ');
        ZTCFQ = getappdata(control_panel, 'ZTCFQ');
        DELTAQ = getappdata(control_panel, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please load data first.', 'Error');
            return;
        end
        
        % Get selected options
        vector_type_names = vector_type_popup.String;
        dataset_names = dataset_popup.String;
        
        selected_vector_type = vector_type_names{vector_type_popup.Value};
        selected_dataset = dataset_names{dataset_popup.Value};
        selected_time = time_slider.Value;
        
        % Select data based on dataset
        switch selected_dataset
            case 'BASEQ'
                data = BASEQ;
            case 'ZTCFQ'
                data = ZTCFQ;
            case 'DELTAQ'
                data = DELTAQ;
            otherwise
                errordlg('Invalid dataset selection.', 'Error');
                return;
        end
        
        if isempty(data)
            errordlg(sprintf('No data available for %s.', selected_dataset), 'Error');
            return;
        end
        
        % Find closest time point
        if ismember('Time', data.Properties.VariableNames)
            [~, time_idx] = min(abs(data.Time - selected_time));
            selected_time = data.Time(time_idx);
            time_text.String = sprintf('%.3f s', selected_time);
        else
            time_idx = round(selected_time * height(data));
            time_idx = max(1, min(time_idx, height(data)));
        end
        
        % Generate quiver plot
        cla(plot_axes);
        hold(plot_axes, 'on');
        
        % Get position data for vector origins
        position_vars = {'Buttx', 'Butty', 'Buttz', 'CHx', 'CHy', 'CHz', 'MPx', 'MPy', 'MPz'};
        available_positions = position_vars(ismember(position_vars, data.Properties.VariableNames));
        
        if isempty(available_positions)
            errordlg('No position data available for quiver plot.', 'Error');
            return;
        end
        
        % Get vector data based on type
        switch selected_vector_type
            case 'Forces'
                vector_vars = {'TotalHandForceGlobal'};
            case 'Torques'
                vector_vars = {'EquivalentMidpointCoupleGlobal'};
            case 'Velocities'
                vector_vars = {'CHx', 'CHy', 'CHz'}; % Use position as proxy for velocity
            case 'Accelerations'
                vector_vars = {'CHx', 'CHy', 'CHz'}; % Use position as proxy for acceleration
            otherwise
                errordlg('Invalid vector type selection.', 'Error');
                return;
        end
        
        % Plot vectors
        colors = lines(length(available_positions));
        for i = 1:length(available_positions)
            pos_var = available_positions{i};
            
            % Get position
            if ismember(pos_var, data.Properties.VariableNames)
                x_pos = data.(pos_var)(time_idx);
                y_pos = data.([pos_var(1:end-1), 'y'])(time_idx);
                z_pos = data.([pos_var(1:end-1), 'z'])(time_idx);
                
                % Get vector components
                if strcmp(selected_vector_type, 'Forces') && ismember('TotalHandForceGlobal', data.Properties.VariableNames)
                    force_data = data.TotalHandForceGlobal(time_idx, :);
                    u = force_data(1);
                    v = force_data(2);
                    w = force_data(3);
                elseif strcmp(selected_vector_type, 'Torques') && ismember('EquivalentMidpointCoupleGlobal', data.Properties.VariableNames)
                    torque_data = data.EquivalentMidpointCoupleGlobal(time_idx, :);
                    u = torque_data(1);
                    v = torque_data(2);
                    w = torque_data(3);
                else
                    % Use position differences as proxy for velocity/acceleration
                    if time_idx > 1
                        u = data.(pos_var)(time_idx) - data.(pos_var)(time_idx-1);
                        v = data.([pos_var(1:end-1), 'y'])(time_idx) - data.([pos_var(1:end-1), 'y'])(time_idx-1);
                        w = data.([pos_var(1:end-1), 'z'])(time_idx) - data.([pos_var(1:end-1), 'z'])(time_idx-1);
                    else
                        u = 0; v = 0; w = 0;
                    end
                end
                
                % Scale vectors if requested
                if scale_vectors_checkbox.Value
                    scale_factor = 0.1;
                    u = u * scale_factor;
                    v = v * scale_factor;
                    w = w * scale_factor;
                end
                
                % Plot quiver
                quiver3(plot_axes, x_pos, y_pos, z_pos, u, v, w, 'Color', colors(i,:), 'LineWidth', 2, 'MaxHeadSize', 0.5, 'DisplayName', pos_var);
                
                % Show magnitude if requested
                if show_magnitude_checkbox.Value
                    magnitude = sqrt(u^2 + v^2 + w^2);
                    text(plot_axes, x_pos + u, y_pos + v, z_pos + w, sprintf('%.2f', magnitude), 'FontSize', 8);
                end
            end
        end
        
        title(plot_axes, sprintf('%s: %s at %.3f s', selected_dataset, selected_vector_type, selected_time), 'FontSize', 14, 'FontWeight', 'bold');
        xlabel(plot_axes, 'X Position', 'FontSize', 12);
        ylabel(plot_axes, 'Y Position', 'FontSize', 12);
        zlabel(plot_axes, 'Z Position', 'FontSize', 12);
        grid(plot_axes, 'on');
        legend(plot_axes, 'show');
        view(plot_axes, 3);
        hold(plot_axes, 'off');
        
    catch ME
        errordlg(sprintf('Error generating quiver plot: %s', ME.message), 'Error');
    end
end

function export_quiver_plot(src, ~)
    try
        control_panel = src.Parent;
        plot_axes = getappdata(control_panel, 'plot_axes');
        
        [filename, pathname] = uiputfile({'*.png', 'PNG Image'; '*.jpg', 'JPEG Image'; '*.pdf', 'PDF Document'; '*.fig', 'MATLAB Figure'}, 'Export Quiver Plot');
        
        if filename ~= 0
            full_path = fullfile(pathname, filename);
            saveas(plot_axes, full_path);
            msgbox(sprintf('Plot exported to: %s', full_path), 'Success');
        end
        
    catch ME
        errordlg(sprintf('Error exporting plot: %s', ME.message), 'Error');
    end
end

% Comparison Plot Callbacks
function load_data_for_comparison(src, variable_popup)
    try
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            errordlg('Main GUI not found. Please launch the GUI first.', 'Error');
            return;
        end
        
        % Get data from main GUI
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            % Try to load from files
            [BASEQ, ZTCFQ, DELTAQ] = load_data_from_files();
        end
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please run simulation or analysis first.', 'Error');
            return;
        end
        
        % Store data in the control panel
        control_panel = src.Parent;
        setappdata(control_panel, 'BASEQ', BASEQ);
        setappdata(control_panel, 'ZTCFQ', ZTCFQ);
        setappdata(control_panel, 'DELTAQ', DELTAQ);
        
        % Update variable popup with available variables
        update_variable_popup(variable_popup, BASEQ);
        
        msgbox('Data loaded successfully!', 'Success');
        
    catch ME
        errordlg(sprintf('Error loading data: %s', ME.message), 'Error');
    end
end

function generate_comparison_plot(src, variable_popup, comparison_popup, plot_type_popup, plot_axes)
    try
        control_panel = src.Parent;
        BASEQ = getappdata(control_panel, 'BASEQ');
        ZTCFQ = getappdata(control_panel, 'ZTCFQ');
        DELTAQ = getappdata(control_panel, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please load data first.', 'Error');
            return;
        end
        
        % Get selected options
        variable_names = variable_popup.String;
        comparison_names = comparison_popup.String;
        plot_type_names = plot_type_popup.String;
        
        selected_variable = variable_names{variable_popup.Value};
        selected_comparison = comparison_names{comparison_popup.Value};
        selected_plot_type = plot_type_names{plot_type_popup.Value};
        
        if strcmp(selected_variable, 'Select variable...')
            errordlg('Please select a variable.', 'Error');
            return;
        end
        
        % Generate comparison plot
        cla(plot_axes);
        hold(plot_axes, 'on');
        
        switch selected_plot_type
            case 'Overlay'
                % Plot all selected datasets on same axes
                if strcmp(selected_comparison, 'BASEQ vs ZTCFQ') || strcmp(selected_comparison, 'All Three')
                    if ~isempty(BASEQ) && ismember(selected_variable, BASEQ.Properties.VariableNames)
                        plot(plot_axes, BASEQ.Time, BASEQ.(selected_variable), 'b-', 'LineWidth', 2, 'DisplayName', 'BASEQ');
                    end
                    if ~isempty(ZTCFQ) && ismember(selected_variable, ZTCFQ.Properties.VariableNames)
                        plot(plot_axes, ZTCFQ.Time, ZTCFQ.(selected_variable), 'r--', 'LineWidth', 2, 'DisplayName', 'ZTCFQ');
                    end
                end
                
                if strcmp(selected_comparison, 'BASEQ vs DELTAQ') || strcmp(selected_comparison, 'All Three')
                    if ~isempty(DELTAQ) && ismember(selected_variable, DELTAQ.Properties.VariableNames)
                        plot(plot_axes, DELTAQ.Time, DELTAQ.(selected_variable), 'g:', 'LineWidth', 2, 'DisplayName', 'DELTAQ');
                    end
                end
                
                if strcmp(selected_comparison, 'ZTCFQ vs DELTAQ')
                    if ~isempty(ZTCFQ) && ismember(selected_variable, ZTCFQ.Properties.VariableNames)
                        plot(plot_axes, ZTCFQ.Time, ZTCFQ.(selected_variable), 'r--', 'LineWidth', 2, 'DisplayName', 'ZTCFQ');
                    end
                    if ~isempty(DELTAQ) && ismember(selected_variable, DELTAQ.Properties.VariableNames)
                        plot(plot_axes, DELTAQ.Time, DELTAQ.(selected_variable), 'g:', 'LineWidth', 2, 'DisplayName', 'DELTAQ');
                    end
                end
                
                title(plot_axes, sprintf('Comparison: %s', selected_variable), 'FontSize', 14, 'FontWeight', 'bold');
                legend(plot_axes, 'show');
                
            case 'Subplot'
                % Create subplots for each dataset
                num_datasets = 0;
                if strcmp(selected_comparison, 'BASEQ vs ZTCFQ') || strcmp(selected_comparison, 'All Three')
                    if ~isempty(BASEQ) && ~isempty(ZTCFQ)
                        num_datasets = num_datasets + 2;
                    end
                end
                if strcmp(selected_comparison, 'BASEQ vs DELTAQ') || strcmp(selected_comparison, 'All Three')
                    if ~isempty(BASEQ) && ~isempty(DELTAQ)
                        num_datasets = num_datasets + 2;
                    end
                end
                if strcmp(selected_comparison, 'ZTCFQ vs DELTAQ')
                    if ~isempty(ZTCFQ) && ~isempty(DELTAQ)
                        num_datasets = num_datasets + 2;
                    end
                end
                
                if num_datasets == 0
                    errordlg('No valid datasets for comparison.', 'Error');
                    return;
                end
                
                % Create subplots
                subplot_idx = 1;
                if strcmp(selected_comparison, 'BASEQ vs ZTCFQ') || strcmp(selected_comparison, 'All Three')
                    if ~isempty(BASEQ) && ismember(selected_variable, BASEQ.Properties.VariableNames)
                        subplot(plot_axes, num_datasets, 1, subplot_idx);
                        plot(BASEQ.Time, BASEQ.(selected_variable), 'b-', 'LineWidth', 2);
                        title('BASEQ', 'FontSize', 12);
                        ylabel(selected_variable);
                        grid on;
                        subplot_idx = subplot_idx + 1;
                    end
                    if ~isempty(ZTCFQ) && ismember(selected_variable, ZTCFQ.Properties.VariableNames)
                        subplot(plot_axes, num_datasets, 1, subplot_idx);
                        plot(ZTCFQ.Time, ZTCFQ.(selected_variable), 'r-', 'LineWidth', 2);
                        title('ZTCFQ', 'FontSize', 12);
                        ylabel(selected_variable);
                        grid on;
                        subplot_idx = subplot_idx + 1;
                    end
                end
                
                if strcmp(selected_comparison, 'BASEQ vs DELTAQ') || strcmp(selected_comparison, 'All Three')
                    if ~isempty(DELTAQ) && ismember(selected_variable, DELTAQ.Properties.VariableNames)
                        subplot(plot_axes, num_datasets, 1, subplot_idx);
                        plot(DELTAQ.Time, DELTAQ.(selected_variable), 'g-', 'LineWidth', 2);
                        title('DELTAQ', 'FontSize', 12);
                        ylabel(selected_variable);
                        grid on;
                        subplot_idx = subplot_idx + 1;
                    end
                end
                
                sgtitle(plot_axes, sprintf('Comparison: %s', selected_variable), 'FontSize', 14, 'FontWeight', 'bold');
                
            case 'Difference'
                % Plot differences between datasets
                if strcmp(selected_comparison, 'BASEQ vs ZTCFQ')
                    if ~isempty(BASEQ) && ~isempty(ZTCFQ) && ismember(selected_variable, BASEQ.Properties.VariableNames) && ismember(selected_variable, ZTCFQ.Properties.VariableNames)
                        diff_data = BASEQ.(selected_variable) - ZTCFQ.(selected_variable);
                        plot(plot_axes, BASEQ.Time, diff_data, 'b-', 'LineWidth', 2);
                        title(plot_axes, sprintf('Difference: BASEQ - ZTCFQ (%s)', selected_variable), 'FontSize', 14, 'FontWeight', 'bold');
                    else
                        errordlg('Both BASEQ and ZTCFQ data required for difference plot.', 'Error');
                        return;
                    end
                elseif strcmp(selected_comparison, 'BASEQ vs DELTAQ')
                    if ~isempty(BASEQ) && ~isempty(DELTAQ) && ismember(selected_variable, BASEQ.Properties.VariableNames) && ismember(selected_variable, DELTAQ.Properties.VariableNames)
                        diff_data = BASEQ.(selected_variable) - DELTAQ.(selected_variable);
                        plot(plot_axes, BASEQ.Time, diff_data, 'r-', 'LineWidth', 2);
                        title(plot_axes, sprintf('Difference: BASEQ - DELTAQ (%s)', selected_variable), 'FontSize', 14, 'FontWeight', 'bold');
                    else
                        errordlg('Both BASEQ and DELTAQ data required for difference plot.', 'Error');
                        return;
                    end
                elseif strcmp(selected_comparison, 'ZTCFQ vs DELTAQ')
                    if ~isempty(ZTCFQ) && ~isempty(DELTAQ) && ismember(selected_variable, ZTCFQ.Properties.VariableNames) && ismember(selected_variable, DELTAQ.Properties.VariableNames)
                        diff_data = ZTCFQ.(selected_variable) - DELTAQ.(selected_variable);
                        plot(plot_axes, ZTCFQ.Time, diff_data, 'g-', 'LineWidth', 2);
                        title(plot_axes, sprintf('Difference: ZTCFQ - DELTAQ (%s)', selected_variable), 'FontSize', 14, 'FontWeight', 'bold');
                    else
                        errordlg('Both ZTCFQ and DELTAQ data required for difference plot.', 'Error');
                        return;
                    end
                else
                    errordlg('Invalid comparison selection for difference plot.', 'Error');
                    return;
                end
        end
        
        xlabel(plot_axes, 'Time (s)', 'FontSize', 12);
        ylabel(plot_axes, selected_variable, 'FontSize', 12);
        grid(plot_axes, 'on');
        hold(plot_axes, 'off');
        
    catch ME
        errordlg(sprintf('Error generating comparison plot: %s', ME.message), 'Error');
    end
end

function export_comparison_plot(src, ~)
    try
        control_panel = src.Parent;
        plot_axes = getappdata(control_panel, 'plot_axes');
        
        [filename, pathname] = uiputfile({'*.png', 'PNG Image'; '*.jpg', 'JPEG Image'; '*.pdf', 'PDF Document'; '*.fig', 'MATLAB Figure'}, 'Export Comparison Plot');
        
        if filename ~= 0
            full_path = fullfile(pathname, filename);
            saveas(plot_axes, full_path);
            msgbox(sprintf('Plot exported to: %s', full_path), 'Success');
        end
        
    catch ME
        errordlg(sprintf('Error exporting plot: %s', ME.message), 'Error');
    end
end

% Data Explorer Callbacks
function load_data_for_explorer(src, dataset_popup, data_table, stats_text)
    try
        main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
        if isempty(main_fig)
            errordlg('Main GUI not found. Please launch the GUI first.', 'Error');
            return;
        end
        
        % Get data from main GUI
        BASEQ = getappdata(main_fig, 'BASEQ');
        ZTCFQ = getappdata(main_fig, 'ZTCFQ');
        DELTAQ = getappdata(main_fig, 'DELTAQ');
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            % Try to load from files
            [BASEQ, ZTCFQ, DELTAQ] = load_data_from_files();
        end
        
        if isempty(BASEQ) && isempty(ZTCFQ) && isempty(DELTAQ)
            errordlg('No data available. Please run simulation or analysis first.', 'Error');
            return;
        end
        
        % Store data in the control panel
        control_panel = src.Parent;
        setappdata(control_panel, 'BASEQ', BASEQ);
        setappdata(control_panel, 'ZTCFQ', ZTCFQ);
        setappdata(control_panel, 'DELTAQ', DELTAQ);
        
        % Update data explorer with BASEQ data initially
        update_data_explorer(dataset_popup, data_table, stats_text);
        
        msgbox('Data loaded successfully!', 'Success');
        
    catch ME
        errordlg(sprintf('Error loading data: %s', ME.message), 'Error');
    end
end

function update_data_explorer(dataset_popup, data_table, stats_text)
    try
        control_panel = dataset_popup.Parent;
        BASEQ = getappdata(control_panel, 'BASEQ');
        ZTCFQ = getappdata(control_panel, 'ZTCFQ');
        DELTAQ = getappdata(control_panel, 'DELTAQ');
        
        % Get selected dataset
        dataset_names = dataset_popup.String;
        selected_dataset = dataset_names{dataset_popup.Value};
        
        % Select data based on dataset
        switch selected_dataset
            case 'BASEQ'
                data = BASEQ;
            case 'ZTCFQ'
                data = ZTCFQ;
            case 'DELTAQ'
                data = DELTAQ;
            otherwise
                errordlg('Invalid dataset selection.', 'Error');
                return;
        end
        
        if isempty(data)
            errordlg(sprintf('No data available for %s.', selected_dataset), 'Error');
            return;
        end
        
        % Calculate statistics for all numeric variables
        numeric_vars = varfun(@isnumeric, data, 'OutputFormat', 'cell');
        numeric_vars = data.Properties.VariableNames(numeric_vars);
        
        if isempty(numeric_vars)
            errordlg('No numeric variables found in data.', 'Error');
            return;
        end
        
        % Create statistics table
        stats_data = cell(length(numeric_vars), 6);
        for i = 1:length(numeric_vars)
            var_name = numeric_vars{i};
            var_data = data.(var_name);
            
            stats_data{i, 1} = var_name;
            stats_data{i, 2} = min(var_data);
            stats_data{i, 3} = max(var_data);
            stats_data{i, 4} = mean(var_data);
            stats_data{i, 5} = std(var_data);
            stats_data{i, 6} = max(var_data) - min(var_data);
        end
        
        % Update data table
        data_table.Data = stats_data;
        
        % Update statistics text
        stats_summary = sprintf('Dataset: %s\n', selected_dataset);
        stats_summary = [stats_summary, sprintf('Total Variables: %d\n', length(numeric_vars))];
        stats_summary = [stats_summary, sprintf('Data Points: %d\n', height(data))];
        
        if ismember('Time', data.Properties.VariableNames)
            time_range = [min(data.Time), max(data.Time)];
            stats_summary = [stats_summary, sprintf('Time Range: %.3f to %.3f s\n', time_range(1), time_range(2))];
        end
        
        stats_text.String = stats_summary;
        
    catch ME
        errordlg(sprintf('Error updating data explorer: %s', ME.message), 'Error');
    end
end

function apply_data_filter(src, filter_var_popup, filter_min_edit, filter_max_edit, data_table)
    try
        % This is a placeholder for data filtering functionality
        % In a full implementation, this would filter the displayed data
        msgbox('Data filtering functionality will be implemented in future versions.', 'Info');
        
    catch ME
        errordlg(sprintf('Error applying filter: %s', ME.message), 'Error');
    end
end

function export_explorer_data(src, ~)
    try
        control_panel = src.Parent;
        data_table = getappdata(control_panel, 'data_table');
        
        [filename, pathname] = uiputfile({'*.csv', 'CSV File'; '*.xlsx', 'Excel File'; '*.mat', 'MATLAB File'}, 'Export Data Statistics');
        
        if filename ~= 0
            full_path = fullfile(pathname, filename);
            
            % Get table data
            table_data = data_table.Data;
            column_names = data_table.ColumnName;
            
            % Create table for export
            export_table = cell2table(table_data, 'VariableNames', column_names);
            
            % Export based on file type
            [~, ~, ext] = fileparts(filename);
            switch lower(ext)
                case '.csv'
                    writetable(export_table, full_path);
                case '.xlsx'
                    writetable(export_table, full_path);
                case '.mat'
                    save(full_path, 'export_table');
                otherwise
                    errordlg('Unsupported file format.', 'Error');
                    return;
            end
            
            msgbox(sprintf('Data exported to: %s', full_path), 'Success');
        end
        
    catch ME
        errordlg(sprintf('Error exporting data: %s', ME.message), 'Error');
    end
end

% ============================================================================
% UTILITY FUNCTIONS
% ============================================================================

function [BASEQ, ZTCFQ, DELTAQ] = load_data_from_files()
    % Try to load data from common file locations
    BASEQ = []; ZTCFQ = []; DELTAQ = [];
    
    % Common directories to search
    search_dirs = {
        'Tables',
        '2D GUI/Tables',
        '2DModel/Tables',
        '2DModel/Model Output/Tables',
        '3DModel/Tables',
        '3DModel/Model Output/Tables'
    };
    
    for i = 1:length(search_dirs)
        if exist(search_dirs{i}, 'dir')
            % Try to load BASEQ
            if isempty(BASEQ) && exist(fullfile(search_dirs{i}, 'BASEQ.mat'), 'file')
                try
                    load(fullfile(search_dirs{i}, 'BASEQ.mat'), 'BASEQ');
                catch
                    % Continue to next file
                end
            end
            
            % Try to load ZTCFQ
            if isempty(ZTCFQ) && exist(fullfile(search_dirs{i}, 'ZTCFQ.mat'), 'file')
                try
                    load(fullfile(search_dirs{i}, 'ZTCFQ.mat'), 'ZTCFQ');
                catch
                    % Continue to next file
                end
            end
            
            % Try to load DELTAQ
            if isempty(DELTAQ) && exist(fullfile(search_dirs{i}, 'DELTAQ.mat'), 'file')
                try
                    load(fullfile(search_dirs{i}, 'DELTAQ.mat'), 'DELTAQ');
                catch
                    % Continue to next file
                end
            end
        end
    end
end

function update_variable_popup(variable_popup, data)
    % Update variable popup with available variables from data
    if isempty(data)
        variable_popup.String = {'Select variable...'};
        variable_popup.Value = 1;
        return;
    end
    
    % Get numeric variables
    numeric_vars = varfun(@isnumeric, data, 'OutputFormat', 'cell');
    numeric_vars = data.Properties.VariableNames(numeric_vars);
    
    % Remove Time variable if present
    numeric_vars = setdiff(numeric_vars, 'Time');
    
    if isempty(numeric_vars)
        variable_popup.String = {'No numeric variables found'};
        variable_popup.Value = 1;
    else
        variable_popup.String = ['Select variable...', numeric_vars];
        variable_popup.Value = 1;
    end
end

function close_gui_callback(src, ~)
    % Clean up when closing GUI
    delete(src);
end
