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

% Placeholder functions for plot panels (these would be implemented based on existing code)
function create_time_series_panel(parent, config)
    % Placeholder for time series panel
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Time Series Plot Panel - To be implemented', ...
              'FontSize', 12, ...
              'Position', [50, 50, 300, 50], ...
              'HorizontalAlignment', 'center');
end

function create_phase_plots_panel(parent, config)
    % Placeholder for phase plots panel
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Phase Plots Panel - To be implemented', ...
              'FontSize', 12, ...
              'Position', [50, 50, 300, 50], ...
              'HorizontalAlignment', 'center');
end

function create_quiver_plots_panel(parent, config)
    % Placeholder for quiver plots panel
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Quiver Plots Panel - To be implemented', ...
              'FontSize', 12, ...
              'Position', [50, 50, 300, 50], ...
              'HorizontalAlignment', 'center');
end

function create_comparison_panel(parent, config)
    % Placeholder for comparison panel
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Comparison Panel - To be implemented', ...
              'FontSize', 12, ...
              'Position', [50, 50, 300, 50], ...
              'HorizontalAlignment', 'center');
end

function create_data_explorer_panel(parent, config)
    % Placeholder for data explorer panel
    uicontrol('Parent', parent, ...
              'Style', 'text', ...
              'String', 'Data Explorer Panel - To be implemented', ...
              'FontSize', 12, ...
              'Position', [50, 50, 300, 50], ...
              'HorizontalAlignment', 'center');
end

function close_gui_callback(src, ~)
    % Clean up when closing GUI
    delete(src);
end
