figure(350);
hold on;

plot(ZTCFQ.Time,ZTCFQ.HipConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.HipConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.HipConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.TorsoConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.TorsoConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.TorsoConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.SpineConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.SpineConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.SpineConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.LScapConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.LScapConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.LScapConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.RScapConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.RScapConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.RScapConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.LSConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.LSConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.LSConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.RSConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.RSConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.RSConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.LEConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.LEConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.LEConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.REConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.REConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.REConstraintTorqueZ);


plot(ZTCFQ.Time,ZTCFQ.LFConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.LFConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.LFConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.RFConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.RFConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.RFConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.LWConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.LWConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.LWConstraintTorqueZ);

plot(ZTCFQ.Time,ZTCFQ.RWConstraintTorqueX);
plot(ZTCFQ.Time,ZTCFQ.RWConstraintTorqueY);
plot(ZTCFQ.Time,ZTCFQ.RWConstraintTorqueZ);


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
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(350);