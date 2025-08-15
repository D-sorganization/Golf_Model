%Generate Club Quiver Plot
figure(916);
run SCRIPT_3D_QuiverClubandShaftData.m;

%Generate LH MOF Quiver Plot
LHMOFQuiver=quiver3(Data.LHx(:,1),Data.LHy(:,1),Data.LHz(:,1),Data.LHMOFonClubGlobal(:,1),Data.LHMOFonClubGlobal(:,2),Data.LHMOFonClubGlobal(:,3));
LHMOFQuiver.LineWidth=1;
LHMOFQuiver.Color=[0 0.5 0];
LHMOFQuiver.MaxHeadSize=0.1;
LHMOFQuiver.AutoScaleFactor=4;

%Generate LH Total Torque Quiver Plot
LHTorqueQuiver=quiver3(Data.LHx(:,1),Data.LHy(:,1),Data.LHz(:,1),Data.LHonClubTGlobal(:,1),Data.LHonClubTGlobal(:,2),Data.LHonClubTGlobal(:,3));
LHTorqueQuiver.LineWidth=1;
LHTorqueQuiver.Color=[0 0 1];
LHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
LHTorqueQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/LHTorqueQuiver.ScaleFactor;

%Generate RH MOF Quiver Plot
RHMOFQuiver=quiver3(Data.RHx(:,1),Data.RHy(:,1),Data.RHz(:,1),Data.RHMOFonClubGlobal(:,1),Data.RHMOFonClubGlobal(:,2),Data.RHMOFonClubGlobal(:,3));
RHMOFQuiver.LineWidth=1;
RHMOFQuiver.Color=[0.5 0 0];
RHMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/RHMOFQuiver.ScaleFactor;

%Generate RH Total Torque Quiver Plot
RHTorqueQuiver=quiver3(Data.RHx(:,1),Data.RHy(:,1),Data.RHz(:,1),Data.RHonClubTGlobal(:,1),Data.RHonClubTGlobal(:,2),Data.RHonClubTGlobal(:,3));
RHTorqueQuiver.LineWidth=1;
RHTorqueQuiver.Color=[1 0 0];
RHTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHTorqueQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/RHTorqueQuiver.ScaleFactor;

%Generate Total MOF Quiver Plot
TotalMOFQuiver=quiver3(Data.MPx(:,1),Data.MPy(:,1),Data.MPz(:,1),Data.MPMOFonClubGlobal(:,1),Data.MPMOFonClubGlobal(:,2),Data.MPMOFonClubGlobal(:,3));
TotalMOFQuiver.LineWidth=1;
TotalMOFQuiver.Color=[0 0 0.5];
TotalMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
TotalMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/TotalMOFQuiver.ScaleFactor;

%Generate Total Torque Quiver Plot
NetTorqueQuiver=quiver3(Data.MPx(:,1),Data.MPy(:,1),Data.MPz(:,1),Data.TotalHandTorqueGlobal(:,1),Data.TotalHandTorqueGlobal(:,2),Data.TotalHandTorqueGlobal(:,3));
NetTorqueQuiver.LineWidth=1;
NetTorqueQuiver.Color=[0 1 0];
NetTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
NetTorqueQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/NetTorqueQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH MOF','LH Torque','RH MOF','RH Torque','Total MOF','Net Torque');

%Add a Title
title('All Torques and Moments on Club');
subtitle('Data');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Quiver Plot - Torques and Moments');
pause(PauseTime);

%Close Figure
close(916);

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
