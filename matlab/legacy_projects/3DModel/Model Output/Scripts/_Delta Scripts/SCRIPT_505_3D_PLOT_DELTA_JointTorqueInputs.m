figure(505);
hold on;

plot(DELTAQ.Time,DELTAQ.HipTorqueXInput);
plot(DELTAQ.Time,DELTAQ.HipTorqueYInput);
plot(DELTAQ.Time,DELTAQ.HipTorqueZInput);
plot(DELTAQ.Time,DELTAQ.TranslationForceXInput);
plot(DELTAQ.Time,DELTAQ.TranslationForceYInput);
plot(DELTAQ.Time,DELTAQ.TranslationForceZInput);
plot(DELTAQ.Time,DELTAQ.TorsoTorqueInput);
plot(DELTAQ.Time,DELTAQ.SpineTorqueXInput);
plot(DELTAQ.Time,DELTAQ.SpineTorqueYInput);
plot(DELTAQ.Time,DELTAQ.LScapTorqueXInput);
plot(DELTAQ.Time,DELTAQ.LScapTorqueYInput);
plot(DELTAQ.Time,DELTAQ.RScapTorqueXInput);
plot(DELTAQ.Time,DELTAQ.RScapTorqueYInput);
plot(DELTAQ.Time,DELTAQ.LSTorqueXInput);
plot(DELTAQ.Time,DELTAQ.LSTorqueYInput);
plot(DELTAQ.Time,DELTAQ.LSTorqueZInput);
plot(DELTAQ.Time,DELTAQ.RSTorqueXInput);
plot(DELTAQ.Time,DELTAQ.RSTorqueYInput);
plot(DELTAQ.Time,DELTAQ.RSTorqueZInput);
plot(DELTAQ.Time,DELTAQ.LETorqueInput);
plot(DELTAQ.Time,DELTAQ.RETorqueInput);
plot(DELTAQ.Time,DELTAQ.LFTorqueInput);
plot(DELTAQ.Time,DELTAQ.RFTorqueInput);
plot(DELTAQ.Time,DELTAQ.LWTorqueXInput);
plot(DELTAQ.Time,DELTAQ.LWTorqueYInput);
plot(DELTAQ.Time,DELTAQ.RWTorqueXInput);
plot(DELTAQ.Time,DELTAQ.RWTorqueYInput);

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
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(505);