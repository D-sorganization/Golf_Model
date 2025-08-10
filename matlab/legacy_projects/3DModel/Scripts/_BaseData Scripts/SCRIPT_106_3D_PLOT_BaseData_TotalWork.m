figure(106);
hold on;

plot(BASEQ.Time,BASEQ.TotalLSWork);
plot(BASEQ.Time,BASEQ.TotalRSWork);
plot(BASEQ.Time,BASEQ.TotalLEWork);
plot(BASEQ.Time,BASEQ.TotalREWork);
plot(BASEQ.Time,BASEQ.TotalLHWork);
plot(BASEQ.Time,BASEQ.TotalRHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Total Work','RS Total Work','LE Total Work','RE Total Work','LH Total Work','RH Total Work');
legend('Location','southeast');

%Add a Title
title('Total Work on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Total Work');
pause(PauseTime);

%Close Figure
close(106);
