figure(729);
hold on;

plot(BASEQ.Time,BASEQ.DELTAQLSFractionalPower);
plot(BASEQ.Time,BASEQ.DELTAQRSFractionalPower);
plot(BASEQ.Time,BASEQ.DELTAQLEFractionalPower);
plot(BASEQ.Time,BASEQ.DELTAQREFractionalPower);
plot(BASEQ.Time,BASEQ.DELTAQLHFractionalPower);
plot(BASEQ.Time,BASEQ.DELTAQRHFractionalPower);
ylim([-5 5]);
ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Total DELTA Fractional Power','RS Total DELTA Fractional Power','LE Total DELTA Fractional Power','RE Total DELTA Fractional Power','LH Total DELTA Fractional Power','RH Total DELTA Fractional Power');
legend('Location','southeast');

%Add a Title
title('Total DELTA Fractional Power on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Total DELTA Fractional Power');
pause(PauseTime);

%Close Figure
close(729);
