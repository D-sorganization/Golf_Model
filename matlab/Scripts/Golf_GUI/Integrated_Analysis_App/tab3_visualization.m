function tab_handles = init_tab3_visualization(parent_tab, app_handles)
% INIT_TAB3_VISUALIZATION - Initialize Visualization Tab
%
% This tab provides the Analysis & Visualization interface using the
% existing SkeletonPlotter and InteractiveSignalPlotter functionality.
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

%% Create UI Layout
% Main container
main_panel = uipanel('Parent', parent_tab, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.94, 0.94, 0.94]);

% Control panel at top
control_panel = uipanel('Parent', main_panel, ...
    'Units', 'normalized', ...
    'Position', [0.01, 0.88, 0.98, 0.11], ...
    'BackgroundColor', [0.9, 0.95, 1], ...
    'Title', 'Data Loading & Visualization', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');

% Visualization container (for SkeletonPlotter)
viz_panel = uipanel('Parent', main_panel, ...
    'Units', 'normalized', ...
    'Position', [0.01, 0.01, 0.98, 0.86], ...
    'BorderType', 'none', ...
    'BackgroundColor', [1, 1, 1]);

%% Create Controls

% Load from Tab 2 button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load from ZTCF Calculation', ...
    'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.52, 0.18, 0.38], ...
    'BackgroundColor', [0.3, 0.6, 0.9], ...
    'ForegroundColor', [1, 1, 1], ...
    'Callback', @(src, event) load_from_tab2(app_handles, tab_handles));

% Load from file button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load from File...', ...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [0.21, 0.52, 0.15, 0.38], ...
    'Callback', @(src, event) load_from_file(app_handles, tab_handles));

% Launch Skeleton Plotter button
tab_handles.launch_button = uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Launch Skeleton Plotter', ...
    'FontSize', 11, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [0.38, 0.52, 0.20, 0.38], ...
    'BackgroundColor', [0.2, 0.7, 0.2], ...
    'ForegroundColor', [1, 1, 1], ...
    'Enable', 'off', ...
    'Callback', @(src, event) launch_skeleton_plotter(app_handles, tab_handles));

% Clear visualization button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Clear Visualization', ...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [0.60, 0.52, 0.15, 0.38], ...
    'Callback', @(src, event) clear_visualization(tab_handles));

% Status text
tab_handles.status_text = uicontrol('Parent', control_panel, ...
    'Style', 'text', ...
    'String', 'No data loaded. Load data from ZTCF Calculation or file.', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.02, 0.05, 0.96, 0.40], ...
    'BackgroundColor', [1, 1, 0.9], ...
    'HorizontalAlignment', 'left');

% Store panels
tab_handles.main_panel = main_panel;
tab_handles.control_panel = control_panel;
tab_handles.viz_panel = viz_panel;

%% Set up Refresh and Cleanup Callbacks
tab_handles.refresh_callback = @() refresh_tab3(app_handles, tab_handles);
tab_handles.cleanup_callback = @() cleanup_tab3(tab_handles);

%% Check if data is already available
check_for_existing_data(app_handles, tab_handles);

end

%% Callback Functions

function load_from_tab2(app_handles, tab_handles)
    % Load data from Tab 2 (ZTCF calculation results)
    
    if app_handles.data_manager.has_ztcf_data()
        ztcf_data = app_handles.data_manager.get_ztcf_data();
        
        % Validate data structure
        if isstruct(ztcf_data) && ...
                isfield(ztcf_data, 'BASEQ') && ...
                isfield(ztcf_data, 'ZTCFQ') && ...
                isfield(ztcf_data, 'DELTAQ')
            
            tab_handles.datasets = ztcf_data;
            
            % Enable launch button
            set(tab_handles.launch_button, 'Enable', 'on');
            
            % Update status
            num_frames = height(ztcf_data.BASEQ);
            set(tab_handles.status_text, 'String', ...
                sprintf('Data loaded from Tab 2: %d frames. Ready to visualize.', num_frames));
            
            fprintf('Tab 3: Data loaded from ZTCF calculation (%d frames)\n', num_frames);
        else
            errordlg('Invalid data structure from Tab 2', 'Data Error');
        end
    else
        warndlg('No data available from Tab 2. Please run ZTCF calculation first.', ...
            'No Data');
    end
end

function load_from_file(app_handles, tab_handles)
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
            
            % Enable launch button
            set(tab_handles.launch_button, 'Enable', 'on');
            
            % Update status
            num_frames = height(datasets.BASEQ);
            set(tab_handles.status_text, 'String', ...
                sprintf('Data loaded from file: %s (%d frames)', file, num_frames));
            
            % Save to config
            app_handles.config.tab3.last_data_file = fullpath;
            guidata(app_handles.main_fig, app_handles);
            
            fprintf('Tab 3: Data loaded from file: %s (%d frames)\n', fullpath, num_frames);
            
        catch ME
            errordlg(sprintf('Failed to load file: %s', ME.message), 'Load Error');
        end
    end
end

function launch_skeleton_plotter(app_handles, tab_handles)
    % Launch the SkeletonPlotter with loaded data
    
    if isempty(tab_handles.datasets)
        warndlg('No data loaded', 'Launch Error');
        return;
    end
    
    try
        % Get path to SkeletonPlotter
        skeleton_plotter_path = fullfile(fileparts(mfilename('fullpath')), ...
            '..', '2D GUI', 'visualization');
        
        % Add to path if needed
        if ~contains(path, skeleton_plotter_path)
            addpath(skeleton_plotter_path);
        end
        
        % Launch SkeletonPlotter
        fprintf('Launching SkeletonPlotter...\n');
        skeleton_handles = SkeletonPlotter(tab_handles.datasets);
        
        % Store handles
        tab_handles.skeleton_plotter_handles = skeleton_handles;
        
        % Update status
        set(tab_handles.status_text, 'String', ...
            'SkeletonPlotter launched successfully. Visualization is active.');
        
    catch ME
        errordlg(sprintf('Failed to launch SkeletonPlotter: %s', ME.message), ...
            'Launch Error');
        fprintf('Error launching SkeletonPlotter: %s\n', ME.message);
    end
end

function clear_visualization(tab_handles)
    % Clear current visualization
    
    % Close SkeletonPlotter if open
    if ~isempty(tab_handles.skeleton_plotter_handles)
        try
            if isfield(tab_handles.skeleton_plotter_handles, 'fig') && ...
                    ishandle(tab_handles.skeleton_plotter_handles.fig)
                close(tab_handles.skeleton_plotter_handles.fig);
            end
        catch
            % Figure may already be closed
        end
        tab_handles.skeleton_plotter_handles = [];
    end
    
    % Clear datasets
    tab_handles.datasets = [];
    
    % Disable launch button
    set(tab_handles.launch_button, 'Enable', 'off');
    
    % Update status
    set(tab_handles.status_text, 'String', ...
        'Visualization cleared. Load data to continue.');
    
    fprintf('Tab 3: Visualization cleared\n');
end

function check_for_existing_data(app_handles, tab_handles)
    % Check if data is already available from Tab 2
    
    if app_handles.data_manager.has_ztcf_data()
        % Auto-load from Tab 2
        load_from_tab2(app_handles, tab_handles);
    end
end

function refresh_tab3(app_handles, tab_handles)
    % Refresh tab with latest data
    
    fprintf('Tab 3: Refreshing...\n');
    check_for_existing_data(app_handles, tab_handles);
end

function cleanup_tab3(tab_handles)
    % Cleanup when tab or app is closed
    
    fprintf('Tab 3: Cleaning up...\n');
    
    % Close SkeletonPlotter if open
    if ~isempty(tab_handles.skeleton_plotter_handles)
        try
            if isfield(tab_handles.skeleton_plotter_handles, 'fig') && ...
                    ishandle(tab_handles.skeleton_plotter_handles.fig)
                close(tab_handles.skeleton_plotter_handles.fig);
            end
        catch
            % Already closed
        end
    end
    
    fprintf('Tab 3: Cleanup complete\n');
end

