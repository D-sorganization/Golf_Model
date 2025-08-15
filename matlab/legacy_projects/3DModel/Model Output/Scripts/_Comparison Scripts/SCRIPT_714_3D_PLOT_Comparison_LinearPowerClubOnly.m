figure(714);
hold on;

plot(BASEQ.Time,BASEQ.LHonClubLinearPower);
plot(BASEQ.Time,BASEQ.RHonClubLinearPower);

plot(ZTCFQ.Time,ZTCFQ.LHonClubLinearPower,'--');
plot(ZTCFQ.Time,ZTCFQ.RHonClubLinearPower,'--');


ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Power - BASE','RH Linear Power - BASE','LH Linear Power - ZTCF','RH Linear Power - ZTCF');
legend('Location','southeast');

%Add a Title
title('Linear Power on Club');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Linear Power on Club');
pause(PauseTime);

%Close Figure
close(714);
