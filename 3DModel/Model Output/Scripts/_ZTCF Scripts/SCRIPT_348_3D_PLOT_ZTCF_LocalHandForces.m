figure(348);
hold on;

plot(ZTCFQ.Time(:,1),ZTCFQ.LHonClubForceLocal(:,1));
plot(ZTCFQ.Time(:,1),ZTCFQ.LHonClubForceLocal(:,2));
plot(ZTCFQ.Time(:,1),ZTCFQ.LHonClubForceLocal(:,3));

plot(ZTCFQ.Time(:,1),ZTCFQ.RHonClubForceLocal(:,1));
plot(ZTCFQ.Time(:,1),ZTCFQ.RHonClubForceLocal(:,2));
plot(ZTCFQ.Time(:,1),ZTCFQ.RHonClubForceLocal(:,3));



ylabel('Force (N)');
grid 'on';

%Add Legend to Plot
legend('Left Hand X','Left Hand Y','Left Hand Z','Right Hand X','Right Hand Y','Right Hand Z');
legend('Location','southeast');

%Add a Title
title('Local Hand Forces on Club');
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Local Hand Forces');
pause(PauseTime);

%Close Figure
close(348);