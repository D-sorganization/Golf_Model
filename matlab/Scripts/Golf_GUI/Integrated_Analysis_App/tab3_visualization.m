function tab_handles = tab3_visualization(parent_tab, app_handles)
% TAB3_VISUALIZATION - Initialize Visualization Tab
%
% This tab launches the full SkeletonPlotter in a managed window.
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
tab_handles.skeleton_plotter_fig = [];
tab_handles.datasets = [];
tab_handles.data_loaded = false;

%% Default Data Files Path
default_data_path = fullfile(fileparts(mfilename('fullpath')), ...
    '..', 'Simscape Multibody Data Plotters', 'Matlab Versions', 'SkeletonPlotter');

%% Add visualization path
viz_path = fullfile(fileparts(mfilename('fullpath')), ...
    '..', '2D GUI', 'visualization');
if ~contains(path, viz_path)
    addpath(viz_path);
end

%% Create UI Layout
% Main instruction panel (full tab space with centered message)
main_panel = uipanel('Parent', parent_tab, ...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 1], ...
    'BorderType', 'none', ...
    'BackgroundColor', [0.94, 0.94, 0.94]);

% Large centered message
msg_text = uicontrol('Parent', main_panel, ...
    'Style', 'text', ...
    'String', {
        '', ...
        '🏌️ Golf Swing 3D Visualization', ...
        '', ...
        'The full-featured SkeletonPlotter opens in a separate window.', ...
        '', ...
        'Default example data loads automatically on first launch.', ...
        'The visualization window includes:', ...
        '  • Full 3D golf swing animation with realistic body rendering', ...
        '  • Playback controls (play, pause, speed adjustment)', ...
        '  • Interactive signal plotter button', ...
        '  • Force and torque vector visualization', ...
        '  • Dataset switching (BASEQ, ZTCFQ, DELTAQ)', ...
        '  • Recording and export capabilities', ...
        '', ...
        'Use the buttons below to control the visualization:', ...
        ''
    }, ...
    'FontSize', 11, ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.35, 0.8, 0.5], ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'HorizontalAlignment', 'center');

% Button panel at bottom
button_panel = uipanel('Parent', main_panel, ...
    'Units', 'normalized', ...
    'Position', [0.2, 0.15, 0.6, 0.15], ...
    'BackgroundColor', [0.9, 0.95, 1], ...
    'Title', 'Visualization Controls', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');

% Launch with defaults button (prominent)
uicontrol('Parent', button_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Launch Visualization (Default Data)', ...
    'FontSize', 11, ...
    'FontWeight', 'bold', ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.55, 0.8, 0.35], ...
    'BackgroundColor', [0.2, 0.7, 0.2], ...
    'ForegroundColor', [1, 1, 1], ...
    'TooltipString', 'Open full SkeletonPlotter with example data', ...
    'Callback', @(src, event) launch_with_defaults(app_handles, tab_handles, default_data_path));

% Load 3 files button
uicontrol('Parent', button_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load 3 Files & Launch...', ...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.10, 0.28, 0.35], ...
    'TooltipString', 'Select BASEQ, ZTCFQ, DELTAQ separately', ...
    'Callback', @(src, event) load_three_files_and_launch(app_handles, tab_handles));

% Load combined file button
uicontrol('Parent', button_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Load Combined & Launch...', ...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [0.36, 0.10, 0.28, 0.35], ...
    'TooltipString', 'Load single MAT file with all datasets', ...
    'Callback', @(src, event) load_combined_and_launch(app_handles, tab_handles));

% Close visualization button
uicontrol('Parent', button_panel, ...
    'Style', 'pushbutton', ...
    'String', 'Close Visualization', ...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [0.67, 0.10, 0.28, 0.35], ...
    'Callback', @(src, event) close_visualization(tab_handles));

% Status text
tab_handles.status_text = uicontrol('Parent', main_panel, ...
    'Style', 'text', ...
    'String', 'Ready. Click "Launch Visualization" to open the 3D golf swing plotter.', ...
    'FontSize', 10, ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.08, 0.8, 0.05], ...
    'BackgroundColor', [1, 1, 0.9], ...
    'HorizontalAlignment', 'center');

% Store panels
tab_handles.main_panel = main_panel;
tab_handles.default_data_path = default_data_path;

%% Set up Refresh and Cleanup Callbacks
tab_handles.refresh_callback = @() refresh_tab3();
tab_handles.cleanup_callback = @() cleanup_tab3(tab_handles);

%% Auto-launch with default data on startup
fprintf('Tab 3: Auto-launching visualization with default data...\n');
pause(0.5); % Brief pause to let UI render
launch_with_defaults(app_handles, tab_handles, default_data_path);

end

%% Callback Functions

function launch_with_defaults(app_handles, tab_handles, default_data_path)
    % Launch SkeletonPlotter with default data
    
    try
        % Check if already open
        if ~isempty(tab_handles.skeleton_plotter_fig) && ishandle(tab_handles.skeleton_plotter_fig)
            figure(tab_handles.skeleton_plotter_fig); % Bring to front
            set(tab_handles.status_text, 'String', '✓ Visualization window brought to front');
            return;
        end
        
        % Load default data
        baseq_file = fullfile(default_data_path, 'BASEQ.mat');
        ztcfq_file = fullfile(default_data_path, 'ZTCFQ.mat');
        deltaq_file = fullfile(default_data_path, 'DELTAQ.mat');
        
        if ~exist(baseq_file, 'file')
            errordlg(sprintf('Default data not found at:\n%s', default_data_path), 'Data Not Found');
            return;
        end
        
        fprintf('Loading default data...\n');
        BASEQ_data = load(baseq_file);
        ZTCFQ_data = load(ztcfq_file);
        DELTAQ_data = load(deltaq_file);
        
        % Extract tables
        BASEQ = extract_table(BASEQ_data, 'BASEQ');
        ZTCFQ = extract_table(ZTCFQ_data, 'ZTCFQ');
        DELTAQ = extract_table(DELTAQ_data, 'DELTAQ');
        
        % Launch SkeletonPlotter
        fprintf('Launching SkeletonPlotter...\n');
        SkeletonPlotter(BASEQ, ZTCFQ, DELTAQ);
        
        % Find the figure
        all_figs = findall(0, 'Type', 'figure');
        for i = 1:length(all_figs)
            if contains(get(all_figs(i), 'Name'), 'Golf Swing Plotter')
                tab_handles.skeleton_plotter_fig = all_figs(i);
                break;
            end
        end
        
        tab_handles.data_loaded = true;
        num_frames = height(BASEQ);
        set(tab_handles.status_text, 'String', ...
            sprintf('✓ Visualization launched successfully (%d frames)', num_frames));
        fprintf('✓ SkeletonPlotter launched with default data (%d frames)\n', num_frames);
        
    catch ME
        errordlg(sprintf('Failed to launch visualization: %s', ME.message), 'Launch Error');
        fprintf('Error: %s\n', ME.message);
        set(tab_handles.status_text, 'String', sprintf('✗ Launch failed: %s', ME.message));
    end
end

function load_three_files_and_launch(app_handles, tab_handles)
    % Load 3 separate files and launch
    
    start_path = tab_handles.default_data_path;
    
    try
        % Load BASEQ
        [file1, path1] = uigetfile('*.mat', 'Select BASEQ file', start_path);
        if file1 == 0, return; end
        BASEQ_data = load(fullfile(path1, file1));
        BASEQ = extract_table(BASEQ_data, 'BASEQ');
        
        % Load ZTCFQ
        [file2, path2] = uigetfile('*.mat', 'Select ZTCFQ file', path1);
        if file2 == 0, return; end
        ZTCFQ_data = load(fullfile(path2, file2));
        ZTCFQ = extract_table(ZTCFQ_data, 'ZTCFQ');
        
        % Load DELTAQ
        [file3, path3] = uigetfile('*.mat', 'Select DELTAQ file', path2);
        if file3 == 0, return; end
        DELTAQ_data = load(fullfile(path3, file3));
        DELTAQ = extract_table(DELTAQ_data, 'DELTAQ');
        
        % Launch
        fprintf('Launching SkeletonPlotter with custom data...\n');
        SkeletonPlotter(BASEQ, ZTCFQ, DELTAQ);
        
        % Find figure
        all_figs = findall(0, 'Type', 'figure');
        for i = 1:length(all_figs)
            if contains(get(all_figs(i), 'Name'), 'Golf Swing Plotter')
                tab_handles.skeleton_plotter_fig = all_figs(i);
                break;
            end
        end
        
        tab_handles.data_loaded = true;
        set(tab_handles.status_text, 'String', '✓ Visualization launched with custom data');
        fprintf('✓ SkeletonPlotter launched with custom data\n');
        
    catch ME
        errordlg(sprintf('Failed to load/launch: %s', ME.message), 'Error');
    end
end

function load_combined_and_launch(app_handles, tab_handles)
    % Load combined file and launch
    
    start_path = tab_handles.default_data_path;
    [file, path] = uigetfile('*.mat', 'Load Combined Golf Data', start_path);
    
    if file ~= 0
        try
            loaded = load(fullfile(path, file));
            
            % Extract datasets
            if isfield(loaded, 'BASEQ')
                BASEQ = loaded.BASEQ;
                ZTCFQ = loaded.ZTCFQ;
                DELTAQ = loaded.DELTAQ;
            elseif isfield(loaded, 'datasets')
                BASEQ = loaded.datasets.BASEQ;
                ZTCFQ = loaded.datasets.ZTCFQ;
                DELTAQ = loaded.datasets.DELTAQ;
            else
                error('Could not find BASEQ, ZTCFQ, DELTAQ in file');
            end
            
            % Launch
            fprintf('Launching SkeletonPlotter...\n');
            SkeletonPlotter(BASEQ, ZTCFQ, DELTAQ);
            
            % Find figure
            all_figs = findall(0, 'Type', 'figure');
            for i = 1:length(all_figs)
                if contains(get(all_figs(i), 'Name'), 'Golf Swing Plotter')
                    tab_handles.skeleton_plotter_fig = all_figs(i);
                    break;
                end
            end
            
            tab_handles.data_loaded = true;
            set(tab_handles.status_text, 'String', sprintf('✓ Visualization launched: %s', file));
            fprintf('✓ SkeletonPlotter launched\n');
            
        catch ME
            errordlg(sprintf('Failed to load/launch: %s', ME.message), 'Error');
        end
    end
end

function close_visualization(tab_handles)
    % Close the SkeletonPlotter window
    
    if ~isempty(tab_handles.skeleton_plotter_fig) && ishandle(tab_handles.skeleton_plotter_fig)
        close(tab_handles.skeleton_plotter_fig);
        tab_handles.skeleton_plotter_fig = [];
        tab_handles.data_loaded = false;
        set(tab_handles.status_text, 'String', 'Visualization closed. Click "Launch" to reopen.');
        fprintf('Visualization window closed\n');
    else
        set(tab_handles.status_text, 'String', 'No visualization window open');
    end
end

function table_data = extract_table(loaded_data, expected_name)
    % Helper to extract table from loaded structure
    
    if istable(loaded_data)
        table_data = loaded_data;
    elseif isstruct(loaded_data)
        if isfield(loaded_data, expected_name)
            table_data = loaded_data.(expected_name);
        else
            fields = fieldnames(loaded_data);
            table_data = loaded_data.(fields{1});
        end
    else
        error('Unexpected data format');
    end
end

function refresh_tab3()
    % Refresh callback (placeholder)
end

function cleanup_tab3(tab_handles)
    % Cleanup when closing
    
    fprintf('Tab 3: Cleaning up...\n');
    
    % Close visualization window if open
    if ~isempty(tab_handles.skeleton_plotter_fig) && ishandle(tab_handles.skeleton_plotter_fig)
        try
            close(tab_handles.skeleton_plotter_fig);
        catch
            % Already closed
        end
    end
    
    fprintf('Tab 3: Cleanup complete\n');
end
