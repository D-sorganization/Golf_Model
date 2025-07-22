figure(712);
hold on;

plot(BASEQ.Time,BASEQ.LHAngularWorkonClub);
plot(BASEQ.Time,BASEQ.RHAngularWorkonClub);


plot(ZTCFQ.Time,ZTCFQ.LHAngularWorkonClub,'--');
plot(ZTCFQ.Time,ZTCFQ.RHAngularWorkonClub,'--');

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LH Angular Work - BASE','RH Angular Work - BASE','LH Angular Work - ZTCF','RH Angular Work - ZTCF');
legend('Location','southeast');

%Add a Title
title('Angular Work on Club');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_PLOT - Angular Work on Club');
pause(PauseTime);

%Close Figure
close(712);