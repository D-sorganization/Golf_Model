%Generate Club Quiver Plot
figure(915);
run SCRIPT_3D_QuiverClubandShaftData.m;

%Generate LH Total Torque Quiver Plot
LHTorqueQuiver=quiver3(Data.LHx(:,1),Data.LHy(:,1),Data.LHz(:,1),Data.LHonClubTGlobal(:,1),Data.LHonClubTGlobal(:,2),Data.LHonClubTGlobal(:,3));
LHTorqueQuiver.LineWidth=1;
LHTorqueQuiver.Color=[0 0 1];
LHTorqueQuiver.AutoScaleFactor=2;
LHTorqueQuiver.MaxHeadSize=0.1;

%Generate RH Total Torque Quiver Plot
RHTorqueQuiver=quiver3(Data.RHx(:,1),Data.RHy(:,1),Data.RHz(:,1),Data.RHonClubTGlobal(:,1),Data.RHonClubTGlobal(:,2),Data.RHonClubTGlobal(:,3));
RHTorqueQuiver.LineWidth=1;
RHTorqueQuiver.Color=[1 0 0];
RHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/RHTorqueQuiver.ScaleFactor;

%Generate Total Torque Quiver Plot
NetTorqueQuiver=quiver3(Data.MPx(:,1),Data.MPy(:,1),Data.MPz(:,1),Data.TotalHandTorqueGlobal(:,1),Data.TotalHandTorqueGlobal(:,2),Data.TotalHandTorqueGlobal(:,3));
NetTorqueQuiver.LineWidth=1;
NetTorqueQuiver.Color=[0 1 0];
NetTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
NetTorqueQuiver.AutoScaleFactor=LHTorqueQuiver.ScaleFactor/NetTorqueQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Torque','RH Torque','Net Torque');

%Add a Title
title('Total Torque');
subtitle('Data');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Quiver Plot - Hand Torques');
pause(PauseTime);

%Close Figure
close(915);

%Clear Figure from Workspace
clear LHTorqueQuiver;
clear RHTorqueQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;