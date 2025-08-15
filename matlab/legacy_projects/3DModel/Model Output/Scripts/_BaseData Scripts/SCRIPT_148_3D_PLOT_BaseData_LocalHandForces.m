figure(148);
hold on;

plot(BASEQ.Time(:,1),BASEQ.LHonClubForceLocal(:,1));
plot(BASEQ.Time(:,1),BASEQ.LHonClubForceLocal(:,2));
plot(BASEQ.Time(:,1),BASEQ.LHonClubForceLocal(:,3));

plot(BASEQ.Time(:,1),BASEQ.RHonClubForceLocal(:,1));
plot(BASEQ.Time(:,1),BASEQ.RHonClubForceLocal(:,2));
plot(BASEQ.Time(:,1),BASEQ.RHonClubForceLocal(:,3));

ylabel('Force (N)');
grid 'on';

%Add Legend to Plot
legend('Left Hand X','Left Hand Y','Left Hand Z','Right Hand X','Right Hand Y','Right Hand Z');
legend('Location','southeast');

%Add a Title
title('Local Hand Forces on Club');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Local Hand Forces');
pause(PauseTime);

%Close Figure
close(148);
