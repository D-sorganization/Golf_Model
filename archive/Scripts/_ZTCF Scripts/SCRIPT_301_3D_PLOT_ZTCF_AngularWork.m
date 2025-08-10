figure(301);
hold on;

plot(ZTCFQ.Time,ZTCFQ.LSAngularWorkonArm);
plot(ZTCFQ.Time,ZTCFQ.RSAngularWorkonArm);
plot(ZTCFQ.Time,ZTCFQ.LEAngularWorkonForearm);
plot(ZTCFQ.Time,ZTCFQ.REAngularWorkonForearm);
plot(ZTCFQ.Time,ZTCFQ.LHAngularWorkonClub);
plot(ZTCFQ.Time,ZTCFQ.RHAngularWorkonClub);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Work','RS Angular Work','LE Angular Work','RE Angular Work','LH Angular Work','RH Angular Work');
legend('Location','southeast');

%Add a Title
title('Angular Work on Distal Segment');
subtitle('ZTCF');

%Save Figure
savefig('ZTCF Charts/ZTCF_Plot - Angular Work');
pause(PauseTime);

%Close Figure
close(301);
