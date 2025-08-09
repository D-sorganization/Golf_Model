%Generate Club Quiver Plot
figure(722);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate Left H Sum of Moments Quiver Plot
LHSumofMomentsQuiver=quiver3(BASEQ.LHx(:,1),BASEQ.LHy(:,1),BASEQ.LHz(:,1),BASEQ.SumofMomentsLHonClub(:,1),BASEQ.SumofMomentsLHonClub(:,2),BASEQ.SumofMomentsLHonClub(:,3));
LHSumofMomentsQuiver.LineWidth=1;
LHSumofMomentsQuiver.Color=[0 1 0];
LHSumofMomentsQuiver.MaxHeadSize=0.1;
LHSumofMomentsQuiver.AutoScaleFactor=3;

%Generate Right H Sum of Moments Quiver Plot
RHSumofMomentsQuiver=quiver3(BASEQ.RHx(:,1),BASEQ.RHy(:,1),BASEQ.RHz(:,1),BASEQ.SumofMomentsRHonClub(:,1),BASEQ.SumofMomentsRHonClub(:,2),BASEQ.SumofMomentsRHonClub(:,3));
RHSumofMomentsQuiver.LineWidth=1;
RHSumofMomentsQuiver.Color=[.8 .2 0];
RHSumofMomentsQuiver.MaxHeadSize=0.1;
%Correct scaling on Sum of Momentss so that ZTCF  BASE are scaled the same.
RHSumofMomentsQuiver.AutoScaleFactor=LHSumofMomentsQuiver.ScaleFactor/RHSumofMomentsQuiver.ScaleFactor;

%Generate ZTCF Left H Sum of Moments Quiver Plot
ZTCFLHSumofMomentsQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),ZTCFQ.SumofMomentsLHonClub(:,1),ZTCFQ.SumofMomentsLHonClub(:,2),ZTCFQ.SumofMomentsLHonClub(:,3));
ZTCFLHSumofMomentsQuiver.LineWidth=1;
ZTCFLHSumofMomentsQuiver.Color=[0 0.3 0];
ZTCFLHSumofMomentsQuiver.MaxHeadSize=0.1;
%Correct scaling on Sum of Momentss so that ZTCF  BASE are scaled the same.
ZTCFLHSumofMomentsQuiver.AutoScaleFactor=LHSumofMomentsQuiver.ScaleFactor/ZTCFLHSumofMomentsQuiver.ScaleFactor;

%Generate ZTCF Right H Sum of Moments Quiver Plot
ZTCFRHSumofMomentsQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),ZTCFQ.SumofMomentsRHonClub(:,1),ZTCFQ.SumofMomentsRHonClub(:,2),ZTCFQ.SumofMomentsRHonClub(:,3));
ZTCFRHSumofMomentsQuiver.LineWidth=1;
ZTCFRHSumofMomentsQuiver.Color=[.5 .5 0];
ZTCFRHSumofMomentsQuiver.MaxHeadSize=0.1;
%Correct scaling on Sum of Moments so that ZTCF  BASE are scaled the same.
ZTCFRHSumofMomentsQuiver.AutoScaleFactor=LHSumofMomentsQuiver.ScaleFactor/ZTCFRHSumofMomentsQuiver.ScaleFactor;



%Add Legend to Plot
legend('','','','','BASE - LH Sum of Moments','BASE - RH Sum of Moments','ZTCF - LH Sum of Moments','ZTCF - RH Sum of Moments');

%Add a Title
title('LH  RH Sum of Moments on Club');
subtitle('COMPARISON');

%Set View
view(-0.0885,-10.6789);

%Save Figure
savefig('Comparison Quiver Plots/COMPARISON_Quiver Plot - LHRH Sum of Moments on Club');
pause(PauseTime);

%Close Figure
close(722);

%Clear Figure from Workspace
clear LHSumofMomentsQuiver;
clear RHSumofMomentsQuiver;
clear ZTCFLHSumofMomentsQuiver;
clear ZTCFRHSumofMomentsQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HPath;
