function test_robust_generator()
    % Test script for robust_dataset_generator
    % This script tests the robust dataset generator with a simple configuration
    
    fprintf('=== Testing Robust Dataset Generator ===\n');
    
    % Create a simple test configuration
    config = struct();
    
    % Model configuration
    config.model_name = 'GolfSwing3D_Kinetic';
    config.model_path = fullfile(pwd, '..', '..', 'Model', 'GolfSwing3D_Kinetic.slx');
    
    % Simulation parameters
    config.simulation_time = 0.1;  % 0.1 seconds (very short for testing)
    config.enable_animation = false;  % Disable animation for faster testing
    config.input_file = '';  % No input file for testing
    
    % Data capture settings
    config.use_signal_bus = true;
    config.use_logsout = true;
    config.use_simscape = true;
    
    % Output settings
    config.output_folder = fullfile(pwd, 'test_output');
    config.file_format = 1;  % CSV files
    
    % Create output folder if it doesn't exist
    if ~exist(config.output_folder, 'dir')
        mkdir(config.output_folder);
    end
    
    % Create a minimal set of test coefficients (1 trial with reduced coefficients)
    % Use only first 10 joints × 7 coefficients = 70 coefficients for faster testing
    config.coefficient_values = rand(1, 70) * 10 - 5;  % Random values between -5 and +5
    
    % Set number of simulations
    config.num_simulations = size(config.coefficient_values, 1);
    
    % Robust mode settings - optimized for testing
    config.BatchSize = 1;  % Small batch size for testing
    config.SaveInterval = 1;  % Save after each trial
    config.MaxMemoryGB = 2;  % Conservative memory limit
    config.MaxWorkers = 1;  % Single worker to avoid timeout issues
    config.Verbosity = 'normal';  % Disable verbose output for speed
    config.PerformanceMonitoring = false;  % Disable for faster testing
    config.CaptureWorkspace = false;  % Disable for faster testing
    
    fprintf('Configuration created:\n');
    fprintf('  Model: %s\n', config.model_name);
    fprintf('  Model path: %s\n', config.model_path);
    fprintf('  Simulation time: %.1f seconds\n', config.simulation_time);
    fprintf('  Number of trials: %d\n', size(config.coefficient_values, 1));
    fprintf('  Number of coefficients: %d (reduced for testing)\n', length(config.coefficient_values));
    fprintf('  Output folder: %s\n', config.output_folder);
    
    % Check if model exists
    if ~exist(config.model_path, 'file')
        fprintf('ERROR: Model file not found: %s\n', config.model_path);
        fprintf('Please ensure the model file exists and the path is correct.\n');
        return;
    end
    
    fprintf('\nStarting robust dataset generation...\n');
    
    try
        % Run the robust dataset generator
        successful_trials = robust_dataset_generator(config, ...
            'BatchSize', config.BatchSize, ...
            'SaveInterval', config.SaveInterval, ...
            'MaxMemoryGB', config.MaxMemoryGB, ...
            'MaxWorkers', config.MaxWorkers, ...
            'Verbosity', config.Verbosity, ...
            'PerformanceMonitoring', config.PerformanceMonitoring, ...
            'CaptureWorkspace', config.CaptureWorkspace);
        
        fprintf('\n=== Test Results ===\n');
        fprintf('Successful trials: %d\n', successful_trials);
        
        if successful_trials > 0
            fprintf('Test PASSED: Robust dataset generator completed successfully\n');
            
            % List generated files
            fprintf('\nGenerated files:\n');
            files = dir(fullfile(config.output_folder, '*.csv'));
            for i = 1:length(files)
                fprintf('  %s\n', files(i).name);
            end
        else
            fprintf('Test FAILED: No successful trials generated\n');
        end
        
    catch ME
        fprintf('\nTest FAILED with error:\n');
        fprintf('  %s\n', ME.message);
        fprintf('\nStack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
    
    fprintf('\n=== Test Complete ===\n');
end 