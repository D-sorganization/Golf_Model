figure(902);
hold on;

plot(Data.Time,Data.LSonArmAngularPower);
plot(Data.Time,Data.RSonArmAngularPower);
plot(Data.Time,Data.LEonForearmAngularPower);
plot(Data.Time,Data.REonForearmAngularPower);
plot(Data.Time,Data.LHonClubAngularPower);
plot(Data.Time,Data.RHonClubAngularPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Power','RS Angular Power','LE Angular Power','RE Angular Power','LH Angular Power','RH Angular Power');
legend('Location','southeast');

%Add a Title
title('Angular Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Angular Power');
pause(PauseTime);

%Close Figure
close(902);
