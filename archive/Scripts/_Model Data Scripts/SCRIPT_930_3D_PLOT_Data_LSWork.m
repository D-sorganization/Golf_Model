figure(930);
hold on;

plot(Data.Time,Data.LSLinearWorkonArm);
plot(Data.Time,Data.LSAngularWorkonArm);
plot(Data.Time,Data.TotalLSWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Linear Work','LS Angular Work','LS Total Work');
legend('Location','southeast');

%Add a Title
title('Left Shoulder Work on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Left Shoulder Work');
pause(PauseTime);

%Close Figure
close(930);
