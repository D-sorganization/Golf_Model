function simInputs = simulation_input_preparer(config, handles)
    % SIMULATION_INPUT_PREPARER - Prepare simulation inputs for batch processing
    %
    % This function prepares simulation input objects for batch processing,
    % including parameter setting, coefficient generation, and model configuration.
    %
    % Inputs:
    %   config - Configuration structure with simulation parameters
    %   handles - GUI handles structure (for progress updates)
    %
    % Outputs:
    %   simInputs - Array of Simulink.SimulationInput objects
    
    if nargin < 2
        handles = [];
    end
    
    % Prepare simulation inputs for the entire batch
    simInputs = prepareSimulationInputs(config, handles);
end

function simInputs = prepareSimulationInputs(config, handles)
    % PREPARESIMULATIONINPUTS - Prepare simulation inputs for all trials
    %
    % This function creates Simulink.SimulationInput objects for all trials
    % in the simulation batch, with proper parameter setting and coefficient generation.
    %
    % Inputs:
    %   config - Configuration structure with simulation parameters
    %   handles - GUI handles structure (for progress updates)
    %
    % Outputs:
    %   simInputs - Array of Simulink.SimulationInput objects
    
    if nargin < 2
        handles = [];
    end
    
    % Validate configuration
    if ~isfield(config, 'num_simulations') || config.num_simulations <= 0
        error('Invalid number of simulations: %d', config.num_simulations);
    end
    
    if ~isfield(config, 'model_path') || ~exist(config.model_path, 'file')
        error('Model file not found: %s', config.model_path);
    end
    
    % Load the model if not already loaded
    [~, model_name, ~] = fileparts(config.model_path);
    if ~bdIsLoaded(model_name)
        load_system(config.model_path);
    end
    
    % Create simulation input objects
    simInputs = Simulink.SimulationInput(model_name);
    simInputs = repmat(simInputs, config.num_simulations, 1);
    
    % Update progress if handles provided
    if ~isempty(handles) && isfield(handles, 'progress_text')
        set(handles.progress_text, 'String', 'Preparing simulation inputs...');
        drawnow;
    end
    
    % Prepare each simulation input
    for i = 1:config.num_simulations
        try
            % Set model parameters
            simInputs(i) = setModelParameters(simInputs(i), config, handles);
            
            % Generate random coefficients for this trial
            coefficients = generateRandomCoefficients(config.num_coefficients);
            
            % Set polynomial coefficients
            simInputs(i) = setPolynomialCoefficients(simInputs(i), coefficients, config);
            
            % Load input file if specified
            if isfield(config, 'input_file') && ~isempty(config.input_file)
                simInputs(i) = loadInputFile(simInputs(i), config.input_file);
            end
            
        catch ME
            warning('Error preparing simulation input %d: %s', i, ME.message);
            % Continue with other inputs
        end
    end
    
    % Update progress
    if ~isempty(handles) && isfield(handles, 'progress_text')
        set(handles.progress_text, 'String', sprintf('Prepared %d simulation inputs', config.num_simulations));
        drawnow;
    end
end

function batch_simInputs = prepareSimulationInputsForBatch(config, start_trial, end_trial)
    % PREPARESIMULATIONINPUTSFORBATCH - Prepare simulation inputs for a specific batch
    %
    % This function creates Simulink.SimulationInput objects for a specific
    % batch of trials, with proper parameter setting and coefficient generation.
    %
    % Inputs:
    %   config - Configuration structure with simulation parameters
    %   start_trial - Starting trial number for this batch
    %   end_trial - Ending trial number for this batch
    %
    % Outputs:
    %   batch_simInputs - Array of Simulink.SimulationInput objects for the batch
    
    % Validate inputs
    if start_trial > end_trial
        error('Start trial (%d) must be <= end trial (%d)', start_trial, end_trial);
    end
    
    if start_trial < 1
        error('Start trial must be >= 1, got %d', start_trial);
    end
    
    % Calculate batch size
    batch_size = end_trial - start_trial + 1;
    
    % Load the model if not already loaded
    [~, model_name, ~] = fileparts(config.model_path);
    if ~bdIsLoaded(model_name)
        load_system(config.model_path);
    end
    
    % Create simulation input objects for this batch
    batch_simInputs = Simulink.SimulationInput(model_name);
    batch_simInputs = repmat(batch_simInputs, batch_size, 1);
    
    % Prepare each simulation input in the batch
    for i = 1:batch_size
        trial_num = start_trial + i - 1;
        
        try
            % Set model parameters
            batch_simInputs(i) = setModelParameters(batch_simInputs(i), config, []);
            
            % Generate random coefficients for this trial
            coefficients = generateRandomCoefficients(config.num_coefficients);
            
            % Set polynomial coefficients
            batch_simInputs(i) = setPolynomialCoefficients(batch_simInputs(i), coefficients, config);
            
            % Load input file if specified
            if isfield(config, 'input_file') && ~isempty(config.input_file)
                batch_simInputs(i) = loadInputFile(batch_simInputs(i), config.input_file);
            end
            
        catch ME
            warning('Error preparing simulation input %d (trial %d): %s', i, trial_num, ME.message);
            % Continue with other inputs
        end
    end
end

function simIn = setModelParameters(simIn, config, handles)
    % SETMODELPARAMETERS - Set model parameters in simulation input
    %
    % This function sets various model parameters in the simulation input object,
    % including solver settings, stop time, and other configuration parameters.
    %
    % Inputs:
    %   simIn - Simulink.SimulationInput object
    %   config - Configuration structure with simulation parameters
    %   handles - GUI handles structure (optional, for progress updates)
    %
    % Outputs:
    %   simIn - Updated Simulink.SimulationInput object
    
    if nargin < 3
        handles = [];
    end
    
    try
        % Set solver parameters
        if isfield(config, 'solver_name') && ~isempty(config.solver_name)
            simIn = simIn.setModelParameter('Solver', config.solver_name);
        end
        
        if isfield(config, 'stop_time') && ~isempty(config.stop_time)
            simIn = simIn.setModelParameter('StopTime', num2str(config.stop_time));
        end
        
        if isfield(config, 'relative_tolerance') && ~isempty(config.relative_tolerance)
            simIn = simIn.setModelParameter('RelTol', num2str(config.relative_tolerance));
        end
        
        if isfield(config, 'absolute_tolerance') && ~isempty(config.absolute_tolerance)
            simIn = simIn.setModelParameter('AbsTol', num2str(config.absolute_tolerance));
        end
        
        % Set output parameters
        if isfield(config, 'save_format') && ~isempty(config.save_format)
            simIn = simIn.setModelParameter('SaveFormat', config.save_format);
        end
        
        if isfield(config, 'save_output') && ~isempty(config.save_output)
            simIn = simIn.setModelParameter('SaveOutput', config.save_output);
        end
        
        % Set additional model-specific parameters
        if isfield(config, 'model_parameters') && ~isempty(config.model_parameters)
            param_names = fieldnames(config.model_parameters);
            for i = 1:length(param_names)
                param_name = param_names{i};
                param_value = config.model_parameters.(param_name);
                
                % Convert to string if numeric
                if isnumeric(param_value)
                    param_value = num2str(param_value);
                end
                
                simIn = simIn.setModelParameter(param_name, param_value);
            end
        end
        
    catch ME
        warning('Error setting model parameters: %s', ME.message);
        % Continue with default parameters
    end
end

function simIn = setPolynomialCoefficients(simIn, coefficients, config)
    % SETPOLYNOMIALCOEFFICIENTS - Set polynomial coefficients in simulation input
    %
    % This function sets polynomial coefficients for kinematic inputs in the
    % simulation input object, handling different coefficient formats and validation.
    %
    % Inputs:
    %   simIn - Simulink.SimulationInput object
    %   coefficients - Array of polynomial coefficients
    %   config - Configuration structure with simulation parameters
    %
    % Outputs:
    %   simIn - Updated Simulink.SimulationInput object
    
    try
        % Validate coefficients
        if isempty(coefficients)
            warning('Empty coefficients provided, using default values');
            coefficients = generateRandomCoefficients(config.num_coefficients);
        end
        
        % Ensure coefficients are numeric
        if ~isnumeric(coefficients)
            error('Coefficients must be numeric, got %s', class(coefficients));
        end
        
        % Handle parallel worker coefficient format issues
        if iscell(coefficients)
            coefficients = cell2mat(coefficients);
        end
        
        % Reshape coefficients if needed
        if isfield(config, 'coefficient_shape') && ~isempty(config.coefficient_shape)
            coefficients = reshape(coefficients, config.coefficient_shape);
        end
        
        % Set coefficients in the model
        if isfield(config, 'coefficient_parameter_name') && ~isempty(config.coefficient_parameter_name)
            simIn = simIn.setVariable(config.coefficient_parameter_name, coefficients);
        else
            % Default parameter name
            simIn = simIn.setVariable('polynomial_coefficients', coefficients);
        end
        
        % Set additional coefficient-related parameters
        if isfield(config, 'coefficient_parameters') && ~isempty(config.coefficient_parameters)
            param_names = fieldnames(config.coefficient_parameters);
            for i = 1:length(param_names)
                param_name = param_names{i};
                param_value = config.coefficient_parameters.(param_name);
                
                simIn = simIn.setVariable(param_name, param_value);
            end
        end
        
    catch ME
        warning('Error setting polynomial coefficients: %s', ME.message);
        % Continue with default coefficients
    end
end

function simIn = loadInputFile(simIn, input_file)
    % LOADINPUTFILE - Load input file data into simulation input
    %
    % This function loads data from an input file and sets it in the simulation
    % input object for use during simulation.
    %
    % Inputs:
    %   simIn - Simulink.SimulationInput object
    %   input_file - Path to input file (.mat format)
    %
    % Outputs:
    %   simIn - Updated Simulink.SimulationInput object
    
    try
        % Validate input file
        if ~exist(input_file, 'file')
            error('Input file not found: %s', input_file);
        end
        
        % Load data from file
        file_data = load(input_file);
        
        % Set variables in simulation input
        var_names = fieldnames(file_data);
        for i = 1:length(var_names)
            var_name = var_names{i};
            var_value = file_data.(var_name);
            
            simIn = simIn.setVariable(var_name, var_value);
        end
        
    catch ME
        warning('Error loading input file %s: %s', input_file, ME.message);
        % Continue without input file data
    end
end
