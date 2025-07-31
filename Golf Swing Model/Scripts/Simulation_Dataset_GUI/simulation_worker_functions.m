function simulation_worker_functions()
    % This file contains essential functions for parallel simulation workers
    % These functions are extracted from Data_GUI.m to make them available
    % to parallel workers that don't have access to nested functions
end

function simIn = setModelParameters(simIn, config)
    % Set basic simulation parameters with careful error handling
    try
        % Set stop time
        if isfield(config, 'simulation_time') && ~isempty(config.simulation_time)
            simIn = simIn.setModelParameter('StopTime', num2str(config.simulation_time));
        end
        
        % Set solver carefully
        try
            simIn = simIn.setModelParameter('Solver', 'ode23t');
        catch
            fprintf('Warning: Could not set solver to ode23t\n');
        end
        
        % Set tolerances carefully
        try
            simIn = simIn.setModelParameter('RelTol', '1e-3');
            simIn = simIn.setModelParameter('AbsTol', '1e-5');
        catch
            fprintf('Warning: Could not set solver tolerances\n');
        end
        
        % CRITICAL: Set output options for data logging
        try
            simIn = simIn.setModelParameter('SaveOutput', 'on');
            simIn = simIn.setModelParameter('SaveFormat', 'Structure');
            simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');
        catch ME
            fprintf('Warning: Could not set output options: %s\n', ME.message);
        end
        
        % Additional logging settings
        try
            simIn = simIn.setModelParameter('SignalLogging', 'on');
            simIn = simIn.setModelParameter('SaveTime', 'on');
        catch
            fprintf('Warning: Could not set logging options\n');
        end
        
        % To Workspace block settings
        try
            simIn = simIn.setModelParameter('LimitDataPoints', 'off');
        catch
            fprintf('Warning: Could not set LimitDataPoints\n');
        end
        
        % MINIMAL SIMSCAPE LOGGING CONFIGURATION (Essential Only)
        % Only set the essential parameter that actually works
        try
            simIn = simIn.setModelParameter('SimscapeLogType', 'all');
            fprintf('Debug: ✅ Set SimscapeLogType = all (essential parameter)\n');
        catch ME
            fprintf('Warning: Could not set essential SimscapeLogType parameter: %s\n', ME.message);
            fprintf('Warning: Simscape data extraction may not work without this parameter\n');
        end
        
        % Set animation control based on user preference
        try
            if isfield(config, 'enable_animation') && ~config.enable_animation
                % Disable animation for faster simulation
                simIn = simIn.setModelParameter('SimulationMode', 'accelerator');
                fprintf('Debug: Animation disabled (accelerator mode)\n');
            else
                % Enable animation (normal mode)
                simIn = simIn.setModelParameter('SimulationMode', 'normal');
                fprintf('Debug: Animation enabled (normal mode)\n');
            end
        catch
            fprintf('Warning: Could not set simulation mode\n');
        end
        
    catch ME
        fprintf('Error setting model parameters: %s\n', ME.message);
        rethrow(ME);
    end
end

function simIn = setPolynomialCoefficients(simIn, coefficients, config)
    % Set polynomial coefficients for the golf swing model
    try
        fprintf('DEBUG: setPolynomialCoefficients called with:\n');
        fprintf('  coefficients class: %s\n', class(coefficients));
        fprintf('  coefficients size: %s\n', mat2str(size(coefficients)));
        
        if isempty(coefficients)
            fprintf('Warning: No coefficients provided\n');
            return;
        end
        
        fprintf('DEBUG: Starting setPolynomialCoefficients processing\n');
        
        % Get parameter information
        fprintf('DEBUG: About to call getPolynomialParameterInfo()\n');
        param_info = getPolynomialParameterInfo();
        fprintf('DEBUG: getPolynomialParameterInfo() returned successfully\n');
        
        % Set coefficients for each joint
        fprintf('DEBUG: Starting loop through %d joints\n', length(param_info.joint_names));
        coeff_index = 1;
        
        for joint_idx = 1:length(param_info.joint_names)
            joint_name = param_info.joint_names{joint_idx};
            joint_coeffs = param_info.joint_coeffs{joint_idx};
            
            fprintf('DEBUG: Processing joint %d: %s with %d coefficients\n', joint_idx, joint_name, length(joint_coeffs));
            
            for coeff_idx = 1:length(joint_coeffs)
                coeff_name = joint_coeffs{coeff_idx};
                fprintf('DEBUG: Processing coefficient %d: %s (class: %s)\n', coeff_idx, coeff_name, class(coeff_name));
                
                if coeff_index <= length(coefficients)
                    coeff_value = coefficients(coeff_index);
                    
                    % Create parameter name
                    param_name = sprintf('%s_%s', joint_name, coeff_name);
                    fprintf('DEBUG: Created param_name: %s\n', param_name);
                    
                    % Set the parameter
                    try
                        simIn = simIn.setVariable(param_name, coeff_value);
                        fprintf('DEBUG: Set variable %s = %.3f\n', param_name, coeff_value);
                    catch ME
                        fprintf('Warning: Could not set %s: %s\n', param_name, ME.message);
                    end
                    
                    coeff_index = coeff_index + 1;
                else
                    fprintf('Warning: Not enough coefficients for %s_%s\n', joint_name, coeff_name);
                end
            end
        end
        
    catch ME
        fprintf('Error setting polynomial coefficients: %s\n', ME.message);
        rethrow(ME);
    end
end

function simIn = loadInputFile(simIn, input_file)
    % Load input file data into simulation
    try
        if ~exist(input_file, 'file')
            fprintf('Warning: Input file %s not found\n', input_file);
            return;
        end
        
        % Load the input file
        input_data = load(input_file);
        
        % Set variables from input file
        field_names = fieldnames(input_data);
        for i = 1:length(field_names)
            field_name = field_names{i};
            field_value = input_data.(field_name);
            
            try
                simIn = simIn.setVariable(field_name, field_value);
                fprintf('Loaded variable %s from input file\n', field_name);
            catch ME
                fprintf('Warning: Could not set variable %s: %s\n', field_name, ME.message);
            end
        end
        
    catch ME
        fprintf('ERROR: Failed to load input file %s: %s\n', input_file, ME.message);
        rethrow(ME);
    end
end

function param_info = getPolynomialParameterInfo()
    % Get polynomial parameter information for coefficient setting
    param_info = struct();
    param_info.joint_names = {'Hip', 'Knee', 'Ankle', 'Shoulder', 'Elbow', 'Wrist'};
    param_info.joint_coeffs = {
        {'a0', 'a1', 'a2', 'a3', 'a4', 'a5'},  % Hip
        {'b0', 'b1', 'b2', 'b3', 'b4', 'b5'},  % Knee
        {'c0', 'c1', 'c2', 'c3', 'c4', 'c5'},  % Ankle
        {'d0', 'd1', 'd2', 'd3', 'd4', 'd5'},  % Shoulder
        {'e0', 'e1', 'e2', 'e3', 'e4', 'e5'},  % Elbow
        {'f0', 'f1', 'f2', 'f3', 'f4', 'f5'}   % Wrist
    };
end 