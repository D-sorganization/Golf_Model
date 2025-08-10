figure(538);
hold on;

plot(DELTAQ.Time,DELTAQ.LHLinearWorkonClub);
plot(DELTAQ.Time,DELTAQ.LHAngularWorkonClub);
plot(DELTAQ.Time,DELTAQ.TotalLHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Work','LH Angular Work','LH Total Work');
legend('Location','southeast');

%Add a Title
title('Left Wrist Work on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Left Wrist Work');
pause(PauseTime);

%Close Figure
close(538);
