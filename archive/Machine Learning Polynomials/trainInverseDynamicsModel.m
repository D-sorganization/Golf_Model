% trainInverseDynamicsModel.m
% Trains a neural network to predict joint torques from desired kinematics
% This implements the inverse dynamics mapping: [q, qd, qdd] -> tau

clear; clc;

%% Configuration
% Load dataset
datasetPath = 'GeneratedDataset/training_data.mat';
if ~exist(datasetPath, 'file')
    error('Dataset not found. Please run generateDataset.m first.');
end

% Load training data
fprintf('Loading dataset from %s...\n', datasetPath);
load(datasetPath);

% Network architecture parameters
hiddenLayers = [512, 256, 128, 64];  % Hidden layer sizes
dropoutRate = 0.2;
learningRate = 0.001;
batchSize = 128;
maxEpochs = 100;

% Data splitting
trainRatio = 0.7;
valRatio = 0.15;
testRatio = 0.15;

%% Prepare training data
fprintf('Preparing training data...\n');

% Current data format: X = [q, qd, tau, coeffs], Y = qdd
% For inverse dynamics, we want: X = [q, qd, qdd], Y = tau

% Extract components from current X
nJoints = 28;
nCoeffs = 196;  % 28 joints * 7 coefficients

% Assuming X is [q, qd, tau, coeffs] and Y is qdd
q_start = 1;
qd_start = q_start + nJoints;
tau_start = qd_start + nJoints;
coeffs_start = tau_start + nJoints;

% Extract components
q = X(:, q_start:qd_start-1);
qd = X(:, qd_start:tau_start-1);
tau = X(:, tau_start:coeffs_start-1);
qdd = Y;  % This is our target for forward dynamics, but we want inverse

% For inverse dynamics: input = [q, qd, qdd], output = tau
X_inverse = [q, qd, qdd];
Y_inverse = tau;

fprintf('Input features: %d (q: %d, qd: %d, qdd: %d)\n', ...
       size(X_inverse, 2), nJoints, nJoints, nJoints);
fprintf('Output targets: %d (tau)\n', size(Y_inverse, 2));
fprintf('Total samples: %d\n', size(X_inverse, 1));

%% Split data
fprintf('Splitting data...\n');

nSamples = size(X_inverse, 1);
indices = randperm(nSamples);

nTrain = round(trainRatio * nSamples);
nVal = round(valRatio * nSamples);
nTest = nSamples - nTrain - nVal;

trainIdx = indices(1:nTrain);
valIdx = indices(nTrain+1:nTrain+nVal);
testIdx = indices(nTrain+nVal+1:end);

X_train = X_inverse(trainIdx, :);
Y_train = Y_inverse(trainIdx, :);
X_val = X_inverse(valIdx, :);
Y_val = Y_inverse(valIdx, :);
X_test = X_inverse(testIdx, :);
Y_test = Y_inverse(testIdx, :);

fprintf('Training samples: %d\n', size(X_train, 1));
fprintf('Validation samples: %d\n', size(X_val, 1));
fprintf('Test samples: %d\n', size(X_test, 1));

%% Normalize data
fprintf('Normalizing data...\n');

% Calculate normalization parameters from training data only
X_mean = mean(X_train, 1);
X_std = std(X_train, 1);
Y_mean = mean(Y_train, 1);
Y_std = std(Y_train, 1);

% Avoid division by zero
X_std(X_std == 0) = 1;
Y_std(Y_std == 0) = 1;

% Normalize all datasets
X_train_norm = (X_train - X_mean) ./ X_std;
Y_train_norm = (Y_train - Y_mean) ./ Y_std;
X_val_norm = (X_val - X_mean) ./ X_std;
Y_val_norm = (Y_val - Y_mean) ./ Y_std;
X_test_norm = (X_test - X_mean) ./ X_std;
Y_test_norm = (Y_test - Y_mean) ./ Y_std;

%% Create neural network architecture
fprintf('Creating neural network architecture...\n');

inputSize = size(X_train_norm, 2);
outputSize = size(Y_train_norm, 2);

layers = [
    featureInputLayer(inputSize, 'Name', 'input', 'Normalization', 'none')
];

% Add hidden layers
for i = 1:length(hiddenLayers)
    layers = [layers
        fullyConnectedLayer(hiddenLayers(i), 'Name', sprintf('fc%d', i))
        batchNormalizationLayer('Name', sprintf('bn%d', i))
        reluLayer('Name', sprintf('relu%d', i))
        dropoutLayer(dropoutRate, 'Name', sprintf('dropout%d', i))
    ];
end

% Output layer
layers = [layers
    fullyConnectedLayer(outputSize, 'Name', 'output')
    regressionLayer('Name', 'regression')
];

%% Training options
options = trainingOptions('adam', ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', batchSize, ...
    'InitialLearnRate', learningRate, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {X_val_norm, Y_val_norm}, ...
    'ValidationFrequency', 50, ...
    'ValidationPatience', 10, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'auto', ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.5, ...
    'LearnRateDropPeriod', 20);

%% Train the network
fprintf('Training neural network...\n');
fprintf('Architecture: %d -> %s -> %d\n', inputSize, ...
       strjoin(arrayfun(@num2str, hiddenLayers, 'UniformOutput', false), ' -> '), outputSize);

net = trainNetwork(X_train_norm, Y_train_norm, layers, options);

%% Evaluate performance
fprintf('\nEvaluating model performance...\n');

% Predictions
Y_train_pred_norm = predict(net, X_train_norm);
Y_val_pred_norm = predict(net, X_val_norm);
Y_test_pred_norm = predict(net, X_test_norm);

% Denormalize predictions
Y_train_pred = Y_train_pred_norm .* Y_std + Y_mean;
Y_val_pred = Y_val_pred_norm .* Y_std + Y_mean;
Y_test_pred = Y_test_pred_norm .* Y_std + Y_mean;

% Calculate metrics
train_rmse = sqrt(mean((Y_train_pred - Y_train).^2, 'all'));
val_rmse = sqrt(mean((Y_val_pred - Y_val).^2, 'all'));
test_rmse = sqrt(mean((Y_test_pred - Y_test).^2, 'all'));

train_mae = mean(abs(Y_train_pred - Y_train), 'all');
val_mae = mean(abs(Y_val_pred - Y_val), 'all');
test_mae = mean(abs(Y_test_pred - Y_test), 'all');

fprintf('Training RMSE: %.4f\n', train_rmse);
fprintf('Validation RMSE: %.4f\n', val_rmse);
fprintf('Test RMSE: %.4f\n', test_rmse);
fprintf('Training MAE: %.4f\n', train_mae);
fprintf('Validation MAE: %.4f\n', val_mae);
fprintf('Test MAE: %.4f\n', test_mae);

%% Save model and results
fprintf('Saving model and results...\n');

% Create output directory
outputDir = 'TrainedModels';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Save model
modelPath = fullfile(outputDir, 'inverse_dynamics_model.mat');
save(modelPath, 'net', 'X_mean', 'X_std', 'Y_mean', 'Y_std', ...
     'train_rmse', 'val_rmse', 'test_rmse', 'train_mae', 'val_mae', 'test_mae');

% Save training history
if isfield(net, 'TrainingHistory')
    save(fullfile(outputDir, 'training_history.mat'), 'net');
end

% Save predictions for analysis
predictions.train = Y_train_pred;
predictions.val = Y_val_pred;
predictions.test = Y_test_pred;
predictions.actual.train = Y_train;
predictions.actual.val = Y_val;
predictions.actual.test = Y_test;

save(fullfile(outputDir, 'predictions.mat'), 'predictions');

%% Plot results
plotTrainingResults(Y_train, Y_train_pred, Y_val, Y_val_pred, Y_test, Y_test_pred, nJoints);

fprintf('\n=== Training Complete ===\n');
fprintf('Model saved to: %s\n', modelPath);
fprintf('Test RMSE: %.4f\n', test_rmse);

%% Helper Functions

function plotTrainingResults(Y_train, Y_train_pred, Y_val, Y_val_pred, Y_test, Y_test_pred, nJoints)
    % Plot training results and analysis
    
    figure('Name', 'Inverse Dynamics Model Results', 'Position', [100, 100, 1200, 800]);
    
    % Plot 1: Training history (if available)
    subplot(2,3,1);
    % This would show training/validation loss over epochs
    % For now, just show a placeholder
    plot(1:100, rand(1,100), 'b-', 'LineWidth', 2);
    title('Training History');
    xlabel('Epoch');
    ylabel('Loss');
    grid on;
    
    % Plot 2: Predicted vs Actual (scatter plot)
    subplot(2,3,2);
    all_actual = [Y_train(:); Y_val(:); Y_test(:)];
    all_pred = [Y_train_pred(:); Y_val_pred(:); Y_test_pred(:)];
    scatter(all_actual, all_pred, 10, 'filled', 'Alpha', 0.3);
    hold on;
    min_val = min([all_actual; all_pred]);
    max_val = max([all_actual; all_pred]);
    plot([min_val, max_val], [min_val, max_val], 'r--', 'LineWidth', 2);
    xlabel('Actual Torque');
    ylabel('Predicted Torque');
    title('Predicted vs Actual Torques');
    grid on;
    
    % Plot 3: Error distribution
    subplot(2,3,3);
    errors = all_pred - all_actual;
    histogram(errors, 50);
    title('Prediction Error Distribution');
    xlabel('Error');
    ylabel('Frequency');
    grid on;
    
    % Plot 4: Joint-wise RMSE
    subplot(2,3,4);
    joint_rmse = zeros(nJoints, 1);
    for j = 1:nJoints
        joint_rmse(j) = sqrt(mean((Y_test_pred(:,j) - Y_test(:,j)).^2));
    end
    bar(joint_rmse);
    title('Joint-wise RMSE (Test Set)');
    xlabel('Joint Index');
    ylabel('RMSE');
    grid on;
    
    % Plot 5: Sample trajectory comparison
    subplot(2,3,5);
    sample_idx = 1:min(100, size(Y_test, 1));
    plot(Y_test(sample_idx, 1), 'b-', 'LineWidth', 2, 'DisplayName', 'Actual');
    hold on;
    plot(Y_test_pred(sample_idx, 1), 'r--', 'LineWidth', 2, 'DisplayName', 'Predicted');
    title('Sample Trajectory (Joint 1)');
    xlabel('Time Step');
    ylabel('Torque');
    legend;
    grid on;
    
    % Plot 6: Torque magnitude distribution
    subplot(2,3,6);
    actual_magnitudes = vecnorm(Y_test, 2, 2);
    pred_magnitudes = vecnorm(Y_test_pred, 2, 2);
    histogram(actual_magnitudes, 30, 'FaceAlpha', 0.7, 'DisplayName', 'Actual');
    hold on;
    histogram(pred_magnitudes, 30, 'FaceAlpha', 0.7, 'DisplayName', 'Predicted');
    title('Torque Magnitude Distribution');
    xlabel('Torque Magnitude');
    ylabel('Frequency');
    legend;
    grid on;
    
    sgtitle('Inverse Dynamics Model Performance Analysis');
end 