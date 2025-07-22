%Generate Club Quiver Plot
figure(719);
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


%Generate ZTCF Left Hand Angular Impulse Quiver Plot
ZTCFLHAngularImpulseQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),ZTCFQ.LHAngularImpulseonClub(:,1),ZTCFQ.LHAngularImpulseonClub(:,2),ZTCFQ.LHAngularImpulseonClub(:,3));
ZTCFLHAngularImpulseQuiver.LineWidth=1;
ZTCFLHAngularImpulseQuiver.Color=[0 0.3 0];
ZTCFLHAngularImpulseQuiver.MaxHeadSize=0.1;
%Correct scaling on Angular Impulses so that ZTCF and BASE are scaled the same.
ZTCFLHAngularImpulseQuiver.AutoScaleFactor=LHAngularImpulseQuiver.ScaleFactor/ZTCFLHAngularImpulseQuiver.ScaleFactor;

%Generate ZTCF Right Hand Angular Impulse Quiver Plot
ZTCFRHAngularImpulseQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),ZTCFQ.RHAngularImpulseonClub(:,1),ZTCFQ.RHAngularImpulseonClub(:,2),ZTCFQ.RHAngularImpulseonClub(:,3));
ZTCFRHAngularImpulseQuiver.LineWidth=1;
ZTCFRHAngularImpulseQuiver.Color=[.5 .5 0];
ZTCFRHAngularImpulseQuiver.MaxHeadSize=0.1;
%Correct scaling on Angular Impulse so that ZTCF and BASE are scaled the same.
ZTCFRHAngularImpulseQuiver.AutoScaleFactor=LHAngularImpulseQuiver.ScaleFactor/ZTCFRHAngularImpulseQuiver.ScaleFactor;



%Add Legend to Plot
legend('','','','','BASE - LH Angular Impulse','BASE - RH Angular Impulse','ZTCF - LH Angular Impulse','ZTCF - RH Angular Impulse');

%Add a Title
title('LH and RH Angular Impulse on Club');
subtitle('COMPARISON');

%Set View
view(-0.0885,-10.6789);

%Save Figure
savefig('Comparison Quiver Plots/COMPARISON_Quiver Plot - LHRH Angular Impulse on Club');
pause(PauseTime);

%Close Figure
close(719);

%Clear Figure from Workspace
clear LHAngularImpulseQuiver;
clear RHAngularImpulseQuiver;
clear ZTCFLHAngularImpulseQuiver;
clear ZTCFRHAngularImpulseQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
