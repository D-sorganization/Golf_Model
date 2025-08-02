% analyzeSimulationPerformance.m
% Analyzes simulation performance and provides recommendations for dataset sizes

clear; clc;

fprintf('=== Golf Swing Simulation Performance Analysis ===\n\n');

%% Load configuration data
config_files = dir('100_Simulation_Test_Dataset/100_sim_config_*.mat');
if isempty(config_files)
    fprintf('No configuration files found. Please run the 100-simulation test first.\n');
    return;
end

% Load the latest configuration
[~, idx] = sort([config_files.datenum], 'descend');
latest_config = config_files(idx(1)).name;
fprintf('Loading configuration: %s\n', latest_config);
load(['100_Simulation_Test_Dataset/' latest_config]);

%% Analyze simulation performance
fprintf('\n--- Simulation Performance Analysis ---\n');

% Extract timing information
if isfield(config, 'generation_time')
    generation_time = config.generation_time;
    fprintf('Dataset generation time: %s\n', datestr(generation_time));
end

% Calculate time per simulation
if isfield(config, 'num_simulations') && isfield(config, 'simulation_duration')
    num_sims = config.num_simulations;
    sim_duration = config.simulation_duration;
    
    % Estimate total simulation time (if not directly available)
    % Based on typical performance: ~0.5-2 seconds per simulation
    estimated_time_per_sim = 1.0;  % seconds (conservative estimate)
    total_estimated_time = num_sims * estimated_time_per_sim;
    
    fprintf('Number of simulations: %d\n', num_sims);
    fprintf('Simulation duration: %.2f seconds each\n', sim_duration);
    fprintf('Estimated time per simulation: %.2f seconds\n', estimated_time_per_sim);
    fprintf('Total estimated generation time: %.1f minutes\n', total_estimated_time / 60);
end

%% Dataset size recommendations
fprintf('\n--- Dataset Size Recommendations ---\n');

% Calculate data requirements for different model complexities
model_complexities = {
    'Basic Model (28 DOF, simple dynamics)', 1000;
    'Standard Model (28 DOF, full dynamics)', 5000;
    'Advanced Model (28 DOF + flexible beam)', 10000;
    'Expert Model (28 DOF + beam + contact)', 20000;
    'Research Model (full complexity + variations)', 50000;
};

fprintf('Recommended dataset sizes for different model complexities:\n');
fprintf('%-50s %-15s %-15s %-15s\n', 'Model Complexity', 'Simulations', 'Time (hours)', 'Storage (GB)');
fprintf('%-50s %-15s %-15s %-15s\n', '-------------', '-----------', '-----------', '-----------');

for i = 1:size(model_complexities, 1)
    complexity = model_complexities{i, 1};
    num_sims = model_complexities{i, 2};
    
    % Calculate time requirements
    time_per_sim = 1.0;  % seconds
    total_time_hours = (num_sims * time_per_sim) / 3600;
    
    % Calculate storage requirements
    % Per simulation: 28 joints * 4 signals * 300 time steps * 8 bytes = ~270 KB
    storage_per_sim = 270 * 1024;  % bytes
    total_storage_gb = (num_sims * storage_per_sim) / (1024^3);
    
    fprintf('%-50s %-15d %-15.1f %-15.1f\n', complexity, num_sims, total_time_hours, total_storage_gb);
end

%% Parallel processing analysis
fprintf('\n--- Parallel Processing Analysis ---\n');

% Calculate speedup with different numbers of cores
num_cores_options = [1, 4, 8, 16, 32];
base_time = 10000;  % seconds for 10k simulations

fprintf('Parallel processing speedup analysis:\n');
fprintf('%-10s %-15s %-15s %-15s\n', 'Cores', 'Speedup', 'Time (hours)', 'Efficiency');
fprintf('%-10s %-15s %-15s %-15s\n', '-----', '-------', '-----------', '----------');

for i = 1:length(num_cores_options)
    num_cores = num_cores_options(i);
    
    % Amdahl's law: speedup = 1 / (s + p/n) where s=serial fraction, p=parallel fraction
    % Assuming 90% parallelizable (typical for independent simulations)
    serial_fraction = 0.1;
    parallel_fraction = 0.9;
    speedup = 1 / (serial_fraction + parallel_fraction / num_cores);
    
    % Calculate time and efficiency
    parallel_time = base_time / speedup;
    parallel_time_hours = parallel_time / 3600;
    efficiency = speedup / num_cores * 100;
    
    fprintf('%-10d %-15.2f %-15.1f %-15.1f%%\n', num_cores, speedup, parallel_time_hours, efficiency);
end

%% Memory requirements analysis
fprintf('\n--- Memory Requirements Analysis ---\n');

% Calculate memory requirements for different batch sizes
batch_sizes = [1, 10, 50, 100, 500];
memory_per_sim = 1;  % MB per simulation

fprintf('Memory requirements for different batch sizes:\n');
fprintf('%-15s %-15s %-15s\n', 'Batch Size', 'Memory (MB)', 'Memory (GB)');
fprintf('%-15s %-15s %-15s\n', '----------', '-----------', '-----------');

for i = 1:length(batch_sizes)
    batch_size = batch_sizes(i);
    memory_mb = batch_size * memory_per_sim;
    memory_gb = memory_mb / 1024;
    
    fprintf('%-15d %-15d %-15.2f\n', batch_size, memory_mb, memory_gb);
end

%% Optimization recommendations
fprintf('\n--- Optimization Recommendations ---\n');

fprintf('For your redundant parallel mechanism activation task:\n\n');

fprintf('1. DATASET SIZE RECOMMENDATIONS:\n');
fprintf('   - Minimum viable dataset: 5,000 simulations\n');
fprintf('   - Recommended dataset: 10,000-20,000 simulations\n');
fprintf('   - Research-grade dataset: 50,000+ simulations\n\n');

fprintf('2. SIMULATION PARAMETERS:\n');
fprintf('   - Duration: 0.3-0.5 seconds (captures key swing phases)\n');
fprintf('   - Sample rate: 1000 Hz (adequate for neural network training)\n');
fprintf('   - Joint ranges: ±90° for most joints (realistic golf swing)\n\n');

fprintf('3. COMPUTATIONAL OPTIMIZATION:\n');
fprintf('   - Use parallel processing (8-16 cores recommended)\n');
fprintf('   - Batch size: 50-100 simulations per batch\n');
fprintf('   - Memory requirement: ~50-100 MB per batch\n');
fprintf('   - Storage requirement: ~2-5 GB for 10k simulations\n\n');

fprintf('4. NEURAL NETWORK TRAINING:\n');
fprintf('   - Input features: Joint positions, velocities, accelerations\n');
fprintf('   - Output targets: Joint torques (28 DOF)\n');
fprintf('   - Include segment dimensions as additional features\n');
fprintf('   - Use temporal continuity constraints\n');
fprintf('   - Architecture: 512-256-128-64 hidden layers\n\n');

fprintf('5. REDUNDANCY HANDLING:\n');
fprintf('   - Primary control: 6 DOF for midhands pose\n');
fprintf('   - Secondary optimization: Energy efficiency, joint limits\n');
fprintf('   - Use weighted loss functions for different objectives\n');
fprintf('   - Implement regularization for smooth torque profiles\n\n');

%% Time estimates for different dataset sizes
fprintf('--- Time Estimates for Dataset Generation ---\n');

dataset_sizes = [1000, 5000, 10000, 20000, 50000];
time_per_sim = 1.0;  % seconds

fprintf('%-15s %-15s %-15s %-15s\n', 'Dataset Size', 'Time (hours)', 'Time (days)', 'Parallel (4 cores)');
fprintf('%-15s %-15s %-15s %-15s\n', '------------', '-----------', '-----------', '----------------');

for i = 1:length(dataset_sizes)
    num_sims = dataset_sizes(i);
    total_time_seconds = num_sims * time_per_sim;
    total_time_hours = total_time_seconds / 3600;
    total_time_days = total_time_hours / 24;
    
    % Parallel time with 4 cores (assuming 3.5x speedup)
    parallel_time_hours = total_time_hours / 3.5;
    
    fprintf('%-15d %-15.1f %-15.1f %-15.1f\n', num_sims, total_time_hours, total_time_days, parallel_time_hours);
end

fprintf('\n=== Analysis Complete ===\n'); 