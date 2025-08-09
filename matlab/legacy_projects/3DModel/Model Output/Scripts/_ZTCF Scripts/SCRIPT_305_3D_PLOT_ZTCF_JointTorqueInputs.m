figure(305);
hold on;

plot(ZTCFQ.Time,ZTCFQ.HipTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.HipTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.HipTorqueZInput);
plot(ZTCFQ.Time,ZTCFQ.TranslationForceXInput);
plot(ZTCFQ.Time,ZTCFQ.TranslationForceYInput);
plot(ZTCFQ.Time,ZTCFQ.TranslationForceZInput);
plot(ZTCFQ.Time,ZTCFQ.TorsoTorqueInput);
plot(ZTCFQ.Time,ZTCFQ.SpineTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.SpineTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.LScapTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.LScapTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.RScapTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.RScapTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.LSTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.LSTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.LSTorqueZInput);
plot(ZTCFQ.Time,ZTCFQ.RSTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.RSTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.RSTorqueZInput);
plot(ZTCFQ.Time,ZTCFQ.LETorqueInput);
plot(ZTCFQ.Time,ZTCFQ.RETorqueInput);
plot(ZTCFQ.Time,ZTCFQ.LFTorqueInput);
plot(ZTCFQ.Time,ZTCFQ.RFTorqueInput);
plot(ZTCFQ.Time,ZTCFQ.LWTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.LWTorqueYInput);
plot(ZTCFQ.Time,ZTCFQ.RWTorqueXInput);
plot(ZTCFQ.Time,ZTCFQ.RWTorqueYInput);

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
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(305);