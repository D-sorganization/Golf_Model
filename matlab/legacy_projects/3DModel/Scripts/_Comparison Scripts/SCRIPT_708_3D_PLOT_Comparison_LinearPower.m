figure(708);
hold on;

plot(BASEQ.Time,BASEQ.LSonArmLinearPower);
plot(BASEQ.Time,BASEQ.RSonArmLinearPower);
plot(BASEQ.Time,BASEQ.LEonForearmLinearPower);
plot(BASEQ.Time,BASEQ.REonForearmLinearPower);
plot(BASEQ.Time,BASEQ.LHonClubLinearPower);
plot(BASEQ.Time,BASEQ.RHonClubLinearPower);

plot(ZTCFQ.Time,ZTCFQ.LSonArmLinearPower,'--');
plot(ZTCFQ.Time,ZTCFQ.RSonArmLinearPower,'--');
plot(ZTCFQ.Time,ZTCFQ.LEonForearmLinearPower,'--');
plot(ZTCFQ.Time,ZTCFQ.REonForearmLinearPower,'--');
plot(ZTCFQ.Time,ZTCFQ.LHonClubLinearPower,'--');
plot(ZTCFQ.Time,ZTCFQ.RHonClubLinearPower,'--');


ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('LS Linear Power - BASE','RS Linear Power - BASE','LE Linear Power - BASE','RE Linear Power - BASE','LH Linear Power - BASE','RH Linear Power - BASE','LS Linear Power - ZTCF','RS Linear Power - ZTCF','LE Linear Power - ZTCF','RE Linear Power - ZTCF','LH Linear Power - ZTCF','RH Linear Power - ZTCF');
legend('Location','southeast');

%Add a Title
title('Linear Power on Distal Segment');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Linear Power on Distal');
pause(PauseTime);

%Close Figure
close(708);
