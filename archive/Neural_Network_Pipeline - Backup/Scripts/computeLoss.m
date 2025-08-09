function loss = computeLoss(simData, target)
% Computes combined position + rotation loss

    posSim = simData.MH;
    posTgt = target.MH;

    T = min(height(posSim), height(posTgt));
    posErr = posSim{1:T,:} - posTgt{1:T,:};
    posLoss = mean(sum(posErr.^2, 2));  % MSE over x,y,z

    % Rotation error (Frobenius norm or geodesic distance)
    rotLoss = 0;
    for t = 1:T
        R_sim = simData.MH_R(:,:,t);
        R_tgt = target.MH_R(:,:,t);
        R_err = R_sim' * R_tgt;
        theta = acos((trace(R_err) - 1) / 2);  % angle between matrices
        rotLoss = rotLoss + theta^2;
    end
    rotLoss = rotLoss / T;

    % Weighted combination
    loss = posLoss + 5 * rotLoss;
end
