figure(713);
hold on;

plot(BASEQ.Time,BASEQ.TotalLHWork);
plot(BASEQ.Time,BASEQ.TotalRHWork);

plot(ZTCFQ.Time,ZTCFQ.TotalLHWork,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalRHWork,'--');

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LH Total Work - BASE','RH Total Work - BASE','LH Total Work - ZTCF','RH Total Work - ZTCF');
legend('Location','southeast');

%Add a Title
title('Total Work Club');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Total Work on Club');
pause(PauseTime);

%Close Figure
close(713);