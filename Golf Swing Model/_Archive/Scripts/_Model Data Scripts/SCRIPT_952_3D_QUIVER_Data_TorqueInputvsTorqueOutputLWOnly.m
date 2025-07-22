%Generate Club Quiver Plot
figure(952);
run SCRIPT_3D_QuiverClubandShaftData.m;
hold on;

%Generate LW Constraint Torque Plot
LWConstraintTorqueQuiver=quiver3(Data.LWgx(:,1),Data.LWgy(:,1),Data.LWgz(:,1),Data.LWConstraintTorque(:,1),Data.LWConstraintTorque(:,2),Data.LWConstraintTorque(:,3));
LWConstraintTorqueQuiver.LineWidth=1;
LWConstraintTorqueQuiver.Color=[0 0 1];
LWConstraintTorqueQuiver.AutoScaleFactor=12;
LWConstraintTorqueQuiver.MaxHeadSize=0.1;

%Generate LW Input Torque Quiver Plot
LWJointTorqueInputGlobalQuiver=quiver3(Data.LWgx(:,1),Data.LWgy(:,1),Data.LWgz(:,1),Data.LWJointTorqueInputGlobal(:,1),Data.LWJointTorqueInputGlobal(:,2),Data.LWJointTorqueInputGlobal(:,3));
LWJointTorqueInputGlobalQuiver.LineWidth=1;
LWJointTorqueInputGlobalQuiver.Color=[1 0 0];
LWJointTorqueInputGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
LWJointTorqueInputGlobalQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/LWJointTorqueInputGlobalQuiver.ScaleFactor;

%Generate LW Total Torque Quiver Plot
LWTorqueGlobalQuiver=quiver3(Data.LWgx(:,1),Data.LWgy(:,1),Data.LWgz(:,1),Data.LWTorqueGlobal(:,1),Data.LWTorqueGlobal(:,2),Data.LWTorqueGlobal(:,3));
LWTorqueGlobalQuiver.LineWidth=1;
LWTorqueGlobalQuiver.Color=[0 1 0];
LWTorqueGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
LWTorqueGlobalQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/LWTorqueGlobalQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LW Constraint Torque','LW Input Torque','LW Total Torque');

%Add a Title
title('Torque Input vs. Torque Output - Wrist Constraint Torques LW Only');
subtitle('Data');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Quiver Plot - Torque In vs Out LW Only');
pause(PauseTime);

%Close Figure
% close(952);

%Clear Figure from Workspace
clear LWConstraintTorqueQuiver;
clear LWJointTorqueInputGlobalQuiver;
clear LWTorqueGlobalQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;