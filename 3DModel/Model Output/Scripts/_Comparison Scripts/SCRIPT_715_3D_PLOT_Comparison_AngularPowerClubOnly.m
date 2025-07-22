figure(715);
hold on;

plot(BASEQ.Time,BASEQ.LHonClubAngularPower);
plot(BASEQ.Time,BASEQ.RHonClubAngularPower);

plot(ZTCFQ.Time,ZTCFQ.LHonClubAngularPower,'--');
plot(ZTCFQ.Time,ZTCFQ.RHonClubAngularPower,'--');

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Angular Power - BASE','RH Angular Power - BASE','LH Angular Power - ZTCF','RH Angular Power - ZTCF');
legend('Location','southeast');

%Add a Title
title('Angular Power on Club');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Angular Power on Club');
pause(PauseTime);

%Close Figure
close(715);