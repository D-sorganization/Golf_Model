function handles = configuration_manager(handles, action, varargin)
    % CONFIGURATION_MANAGER - Manage user preferences and configuration
    %
    % This function handles loading, saving, and applying user preferences
    % and configuration settings for the GUI.
    %
    % Inputs:
    %   handles - GUI handles structure
    %   action - Action to perform: 'load_preferences', 'save_preferences', 
    %            'apply_preferences', 'save_config', 'load_config'
    %   varargin - Additional arguments depending on action
    %
    % Outputs:
    %   handles - Updated handles structure
    %
    % Usage:
    %   handles = configuration_manager(handles, 'load_preferences');
    %   handles = configuration_manager(handles, 'save_preferences');
    %   handles = configuration_manager(handles, 'apply_preferences');
    %   handles = configuration_manager(handles, 'save_config', config);
    %   handles = configuration_manager(handles, 'load_config');
    
    switch lower(action)
        case 'load_preferences'
            handles = loadUserPreferences(handles);
        case 'save_preferences'
            handles = saveUserPreferences(handles);
        case 'apply_preferences'
            handles = applyUserPreferences(handles);
        case 'save_config'
            if nargin >= 3
                config = varargin{1};
                saveConfiguration(config);
            else
                error('Configuration required for save_config action');
            end
        case 'load_config'
            config = loadConfiguration();
            if nargout > 0
                handles.config = config;
            end
        otherwise
            error('Unknown action: %s', action);
    end
end

function handles = loadUserPreferences(handles)
    % LOADUSERPREFERENCES - Load user preferences with safe defaults
    %
    % Inputs:
    %   handles - GUI handles structure
    %
    % Outputs:
    %   handles - Updated handles structure with loaded preferences
    
    script_dir = fileparts(mfilename('fullpath'));
    pref_file = fullfile(script_dir, 'user_preferences.mat');

    % Initialize default preferences
    handles.preferences = struct();
    handles.preferences.last_input_file = '';
    handles.preferences.last_input_file_path = '';
    handles.preferences.last_output_folder = pwd;
    handles.preferences.default_num_trials = 10;
    handles.preferences.default_sim_time = 0.3;
    handles.preferences.default_sample_rate = 100;
    handles.preferences.capture_workspace = true; % Default to capturing workspace data

    % PERFORMANCE UPGRADES: Add last used model and input file preferences
    handles.preferences.last_model_name = '';
    handles.preferences.last_model_path = '';
    handles.preferences.last_model_was_loaded = false;
    handles.preferences.enable_model_caching = true;
    handles.preferences.enable_preallocation = true;
    handles.preferences.preallocation_buffer_size = 1000; % Default buffer size for preallocation

    % Batch settings defaults
    handles.preferences.default_batch_size = 50;
    handles.preferences.default_save_interval = 25;
    handles.preferences.enable_performance_monitoring = true;
    handles.preferences.default_verbosity = 'Normal';
    handles.preferences.enable_memory_monitoring = true;
    handles.preferences.memory_pool_size = 100; % MB

    % Try to load saved preferences
    if exist(pref_file, 'file')
        try
            loaded_prefs = load(pref_file);
            if isfield(loaded_prefs, 'preferences')
                % Merge loaded preferences with defaults
                pref_fields = fieldnames(loaded_prefs.preferences);
                for i = 1:length(pref_fields)
                    field_name = pref_fields{i};
                    handles.preferences.(field_name) = loaded_prefs.preferences.(field_name);
                end
            end
        catch
            % Use defaults if loading fails
            fprintf('Note: Could not load user preferences, using defaults.\n');
        end
    end
end

function handles = saveUserPreferences(handles)
    % SAVEUSERPREFERENCES - Save current user preferences
    %
    % Inputs:
    %   handles - GUI handles structure
    %
    % Outputs:
    %   handles - Updated handles structure
    
    if ~isfield(handles, 'preferences')
        warning('No preferences to save');
        return;
    end
    
    script_dir = fileparts(mfilename('fullpath'));
    pref_file = fullfile(script_dir, 'user_preferences.mat');
    
    try
        preferences = handles.preferences;
        save(pref_file, 'preferences');
        fprintf('User preferences saved to: %s\n', pref_file);
    catch ME
        warning('Failed to save user preferences: %s', ME.message);
    end
end

function handles = applyUserPreferences(handles)
    % APPLYUSERPREFERENCES - Apply user preferences to UI
    %
    % Inputs:
    %   handles - GUI handles structure
    %
    % Outputs:
    %   handles - Updated handles structure
    
    try
        if isfield(handles, 'preferences')
            prefs = handles.preferences;

            % Apply last output folder
            if isfield(handles, 'output_folder_edit') && ~isempty(prefs.last_output_folder)
                set(handles.output_folder_edit, 'String', prefs.last_output_folder);
            end

            % Apply last input file
            if isfield(handles, 'input_file_edit') && ~isempty(prefs.last_input_file_path)
                if exist(prefs.last_input_file_path, 'file')
                    handles.selected_input_file = prefs.last_input_file_path;
                    [~, filename, ext] = fileparts(prefs.last_input_file_path);
                    set(handles.input_file_edit, 'String', [filename ext]);
                end
            end

            % PERFORMANCE UPGRADES: Apply last used model
            if isfield(handles, 'model_path_edit') && ~isempty(prefs.last_model_path)
                if exist(prefs.last_model_path, 'file')
                    set(handles.model_path_edit, 'String', prefs.last_model_path);
                    handles.selected_model_path = prefs.last_model_path;
                end
            end

            % Apply default values to other fields
            if isfield(handles, 'num_simulations_edit')
                set(handles.num_simulations_edit, 'String', num2str(prefs.default_num_trials));
            end

            if isfield(handles, 'stop_time_edit')
                set(handles.stop_time_edit, 'String', num2str(prefs.default_sim_time));
            end

            if isfield(handles, 'batch_size_edit')
                set(handles.batch_size_edit, 'String', num2str(prefs.default_batch_size));
            end

            if isfield(handles, 'save_interval_edit')
                set(handles.save_interval_edit, 'String', num2str(prefs.default_save_interval));
            end

            if isfield(handles, 'capture_workspace_checkbox')
                set(handles.capture_workspace_checkbox, 'Value', prefs.capture_workspace);
            end

            % Apply performance settings
            if isfield(handles, 'enable_performance_monitoring_checkbox')
                set(handles.enable_performance_monitoring_checkbox, 'Value', prefs.enable_performance_monitoring);
            end

            if isfield(handles, 'enable_memory_monitoring_checkbox')
                set(handles.enable_memory_monitoring_checkbox, 'Value', prefs.enable_memory_monitoring);
            end

            if isfield(handles, 'enable_model_caching_checkbox')
                set(handles.enable_model_caching_checkbox, 'Value', prefs.enable_model_caching);
            end

            if isfield(handles, 'enable_preallocation_checkbox')
                set(handles.enable_preallocation_checkbox, 'Value', prefs.enable_preallocation);
            end

            % Apply verbosity setting
            if isfield(handles, 'verbosity_popup')
                verbosity_options = get(handles.verbosity_popup, 'String');
                if iscell(verbosity_options)
                    verbosity_idx = find(strcmp(verbosity_options, prefs.default_verbosity));
                    if ~isempty(verbosity_idx)
                        set(handles.verbosity_popup, 'Value', verbosity_idx);
                    end
                end
            end
        end
    catch ME
        warning('Error applying user preferences: %s', ME.message);
    end
end

function saveConfiguration(config)
    % SAVECONFIGURATION - Save configuration to file
    %
    % Inputs:
    %   config - Configuration structure to save
    
    try
        [filename, pathname] = uiputfile('*.mat', 'Save Configuration');
        if filename ~= 0
            config_file = fullfile(pathname, filename);
            save(config_file, 'config');
            fprintf('Configuration saved to: %s\n', config_file);
        end
    catch ME
        warning('Failed to save configuration: %s', ME.message);
    end
end

function config = loadConfiguration()
    % LOADCONFIGURATION - Load configuration from file
    %
    % Outputs:
    %   config - Loaded configuration structure
    
    try
        [filename, pathname] = uigetfile('*.mat', 'Load Configuration');
        if filename ~= 0
            config_file = fullfile(pathname, filename);
            loaded_data = load(config_file);
            if isfield(loaded_data, 'config')
                config = loaded_data.config;
                fprintf('Configuration loaded from: %s\n', config_file);
            else
                error('No configuration found in file');
            end
        else
            config = [];
        end
    catch ME
        warning('Failed to load configuration: %s', ME.message);
        config = [];
    end
end
