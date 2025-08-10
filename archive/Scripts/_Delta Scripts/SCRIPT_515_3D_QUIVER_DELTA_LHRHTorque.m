%Generate Club Quiver Plot
figure(515);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate LH Total Torque Quiver Plot
LHTorqueQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),DELTAQ.LHonClubTGlobal(:,1),DELTAQ.LHonClubTGlobal(:,2),DELTAQ.LHonClubTGlobal(:,3));
LHTorqueQuiver.LineWidth=1;
LHTorqueQuiver.Color=[0 0 1];
LHTorqueQuiver.AutoScaleFactor=2;
LHTorqueQuiver.MaxHeadSize=0.1;

%Generate RH Total Torque Quiver Plot
RHTorqueQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),DELTAQ.RHonClubTGlobal(:,1),DELTAQ.RHonClubTGlobal(:,2),DELTAQ.RHonClubTGlobal(:,3));
RHTorqueQuiver.LineWidth=1;
RHTorqueQuiver.Color=[1 0 0];
RHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/RHTorqueQuiver.ScaleFactor;

%Generate Total Torque Quiver Plot
NetTorqueQuiver=quiver3(ZTCFQ.MPx(:,1),ZTCFQ.MPy(:,1),ZTCFQ.MPz(:,1),DELTAQ.TotalHandTorqueGlobal(:,1),DELTAQ.TotalHandTorqueGlobal(:,2),DELTAQ.TotalHandTorqueGlobal(:,3));
NetTorqueQuiver.LineWidth=1;
NetTorqueQuiver.Color=[0 1 0];
NetTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
NetTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/NetTorqueQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Torque','RH Torque','Net Torque');

%Add a Title
title('Total Torque');
subtitle('DELTA');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('Delta Quiver Plots/DELTA_Quiver Plot - Hand Torques');
pause(PauseTime);

%Close Figure
close(515);

%Clear Figure from Workspace
clear LHTorqueQuiver;
clear RHTorqueQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
