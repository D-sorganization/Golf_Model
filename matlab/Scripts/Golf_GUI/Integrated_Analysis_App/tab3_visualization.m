function tab_handles = tab3_visualization(parent_tab, app_handles)
% TAB3_VISUALIZATION - Initialize Visualization Tab
%
% This tab provides embedded 3D skeleton visualization directly in the tab.
% Auto-loads default data files on startup.
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

%% Default Data Files Path
default_data_path = fullfile(fileparts(mfilename('fullpath')), ...
    '..', 'Simscape Multibody Data Plotters', 'Matlab Versions', 'SkeletonPlotter');

%% Create UI Layout
% Control panel at top (compact horizontal layout)
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

% Load 3 separate files button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load 3 Files...', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.01, 0.25, 0.11, 0.50], ...
    'BackgroundColor', [0.2, 0.7, 0.2], ...
    'ForegroundColor', [1, 1, 1], ...
    'TooltipString', 'Load BASEQ, ZTCFQ, DELTAQ separately', ...
    'Callback', @(src, event) load_three_files(app_handles, tab_handles, viz_panel));

% Load combined file button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load Combined...', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.13, 0.25, 0.12, 0.50], ...
    'TooltipString', 'Load single MAT file with all datasets', ...
    'Callback', @(src, event) load_from_file(app_handles, tab_handles, viz_panel));

% Load from Tab 2 button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load from Tab 2', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.26, 0.25, 0.12, 0.50], ...
    'BackgroundColor', [0.3, 0.6, 0.9], ...
    'ForegroundColor', [1, 1, 1], ...
    'TooltipString', 'Load from ZTCF Calculation', ...
    'Callback', @(src, event) load_from_tab2(app_handles, tab_handles, viz_panel));

% Reload defaults button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Reload Defaults', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.39, 0.25, 0.12, 0.50], ...
    'TooltipString', 'Reload default example data', ...
    'Callback', @(src, event) load_default_data(app_handles, tab_handles, viz_panel, default_data_path));

% Clear button
uicontrol('Parent', control_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Clear', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.52, 0.25, 0.08, 0.50], ...
    'Callback', @(src, event) clear_visualization(tab_handles, viz_panel));

% Status text
tab_handles.status_text = uicontrol('Parent', control_panel, ...
    'Style', 'text', ...
    'String', 'Loading default data...', ...
    'FontSize', 9, ...
    'Units', 'normalized', ...
    'Position', [0.62, 0.10, 0.37, 0.80], ...
    'BackgroundColor', [1, 1, 0.9], ...
    'HorizontalAlignment', 'left');

% Store panels
tab_handles.control_panel = control_panel;
tab_handles.viz_panel = viz_panel;
tab_handles.default_data_path = default_data_path;

%% Set up Refresh and Cleanup Callbacks
tab_handles.refresh_callback = @() refresh_tab3(app_handles, tab_handles, viz_panel, default_data_path);
tab_handles.cleanup_callback = @() cleanup_tab3(tab_handles);

%% Auto-load default data on startup
fprintf('Tab 3: Auto-loading default data...\n');
load_default_data(app_handles, tab_handles, viz_panel, default_data_path);

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
            '  • "Load 3 Files..." - Select BASEQ, ZTCFQ, DELTAQ separately', ...
            '  • "Load Combined..." - Load single MAT file with all data', ...
            '  • "Load from Tab 2" - Use ZTCF calculation results', ...
            '  • "Reload Defaults" - Load example data', ...
            '', ...
            'Default data loads automatically on startup'
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

function load_default_data(app_handles, tab_handles, viz_panel, default_data_path)
    % Load default data files from repository
    
    try
        % Construct full paths
        baseq_file = fullfile(default_data_path, 'BASEQ.mat');
        ztcfq_file = fullfile(default_data_path, 'ZTCFQ.mat');
        deltaq_file = fullfile(default_data_path, 'DELTAQ.mat');
        
        % Check if files exist
        if ~exist(baseq_file, 'file') || ~exist(ztcfq_file, 'file') || ~exist(deltaq_file, 'file')
            warning('Default data files not found at: %s', default_data_path);
            set(tab_handles.status_text, 'String', ...
                '⚠ Default data not found. Use "Load 3 Files..." to select data.');
            display_welcome_message(viz_panel);
            return;
        end
        
        fprintf('Loading default data files:\n');
        fprintf('  BASEQ:  %s\n', baseq_file);
        fprintf('  ZTCFQ:  %s\n', ztcfq_file);
        fprintf('  DELTAQ: %s\n', deltaq_file);
        
        % Load each file
        BASEQ_data = load(baseq_file);
        ZTCFQ_data = load(ztcfq_file);
        DELTAQ_data = load(deltaq_file);
        
        % Extract tables (handle both direct table and structure with table)
        if istable(BASEQ_data)
            BASEQ = BASEQ_data;
        elseif isstruct(BASEQ_data) && isfield(BASEQ_data, 'BASEQ')
            BASEQ = BASEQ_data.BASEQ;
        else
            % First field
            fields = fieldnames(BASEQ_data);
            BASEQ = BASEQ_data.(fields{1});
        end
        
        if istable(ZTCFQ_data)
            ZTCFQ = ZTCFQ_data;
        elseif isstruct(ZTCFQ_data) && isfield(ZTCFQ_data, 'ZTCFQ')
            ZTCFQ = ZTCFQ_data.ZTCFQ;
        else
            fields = fieldnames(ZTCFQ_data);
            ZTCFQ = ZTCFQ_data.(fields{1});
        end
        
        if istable(DELTAQ_data)
            DELTAQ = DELTAQ_data;
        elseif isstruct(DELTAQ_data) && isfield(DELTAQ_data, 'DELTAQ')
            DELTAQ = DELTAQ_data.DELTAQ;
        else
            fields = fieldnames(DELTAQ_data);
            DELTAQ = DELTAQ_data.(fields{1});
        end
        
        % Create datasets structure
        datasets = struct('BASEQ', BASEQ, 'ZTCFQ', ZTCFQ, 'DELTAQ', DELTAQ);
        tab_handles.datasets = datasets;
        
        % Update status
        num_frames = height(BASEQ);
        set(tab_handles.status_text, 'String', ...
            sprintf('✓ Default data loaded (%d frames) - Ready!', num_frames));
        
        % Embed plotter
        embed_skeleton_plotter(viz_panel, datasets, tab_handles);
        
        fprintf('✓ Default data loaded successfully (%d frames)\n', num_frames);
        
    catch ME
        warning('Failed to load default data: %s', ME.message);
        set(tab_handles.status_text, 'String', ...
            sprintf('⚠ Could not load defaults: %s', ME.message));
        display_welcome_message(viz_panel);
    end
end

function load_three_files(app_handles, tab_handles, viz_panel)
    % Load three separate MAT files for BASEQ, ZTCFQ, DELTAQ
    
    % Get starting directory
    if isfield(app_handles.config, 'tab3') && ...
            isfield(app_handles.config.tab3, 'last_data_file') && ...
            ~isempty(app_handles.config.tab3.last_data_file)
        start_path = fileparts(app_handles.config.tab3.last_data_file);
    else
        start_path = tab_handles.default_data_path;
    end
    
    try
        % Load BASEQ
        [file1, path1] = uigetfile('*.mat', 'Select BASEQ file', start_path);
        if file1 == 0
            return; % User cancelled
        end
        baseq_file = fullfile(path1, file1);
        BASEQ_data = load(baseq_file);
        
        % Load ZTCFQ
        [file2, path2] = uigetfile('*.mat', 'Select ZTCFQ file', path1);
        if file2 == 0
            return;
        end
        ztcfq_file = fullfile(path2, file2);
        ZTCFQ_data = load(ztcfq_file);
        
        % Load DELTAQ
        [file3, path3] = uigetfile('*.mat', 'Select DELTAQ file', path2);
        if file3 == 0
            return;
        end
        deltaq_file = fullfile(path3, file3);
        DELTAQ_data = load(deltaq_file);
        
        % Extract tables from loaded data
        BASEQ = extract_table_from_struct(BASEQ_data, 'BASEQ');
        ZTCFQ = extract_table_from_struct(ZTCFQ_data, 'ZTCFQ');
        DELTAQ = extract_table_from_struct(DELTAQ_data, 'DELTAQ');
        
        % Create datasets structure
        datasets = struct('BASEQ', BASEQ, 'ZTCFQ', ZTCFQ, 'DELTAQ', DELTAQ);
        tab_handles.datasets = datasets;
        
        % Update status
        num_frames = height(BASEQ);
        set(tab_handles.status_text, 'String', ...
            sprintf('✓ Loaded 3 files (%d frames) - Visualizing...', num_frames));
        
        % Save path to config
        app_handles.config.tab3.last_data_file = baseq_file;
        guidata(app_handles.main_fig, app_handles);
        
        % Embed plotter
        embed_skeleton_plotter(viz_panel, datasets, tab_handles);
        
        fprintf('Tab 3: Loaded 3 separate files (%d frames)\n', num_frames);
        
    catch ME
        errordlg(sprintf('Failed to load files: %s', ME.message), 'Load Error');
        fprintf('Error loading 3 files: %s\n', ME.message);
    end
end

function table_data = extract_table_from_struct(loaded_data, expected_name)
    % Helper to extract table from loaded MAT file structure
    
    if istable(loaded_data)
        % Data is already a table
        table_data = loaded_data;
    elseif isstruct(loaded_data)
        % Check for expected field name first
        if isfield(loaded_data, expected_name)
            table_data = loaded_data.(expected_name);
        else
            % Use first field
            fields = fieldnames(loaded_data);
            table_data = loaded_data.(fields{1});
        end
    else
        error('Unexpected data format');
    end
    
    % Verify it's a table
    if ~istable(table_data)
        error('Loaded data is not a table');
    end
end

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
    % Load data from combined MAT file (single file with all datasets)
    
    % Get last directory from config
    if isfield(app_handles.config, 'tab3') && ...
            isfield(app_handles.config.tab3, 'last_data_file') && ...
            ~isempty(app_handles.config.tab3.last_data_file)
        start_path = fileparts(app_handles.config.tab3.last_data_file);
    else
        start_path = tab_handles.default_data_path;
    end
    
    [file, path] = uigetfile('*.mat', 'Load Combined Golf Data', start_path);
    
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
            
            fprintf('Tab 3: Data loaded from combined file: %s (%d frames)\n', fullpath, num_frames);
            
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
        'Visualization cleared. Use buttons to load data.');
    
    fprintf('Tab 3: Visualization cleared\n');
end

function refresh_tab3(app_handles, tab_handles, viz_panel, default_data_path)
    % Refresh tab with latest data
    
    fprintf('Tab 3: Refreshing...\n');
    
    % Reload if not loaded
    if ~tab_handles.data_loaded
        load_default_data(app_handles, tab_handles, viz_panel, default_data_path);
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
