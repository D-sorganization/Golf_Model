figure(907);
hold on;

plot(Data.Time,Data.TotalLSPower);
plot(Data.Time,Data.TotalRSPower);
plot(Data.Time,Data.TotalLEPower);
plot(Data.Time,Data.TotalREPower);
plot(Data.Time,Data.TotalLHPower);
plot(Data.Time,Data.TotalRHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Total Power','RS Total Power','LE Total Power','RE Total Power','LH Total Power','RH Total Power');
legend('Location','southeast');

%Add a Title
title('Total Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Total Power');
pause(PauseTime);

%Close Figure
close(907);