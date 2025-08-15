figure(103);
hold on;

plot(BASEQ.Time,BASEQ.LSonArmLinearPower);
plot(BASEQ.Time,BASEQ.RSonArmLinearPower);
plot(BASEQ.Time,BASEQ.LEonForearmLinearPower);
plot(BASEQ.Time,BASEQ.REonForearmLinearPower);
plot(BASEQ.Time,BASEQ.LHonClubLinearPower);
plot(BASEQ.Time,BASEQ.RHonClubLinearPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Linear Power','RS Linear Power','LE Linear Power','RE Linear Power','LH Linear Power','RH Linear Power');
legend('Location','southeast');

%Add a Title
title('Linear Power on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Linear Power');
pause(PauseTime);

%Close Figure
close(103);
