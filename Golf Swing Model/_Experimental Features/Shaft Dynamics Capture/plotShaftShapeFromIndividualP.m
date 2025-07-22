function plotShaftShapeFromIndividualP(startIndex, endIndex)
% Plots shaft shape from SDI signals labeled p(2) to p(endIndex)

    runIDs = Simulink.sdi.getAllRunIDs;
    runObj = Simulink.sdi.getRun(runIDs(end));
    
    numNodes = endIndex - startIndex + 1;
    shaftShape = NaN(numNodes, 3);  % Initialize one time point

    for i = 1:numNodes
        sigName = sprintf('GolfSwing3D_KineticallyDriven.Club.Flexible_Beam_Model.Flexible_Cylindrical_Beam.p(%d)', i + 1);
        sigObj = runObj.getSignalByIndex(findSignalIndex(runObj, sigName));
        [data, ~] = sigObj.getData;
        shaftShape(i, :) = data(end, :);  % Last time point
    end

    % Plot 3D shaft
    figure;
    plot3(shaftShape(:,1), shaftShape(:,2), shaftShape(:,3), '-o', 'LineWidth', 2);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Shaft Shape from p(2) to p(12)');
    grid on; axis equal;
    view(135, 25);
end

function idx = findSignalIndex(runObj, name)
    idx = -1;
    for k = 1:runObj.signalCount
        if strcmp(runObj.getSignalByIndex(k).Name, name)
            idx = k;
            return;
        end
    end
    error('Signal "%s" not found in SDI run.', name);
end
