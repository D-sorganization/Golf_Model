function animateGolfSwingMotion(leftTree, rightTree, headNeckTree, qL_traj, qR_traj, qH_traj, timeVec, eeNames, recordGIF)
%ANIMATEGOLFSWINGMOTION Animates full-body motion with custom joint trajectories.
% Inputs:
% - qL_traj, qR_traj, qH_traj: NxM joint angle arrays
% - timeVec: 1xN time vector
% - eeNames: struct with fields 'left', 'right', 'head'
% - recordGIF: logical flag
if nargin < 9, recordGIF = false; end
filename = 'golf_swing_motion.gif';

figure('Color','w'); axis equal; view(3); grid on;
title('Full Motion Animation'); hold on;
club_trace = [];

for i = 1:length(timeVec)
    qL = qL_traj(i,:);
    qR = qR_traj(i,:);
    qH = qH_traj(i,:);

    cla;
    show(leftTree, 'Frames','off', 'PreservePlot', false, 'Parent', gca, 'Configuration', qL);
    show(rightTree, 'Frames','off', 'PreservePlot', false, 'Parent', gca, 'Configuration', qR);
    show(headNeckTree, 'Frames','off', 'PreservePlot', false, 'Parent', gca, 'Configuration', qH);

    T = getTransform(leftTree, qL, eeNames.left);
    p = tform2trvec(T);
    club_trace = [club_trace; p];
    plot3(club_trace(:,1), club_trace(:,2), club_trace(:,3), 'b.-', 'LineWidth', 2);

    drawnow;
    if recordGIF
        frame = getframe(gcf);
        im = frame2im(frame);
        [A,map] = rgb2ind(im,256);
        if i == 1
            imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.05);
        else
            imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.05);
        end
    end
end
end
