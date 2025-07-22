function plotAndAnalyzeGolfTrees(leftTree, rightTree, headNeckTree)
%PLOTANDANALYZEGOLFTREES Visualizes trees, computes Jacobians, manipulability, and joint torques.

figure; hold on; view(3); axis equal; grid on;
title('Golf Swing Model Rigid Body Trees');

show(leftTree, 'Frames','off','PreservePlot',false);
show(rightTree, 'Frames','off','PreservePlot',false, 'Parent', gca);
show(headNeckTree, 'Frames','off','PreservePlot',false, 'Parent', gca);
set(gca,'ZDir','up')

qL = zeros(1, leftTree.NumBodies);
qR = zeros(1, rightTree.NumBodies);
qH = zeros(1, headNeckTree.NumBodies);

JL = geometricJacobian(leftTree, qL, 'club');
JR = geometricJacobian(rightTree, qR, 'rightHandOnClub');
JH = geometricJacobian(headNeckTree, qH, 'head');

mL = sqrt(det(JL*JL'));
mR = sqrt(det(JR*JR'));
mH = sqrt(det(JH*JH'));

disp('--- Manipulability ---');
disp(['Left chain: ', num2str(mL)]);
disp(['Right chain: ', num2str(mR)]);
disp(['Head chain: ', num2str(mH)]);

W = [0;0;10; 0;0;0]; % 10 N Z force
tau_L = JL' * W;
tau_R = JR' * W;
tau_H = JH' * W;

disp('--- Required Torques for 10N Z-force ---');
disp('Left chain torques:'); disp(tau_L');
disp('Right chain torques:'); disp(tau_R');
disp('Head chain torques:'); disp(tau_H');

% Draw ellipsoids at each end-effector
% --- Club ---
Tclub = getTransform(leftTree, qL, 'club');
pclub = tform2trvec(Tclub);
plotEllipsoid(pclub, JL(1:3,1:3)*JL(1:3,1:3)', 'g'); % mobility
plotEllipsoid(pclub, inv(JL(1:3,1:3)'*JL(1:3,1:3)), 'r'); % force

% --- Right Hand ---
Trh = getTransform(rightTree, qR, 'rightHandOnClub');
prh = tform2trvec(Trh);
plotEllipsoid(prh, JR(1:3,1:3)*JR(1:3,1:3)', 'g');
plotEllipsoid(prh, inv(JR(1:3,1:3)'*JR(1:3,1:3)), 'r');

% --- Head ---
Thead = getTransform(headNeckTree, qH, 'head');
phead = tform2trvec(Thead);
plotEllipsoid(phead, JH(1:3,1:3)*JH(1:3,1:3)', 'g');
plotEllipsoid(phead, inv(JH(1:3,1:3)'*JH(1:3,1:3)), 'r');

% Path Trace
disp('--- Path Trace ---');
pts = [];
for i = 1:20
    qL(3) = pi/40 * i;
    T = getTransform(leftTree, qL, 'club');
    pts(end+1,:) = tform2trvec(T);
end
plot3(pts(:,1), pts(:,2), pts(:,3), 'b.-');
legend({'leftTree','rightTree','headNeckTree','Club Path'})

end
