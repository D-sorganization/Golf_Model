% runTorqueOptimization.m
% Main script to optimize torque coefficients with regularization and loss breakdown plot

clear; clc;

% --- USER SETTINGS ---
nJoints = 28;
polyOrder = 7;  % 6th-degree => 7 coefficients
nCoeffs = nJoints * polyOrder;

swarmSize = 16;
maxIters  = 40;
coeffBounds = 50;
lambda = 0.001;  % Regularization strength
useWeighted = true;  % Penalize higher-order terms more

% Load MoCap-aligned target kinematics
load('targetKinematics.mat', 'targetKinematics');

% --- PARTICLESWARM SETUP ---
lb = -coeffBounds * ones(1, nCoeffs);
ub =  coeffBounds * ones(1, nCoeffs);

opts = optimoptions('particleswarm', ...
    'SwarmSize', swarmSize, ...
    'MaxIterations', maxIters, ...
    'UseParallel', true, ...
    'Display', 'iter', ...
    'FunctionTolerance', 1e-4, ...
    'OutputFcn', @logLossProgress);

% Log progress
global lossLog; lossLog = [];

% --- LOSS FUNCTION WRAPPER ---
objFcn = @(x) batchTorqueLossRegularized(x, targetKinematics, lambda, useWeighted);

% --- RUN OPTIMIZATION ---
[bestCoeffs, bestLoss] = particleswarm(objFcn, nCoeffs, lb, ub, opts);

% --- SAVE RESULTS ---
timestamp = datestr(now,'yyyy-mm-dd_HHMMSS');
save(['TorqueOptimizationResults_' timestamp '.mat'], ...
     'bestCoeffs', 'bestLoss', 'opts', 'targetKinematics', 'lambda', 'useWeighted', 'lossLog');

fprintf('Optimization complete. Best loss: %.4f\n', bestLoss);

% Plot loss breakdown
if ~isempty(lossLog)
    figure('Name','Loss Breakdown');
    plot(lossLog(:,1), 'r-', 'DisplayName','Pose Loss'); hold on;
    plot(lossLog(:,2), 'b-', 'DisplayName','Reg Loss');
    plot(lossLog(:,3), 'k--', 'DisplayName','Total Loss');
    xlabel('Iteration'); ylabel('Loss'); legend; grid on;
    title('Optimization Loss Components');
end

% Wrapper to pass extra args to loss
function loss = batchTorqueLossRegularized(coeffVec, targetKinematics, lambda, useWeighted)
    global lossLog
    if isvector(coeffVec)
        coeffVec = coeffVec(:)';
    end
    if size(coeffVec,1) == 1
        simIn = generateSimInputs(coeffVec);
        simOut = parsim(simIn, 'ShowProgress', false, 'TransferBaseWorkspaceVariables','on', 'ReuseBlockConfigurations', true);
        simData = extractSimKinematics(simOut(1));
        poseLoss = computeLoss(simData, targetKinematics);
        regLoss = computeRegLoss(coeffVec, useWeighted);
        loss = poseLoss + lambda * regLoss;
        lossLog(end+1,:) = [poseLoss, regLoss, loss];
    else
        loss = zeros(size(coeffVec,1),1);
        for i = 1:size(coeffVec,1)
            loss(i) = batchTorqueLossRegularized(coeffVec(i,:), targetKinematics, lambda, useWeighted);
        end
    end
end

% Dummy output function to satisfy particleswarm structure
function stop = logLossProgress(~, ~, ~)
    stop = false;
end
