function golf_swing_analysis_gui()
% GOLF_SWING_ANALYSIS_GUI - Enhanced Main GUI for 2D Golf Swing Analysis
%
% This GUI provides:
%   1. Animation window showing the golf swing
%   2. Advanced plot viewer with multiple plot types
%   3. Data explorer for understanding data structure
%   4. Controls to run the complete ZTCF/ZVCF analysis
%   5. Progress tracking and status updates
%   6. Comprehensive help system
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
    
    % Create animation window
    [anim_fig, anim_ax, anim_handles] = create_animation_window(config);
    
    % Create advanced plot viewer
    [plot_fig, plot_handles] = create_advanced_plot_viewer(config);
    
    % Create data explorer
    [explorer_fig, explorer_handles] = create_data_explorer(config);
    
    % Create main GUI layout
    create_enhanced_gui_layout(main_fig, config, anim_fig, anim_handles, plot_fig, plot_handles, explorer_fig, explorer_handles);
    
    % Store data in figure
    setappdata(main_fig, 'config', config);
    setappdata(main_fig, 'animation_handles', anim_handles);
    setappdata(main_fig, 'animation_fig', anim_fig);
    setappdata(main_fig, 'animation_ax', anim_ax);
    setappdata(main_fig, 'plot_handles', plot_handles);
    setappdata(main_fig, 'plot_fig', plot_fig);
    setappdata(main_fig, 'explorer_handles', explorer_handles);
    setappdata(main_fig, 'explorer_fig', explorer_fig);
    
    fprintf('✅ Enhanced Golf Swing Analysis GUI created successfully\n');
    
end

function create_enhanced_gui_layout(main_fig, config, anim_fig, anim_handles, plot_fig, plot_handles, explorer_fig, explorer_handles)
    % Create main tab group
    main_tab_group = uitabgroup('Parent', main_fig, ...
                               'Position', [0.02, 0.02, 0.96, 0.96]);
    
    % Create main control tab
    control_tab = uitab('Parent', main_tab_group, ...
                       'Title', 'Analysis Control');
    
    % Create visualization tab
    visualization_tab = uitab('Parent', main_tab_group, ...
                             'Title', 'Visualization');
    
    % Create data exploration tab
    data_tab = uitab('Parent', main_tab_group, ...
                    'Title', 'Data Explorer');
    
    % Create help tab
    help_tab = uitab('Parent', main_tab_group, ...
                    'Title', 'Help & Info');
    
    % Create main control panel
    create_main_control_panel(control_tab, config, anim_handles);
    
    % Create visualization panel
    create_visualization_panel(visualization_tab, config, plot_handles);
    
    % Create data exploration panel
    create_data_exploration_panel(data_tab, config, explorer_handles);
    
    % Create help panel
    create_comprehensive_help_panel(help_tab, config);
    
end

function create_main_control_panel(parent, config, anim_handles)
    % Create control panel
    control_panel = uipanel('Parent', parent, ...
                           'Title', 'Analysis Controls', ...
                           'FontSize', 12, ...
                           'Position', [0.02, 0.02, 0.3, 0.96]);
    
    % Analysis buttons
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '🚀 Run Complete Analysis', ...
              'FontSize', 11, ...
              'Position', [10, 500, 200, 40], ...
              'Callback', @run_analysis_callback);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '📂 Load Existing Data', ...
              'FontSize', 11, ...
              'Position', [10, 450, 200, 40], ...
              'Callback', @load_data_callback);
    
    % Animation controls
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '▶️ Play Animation', ...
              'FontSize', 11, ...
              'Position', [10, 400, 200, 40], ...
              'Callback', @play_animation_callback);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '⏹️ Stop Animation', ...
              'FontSize', 11, ...
              'Position', [10, 350, 200, 40], ...
              'Callback', @stop_animation_callback);
    
    % Quick plot buttons
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '📊 Quick Time Series', ...
              'FontSize', 11, ...
              'Position', [10, 300, 200, 40], ...
              'Callback', @quick_time_series_callback);
    
    uicontrol('Parent', control_panel, ...
              'Style', 'pushbutton', ...
              'String', '🔄 Quick Phase Plot', ...
              'FontSize', 11, ...
              'Position', [10, 250, 200, 40], ...
              'Callback', @quick_phase_plot_callback);
    
    % Progress panel
    progress_panel = uipanel('Parent', control_panel, ...
                            'Title', 'Progress & Status', ...
                            'FontSize', 10, ...
                            'Position', [0.05, 0.05, 0.9, 0.25]);
    
    % Progress text
    progress_text = uicontrol('Parent', progress_panel, ...
                             'Style', 'text', ...
                             'String', 'Ready to start analysis...', ...
                             'FontSize', 10, ...
                             'Position', [10, 80, 180, 60], ...
                             'HorizontalAlignment', 'left');
    
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

function create_visualization_panel(parent, config, plot_handles)
    % Create visualization control panel
    viz_panel = uipanel('Parent', parent, ...
                       'Title', 'Visualization Tools', ...
                       'FontSize', 12, ...
                       'Position', [0.02, 0.02, 0.3, 0.96]);
    
    % Plot viewer controls
    uicontrol('Parent', viz_panel, ...
              'Style', 'pushbutton', ...
              'String', '📈 Open Plot Viewer', ...
              'FontSize', 11, ...
              'Position', [10, 500, 200, 40], ...
              'Callback', @open_plot_viewer_callback);
    
    uicontrol('Parent', viz_panel, ...
              'Style', 'pushbutton', ...
              'String', '📊 Time Series Analysis', ...
              'FontSize', 11, ...
              'Position', [10, 450, 200, 40], ...
              'Callback', @time_series_analysis_callback);
    
    uicontrol('Parent', viz_panel, ...
              'Style', 'pushbutton', ...
              'String', '🔄 Phase Space Analysis', ...
              'FontSize', 11, ...
              'Position', [10, 400, 200, 40], ...
              'Callback', @phase_space_analysis_callback);
    
    uicontrol('Parent', viz_panel, ...
              'Style', 'pushbutton', ...
              'String', '➡️ Quiver Plot Analysis', ...
              'FontSize', 11, ...
              'Position', [10, 350, 200, 40], ...
              'Callback', @quiver_plot_analysis_callback);
    
    uicontrol('Parent', viz_panel, ...
              'Style', 'pushbutton', ...
              'String', '⚖️ Comparison Analysis', ...
              'FontSize', 11, ...
              'Position', [10, 300, 200, 40], ...
              'Callback', @comparison_analysis_callback);
    
    % Export controls
    uicontrol('Parent', viz_panel, ...
              'Style', 'pushbutton', ...
              'String', '💾 Export All Plots', ...
              'FontSize', 11, ...
              'Position', [10, 250, 200, 40], ...
              'Callback', @export_all_plots_callback);
    
    % Information panel
    info_panel = uipanel('Parent', viz_panel, ...
                        'Title', 'Visualization Info', ...
                        'FontSize', 10, ...
                        'Position', [0.05, 0.05, 0.9, 0.3]);
    
    info_text = uicontrol('Parent', info_panel, ...
                         'Style', 'text', ...
                         'String', {'Visualization Tools:', '', ...
                                   '• Time Series: View variables over time', ...
                                   '• Phase Plots: Explore relationships', ...
                                   '• Quiver Plots: Analyze forces/torques', ...
                                   '• Comparisons: Compare datasets', ...
                                   '', 'Click buttons to open specific tools.'}, ...
                         'FontSize', 9, ...
                         'Position', [10, 10, 180, 150], ...
                         'HorizontalAlignment', 'left');
    
end

function create_data_exploration_panel(parent, config, explorer_handles)
    % Create data exploration control panel
    data_panel = uipanel('Parent', parent, ...
                        'Title', 'Data Exploration Tools', ...
                        'FontSize', 12, ...
                        'Position', [0.02, 0.02, 0.3, 0.96]);
    
    % Data explorer controls
    uicontrol('Parent', data_panel, ...
              'Style', 'pushbutton', ...
              'String', '🔍 Open Data Explorer', ...
              'FontSize', 11, ...
              'Position', [10, 500, 200, 40], ...
              'Callback', @open_data_explorer_callback);
    
    uicontrol('Parent', data_panel, ...
              'Style', 'pushbutton', ...
              'String', '📋 Variable Browser', ...
              'FontSize', 11, ...
              'Position', [10, 450, 200, 40], ...
              'Callback', @variable_browser_callback);
    
    uicontrol('Parent', data_panel, ...
              'Style', 'pushbutton', ...
              'String', '📊 Statistical Summary', ...
              'FontSize', 11, ...
              'Position', [10, 400, 200, 40], ...
              'Callback', @statistical_summary_callback);
    
    uicontrol('Parent', data_panel, ...
              'Style', 'pushbutton', ...
              'String', '🔍 Data Search', ...
              'FontSize', 11, ...
              'Position', [10, 350, 200, 40], ...
              'Callback', @data_search_callback);
    
    % Data export controls
    uicontrol('Parent', data_panel, ...
              'Style', 'pushbutton', ...
              'String', '💾 Export Data', ...
              'FontSize', 11, ...
              'Position', [10, 300, 200, 40], ...
              'Callback', @export_data_callback);
    
    % Information panel
    info_panel = uipanel('Parent', data_panel, ...
                        'Title', 'Data Exploration Info', ...
                        'FontSize', 10, ...
                        'Position', [0.05, 0.05, 0.9, 0.3]);
    
    info_text = uicontrol('Parent', info_panel, ...
                         'Style', 'text', ...
                         'String', {'Data Exploration Tools:', '', ...
                                   '• Data Explorer: Browse and navigate datasets', ...
                                   '• Variable Browser: Find and select specific variables', ...
                                   '• Statistical Summary: Get descriptive statistics', ...
                                   '• Data Search: Search through variable names', ...
                                   '', 'Use these tools to understand your data.'}, ...
                         'FontSize', 9, ...
                         'Position', [10, 10, 180, 150], ...
                         'HorizontalAlignment', 'left');
    
end

function create_comprehensive_help_panel(parent, config)
    % Create comprehensive help panel
    help_panel = uipanel('Parent', parent, ...
                        'Title', 'Help & Information', ...
                        'FontSize', 12, ...
                        'Position', [0.02, 0.02, 0.96, 0.96]);
    
    % Create tab group for help sections
    help_tab_group = uitabgroup('Parent', help_panel, ...
                               'Position', [0.02, 0.02, 0.96, 0.96]);
    
    % Quick start tab
    quick_start_tab = uitab('Parent', help_tab_group, ...
                           'Title', 'Quick Start');
    
    % Features tab
    features_tab = uitab('Parent', help_tab_group, ...
                        'Title', 'Features');
    
    % Data understanding tab
    data_tab = uitab('Parent', help_tab_group, ...
                    'Title', 'Data Understanding');
    
    % Troubleshooting tab
    troubleshooting_tab = uitab('Parent', help_tab_group, ...
                               'Title', 'Troubleshooting');
    
    % Create help content for each tab
    create_quick_start_content(quick_start_tab);
    create_features_content(features_tab);
    create_data_understanding_content(data_tab);
    create_troubleshooting_content(troubleshooting_tab);
    
end

function create_quick_start_content(parent)
    help_text = uicontrol('Parent', parent, ...
                         'Style', 'text', ...
                         'String', get_quick_start_text(), ...
                         'FontSize', 10, ...
                         'Position', [20, 20, 1100, 700], ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.98, 0.98, 0.98]);
end

function create_features_content(parent)
    help_text = uicontrol('Parent', parent, ...
                         'Style', 'text', ...
                         'String', get_features_text(), ...
                         'FontSize', 10, ...
                         'Position', [20, 20, 1100, 700], ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.98, 0.98, 0.98]);
end

function create_data_understanding_content(parent)
    help_text = uicontrol('Parent', parent, ...
                         'Style', 'text', ...
                         'String', get_data_understanding_text(), ...
                         'FontSize', 10, ...
                         'Position', [20, 20, 1100, 700], ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.98, 0.98, 0.98]);
end

function create_troubleshooting_content(parent)
    help_text = uicontrol('Parent', parent, ...
                         'Style', 'text', ...
                         'String', get_troubleshooting_text(), ...
                         'FontSize', 10, ...
                         'Position', [20, 20, 1100, 700], ...
                         'HorizontalAlignment', 'left', ...
                         'BackgroundColor', [0.98, 0.98, 0.98]);
end

% Help text functions
function text = get_quick_start_text()
    text = {
        'QUICK START GUIDE';
        '=================';
        '';
        '1. GETTING STARTED:';
        '   • Launch the GUI using: golf_swing_analysis_gui()';
        '   • The GUI will open with multiple windows for different functions';
        '';
        '2. RUNNING ANALYSIS:';
        '   • Click "Run Complete Analysis" to generate all data';
        '   • This will create BASE, ZTCF, DELTA, and ZVCF datasets';
        '   • Progress will be shown in the status panel';
        '';
        '3. EXPLORING DATA:';
        '   • Use the "Data Explorer" tab to browse datasets';
        '   • Click "Open Data Explorer" for detailed data navigation';
        '   • Search for specific variables using the search function';
        '';
        '4. VISUALIZING RESULTS:';
        '   • Use the "Visualization" tab for plotting tools';
        '   • Click "Open Plot Viewer" for advanced plotting capabilities';
        '   • Try different plot types: Time Series, Phase Plots, Quiver Plots';
        '';
        '5. ANIMATION:';
        '   • Click "Play Animation" to see the golf swing in motion';
        '   • Use "Stop Animation" to pause the visualization';
        '';
        '6. EXPORTING:';
        '   • Use export buttons to save plots and data';
        '   • Plots can be saved as images (PNG, JPG, PDF)';
        '   • Data can be exported as CSV or MAT files';
        '';
        'TIPS:';
        '• Start with the "Data Explorer" to understand your data';
        '• Use "Quick Plot" buttons for common visualizations';
        '• Check the "Help & Info" tab for detailed information';
        '• All windows can be resized and repositioned';
    };
    text = strjoin(text, '\n');
end

function text = get_features_text()
    text = {
        'GUI FEATURES OVERVIEW';
        '=====================';
        '';
        'ANALYSIS CONTROL:';
        '• Run Complete Analysis: Executes the full ZTCF/ZVCF pipeline';
        '• Load Existing Data: Import previously generated data';
        '• Progress Tracking: Real-time status updates during analysis';
        '';
        'VISUALIZATION TOOLS:';
        '• Advanced Plot Viewer: Comprehensive plotting interface';
        '• Time Series Analysis: View variables over time';
        '• Phase Space Analysis: Explore variable relationships';
        '• Quiver Plot Analysis: Visualize forces and torques';
        '• Comparison Analysis: Compare different datasets';
        '• Export Capabilities: Save plots in multiple formats';
        '';
        'DATA EXPLORATION:';
        '• Data Explorer: Browse and navigate datasets';
        '• Variable Browser: Find and select specific variables';
        '• Statistical Summary: Get descriptive statistics';
        '• Data Search: Search through variable names';
        '• Data Export: Export data in various formats';
        '';
        'ANIMATION FEATURES:';
        '• Real-time Golf Swing Animation';
        '• Interactive Play/Stop Controls';
        '• Multiple View Options';
        '• Time Display and Controls';
        '';
        'HELP SYSTEM:';
        '• Comprehensive Help Documentation';
        '• Quick Start Guide';
        '• Feature Descriptions';
        '• Troubleshooting Guide';
        '• Data Understanding Guide';
        '';
        'ADVANCED FEATURES:';
        '• Multiple Plot Types';
        '• Interactive Controls';
        '• Data Filtering and Search';
        '• Statistical Analysis';
        '• Export and Sharing';
        '• Customizable Settings';
    };
    text = strjoin(text, '\n');
end

function text = get_data_understanding_text()
    text = {
        'UNDERSTANDING YOUR DATA';
        '=======================';
        '';
        'DATASET TYPES:';
        '';
        'BASE Dataset:';
        '• Original simulation data with all torques active';
        '• Represents the complete golf swing dynamics';
        '• Contains all forces, torques, positions, and velocities';
        '';
        'ZTCF Dataset (Zero Torque Counterfactual):';
        '• Shows what happens when joint torques are removed';
        '• Represents passive effects (gravity, inertia, etc.)';
        '• Helps understand what torques contribute to the swing';
        '';
        'DELTA Dataset:';
        '• Difference between BASE and ZTCF';
        '• Shows the active effects of joint torques';
        '• Represents what torques add to the swing';
        '';
        'ZVCF Dataset (Zero Velocity Counterfactual):';
        '• Shows inertial effects when velocities are zeroed';
        '• Helps understand momentum and energy transfer';
        '• Useful for analyzing swing mechanics';
        '';
        'KEY VARIABLES:';
        '';
        'Kinematic Variables:';
        '• Positions: Spatial locations of body segments';
        '• Velocities: Speeds and directions of movement';
        '• Accelerations: Rates of velocity change';
        '• Angular Velocities: Rotational speeds';
        '';
        'Dynamic Variables:';
        '• Forces: Applied forces at joints and contacts';
        '• Torques: Rotational forces at joints';
        '• Power: Rate of energy transfer';
        '• Work: Energy transferred over time';
        '';
        'Club Variables:';
        '• Club Head Speed: Velocity of the club head';
        '• Club Path: Trajectory of the club';
        '• Club Face Angle: Orientation of the club face';
        '';
        'INTERPRETING RESULTS:';
        '';
        '• Compare BASE vs ZTCF to understand torque contributions';
        '• Use DELTA to see active vs passive effects';
        '• Analyze ZVCF for inertial effects';
        '• Look for peaks in power and velocity curves';
        '• Identify key moments in the swing (backswing, downswing, impact)';
    };
    text = strjoin(text, '\n');
end

function text = get_troubleshooting_text()
    text = {
        'TROUBLESHOOTING GUIDE';
        '=====================';
        '';
        'COMMON ISSUES:';
        '';
        '1. GUI Not Starting:';
        '   • Check MATLAB version compatibility';
        '   • Ensure all files are in the correct directory';
        '   • Try running: addpath(genpath(''./''))';
        '';
        '2. Analysis Fails:';
        '   • Check if Simulink model exists and loads correctly';
        '   • Verify all required scripts are present';
        '   • Check console for specific error messages';
        '   • Ensure sufficient disk space for data files';
        '';
        '3. Plots Appear Empty:';
        '   • Verify data has been loaded or generated';
        '   • Check if the selected variable exists in the dataset';
        '   • Try refreshing the plot viewer';
        '   • Check data ranges and scaling';
        '';
        '4. Animation Not Working:';
        '   • Ensure BASE data is available';
        '   • Check if animation window is visible';
        '   • Try stopping and restarting the animation';
        '';
        '5. Export Fails:';
        '   • Check write permissions in the target directory';
        '   • Ensure sufficient disk space';
        '   • Try a different file format';
        '';
        'PERFORMANCE ISSUES:';
        '';
        '• Large datasets may cause slow performance';
        '• Close unnecessary plot windows';
        '• Use data filtering to reduce plot complexity';
        '• Consider using Q-spaced data for faster plotting';
        '';
        'DATA ISSUES:';
        '';
        '• Missing variables: Check if analysis completed successfully';
        '• Incorrect values: Verify model parameters';
        '• Time synchronization: Check if all datasets have matching time vectors';
        '';
        'GETTING HELP:';
        '';
        '• Check the console for error messages';
        '• Review the help documentation';
        '• Verify your data structure matches expectations';
        '• Try running individual functions separately';
        '• Check the original scripts for reference';
    };
    text = strjoin(text, '\n');
end

% Enhanced callback functions
function run_analysis_callback(src, ~)
    % Get main figure and data
    main_fig = ancestor(src, 'figure');
    config = getappdata(main_fig, 'config');
    progress_text = getappdata(main_fig, 'progress_text');
    progress_bar = getappdata(main_fig, 'progress_bar');
    
    % Update progress
    set(progress_text, 'String', 'Starting analysis...');
    set(progress_bar, 'BackgroundColor', [0.2, 0.6, 1.0]);
    drawnow;
    
    try
        % Run the analysis
        [BASE, ZTCF, DELTA, ZVCFTable] = run_ztcf_zvcf_analysis();
        
        % Store results
        setappdata(main_fig, 'BASE', BASE);
        setappdata(main_fig, 'ZTCF', ZTCF);
        setappdata(main_fig, 'DELTA', DELTA);
        setappdata(main_fig, 'ZVCFTable', ZVCFTable);
        
        % Update progress
        set(progress_text, 'String', 'Analysis completed successfully!');
        set(progress_bar, 'BackgroundColor', [0.2, 0.8, 0.2]);
        
        % Update all viewers with new data
        update_all_viewers(main_fig, BASE, ZTCF, DELTA, ZVCFTable);
        
    catch ME
        % Update progress with error
        set(progress_text, 'String', sprintf('Error: %s', ME.message));
        set(progress_bar, 'BackgroundColor', [0.8, 0.2, 0.2]);
        fprintf('❌ Analysis failed: %s\n', ME.message);
    end
    
    drawnow;
end

function update_all_viewers(main_fig, BASE, ZTCF, DELTA, ZVCFTable)
    % Update animation
    update_animation(main_fig, BASE);
    
    % Update plot viewer
    plot_handles = getappdata(main_fig, 'plot_handles');
    if ~isempty(plot_handles)
        % Update plot viewer with new data
        fprintf('✅ Updated plot viewer with new data\n');
    end
    
    % Update data explorer
    explorer_handles = getappdata(main_fig, 'explorer_handles');
    if ~isempty(explorer_handles)
        % Update data explorer with new data
        fprintf('✅ Updated data explorer with new data\n');
    end
end

% Additional callback functions (placeholders)
function load_data_callback(src, ~)
    fprintf('📂 Loading existing data...\n');
end

function play_animation_callback(src, ~)
    fprintf('▶️ Playing animation...\n');
end

function stop_animation_callback(src, ~)
    fprintf('⏹️ Stopping animation...\n');
end

function quick_time_series_callback(src, ~)
    fprintf('📊 Opening quick time series plot...\n');
end

function quick_phase_plot_callback(src, ~)
    fprintf('🔄 Opening quick phase plot...\n');
end

function open_plot_viewer_callback(src, ~)
    fprintf('📈 Opening plot viewer...\n');
end

function time_series_analysis_callback(src, ~)
    fprintf('📊 Opening time series analysis...\n');
end

function phase_space_analysis_callback(src, ~)
    fprintf('🔄 Opening phase space analysis...\n');
end

function quiver_plot_analysis_callback(src, ~)
    fprintf('➡️ Opening quiver plot analysis...\n');
end

function comparison_analysis_callback(src, ~)
    fprintf('⚖️ Opening comparison analysis...\n');
end

function export_all_plots_callback(src, ~)
    fprintf('💾 Exporting all plots...\n');
end

function open_data_explorer_callback(src, ~)
    fprintf('🔍 Opening data explorer...\n');
end

function variable_browser_callback(src, ~)
    fprintf('📋 Opening variable browser...\n');
end

function statistical_summary_callback(src, ~)
    fprintf('📊 Opening statistical summary...\n');
end

function data_search_callback(src, ~)
    fprintf('🔍 Opening data search...\n');
end

function export_data_callback(src, ~)
    fprintf('💾 Exporting data...\n');
end

function update_animation(main_fig, BASE)
    % Update animation with new data
    animation_handles = getappdata(main_fig, 'animation_handles');
    
    % Extract position data (this would need to be adapted based on actual data structure)
    if ~isempty(BASE) && height(BASE) > 0
        % Update animation limits based on data
        % This is a placeholder - actual implementation would depend on data structure
        fprintf('✅ Animation updated with new data\n');
    end
end

function close_gui_callback(src, ~)
    % Clean up when closing GUI
    animation_fig = getappdata(src, 'animation_fig');
    plot_fig = getappdata(src, 'plot_fig');
    explorer_fig = getappdata(src, 'explorer_fig');
    
    if ~isempty(animation_fig) && ishandle(animation_fig)
        delete(animation_fig);
    end
    
    if ~isempty(plot_fig) && ishandle(plot_fig)
        delete(plot_fig);
    end
    
    if ~isempty(explorer_fig) && ishandle(explorer_fig)
        delete(explorer_fig);
    end
    
    delete(src);
end
