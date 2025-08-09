%Generate Club Quiver Plot
figure(815);
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

%Generate LH Total Force Quiver Plot for Delta
DeltaLHForceQuiver=quiver3(BASEQ.LHx(:,1),BASEQ.LHy(:,1),BASEQ.LHz(:,1),DELTAQ.LHonClubFGlobal(:,1),DELTAQ.LHonClubFGlobal(:,2),DELTAQ.LHonClubFGlobal(:,3));
DeltaLHForceQuiver.LineWidth=1;
DeltaLHForceQuiver.Color=[0 0 0.5];
DeltaLHForceQuiver.MaxHeadSize=0.1;
DeltaLHForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/DeltaLHForceQuiver.ScaleFactor;

%Generate RH Total Force Quiver Plot for Delta
DeltaRHForceQuiver=quiver3(BASEQ.RHx(:,1),BASEQ.RHy(:,1),BASEQ.RHz(:,1),DELTAQ.RHonClubFGlobal(:,1),DELTAQ.RHonClubFGlobal(:,2),DELTAQ.RHonClubFGlobal(:,3));
DeltaRHForceQuiver.LineWidth=1;
DeltaRHForceQuiver.Color=[0.5 0 0];
DeltaRHForceQuiver.MaxHeadSize=0.1;
%Correct scaling so that LH and RH are scaled the same.
DeltaRHForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/DeltaRHForceQuiver.ScaleFactor;

%Generate Total Force Quiver Plot for Delta
DeltaNetForceQuiver=quiver3(BASEQ.MPx(:,1),BASEQ.MPy(:,1),BASEQ.MPz(:,1),DELTAQ.TotalHandForceGlobal(:,1),DELTAQ.TotalHandForceGlobal(:,2),DELTAQ.TotalHandForceGlobal(:,3));
DeltaNetForceQuiver.LineWidth=1;
DeltaNetForceQuiver.Color=[0 0.5 0];
DeltaNetForceQuiver.MaxHeadSize=0.1;
%Correct scaling so that LH and RH are scaled the same.
DeltaNetForceQuiver.AutoScaleFactor=LHForceQuiver.ScaleFactor/DeltaNetForceQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','ZVCF LH Force','ZVCF RH Force','ZVCF Net Force','Delta LH Force','Delta RH Force','Delta Net Force');

%Add a Title
title('Hand Forces');
subtitle('ZVCF and Delta Comparison');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
savefig('ZVCF Quiver Plots/ZVCF_Quiver Plot - Hand Forces ZVCF Comparison to Delta');
PauseTime=1;
pause(PauseTime);

%Close Figure
close(815);

%Clear Figure from Workspace
clear LHForceQuiver;
clear RHForceQuiver;
clear NetForceQuiver;
clear DeltaLHForceQuiver;
clear DeltaRHForceQuiver;
clear DeltaNetForceQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
clear PauseTime;
