%Generate Club Quiver Plot
figure(942);
run SCRIPT_3D_QuiverClubandShaftData.m;

%Generate Left Hand Linear Impulse Quiver Plot
LHLinearImpulseQuiver=quiver3(Data.LHx(:,1),Data.LHy(:,1),Data.LHz(:,1),Data.LHLinearImpulseonClub(:,1),Data.LHLinearImpulseonClub(:,2),Data.LHLinearImpulseonClub(:,3));
LHLinearImpulseQuiver.LineWidth=1;
LHLinearImpulseQuiver.Color=[0 1 0];
LHLinearImpulseQuiver.MaxHeadSize=0.1;
LHLinearImpulseQuiver.AutoScaleFactor=3;

%Generate Right Hand Linear Impulse Quiver Plot
RHLinearImpulseQuiver=quiver3(Data.RHx(:,1),Data.RHy(:,1),Data.RHz(:,1),Data.RHLinearImpulseonClub(:,1),Data.RHLinearImpulseonClub(:,2),Data.RHLinearImpulseonClub(:,3));
RHLinearImpulseQuiver.LineWidth=1;
RHLinearImpulseQuiver.Color=[.8 .2 0];
RHLinearImpulseQuiver.MaxHeadSize=0.1;
%Correct scaling on Linear Impulses so that LH and RH are scaled the same.
RHLinearImpulseQuiver.AutoScaleFactor=LHLinearImpulseQuiver.ScaleFactor/RHLinearImpulseQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Linear Impulse','RH Linear Impulse');

%Add a Title
title('LH and RH Linear Impulse on Club');
subtitle('Data');

%Set View
view(-0.0885,-10.6789);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Data_Quiver Plot - LHRH Linear Impulse on Club');
pause(PauseTime);

%Close Figure
close(942);

%Clear Figure from Workspace
clear LHLinearImpulseQuiver;
clear RHLinearImpulseQuiver;
clear ZTCFLHLinearImpulseQuiver;
clear ZTCFRHLinearImpulseQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
