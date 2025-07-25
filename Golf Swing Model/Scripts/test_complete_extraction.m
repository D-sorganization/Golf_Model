% test_complete_extraction.m
% Test script to verify the complete data extraction pipeline

clear; clc;

fprintf('=== Testing Complete Data Extraction Pipeline ===\n\n');

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
    
    % Test complete data extraction
    fprintf('\n--- Testing Complete Data Extraction ---\n');
    
    try
        [trial_data, signal_names] = extractCompleteTrialData(simOut, 1, config);
        
        if ~isempty(trial_data)
            fprintf('✓ Complete data extraction successful!\n');
            fprintf('  Data matrix size: %dx%d\n', size(trial_data, 1), size(trial_data, 2));
            fprintf('  Number of signals: %d\n', length(signal_names));
            
            % Show some signal names
            fprintf('  Sample signal names:\n');
            for i = 1:min(15, length(signal_names))
                fprintf('    %d: %s\n', i, signal_names{i});
            end
            
            % Test CSV creation
            fprintf('\n--- Testing CSV Creation ---\n');
            try
                data_table = array2table(trial_data, 'VariableNames', signal_names);
                fprintf('✓ Data table created successfully\n');
                fprintf('  Table size: %dx%d\n', size(data_table, 1), size(data_table, 2));
                
                % Show table info
                fprintf('  Table variables:\n');
                for i = 1:min(10, width(data_table))
                    var_name = data_table.Properties.VariableNames{i};
                    fprintf('    %d: %s\n', i, var_name);
                end
                
                % Test saving to CSV
                test_filename = 'test_extraction_output.csv';
                writetable(data_table, test_filename);
                fprintf('✓ CSV file saved: %s\n', test_filename);
                
                % Clean up test file
                delete(test_filename);
                fprintf('✓ Test file cleaned up\n');
                
            catch ME
                fprintf('✗ CSV creation failed: %s\n', ME.message);
            end
            
        else
            fprintf('✗ No data extracted\n');
        end
        
    catch ME
        fprintf('✗ Complete data extraction failed: %s\n', ME.message);
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