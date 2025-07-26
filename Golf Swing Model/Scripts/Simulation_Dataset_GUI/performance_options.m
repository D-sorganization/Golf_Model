function settings = performance_options()
% PERFORMANCE_OPTIONS - Dialog for configuring simulation performance options
% Returns a structure with performance settings for the GUI
%
% Output:
%   settings - Structure with fields:
%     .disable_simscape_results - Boolean, disable Simscape Results Explorer
%     .optimize_memory - Boolean, optimize memory usage
%     .fast_restart - Boolean, enable fast restart
%     .apply_settings - Boolean, whether to apply the settings

% Default settings
settings = struct();
settings.disable_simscape_results = true;  % Default to enabled for performance
settings.optimize_memory = true;
settings.fast_restart = false;
settings.apply_settings = false;

% Create the dialog
fig = figure('Name', 'Simulation Performance Options', ...
             'Position', [400, 300, 450, 350], ...
             'MenuBar', 'none', ...
             'ToolBar', 'none', ...
             'Resize', 'off', ...
             'NumberTitle', 'off');

% Title
uicontrol('Style', 'text', ...
          'String', 'Performance Optimization Settings', ...
          'FontSize', 14, 'FontWeight', 'bold', ...
          'Position', [20, 300, 410, 30], ...
          'HorizontalAlignment', 'center');

% Simscape Results Explorer option
simscape_var = settings.disable_simscape_results;
simscape_check = uicontrol('Style', 'checkbox', ...
                          'String', 'Disable Simscape Results Explorer', ...
                          'Value', simscape_var, ...
                          'Position', [20, 250, 250, 25], ...
                          'FontSize', 10, ...
                          'Callback', @update_simscape_info);

% Info label for Simscape option
simscape_info = uicontrol('Style', 'text', ...
                         'String', '✅ Provides ~5% speed improvement', ...
                         'Position', [20, 220, 400, 20], ...
                         'HorizontalAlignment', 'left', ...
                         'FontSize', 9, ...
                         'ForegroundColor', [0, 0.5, 0]);

% Memory optimization option
memory_var = settings.optimize_memory;
memory_check = uicontrol('Style', 'checkbox', ...
                        'String', 'Optimize Memory Usage', ...
                        'Value', memory_var, ...
                        'Position', [20, 180, 200, 25], ...
                        'FontSize', 10);

memory_info = uicontrol('Style', 'text', ...
                       'String', 'Reduces memory allocation during simulation', ...
                       'Position', [20, 150, 400, 20], ...
                       'HorizontalAlignment', 'left', ...
                       'FontSize', 9, ...
                       'ForegroundColor', [0, 0, 0.8]);

% Fast restart option
fast_restart_var = settings.fast_restart;
fast_restart_check = uicontrol('Style', 'checkbox', ...
                              'String', 'Enable Fast Restart', ...
                              'Value', fast_restart_var, ...
                              'Position', [20, 110, 200, 25], ...
                              'FontSize', 10);

fast_restart_info = uicontrol('Style', 'text', ...
                             'String', 'Faster subsequent simulations (may use more memory)', ...
                             'Position', [20, 80, 400, 20], ...
                             'HorizontalAlignment', 'left', ...
                             'FontSize', 9, ...
                             'ForegroundColor', [0, 0, 0.8]);

% Buttons
ok_button = uicontrol('Style', 'pushbutton', ...
                     'String', 'OK', ...
                     'Position', [250, 20, 80, 30], ...
                     'FontSize', 10, ...
                     'Callback', @ok_clicked);

cancel_button = uicontrol('Style', 'pushbutton', ...
                         'String', 'Cancel', ...
                         'Position', [350, 20, 80, 30], ...
                         'FontSize', 10, ...
                         'Callback', @cancel_clicked);

% Store handles for callbacks
setappdata(fig, 'simscape_check', simscape_check);
setappdata(fig, 'simscape_info', simscape_info);
setappdata(fig, 'memory_check', memory_check);
setappdata(fig, 'fast_restart_check', fast_restart_check);
setappdata(fig, 'settings', settings);

% Wait for user input
uiwait(fig);

% Get the final settings
if ishandle(fig)
    settings = getappdata(fig, 'settings');
    delete(fig);
else
    settings = [];  % User closed the window
end

% Callback functions
function update_simscape_info(~, ~)
    simscape_check = getappdata(fig, 'simscape_check');
    simscape_info = getappdata(fig, 'simscape_info');
    
    if get(simscape_check, 'Value')
        set(simscape_info, 'String', '✅ Provides ~5% speed improvement', ...
           'ForegroundColor', [0, 0.5, 0]);
    else
        set(simscape_info, 'String', '⚠️  Simscape Results Explorer enabled', ...
           'ForegroundColor', [0.8, 0.4, 0]);
    end
end

function ok_clicked(~, ~)
    simscape_check = getappdata(fig, 'simscape_check');
    memory_check = getappdata(fig, 'memory_check');
    fast_restart_check = getappdata(fig, 'fast_restart_check');
    
    settings.disable_simscape_results = get(simscape_check, 'Value');
    settings.optimize_memory = get(memory_check, 'Value');
    settings.fast_restart = get(fast_restart_check, 'Value');
    settings.apply_settings = true;
    
    setappdata(fig, 'settings', settings);
    uiresume(fig);
end

function cancel_clicked(~, ~)
    settings.apply_settings = false;
    setappdata(fig, 'settings', settings);
    uiresume(fig);
end

end

function script = generate_performance_script(settings)
% GENERATE_PERFORMANCE_SCRIPT - Generate MATLAB script with performance settings
%
% Input:
%   settings - Structure with performance settings
%
% Output:
%   script - String containing MATLAB script

script_lines = {};

script_lines{end+1} = '% Performance optimization settings';
script_lines{end+1} = '% Generated by Simulation Dataset Generation GUI';
script_lines{end+1} = '';

if settings.disable_simscape_results
    script_lines{end+1} = '% Disable Simscape Results Explorer for better performance';
    script_lines{end+1} = 'set_param(gcs, ''SimscapeLogType'', ''none'');';
    script_lines{end+1} = '';
end

if settings.optimize_memory
    script_lines{end+1} = '% Optimize memory usage';
    script_lines{end+1} = 'set_param(gcs, ''MemoryReduction'', ''on'');';
    script_lines{end+1} = '';
end

if settings.fast_restart
    script_lines{end+1} = '% Enable fast restart';
    script_lines{end+1} = 'set_param(gcs, ''FastRestart'', ''on'');';
    script_lines{end+1} = '';
end

script_lines{end+1} = '% Apply settings';
script_lines{end+1} = 'apply_param_changes = true;';

script = strjoin(script_lines, '\n');

end 