% trainGroupedAccelNN.m
% Trains a deep neural net with grouped sub-networks per body segment to predict joint accelerations
% Uses 5 dense layers and dropout for enhanced capacity and generalization

function net = trainGroupedAccelNN(X, Y)
    inputSize = size(X,2);
    outputSize = size(Y,2);

    layers = layerGraph();

    % Shared input layer for all group blocks
    sharedInput = featureInputLayer(inputSize, 'Name','input', 'Normalization','none');
    layers = addLayers(layers, sharedInput);

    % Subnets for each group using full input
    layers = addGroupBlock(layers, 'leftArm',  inputSize);
    layers = addGroupBlock(layers, 'rightArm', inputSize);
    layers = addGroupBlock(layers, 'leftLeg',  inputSize);
    layers = addGroupBlock(layers, 'rightLeg', inputSize);
    layers = addGroupBlock(layers, 'torso',    inputSize);
    layers = addGroupBlock(layers, 'base',     inputSize);

    % Connect shared input to each block
    layers = connectLayers(layers, 'input', 'leftArm_input');
    layers = connectLayers(layers, 'input', 'rightArm_input');
    layers = connectLayers(layers, 'input', 'leftLeg_input');
    layers = connectLayers(layers, 'input', 'rightLeg_input');
    layers = connectLayers(layers, 'input', 'torso_input');
    layers = connectLayers(layers, 'input', 'base_input');

    % Concatenate group outputs
    layers = addLayers(layers, depthConcatenationLayer(6, 'Name','concat'));
    layers = connectLayers(layers, 'leftArm_fc5',  'concat/in1');
    layers = connectLayers(layers, 'rightArm_fc5', 'concat/in2');
    layers = connectLayers(layers, 'leftLeg_fc5',  'concat/in3');
    layers = connectLayers(layers, 'rightLeg_fc5', 'concat/in4');
    layers = connectLayers(layers, 'torso_fc5',    'concat/in5');
    layers = connectLayers(layers, 'base_fc5',     'concat/in6');

    % Final regression layers (deeper variant)
    finalLayers = [
        fullyConnectedLayer(256, 'Name','fc_final1')
        reluLayer('Name','relu_final1')
        dropoutLayer(0.2, 'Name','dropout_final1')
        fullyConnectedLayer(128, 'Name','fc_final2')
        reluLayer('Name','relu_final2')
        fullyConnectedLayer(64, 'Name','fc_final3')
        reluLayer('Name','relu_final3')
        fullyConnectedLayer(32, 'Name','fc_final4')
        reluLayer('Name','relu_final4')
        fullyConnectedLayer(outputSize, 'Name','output')
        regressionLayer('Name','regression')
    ];

    layers = addLayers(layers, finalLayers);
    layers = connectLayers(layers, 'concat', 'fc_final1');

    % Training options
    options = trainingOptions('adam', ...
        'MaxEpochs', 50, ...
        'MiniBatchSize', 128, ...
        'Shuffle', 'every-epoch', ...
        'ExecutionEnvironment', 'gpu', ...
        'Plots', 'training-progress', ...
        'Verbose', true);

    % Train
    net = trainNetwork(X, Y, layers, options);
end

function layers = addGroupBlock(layers, groupName, inputDim)
    block = [
        featureInputLayer(inputDim, 'Name', [groupName '_input'], 'Normalization','none')
        fullyConnectedLayer(128, 'Name', [groupName '_fc1'])
        reluLayer('Name', [groupName '_relu1'])
        dropoutLayer(0.2, 'Name', [groupName '_drop1'])
        fullyConnectedLayer(64, 'Name', [groupName '_fc2'])
        reluLayer('Name', [groupName '_relu2'])
        fullyConnectedLayer(32, 'Name', [groupName '_fc3'])
        reluLayer('Name', [groupName '_relu3'])
        fullyConnectedLayer(32, 'Name', [groupName '_fc4'])
        reluLayer('Name', [groupName '_relu4'])
        fullyConnectedLayer(16, 'Name', [groupName '_fc5'])
    ];
    layers = addLayers(layers, block);
end
