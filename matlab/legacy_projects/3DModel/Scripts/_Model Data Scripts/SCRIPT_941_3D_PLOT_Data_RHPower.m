figure(941);
hold on;

plot(Data.Time,Data.RHonClubLinearPower);
plot(Data.Time,Data.RHonClubAngularPower);
plot(Data.Time,Data.TotalRHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Power','RH Angular Power','RH Total Power');
legend('Location','southeast');

%Add a Title
title('Right Wrist Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Right Wrist Power');
pause(PauseTime);

%Close Figure
close(941);