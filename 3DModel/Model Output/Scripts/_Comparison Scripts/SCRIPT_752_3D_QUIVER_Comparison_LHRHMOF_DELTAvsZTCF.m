%Generate Club Quiver Plot
figure(752);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate DELTA Left Hand Moment of Force Quiver Plot
LHSumofMomentsQuiver=quiver3(BASEQ.LHx(:,1),BASEQ.LHy(:,1),BASEQ.LHz(:,1),DELTAQ.LHMOFonClubGlobal(:,1),DELTAQ.LHMOFonClubGlobal(:,2),DELTAQ.LHMOFonClubGlobal(:,3));
LHSumofMomentsQuiver.LineWidth=1;
LHSumofMomentsQuiver.Color=[0 1 0];
LHSumofMomentsQuiver.MaxHeadSize=0.1;
LHSumofMomentsQuiver.AutoScaleFactor=3;

%Generate DELTA Right Hand Moment of Force Quiver Plot
RHSumofMomentsQuiver=quiver3(BASEQ.RHx(:,1),BASEQ.RHy(:,1),BASEQ.RHz(:,1),DELTAQ.RHMOFonClubGlobal(:,1),DELTAQ.RHMOFonClubGlobal(:,2),DELTAQ.RHMOFonClubGlobal(:,3));
RHSumofMomentsQuiver.LineWidth=1;
RHSumofMomentsQuiver.Color=[.8 .2 0];
RHSumofMomentsQuiver.MaxHeadSize=0.1;
%Correct scaling on Moment of Forces so that ZTCF and DELTA are scaled the same.
RHSumofMomentsQuiver.AutoScaleFactor=LHSumofMomentsQuiver.ScaleFactor/RHSumofMomentsQuiver.ScaleFactor;

%Generate ZTCF Left Hand Moment of Force Quiver Plot
ZTCFLHSumofMomentsQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),ZTCFQ.LHMOFonClubGlobal(:,1),ZTCFQ.LHMOFonClubGlobal(:,2),ZTCFQ.LHMOFonClubGlobal(:,3));
ZTCFLHSumofMomentsQuiver.LineWidth=1;
ZTCFLHSumofMomentsQuiver.Color=[0 0.3 0];
ZTCFLHSumofMomentsQuiver.MaxHeadSize=0.1;
%Correct scaling on Moment of Forces so that ZTCF and DELTA are scaled the same.
ZTCFLHSumofMomentsQuiver.AutoScaleFactor=LHSumofMomentsQuiver.ScaleFactor/ZTCFLHSumofMomentsQuiver.ScaleFactor;

%Generate ZTCF Right Hand Moment of Force Quiver Plot
ZTCFRHSumofMomentsQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),ZTCFQ.RHMOFonClubGlobal(:,1),ZTCFQ.RHMOFonClubGlobal(:,2),ZTCFQ.RHMOFonClubGlobal(:,3));
ZTCFRHSumofMomentsQuiver.LineWidth=1;
ZTCFRHSumofMomentsQuiver.Color=[.5 .5 0];
ZTCFRHSumofMomentsQuiver.MaxHeadSize=0.1;
%Correct scaling on Moment of Force so that ZTCF and DELTA are scaled the same.
ZTCFRHSumofMomentsQuiver.AutoScaleFactor=LHSumofMomentsQuiver.ScaleFactor/ZTCFRHSumofMomentsQuiver.ScaleFactor;



%Add Legend to Plot
legend('','','','','DELTA - LH Moment of Force','DELTA - RH Moment of Force','ZTCF - LH Moment of Force','ZTCF - RH Moment of Force');

%Add a Title
title('LH and RH Moment of Force DELTA vs. ZTCF');
subtitle('COMPARISON');

%Set View
view(-0.0885,-10.6789);

%Save Figure
savefig('Comparison Quiver Plots/COMPARISON_Quiver Plot - LHRH Moment of Force Delta vs ZTCF');
pause(PauseTime);

%Close Figure
close(752);

%Clear Figure from Workspace
clear LHSumofMomentsQuiver;
clear RHSumofMomentsQuiver;
clear ZTCFLHSumofMomentsQuiver;
clear ZTCFRHSumofMomentsQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
