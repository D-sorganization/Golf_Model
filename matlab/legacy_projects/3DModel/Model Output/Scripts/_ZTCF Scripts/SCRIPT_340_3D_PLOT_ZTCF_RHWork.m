figure(340);
hold on;

plot(ZTCFQ.Time,ZTCFQ.RHLinearWorkonClub);
plot(ZTCFQ.Time,ZTCFQ.RHAngularWorkonClub);
plot(ZTCFQ.Time,ZTCFQ.TotalRHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Work','RH Angular Work','RH Total Work');
legend('Location','southeast');

%Add a Title
title('Right Wrist Work on Distal Segment');
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Right Wrist Work');
pause(PauseTime);

%Close Figure
close(340);
