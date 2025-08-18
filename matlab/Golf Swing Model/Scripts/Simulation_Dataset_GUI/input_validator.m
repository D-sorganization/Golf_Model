function config = input_validator(handles)
    % INPUT_VALIDATOR - Validate and prepare configuration from GUI inputs
    %
    % This function validates all GUI inputs and creates a configuration structure
    % for simulation execution, with comprehensive error checking and validation.
    %
    % Inputs:
    %   handles - GUI handles structure containing all input values
    %
    % Outputs:
    %   config - Validated configuration structure for simulation
    %
    % Throws:
    %   error - If validation fails with specific error messages
    
    % Initialize configuration structure
    config = struct();
    
    % Validate model selection
    config = validateModelSelection(handles, config);
    
    % Validate simulation parameters
    config = validateSimulationParameters(handles, config);
    
    % Validate output settings
    config = validateOutputSettings(handles, config);
    
    % Validate data extraction settings
    config = validateDataExtractionSettings(handles, config);
    
    % Validate performance settings
    config = validatePerformanceSettings(handles, config);
    
    % Validate coefficient settings
    config = validateCoefficientSettings(handles, config);
    
    % Final validation
    config = performFinalValidation(config);
end

function config = validateModelSelection(handles, config)
    % VALIDATEMODELSELECTION - Validate model file selection
    %
    % Inputs:
    %   handles - GUI handles structure
    %   config - Configuration structure to update
    %
    % Outputs:
    %   config - Updated configuration structure
    
    % Get model path from GUI
    if isfield(handles, 'model_path_edit') && ishandle(handles.model_path_edit)
        model_path = get(handles.model_path_edit, 'String');
    else
        error('Model path edit control not found');
    end
    
    % Validate model path
    if isempty(model_path)
        error('Model path is empty. Please select a Simulink model file.');
    end
    
    if ~exist(model_path, 'file')
        error('Model file not found: %s', model_path);
    end
    
    [~, ~, ext] = fileparts(model_path);
    if ~strcmpi(ext, '.slx') && ~strcmpi(ext, '.mdl')
        error('Invalid model file format: %s. Please select a .slx or .mdl file.', ext);
    end
    
    % Store validated model information
    config.model_path = model_path;
    [~, config.model_name, ~] = fileparts(model_path);
    
    % Check if model can be loaded
    try
        if ~bdIsLoaded(config.model_name)
            load_system(model_path);
        end
    catch ME
        error('Failed to load model %s: %s', model_path, ME.message);
    end
end

function config = validateSimulationParameters(handles, config)
    % VALIDATESIMULATIONPARAMETERS - Validate simulation parameters
    %
    % Inputs:
    %   handles - GUI handles structure
    %   config - Configuration structure to update
    %
    % Outputs:
    %   config - Updated configuration structure
    
    % Number of simulations
    if isfield(handles, 'num_simulations_edit') && ishandle(handles.num_simulations_edit)
        num_simulations_str = get(handles.num_simulations_edit, 'String');
        num_simulations = str2double(num_simulations_str);
    else
        error('Number of simulations edit control not found');
    end
    
    if isnan(num_simulations) || num_simulations <= 0 || num_simulations ~= round(num_simulations)
        error('Invalid number of simulations: %s. Must be a positive integer.', num_simulations_str);
    end
    
    config.num_simulations = num_simulations;
    
    % Stop time
    if isfield(handles, 'stop_time_edit') && ishandle(handles.stop_time_edit)
        stop_time_str = get(handles.stop_time_edit, 'String');
        stop_time = str2double(stop_time_str);
    else
        stop_time = 1.0; % Default value
    end
    
    if isnan(stop_time) || stop_time <= 0
        error('Invalid stop time: %s. Must be a positive number.', stop_time_str);
    end
    
    config.stop_time = stop_time;
    
    % Solver name
    if isfield(handles, 'solver_popup') && ishandle(handles.solver_popup)
        solver_idx = get(handles.solver_popup, 'Value');
        solver_options = get(handles.solver_popup, 'String');
        if iscell(solver_options)
            config.solver_name = solver_options{solver_idx};
        else
            config.solver_name = solver_options;
        end
    else
        config.solver_name = 'ode45'; % Default solver
    end
    
    % Relative tolerance
    if isfield(handles, 'rel_tol_edit') && ishandle(handles.rel_tol_edit)
        rel_tol_str = get(handles.rel_tol_edit, 'String');
        rel_tol = str2double(rel_tol_str);
    else
        rel_tol = 1e-3; % Default value
    end
    
    if isnan(rel_tol) || rel_tol <= 0
        error('Invalid relative tolerance: %s. Must be a positive number.', rel_tol_str);
    end
    
    config.relative_tolerance = rel_tol;
    
    % Absolute tolerance
    if isfield(handles, 'abs_tol_edit') && ishandle(handles.abs_tol_edit)
        abs_tol_str = get(handles.abs_tol_edit, 'String');
        abs_tol = str2double(abs_tol_str);
    else
        abs_tol = 1e-6; % Default value
    end
    
    if isnan(abs_tol) || abs_tol <= 0
        error('Invalid absolute tolerance: %s. Must be a positive number.', abs_tol_str);
    end
    
    config.absolute_tolerance = abs_tol;
end

function config = validateOutputSettings(handles, config)
    % VALIDATEOUTPUTSETTINGS - Validate output folder and settings
    %
    % Inputs:
    %   handles - GUI handles structure
    %   config - Configuration structure to update
    %
    % Outputs:
    %   config - Updated configuration structure
    
    % Output folder
    if isfield(handles, 'output_folder_edit') && ishandle(handles.output_folder_edit)
        output_folder = get(handles.output_folder_edit, 'String');
    else
        error('Output folder edit control not found');
    end
    
    if isempty(output_folder)
        error('Output folder is empty. Please select an output folder.');
    end
    
    % Create output folder if it doesn't exist
    if ~exist(output_folder, 'dir')
        try
            mkdir(output_folder);
        catch ME
            error('Failed to create output folder %s: %s', output_folder, ME.message);
        end
    end
    
    % Check if folder is writable
    test_file = fullfile(output_folder, 'test_write.tmp');
    try
        fid = fopen(test_file, 'w');
        if fid == -1
            error('Output folder is not writable: %s', output_folder);
        end
        fclose(fid);
        delete(test_file);
    catch ME
        error('Output folder validation failed: %s', ME.message);
    end
    
    config.output_folder = output_folder;
    
    % Save format
    if isfield(handles, 'save_format_popup') && ishandle(handles.save_format_popup)
        format_idx = get(handles.save_format_popup, 'Value');
        format_options = get(handles.save_format_popup, 'String');
        if iscell(format_options)
            config.save_format = format_options{format_idx};
        else
            config.save_format = format_options;
        end
    else
        config.save_format = 'Dataset'; % Default format
    end
    
    % Save output setting
    if isfield(handles, 'save_output_checkbox') && ishandle(handles.save_output_checkbox)
        config.save_output = get(handles.save_output_checkbox, 'Value');
    else
        config.save_output = true; % Default to saving output
    end
end

function config = validateDataExtractionSettings(handles, config)
    % VALIDATEDATAEXTRACTIONSETTINGS - Validate data extraction settings
    %
    % Inputs:
    %   handles - GUI handles structure
    %   config - Configuration structure to update
    %
    % Outputs:
    %   config - Updated configuration structure
    
    % Signal bus extraction
    if isfield(handles, 'use_signal_bus_checkbox') && ishandle(handles.use_signal_bus_checkbox)
        config.use_signal_bus = get(handles.use_signal_bus_checkbox, 'Value');
    else
        config.use_signal_bus = true; % Default to using signal bus
    end
    
    % Logsout extraction
    if isfield(handles, 'use_logsout_checkbox') && ishandle(handles.use_logsout_checkbox)
        config.use_logsout = get(handles.use_logsout_checkbox, 'Value');
    else
        config.use_logsout = true; % Default to using logsout
    end
    
    % Simscape extraction
    if isfield(handles, 'use_simscape_checkbox') && ishandle(handles.use_simscape_checkbox)
        config.use_simscape = get(handles.use_simscape_checkbox, 'Value');
    else
        config.use_simscape = false; % Default to not using Simscape
    end
    
    % Workspace capture
    if isfield(handles, 'capture_workspace_checkbox') && ishandle(handles.capture_workspace_checkbox)
        config.capture_workspace = get(handles.capture_workspace_checkbox, 'Value');
    else
        config.capture_workspace = false; % Default to not capturing workspace
    end
    
    % Ensure at least one extraction method is enabled
    if ~config.use_signal_bus && ~config.use_logsout && ~config.use_simscape
        error('At least one data extraction method must be enabled (Signal Bus, Logsout, or Simscape).');
    end
end

function config = validatePerformanceSettings(handles, config)
    % VALIDATEPERFORMANCESETTINGS - Validate performance-related settings
    %
    % Inputs:
    %   handles - GUI handles structure
    %   config - Configuration structure to update
    %
    % Outputs:
    %   config - Updated configuration structure
    
    % Batch size
    if isfield(handles, 'batch_size_edit') && ishandle(handles.batch_size_edit)
        batch_size_str = get(handles.batch_size_edit, 'String');
        batch_size = str2double(batch_size_str);
    else
        batch_size = 50; % Default batch size
    end
    
    if isnan(batch_size) || batch_size <= 0 || batch_size ~= round(batch_size)
        error('Invalid batch size: %s. Must be a positive integer.', batch_size_str);
    end
    
    if batch_size > config.num_simulations
        batch_size = config.num_simulations;
    end
    
    config.batch_size = batch_size;
    
    % Save interval
    if isfield(handles, 'save_interval_edit') && ishandle(handles.save_interval_edit)
        save_interval_str = get(handles.save_interval_edit, 'String');
        save_interval = str2double(save_interval_str);
    else
        save_interval = 5; % Default save interval
    end
    
    if isnan(save_interval) || save_interval <= 0 || save_interval ~= round(save_interval)
        error('Invalid save interval: %s. Must be a positive integer.', save_interval_str);
    end
    
    config.save_interval = save_interval;
    
    % Verbosity level
    if isfield(handles, 'verbosity_popup') && ishandle(handles.verbosity_popup)
        verbosity_idx = get(handles.verbosity_popup, 'Value');
        verbosity_options = get(handles.verbosity_popup, 'String');
        if iscell(verbosity_options)
            config.verbosity = verbosity_options{verbosity_idx};
        else
            config.verbosity = verbosity_options;
        end
    else
        config.verbosity = 'Normal'; % Default verbosity
    end
end

function config = validateCoefficientSettings(handles, config)
    % VALIDATECOEFFICIENTSETTINGS - Validate coefficient-related settings
    %
    % Inputs:
    %   handles - GUI handles structure
    %   config - Configuration structure to update
    %
    % Outputs:
    %   config - Updated configuration structure
    
    % Number of coefficients
    if isfield(handles, 'num_coefficients_edit') && ishandle(handles.num_coefficients_edit)
        num_coefficients_str = get(handles.num_coefficients_edit, 'String');
        num_coefficients = str2double(num_coefficients_str);
    else
        num_coefficients = 10; % Default number of coefficients
    end
    
    if isnan(num_coefficients) || num_coefficients <= 0 || num_coefficients ~= round(num_coefficients)
        error('Invalid number of coefficients: %s. Must be a positive integer.', num_coefficients_str);
    end
    
    config.num_coefficients = num_coefficients;
    
    % Coefficient range
    if isfield(handles, 'coefficient_range_edit') && ishandle(handles.coefficient_range_edit)
        coefficient_range_str = get(handles.coefficient_range_edit, 'String');
        coefficient_range = str2double(coefficient_range_str);
    else
        coefficient_range = 1.0; % Default coefficient range
    end
    
    if isnan(coefficient_range) || coefficient_range <= 0
        error('Invalid coefficient range: %s. Must be a positive number.', coefficient_range_str);
    end
    
    config.coefficient_range = coefficient_range;
end

function config = performFinalValidation(config)
    % PERFORMFINALVALIDATION - Perform final configuration validation
    %
    % Inputs:
    %   config - Configuration structure to validate
    %
    % Outputs:
    %   config - Final validated configuration structure
    
    % Check model configuration
    config = checkModelConfiguration(config);
    
    % Validate batch size against number of simulations
    if config.batch_size > config.num_simulations
        config.batch_size = config.num_simulations;
    end
    
    % Validate save interval against number of batches
    num_batches = ceil(config.num_simulations / config.batch_size);
    if config.save_interval > num_batches
        config.save_interval = num_batches;
    end
    
    % Add timestamp
    config.timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    
    % Add version information
    config.version = '2.0';
    config.matlab_version = version;
end

function config = checkModelConfiguration(config)
    % CHECKMODELCONFIGURATION - Check if model configuration is valid
    %
    % Inputs:
    %   config - Configuration structure to validate
    %
    % Outputs:
    %   config - Updated configuration structure
    
    try
        % Load model if not already loaded
        if ~bdIsLoaded(config.model_name)
            load_system(config.model_path);
        end
        
        % Check if model is valid
        if ~bdIsLoaded(config.model_name)
            error('Failed to load model: %s', config.model_name);
        end
        
        % Get model parameters
        model_params = get_param(config.model_name, 'ObjectParameters');
        
        % Validate solver
        if isfield(model_params, 'Solver')
            valid_solvers = get_param(config.model_name, 'Solver');
            if ~isempty(valid_solvers) && ~contains(valid_solvers, config.solver_name)
                warning('Solver %s may not be optimal for model %s. Consider using: %s', ...
                    config.solver_name, config.model_name, valid_solvers);
            end
        end
        
        % Check model complexity
        blocks = find_system(config.model_name, 'FollowLinks', 'on', 'LookUnderMasks', 'on');
        num_blocks = length(blocks);
        
        if num_blocks > 1000
            warning('Model %s has %d blocks. Consider using a smaller batch size for better performance.', ...
                config.model_name, num_blocks);
        end
        
        % Store model information
        config.model_blocks = num_blocks;
        config.model_loaded = true;
        
    catch ME
        error('Model configuration validation failed: %s', ME.message);
    end
end
