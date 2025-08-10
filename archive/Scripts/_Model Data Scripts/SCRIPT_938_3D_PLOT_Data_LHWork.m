figure(938);
hold on;

plot(Data.Time,Data.LHLinearWorkonClub);
plot(Data.Time,Data.LHAngularWorkonClub);
plot(Data.Time,Data.TotalLHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Work','LH Angular Work','LH Total Work');
legend('Location','southeast');

%Add a Title
title('Left Wrist Work on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Left Hand Work');
pause(PauseTime);

%Close Figure
close(938);
