figure(139);
hold on;

plot(BASEQ.Time,BASEQ.LHonClubLinearPower);
plot(BASEQ.Time,BASEQ.LHonClubAngularPower);
plot(BASEQ.Time,BASEQ.TotalLHPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Power','LH Angular Power','LH Total Power');
legend('Location','southeast');

%Add a Title
title('Left Wrist Power on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Left Wrist Power');
pause(PauseTime);

%Close Figure
close(139);
