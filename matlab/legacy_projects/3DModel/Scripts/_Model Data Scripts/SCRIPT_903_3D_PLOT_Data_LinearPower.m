figure(903);
hold on;

plot(Data.Time,Data.LSonArmLinearPower);
plot(Data.Time,Data.RSonArmLinearPower);
plot(Data.Time,Data.LEonForearmLinearPower);
plot(Data.Time,Data.REonForearmLinearPower);
plot(Data.Time,Data.LHonClubLinearPower);
plot(Data.Time,Data.RHonClubLinearPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Linear Power','RS Linear Power','LE Linear Power','RE Linear Power','LH Linear Power','RH Linear Power');
legend('Location','southeast');

%Add a Title
title('Linear Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Linear Power');
pause(PauseTime);

%Close Figure
close(903);
