function animateGolfSwingFromMAT(leftTree, rightTree, headNeckTree, matFile, recordGIF)
%ANIMATEGOLFSWINGFROMMAT Animates motion using joint data from a .mat file.
if nargin < 5, recordGIF = false; end
data = load(matFile);

qL_traj = data.qL_traj;
qR_traj = data.qR_traj;
qH_traj = data.qH_traj;
timeVec = data.timeVec;

if isfield(data,'eeNames')
    eeNames = data.eeNames;
else
    eeNames.left = 'club'; eeNames.right = 'rightHandOnClub'; eeNames.head = 'head';
end

filename = 'golf_swing_from_mat.gif';
figure('Color','w'); axis equal; view(3); grid on; title('MAT-driven Motion'); hold on;
club_trace = [];

for i = 1:length(timeVec)
    qL = qL_traj(i,:); qR = qR_traj(i,:); qH = qH_traj(i,:);
    cla;
    show(leftTree, 'Frames','off','PreservePlot',false,'Parent',gca,'Configuration',qL);
    show(rightTree,'Frames','off','PreservePlot',false,'Parent',gca,'Configuration',qR);
    show(headNeckTree,'Frames','off','PreservePlot',false,'Parent',gca,'Configuration',qH);

    T = getTransform(leftTree, qL, eeNames.left);
    p = tform2trvec(T);
    club_trace = [club_trace; p];
    plot3(club_trace(:,1), club_trace(:,2), club_trace(:,3), 'b.-', 'LineWidth', 2);
    drawnow;

    if recordGIF
        frame = getframe(gcf); im = frame2im(frame); [A,map] = rgb2ind(im,256);
        if i==1
            imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.05);
        else
            imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.05);
        end
    end
end
end
