figure(906);
hold on;

plot(Data.Time,Data.TotalLSWork);
plot(Data.Time,Data.TotalRSWork);
plot(Data.Time,Data.TotalLEWork);
plot(Data.Time,Data.TotalREWork);
plot(Data.Time,Data.TotalLHWork);
plot(Data.Time,Data.TotalRHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Total Work','RS Total Work','LE Total Work','RE Total Work','LW Total Work','RW Total Work');
legend('Location','southeast');

%Add a Title
title('Total Work on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Total Work');
pause(PauseTime);

%Close Figure
close(906);