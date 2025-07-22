figure(748);
hold on;


plot(BASEQ.Time(:,1),BASEQ.LHonClubForceLocal(:,1),'LineWidth',3);
plot(BASEQ.Time(:,1),BASEQ.LHonClubForceLocal(:,2),'LineWidth',3);
plot(BASEQ.Time(:,1),BASEQ.LHonClubForceLocal(:,3),'LineWidth',3);
plot(BASEQ.Time(:,1),BASEQ.RHonClubForceLocal(:,1),'LineWidth',3);
plot(BASEQ.Time(:,1),BASEQ.RHonClubForceLocal(:,2),'LineWidth',3);
plot(BASEQ.Time(:,1),BASEQ.RHonClubForceLocal(:,3),'LineWidth',3);

plot(ZTCFQ.Time(:,1),ZTCFQ.LHonClubForceLocal(:,1),'LineWidth',3);
plot(ZTCFQ.Time(:,1),ZTCFQ.LHonClubForceLocal(:,2),'LineWidth',3);
plot(ZTCFQ.Time(:,1),ZTCFQ.LHonClubForceLocal(:,3),'LineWidth',3);
plot(ZTCFQ.Time(:,1),ZTCFQ.RHonClubForceLocal(:,1),'LineWidth',3);
plot(ZTCFQ.Time(:,1),ZTCFQ.RHonClubForceLocal(:,2),'LineWidth',3);
plot(ZTCFQ.Time(:,1),ZTCFQ.RHonClubForceLocal(:,3),'LineWidth',3);


ylabel('Force (N)');
grid 'on';

%Add Legend to Plot
legend('BASE Left Wrist X','BASE Left Wrist Y','BASE Left Wrist Z',...
    'BASE Right Wrist X','BASE Right Wrist Y','BASE Right Wrist Z',...
    'ZTCF Left Wrist X','ZTCF Left Wrist Y','ZTCF Left Wrist Z',...
    'ZTCF Right Wrist X','ZTCF Right Wrist Y','ZTCF Right Wrist Z');
legend('Location','southeast');

%Add a Title
title('Local Hand Forces on Club');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Local Hand Forces');
pause(PauseTime);

%Close Figure
close(748);