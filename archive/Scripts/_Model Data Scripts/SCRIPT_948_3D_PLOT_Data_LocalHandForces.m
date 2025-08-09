figure(948);
hold on;

plot(Data.Time(:,1),Data.LHonClubForceLocal(:,1));
plot(Data.Time(:,1),Data.LHonClubForceLocal(:,2));
plot(Data.Time(:,1),Data.LHonClubForceLocal(:,3));
plot(Data.Time(:,1),Data.RHonClubForceLocal(:,1));
plot(Data.Time(:,1),Data.RHonClubForceLocal(:,2));
plot(Data.Time(:,1),Data.RHonClubForceLocal(:,3));

ylabel('Force (N)');
grid 'on';

%Add Legend to Plot
legend('Left Wrist X','Left Wrist Y','Left Wrist Z','Right Wrist X','Right Wrist Y','Right Wrist Z');
legend('Location','southeast');

%Add a Title
title('Local Hand Forces on Club');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Local Hand Forces');
pause(PauseTime);

%Close Figure
close(948);