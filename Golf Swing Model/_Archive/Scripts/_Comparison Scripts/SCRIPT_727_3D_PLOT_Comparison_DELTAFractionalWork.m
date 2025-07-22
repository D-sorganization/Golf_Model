figure(727);
hold on;

plot(BASEQ.Time,BASEQ.DELTAQLSFractionalWork);
plot(BASEQ.Time,BASEQ.DELTAQRSFractionalWork);
plot(BASEQ.Time,BASEQ.DELTAQLEFractionalWork);
plot(BASEQ.Time,BASEQ.DELTAQREFractionalWork);
plot(BASEQ.Time,BASEQ.DELTAQLHFractionalWork);
plot(BASEQ.Time,BASEQ.DELTAQRHFractionalWork);
ylim([-5 5]);
ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Total DELTA Fractional Work','RS Total DELTA Fractional Work','LE Total DELTA Fractional Work','RE Total DELTA Fractional Work','LH Total DELTA Fractional Work','RH Total DELTA Fractional Work');
legend('Location','southeast');

%Add a Title
title('Total DELTA Fractional Work on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Total DELTA Fractional Work');
pause(PauseTime);

%Close Figure
close(727);