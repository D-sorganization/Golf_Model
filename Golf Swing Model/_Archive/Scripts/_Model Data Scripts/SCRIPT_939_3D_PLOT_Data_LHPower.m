figure(939);
hold on;

plot(Data.Time,Data.LHonClubLinearPower);
plot(Data.Time,Data.LHonClubAngularPower);
plot(Data.Time,Data.TotalLHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Power','LH Angular Power','LH Total Power');
legend('Location','southeast');

%Add a Title
title('Left Wrist Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Left Wrist Power');
pause(PauseTime);

%Close Figure
close(939);