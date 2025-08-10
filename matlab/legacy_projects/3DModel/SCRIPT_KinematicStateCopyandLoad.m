% Copy the Kinematic State in the Model at a Point in Time and Copy to
% Model Workspace Starting Conditions

% Currently only have the hip angular position, velocity, and torque in
% here but the issue I am having is that it is returning a NaN value when I
% use the interp function to try and read the value from the table. Maybe
% look at the most recent ZVCF to see if there is a better way to write it.

% Select time that kinematic data is copied from:
% j=0
LookupTime=0.0;
%SimulationTime=LookupTime+0.1;

% Load GolfSwing3D Model and Assign in the Simulation Time Prior to Running
cd(matlabdrive);
cd 3DModel;
GolfSwing3D_KineticallyDriven;
% GolfSwing3D_KinematicallyDriven;

mdlWks=get_param('GolfSwing3D_KineticallyDriven','ModelWorkspace');
% mdlWks=get_param('GolfSwing3D_KinematicallyDriven','ModelWorkspace');

%assignin(mdlWks,"StopTime",Simulink.Parameter(SimulationTime))
out=sim("GolfSwing3D_KineticallyDriven.slx");
% out=sim("GolfSwing3D_KinematicallyDriven.slx");

% Run Preliminary Scripts to Generate Data Tables to Draw Values From
cd(matlabdrive);
cd 3DModel;
cd 'Scripts/_Model Data Scripts';
SCRIPT_3D_TableGeneration;
SCRIPT_Data_3D_TotalWorkandPowerCalculation;
SCRIPT_Data_3D_TotalWorkandPowerCalculation;
SCRIPT_Data_3D_CHPandMPPCalculation;
SCRIPT_Data_3D_TableofValues;

%Set the killswitch time to 1 second so it doesn't ever trigger
assignin(mdlWks,'KillswitchStepTime',Simulink.Parameter(1));

% Read the joint torque values at the counter time
HipTorqueX=interp1(Data.Time,Data.HipTorqueXInput,LookupTime,'linear');
HipTorqueY=interp1(Data.Time,Data.HipTorqueYInput,LookupTime,'linear');
HipTorqueZ=interp1(Data.Time,Data.HipTorqueZInput,LookupTime,'linear');

TranslationForceX=interp1(Data.Time,Data.TranslationForceXInput,LookupTime,'linear');
TranslationForceY=interp1(Data.Time,Data.TranslationForceYInput,LookupTime,'linear');
TranslationForceZ=interp1(Data.Time,Data.TranslationForceZInput,LookupTime,'linear');

SpineTorqueX=interp1(Data.Time,Data.SpineTorqueXInput,LookupTime,'linear');
SpineTorqueY=interp1(Data.Time,Data.SpineTorqueYInput,LookupTime,'linear');

TorsoTorque=interp1(Data.Time,Data.TorsoTorqueInput,LookupTime,'linear');

LScapTorqueX=interp1(Data.Time,Data.LScapTorqueXInput,LookupTime,'linear');
LScapTorqueY=interp1(Data.Time,Data.LScapTorqueYInput,LookupTime,'linear');

RScapTorqueX=interp1(Data.Time,Data.RScapTorqueXInput,LookupTime,'linear');
RScapTorqueY=interp1(Data.Time,Data.RScapTorqueYInput,LookupTime,'linear');

LSTorqueX=interp1(Data.Time,Data.LSTorqueXInput,LookupTime,'linear');
LSTorqueY=interp1(Data.Time,Data.LSTorqueYInput,LookupTime,'linear');
LSTorqueZ=interp1(Data.Time,Data.LSTorqueZInput,LookupTime,'linear');

RSTorqueX=interp1(Data.Time,Data.RSTorqueXInput,LookupTime,'linear');
RSTorqueY=interp1(Data.Time,Data.RSTorqueYInput,LookupTime,'linear');
RSTorqueZ=interp1(Data.Time,Data.RSTorqueZInput,LookupTime,'linear');

LETorque=interp1(Data.Time,Data.LETorqueInput,LookupTime,'linear');

RETorque=interp1(Data.Time,Data.RETorqueInput,LookupTime,'linear');

LFTorque=interp1(Data.Time,Data.LFTorqueInput,LookupTime,'linear');

RFTorque=interp1(Data.Time,Data.RFTorqueInput,LookupTime,'linear');

LWTorqueX=interp1(Data.Time,Data.LWTorqueXInput,LookupTime,'linear');
LWTorqueY=interp1(Data.Time,Data.LWTorqueYInput,LookupTime,'linear');

RWTorqueX=interp1(Data.Time,Data.RWTorqueXInput,LookupTime,'linear');
RWTorqueY=interp1(Data.Time,Data.RWTorqueYInput,LookupTime,'linear');

%Read the position values at the counter time (verify all read in degrees)
HipPositionX=interp1(Data.Time,Data.HipPositionX,LookupTime,'linear');
HipPositionY=interp1(Data.Time,Data.HipPositionY,LookupTime,'linear');
HipPositionZ=interp1(Data.Time,Data.HipPositionZ,LookupTime,'linear');

TranslationPositionX=interp1(Data.Time,Data.HipGlobalPositionX,LookupTime,'linear');
TranslationPositionY=interp1(Data.Time,Data.HipGlobalPositionY,LookupTime,'linear');
TranslationPositionZ=interp1(Data.Time,Data.HipGlobalPositionZ,LookupTime,'linear');

SpinePositionX=interp1(Data.Time,Data.SpinePositionX,LookupTime,'linear');
SpinePositionY=interp1(Data.Time,Data.SpinePositionY,LookupTime,'linear');

TorsoPosition=interp1(Data.Time,Data.TorsoPosition,LookupTime,'linear');

LScapPositionX=interp1(Data.Time,Data.LScapPositionX,LookupTime,'linear');
LScapPositionY=interp1(Data.Time,Data.LScapPositionY,LookupTime,'linear');

RScapPositionX=interp1(Data.Time,Data.RScapPositionX,LookupTime,'linear');
RScapPositionY=interp1(Data.Time,Data.RScapPositionY,LookupTime,'linear');

LSPositionX=interp1(Data.Time,Data.LSPositionX,LookupTime,'linear');
LSPositionY=interp1(Data.Time,Data.LSPositionY,LookupTime,'linear');
LSPositionZ=interp1(Data.Time,Data.LSPositionZ,LookupTime,'linear');

RSPositionX=interp1(Data.Time,Data.RSPositionX,LookupTime,'linear');
RSPositionY=interp1(Data.Time,Data.RSPositionY,LookupTime,'linear');
RSPositionZ=interp1(Data.Time,Data.RSPositionZ,LookupTime,'linear');

LEPosition=interp1(Data.Time,Data.LEPosition,LookupTime,'linear');

REPosition=interp1(Data.Time,Data.REPosition,LookupTime,'linear');

LFPosition=interp1(Data.Time,Data.LFPosition,LookupTime,'linear');

RFPosition=interp1(Data.Time,Data.RFPosition,LookupTime,'linear');

LWPositionX=interp1(Data.Time,Data.LWPositionX,LookupTime,'linear');
LWPositionY=interp1(Data.Time,Data.LWPositionY,LookupTime,'linear');

RWPositionX=interp1(Data.Time,Data.RWPositionX,LookupTime,'linear');
RWPositionY=interp1(Data.Time,Data.RWPositionY,LookupTime,'linear');

%Read the Velocity values at the counter time (verify all read in degrees)
HipVelocityX=interp1(Data.Time,Data.HipVelocityX,LookupTime,'linear');
HipVelocityY=interp1(Data.Time,Data.HipVelocityY,LookupTime,'linear');
HipVelocityZ=interp1(Data.Time,Data.HipVelocityZ,LookupTime,'linear');

TranslationVelocityX=interp1(Data.Time,Data.HipGlobalVelocityX,LookupTime,'linear');
TranslationVelocityY=interp1(Data.Time,Data.HipGlobalVelocityY,LookupTime,'linear');
TranslationVelocityZ=interp1(Data.Time,Data.HipGlobalVelocityZ,LookupTime,'linear');

SpineVelocityX=interp1(Data.Time,Data.SpineVelocityX,LookupTime,'linear');
SpineVelocityY=interp1(Data.Time,Data.SpineVelocityY,LookupTime,'linear');

TorsoVelocity=interp1(Data.Time,Data.TorsoVelocity,LookupTime,'linear');

LScapVelocityX=interp1(Data.Time,Data.LScapVelocityX,LookupTime,'linear');
LScapVelocityY=interp1(Data.Time,Data.LScapVelocityY,LookupTime,'linear');

RScapVelocityX=interp1(Data.Time,Data.RScapVelocityX,LookupTime,'linear');
RScapVelocityY=interp1(Data.Time,Data.RScapVelocityY,LookupTime,'linear');

LSVelocityX=interp1(Data.Time,Data.LSVelocityX,LookupTime,'linear');
LSVelocityY=interp1(Data.Time,Data.LSVelocityY,LookupTime,'linear');
LSVelocityZ=interp1(Data.Time,Data.LSVelocityZ,LookupTime,'linear');

RSVelocityX=interp1(Data.Time,Data.RSVelocityX,LookupTime,'linear');
RSVelocityY=interp1(Data.Time,Data.RSVelocityY,LookupTime,'linear');
RSVelocityZ=interp1(Data.Time,Data.RSVelocityZ,LookupTime,'linear');

LEVelocity=interp1(Data.Time,Data.LEVelocity,LookupTime,'linear');

REVelocity=interp1(Data.Time,Data.REVelocity,LookupTime,'linear');

LFVelocity=interp1(Data.Time,Data.LFVelocity,LookupTime,'linear');

RFVelocity=interp1(Data.Time,Data.RFVelocity,LookupTime,'linear');

LWVelocityX=interp1(Data.Time,Data.LWVelocityX,LookupTime,'linear');
LWVelocityY=interp1(Data.Time,Data.LWVelocityY,LookupTime,'linear');

RWVelocityX=interp1(Data.Time,Data.RWVelocityX,LookupTime,'linear');
RWVelocityY=interp1(Data.Time,Data.RWVelocityY,LookupTime,'linear');

% % Assign in the torque values to the model workspace (Only Used For ZVCF)
% assignin(mdlWks,'ZVCFHipTorqueX',Simulink.Parameter(HipTorqueX));
% assignin(mdlWks,'ZVCFHipTorqueY',Simulink.Parameter(HipTorqueY));
% assignin(mdlWks,'ZVCFHipTorqueZ',Simulink.Parameter(HipTorqueZ));
%
% assignin(mdlWks,'ZVCFTranslationForceX',Simulink.Parameter(TranslationForceX));
% assignin(mdlWks,'ZVCFTranslationForceY',Simulink.Parameter(TranslationForceY));
% assignin(mdlWks,'ZVCFTranslationForceZ',Simulink.Parameter(TranslationForceZ));
%
% assignin(mdlWks,'ZVCFSpineTorqueX',Simulink.Parameter(SpineTorqueX));
% assignin(mdlWks,'ZVCFSpineTorqueY',Simulink.Parameter(SpineTorqueY));
%
% assignin(mdlWks,'ZVCFTorsoTorque',Simulink.Parameter(TorsoTorque));
%
% assignin(mdlWks,'ZVCFLScapTorqueX',Simulink.Parameter(LScapTorqueX));
% assignin(mdlWks,'ZVCFLScapTorqueY',Simulink.Parameter(LScapTorqueY));
%
% assignin(mdlWks,'ZVCFRScapTorqueX',Simulink.Parameter(RScapTorqueX));
% assignin(mdlWks,'ZVCFRScapTorqueY',Simulink.Parameter(RScapTorqueY));
%
% assignin(mdlWks,'ZVCFLSTorqueX',Simulink.Parameter(LSTorqueX));
% assignin(mdlWks,'ZVCFLSTorqueY',Simulink.Parameter(LSTorqueY));
% assignin(mdlWks,'ZVCFLSTorqueZ',Simulink.Parameter(LSTorqueZ));
%
% assignin(mdlWks,'ZVCFRSTorqueX',Simulink.Parameter(RSTorqueX));
% assignin(mdlWks,'ZVCFRSTorqueY',Simulink.Parameter(RSTorqueY));
% assignin(mdlWks,'ZVCFRSTorqueZ',Simulink.Parameter(RSTorqueZ));
%
% assignin(mdlWks,'ZVCFLETorque',Simulink.Parameter(LETorque));
%
% assignin(mdlWks,'ZVCFRETorque',Simulink.Parameter(RETorque));
%
% assignin(mdlWks,'ZVCFLFTorque',Simulink.Parameter(LFTorque));
%
% assignin(mdlWks,'ZVCFRFTorque',Simulink.Parameter(RFTorque));
%
% assignin(mdlWks,'ZVCFLWTorqueX',Simulink.Parameter(LWTorqueX));
% assignin(mdlWks,'ZVCFLWTorqueY',Simulink.Parameter(LWTorqueY));
%
% assignin(mdlWks,'ZVCFRWTorqueX',Simulink.Parameter(RWTorqueX));
% assignin(mdlWks,'ZVCFRWTorqueY',Simulink.Parameter(RWTorqueY));

% Assign in position and velocity values to the model workspace
assignin(mdlWks,'HipStartPositionX',Simulink.Parameter(HipPositionX));
assignin(mdlWks,'HipStartPositionY',Simulink.Parameter(HipPositionY));
assignin(mdlWks,'HipStartPositionZ',Simulink.Parameter(HipPositionZ));
assignin(mdlWks,'HipStartVelocityX',Simulink.Parameter(HipVelocityX));
assignin(mdlWks,'HipStartVelocityY',Simulink.Parameter(HipVelocityY));
assignin(mdlWks,'HipStartVelocityZ',Simulink.Parameter(HipVelocityZ));

assignin(mdlWks,'TranslationStartPositionX',Simulink.Parameter(TranslationPositionX));
assignin(mdlWks,'TranslationStartPositionY',Simulink.Parameter(TranslationPositionY));
assignin(mdlWks,'TranslationStartPositionZ',Simulink.Parameter(TranslationPositionZ));
assignin(mdlWks,'TranslationStartVelocityX',Simulink.Parameter(TranslationVelocityX));
assignin(mdlWks,'TranslationStartVelocityY',Simulink.Parameter(TranslationVelocityY));
assignin(mdlWks,'TranslationStartVelocityZ',Simulink.Parameter(TranslationVelocityZ));

assignin(mdlWks,'SpineStartPositionX',Simulink.Parameter(SpinePositionX));
assignin(mdlWks,'SpineStartPositionY',Simulink.Parameter(SpinePositionY));
assignin(mdlWks,'SpineStartVelocityX',Simulink.Parameter(SpineVelocityX));
assignin(mdlWks,'SpineStartVelocityY',Simulink.Parameter(SpineVelocityY));

assignin(mdlWks,'TorsoStartPosition',Simulink.Parameter(TorsoPosition));
assignin(mdlWks,'TorsoStartVelocity',Simulink.Parameter(TorsoVelocity));

assignin(mdlWks,'LScapStartPositionX',Simulink.Parameter(LScapPositionX));
assignin(mdlWks,'LScapStartPositionY',Simulink.Parameter(LScapPositionY));
assignin(mdlWks,'LScapStartVelocityX',Simulink.Parameter(LScapVelocityX));
assignin(mdlWks,'LScapStartVelocityY',Simulink.Parameter(LScapVelocityY));

assignin(mdlWks,'RScapStartPositionX',Simulink.Parameter(RScapPositionX));
assignin(mdlWks,'RScapStartPositionY',Simulink.Parameter(RScapPositionY));
assignin(mdlWks,'RScapStartVelocityX',Simulink.Parameter(RScapVelocityX));
assignin(mdlWks,'RScapStartVelocityY',Simulink.Parameter(RScapVelocityY));

assignin(mdlWks,'LSStartPositionX',Simulink.Parameter(LSPositionX));
assignin(mdlWks,'LSStartPositionY',Simulink.Parameter(LSPositionY));
assignin(mdlWks,'LSStartPositionZ',Simulink.Parameter(LSPositionZ));
assignin(mdlWks,'LSStartVelocityX',Simulink.Parameter(LSVelocityX));
assignin(mdlWks,'LSStartVelocityY',Simulink.Parameter(LSVelocityY));
assignin(mdlWks,'LSStartVelocityZ',Simulink.Parameter(LSVelocityZ));

assignin(mdlWks,'RSStartPositionX',Simulink.Parameter(RSPositionX));
assignin(mdlWks,'RSStartPositionY',Simulink.Parameter(RSPositionY));
assignin(mdlWks,'RSStartPositionZ',Simulink.Parameter(RSPositionZ));
assignin(mdlWks,'RSStartVelocityX',Simulink.Parameter(RSVelocityX));
assignin(mdlWks,'RSStartVelocityY',Simulink.Parameter(RSVelocityY));
assignin(mdlWks,'RSStartVelocityZ',Simulink.Parameter(RSVelocityZ));

assignin(mdlWks,'LEStartPosition',Simulink.Parameter(LEPosition));
assignin(mdlWks,'LEStartVelocity',Simulink.Parameter(LEVelocity));

assignin(mdlWks,'REStartPosition',Simulink.Parameter(REPosition));
assignin(mdlWks,'REStartVelocity',Simulink.Parameter(REVelocity));

assignin(mdlWks,'LFStartPosition',Simulink.Parameter(LFPosition));
assignin(mdlWks,'LFStartVelocity',Simulink.Parameter(LFVelocity));

assignin(mdlWks,'RFStartPosition',Simulink.Parameter(RFPosition));
assignin(mdlWks,'RFStartVelocity',Simulink.Parameter(RFVelocity));

assignin(mdlWks,'LWStartPositionX',Simulink.Parameter(LWPositionX));
assignin(mdlWks,'LWStartPositionY',Simulink.Parameter(LWPositionY));
assignin(mdlWks,'LWStartVelocityX',Simulink.Parameter(LWVelocityX));
assignin(mdlWks,'LWStartVelocityY',Simulink.Parameter(LWVelocityY));

assignin(mdlWks,'RWStartPositionX',Simulink.Parameter(RWPositionX));
assignin(mdlWks,'RWStartPositionY',Simulink.Parameter(RWPositionY));
assignin(mdlWks,'RWStartVelocityX',Simulink.Parameter(RWVelocityX));
assignin(mdlWks,'RWStartVelocityY',Simulink.Parameter(RWVelocityY));

clear out;
clear LookupTime;
clear SimulationTime;
clear HipTorqueX;
clear HipTorqueY;
clear HipTorqueZ;
clear HipPositionX;
clear HipPositionY;
clear HipPositionZ;
clear HipVelocityX;
clear HipVelocityY;
clear HipVelocityZ;
clear TranslationVelocityX;
clear TranslationVelocityY;
clear TranslationVelocityZ;
clear TranslationPositionX;
clear TranslationPositionY;
clear TranslationPositionZ;
clear TranslationForceX;
clear TranslationForceY;
clear TranslationForceZ;
clear SpinePositionX;
clear SpinePositionY;
clear SpineVelocityX;
clear SpineVelocityY;
clear SpineTorqueX;
clear SpineTorqueY;
clear TorsoTorque;
clear TorsoPosition;
clear TorsoVelocity;
clear LScapVelocityX;
clear LScapVelocityY;
clear LScapPositionX;
clear LScapPositionY;
clear LScapTorqueX;
clear LScapTorqueY;
clear RScapVelocityX;
clear RScapVelocityY;
clear RScapPositionX;
clear RScapPositionY;
clear RScapTorqueX;
clear RScapTorqueY;
clear LSVelocityX;
clear LSVelocityY;
clear LSVelocityZ;
clear LSPositionX;
clear LSPositionY;
clear LSPositionZ;
clear LSTorqueX;
clear LSTorqueY;
clear LSTorqueZ;
clear RSVelocityX;
clear RSVelocityY;
clear RSVelocityZ;
clear RSPositionX;
clear RSPositionY;
clear RSPositionZ;
clear RSTorqueX;
clear RSTorqueY;
clear RSTorqueZ;
clear LETorque;
clear LEPosition;
clear LEVelocity;
clear RETorque;
clear REPosition;
clear REVelocity;
clear LFTorque;
clear LFPosition;
clear LFVelocity;
clear RFTorque;
clear RFPosition;
clear RFVelocity;
clear LWTorqueX;
clear LWTorqueY;
clear RWTorqueX;
clear RWTorqueY;
clear LWPositionX;
clear LWPositionY;
clear LWVelocityX;
clear LWVelocityY;
clear RWPositionX;
clear RWPositionY;
clear RWVelocityX;
clear RWVelocityY;

cd(matlabdrive);
