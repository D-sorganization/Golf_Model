%Generate Club Quiver Plot
figure(343);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate Left Hand Angular Impulse Quiver Plot
LHAngularImpulseQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),ZTCFQ.LHAngularImpulseonClub(:,1),ZTCFQ.LHAngularImpulseonClub(:,2),ZTCFQ.LHAngularImpulseonClub(:,3));
LHAngularImpulseQuiver.LineWidth=1;
LHAngularImpulseQuiver.Color=[0 1 0];
LHAngularImpulseQuiver.MaxHeadSize=0.1;
LHAngularImpulseQuiver.AutoScaleFactor=3;

%Generate Right Hand Angular Impulse Quiver Plot
RHAngularImpulseQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),ZTCFQ.RHAngularImpulseonClub(:,1),ZTCFQ.RHAngularImpulseonClub(:,2),ZTCFQ.RHAngularImpulseonClub(:,3));
RHAngularImpulseQuiver.LineWidth=1;
RHAngularImpulseQuiver.Color=[.8 .2 0];
RHAngularImpulseQuiver.MaxHeadSize=0.1;
%Correct scaling on Angular Impulses so that LH and RH are scaled the same.
RHAngularImpulseQuiver.AutoScaleFactor=LHAngularImpulseQuiver.ScaleFactor/RHAngularImpulseQuiver.ScaleFactor;


%Add Legend to Plot
legend('','','','','LH Angular Impulse','RH Angular Impulse');

%Add a Title
title('LH and RH Angular Impulse on Club');
subtitle('ZTCF');

%Set View
view(-0.0885,-10.6789);

%Save Figure
savefig('ZTCF Quiver Plots/ZTCF_Quiver Plot - LHRH Angular Impulse on Club');
pause(PauseTime);

%Close Figure
close(343);

%Clear Figure from Workspace
clear LHAngularImpulseQuiver;
clear RHAngularImpulseQuiver;
clear ZTCFLHAngularImpulseQuiver;
clear ZTCFRHAngularImpulseQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
