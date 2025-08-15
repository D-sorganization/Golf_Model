figure(150);
hold on;

plot(BASEQ.Time,BASEQ.HipConstraintTorqueX);
plot(BASEQ.Time,BASEQ.HipConstraintTorqueY);
plot(BASEQ.Time,BASEQ.HipConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.TorsoConstraintTorqueX);
plot(BASEQ.Time,BASEQ.TorsoConstraintTorqueY);
plot(BASEQ.Time,BASEQ.TorsoConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.SpineConstraintTorqueX);
plot(BASEQ.Time,BASEQ.SpineConstraintTorqueY);
plot(BASEQ.Time,BASEQ.SpineConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.LScapConstraintTorqueX);
plot(BASEQ.Time,BASEQ.LScapConstraintTorqueY);
plot(BASEQ.Time,BASEQ.LScapConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.RScapConstraintTorqueX);
plot(BASEQ.Time,BASEQ.RScapConstraintTorqueY);
plot(BASEQ.Time,BASEQ.RScapConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.LSConstraintTorqueX);
plot(BASEQ.Time,BASEQ.LSConstraintTorqueY);
plot(BASEQ.Time,BASEQ.LSConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.RSConstraintTorqueX);
plot(BASEQ.Time,BASEQ.RSConstraintTorqueY);
plot(BASEQ.Time,BASEQ.RSConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.LEConstraintTorqueX);
plot(BASEQ.Time,BASEQ.LEConstraintTorqueY);
plot(BASEQ.Time,BASEQ.LEConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.REConstraintTorqueX);
plot(BASEQ.Time,BASEQ.REConstraintTorqueY);
plot(BASEQ.Time,BASEQ.REConstraintTorqueZ);


plot(BASEQ.Time,BASEQ.LFConstraintTorqueX);
plot(BASEQ.Time,BASEQ.LFConstraintTorqueY);
plot(BASEQ.Time,BASEQ.LFConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.RFConstraintTorqueX);
plot(BASEQ.Time,BASEQ.RFConstraintTorqueY);
plot(BASEQ.Time,BASEQ.RFConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.LWConstraintTorqueX);
plot(BASEQ.Time,BASEQ.LWConstraintTorqueY);
plot(BASEQ.Time,BASEQ.LWConstraintTorqueZ);

plot(BASEQ.Time,BASEQ.RWConstraintTorqueX);
plot(BASEQ.Time,BASEQ.RWConstraintTorqueY);
plot(BASEQ.Time,BASEQ.RWConstraintTorqueZ);


ylabel('Torque (Nm)');
grid 'on';

%Add Legend to Plot
legend('Hip Constraint Torque X','Hip Constraint Torque Y','Hip Constraint Torque Z',...
    'Torso Constraint Torque X','Torso Constraint Torque Y','Torso Constraint Torque Z',...
    'Spine Constraint Torque X','Spine Constraint Torque Y','Spine Constraint Torque Z',...
    'LScap Constraint Torque X','LScap Constraint Torque Y','LScap Constraint Torque Z',...
    'RScap Constraint Torque X','RScap Constraint Torque Y','RScap Constraint Torque Z',...
    'LS Constraint Torque X','LS Constraint Torque Y','LS Constraint Torque Z',...
    'RS Constraint Torque X','RS Constraint Torque Y','RS Constraint Torque Z',...
    'LE Constraint Torque X','LE Constraint Torque Y','LE Constraint Torque Z',...
    'RE Constraint Torque X','RE Constraint Torque Y','RE Constraint Torque Z',...
    'LF Constraint Torque X','LF Constraint Torque Y','LF Constraint Torque Z',...
    'RF Constraint Torque X','RF Constraint Torque Y','RF Constraint Torque Z',...
    'LW Constraint Torque X','LW Constraint Torque Y','LW Constraint Torque Z',...
    'RW Constraint Torque X','RW Constraint Torque Y','RW Constraint Torque Z');

legend('Location','southeast');

%Add a Title
title('Joint Torque Inputs');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(150);
