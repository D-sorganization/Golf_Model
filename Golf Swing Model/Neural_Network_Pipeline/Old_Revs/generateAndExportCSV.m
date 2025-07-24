% generateAndExportCSV.m
% Generate dataset and export to CSV files automatically
% This script runs the complete pipeline and creates the CSV files you need

clear; clc; close all;

fprintf('=== Generate Dataset and Export to CSV ===\n\n');

% Add scripts to path
addpath('Scripts');

%% Step 1: Generate Dataset
fprintf('Step 1: Generating dataset...\n');

% Configure for reasonable number of simulations
config = struct();
config.num_simulations = 10;  % Start with 10, can increase later
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

fprintf('\n=== Dataset Generation Complete ===\n');
fprintf('Total time: %.2f seconds\n', total_time);
fprintf('Total time: %.2f minutes\n', total_time/60);
fprintf('Average per simulation: %.2f seconds\n', total_time/config.num_simulations);

%% Step 2: Export to CSV
fprintf('\nStep 2: Exporting to CSV...\n');

% Run the CSV export script
exportDatasetToCSV;

fprintf('\n=== Complete! ===\n');
fprintf('CSV files have been generated in the current directory.\n');
fprintf('Look for files with names like:\n');
fprintf('  - simulation_*_data_*.csv (individual simulation data)\n');
fprintf('  - training_*_*.csv (training datasets)\n');
fprintf('  - dataset_summary_*.csv (summary information)\n');

% List the generated CSV files
fprintf('\nGenerated CSV files:\n');
csv_files = dir('*.csv');
for i = 1:length(csv_files)
    fprintf('  - %s (%s)\n', csv_files(i).name, formatFileSize(csv_files(i).bytes));
end

fprintf('\n=== Pipeline Complete ===\n');

%% Helper function to format file size
function size_str = formatFileSize(bytes)
    if bytes < 1024
        size_str = sprintf('%d B', bytes);
    elseif bytes < 1024^2
        size_str = sprintf('%.1f KB', bytes/1024);
    elseif bytes < 1024^3
        size_str = sprintf('%.1f MB', bytes/1024^2);
    else
        size_str = sprintf('%.1f GB', bytes/1024^3);
    end
end 