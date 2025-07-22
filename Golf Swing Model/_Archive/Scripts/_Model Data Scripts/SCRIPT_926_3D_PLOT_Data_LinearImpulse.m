figure(926);
plot(Data.Time,Data.LinearImpulseonClub);
xlabel('Time (s)');
ylabel('Impulse (Ns)');
grid 'on';

%Add Legend to Plot
legend('Linear Impulse');
legend('Location','southeast');

%Add a Title
title('Linear Impulse');
subtitle('Data');

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Charts/Plot - Linear Impulse');
pause(PauseTime);

%Close Figure
close(926);