figure(707);
hold on;

plot(BASEQ.Time,BASEQ.TotalLSWork);
plot(BASEQ.Time,BASEQ.TotalRSWork);
plot(BASEQ.Time,BASEQ.TotalLEWork);
plot(BASEQ.Time,BASEQ.TotalREWork);
plot(BASEQ.Time,BASEQ.TotalLHWork);
plot(BASEQ.Time,BASEQ.TotalRHWork);

plot(ZTCFQ.Time,ZTCFQ.TotalLSWork,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalRSWork,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalLEWork,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalREWork,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalLHWork,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalRHWork,'--');

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Total Work - BASE','RS Total Work - BASE','LE Total Work - BASE','RE Total Work - BASE','LH Total Work - BASE','RH Total Work - BASE','LS Total Work - ZTCF','RS Total Work - ZTCF','LE Total Work - ZTCF','RE Total Work - ZTCF','LH Total Work - ZTCF','RH Total Work - ZTCF');
legend('Location','southeast');

%Add a Title
title('Total Work on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Total Work on Distal');
pause(PauseTime);

%Close Figure
close(707);
