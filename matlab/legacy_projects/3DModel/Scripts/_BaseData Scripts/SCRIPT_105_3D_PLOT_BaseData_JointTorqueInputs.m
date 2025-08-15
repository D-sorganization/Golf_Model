figure(105);
hold on;

plot(BASEQ.Time,BASEQ.HipTorqueXInput);
plot(BASEQ.Time,BASEQ.HipTorqueYInput);
plot(BASEQ.Time,BASEQ.HipTorqueZInput);
plot(BASEQ.Time,BASEQ.TranslationForceXInput);
plot(BASEQ.Time,BASEQ.TranslationForceYInput);
plot(BASEQ.Time,BASEQ.TranslationForceZInput);
plot(BASEQ.Time,BASEQ.TorsoTorqueInput);
plot(BASEQ.Time,BASEQ.SpineTorqueXInput);
plot(BASEQ.Time,BASEQ.SpineTorqueYInput);
plot(BASEQ.Time,BASEQ.LScapTorqueXInput);
plot(BASEQ.Time,BASEQ.LScapTorqueYInput);
plot(BASEQ.Time,BASEQ.RScapTorqueXInput);
plot(BASEQ.Time,BASEQ.RScapTorqueYInput);
plot(BASEQ.Time,BASEQ.LSTorqueXInput);
plot(BASEQ.Time,BASEQ.LSTorqueYInput);
plot(BASEQ.Time,BASEQ.LSTorqueZInput);
plot(BASEQ.Time,BASEQ.RSTorqueXInput);
plot(BASEQ.Time,BASEQ.RSTorqueYInput);
plot(BASEQ.Time,BASEQ.RSTorqueZInput);
plot(BASEQ.Time,BASEQ.LETorqueInput);
plot(BASEQ.Time,BASEQ.RETorqueInput);
plot(BASEQ.Time,BASEQ.LFTorqueInput);
plot(BASEQ.Time,BASEQ.RFTorqueInput);
plot(BASEQ.Time,BASEQ.LWTorqueXInput);
plot(BASEQ.Time,BASEQ.LWTorqueYInput);
plot(BASEQ.Time,BASEQ.RWTorqueXInput);
plot(BASEQ.Time,BASEQ.RWTorqueYInput);

ylabel('Torque (Nm)');
grid 'on';

%Add Legend to Plot
legend('Hip Torque X','Hip Torque Y','Hip Torque Z','Translation Force X',...
    'Translation Force Y','Translation Force Z','Torso Torque','Spine Torque X',...
    'Spine Torque Y','LScap Torque X','Left Scap Torque Y','RScap Torque X',...
    'RScapTorqueY','LS Torque X','LS Torque Y','LS Torque Z','RS Torque X','RS Torque Y',...
    'RS Torque Z','LE Torque','RE Torque','LF Torque','RF Torque','LW Torque X',...
    'LW Torque Y','RW Torque X','RW Torque Y');
legend('Location','southeast');
%Add a Title
title('Joint Torque Inputs');
%subtitle('Left Hand, Right Hand, Total');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(105);
