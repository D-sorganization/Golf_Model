figure(138);
hold on;

plot(BASEQ.Time,BASEQ.LHLinearWorkonClub);
plot(BASEQ.Time,BASEQ.LHAngularWorkonClub);
plot(BASEQ.Time,BASEQ.TotalLHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Work','LH Angular Work','LH Total Work');
legend('Location','southeast');

%Add a Title
title('Left Wrist Work on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Left Wrist Work');
pause(PauseTime);

%Close Figure
close(138);