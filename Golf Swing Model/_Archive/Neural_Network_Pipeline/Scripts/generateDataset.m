% generateDataset.m
% Generates a large dataset of golf swing simulations with random polynomial inputs
% for training a neural network to map kinematics to joint torques

clear; clc;

%% Configuration
nSimulations = 1000;  % Number of simulations to generate
nJoints = 28;
polyOrder = 7;  % 6th-degree polynomials (7 coefficients)
nCoeffs = nJoints * polyOrder;

% Coefficient bounds for random generation
coeffBounds = 50;

% Simulation parameters
simFlags.UseRigidClub = true;
simFlags.KillswitchGravity = false;

% Output settings
outputDir = '../Data';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% Generate random polynomial coefficients
fprintf('Generating %d random polynomial coefficient sets...\n', nSimulations);

% Generate random coefficients within bounds
coeffMatrix = (rand(nSimulations, nCoeffs) - 0.5) * 2 * coeffBounds;

% Optional: Add some structure to make swings more realistic
% This could include constraints on certain joints or temporal patterns
for i = 1:nSimulations
    % Add some correlation between related joints (e.g., left/right symmetry)
    % This is a simple example - you might want more sophisticated constraints
    coeffMatrix(i, :) = addRealisticConstraints(coeffMatrix(i, :), nJoints, polyOrder);
end

%% Run simulations in batches
batchSize = 10;  % Process simulations in batches to manage memory
nBatches = ceil(nSimulations / batchSize);

% Initialize storage
allData = struct();
allData.coeffs = coeffMatrix;
allData.simulations = cell(nSimulations, 1);
allData.successful = false(nSimulations, 1);

fprintf('Running %d simulations in %d batches...\n', nSimulations, nBatches);

for batch = 1:nBatches
    fprintf('Processing batch %d/%d...\n', batch, nBatches);
    
    % Get indices for this batch
    startIdx = (batch-1) * batchSize + 1;
    endIdx = min(batch * batchSize, nSimulations);
    batchIndices = startIdx:endIdx;
    
    % Generate simulation inputs for this batch
    batchCoeffs = coeffMatrix(batchIndices, :);
    simInputs = generateSimInputs(batchCoeffs, simFlags);
    
    try
        % Run batch simulation
        simOut = parsim(simInputs, 'ShowProgress', false, ...
                       'TransferBaseWorkspaceVariables', 'on', ...
                       'ReuseBlockConfigurations', true);
        
        % Process each simulation in the batch
        for i = 1:length(batchIndices)
            simIdx = batchIndices(i);
            
            try
                % Extract kinematics from simulation output
                simData = extractSimKinematics(simOut(i));
                
                % Store successful simulation
                allData.simulations{simIdx} = simData;
                allData.successful(simIdx) = true;
                
                fprintf('  Simulation %d: Success (CHS: %.1f mph)\n', ...
                       simIdx, max(simData.CHS_mph));
                
            catch ME
                fprintf('  Simulation %d: Failed - %s\n', simIdx, ME.message);
                allData.successful(simIdx) = false;
            end
        end
        
    catch ME
        fprintf('  Batch %d failed: %s\n', batch, ME.message);
        allData.successful(batchIndices) = false;
    end
end

%% Compile training dataset
fprintf('\nCompiling training dataset...\n');

successfulSims = find(allData.successful);
nSuccessful = length(successfulSims);

if nSuccessful == 0
    error('No successful simulations generated!');
end

fprintf('Successfully generated %d/%d simulations (%.1f%%)\n', ...
       nSuccessful, nSimulations, 100*nSuccessful/nSimulations);

% Initialize training data arrays
X = [];  % Input features: [q, qd, tau, coeffs]
Y = [];  % Output targets: qdd

% Process each successful simulation
for i = 1:nSuccessful
    simIdx = successfulSims(i);
    simData = allData.simulations{simIdx};
    coeffs = allData.coeffs(simIdx, :);
    
    % Extract features and targets
    q = simData.q;      % Joint positions
    qd = simData.qd;    % Joint velocities
    qdd = simData.qdd;  % Joint accelerations (target)
    tau = simData.tau;  % Joint torques
    
    nFrames = size(q, 1);
    
    % Create feature matrix for this simulation
    % Features: [q, qd, tau, coeffs] for each time step
    coeffsMatrix = repmat(coeffs, nFrames, 1);
    X_i = [q, qd, tau, coeffsMatrix];
    Y_i = qdd;
    
    % Append to training data
    X = [X; X_i];
    Y = [Y; Y_i];
end

%% Save dataset
fprintf('Saving dataset...\n');

% Save full dataset
save(fullfile(outputDir, 'golf_swing_dataset.mat'), ...
     'X', 'Y', 'allData', 'nSimulations', 'nSuccessful', ...
     'nJoints', 'polyOrder', 'nCoeffs', 'coeffBounds');

% Save training data separately for easy loading
save(fullfile(outputDir, 'training_data.mat'), 'X', 'Y');

% Save metadata
metadata.nSimulations = nSimulations;
metadata.nSuccessful = nSuccessful;
metadata.nJoints = nJoints;
metadata.polyOrder = polyOrder;
metadata.nCoeffs = nCoeffs;
metadata.coeffBounds = coeffBounds;
metadata.featureDim = size(X, 2);
metadata.targetDim = size(Y, 2);
metadata.nSamples = size(X, 1);

save(fullfile(outputDir, 'dataset_metadata.mat'), 'metadata');

%% Print summary
fprintf('\n=== Dataset Generation Complete ===\n');
fprintf('Total simulations: %d\n', nSimulations);
fprintf('Successful simulations: %d (%.1f%%)\n', nSuccessful, 100*nSuccessful/nSimulations);
fprintf('Training samples: %d\n', size(X, 1));
fprintf('Feature dimension: %d\n', size(X, 2));
fprintf('Target dimension: %d\n', size(Y, 2));
fprintf('Dataset saved to: %s\n', outputDir);

% Optional: Plot some statistics
plotDatasetStats(allData, successfulSims);

%% Helper Functions

function coeffs = addRealisticConstraints(coeffs, nJoints, polyOrder)
    % Add realistic constraints to make swings more physically plausible
    % This is a simple example - you might want more sophisticated constraints
    
    % Example: Reduce high-order coefficients for stability
    for j = 1:nJoints
        offset = (j-1) * polyOrder;
        % Reduce magnitude of higher-order terms
        coeffs(offset + 4:offset + 7) = coeffs(offset + 4:offset + 7) * 0.5;
    end
    
    % Example: Add some symmetry between left/right joints
    % This would depend on your specific joint ordering
end

function plotDatasetStats(allData, successfulSims)
    % Plot some basic statistics about the generated dataset
    
    figure('Name', 'Dataset Statistics');
    
    % Plot successful vs failed simulations
    subplot(2,2,1);
    successful = allData.successful;
    bar([sum(successful), sum(~successful)]);
    set(gca, 'XTickLabel', {'Successful', 'Failed'});
    title('Simulation Success Rate');
    ylabel('Count');
    
    % Plot coefficient distribution
    subplot(2,2,2);
    coeffs = allData.coeffs(successfulSims, :);
    histogram(coeffs(:), 50);
    title('Coefficient Distribution');
    xlabel('Coefficient Value');
    ylabel('Frequency');
    
    % Plot clubhead speeds
    subplot(2,2,3);
    chs_values = [];
    for i = 1:length(successfulSims)
        simData = allData.simulations{successfulSims(i)};
        chs_values = [chs_values; max(simData.CHS_mph)];
    end
    histogram(chs_values, 20);
    title('Clubhead Speed Distribution');
    xlabel('Max CHS (mph)');
    ylabel('Frequency');
    
    % Plot simulation durations
    subplot(2,2,4);
    durations = [];
    for i = 1:length(successfulSims)
        simData = allData.simulations{successfulSims(i)};
        durations = [durations; simData.duration];
    end
    histogram(durations, 20);
    title('Simulation Duration Distribution');
    xlabel('Duration (s)');
    ylabel('Frequency');
    
    sgtitle('Golf Swing Dataset Statistics');
end 