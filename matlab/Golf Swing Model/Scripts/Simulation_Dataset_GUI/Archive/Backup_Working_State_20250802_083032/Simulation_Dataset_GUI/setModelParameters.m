function simIn = setModelParameters(simIn, config)
    % External function for setting model parameters - can be used in parallel processing
    % This function accepts config as a parameter instead of relying on handles

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
            if isfield(config, 'enable_animation') && config.enable_animation
                % Enable animation (normal mode)
                simIn = simIn.setModelParameter('SimulationMode', 'normal');
                fprintf('Debug: Animation enabled (normal mode)\n');
            else
                % Disable animation for faster simulation
                simIn = simIn.setModelParameter('SimulationMode', 'accelerator');
                fprintf('Debug: Animation disabled (accelerator mode)\n');
            end
        catch ME
            fprintf('Warning: Could not set simulation mode for animation control: %s\n', ME.message);
        end

        % Set other model parameters to suppress unconnected port warnings
        try
            simIn = simIn.setModelParameter('UnconnectedInputMsg', 'none');
            simIn = simIn.setModelParameter('UnconnectedOutputMsg', 'none');
        catch
            % These parameters might not exist in all model types
        end

    catch ME
        fprintf('Error setting model parameters: %s\n', ME.message);
        rethrow(ME);
    end
end
