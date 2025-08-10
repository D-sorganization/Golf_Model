% runCompletePipeline.m
% Master script to run the complete golf swing neural network pipeline
% 1. Generate dataset with random polynomial inputs
% 2. Train inverse dynamics neural network
% 3. Demonstrate control with desired kinematics

clear; clc;

fprintf('=== Golf Swing Neural Network Pipeline ===\n\n');

%% Configuration
% Pipeline settings
generateNewDataset = true;    % Set to false to use existing dataset
trainNewModel = true;         % Set to false to use existing model
runControlDemo = true;        % Set to false to skip control demonstration

% Dataset generation parameters
nSimulations = 500;           % Number of simulations (reduce for testing)
coeffBounds = 50;             % Coefficient bounds for random generation

% Training parameters
hiddenLayers = [256, 128, 64]; % Neural network architecture
maxEpochs = 50;               % Training epochs (reduce for testing)
batchSize = 64;               % Batch size

% Control parameters
simDuration = 0.5;            % Control demonstration duration

%% Step 1: Generate Dataset
if generateNewDataset
    fprintf('Step 1: Generating dataset...\n');
    fprintf('Number of simulations: %d\n', nSimulations);

    % Modify generateDataset.m parameters
    % Note: In a real implementation, you'd pass these as parameters
    % For now, we'll create a modified version

    try
        % Run dataset generation
        runDatasetGeneration(nSimulations, coeffBounds);
        fprintf('Dataset generation completed successfully.\n\n');
    catch ME
        fprintf('Error in dataset generation: %s\n', ME.message);
        fprintf('Continuing with existing dataset if available...\n\n');
    end
else
    fprintf('Step 1: Skipping dataset generation (using existing dataset).\n\n');
end

%% Step 2: Train Neural Network
if trainNewModel
    fprintf('Step 2: Training neural network...\n');

    % Check if dataset exists
    datasetPath = 'GeneratedDataset/training_data.mat';
    if ~exist(datasetPath, 'file')
        error('Dataset not found. Please run dataset generation first.');
    end

    try
        % Run neural network training
        runNeuralNetworkTraining(hiddenLayers, maxEpochs, batchSize);
        fprintf('Neural network training completed successfully.\n\n');
    catch ME
        fprintf('Error in neural network training: %s\n', ME.message);
        fprintf('Continuing with existing model if available...\n\n');
    end
else
    fprintf('Step 2: Skipping neural network training (using existing model).\n\n');
end

%% Step 3: Control Demonstration
if runControlDemo
    fprintf('Step 3: Running control demonstration...\n');

    % Check if trained model exists
    modelPath = 'TrainedModels/inverse_dynamics_model.mat';
    if ~exist(modelPath, 'file')
        error('Trained model not found. Please run neural network training first.');
    end

    try
        % Run control demonstration
        runControlDemonstration(simDuration);
        fprintf('Control demonstration completed successfully.\n\n');
    catch ME
        fprintf('Error in control demonstration: %s\n', ME.message);
    end
else
    fprintf('Step 3: Skipping control demonstration.\n\n');
end

%% Summary
fprintf('=== Pipeline Summary ===\n');
fprintf('Dataset generation: %s\n', ifelse(generateNewDataset, 'Completed', 'Skipped'));
fprintf('Neural network training: %s\n', ifelse(trainNewModel, 'Completed', 'Skipped'));
fprintf('Control demonstration: %s\n', ifelse(runControlDemo, 'Completed', 'Skipped'));

% Check for output files
checkOutputFiles();

fprintf('\nPipeline execution complete!\n');

%% Helper Functions

function runDatasetGeneration(nSimulations, coeffBounds)
    % Wrapper function to run dataset generation with custom parameters

    % Create a temporary script with modified parameters
    tempScript = 'temp_generateDataset.m';

    % Read the original script
    originalScript = 'generateDataset.m';
    if exist(originalScript, 'file')
        fid = fopen(originalScript, 'r');
        scriptContent = fread(fid, '*char')';
        fclose(fid);

        % Replace parameters
        scriptContent = strrep(scriptContent, 'nSimulations = 1000;', sprintf('nSimulations = %d;', nSimulations));
        scriptContent = strrep(scriptContent, 'coeffBounds = 50;', sprintf('coeffBounds = %d;', coeffBounds));

        % Write temporary script
        fid = fopen(tempScript, 'w');
        fprintf(fid, '%s', scriptContent);
        fclose(fid);

        % Run the modified script
        run(tempScript);

        % Clean up
        delete(tempScript);
    else
        error('generateDataset.m not found');
    end
end

function runNeuralNetworkTraining(hiddenLayers, maxEpochs, batchSize)
    % Wrapper function to run neural network training with custom parameters

    % Create a temporary script with modified parameters
    tempScript = 'temp_trainInverseDynamicsModel.m';

    % Read the original script
    originalScript = 'trainInverseDynamicsModel.m';
    if exist(originalScript, 'file')
        fid = fopen(originalScript, 'r');
        scriptContent = fread(fid, '*char')';
        fclose(fid);

        % Replace parameters
        scriptContent = strrep(scriptContent, 'hiddenLayers = [512, 256, 128, 64];', ...
                              sprintf('hiddenLayers = [%s];', strjoin(arrayfun(@num2str, hiddenLayers, 'UniformOutput', false), ', ')));
        scriptContent = strrep(scriptContent, 'maxEpochs = 100;', sprintf('maxEpochs = %d;', maxEpochs));
        scriptContent = strrep(scriptContent, 'batchSize = 128;', sprintf('batchSize = %d;', batchSize));

        % Write temporary script
        fid = fopen(tempScript, 'w');
        fprintf(fid, '%s', scriptContent);
        fclose(fid);

        % Run the modified script
        run(tempScript);

        % Clean up
        delete(tempScript);
    else
        error('trainInverseDynamicsModel.m not found');
    end
end

function runControlDemonstration(simDuration)
    % Wrapper function to run control demonstration with custom parameters

    % Create a temporary script with modified parameters
    tempScript = 'temp_controlWithNeuralNetwork.m';

    % Read the original script
    originalScript = 'controlWithNeuralNetwork.m';
    if exist(originalScript, 'file')
        fid = fopen(originalScript, 'r');
        scriptContent = fread(fid, '*char')';
        fclose(fid);

        % Replace parameters
        scriptContent = strrep(scriptContent, 'simDuration = 1.0;', sprintf('simDuration = %.1f;', simDuration));

        % Write temporary script
        fid = fopen(tempScript, 'w');
        fprintf(fid, '%s', scriptContent);
        fclose(fid);

        % Run the modified script
        run(tempScript);

        % Clean up
        delete(tempScript);
    else
        error('controlWithNeuralNetwork.m not found');
    end
end

function result = ifelse(condition, trueValue, falseValue)
    % Simple if-else function for string output
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end

function checkOutputFiles()
    % Check for expected output files and report status

    fprintf('\nOutput file status:\n');

    % Dataset files
    datasetFiles = {
        'GeneratedDataset/training_data.mat',
        'GeneratedDataset/golf_swing_dataset.mat',
        'GeneratedDataset/dataset_metadata.mat'
    };

    for i = 1:length(datasetFiles)
        if exist(datasetFiles{i}, 'file')
            fileInfo = dir(datasetFiles{i});
            fprintf('✓ %s (%.1f MB)\n', datasetFiles{i}, fileInfo.bytes/1e6);
        else
            fprintf('✗ %s (not found)\n', datasetFiles{i});
        end
    end

    % Model files
    modelFiles = {
        'TrainedModels/inverse_dynamics_model.mat',
        'TrainedModels/predictions.mat'
    };

    for i = 1:length(modelFiles)
        if exist(modelFiles{i}, 'file')
            fileInfo = dir(modelFiles{i});
            fprintf('✓ %s (%.1f MB)\n', modelFiles{i}, fileInfo.bytes/1e6);
        else
            fprintf('✗ %s (not found)\n', modelFiles{i});
        end
    end

    % Control results
    if exist('neural_network_control_results.mat', 'file')
        fileInfo = dir('neural_network_control_results.mat');
        fprintf('✓ neural_network_control_results.mat (%.1f MB)\n', fileInfo.bytes/1e6);
    else
        fprintf('✗ neural_network_control_results.mat (not found)\n');
    end
end
