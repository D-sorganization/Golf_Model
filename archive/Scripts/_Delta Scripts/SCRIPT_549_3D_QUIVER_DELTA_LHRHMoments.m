%Generate Club Quiver Plot
figure(549);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate LH MOF Quiver Plot
LHMOFQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),DELTAQ.LHMOFonClubGlobal(:,1),DELTAQ.LHMOFonClubGlobal(:,2),DELTAQ.LHMOFonClubGlobal(:,3));
LHMOFQuiver.LineWidth=1;
LHMOFQuiver.Color=[0 0.5 0];
LHMOFQuiver.MaxHeadSize=0.1;
LHMOFQuiver.AutoScaleFactor=10;

%Generate RH MOF Quiver Plot
RHMOFQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),DELTAQ.RHMOFonClubGlobal(:,1),DELTAQ.RHMOFonClubGlobal(:,2),DELTAQ.RHMOFonClubGlobal(:,3));
RHMOFQuiver.LineWidth=1;
RHMOFQuiver.Color=[0.5 0 0];
RHMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/RHMOFQuiver.ScaleFactor;

%Generate Total MOF Quiver Plot
%TotalMOFQuiver=quiver3(ZTCFQ.MPx(:,1),ZTCFQ.MPy(:,1),ZTCFQ.MPz(:,1),DELTAQ.MPMOFonClubGlobal(:,1),DELTAQ.MPMOFonClubGlobal(:,2),DELTAQ.MPMOFonClubGlobal(:,3));
%TotalMOFQuiver.LineWidth=1;
%TotalMOFQuiver.Color=[0 0 0.5];
%TotalMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
%TotalMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/TotalMOFQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH MOF','RH MOF');

%Add a Title
title('LHRH Moments of Force on Club');
subtitle('DELTA');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('Delta Quiver Plots/DELTA_Quiver Plot - LHRH Moments of Force');
pause(PauseTime);

%Close Figure
close(549);

%Clear Figure from Workspace
clear LHMOFQuiver;
clear RHMOFQuiver;
clear TotalMOFQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;