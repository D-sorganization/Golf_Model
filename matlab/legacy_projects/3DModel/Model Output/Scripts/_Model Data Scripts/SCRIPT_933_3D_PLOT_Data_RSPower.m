figure(933);
hold on;

plot(Data.Time,Data.RSonArmLinearPower);
plot(Data.Time,Data.RSonArmAngularPower);
plot(Data.Time,Data.TotalRSPower);

ylabel('Power (W)');
grid 'on';

%Add Legend to Plot
legend('RS Linear Power','RS Angular Power','RS Total Power');
legend('Location','southeast');

%Add a Title
title('Right Shoulder Power on Distal Segment');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Data_Plot - Right Shoulder Power');
pause(PauseTime);

%Close Figure
close(933);
