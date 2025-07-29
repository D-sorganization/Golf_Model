% compareMidhandsViewer.m
% Visualizes midhands trajectory and orientation match between simulation and target

function compareMidhandsViewer(simData, targetKinematics)
    if istable(simData.MH), simPos = simData.MH{:,:}; else, simPos = simData.MH; end
    if istable(targetKinematics.MH), tgtPos = targetKinematics.MH{:,:}; else, tgtPos = targetKinematics.MH; end
    T = min(size(simPos,1), size(tgtPos,1));

    simRot = simData.MH_R(:,:,1:T);
    tgtRot = targetKinematics.MH_R(:,:,1:T);

    figure('Name','Midhands Pose Comparison','Color','w');
    ax = axes('XGrid','on','YGrid','on','ZGrid','on');
    view(3); axis equal; hold on;

    % Plot full traces
    plot3(simPos(1:T,1), simPos(1:T,2), simPos(1:T,3), 'b--', 'DisplayName','Sim Trace');
    plot3(tgtPos(1:T,1), tgtPos(1:T,2), tgtPos(1:T,3), 'r--', 'DisplayName','Target Trace');

    % Create point markers and quivers
    simPt = plot3(0,0,0,'bo','MarkerFaceColor','b','DisplayName','Sim Pos');
    tgtPt = plot3(0,0,0,'ro','MarkerFaceColor','r','DisplayName','Target Pos');

    qLength = norm(max(tgtPos) - min(tgtPos)) * 0.05;
    simQ = gobjects(3,1); tgtQ = gobjects(3,1);
    for i = 1:3
        simQ(i) = quiver3(0,0,0,0,0,0,'b','LineWidth',1.5);
        tgtQ(i) = quiver3(0,0,0,0,0,0,'r','LineWidth',1.5);
    end

    legend;

    % Slider for time
    uicontrol('Style','slider','Min',1,'Max',T,'Value',1, 'SliderStep',[1/(T-1), 0.1],...
              'Units','normalized','Position',[0.1 0.02 0.8 0.04],...
              'Callback',@(s,~) updateFrame(round(get(s,'Value'))));

    function updateFrame(k)
        % Update points
        set(simPt, 'XData', simPos(k,1), 'YData', simPos(k,2), 'ZData', simPos(k,3));
        set(tgtPt, 'XData', tgtPos(k,1), 'YData', tgtPos(k,2), 'ZData', tgtPos(k,3));

        % Update quivers for rotation axes
        for i = 1:3
            % Sim rotation
            v = simRot(:,i,k) * qLength;
            set(simQ(i), 'XData', simPos(k,1), 'YData', simPos(k,2), 'ZData', simPos(k,3), ...
                        'UData', v(1), 'VData', v(2), 'WData', v(3));
            % Target rotation
            v = tgtRot(:,i,k) * qLength;
            set(tgtQ(i), 'XData', tgtPos(k,1), 'YData', tgtPos(k,2), 'ZData', tgtPos(k,3), ...
                        'UData', v(1), 'VData', v(2), 'WData', v(3));
        end
        title(sprintf('Frame %d / %d', k, T));
    end

    updateFrame(1);
end
