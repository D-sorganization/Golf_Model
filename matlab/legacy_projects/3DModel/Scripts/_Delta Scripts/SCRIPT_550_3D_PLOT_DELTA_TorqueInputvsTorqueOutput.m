figure(550);
hold on;

plot(DELTAQ.Time,DELTAQ.HipConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.HipConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.HipConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.TorsoConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.TorsoConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.TorsoConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.SpineConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.SpineConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.SpineConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.LScapConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.LScapConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.LScapConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.RScapConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.RScapConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.RScapConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.LSConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.LSConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.LSConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.RSConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.RSConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.RSConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.LEConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.LEConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.LEConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.REConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.REConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.REConstraintTorqueZ);


plot(DELTAQ.Time,DELTAQ.LFConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.LFConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.LFConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.RFConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.RFConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.RFConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.LWConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.LWConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.LWConstraintTorqueZ);

plot(DELTAQ.Time,DELTAQ.RWConstraintTorqueX);
plot(DELTAQ.Time,DELTAQ.RWConstraintTorqueY);
plot(DELTAQ.Time,DELTAQ.RWConstraintTorqueZ);


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
subtitle('DELTA');

%Save Figure
savefig('DELTA Charts/DELTA_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(550);