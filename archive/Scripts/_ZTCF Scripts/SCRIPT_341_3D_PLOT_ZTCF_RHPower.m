figure(341);
hold on;

plot(ZTCFQ.Time,ZTCFQ.RHonClubLinearPower);
plot(ZTCFQ.Time,ZTCFQ.RHonClubAngularPower);
plot(ZTCFQ.Time,ZTCFQ.TotalRHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Power','RH Angular Power','RH Total Power');
legend('Location','southeast');

%Add a Title
title('Right Wrist Power on Distal Segment');
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Right Wrist Power');
pause(PauseTime);

%Close Figure
close(341);
