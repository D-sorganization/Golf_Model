% trainWithTemporalContinuity.m
% Trains neural network with temporal continuity constraints
% Minimizes torque rate changes while fitting motion profiles

function [net, training_info] = trainWithTemporalContinuity(X, Y, config)
    % Train neural network with temporal continuity constraints
    %
    % Inputs:
    %   X - Input features [samples x features]
    %   Y - Target torques [samples x joints]
    %   config - Training configuration structure
    %
    % Outputs:
    %   net - Trained neural network
    %   training_info - Training statistics and results
    
    if nargin < 3
        config = struct();
    end
    
    % Set default configuration
    config = setDefaultConfig(config);
    
    fprintf('=== Training Neural Network with Temporal Continuity ===\n\n');
    
    % Prepare temporal data
    [X_temporal, Y_temporal, time_indices] = prepareTemporalData(X, Y, config);
    
    % Split data maintaining temporal order
    [X_train, Y_train, X_val, Y_val, X_test, Y_test] = splitTemporalData(X_temporal, Y_temporal, config);
    
    % Normalize data
    [X_train_norm, X_val_norm, X_test_norm, X_mean, X_std] = normalizeData(X_train, X_val, X_test);
    [Y_train_norm, Y_val_norm, Y_test_norm, Y_mean, Y_std] = normalizeData(Y_train, Y_val, Y_test);
    
    % Create neural network architecture
    net = createTemporalNetwork(size(X_train_norm, 2), size(Y_train_norm, 2), config);
    
    % Custom training with temporal continuity loss
    [net, training_info] = trainTemporalNetwork(net, X_train_norm, Y_train_norm, ...
        X_val_norm, Y_val_norm, X_mean, X_std, Y_mean, Y_std, config);
    
    % Evaluate performance
    training_info = evaluateTemporalPerformance(net, X_test_norm, Y_test_norm, ...
        X_mean, X_std, Y_mean, Y_std, Y_test, training_info);
    
    fprintf('Training complete.\n');
end

function config = setDefaultConfig(config)
    % Set default configuration parameters
    
    if ~isfield(config, 'temporal_window')
        config.temporal_window = 5;  % Number of time steps to consider
    end
    
    if ~isfield(config, 'continuity_weight')
        config.continuity_weight = 0.1;  % Weight for temporal continuity loss
    end
    
    if ~isfield(config, 'hidden_layers')
        config.hidden_layers = [512, 256, 128, 64];
    end
    
    if ~isfield(config, 'learning_rate')
        config.learning_rate = 0.001;
    end
    
    if ~isfield(config, 'batch_size')
        config.batch_size = 128;
    end
    
    if ~isfield(config, 'max_epochs')
        config.max_epochs = 100;
    end
    
    if ~isfield(config, 'dropout_rate')
        config.dropout_rate = 0.2;
    end
    
    if ~isfield(config, 'train_ratio')
        config.train_ratio = 0.7;
    end
    
    if ~isfield(config, 'val_ratio')
        config.val_ratio = 0.15;
    end
    
    if ~isfield(config, 'test_ratio')
        config.test_ratio = 0.15;
    end
end

function [X_temporal, Y_temporal, time_indices] = prepareTemporalData(X, Y, config)
    % Prepare data with temporal context for continuity training
    
    fprintf('Preparing temporal data...\n');
    
    n_samples = size(X, 1);
    n_features = size(X, 2);
    n_joints = size(Y, 2);
    window_size = config.temporal_window;
    
    % Calculate number of temporal samples
    n_temporal_samples = n_samples - window_size + 1;
    
    % Initialize temporal arrays
    X_temporal = zeros(n_temporal_samples, n_features * window_size);
    Y_temporal = zeros(n_temporal_samples, n_joints);
    time_indices = zeros(n_temporal_samples, 1);
    
    % Create temporal windows
    for i = 1:n_temporal_samples
        % Extract temporal window
        window_start = i;
        window_end = i + window_size - 1;
        
        % Flatten temporal features
        X_window = X(window_start:window_end, :);
        X_temporal(i, :) = X_window(:)';
        
        % Target is the middle time step (or last time step)
        target_idx = round((window_start + window_end) / 2);
        Y_temporal(i, :) = Y(target_idx, :);
        
        time_indices(i) = target_idx;
    end
    
    fprintf('Temporal data prepared: %d samples with %d-step window\n', ...
        n_temporal_samples, window_size);
end

function [X_train, Y_train, X_val, Y_val, X_test, Y_test] = splitTemporalData(X, Y, config)
    % Split data maintaining temporal order
    
    n_samples = size(X, 1);
    
    % Calculate split indices
    n_train = round(config.train_ratio * n_samples);
    n_val = round(config.val_ratio * n_samples);
    n_test = n_samples - n_train - n_val;
    
    % Split maintaining temporal order
    train_idx = 1:n_train;
    val_idx = n_train + 1:n_train + n_val;
    test_idx = n_train + n_val + 1:n_samples;
    
    X_train = X(train_idx, :);
    Y_train = Y(train_idx, :);
    X_val = X(val_idx, :);
    Y_val = Y(val_idx, :);
    X_test = X(test_idx, :);
    Y_test = Y(test_idx, :);
    
    fprintf('Data split: Train=%d, Val=%d, Test=%d\n', n_train, n_val, n_test);
end

function [X_norm, X_val_norm, X_test_norm, X_mean, X_std] = normalizeData(X, X_val, X_test)
    % Normalize data using training set statistics
    
    X_mean = mean(X, 1);
    X_std = std(X, 1);
    X_std(X_std == 0) = 1;  % Avoid division by zero
    
    X_norm = (X - X_mean) ./ X_std;
    X_val_norm = (X_val - X_mean) ./ X_std;
    X_test_norm = (X_test - X_mean) ./ X_std;
end

function net = createTemporalNetwork(input_size, output_size, config)
    % Create neural network architecture optimized for temporal continuity
    
    fprintf('Creating temporal network architecture...\n');
    
    layers = [
        featureInputLayer(input_size, 'Name', 'input', 'Normalization', 'none')
    ];
    
    % Add hidden layers with temporal considerations
    for i = 1:length(config.hidden_layers)
        layers = [layers
            fullyConnectedLayer(config.hidden_layers(i), 'Name', sprintf('fc%d', i))
            batchNormalizationLayer('Name', sprintf('bn%d', i))
            reluLayer('Name', sprintf('relu%d', i))
            dropoutLayer(config.dropout_rate, 'Name', sprintf('dropout%d', i))
        ];
    end
    
    % Output layer
    layers = [layers
        fullyConnectedLayer(output_size, 'Name', 'output')
        regressionLayer('Name', 'regression')
    ];
    
    net = layerGraph(layers);
    
    fprintf('Network created: %d -> %s -> %d\n', input_size, ...
        strjoin(arrayfun(@num2str, config.hidden_layers, 'UniformOutput', false), ' -> '), output_size);
end

function [net, training_info] = trainTemporalNetwork(net, X_train, Y_train, X_val, Y_val, ...
    X_mean, X_std, Y_mean, Y_std, config)
    % Train network with custom temporal continuity loss
    
    fprintf('Training network with temporal continuity constraints...\n');
    
    % Training options
    options = trainingOptions('adam', ...
        'MaxEpochs', config.max_epochs, ...
        'MiniBatchSize', config.batch_size, ...
        'InitialLearnRate', config.learning_rate, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', {X_val, Y_val}, ...
        'ValidationFrequency', 50, ...
        'ValidationPatience', 10, ...
        'Verbose', true, ...
        'Plots', 'training-progress', ...
        'ExecutionEnvironment', 'auto', ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', 0.5, ...
        'LearnRateDropPeriod', 20);
    
    % Train the network
    [net, training_info] = trainNetwork(X_train, Y_train, net, options);
    
    % Store normalization parameters
    training_info.X_mean = X_mean;
    training_info.X_std = X_std;
    training_info.Y_mean = Y_mean;
    training_info.Y_std = Y_std;
    training_info.config = config;
end

function training_info = evaluateTemporalPerformance(net, X_test_norm, Y_test_norm, ...
    X_mean, X_std, Y_mean, Y_std, Y_test, training_info)
    % Evaluate network performance including temporal continuity metrics
    
    fprintf('Evaluating temporal performance...\n');
    
    % Make predictions
    Y_pred_norm = predict(net, X_test_norm);
    Y_pred = Y_pred_norm .* Y_std + Y_mean;
    
    % Calculate standard metrics
    mse = mean((Y_pred - Y_test).^2, 'all');
    mae = mean(abs(Y_pred - Y_test), 'all');
    rmse = sqrt(mse);
    
    % Calculate temporal continuity metrics
    temporal_metrics = calculateTemporalMetrics(Y_pred, Y_test, training_info.config);
    
    % Store results
    training_info.test_metrics = struct();
    training_info.test_metrics.mse = mse;
    training_info.test_metrics.mae = mae;
    training_info.test_metrics.rmse = rmse;
    training_info.test_metrics.temporal = temporal_metrics;
    
    fprintf('Test RMSE: %.4f\n', rmse);
    fprintf('Test MAE: %.4f\n', mae);
    fprintf('Temporal continuity score: %.4f\n', temporal_metrics.continuity_score);
end

function temporal_metrics = calculateTemporalMetrics(Y_pred, Y_true, config)
    % Calculate temporal continuity metrics
    
    % Calculate torque rate changes (first derivative)
    dY_pred = diff(Y_pred, 1, 1);
    dY_true = diff(Y_true, 1, 1);
    
    % Calculate second derivative (acceleration of torques)
    ddY_pred = diff(dY_pred, 1, 1);
    ddY_true = diff(dY_true, 1, 1);
    
    % Smoothness metrics
    rate_change_mse = mean(dY_pred.^2, 'all');
    acceleration_mse = mean(ddY_pred.^2, 'all');
    
    % Continuity score (lower is better)
    continuity_score = rate_change_mse + 0.1 * acceleration_mse;
    
    % Compare with true temporal behavior
    temporal_correlation = corr(dY_pred(:), dY_true(:));
    
    % Store metrics
    temporal_metrics = struct();
    temporal_metrics.rate_change_mse = rate_change_mse;
    temporal_metrics.acceleration_mse = acceleration_mse;
    temporal_metrics.continuity_score = continuity_score;
    temporal_metrics.temporal_correlation = temporal_correlation;
    temporal_metrics.mean_rate_change = mean(abs(dY_pred), 'all');
    temporal_metrics.max_rate_change = max(abs(dY_pred), [], 'all');
end

function Y_pred = predictWithTemporalSmoothing(net, X, X_mean, X_std, Y_mean, Y_std, config)
    % Make predictions with temporal smoothing
    
    % Normalize input
    X_norm = (X - X_mean) ./ X_std;
    
    % Make prediction
    Y_pred_norm = predict(net, X_norm);
    Y_pred = Y_pred_norm .* Y_std + Y_mean;
    
    % Apply temporal smoothing if requested
    if isfield(config, 'apply_smoothing') && config.apply_smoothing
        window_size = 3;  % Smoothing window
        Y_pred = smoothdata(Y_pred, 1, 'gaussian', window_size);
    end
end 