figure(940);
hold on;

plot(Data.Time,Data.RHLinearWorkonClub);
plot(Data.Time,Data.RHAngularWorkonClub);
plot(Data.Time,Data.TotalRHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Work','RH Angular Work','RH Total Work');
legend('Location','southeast');

%Add a Title
title('Right Wrist Work on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Right Wrist Work');
pause(PauseTime);

%Close Figure
close(940);