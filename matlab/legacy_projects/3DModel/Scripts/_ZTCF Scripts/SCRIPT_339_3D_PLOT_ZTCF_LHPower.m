figure(339);
hold on;

plot(ZTCFQ.Time,ZTCFQ.LHonClubLinearPower);
plot(ZTCFQ.Time,ZTCFQ.LHonClubAngularPower);
plot(ZTCFQ.Time,ZTCFQ.TotalLHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Power','LH Angular Power','LH Total Power');
legend('Location','southeast');

%Add a Title
title('Left Wrist Power on Distal Segment');
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Left Wrist Power');
pause(PauseTime);

%Close Figure
close(339);
