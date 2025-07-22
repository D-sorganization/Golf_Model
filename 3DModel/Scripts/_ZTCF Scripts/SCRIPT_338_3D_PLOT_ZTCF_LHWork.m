figure(338);
hold on;

plot(ZTCFQ.Time,ZTCFQ.LHLinearWorkonClub);
plot(ZTCFQ.Time,ZTCFQ.LHAngularWorkonClub);
plot(ZTCFQ.Time,ZTCFQ.TotalLHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Work','LH Angular Work','LH Total Work');
legend('Location','southeast');

%Add a Title
title('Left Wrist Work on Distal Segment');
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Left Wrist Work');
pause(PauseTime);

%Close Figure
close(338);