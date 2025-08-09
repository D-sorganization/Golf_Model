function [shaftShape, shaftTimes] = extractShaftShapeFromSDI(signalName)
% Extracts a shaft shape (Nx3) matrix over time from SDI based on a logged signal name
%
% Inputs:
%   signalName - full signal name as shown in SDI (string or char)
%
% Outputs:
%   shaftShape - 3D matrix [numTimes x numNodes x 3]
%   shaftTimes - time vector [numTimes x 1]

    % Get most recent run from SDI
    runIDs = Simulink.sdi.getAllRunIDs;
    if isempty(runIDs)
        error('No SDI runs found.');
    end
    runObj = Simulink.sdi.getRun(runIDs(end));

    % Search for matching signal
    sigIdx = [];
    for i = 1:runObj.signalCount
        sig = runObj.getSignalByIndex(i);
        if strcmp(sig.Name, signalName)
            sigIdx = i;
            break;
        end
    end

    if isempty(sigIdx)
        error('Signal "%s" not found in SDI run.', signalName);
    end

    % Get signal data
    pSig = runObj.getSignalByIndex(sigIdx);
    [data, time] = pSig.getData;

    % Assume data is [numTimes x 36] for 12 nodes * 3 components
    numTimes = size(data, 1);
    if mod(size(data, 2), 3) ~= 0
        error('Expected multiple of 3 columns in signal data.');
    end
    numNodes = size(data, 2) / 3;

    % Reshape to [numTimes x numNodes x 3]
    shaftShape = zeros(numTimes, numNodes, 3);
    for dim = 1:3
        shaftShape(:, :, dim) = data(:, dim:3:end);
    end

    shaftTimes = time;
end
