figure(502);
hold on;

plot(ZTCFQ.Time,DELTAQ.LSonArmAngularPower);
plot(ZTCFQ.Time,DELTAQ.RSonArmAngularPower);
plot(ZTCFQ.Time,DELTAQ.LEonForearmAngularPower);
plot(ZTCFQ.Time,DELTAQ.REonForearmAngularPower);
plot(ZTCFQ.Time,DELTAQ.LHonClubAngularPower);
plot(ZTCFQ.Time,DELTAQ.RHonClubAngularPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Power','RS Angular Power','LE Angular Power','RE Angular Power','LH Angular Power','RH Angular Power');
legend('Location','southeast');

%Add a Title
title('Angular Power on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Angular Power');
pause(PauseTime);

%Close Figure
close(502);