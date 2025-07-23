% trainKinematicsToPolynomialMap.m
% Trains a neural network to map from desired kinematics to polynomial inputs
% 
% This script:
% 1. Loads the generated dataset
% 2. Extracts kinematics (output) and polynomial inputs (target)
% 3. Preprocesses the data for neural network training
% 4. Trains a neural network to predict polynomial coefficients
% 5. Evaluates the model and saves the trained network

clear; clc; close all;

fprintf('=== Kinematics to Polynomial Mapping Neural Network ===\n\n');

%% Configuration
config = struct();

% Data configuration
config.dataset_path = 'golf_swing_dataset_*.mat'; % Use wildcard to find latest
config.test_split = 0.2; % 20% for testing
config.validation_split = 0.1; % 10% for validation
config.random_seed = 42;

% Neural network configuration
config.hidden_layers = [256, 128, 64]; % Hidden layer sizes
config.learning_rate = 0.001;
config.batch_size = 32;
config.max_epochs = 100;
config.early_stopping_patience = 10;
config.dropout_rate = 0.3;

% Kinematics features to use as input
config.kinematics_features = {
    'clubhead_speed_at_impact'
    'clubhead_position_at_impact'
    'clubhead_orientation_at_impact'
    'hand_speed_at_impact'
    'hand_position_at_impact'
    'maximum_clubhead_speed'
    'time_to_maximum_speed'
    'swing_duration'
    'impact_angle'
    'launch_angle'
};

% Polynomial outputs to predict
config.polynomial_outputs = {
    'hip_torque_x', 'hip_torque_y', 'hip_torque_z'
    'spine_torque_x', 'spine_torque_y'
    'left_shoulder_x', 'left_shoulder_y', 'left_shoulder_z'
    'right_shoulder_x', 'right_shoulder_y', 'right_shoulder_z'
    'left_elbow_z', 'right_elbow_z'
    'left_wrist_x', 'left_wrist_y'
    'right_wrist_x', 'right_wrist_y'
    'translation_force_x', 'translation_force_y', 'translation_force_z'
};

fprintf('Configuration:\n');
fprintf('  Dataset: %s\n', config.dataset_path);
fprintf('  Test split: %.1f%%\n', config.test_split * 100);
fprintf('  Validation split: %.1f%%\n', config.validation_split * 100);
fprintf('  Hidden layers: [%s]\n', num2str(config.hidden_layers));
fprintf('  Learning rate: %.6f\n', config.learning_rate);
fprintf('  Batch size: %d\n', config.batch_size);
fprintf('  Max epochs: %d\n', config.max_epochs);

%% Load dataset
fprintf('\nLoading dataset...\n');
dataset_files = dir(config.dataset_path);
if isempty(dataset_files)
    fprintf('✗ No dataset files found matching pattern: %s\n', config.dataset_path);
    return;
end

% Load the most recent dataset
[~, idx] = max([dataset_files.datenum]);
dataset_path = dataset_files(idx).name;
fprintf('Loading: %s\n', dataset_path);

try
    load(dataset_path);
    fprintf('✓ Dataset loaded successfully\n');
catch ME
    fprintf('✗ Failed to load dataset: %s\n', ME.message);
    return;
end

% Check if dataset has the expected structure
if ~isfield(dataset, 'simulations') || ~isfield(dataset, 'parameters')
    fprintf('✗ Dataset does not have expected structure\n');
    return;
end

%% Extract successful simulations
successful_indices = find(dataset.success_flags);
num_successful = length(successful_indices);

if num_successful == 0
    fprintf('✗ No successful simulations found in dataset\n');
    return;
end

fprintf('Found %d successful simulations\n', num_successful);

%% Prepare training data
fprintf('\nPreparing training data...\n');

% Initialize data arrays
X = []; % Kinematics features
Y = []; % Polynomial coefficients

% Extract features from each successful simulation
for i = 1:num_successful
    idx = successful_indices(i);
    
    % Get simulation data
    sim_data = dataset.simulations{idx};
    poly_inputs = dataset.parameters{idx}.polynomial_inputs;
    
    % Extract kinematics features
    kinematics_features = extractKinematicsFeatures(sim_data, config);
    
    % Extract polynomial coefficients
    polynomial_coeffs = extractPolynomialCoefficients(poly_inputs, config);
    
    % Add to data arrays
    X = [X; kinematics_features];
    Y = [Y; polynomial_coeffs];
    
    % Progress update
    if mod(i, 100) == 0
        fprintf('Processed %d/%d simulations\n', i, num_successful);
    end
end

fprintf('✓ Data preparation complete\n');
fprintf('Input features: %d\n', size(X, 2));
fprintf('Output coefficients: %d\n', size(Y, 2));
fprintf('Total samples: %d\n', size(X, 1));

%% Data preprocessing
fprintf('\nPreprocessing data...\n');

% Normalize features
X_mean = mean(X, 1);
X_std = std(X, 1);
X_normalized = (X - X_mean) ./ (X_std + 1e-8);

% Normalize outputs
Y_mean = mean(Y, 1);
Y_std = std(Y, 1);
Y_normalized = (Y - Y_mean) ./ (Y_std + 1e-8);

% Split data
rng(config.random_seed);
indices = randperm(size(X_normalized, 1));

test_size = round(config.test_split * size(X_normalized, 1));
val_size = round(config.validation_split * size(X_normalized, 1));
train_size = size(X_normalized, 1) - test_size - val_size;

test_indices = indices(1:test_size);
val_indices = indices(test_size+1:test_size+val_size);
train_indices = indices(test_size+val_size+1:end);

X_train = X_normalized(train_indices, :);
Y_train = Y_normalized(train_indices, :);
X_val = X_normalized(val_indices, :);
Y_val = Y_normalized(val_indices, :);
X_test = X_normalized(test_indices, :);
Y_test = Y_normalized(test_indices, :);

fprintf('Training set: %d samples\n', size(X_train, 1));
fprintf('Validation set: %d samples\n', size(X_val, 1));
fprintf('Test set: %d samples\n', size(X_test, 1));

%% Create neural network
fprintf('\nCreating neural network...\n');

% Define network architecture
layers = [
    featureInputLayer(size(X_train, 2), 'Name', 'input')
];

% Add hidden layers
for i = 1:length(config.hidden_layers)
    layers = [layers
        fullyConnectedLayer(config.hidden_layers(i), 'Name', sprintf('fc%d', i))
        batchNormalizationLayer('Name', sprintf('bn%d', i))
        reluLayer('Name', sprintf('relu%d', i))
        dropoutLayer(config.dropout_rate, 'Name', sprintf('dropout%d', i))
    ];
end

% Add output layer
layers = [layers
    fullyConnectedLayer(size(Y_train, 2), 'Name', 'output')
    regressionLayer('Name', 'regression')
];

% Create network
net = layerGraph(layers);

% Training options
options = trainingOptions('adam', ...
    'InitialLearnRate', config.learning_rate, ...
    'MaxEpochs', config.max_epochs, ...
    'MiniBatchSize', config.batch_size, ...
    'ValidationData', {X_val, Y_val}, ...
    'ValidationFrequency', 50, ...
    'ValidationPatience', config.early_stopping_patience, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'Shuffle', 'every-epoch');

fprintf('✓ Neural network created\n');

%% Train the network
fprintf('\nTraining neural network...\n');
training_start_time = tic;

[trained_net, training_info] = trainNetwork(X_train, Y_train, net, options);

training_time = toc(training_start_time);
fprintf('✓ Training completed in %.2f seconds\n', training_time);

%% Evaluate the model
fprintf('\nEvaluating model...\n');

% Predict on test set
Y_pred_normalized = predict(trained_net, X_test);

% Denormalize predictions
Y_pred = Y_pred_normalized .* (Y_std + 1e-8) + Y_mean;
Y_test_denorm = Y_test .* (Y_std + 1e-8) + Y_mean;

% Calculate metrics
mse = mean((Y_pred - Y_test_denorm).^2, 1);
rmse = sqrt(mse);
mae = mean(abs(Y_pred - Y_test_denorm), 1);
r_squared = 1 - sum((Y_test_denorm - Y_pred).^2, 1) ./ sum((Y_test_denorm - mean(Y_test_denorm, 1)).^2, 1);

fprintf('Test Set Performance:\n');
fprintf('  Mean RMSE: %.4f\n', mean(rmse));
fprintf('  Mean MAE: %.4f\n', mean(mae));
fprintf('  Mean R²: %.4f\n', mean(r_squared));

%% Save the trained model
fprintf('\nSaving trained model...\n');
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
model_filename = sprintf('kinematics_to_polynomial_model_%s.mat', timestamp);

% Create model structure
model = struct();
model.network = trained_net;
model.training_info = training_info;
model.config = config;
model.preprocessing = struct();
model.preprocessing.X_mean = X_mean;
model.preprocessing.X_std = X_std;
model.preprocessing.Y_mean = Y_mean;
model.preprocessing.Y_std = Y_std;
model.performance = struct();
model.performance.test_rmse = rmse;
model.performance.test_mae = mae;
model.performance.test_r_squared = r_squared;
model.performance.mean_rmse = mean(rmse);
model.performance.mean_mae = mean(mae);
model.performance.mean_r_squared = mean(r_squared);
model.training_time = training_time;
model.creation_time = datetime('now');

save(model_filename, 'model', '-v7.3');
fprintf('✓ Model saved to: %s\n', model_filename);

%% Generate prediction function
generatePredictionFunction(model, config, timestamp);

%% Plot results
plotTrainingResults(Y_test_denorm, Y_pred, config, timestamp);

%% Cleanup workspace
fprintf('\n=== Cleaning Workspace ===\n');

% Variables to keep
keep_vars = {'model', 'config', 'timestamp', 'training_time'};

% Get all variables in workspace
all_vars = who;

% Variables to remove
remove_vars = setdiff(all_vars, keep_vars);

if ~isempty(remove_vars)
    fprintf('Removing %d workspace variables:\n', length(remove_vars));
    for i = 1:length(remove_vars)
        fprintf('  - %s\n', remove_vars{i});
    end
    
    % Remove variables
    clear(remove_vars{:});
    fprintf('✓ Workspace cleaned\n');
else
    fprintf('✓ No variables to remove\n');
end

% Final workspace status
remaining_vars = who;
fprintf('Remaining variables: %d\n', length(remaining_vars));
for i = 1:length(remaining_vars)
    fprintf('  - %s\n', remaining_vars{i});
end

fprintf('\n=== Training Complete ===\n');
fprintf('Model successfully trained and saved!\n');

end

function features = extractKinematicsFeatures(sim_data, config)
% Extract kinematics features from simulation data
features = [];

% Extract features based on configuration
for i = 1:length(config.kinematics_features)
    feature_name = config.kinematics_features{i};
    
    switch feature_name
        case 'clubhead_speed_at_impact'
            % Calculate clubhead speed at impact
            if isfield(sim_data, 'clubhead_velocity')
                impact_idx = find(sim_data.time >= 0.8, 1); % Approximate impact time
                if ~isempty(impact_idx)
                    vel = sim_data.clubhead_velocity(impact_idx, :);
                    speed = sqrt(sum(vel.^2));
                    features = [features, speed];
                else
                    features = [features, 0];
                end
            else
                features = [features, 0];
            end
            
        case 'clubhead_position_at_impact'
            % Clubhead position at impact
            if isfield(sim_data, 'clubhead_position')
                impact_idx = find(sim_data.time >= 0.8, 1);
                if ~isempty(impact_idx)
                    pos = sim_data.clubhead_position(impact_idx, :);
                    features = [features, pos];
                else
                    features = [features, 0, 0, 0];
                end
            else
                features = [features, 0, 0, 0];
            end
            
        case 'maximum_clubhead_speed'
            % Maximum clubhead speed during swing
            if isfield(sim_data, 'clubhead_velocity')
                speeds = sqrt(sum(sim_data.clubhead_velocity.^2, 2));
                max_speed = max(speeds);
                features = [features, max_speed];
            else
                features = [features, 0];
            end
            
        case 'swing_duration'
            % Total swing duration
            duration = sim_data.time(end) - sim_data.time(1);
            features = [features, duration];
            
        otherwise
            % Default: extract from available data
            if isfield(sim_data, feature_name)
                data = sim_data.(feature_name);
                if isvector(data)
                    features = [features, data(end)]; % Use final value
                else
                    features = [features, data(end, :)]; % Use final row
                end
            else
                features = [features, 0];
            end
    end
end

end

function coeffs = extractPolynomialCoefficients(poly_inputs, config)
% Extract polynomial coefficients from polynomial inputs
coeffs = [];

for i = 1:length(config.polynomial_outputs)
    output_name = config.polynomial_outputs{i};
    
    if isfield(poly_inputs, output_name)
        coeffs = [coeffs, poly_inputs.(output_name)];
    else
        % Add zeros for missing coefficients
        coeffs = [coeffs, zeros(1, 5)]; % Assuming 5 coefficients per polynomial
    end
end

end

function generatePredictionFunction(model, config, timestamp)
% Generate a standalone prediction function
func_filename = sprintf('predictPolynomialFromKinematics_%s.m', timestamp);

fid = fopen(func_filename, 'w');

fprintf(fid, 'function polynomial_coeffs = predictPolynomialFromKinematics(kinematics_features)\n');
fprintf(fid, '%% predictPolynomialFromKinematics.m\n');
fprintf(fid, '%% Predicts polynomial coefficients from kinematics features\n');
fprintf(fid, '%%\n');
fprintf(fid, '%% Inputs:\n');
fprintf(fid, '%%   kinematics_features - Vector of kinematics features\n');
fprintf(fid, '%%\n');
fprintf(fid, '%% Outputs:\n');
fprintf(fid, '%%   polynomial_coeffs - Structure containing polynomial coefficients\n');
fprintf(fid, '\n');

% Add preprocessing constants
fprintf(fid, '%% Preprocessing constants\n');
fprintf(fid, 'X_mean = %s;\n', mat2str(model.preprocessing.X_mean));
fprintf(fid, 'X_std = %s;\n', mat2str(model.preprocessing.X_std));
fprintf(fid, 'Y_mean = %s;\n', mat2str(model.preprocessing.Y_mean));
fprintf(fid, 'Y_std = %s;\n', mat2str(model.preprocessing.Y_std));
fprintf(fid, '\n');

% Add prediction logic
fprintf(fid, '%% Normalize input features\n');
fprintf(fid, 'kinematics_normalized = (kinematics_features - X_mean) ./ (X_std + 1e-8);\n');
fprintf(fid, '\n');
fprintf(fid, '%% Load trained network\n');
fprintf(fid, 'persistent trained_net\n');
fprintf(fid, 'if isempty(trained_net)\n');
fprintf(fid, '    model_data = load(''%s'');\n', sprintf('kinematics_to_polynomial_model_%s.mat', timestamp));
fprintf(fid, '    trained_net = model_data.model.network;\n');
fprintf(fid, 'end\n');
fprintf(fid, '\n');
fprintf(fid, '%% Predict normalized coefficients\n');
fprintf(fid, 'coeffs_normalized = predict(trained_net, kinematics_normalized);\n');
fprintf(fid, '\n');
fprintf(fid, '%% Denormalize coefficients\n');
fprintf(fid, 'coeffs = coeffs_normalized .* (Y_std + 1e-8) + Y_mean;\n');
fprintf(fid, '\n');

% Add coefficient packaging
fprintf(fid, '%% Package coefficients into structure\n');
fprintf(fid, 'polynomial_coeffs = struct();\n');
coeff_idx = 1;
for i = 1:length(config.polynomial_outputs)
    output_name = config.polynomial_outputs{i};
    fprintf(fid, 'polynomial_coeffs.%s = coeffs(%d:%d);\n', output_name, coeff_idx, coeff_idx+4);
    coeff_idx = coeff_idx + 5;
end

fprintf(fid, '\nend\n');

fclose(fid);
fprintf('✓ Prediction function generated: %s\n', func_filename);

end

function plotTrainingResults(Y_true, Y_pred, config, timestamp)
% Plot training results
fig = figure('Position', [100, 100, 1200, 800]);

% Scatter plot of predicted vs true values
subplot(2, 2, 1);
scatter(Y_true(:), Y_pred(:), 'b.', 'Alpha', 0.3);
hold on;
plot([min(Y_true(:)), max(Y_true(:))], [min(Y_true(:)), max(Y_true(:))], 'r--', 'LineWidth', 2);
xlabel('True Values');
ylabel('Predicted Values');
title('Predicted vs True Values');
grid on;

% Residual plot
subplot(2, 2, 2);
residuals = Y_pred - Y_true;
scatter(Y_true(:), residuals(:), 'b.', 'Alpha', 0.3);
hold on;
plot([min(Y_true(:)), max(Y_true(:))], [0, 0], 'r--', 'LineWidth', 2);
xlabel('True Values');
ylabel('Residuals');
title('Residual Plot');
grid on;

% Histogram of residuals
subplot(2, 2, 3);
histogram(residuals(:), 50, 'Normalization', 'probability');
xlabel('Residuals');
ylabel('Probability');
title('Residual Distribution');
grid on;

% Performance metrics by output
subplot(2, 2, 4);
rmse_by_output = sqrt(mean((Y_pred - Y_true).^2, 1));
bar(rmse_by_output);
xlabel('Output Index');
ylabel('RMSE');
title('RMSE by Output');
grid on;

% Save plot
plot_filename = sprintf('training_results_%s.png', timestamp);
saveas(fig, plot_filename);
fprintf('✓ Training results plot saved: %s\n', plot_filename);

end 