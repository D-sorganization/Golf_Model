%Generate Club Quiver Plot
figure(943);
run SCRIPT_3D_QuiverClubandShaftData.m;

%Generate Left Hand Angular Impulse Quiver Plot
LHAngularImpulseQuiver=quiver3(Data.LHx(:,1),Data.LHy(:,1),Data.LHz(:,1),Data.LHAngularImpulseonClub(:,1),Data.LHAngularImpulseonClub(:,2),Data.LHAngularImpulseonClub(:,3));
LHAngularImpulseQuiver.LineWidth=1;
LHAngularImpulseQuiver.Color=[0 1 0];
LHAngularImpulseQuiver.MaxHeadSize=0.1;
LHAngularImpulseQuiver.AutoScaleFactor=3;

%Generate Right Hand Angular Impulse Quiver Plot
RHAngularImpulseQuiver=quiver3(Data.RHx(:,1),Data.RHy(:,1),Data.RHz(:,1),Data.RHAngularImpulseonClub(:,1),Data.RHAngularImpulseonClub(:,2),Data.RHAngularImpulseonClub(:,3));
RHAngularImpulseQuiver.LineWidth=1;
RHAngularImpulseQuiver.Color=[.8 .2 0];
RHAngularImpulseQuiver.MaxHeadSize=0.1;
%Correct scaling on Angular Impulses so that LH and RH are scaled the same.
RHAngularImpulseQuiver.AutoScaleFactor=LHAngularImpulseQuiver.ScaleFactor/RHAngularImpulseQuiver.ScaleFactor;


%Add Legend to Plot
legend('','','','','LH Angular Impulse','RH Angular Impulse');

%Add a Title
title('LH and RH Angular Impulse on Club');
subtitle('Data');

%Set View
view(-0.0885,-10.6789);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Data_Quiver Plot - LHRH Angular Impulse on Club');
pause(PauseTime);

%Close Figure
close(943);

%Clear Figure from Workspace
clear LHAngularImpulseQuiver;
clear RHAngularImpulseQuiver;
clear ZTCFLHAngularImpulseQuiver;
clear ZTCFRHAngularImpulseQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
