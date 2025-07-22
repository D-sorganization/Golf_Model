figure(726);
hold on;

plot(BASEQ.Time,BASEQ.ZTCFQLSFractionalWork);
plot(BASEQ.Time,BASEQ.ZTCFQRSFractionalWork);
plot(BASEQ.Time,BASEQ.ZTCFQLEFractionalWork);
plot(BASEQ.Time,BASEQ.ZTCFQREFractionalWork);
plot(BASEQ.Time,BASEQ.ZTCFQLHFractionalWork);
plot(BASEQ.Time,BASEQ.ZTCFQRHFractionalWork);
ylim([-5 5]);
ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Total ZTCF Fractional Work','RS Total ZTCF Fractional Work','LE Total ZTCF Fractional Work','RE Total ZTCF Fractional Work','LH Total ZTCF Fractional Work','RH Total ZTCF Fractional Work');
legend('Location','southeast');

%Add a Title
title('Total ZTCF Fractional Work on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Total ZTCF Fractional Work');
pause(PauseTime);

%Close Figure
close(726);