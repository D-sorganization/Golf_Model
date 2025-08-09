%Generate Club Quiver Plot
figure(514);
run SCRIPT_QuiverClubandShaftBaseData.m;

%Generate LH Total Force Quiver Plot
LHForceQuiver=quiver3(ZTCFQ.LHx(:,1),ZTCFQ.LHy(:,1),ZTCFQ.LHz(:,1),DELTAQ.LHonClubFGlobal(:,1),DELTAQ.LHonClubFGlobal(:,2),DELTAQ.LHonClubFGlobal(:,3));
LHForceQuiver.LineWidth=1;
LHForceQuiver.Color=[0 0 1];
LHForceQuiver.AutoScaleFactor=2;
LHForceQuiver.MaxHeadSize=0.1;

%Generate RH Total Force Quiver Plot
RHForceQuiver=quiver3(ZTCFQ.RHx(:,1),ZTCFQ.RHy(:,1),ZTCFQ.RHz(:,1),DELTAQ.RHonClubFGlobal(:,1),DELTAQ.RHonClubFGlobal(:,2),DELTAQ.RHonClubFGlobal(:,3));
RHForceQuiver.LineWidth=1;
RHForceQuiver.Color=[1 0 0];
RHForceQuiver.MaxHeadSize=0.1;
%Correct scaling so that LH and RH are scaled the same.
RHForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/RHForceQuiver.ScaleFactor;

%Generate Total Force Quiver Plot
NetForceQuiver=quiver3(ZTCFQ.MPx(:,1),ZTCFQ.MPy(:,1),ZTCFQ.MPz(:,1),DELTAQ.TotalHandForceGlobal(:,1),DELTAQ.TotalHandForceGlobal(:,2),DELTAQ.TotalHandForceGlobal(:,3));
NetForceQuiver.LineWidth=1;
NetForceQuiver.Color=[0 1 0];
NetForceQuiver.MaxHeadSize=0.1;
%Correct scaling so that LH and RH are scaled the same.
NetForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/NetForceQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LH Force','RH Force','Net Force');

%Add a Title
title('Hand Forces');
subtitle('DELTA');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('Delta Quiver Plots/DELTA_Quiver Plot - Hand Forces');
pause(PauseTime);

%Close Figure
close(514);

%Clear Figure from Workspace
clear LHForceQuiver;
clear RHForceQuiver;
clear NetForceQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;