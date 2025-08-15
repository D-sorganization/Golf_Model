figure(501);
hold on;

plot(DELTAQ.Time,DELTAQ.LSAngularWorkonArm);
plot(DELTAQ.Time,DELTAQ.RSAngularWorkonArm);
plot(DELTAQ.Time,DELTAQ.LEAngularWorkonForearm);
plot(DELTAQ.Time,DELTAQ.REAngularWorkonForearm);
plot(DELTAQ.Time,DELTAQ.LHAngularWorkonClub);
plot(DELTAQ.Time,DELTAQ.RHAngularWorkonClub);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Work','RS Angular Work','LE Angular Work','RE Angular Work','LH Angular Work','RH Angular Work');
legend('Location','southeast');

%Add a Title
title('Angular Work on Distal Segment');
subtitle('DELTA');

%Save Figure
savefig('Delta Charts/DELTA_Plot - Angular Work');
pause(PauseTime);

%Close Figure
close(501);
