figure(709);
hold on;

plot(BASEQ.Time,BASEQ.LSonArmAngularPower);
plot(BASEQ.Time,BASEQ.RSonArmAngularPower);
plot(BASEQ.Time,BASEQ.LEonForearmAngularPower);
plot(BASEQ.Time,BASEQ.REonForearmAngularPower);
plot(BASEQ.Time,BASEQ.LHonClubAngularPower);
plot(BASEQ.Time,BASEQ.RHonClubAngularPower);

plot(ZTCFQ.Time,ZTCFQ.LSonArmAngularPower,'--');
plot(ZTCFQ.Time,ZTCFQ.RSonArmAngularPower,'--');
plot(ZTCFQ.Time,ZTCFQ.LEonForearmAngularPower,'--');
plot(ZTCFQ.Time,ZTCFQ.REonForearmAngularPower,'--');
plot(ZTCFQ.Time,ZTCFQ.LHonClubAngularPower,'--');
plot(ZTCFQ.Time,ZTCFQ.RHonClubAngularPower,'--');

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Power - BASE','RS Angular Power - BASE','LE Angular Power - BASE','RE Angular Power - BASE','LH Angular Power - BASE','RH Angular Power - BASE','LS Angular Power - ZTCF','RS Angular Power - ZTCF','LE Angular Power - ZTCF','RE Angular Power - ZTCF','LH Angular Power - ZTCF','RH Angular Power - ZTCF');
legend('Location','southeast');

%Add a Title
title('Angular Power on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Angular Power on Distal');
pause(PauseTime);

%Close Figure
close(709);