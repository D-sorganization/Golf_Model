figure(140);
hold on;

plot(BASEQ.Time,BASEQ.RHLinearWorkonClub);
plot(BASEQ.Time,BASEQ.RHAngularWorkonClub);
plot(BASEQ.Time,BASEQ.TotalRHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Work','RH Angular Work','RH Total Work');
legend('Location','southeast');

%Add a Title
title('Right Wrist Work on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Right Wrist Work');
pause(PauseTime);

%Close Figure
close(140);
