% test_simscape_extraction.m
% Simple test script to verify Simscape data extraction

clear; clc;

fprintf('=== Testing Simscape Data Extraction ===\n\n');

% Test configuration
config = struct();
config.model_name = 'GolfSwing3D_Kinetic';
config.simulation_time = 0.1;
config.sample_rate = 100;
config.modeling_mode = 3;
config.torque_scenario = 1;
config.coeff_range = 0.1;
config.constant_value = 1.0;
config.use_model_workspace = true;
config.use_logsout = true;
config.use_signal_bus = true;
config.use_simscape = true;

% Load model and run a quick simulation
try
    load_system(config.model_name);
    fprintf('✓ Model loaded\n');
    
    % Generate coefficients
    polynomial_coeffs = generatePolynomialCoefficients(config);
    fprintf('✓ Generated coefficients\n');
    
    % Create simulation input
    simInput = Simulink.SimulationInput(config.model_name);
    simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));
    modeling_mode_param = Simulink.Parameter(config.modeling_mode);
    simInput = simInput.setVariable('ModelingMode', modeling_mode_param);
    simInput = setPolynomialVariables(simInput, polynomial_coeffs);
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    % Run simulation
    fprintf('Running simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Simulation completed\n');
    
    % Test Simscape extraction directly
    fprintf('\n--- Testing Simscape Extraction ---\n');
    
    % Initialize test data
    target_time = 0:0.01:0.1;
    test_data = zeros(length(target_time), 0);
    test_names = {'time'}; % This should be a cell array
    
    % Add time column using inline function
    test_data = [test_data, target_time(:)];
    test_names{end+1} = 'time';
    fprintf('Initial data size: %dx%d\n', size(test_data, 1), size(test_data, 2));
    
    % Test Simscape extraction
    try
        [extracted_data, extracted_names] = extractSimscapeResultsData(simOut, test_data, test_names, target_time);
        fprintf('✓ Simscape extraction successful\n');
        fprintf('  Final data size: %dx%d\n', size(extracted_data, 1), size(extracted_data, 2));
        fprintf('  Number of signals: %d\n', length(extracted_names));
        
        % Show some signal names
        fprintf('  Sample signal names:\n');
        for i = 1:min(10, length(extracted_names))
            fprintf('    %d: %s\n', i, extracted_names{i});
        end
        
    catch ME
        fprintf('✗ Simscape extraction failed: %s\n', ME.message);
        fprintf('Error details: %s\n', getReport(ME, 'extended'));
    end
    
    % Cleanup
    close_system(config.model_name, 0);
    fprintf('\n✓ Model closed\n');
    
catch ME
    fprintf('✗ Test failed: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

fprintf('\n=== Test Complete ===\n');

% Include helper functions inline to avoid path issues
function [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time)
    % Extract data from Simscape Results Explorer
    try
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run_id = runIDs(end);
            run_obj = Simulink.sdi.getRun(latest_run_id);
            all_signals = run_obj.getAllSignals;
            
            fprintf('  Found %d Simscape signals\n', length(all_signals));
            
            for i = 1:length(all_signals)
                sig = all_signals(i);
                try
                    % Get signal data
                    data = sig.Values.Data;
                    time = sig.Values.Time;
                    
                    % Use original signal name, but clean it for table compatibility
                    original_name = sig.Name;
                    clean_name = strrep(original_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');
                    
                    % Handle different data types
                    if isvector(data)
                        % Single-dimensional data
                        resampled_data = interp1(time, data, target_time, 'linear', 'extrap');
                        trial_data = [trial_data, resampled_data(:)];
                        signal_names{end+1} = clean_name;
                    elseif ismatrix(data) && size(data, 2) > 1
                        % Multi-dimensional data - extract each component
                        for j = 1:size(data, 2)
                            component_data = data(:, j);
                            resampled_data = interp1(time, component_data, target_time, 'linear', 'extrap');
                            trial_data = [trial_data, resampled_data(:)];
                            signal_names{end+1} = sprintf('%s_%d', clean_name, j);
                        end
                    end
                    
                catch ME
                    % Continue to next signal
                end
            end
        end
        
    catch ME
        % Continue without Simscape data
    end
end 