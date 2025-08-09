figure(925);
hold on;

plot(Data.Time,Data.LHForceAlongHandPath);
plot(Data.Time,Data.RHForceAlongHandPath);
plot(Data.Time,Data.ForceAlongHandPath);

ylabel('Force (N)');
grid 'on';

%Add Legend to Plot
legend('LH Force on Left Hand Path','RH Force on Right Hand Path','Net Force Along MP Hand Path');
legend('Location','southeast');

%Add a Title
title('Force Along Hand Path');
subtitle('Data');
%subtitle('Left Hand, Right Hand, Total');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Plot - Force Along Hand Path - LH RH Total');
pause(PauseTime);

%Close Figure
close(925);