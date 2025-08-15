figure(102);
hold on;

plot(BASEQ.Time,BASEQ.LSonArmAngularPower);
plot(BASEQ.Time,BASEQ.RSonArmAngularPower);
plot(BASEQ.Time,BASEQ.LEonForearmAngularPower);
plot(BASEQ.Time,BASEQ.REonForearmAngularPower);
plot(BASEQ.Time,BASEQ.LHonClubAngularPower);
plot(BASEQ.Time,BASEQ.RHonClubAngularPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Power','RS Angular Power','LE Angular Power','RE Angular Power','LH Angular Power','RH Angular Power');
legend('Location','southeast');

%Add a Title
title('Angular Power on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Angular Power');
pause(PauseTime);

%Close Figure
close(102);
