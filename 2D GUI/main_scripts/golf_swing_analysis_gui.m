function golf_swing_analysis_gui()
% GOLF_SWING_ANALYSIS_GUI  Responsive GUI for 2D Golf Swing Analysis.
%   Creates a figure with four tabs (simulation, analysis, plots and
%   skeleton) and centralizes configuration/state using GUIDATA.

    % Load configuration
    config = model_config();

    % Create main figure with responsive layout
    main_fig = uifigure('Name', config.gui_title, ...
                        'Color', config.colors.background, ...
                        'CloseRequestFcn', @close_gui_callback);
    mainLayout = uigridlayout(main_fig, [1 1]);

    % Create tab group
    main_tab_group = uitabgroup(mainLayout);

    % Initialize shared state and store with GUIDATA
    handles = struct();
    handles.config = config;
    handles.main_fig = main_fig;
    handles.main_tab_group = main_tab_group;
    guidata(main_fig, handles);

    % Create individual tabs
    simulation_tab = uitab(main_tab_group, 'Title', '\x1F3AE Simulation');
    analysis_tab   = uitab(main_tab_group, 'Title', '\x1F4CA ZTCF/ZVCF Analysis');
    plots_tab      = uitab(main_tab_group, 'Title', '\x1F4C8 Plots & Interaction');
    skeleton_tab   = uitab(main_tab_group, 'Title', '\x1F9B4 Skeleton Plotter');

    create_simulation_tab(simulation_tab, main_fig);
    create_analysis_tab(analysis_tab, main_fig);
    create_plots_tab(plots_tab, main_fig);
    create_skeleton_tab(skeleton_tab, main_fig);

    fprintf('✅ Enhanced 4-Tab Golf Swing Analysis GUI created successfully\n');
end

function close_gui_callback(src, ~)
% CLOSE_GUI_CALLBACK  Handle closing of the main GUI window.
    delete(src);
end
