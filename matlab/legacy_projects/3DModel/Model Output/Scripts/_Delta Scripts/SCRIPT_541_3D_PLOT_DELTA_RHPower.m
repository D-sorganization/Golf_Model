figure(541);
hold on;

plot(DELTAQ.Time,DELTAQ.RHonClubLinearPower);
plot(DELTAQ.Time,DELTAQ.RHonClubAngularPower);
plot(DELTAQ.Time,DELTAQ.TotalRHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('RH Linear Power','RH Angular Power','RH Total Power');
legend('Location','southeast');

%Add a Title
title('Right Wrist Power on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Right Wrist Power');
pause(PauseTime);

%Close Figure
close(541);
