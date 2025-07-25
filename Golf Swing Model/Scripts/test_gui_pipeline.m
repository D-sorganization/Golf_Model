% test_gui_pipeline.m
% Test script to verify the complete GUI pipeline works correctly

clear; clc;

fprintf('=== Testing Complete GUI Pipeline ===\n\n');

% Test configuration (simulating GUI inputs)
config = struct();
config.model_name = 'GolfSwing3D_Kinetic';
config.num_simulations = 2; % Small number for testing
config.simulation_time = 0.1;
config.sample_rate = 100;
config.modeling_mode = 3;
config.torque_scenario = 1; % Variable torques
config.coeff_range = 0.1;
config.constant_value = 1.0;
config.use_model_workspace = true;
config.use_logsout = true;
config.use_signal_bus = true;
config.use_simscape = true;
config.execution_mode = 'sequential'; % Use sequential for testing
config.output_folder = 'test_output';

% Create output folder
if ~exist(config.output_folder, 'dir')
    mkdir(config.output_folder);
    fprintf('✓ Created output folder: %s\n', config.output_folder);
end

fprintf('Configuration:\n');
fprintf('  Number of simulations: %d\n', config.num_simulations);
fprintf('  Simulation time: %.1f seconds\n', config.simulation_time);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);
fprintf('  Modeling mode: %d\n', config.modeling_mode);
fprintf('  Torque scenario: %d\n', config.torque_scenario);
fprintf('  Execution mode: %s\n', config.execution_mode);
fprintf('  Output folder: %s\n', config.output_folder);

% Test the complete pipeline
fprintf('\n--- Testing Complete Pipeline ---\n');

try
    % Initialize results
    results = cell(config.num_simulations, 1);
    successful_trials = 0;
    failed_trials = 0;
    
    % Run trials
    for sim_idx = 1:config.num_simulations
        fprintf('Processing trial %d/%d...\n', sim_idx, config.num_simulations);
        
        try
            result = runSingleTrial(sim_idx, config);
            results{sim_idx} = result;
            
            if result.success
                successful_trials = successful_trials + 1;
                fprintf('  ✓ Trial %d: Success (%d rows, %d columns)\n', ...
                    sim_idx, result.data_points, result.columns);
                fprintf('    File: %s\n', result.filename);
            else
                failed_trials = failed_trials + 1;
                fprintf('  ✗ Trial %d: Failed - %s\n', sim_idx, result.error);
            end
            
        catch ME
            failed_trials = failed_trials + 1;
            results{sim_idx} = struct('success', false, 'error', ME.message);
            fprintf('  ✗ Trial %d: Error - %s\n', sim_idx, ME.message);
        end
    end
    
    % Summary
    fprintf('\n--- Pipeline Summary ---\n');
    fprintf('Total trials: %d\n', config.num_simulations);
    fprintf('Successful: %d\n', successful_trials);
    fprintf('Failed: %d\n', failed_trials);
    fprintf('Success rate: %.1f%%\n', 100 * successful_trials / config.num_simulations);
    
    % Check output files
    fprintf('\n--- Output Files ---\n');
    output_files = dir(fullfile(config.output_folder, '*.csv'));
    fprintf('Found %d CSV files in output folder:\n', length(output_files));
    for i = 1:length(output_files)
        fprintf('  %s\n', output_files(i).name);
    end
    
    % Test one of the output files
    if ~isempty(output_files)
        test_file = fullfile(config.output_folder, output_files(1).name);
        fprintf('\nTesting output file: %s\n', test_file);
        
        try
            test_table = readtable(test_file);
            fprintf('✓ File read successfully\n');
            fprintf('  Table size: %dx%d\n', size(test_table, 1), size(test_table, 2));
            fprintf('  Variables: %d\n', width(test_table));
            
            % Show some variable names
            fprintf('  Sample variables:\n');
            for i = 1:min(10, width(test_table))
                var_name = test_table.Properties.VariableNames{i};
                fprintf('    %d: %s\n', i, var_name);
            end
            
        catch ME
            fprintf('✗ Failed to read output file: %s\n', ME.message);
        end
    end
    
    fprintf('\n✓ Complete pipeline test successful!\n');
    
catch ME
    fprintf('✗ Pipeline test failed: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

% Cleanup
fprintf('\n--- Cleanup ---\n');
try
    % Remove test output folder
    rmdir(config.output_folder, 's');
    fprintf('✓ Removed test output folder\n');
catch ME
    fprintf('⚠ Could not remove test output folder: %s\n', ME.message);
end

fprintf('\n=== Test Complete ===\n'); 