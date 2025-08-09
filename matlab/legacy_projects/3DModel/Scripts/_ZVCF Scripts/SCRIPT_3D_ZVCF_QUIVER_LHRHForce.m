%Generate Club Quiver Plot
figure(814);
run SCRIPT_QuiverClubandShaftBaseData_3D.m;

%Generate LH Total Force Quiver Plot
LHForceQuiver=quiver3(ZVCFTableQ.LHx(:,1),ZVCFTableQ.LHy(:,1),ZVCFTableQ.LHz(:,1),ZVCFTableQ.LHonClubFGlobal(:,1),ZVCFTableQ.LHonClubFGlobal(:,2),ZVCFTableQ.LHonClubFGlobal(:,3));
LHForceQuiver.LineWidth=1;
LHForceQuiver.Color=[0 0 1];
LHForceQuiver.AutoScaleFactor=2;
LHForceQuiver.MaxHeadSize=0.1;

%Generate RH Total Force Quiver Plot
RHForceQuiver=quiver3(ZVCFTableQ.RHx(:,1),ZVCFTableQ.RHy(:,1),ZVCFTableQ.RHz(:,1),ZVCFTableQ.RHonClubFGlobal(:,1),ZVCFTableQ.RHonClubFGlobal(:,2),ZVCFTableQ.RHonClubFGlobal(:,3));
RHForceQuiver.LineWidth=1;
RHForceQuiver.Color=[1 0 0];
RHForceQuiver.MaxHeadSize=0.1;
%Correct scaling so that LH and RH are scaled the same.
RHForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/RHForceQuiver.ScaleFactor;

%Generate Total Force Quiver Plot
NetForceQuiver=quiver3(ZVCFTableQ.MPx(:,1),ZVCFTableQ.MPy(:,1),ZVCFTableQ.MPz(:,1),ZVCFTableQ.TotalHandForceGlobal(:,1),ZVCFTableQ.TotalHandForceGlobal(:,2),ZVCFTableQ.TotalHandForceGlobal(:,3));
NetForceQuiver.LineWidth=1;
NetForceQuiver.Color=[0 1 0];
NetForceQuiver.MaxHeadSize=0.1;
%Correct scaling so that LH and RH are scaled the same.
NetForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/NetForceQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Force','RH Force','Net Force');

%Add a Title
title('Hand Forces');
subtitle('ZVCF');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('ZVCF Quiver Plots/ZVCF_Quiver Plot - Hand Forces');
%PauseTime=1;
pause(PauseTime);

%Close Figure
close(814);

%Clear Figure from Workspace
clear LHForceQuiver;
clear RHForceQuiver;
clear NetForceQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
clear PauseTime;
