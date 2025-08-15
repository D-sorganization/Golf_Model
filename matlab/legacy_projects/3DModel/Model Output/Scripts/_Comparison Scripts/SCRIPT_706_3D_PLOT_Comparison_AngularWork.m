figure(706);
hold on;

plot(BASEQ.Time,BASEQ.LSAngularWorkonArm);
plot(BASEQ.Time,BASEQ.RSAngularWorkonArm);
plot(BASEQ.Time,BASEQ.LEAngularWorkonForearm);
plot(BASEQ.Time,BASEQ.REAngularWorkonForearm);
plot(BASEQ.Time,BASEQ.LHAngularWorkonClub);
plot(BASEQ.Time,BASEQ.RHAngularWorkonClub);

plot(ZTCFQ.Time,ZTCFQ.LSAngularWorkonArm,'--');
plot(ZTCFQ.Time,ZTCFQ.RSAngularWorkonArm,'--');
plot(ZTCFQ.Time,ZTCFQ.LEAngularWorkonForearm,'--');
plot(ZTCFQ.Time,ZTCFQ.REAngularWorkonForearm,'--');
plot(ZTCFQ.Time,ZTCFQ.LHAngularWorkonClub,'--');
plot(ZTCFQ.Time,ZTCFQ.RHAngularWorkonClub,'--');

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Work - BASE','RS Angular Work - BASE','LE Angular Work - BASE','RE Angular Work - BASE','LH Angular Work - BASE','RH Angular Work - BASE','LS Angular Work - ZTCF','RS Angular Work - ZTCF','LE Angular Work - ZTCF','RE Angular Work - ZTCF','LH Angular Work - ZTCF','RH Angular Work - ZTCF');
legend('Location','southeast');

%Add a Title
title('Angular Work on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Angular Work on Distal');
pause(PauseTime);

%Close Figure
close(706);
