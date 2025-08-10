figure(901);
hold on;

plot(Data.Time,Data.LSAngularWorkonArm);
plot(Data.Time,Data.RSAngularWorkonArm);
plot(Data.Time,Data.LEAngularWorkonForearm);
plot(Data.Time,Data.REAngularWorkonForearm);
plot(Data.Time,Data.LHAngularWorkonClub);
plot(Data.Time,Data.RHAngularWorkonClub);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Work','RS Angular Work','LE Angular Work','RE Angular Work','LH Angular Work','RH Angular Work');
legend('Location','southeast');

%Add a Title
title('Angular Work on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Angular Work');
pause(PauseTime);

%Close Figure
close(901);
