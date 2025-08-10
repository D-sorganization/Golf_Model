%Generate Club Quiver Plot
figure(953);
run SCRIPT_3D_QuiverClubandShaftData.m;
hold on;

%Generate RW Constraint Torque Plot
RWConstraintTorqueQuiver=quiver3(Data.RWgx(:,1),Data.RWgy(:,1),Data.RWgz(:,1),Data.RWConstraintTorque(:,1),Data.RWConstraintTorque(:,2),Data.RWConstraintTorque(:,3));
RWConstraintTorqueQuiver.LineWidth=1;
RWConstraintTorqueQuiver.Color=[0 0 1];
RWConstraintTorqueQuiver.AutoScaleFactor=12;
RWConstraintTorqueQuiver.MaxHeadSize=0.1;

%Generate RW Input Torque Quiver Plot
RWJointTorqueInputGlobalQuiver=quiver3(Data.RWgx(:,1),Data.RWgy(:,1),Data.RWgz(:,1),Data.RWJointTorqueInputGlobal(:,1),Data.RWJointTorqueInputGlobal(:,2),Data.RWJointTorqueInputGlobal(:,3));
RWJointTorqueInputGlobalQuiver.LineWidth=1;
RWJointTorqueInputGlobalQuiver.Color=[1 0 0];
RWJointTorqueInputGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RWJointTorqueInputGlobalQuiver.AutoScaleFactor=RWConstraintTorqueQuiver.ScaleFactor/RWJointTorqueInputGlobalQuiver.ScaleFactor;

%Generate RW Total Torque Quiver Plot
RWTorqueGlobalQuiver=quiver3(Data.RWgx(:,1),Data.RWgy(:,1),Data.RWgz(:,1),Data.RWTorqueGlobal(:,1),Data.RWTorqueGlobal(:,2),Data.RWTorqueGlobal(:,3));
RWTorqueGlobalQuiver.LineWidth=1;
RWTorqueGlobalQuiver.Color=[0 1 0];
RWTorqueGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RWTorqueGlobalQuiver.AutoScaleFactor=RWConstraintTorqueQuiver.ScaleFactor/RWTorqueGlobalQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','RW Constraint Torque','RW Input Torque','RW Total Torque');

%Add a Title
title('Torque Input vs. Torque Output - Constraint Torques RW Only');
subtitle('Data');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Quiver Plot - Torque In vs Out RW Only');
pause(PauseTime);

%Close Figure
% close(953);

%Clear Figure from Workspace
clear RWConstraintTorqueQuiver;
clear RWJointTorqueInputGlobalQuiver;
clear RWTorqueGlobalQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
