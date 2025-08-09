function exportJacobiansAndTorques(leftTree, rightTree, headNeckTree)
%EXPORTJACOBIANSANDTORQUES Export Jacobians and torque projections to CSV.

qL = zeros(1, leftTree.NumBodies);
qR = zeros(1, rightTree.NumBodies);
qH = zeros(1, headNeckTree.NumBodies);

JL = geometricJacobian(leftTree, qL, 'club');
JR = geometricJacobian(rightTree, qR, 'rightHandOnClub');
JH = geometricJacobian(headNeckTree, qH, 'head');

% Export Jacobians
writematrix(JL, 'jacobian_left.csv');
writematrix(JR, 'jacobian_right.csv');
writematrix(JH, 'jacobian_head.csv');

% External wrench
W = [0; 0; 10; 0; 0; 0]; % 10N Z force

tau_L = JL' * W;
tau_R = JR' * W;
tau_H = JH' * W;

% Combine torques into table
T = table(tau_L, tau_R, tau_H);
writetable(T, 'torques.csv');

disp('Exported jacobians and torques.');
end
