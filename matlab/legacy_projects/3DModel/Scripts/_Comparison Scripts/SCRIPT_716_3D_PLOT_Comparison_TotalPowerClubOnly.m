figure(716);
hold on;

plot(BASEQ.Time,BASEQ.TotalLHPower);
plot(BASEQ.Time,BASEQ.TotalRHPower);

plot(ZTCFQ.Time,ZTCFQ.TotalLHPower,'--');
plot(ZTCFQ.Time,ZTCFQ.TotalRHPower,'--');


ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Total Power - BASE','RH Total Power - BASE','LH Total Power - ZTCF','RH Total Power - ZTCF');
legend('Location','southeast');

%Add a Title
title('Total Power on Club');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Total Power on Club');
pause(PauseTime);

%Close Figure
close(716);
