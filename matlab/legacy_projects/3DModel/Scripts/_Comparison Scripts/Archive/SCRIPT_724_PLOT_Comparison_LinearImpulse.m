figure(17);
hold on;

plot(BASEQ.Time,BASEQ.LHLinearImpulseonClub);
plot(BASEQ.Time,BASEQ.RHLinearImpulseonClub);
plot(BASEQ.Time,BASEQ.LinearImpulseonClub);

ylabel('Linear Impulse (kgm/s)');
grid 'on';

%Add Legend to Plot
legend('LH Linear Impulse','RH Linear Impulse','Net Force Linear Impulse (midpoint)');
legend('Location','southeast');

%Add a Title
title('Linear Impulse');
%subtitle('Left Hand, Right Hand, Total');
subtitle('COMPARISON');

%Save Figure
savefig('Comparison Charts/COMPARISON_Plot - Linear Impulse LH,RH,Total');

%Close Figure
close(17);
