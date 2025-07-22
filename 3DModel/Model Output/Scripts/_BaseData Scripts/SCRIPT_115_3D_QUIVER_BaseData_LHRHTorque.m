%Generate Club Quiver Plot
figure(115);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate LH Total Torque Quiver Plot
LHTorqueQuiver=quiver3(BASEQ.LHx(:,1),BASEQ.LHy(:,1),BASEQ.LHz(:,1),BASEQ.LHonClubTGlobal(:,1),BASEQ.LHonClubTGlobal(:,2),BASEQ.LHonClubTGlobal(:,3));
LHTorqueQuiver.LineWidth=1;
LHTorqueQuiver.Color=[0 0 1];
LHTorqueQuiver.AutoScaleFactor=2;
LHTorqueQuiver.MaxHeadSize=0.1;

%Generate RH Total Torque Quiver Plot
RHTorqueQuiver=quiver3(BASEQ.RHx(:,1),BASEQ.RHy(:,1),BASEQ.RHz(:,1),BASEQ.RHonClubTGlobal(:,1),BASEQ.RHonClubTGlobal(:,2),BASEQ.RHonClubTGlobal(:,3));
RHTorqueQuiver.LineWidth=1;
RHTorqueQuiver.Color=[1 0 0];
RHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/RHTorqueQuiver.ScaleFactor;

%Generate Total Torque Quiver Plot
NetTorqueQuiver=quiver3(BASEQ.MPx(:,1),BASEQ.MPy(:,1),BASEQ.MPz(:,1),BASEQ.TotalHandTorqueGlobal(:,1),BASEQ.TotalHandTorqueGlobal(:,2),BASEQ.TotalHandTorqueGlobal(:,3));
NetTorqueQuiver.LineWidth=1;
NetTorqueQuiver.Color=[0 1 0];
NetTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
NetTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/NetTorqueQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Torque','RH Torque','Net Torque');

%Add a Title
title('Total Torque');
subtitle('BASE');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('BaseData Quiver Plots//BASE_Quiver Plot - Hand Torques');
pause(PauseTime);

%Close Figure
close(115);

%Clear Figure from Workspace
clear LHTorqueQuiver;
clear RHTorqueQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;