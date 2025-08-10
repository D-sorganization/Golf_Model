figure(950);
hold on;

plot(Data.Time,Data.HipConstraintTorqueX);
plot(Data.Time,Data.HipConstraintTorqueY);
plot(Data.Time,Data.HipConstraintTorqueZ);

plot(Data.Time,Data.TorsoConstraintTorqueX);
plot(Data.Time,Data.TorsoConstraintTorqueY);
plot(Data.Time,Data.TorsoConstraintTorqueZ);

plot(Data.Time,Data.SpineConstraintTorqueX);
plot(Data.Time,Data.SpineConstraintTorqueY);
plot(Data.Time,Data.SpineConstraintTorqueZ);

plot(Data.Time,Data.LScapConstraintTorqueX);
plot(Data.Time,Data.LScapConstraintTorqueY);
plot(Data.Time,Data.LScapConstraintTorqueZ);

plot(Data.Time,Data.RScapConstraintTorqueX);
plot(Data.Time,Data.RScapConstraintTorqueY);
plot(Data.Time,Data.RScapConstraintTorqueZ);

plot(Data.Time,Data.LSConstraintTorqueX);
plot(Data.Time,Data.LSConstraintTorqueY);
plot(Data.Time,Data.LSConstraintTorqueZ);

plot(Data.Time,Data.RSConstraintTorqueX);
plot(Data.Time,Data.RSConstraintTorqueY);
plot(Data.Time,Data.RSConstraintTorqueZ);

plot(Data.Time,Data.LEConstraintTorqueX);
plot(Data.Time,Data.LEConstraintTorqueY);
plot(Data.Time,Data.LEConstraintTorqueZ);

plot(Data.Time,Data.REConstraintTorqueX);
plot(Data.Time,Data.REConstraintTorqueY);
plot(Data.Time,Data.REConstraintTorqueZ);


plot(Data.Time,Data.LFConstraintTorqueX);
plot(Data.Time,Data.LFConstraintTorqueY);
plot(Data.Time,Data.LFConstraintTorqueZ);

plot(Data.Time,Data.RFConstraintTorqueX);
plot(Data.Time,Data.RFConstraintTorqueY);
plot(Data.Time,Data.RFConstraintTorqueZ);

plot(Data.Time,Data.LWConstraintTorqueX);
plot(Data.Time,Data.LWConstraintTorqueY);
plot(Data.Time,Data.LWConstraintTorqueZ);

plot(Data.Time,Data.RWConstraintTorqueX);
plot(Data.Time,Data.RWConstraintTorqueY);
plot(Data.Time,Data.RWConstraintTorqueZ);


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
subtitle('Data');

%Save Figure
cd(matlabdrive);
savefig('3DModel/Scripts/_Model Data Scripts/Data Charts/Data_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(950);
