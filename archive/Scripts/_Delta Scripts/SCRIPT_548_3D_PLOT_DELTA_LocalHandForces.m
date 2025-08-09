figure(548);
hold on;

plot(DELTAQ.Time(:,1),DELTAQ.LHonClubForceLocal(:,1));
plot(DELTAQ.Time(:,1),DELTAQ.LHonClubForceLocal(:,2));
plot(DELTAQ.Time(:,1),DELTAQ.LHonClubForceLocal(:,3));

plot(DELTAQ.Time(:,1),DELTAQ.RHonClubForceLocal(:,1));
plot(DELTAQ.Time(:,1),DELTAQ.RHonClubForceLocal(:,2));
plot(DELTAQ.Time(:,1),DELTAQ.RHonClubForceLocal(:,3));

ylabel('Force (N)');
grid 'on';

%Add Legend to Plot
legend('Left Hand X','Left Hand Y','Left Hand Z','Right Hand X','Right Hand Y','Right Hand Z');
legend('Location','southeast');

%Add a Title
title('Local Hand Forces on Club');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Local Hand Forces');
pause(PauseTime);

%Close Figure
close(548);