%Generate Club Quiver Plot
figure(315);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate LH Total Torque Quiver Plot
LHTorqueQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),ZTCFQ.LHonClubTGlobal(:,1),ZTCFQ.LHonClubTGlobal(:,2),ZTCFQ.LHonClubTGlobal(:,3));
LHTorqueQuiver.LineWidth=1;
LHTorqueQuiver.Color=[0 0 1];
LHTorqueQuiver.AutoScaleFactor=2;
LHTorqueQuiver.MaxHeadSize=0.1;

%Generate RH Total Torque Quiver Plot
RHTorqueQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),ZTCFQ.RHonClubTGlobal(:,1),ZTCFQ.RHonClubTGlobal(:,2),ZTCFQ.RHonClubTGlobal(:,3));
RHTorqueQuiver.LineWidth=1;
RHTorqueQuiver.Color=[1 0 0];
RHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/RHTorqueQuiver.ScaleFactor;

%Generate Total Torque Quiver Plot
NetTorqueQuiver=quiver3(ZTCFQ.MPx(:,1),ZTCFQ.MPy(:,1),ZTCFQ.MPz(:,1),ZTCFQ.TotalHandTorqueGlobal(:,1),ZTCFQ.TotalHandTorqueGlobal(:,2),ZTCFQ.TotalHandTorqueGlobal(:,3));
NetTorqueQuiver.LineWidth=1;
NetTorqueQuiver.Color=[0 1 0];
NetTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
NetTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/NetTorqueQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Torque','RH Torque','Net Torque');

%Add a Title
title('Total Torque');
subtitle('ZTCF');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('ZTCF Quiver Plots/ZTCF_Quiver Plot - Hand Torques');
pause(PauseTime);

%Close Figure
close(315);

%Clear Figure from Workspace
clear LHTorqueQuiver;
clear RHTorqueQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
