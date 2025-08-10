%Generate Club Quiver Plot
figure(951);
run SCRIPT_3D_QuiverClubandShaftData.m;
hold on;

%Generate LW Constraint Torque Plot
LWConstraintTorqueQuiver=quiver3(Data.LWgx(:,1),Data.LWgy(:,1),Data.LWgz(:,1),Data.LWConstraintTorque(:,1),Data.LWConstraintTorque(:,2),Data.LWConstraintTorque(:,3));
LWConstraintTorqueQuiver.LineWidth=1;
LWConstraintTorqueQuiver.Color=[0 0 1];
LWConstraintTorqueQuiver.AutoScaleFactor=12;
LWConstraintTorqueQuiver.MaxHeadSize=0.1;

%Generate RW Constraint Torque Quiver Plot
RWConstraintTorqueQuiver=quiver3(Data.RWgx(:,1),Data.RWgy(:,1),Data.RWgz(:,1),Data.RWConstraintTorque(:,1),Data.RWConstraintTorque(:,2),Data.RWConstraintTorque(:,3));
RWConstraintTorqueQuiver.LineWidth=1;
RWConstraintTorqueQuiver.Color=[0 0 1];
RWConstraintTorqueQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RWConstraintTorqueQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/RWConstraintTorqueQuiver.ScaleFactor;

%Generate LW Input Torque Quiver Plot
LWJointTorqueInputGlobalQuiver=quiver3(Data.LWgx(:,1),Data.LWgy(:,1),Data.LWgz(:,1),Data.LWJointTorqueInputGlobal(:,1),Data.LWJointTorqueInputGlobal(:,2),Data.LWJointTorqueInputGlobal(:,3));
LWJointTorqueInputGlobalQuiver.LineWidth=1;
LWJointTorqueInputGlobalQuiver.Color=[1 0 0];
LWJointTorqueInputGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
LWJointTorqueInputGlobalQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/LWJointTorqueInputGlobalQuiver.ScaleFactor;

%Generate RW Input Torque Quiver Plot
RWJointTorqueInputGlobalQuiver=quiver3(Data.RWgx(:,1),Data.RWgy(:,1),Data.RWgz(:,1),Data.RWJointTorqueInputGlobal(:,1),Data.RWJointTorqueInputGlobal(:,2),Data.RWJointTorqueInputGlobal(:,3));
RWJointTorqueInputGlobalQuiver.LineWidth=1;
RWJointTorqueInputGlobalQuiver.Color=[1 0 0];
RWJointTorqueInputGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RWJointTorqueInputGlobalQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/RWJointTorqueInputGlobalQuiver.ScaleFactor;

%Generate LW Total Torque Quiver Plot
LWTorqueGlobalQuiver=quiver3(Data.LWgx(:,1),Data.LWgy(:,1),Data.LWgz(:,1),Data.LWTorqueGlobal(:,1),Data.LWTorqueGlobal(:,2),Data.LWTorqueGlobal(:,3));
LWTorqueGlobalQuiver.LineWidth=1;
LWTorqueGlobalQuiver.Color=[0 1 0];
LWTorqueGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
LWTorqueGlobalQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/LWTorqueGlobalQuiver.ScaleFactor;

%Generate RW Total Torque Quiver Plot
RWTorqueGlobalQuiver=quiver3(Data.RWgx(:,1),Data.RWgy(:,1),Data.RWgz(:,1),Data.RWTorqueGlobal(:,1),Data.RWTorqueGlobal(:,2),Data.RWTorqueGlobal(:,3));
RWTorqueGlobalQuiver.LineWidth=1;
RWTorqueGlobalQuiver.Color=[0 1 0];
RWTorqueGlobalQuiver.MaxHeadSize=0.1;
%Correct scaling so that all are scaled the same.
RWTorqueGlobalQuiver.AutoScaleFactor=LWConstraintTorqueQuiver.ScaleFactor/RWTorqueGlobalQuiver.ScaleFactor;

%Add Legend to Plot
legend('','','','','LW Constraint Torque','RW Constraint Torque','LW Input Torque','RW Input Torque','LW Total Torque','RW Total Torque');

%Add a Title
title('Torque Input vs. Torque Output - Wrist Constraint Torques');
subtitle('Data');

%Set View
view(-0.186585735654603,37.199999973925109);

%Save Figure
cd(matlabdrive);
cd '3DModel';
savefig('Scripts/_Model Data Scripts/Data Quiver Plots/Quiver Plot - Torque In vs Out');
pause(PauseTime);

%Close Figure
% close(951);

%Clear Figure from Workspace
clear LWConstraintTorqueQuiver;
clear RWConstraintTorqueQuiver;
clear LWJointTorqueInputGlobalQuiver;
clear RWJointTorqueInputGlobalQuiver;
clear LWTorqueGlobalQuiver;
clear RWTorqueGlobalQuiver;
clear NetTorqueQuiver;
clear Grip;
clear Shaft;
clear ClubPath;
clear HandPath;
