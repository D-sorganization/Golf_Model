function animateGolfSwingModel(leftTree, rightTree, headNeckTree, recordGIF)
%ANIMATEGOLFSWINGMODEL Animates model and optionally saves to golf_swing.gif.
if nargin < 4, recordGIF = false; end
figure('Color','w'); axis equal; view(3); grid on;
title('Golf Swing Animation');
hold on;
club_trace = [];

filename = 'golf_swing.gif';

for i = 1:20
    qL = zeros(1, leftTree.NumBodies);
    qR = zeros(1, rightTree.NumBodies);
    qH = zeros(1, headNeckTree.NumBodies);
    qL(3) = pi/40 * i;
    qR(1) = pi/40 * i;
    qH(1) = pi/40 * i;

    cla;
    show(leftTree, 'Frames','off', 'PreservePlot', false, 'Parent', gca, 'Configuration', qL);
    show(rightTree, 'Frames','off', 'PreservePlot', false, 'Parent', gca, 'Configuration', qR);
    show(headNeckTree, 'Frames','off', 'PreservePlot', false, 'Parent', gca, 'Configuration', qH);

    Tclub = getTransform(leftTree, qL, 'club');
    p = tform2trvec(Tclub);
    club_trace = [club_trace; p];
    plot3(club_trace(:,1), club_trace(:,2), club_trace(:,3), 'b.-', 'LineWidth', 2);

    drawnow;
    if recordGIF
        frame = getframe(gcf);
        im = frame2im(frame);
        [A,map] = rgb2ind(im,256);
        if i == 1
            imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
        else
            imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
        end
    end
end
end
