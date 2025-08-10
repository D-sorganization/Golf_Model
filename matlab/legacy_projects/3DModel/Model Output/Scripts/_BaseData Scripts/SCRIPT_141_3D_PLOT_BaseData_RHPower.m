figure(141);
hold on;

plot(BASEQ.Time,BASEQ.RHonClubLinearPower);
plot(BASEQ.Time,BASEQ.RHonClubAngularPower);
plot(BASEQ.Time,BASEQ.TotalRHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Power','RH Angular Power','RH Total Power');
legend('Location','southeast');

%Add a Title
title('Right Wrist Power on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Right Wrist Power');
pause(PauseTime);

%Close Figure
close(141);
