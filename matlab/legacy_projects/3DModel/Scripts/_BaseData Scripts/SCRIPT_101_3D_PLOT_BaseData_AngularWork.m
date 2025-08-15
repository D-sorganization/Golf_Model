figure(101);
hold on;

plot(BASEQ.Time,BASEQ.LSAngularWorkonArm);
plot(BASEQ.Time,BASEQ.RSAngularWorkonArm);
plot(BASEQ.Time,BASEQ.LEAngularWorkonForearm);
plot(BASEQ.Time,BASEQ.REAngularWorkonForearm);
plot(BASEQ.Time,BASEQ.LHAngularWorkonClub);
plot(BASEQ.Time,BASEQ.RHAngularWorkonClub);

ylabel('Work (J)');
grid 'on';

%Add Legend to Plot
legend('LS Angular Work','RS Angular Work','LE Angular Work','RE Angular Work','LH Angular Work','RH Angular Work');
legend('Location','southeast');

%Add a Title
title('Angular Work on Distal Segment');
subtitle('BASE');

%Save Figure
savefig('BaseData Charts/BASE_Plot - Angular Work');
pause(PauseTime);

%Close Figure
close(101);
