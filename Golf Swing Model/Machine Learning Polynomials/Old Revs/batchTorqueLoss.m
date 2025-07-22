function loss = batchTorqueLoss(coeffVec, targetKinematics)
% batchTorqueLoss - Objective function for particleswarm optimizer.
%   Accepts a [1×n] vector (or [m×n] matrix for batch swarm),
%   runs parsim, compares with target kinematics, and returns scalar loss.

    if isvector(coeffVec)
        coeffVec = coeffVec(:)';  % ensure row vector
    end

    if size(coeffVec, 1) == 1
        simIn = generateSimInputs(coeffVec);
        simOut = parsim(simIn, 'ShowProgress', false, ...
                        'TransferBaseWorkspaceVariables', 'on', ...
                        'ReuseBlockConfigurations', true);
        simData = extractSimKinematics(simOut(1));
        loss = computeLoss(simData, targetKinematics);
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
            loss(i) = computeLoss(simData, targetKinematics);
        end
        loss = min(loss); % particleswarm expects a scalar return
    end
end
