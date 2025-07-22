%Generate Club Quiver Plot
figure(143);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate Left Hand Angular Impulse Quiver Plot
LHAngularImpulseQuiver=quiver3(BASEQ.LHx(:,1),BASEQ.LHy(:,1),BASEQ.LHz(:,1),BASEQ.LHAngularImpulseonClub(:,1),BASEQ.LHAngularImpulseonClub(:,2),BASEQ.LHAngularImpulseonClub(:,3));
LHAngularImpulseQuiver.LineWidth=1;
LHAngularImpulseQuiver.Color=[0 1 0];
LHAngularImpulseQuiver.MaxHeadSize=0.1;
LHAngularImpulseQuiver.AutoScaleFactor=3;

%Generate Right Hand Angular Impulse Quiver Plot
RHAngularImpulseQuiver=quiver3(BASEQ.RHx(:,1),BASEQ.RHy(:,1),BASEQ.RHz(:,1),BASEQ.RHAngularImpulseonClub(:,1),BASEQ.RHAngularImpulseonClub(:,2),BASEQ.RHAngularImpulseonClub(:,3));
RHAngularImpulseQuiver.LineWidth=1;
RHAngularImpulseQuiver.Color=[.8 .2 0];
RHAngularImpulseQuiver.MaxHeadSize=0.1;
%Correct scaling on Angular Impulses so that ZTCF and BASE are scaled the same.
RHAngularImpulseQuiver.AutoScaleFactor=LHAngularImpulseQuiver.ScaleFactor/RHAngularImpulseQuiver.ScaleFactor;


%Add Legend to Plot
legend('','','','','LH Angular Impulse','RH Angular Impulse');

%Add a Title
title('LH and RH Angular Impulse on Club');
subtitle('BASE');

%Set View
view(-0.0885,-10.6789);

%Save Figure
savefig('BaseData Quiver Plots/BASE_Quiver Plot - LHRH Angular Impulse on Club');
pause(PauseTime);

%Close Figure
close(143);

%Clear Figure from Workspace
clear LHAngularImpulseQuiver;
clear RHAngularImpulseQuiver;
clear ZTCFLHAngularImpulseQuiver;
clear ZTCFRHAngularImpulseQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
