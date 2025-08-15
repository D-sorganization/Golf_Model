function result = runSingleTrial(sim_idx, config)
    % Standalone function for running a single simulation trial
    % This function can be called from parfor loops

    % Generate polynomial coefficients based on scenario
    polynomial_coeffs = generatePolynomialCoefficients(config);

    % Create simulation input
    simInput = Simulink.SimulationInput(config.model_name);
    simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));

    % Set modeling mode to 3 (hex polynomial) - handle as Simulink.Parameter
    modeling_mode_param = Simulink.Parameter(config.modeling_mode);
    simInput = simInput.setVariable('ModelingMode', modeling_mode_param);

    % Set polynomial coefficients
    simInput = setPolynomialVariables(simInput, polynomial_coeffs);

    % Configure logging
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');

    % Run simulation
    simOut = sim(simInput);

    % Extract data based on selected sources
    [trial_data, signal_names] = extractCompleteTrialData(simOut, sim_idx, config);

    if ~isempty(trial_data)
        % Create CSV file
        data_table = array2table(trial_data, 'VariableNames', signal_names);
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        filename = sprintf('trial_%03d_%s.csv', sim_idx, timestamp);
        filepath = fullfile(config.output_folder, filename);
        writetable(data_table, filepath);

        result = struct();
        result.success = true;
        result.filename = filename;
        result.data_points = size(trial_data, 1);
        result.columns = size(trial_data, 2);
    else
        result = struct();
        result.success = false;
        result.error = 'No data extracted';
    end
end
