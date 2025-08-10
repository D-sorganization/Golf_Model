figure(934);
hold on;

plot(Data.Time,Data.LELinearWorkonForearm);
plot(Data.Time,Data.LEAngularWorkonForearm);
plot(Data.Time,Data.TotalLEWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LE Linear Work','LE Angular Work','LE Total Work');
legend('Location','southeast');

%Add a Title
title('Left Elbow Work on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Left Elbow Work');
pause(PauseTime);

%Close Figure
close(934);
