function test_data_extraction_fix()
% test_data_extraction_fix.m
% Test script to verify the dimension mismatch fix works correctly

fprintf('=== Testing Data Extraction Fix ===\n\n');

try
    % Test configuration
    config = struct();
    config.num_simulations = 1;
    config.simulation_time = 0.1;
    config.sample_rate = 5;
    config.output_folder = './TestData';
    config.model_name = 'GolfSwing3D_Kinetic';
    config.use_parallel = false;
    
    % Create output folder if it doesn't exist
    if ~exist(config.output_folder, 'dir')
        mkdir(config.output_folder);
    end
    
    fprintf('Configuration:\n');
    fprintf('  Number of trials: %d\n', config.num_simulations);
    fprintf('  Simulation duration: %.1f seconds\n', config.simulation_time);
    fprintf('  Sample rate: %d Hz\n', config.sample_rate);
    fprintf('  Output folder: %s\n', config.output_folder);
    fprintf('  Model: %s\n', config.model_name);
    fprintf('\n');
    
    % Run a single trial to test the fix
    fprintf('Running test trial...\n');
    [result, signal_names] = runSingleTrialWithCSV(1, config);
    
    if ~isempty(result) && result.success
        fprintf('✓ Test successful!\n');
        fprintf('  CSV file: %s\n', result.filename);
        fprintf('  Data points: %d\n', result.data_points);
        fprintf('  Columns: %d\n', result.columns);
        fprintf('  Signal names: %d\n', length(signal_names));
        
        % Verify data integrity
        if result.data_points > 0 && result.columns > 0
            fprintf('✓ Data integrity verified\n');
        else
            fprintf('⚠️  Data integrity issue detected\n');
        end
    else
        fprintf('✗ Test failed\n');
    end
    
catch ME
    fprintf('✗ Test error: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== Test Complete ===\n');

end 