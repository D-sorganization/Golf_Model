figure(507);
hold on;

plot(DELTAQ.Time,DELTAQ.TotalLSPower);
plot(DELTAQ.Time,DELTAQ.TotalRSPower);
plot(DELTAQ.Time,DELTAQ.TotalLEPower);
plot(DELTAQ.Time,DELTAQ.TotalREPower);
plot(DELTAQ.Time,DELTAQ.TotalLHPower);
plot(DELTAQ.Time,DELTAQ.TotalRHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Total Power','RS Total Power','LE Total Power','RE Total Power','LH Total Power','RH Total Power');
legend('Location','southeast');

%Add a Title
title('Total Power on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Total Power');
pause(PauseTime);

%Close Figure
close(507);
