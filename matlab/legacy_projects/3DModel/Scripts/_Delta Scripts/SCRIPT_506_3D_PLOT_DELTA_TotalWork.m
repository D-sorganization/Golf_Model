figure(506);
hold on;

plot(DELTAQ.Time,DELTAQ.TotalLSWork);
plot(DELTAQ.Time,DELTAQ.TotalRSWork);
plot(DELTAQ.Time,DELTAQ.TotalLEWork);
plot(DELTAQ.Time,DELTAQ.TotalREWork);
plot(DELTAQ.Time,DELTAQ.TotalLHWork);
plot(DELTAQ.Time,DELTAQ.TotalRHWork);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Total Work','RS Total Work','LE Total Work','RE Total Work','LH Total Work','RH Total Work');
legend('Location','southeast');

%Add a Title
title('Total Work on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Total Work');
pause(PauseTime);

%Close Figure
close(506);