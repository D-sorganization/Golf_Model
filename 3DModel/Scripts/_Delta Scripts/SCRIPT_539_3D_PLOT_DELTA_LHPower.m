figure(539);
hold on;

plot(DELTAQ.Time,DELTAQ.LHonClubLinearPower);
plot(DELTAQ.Time,DELTAQ.LHonClubAngularPower);
plot(DELTAQ.Time,DELTAQ.TotalLHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Power','LH Angular Power','LH Total Power');
legend('Location','southeast');

%Add a Title
title('Left Wrist Power on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Left Wrist Power');
pause(PauseTime);

%Close Figure
close(539);