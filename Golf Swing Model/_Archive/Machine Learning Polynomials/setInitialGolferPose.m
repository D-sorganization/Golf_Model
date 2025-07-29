% batchTorqueLoss.m (with regularization)
% Evaluates trajectory + regularization loss for optimization

function loss = batchTorqueLoss(coeffVec, targetKinematics)
    lambda = 0.001;  % Regularization strength
    useWeighted = true;  % Set true to penalize high-order terms more

    if isvector(coeffVec)
        coeffVec = coeffVec(:)';  % ensure row vector
    end

    if size(coeffVec, 1) == 1
        simIn = generateSimInputs(coeffVec);
        simOut = parsim(simIn, 'ShowProgress', false, ...
                        'TransferBaseWorkspaceVariables', 'on', ...
                        'ReuseBlockConfigurations', true);
        simData = extractSimKinematics(simOut(1));
        poseLoss = computeLoss(simData, targetKinematics);
        regLoss = computeRegLoss(coeffVec, useWeighted);
        loss = poseLoss + lambda * regLoss;
    else
        % Batch mode for swarm
        nSim = size(coeffVec,1);
        simIn = generateSimInputs(coeffVec);
        simOut = parsim(simIn, 'ShowProgress', false, ...
                        'TransferBaseWorkspaceVariables', 'on', ...
                        'ReuseBlockConfigurations', true);
        loss = zeros(nSim, 1);
        for i = 1:nSim
            simData = extractSimKinematics(simOut(i));
            poseLoss = computeLoss(simData, targetKinematics);
            regLoss = computeRegLoss(coeffVec(i,:), useWeighted);
            loss(i) = poseLoss + lambda * regLoss;
        end
        loss = min(loss); % particleswarm expects scalar
    end
end

function regLoss = computeRegLoss(coeffs, useWeighted)
    nCoeffsPerJoint = 7;
    nJoints = numel(coeffs) / nCoeffsPerJoint;

    if useWeighted
        weights = [1 1 2 3 4 5 6];  % weight higher orders more
    else
        weights = ones(1, nCoeffsPerJoint);
    end

    regLoss = 0;
    for j = 1:nJoints
        idx = (j-1)*nCoeffsPerJoint + (1:nCoeffsPerJoint);
        regLoss = regLoss + sum((weights .* coeffs(idx)).^2);
    end
end
