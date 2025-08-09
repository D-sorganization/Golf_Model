% Run 10 simulations with timing
fprintf('=== Running 10 Simulations Test ===\n');

% Add scripts to path
addpath('Scripts');

% Configure for 10 simulations
config = struct();
config.num_simulations = 10;
config.simulation_duration = 0.3;
config.sample_rate = 1000;

fprintf('Configuration:\n');
fprintf('  Simulations: %d\n', config.num_simulations);
fprintf('  Duration: %.1f seconds each\n', config.simulation_duration);
fprintf('  Sample rate: %d Hz\n', config.sample_rate);

% Start timing
fprintf('\nStarting dataset generation...\n');
tic;

% Generate dataset
generateCompleteDataset(config);

% End timing
total_time = toc;

fprintf('\n=== Results ===\n');
fprintf('Total time: %.2f seconds\n', total_time);
fprintf('Total time: %.2f minutes\n', total_time/60);
fprintf('Average per simulation: %.2f seconds\n', total_time/config.num_simulations);

fprintf('\n=== Test Complete ===\n'); 