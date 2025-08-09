%Generate Club Quiver Plot
figure(516);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate LH MOF Quiver Plot
LHMOFQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),DELTAQ.LHMOFonClubGlobal(:,1),DELTAQ.LHMOFonClubGlobal(:,2),DELTAQ.LHMOFonClubGlobal(:,3));
LHMOFQuiver.LineWidth=1;
LHMOFQuiver.Color=[0 0.5 0];
LHMOFQuiver.MaxHeadSize=0.1;
LHMOFQuiver.AutoScaleFactor=4;

%Generate LH Total Torque Quiver Plot
LHTorqueQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),DELTAQ.LHonClubTGlobal(:,1),DELTAQ.LHonClubTGlobal(:,2),DELTAQ.LHonClubTGlobal(:,3));
LHTorqueQuiver.LineWidth=1;
LHTorqueQuiver.Color=[0 0 1];
LHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
LHTorqueQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/LHTorqueQuiver.ScaleFactor;

%Generate RH MOF Quiver Plot
RHMOFQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),DELTAQ.RHMOFonClubGlobal(:,1),DELTAQ.RHMOFonClubGlobal(:,2),DELTAQ.RHMOFonClubGlobal(:,3));
RHMOFQuiver.LineWidth=1;
RHMOFQuiver.Color=[0.5 0 0];
RHMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/RHMOFQuiver.ScaleFactor;

%Generate RH Total Torque Quiver Plot
RHTorqueQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),DELTAQ.RHonClubTGlobal(:,1),DELTAQ.RHonClubTGlobal(:,2),DELTAQ.RHonClubTGlobal(:,3));
RHTorqueQuiver.LineWidth=1;
RHTorqueQuiver.Color=[1 0 0];
RHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHTorqueQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/RHTorqueQuiver.ScaleFactor;

%Generate Total MOF Quiver Plot
TotalMOFQuiver=quiver3(ZTCFQ.MPx(:,1),ZTCFQ.MPy(:,1),ZTCFQ.MPz(:,1),DELTAQ.MPMOFonClubGlobal(:,1),DELTAQ.MPMOFonClubGlobal(:,2),DELTAQ.MPMOFonClubGlobal(:,3));
TotalMOFQuiver.LineWidth=1;
TotalMOFQuiver.Color=[0 0 0.5];
TotalMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
TotalMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/TotalMOFQuiver.ScaleFactor;

%Generate Total Torque Quiver Plot
NetTorqueQuiver=quiver3(ZTCFQ.MPx(:,1),ZTCFQ.MPy(:,1),ZTCFQ.MPz(:,1),DELTAQ.TotalHandTorqueGlobal(:,1),DELTAQ.TotalHandTorqueGlobal(:,2),DELTAQ.TotalHandTorqueGlobal(:,3));
NetTorqueQuiver.LineWidth=1;
NetTorqueQuiver.Color=[0 1 0];
NetTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
NetTorqueQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/NetTorqueQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH MOF','LH Torque','RH MOF','RH Torque','Total MOF','Net Torque');

%Add a Title
title('All Torques and Moments on Club');
subtitle('DELTA');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('Delta Quiver Plots/DELTA_Quiver Plot - Torques and Moments');
pause(PauseTime);

%Close Figure
close(516);

%Clear Figure from Workspace
clear LHTorqueQuiver;
clear RHTorqueQuiver;
clear NetTorqueQuiver;
clear LHMOFQuiver;
clear RHMOFQuiver;
clear TotalMOFQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;