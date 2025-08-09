figure(935);
hold on;

plot(Data.Time,Data.LEonForearmLinearPower);
plot(Data.Time,Data.LEonForearmAngularPower);
plot(Data.Time,Data.TotalLEPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LE Linear Power','LE Angular Power','LE Total Power');
legend('Location','southeast');

%Add a Title
title('Left Elbow Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Left Elbow Power');
pause(PauseTime);

%Close Figure
close(935);