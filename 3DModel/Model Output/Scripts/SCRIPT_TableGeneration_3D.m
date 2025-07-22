% Generate a table with a time column and the variable name set to time.
cd(matlabdrive);
cd '3DModel/Scripts';

Time=out.tout;
Data = table(Time,'VariableNames', {'Time'});

%Loop through each dataset element to add it to the table
for i=1:out.logsout.numElements;
    % Get signal name
    signalName=out.logsout.getElement(i).Name;
    % Get signal data
    signalData=out.logsout.getElement(i).Values.Data;
    % Add the data as a new column in the table
    Data.(signalName)=signalData;
end

% Clean Up Workspace After Running and Generating the Table
clear i;
clear signalName;
clear signalData;
clear Time;

% Generate Shaft and Grip Vector Components for Quivers Plot Use

% Grip Scale Factor (Size up grip vector for graphics)
GripScale=1.5;

% Generate Grip Vector in Table
Data.Gripdx=GripScale.*(Data.RHx-Data.Buttx);
Data.Gripdy=GripScale.*(Data.RHy-Data.Butty);
Data.Gripdz=GripScale.*(Data.RHz-Data.Buttz);
clear GripScale;

% Generate Shaft Vector in Table
Data.Shaftdx=Data.CHx-Data.RHx;
Data.Shaftdy=Data.CHy-Data.RHy;
Data.Shaftdz=Data.CHz-Data.RHz;

% Generate Left Forearm Vector in Table
Data.LeftForearmdx=Data.LHx-Data.LEx;
Data.LeftForearmdy=Data.LHy-Data.LEy;
Data.LeftForearmdz=Data.LHz-Data.LEz;

% Generate Left Forearm Vector in Table
Data.RightForearmdx=Data.RHx-Data.REx;
Data.RightForearmdy=Data.RHy-Data.REy;
Data.RightForearmdz=Data.RHz-Data.REz;

% Generate Left Upper Arm Vector in Table
Data.LeftArmdx=Data.LEx-Data.LSx;
Data.LeftArmdy=Data.LEy-Data.LSy;
Data.LeftArmdz=Data.LEz-Data.LSz;

% Generate Right Upper Arm Vector in Table
Data.RightArmdx=Data.REx-Data.RSx;
Data.RightArmdy=Data.REy-Data.RSy;
Data.RightArmdz=Data.REz-Data.RSz;

% Generate Left Shoulder Vector
Data.LeftShoulderdx=Data.LSx-Data.HUBx;
Data.LeftShoulderdy=Data.LSy-Data.HUBy;
Data.LeftShoulderdz=Data.LSz-Data.HUBz;

% Generate Right Shoulder Vector
Data.RightShoulderdx=Data.RSx-Data.HUBx;
Data.RightShoulderdy=Data.RSy-Data.HUBy;
Data.RightShoulderdz=Data.RSz-Data.HUBz;

% % Generate Hip Constraint Torque
% Data.HipConstraintTorqueX=Data.HipTorqueLocal(:,1)-Data.HipTorqueXInput;
% Data.HipConstraintTorqueY=Data.HipTorqueLocal(:,2)-Data.HipTorqueYInput;
% Data.HipConstraintTorqueZ=Data.HipTorqueLocal(:,3)-Data.HipTorqueZInput;
% 
% % Generate Torso Constraint Torque 
% Data.TorsoConstraintTorqueX=Data.TorsoTorqueLocal(:,1); % No x input
% Data.TorsoConstraintTorqueY=Data.TorsoTorqueLocal(:,2); % No x input
% Data.TorsoConstraintTorqueZ=Data.TorsoTorqueLocal(:,3)-Data.TorsoTorqueInput;
% 
% % Generate Spine Constraint Torque
% Data.SpineConstraintTorqueX=Data.SpineTorqueLocal(:,1)-Data.SpineTorqueXInput;
% Data.SpineConstraintTorqueY=Data.SpineTorqueLocal(:,2)-Data.SpineTorqueYInput;
% Data.SpineConstraintTorqueZ=Data.SpineTorqueLocal(:,3); % No z input
% 
% % Generate LScap Constraint Torque
% Data.LScapConstraintTorqueX=Data.LScapTorqueLocal(:,1)-Data.LScapTorqueXInput;
% Data.LScapConstraintTorqueY=Data.LScapTorqueLocal(:,2)-Data.LScapTorqueYInput;
% Data.LScapConstraintTorqueZ=Data.LScapTorqueLocal(:,3); % No z input
% 
% % Generate RScap Constraint Torque
% Data.RScapConstraintTorqueX=Data.RScapTorqueLocal(:,1)-Data.RScapTorqueXInput;
% Data.RScapConstraintTorqueY=Data.RScapTorqueLocal(:,2)-Data.RScapTorqueYInput;
% Data.RScapConstraintTorqueZ=Data.RScapTorqueLocal(:,3); % No z input
% 
% % Generate LS Constraint Torque
% Data.LSConstraintTorqueX=Data.LSTorqueLocal(:,1)-Data.LSTorqueXInput;
% Data.LSConstraintTorqueY=Data.LSTorqueLocal(:,2)-Data.LSTorqueYInput;
% Data.LSConstraintTorqueZ=Data.LSTorqueLocal(:,3)-Data.LSTorqueZInput;
% 
% % Generate RS Constraint Torque
% Data.RSConstraintTorqueX=Data.RSTorqueLocal(:,1)-Data.RSTorqueXInput;
% Data.RSConstraintTorqueY=Data.RSTorqueLocal(:,2)-Data.RSTorqueYInput;
% Data.RSConstraintTorqueZ=Data.RSTorqueLocal(:,3)-Data.RSTorqueZInput;
% 
% % Generate LE Constraint Torque 
% Data.LEConstraintTorqueX=Data.LETorqueLocal(:,1); % No x input
% Data.LEConstraintTorqueY=Data.LETorqueLocal(:,2); % No x input
% Data.LEConstraintTorqueZ=Data.LETorqueLocal(:,3)-Data.LETorqueInput;
% 
% % Generate RE Constraint Torque 
% Data.REConstraintTorqueX=Data.RETorqueLocal(:,1); % No x input
% Data.REConstraintTorqueY=Data.RETorqueLocal(:,2); % No x input
% Data.REConstraintTorqueZ=Data.RETorqueLocal(:,3)-Data.RETorqueInput;
% 
% % Generate LF Constraint Torque 
% Data.LFConstraintTorqueX=Data.LFTorqueLocal(:,1); % No x input
% Data.LFConstraintTorqueY=Data.LFTorqueLocal(:,2); % No x input
% Data.LFConstraintTorqueZ=Data.LFTorqueLocal(:,3)-Data.LFTorqueInput;
% 
% % Generate RF Constraint Torque 
% Data.RFConstraintTorqueX=Data.RFTorqueLocal(:,1); % No x input
% Data.RFConstraintTorqueY=Data.RFTorqueLocal(:,2); % No x input
% Data.RFConstraintTorqueZ=Data.RFTorqueLocal(:,3)-Data.RFTorqueInput;
% 
% % Generate LW Constraint Torque
% Data.LWConstraintTorqueX=Data.LWTorqueLocal(:,1)-Data.LWTorqueXInput;
% Data.LWConstraintTorqueY=Data.LWTorqueLocal(:,2)-Data.LWTorqueYInput;
% Data.LWConstraintTorqueZ=Data.LWTorqueLocal(:,3); % No z input
% 
% % Generate RW Constraint Torque
% Data.RWConstraintTorqueX=Data.RWTorqueLocal(:,1)-Data.RWTorqueXInput;
% Data.RWConstraintTorqueY=Data.RWTorqueLocal(:,2)-Data.RWTorqueYInput;
% Data.RWConstraintTorqueZ=Data.RWTorqueLocal(:,3); % No z input


cd(matlabdrive);
cd 3DModel;
