function tab_handles = init_tab3_visualization(parent_tab, app_handles)
% INIT_TAB3_VISUALIZATION - Initialize Visualization Tab
%
% This tab provides embedded 3D skeleton visualization directly in the tab.
%
% Inputs:
%   parent_tab   - Handle to the tab UI container
%   app_handles  - Main application handles structure
%
% Returns:
%   tab_handles  - Handles structure for this tab

%% Initialize Tab Handles
tab_handles = struct();
tab_handles.parent = parent_tab;
tab_handles.skeleton_plotter_handles = [];
tab_handles.datasets = [];
tab_handles.data_loaded = false;

%% Create UI Layout
% Control panel at top (smaller, just for data loading)
control_panel = uipanel('Parent', parent_tab, ...
    'Units', 'normalized', ...
    'Position', [0, 0.92, 1, 0.08], ...
    'BackgroundColor', [0.9, 0.95, 1], ...
    'BorderType', 'line');

% Visualization container (main area for embedded plotter)
viz_panel = uipanel('Parent', parent_tab, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 0.92], ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.94, 0.94, 0.94]);

%% Create Controls (Compact horizontal layout)

% Load from Tab 2 button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load from Tab 2', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.01, 0.25, 0.12, 0.50], ...
    'BackgroundColor', [0.3, 0.6, 0.9], ...
    'ForegroundColor', [1, 1, 1], ...
    'Callback', @(src, event) load_from_tab2(app_handles, tab_handles, viz_panel));

% Load from file button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load from File...', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.14, 0.25, 0.12, 0.50], ...
    'Callback', @(src, event) load_from_file(app_handles, tab_handles, viz_panel));

% Clear button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Clear', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.27, 0.25, 0.08, 0.50], ...
    'Callback', @(src, event) clear_visualization(tab_handles, viz_panel));

% Status text
tab_handles.status_text = uicontrol('Parent', control_panel, ...
    'Style', 'text', ...
    'String', 'No data loaded. Use buttons on the left to load golf swing data.', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.37, 0.10, 0.62, 0.80], ...
    'BackgroundColor', [1, 1, 0.9], ...
    'HorizontalAlignment', 'left');

% Store panels
tab_handles.control_panel = control_panel;
tab_handles.viz_panel = viz_panel;

% Display initial message
display_welcome_message(viz_panel);

%% Set up Refresh and Cleanup Callbacks
tab_handles.refresh_callback = @() refresh_tab3(app_handles, tab_handles, viz_panel);
tab_handles.cleanup_callback = @() cleanup_tab3(tab_handles);

%% Check if data is already available
check_for_existing_data(app_handles, tab_handles, viz_panel);

end

%% Helper Functions

function display_welcome_message(viz_panel)
    % Display welcome message in visualization panel
    delete(allchild(viz_panel));
    
    welcome_text = uicontrol('Parent', viz_panel, ...
        'Style', 'text', ...
        'String', {
            '', ...
            '🏌️ Golf Swing Visualization', ...
            '', ...
            'Load data to begin:', ...
            '  • Click "Load from Tab 2" to use calculated ZTCF data', ...
            '  • Click "Load from File..." to load from a MAT file', ...
            '', ...
            'Data must contain BASEQ, ZTCFQ, and DELTAQ tables'
        }, ...
        'FontSize', 12, ...
        'Units', 'normalized', ...
        'Position', [0.2, 0.3, 0.6, 0.4], ...
        'BackgroundColor', [0.94, 0.94, 0.94], ...
        'HorizontalAlignment', 'center');
end

function embed_skeleton_plotter(viz_panel, datasets, tab_handles)
    % Embed the skeleton plotter in the visualization panel
    
    try
        fprintf('Embedding skeleton plotter in Tab 3...\n');
        
        % Clear existing content
        delete(allchild(viz_panel));
        
        % Create embedded plotter
        plotter_handles = EmbeddedSkeletonPlotter(viz_panel, ...
            datasets.BASEQ, datasets.ZTCFQ, datasets.DELTAQ);
        
        % Store handles
        tab_handles.skeleton_plotter_handles = plotter_handles;
        tab_handles.data_loaded = true;
        
        fprintf('✓ Skeleton plotter embedded successfully\n');
        
    catch ME
        errordlg(sprintf('Failed to embed skeleton plotter: %s', ME.message), ...
            'Embedding Error');
        fprintf('Error embedding skeleton plotter: %s\n', ME.message);
        disp(ME.stack);
        display_welcome_message(viz_panel);
    end
end

%% Callback Functions

function load_from_tab2(app_handles, tab_handles, viz_panel)
    % Load data from Tab 2 (ZTCF calculation results)
    
    if app_handles.data_manager.has_ztcf_data()
        ztcf_data = app_handles.data_manager.get_ztcf_data();
        
        % Validate data structure
        if isstruct(ztcf_data) && ...
                isfield(ztcf_data, 'BASEQ') && ...
                isfield(ztcf_data, 'ZTCFQ') && ...
                isfield(ztcf_data, 'DELTAQ')
            
            tab_handles.datasets = ztcf_data;
            
            % Update status
            num_frames = height(ztcf_data.BASEQ);
            set(tab_handles.status_text, 'String', ...
                sprintf('✓ Data loaded from Tab 2 (%d frames) - Visualizing...', num_frames));
            
            % Embed plotter
            embed_skeleton_plotter(viz_panel, ztcf_data, tab_handles);
            
            fprintf('Tab 3: Data loaded from ZTCF calculation (%d frames)\n', num_frames);
        else
            errordlg('Invalid data structure from Tab 2', 'Data Error');
        end
    else
        warndlg('No data available from Tab 2. Please run ZTCF calculation first.', ...
            'No Data');
    end
end

function load_from_file(app_handles, tab_handles, viz_panel)
    % Load data from MAT file
    
    % Get last directory from config
    if isfield(app_handles.config, 'tab3') && ...
            isfield(app_handles.config.tab3, 'last_data_file') && ...
            ~isempty(app_handles.config.tab3.last_data_file)
        start_path = fileparts(app_handles.config.tab3.last_data_file);
    else
        start_path = pwd;
    end
    
    [file, path] = uigetfile('*.mat', 'Load Golf Data', start_path);
    
    if file ~= 0
        fullpath = fullfile(path, file);
        
        try
            loaded = load(fullpath);
            
            % Try to find BASEQ, ZTCFQ, DELTAQ in loaded data
            datasets = struct();
            
            if isfield(loaded, 'BASEQ')
                datasets.BASEQ = loaded.BASEQ;
            elseif isfield(loaded, 'datasets') && isfield(loaded.datasets, 'BASEQ')
                datasets = loaded.datasets;
            else
                error('Could not find BASEQ in file');
            end
            
            % Validate all required fields
            if ~isfield(datasets, 'ZTCFQ') || ~isfield(datasets, 'DELTAQ')
                error('File must contain BASEQ, ZTCFQ, and DELTAQ');
            end
            
            % Store datasets
            tab_handles.datasets = datasets;
            
            % Update status
            num_frames = height(datasets.BASEQ);
            set(tab_handles.status_text, 'String', ...
                sprintf('✓ Loaded: %s (%d frames) - Visualizing...', file, num_frames));
            
            % Save to config
            app_handles.config.tab3.last_data_file = fullpath;
            guidata(app_handles.main_fig, app_handles);
            
            % Embed plotter
            embed_skeleton_plotter(viz_panel, datasets, tab_handles);
            
            fprintf('Tab 3: Data loaded from file: %s (%d frames)\n', fullpath, num_frames);
            
        catch ME
            errordlg(sprintf('Failed to load file: %s', ME.message), 'Load Error');
            display_welcome_message(viz_panel);
        end
    end
end

function clear_visualization(tab_handles, viz_panel)
    % Clear current visualization
    
    % Clear plotter
    tab_handles.skeleton_plotter_handles = [];
    tab_handles.datasets = [];
    tab_handles.data_loaded = false;
    
    % Display welcome message
    display_welcome_message(viz_panel);
    
    % Update status
    set(tab_handles.status_text, 'String', ...
        'Visualization cleared. Load data to continue.');
    
    fprintf('Tab 3: Visualization cleared\n');
end

function check_for_existing_data(app_handles, tab_handles, viz_panel)
    % Check if data is already available from Tab 2
    
    if app_handles.data_manager.has_ztcf_data()
        % Auto-load from Tab 2
        load_from_tab2(app_handles, tab_handles, viz_panel);
    end
end

function refresh_tab3(app_handles, tab_handles, viz_panel)
    % Refresh tab with latest data
    
    fprintf('Tab 3: Refreshing...\n');
    
    % Check for new data
    if ~tab_handles.data_loaded
        check_for_existing_data(app_handles, tab_handles, viz_panel);
    end
end

function cleanup_tab3(tab_handles)
    % Cleanup when tab or app is closed
    
    fprintf('Tab 3: Cleaning up...\n');
    
    % Clear plotter handles
    tab_handles.skeleton_plotter_handles = [];
    tab_handles.datasets = [];
    
    fprintf('Tab 3: Cleanup complete\n');
end
