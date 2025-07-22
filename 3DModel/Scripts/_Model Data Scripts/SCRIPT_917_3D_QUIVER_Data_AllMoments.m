%Generate Club Quiver Plot
figure(917);
run SCRIPT_3D_QuiverClubandShaftData.m;

%Generate LH MOF Quiver Plot
LHMOFQuiver=quiver3(Data.LHx(:,1),Data.LHy(:,1),Data.LHz(:,1),Data.LHMOFonClubGlobal(:,1),Data.LHMOFonClubGlobal(:,2),Data.LHMOFonClubGlobal(:,3));
LHMOFQuiver.LineWidth=1;
LHMOFQuiver.Color=[0 0.5 0];
LHMOFQuiver.MaxHeadSize=0.1;
LHMOFQuiver.AutoScaleFactor=2;

%Generate RH MOF Quiver Plot
RHMOFQuiver=quiver3(Data.RHx(:,1),Data.RHy(:,1),Data.RHz(:,1),Data.RHMOFonClubGlobal(:,1),Data.RHMOFonClubGlobal(:,2),Data.RHMOFonClubGlobal(:,3));
RHMOFQuiver.LineWidth=1;
RHMOFQuiver.Color=[0.5 0 0];
RHMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RHMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/RHMOFQuiver.ScaleFactor;

%Generate RH MOF Quiver Plot
TotalMOFQuiver=quiver3(Data.MPx(:,1),Data.MPy(:,1),Data.MPz(:,1),Data.MPMOFonClubGlobal(:,1),Data.MPMOFonClubGlobal(:,2),Data.MPMOFonClubGlobal(:,3));
TotalMOFQuiver.LineWidth=1;
TotalMOFQuiver.Color=[0 0 0.5];
TotalMOFQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
TotalMOFQuiver.AutoScaleFactor=LHMOFQuiver.ScaleFactor/TotalMOFQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH MOF','RH MOF','Total MOF');

%Add a Title
title('All Moments of Force on Club');
subtitle('Data');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Quiver Plot - Club Moments of Force');
pause(PauseTime);

%Close Figure
close(917);

%Clear Figure from Workspace
clear LHMOFQuiver;
clear RHMOFQuiver;
clear TotalMOFQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;