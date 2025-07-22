
% Read from model workspace the value in the starting position / velocity
% from the impact optimized model

% Load the impact desired kinematics from the LoadImpact Script and run the
% model with these parameters. Then copy the parameters from the start
% position of model works to the target position of modelworks.

cd(matlabdrive);
cd '3DModel';

% Load optimized input into the model workspace. This loads the impact file
% and runs the kinetic model on the impact. The start positions and
% velocities from this file will be copied to the targets in the model
% workspace.

SCRIPT_LoadImpact


% Copy the kinematics from model workspace starting values (which the
% impact position is in the 3DModelInputs_Impact file) and write them as
% the target for the model workspace. This target will serve as the
% setpoint for a different starting position that will be loaded into the
% model after running this script.

% Hip Rotation Position Targets
GetValueHPX=getVariable(mdlWks,"HipStartPositionX");
assignin(mdlWks,"TargetHipPositionX",GetValueHPX);
GetValueHPY=getVariable(mdlWks,"HipStartPositionY");
assignin(mdlWks,"TargetHipPositionY",GetValueHPY);
GetValueHPZ=getVariable(mdlWks,"HipStartPositionZ");
assignin(mdlWks,"TargetHipPositionZ",GetValueHPZ);

% Hip Rotation Velocity Targets
GetValueHVX=getVariable(mdlWks,"HipStartVelocityX");
assignin(mdlWks,"TargetHipVelocityX",GetValueHVX);
GetValueHVY=getVariable(mdlWks,"HipStartVelocityY");
assignin(mdlWks,"TargetHipVelocityY",GetValueHVY);
GetValueHVZ=getVariable(mdlWks,"HipStartVelocityZ");
assignin(mdlWks,"TargetHipVelocityZ",GetValueHVZ);

% Hip Translation Position Targets
GetValueTPX=getVariable(mdlWks,"TranslationStartPositionX");
assignin(mdlWks,"TargetTranslationPositionX",GetValueTPX);
GetValueTPY=getVariable(mdlWks,"TranslationStartPositionY");
assignin(mdlWks,"TargetTranslationPositionY",GetValueTPY);
GetValueTPZ=getVariable(mdlWks,"TranslationStartPositionZ");
assignin(mdlWks,"TargetTranslationPositionZ",GetValueTPZ);

% Hip Translation Velocity Targets
GetValueTVX=getVariable(mdlWks,"TranslationStartVelocityX");
assignin(mdlWks,"TargetTranslationVelocityX",GetValueTVX);
GetValueTVY=getVariable(mdlWks,"TranslationStartVelocityY");
assignin(mdlWks,"TargetTranslationVelocityY",GetValueTVY);
GetValueTVZ=getVariable(mdlWks,"TranslationStartVelocityZ");
assignin(mdlWks,"TargetTranslationVelocityZ",GetValueTVZ);

% Spine Position Targets
GetValueSPX=getVariable(mdlWks,"SpineStartPositionX");
assignin(mdlWks,"TargetSpinePositionX",GetValueSPX);
GetValueSPY=getVariable(mdlWks,"SpineStartPositionY");
assignin(mdlWks,"TargetSpinePositionY",GetValueSPY);

% Spine Velocity Targets
GetValueSVX=getVariable(mdlWks,"SpineStartVelocityX");
assignin(mdlWks,"TargetSpineVelocityX",GetValueSVX);
GetValueSVY=getVariable(mdlWks,"SpineStartVelocityY");
assignin(mdlWks,"TargetSpineVelocityY",GetValueSVY);

% Torso Position Targets
GetValueTP=getVariable(mdlWks,"TorsoStartPosition");
assignin(mdlWks,"TargetTorsoPosition",GetValueTP);

% Torso Velocity Targets
GetValueTV=getVariable(mdlWks,"TorsoStartVelocity");
assignin(mdlWks,"TargetTorsoVelocity",GetValueTV);

% LScap Position Targets
GetValueLSCAPPX=getVariable(mdlWks,"LScapStartPositionX");
assignin(mdlWks,"TargetLScapPositionX",GetValueLSCAPPX);
GetValueLSCAPPY=getVariable(mdlWks,"LScapStartPositionY");
assignin(mdlWks,"TargetLScapPositionY",GetValueLSCAPPY);

% LScap Velocity Targets
GetValueLSCAPVX=getVariable(mdlWks,"LScapStartVelocityX");
assignin(mdlWks,"TargetLScapVelocityX",GetValueLSCAPVX);
GetValueLSCAPVY=getVariable(mdlWks,"LScapStartVelocityY");
assignin(mdlWks,"TargetLScapVelocityY",GetValueLSCAPVY);

% RScap Position Targets
GetValueRSCAPPX=getVariable(mdlWks,"RScapStartPositionX");
assignin(mdlWks,"TargetRScapPositionX",GetValueRSCAPPX);
GetValueRSCAPPY=getVariable(mdlWks,"RScapStartPositionY");
assignin(mdlWks,"TargetRScapPositionY",GetValueRSCAPPY);

% RScap Velocity Targets
GetValueRSCAPVX=getVariable(mdlWks,"RScapStartVelocityX");
assignin(mdlWks,"TargetRScapVelocityX",GetValueRSCAPVX);
GetValueRSCAPVY=getVariable(mdlWks,"RScapStartVelocityY");
assignin(mdlWks,"TargetRScapVelocityY",GetValueRSCAPVY);

% LS Position Targets
GetValueLSPX=getVariable(mdlWks,"LSStartPositionX");
assignin(mdlWks,"TargetLSPositionX",GetValueLSPX);
GetValueLSPY=getVariable(mdlWks,"LSStartPositionY");
assignin(mdlWks,"TargetLSPositionY",GetValueLSPY);
GetValueLSPZ=getVariable(mdlWks,"LSStartPositionZ");
assignin(mdlWks,"TargetLSPositionZ",GetValueLSPZ);

% LS Velocity Targets
GetValueLSVX=getVariable(mdlWks,"LSStartVelocityX");
assignin(mdlWks,"TargetLSVelocityX",GetValueLSVX);
GetValueLSVY=getVariable(mdlWks,"LSStartVelocityY");
assignin(mdlWks,"TargetLSVelocityY",GetValueLSVY);
GetValueLSVZ=getVariable(mdlWks,"LSStartVelocityZ");
assignin(mdlWks,"TargetLSVelocityZ",GetValueLSVZ);

% RS Position Targets
GetValueRSPX=getVariable(mdlWks,"RSStartPositionX");
assignin(mdlWks,"TargetRSPositionX",GetValueRSPX);
GetValueRSPY=getVariable(mdlWks,"RSStartPositionY");
assignin(mdlWks,"TargetRSPositionY",GetValueRSPY);
GetValueRSPZ=getVariable(mdlWks,"RSStartPositionZ");
assignin(mdlWks,"TargetRSPositionZ",GetValueRSPZ);

% RS Velocity Targets
GetValueRSVX=getVariable(mdlWks,"RSStartVelocityX");
assignin(mdlWks,"TargetRSVelocityX",GetValueRSVX);
GetValueRSVY=getVariable(mdlWks,"RSStartVelocityY");
assignin(mdlWks,"TargetRSVelocityY",GetValueRSVY);
GetValueRSVZ=getVariable(mdlWks,"RSStartVelocityZ");
assignin(mdlWks,"TargetRSVelocityZ",GetValueRSVZ);

% LE Position Targets
GetValueLEP=getVariable(mdlWks,"LEStartPosition");
assignin(mdlWks,"TargetLEPosition",GetValueLEP);

% LE Velocity Targets
GetValueLEV=getVariable(mdlWks,"LEStartVelocity");
assignin(mdlWks,"TargetLEVelocity",GetValueLEV);

% RE Position Targets
GetValueREP=getVariable(mdlWks,"REStartPosition");
assignin(mdlWks,"TargetREPosition",GetValueREP);

% RE Velocity Targets
GetValueREV=getVariable(mdlWks,"REStartVelocity");
assignin(mdlWks,"TargetREVelocity",GetValueREV);

% LF Position Targets
GetValueLFP=getVariable(mdlWks,"LFStartPosition");
assignin(mdlWks,"TargetLFPosition",GetValueLFP);

% LF Velocity Targets
GetValueLFV=getVariable(mdlWks,"LFStartVelocity");
assignin(mdlWks,"TargetLFVelocity",GetValueLFV);

% RF Position Targets
GetValueRFP=getVariable(mdlWks,"RFStartPosition");
assignin(mdlWks,"TargetRFPosition",GetValueRFP);

% RF Velocity Targets
GetValueRFV=getVariable(mdlWks,"RFStartVelocity");
assignin(mdlWks,"TargetRFVelocity",GetValueRFV);

% LW Position Targets
GetValueLWPX=getVariable(mdlWks,"LWStartPositionX");
assignin(mdlWks,"TargetLWPositionX",GetValueLWPX);
GetValueLWPY=getVariable(mdlWks,"LWStartPositionY");
assignin(mdlWks,"TargetLWPositionY",GetValueLWPY);

% LW Velocity Targets
GetValueLWVX=getVariable(mdlWks,"LWStartVelocityX");
assignin(mdlWks,"TargetLWVelocityX",GetValueLWVX);
GetValueLWVY=getVariable(mdlWks,"LWStartVelocityY");
assignin(mdlWks,"TargetLWVelocityY",GetValueLWVY);

% RW Position Targets
GetValueRWPX=getVariable(mdlWks,"RWStartPositionX");
assignin(mdlWks,"TargetRWPositionX",GetValueRWPX);
GetValueRWPY=getVariable(mdlWks,"RWStartPositionY");
assignin(mdlWks,"TargetRWPositionY",GetValueRWPY);

% RW Velocity Targets
GetValueRWVX=getVariable(mdlWks,"RWStartVelocityX");
assignin(mdlWks,"TargetRWVelocityX",GetValueRWVX);
GetValueRWVY=getVariable(mdlWks,"RWStartVelocityY");
assignin(mdlWks,"TargetRWVelocityY",GetValueRWVY);

% Run the model with the new target values:
out=sim('GolfSwing3D_KineticallyDriven.slx');

% Save Model Workspace
save(mdlWks,'3DModelInputs.mat')

clear GetValue;
clear GetValueHPX;
clear GetValueHPY;
clear GetValueHPZ;
clear GetValueHVX;
clear GetValueHVY;
clear GetValueHVZ;
clear GetValueTPX;
clear GetValueTPY;
clear GetValueTPZ;
clear GetValueTVX;
clear GetValueTVY;
clear GetValueTVZ;
clear GetValueSPX;
clear GetValueSPY;
clear GetValueSVX;
clear GetValueSVY;
clear GetValueTP;
clear GetValueTV;
clear GetValueLSCAPPX;
clear GetValueLSCAPPY;
clear GetValueLSCAPVX;
clear GetValueLSCAPVY;
clear GetValueRSCAPPX;
clear GetValueRSCAPPY;
clear GetValueRSCAPVX;
clear GetValueRSCAPVY;
clear GetValueLSPX;
clear GetValueLSPY;
clear GetValueLSPZ;
clear GetValueLSVX;
clear GetValueLSVY;
clear GetValueLSVZ;
clear GetValueRSPX;
clear GetValueRSPY;
clear GetValueRSPZ;
clear GetValueRSVX;
clear GetValueRSVY;
clear GetValueRSVZ;
clear GetValueLEP;
clear GetValueLEV;
clear GetValueREP;
clear GetValueREV;
clear GetValueLFP;
clear GetValueLFV;
clear GetValueRFP;
clear GetValueRFV;
clear GetValueLWPX;
clear GetValueLWPY;
clear GetValueLWVX;
clear GetValueLWVY;
clear GetValueRWPX;
clear GetValueRWPY;
clear GetValueRWVX;
clear GetValueRWVY;
