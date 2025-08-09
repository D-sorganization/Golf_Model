figure(905);
hold on;

plot(Data.Time,Data.HipTorqueXInput);
plot(Data.Time,Data.HipTorqueYInput);
plot(Data.Time,Data.HipTorqueZInput);
plot(Data.Time,Data.TranslationForceXInput);
plot(Data.Time,Data.TranslationForceYInput);
plot(Data.Time,Data.TranslationForceZInput);
plot(Data.Time,Data.TorsoTorqueInput);
plot(Data.Time,Data.SpineTorqueXInput);
plot(Data.Time,Data.SpineTorqueYInput);
plot(Data.Time,Data.LScapTorqueXInput);
plot(Data.Time,Data.LScapTorqueYInput);
plot(Data.Time,Data.RScapTorqueXInput);
plot(Data.Time,Data.RScapTorqueYInput);
plot(Data.Time,Data.LSTorqueXInput);
plot(Data.Time,Data.LSTorqueYInput);
plot(Data.Time,Data.LSTorqueZInput);
plot(Data.Time,Data.RSTorqueXInput);
plot(Data.Time,Data.RSTorqueYInput);
plot(Data.Time,Data.RSTorqueZInput);
plot(Data.Time,Data.LETorqueInput);
plot(Data.Time,Data.RETorqueInput);
plot(Data.Time,Data.LFTorqueInput);
plot(Data.Time,Data.RFTorqueInput);
plot(Data.Time,Data.LWTorqueXInput);
plot(Data.Time,Data.LWTorqueYInput);
plot(Data.Time,Data.RWTorqueXInput);
plot(Data.Time,Data.RWTorqueYInput);

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
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Joint Torque Inputs');
pause(PauseTime);

%Close Figure
close(905);