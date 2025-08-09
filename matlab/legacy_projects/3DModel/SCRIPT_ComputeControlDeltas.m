% Read from model workspace the value in the starting position / velocity
% from the impact optimized model and compare actual kinematics to the
% desired kinematics. These are then added to the Data table as target
% delta kinematics (delta from the target state).

% Prerequisite functions: Model workspace generation, Data table generation

cd(matlabdrive);
cd '3DModel';
% out=sim(GolfSwing3D);

% Hip Rotation Position Targets
TargetHipPositionX=getVariable(mdlWks,"TargetHipPositionX");
Data.TargetDeltaHipPositionX=Data.HipsAPX-TargetHipPositionX.Value;
TargetHipPositionY=getVariable(mdlWks,"TargetHipPositionY");
Data.TargetDeltaHipPositionY=Data.HipsAPY-TargetHipPositionY.Value;
TargetHipPositionZ=getVariable(mdlWks,"TargetHipPositionZ");
Data.TargetDeltaHipPositionZ=Data.HipsAPZ-TargetHipPositionZ.Value;

% Hip Rotation Velocity Targets
TargetHipVelocityX=getVariable(mdlWks,"TargetHipVelocityX");
Data.TargetDeltaHipVelocityX=Data.HipsAVX-TargetHipVelocityX.Value;
TargetHipVelocityY=getVariable(mdlWks,"TargetHipVelocityY");
Data.TargetDeltaHipVelocityY=Data.HipsAVY-TargetHipVelocityY.Value;
TargetHipVelocityZ=getVariable(mdlWks,"TargetHipVelocityZ");
Data.TargetDeltaHipVelocityZ=Data.HipsAVZ-TargetHipVelocityZ.Value;

% Hip Translation Position Targets
TargetTranslationPositionX=getVariable(mdlWks,"TargetTranslationPositionX");
Data.TargetDeltaTranslationPositionX=Data.HipGlobalPositionX-TargetTranslationPositionX.Value;
TargetTranslationPositionY=getVariable(mdlWks,"TargetTranslationPositionY");
Data.TargetDeltaTranslationPositionY=Data.HipGlobalPositionY-TargetTranslationPositionY.Value;
TargetTranslationPositionZ=getVariable(mdlWks,"TargetTranslationPositionZ");
Data.TargetDeltaTranslationPositionZ=Data.HipGlobalPositionZ-TargetTranslationPositionZ.Value;

% Hip Translation Velocity Targets
TargetTranslationVelocityX=getVariable(mdlWks,"TargetTranslationVelocityX");
Data.TargetDeltaTranslationVelocityX=Data.HipGlobalVelocityX-TargetTranslationVelocityX.Value;
TargetTranslationVelocityY=getVariable(mdlWks,"TargetTranslationVelocityY");
Data.TargetDeltaTranslationVelocityY=Data.HipGlobalVelocityY-TargetTranslationVelocityY.Value;
TargetTranslationVelocityZ=getVariable(mdlWks,"TargetTranslationVelocityZ");
Data.TargetDeltaTranslationVelocityZ=Data.HipGlobalVelocityZ-TargetTranslationVelocityZ.Value;

% Spine Position Targets
TargetSpinePositionX=getVariable(mdlWks,"TargetSpinePositionX");
Data.TargetDeltaSpinePositionX=Data.SpinePositionX-TargetSpinePositionX.Value;
TargetSpinePositionY=getVariable(mdlWks,"TargetSpinePositionY");
Data.TargetDeltaSpinePositionY=Data.SpinePositionY-TargetSpinePositionY.Value;

% Spine Velocity Targets
TargetSpineVelocityX=getVariable(mdlWks,"TargetSpineVelocityX");
Data.TargetDeltaSpineVelocityX=Data.SpineVelocityX-TargetSpineVelocityX.Value;
TargetSpineVelocityY=getVariable(mdlWks,"TargetSpineVelocityY");
Data.TargetDeltaSpineVelocityY=Data.SpineVelocityY-TargetSpineVelocityY.Value;

% Torso Position Targets
TargetTorsoPosition=getVariable(mdlWks,"TargetTorsoPosition");
Data.TargetDeltaTorsoPosition=Data.TorsoPosition-TargetTorsoPosition.Value;

% Torso Velocity Targets
TargetTorsoVelocity=getVariable(mdlWks,"TargetTorsoVelocity");
Data.TargetDeltaTorsoVelocity=Data.TorsoVelocity-TargetTorsoVelocity.Value;

% LScap Position Targets
TargetLScapPositionX=getVariable(mdlWks,"TargetLScapPositionX");
Data.TargetDeltaLScapPositionX=Data.LScapPositionX-TargetLScapPositionX.Value;
TargetLScapPositionY=getVariable(mdlWks,"TargetLScapPositionY");
Data.TargetDeltaLScapPositionY=Data.LScapPositionY-TargetLScapPositionY.Value;

% LScap Velocity Targets
TargetLScapVelocityX=getVariable(mdlWks,"TargetLScapVelocityX");
Data.TargetDeltaLScapVelocityX=Data.LScapVelocityX-TargetLScapVelocityX.Value;
TargetLScapVelocityY=getVariable(mdlWks,"TargetLScapVelocityY");
Data.TargetDeltaLScapVelocityY=Data.LScapVelocityY-TargetLScapVelocityY.Value;

% RScap Position Targets
TargetRScapPositionX=getVariable(mdlWks,"TargetRScapPositionX");
Data.TargetDeltaRScapPositionX=Data.RScapPositionX-TargetRScapPositionX.Value;
TargetRScapPositionY=getVariable(mdlWks,"TargetRScapPositionY");
Data.TargetDeltaRScapPositionY=Data.RScapPositionY-TargetRScapPositionY.Value;

% RScap Velocity Targets
TargetRScapVelocityX=getVariable(mdlWks,"TargetRScapVelocityX");
Data.TargetDeltaRScapVelocityX=Data.RScapVelocityX-TargetRScapVelocityX.Value;
TargetRScapVelocityY=getVariable(mdlWks,"TargetRScapVelocityY");
Data.TargetDeltaRScapVelocityY=Data.RScapVelocityY-TargetRScapVelocityY.Value;

% LS Position Targets
TargetLSPositionX=getVariable(mdlWks,"TargetLSPositionX");
Data.TargetDeltaLSPositionX=Data.LSPositionX-TargetLSPositionX.Value;
TargetLSPositionY=getVariable(mdlWks,"TargetLSPositionY");
Data.TargetDeltaLSPositionY=Data.LSPositionY-TargetLSPositionY.Value;
TargetLSPositionZ=getVariable(mdlWks,"TargetLSPositionZ");
Data.TargetDeltaLSPositionZ=Data.LSPositionZ-TargetLSPositionZ.Value;

% LS Velocity Targets
TargetLSVelocityX=getVariable(mdlWks,"TargetLSVelocityX");
Data.TargetDeltaLSVelocityX=Data.LSVelocityX-TargetLSVelocityX.Value;
TargetLSVelocityY=getVariable(mdlWks,"TargetLSVelocityY");
Data.TargetDeltaLSVelocityY=Data.LSVelocityY-TargetLSVelocityY.Value;
TargetLSVelocityZ=getVariable(mdlWks,"TargetLSVelocityZ");
Data.TargetDeltaLSVelocityZ=Data.LSVelocityZ-TargetLSVelocityZ.Value;

% RS Position Targets
TargetRSPositionX=getVariable(mdlWks,"TargetRSPositionX");
Data.TargetDeltaRSPositionX=Data.RSPositionX-TargetRSPositionX.Value;
TargetRSPositionY=getVariable(mdlWks,"TargetRSPositionY");
Data.TargetDeltaRSPositionY=Data.RSPositionY-TargetRSPositionY.Value;
TargetRSPositionZ=getVariable(mdlWks,"TargetRSPositionZ");
Data.TargetDeltaRSPositionZ=Data.RSPositionZ-TargetRSPositionZ.Value;

% RS Velocity Targets
TargetRSVelocityX=getVariable(mdlWks,"TargetRSVelocityX");
Data.TargetDeltaRSVelocityX=Data.RSVelocityX-TargetRSVelocityX.Value;
TargetRSVelocityY=getVariable(mdlWks,"TargetRSVelocityY");
Data.TargetDeltaRSVelocityY=Data.RSVelocityY-TargetRSVelocityY.Value;
TargetRSVelocityZ=getVariable(mdlWks,"TargetRSVelocityZ");
Data.TargetDeltaRSVelocityZ=Data.RSVelocityZ-TargetRSVelocityZ.Value;

% LE Position Targets
TargetLEPosition=getVariable(mdlWks,"TargetLEPosition");
Data.TargetDeltaLEPosition=Data.LEPosition-TargetLEPosition.Value;

% LE Velocity Targets
TargetLEVelocity=getVariable(mdlWks,"TargetLEVelocity");
Data.TargetDeltaLEVelocity=Data.LEVelocity-TargetLEVelocity.Value;

% RE Position Targets
TargetREPosition=getVariable(mdlWks,"TargetREPosition");
Data.TargetDeltaREPosition=Data.REPosition-TargetREPosition.Value;

% RE Velocity Targets
TargetREVelocity=getVariable(mdlWks,"TargetREVelocity");
Data.TargetDeltaREVelocity=Data.REVelocity-TargetREVelocity.Value;

% LF Position Targets
TargetLFPosition=getVariable(mdlWks,"TargetLFPosition");
Data.TargetDeltaLFPosition=Data.LFPosition-TargetLFPosition.Value;

% LF Velocity Targets
TargetLFVelocity=getVariable(mdlWks,"TargetLFVelocity");
Data.TargetDeltaLFVelocity=Data.LFVelocity-TargetLFVelocity.Value;

% RF Position Targets
TargetRFPosition=getVariable(mdlWks,"TargetRFPosition");
Data.TargetDeltaRFPosition=Data.RFPosition-TargetRFPosition.Value;

% RF Velocity Targets
TargetRFVelocity=getVariable(mdlWks,"TargetRFVelocity");
Data.TargetDeltaRFVelocity=Data.RFVelocity-TargetRFVelocity.Value;

% LW Position Targets
TargetLWPositionX=getVariable(mdlWks,"TargetLWPositionX");
Data.TargetDeltaLWPositionX=Data.LWPositionX-TargetLWPositionX.Value;
TargetLWPositionY=getVariable(mdlWks,"TargetLWPositionY");
Data.TargetDeltaLWPositionY=Data.LWPositionY-TargetLWPositionY.Value;

% LW Velocity Targets
TargetLWVelocityX=getVariable(mdlWks,"TargetLWVelocityX");
Data.TargetDeltaLWVelocityX=Data.LWVelocityX-TargetLWVelocityX.Value;
TargetLWVelocityY=getVariable(mdlWks,"TargetLWVelocityY");
Data.TargetDeltaLWVelocityY=Data.LWVelocityY-TargetLWVelocityY.Value;

% RW Position Targets
TargetRWPositionX=getVariable(mdlWks,"TargetRWPositionX");
Data.TargetDeltaRWPositionX=Data.RWPositionX-TargetRWPositionX.Value;
TargetRWPositionY=getVariable(mdlWks,"TargetRWPositionY");
Data.TargetDeltaRWPositionY=Data.RWPositionY-TargetRWPositionY.Value;

% RW Velocity Targets
TargetRWVelocityX=getVariable(mdlWks,"TargetRWVelocityX");
Data.TargetDeltaRWVelocityX=Data.RWVelocityX-TargetRWVelocityX.Value;
TargetRWVelocityY=getVariable(mdlWks,"TargetRWVelocityY");
Data.TargetDeltaRWVelocityY=Data.RWVelocityY-TargetRWVelocityY.Value;

clear GetValue;
clear TargetHipPositionX;
clear TargetHipPositionY;
clear TargetHipPositionZ;
clear TargetHipVelocityX;
clear TargetHipVelocityY;
clear TargetHipVelocityZ;
clear TargetTranslationPositionX;
clear TargetTranslationPositionY;
clear TargetTranslationPositionZ;
clear TargetTranslationVelocityX;
clear TargetTranslationVelocityY;
clear TargetTranslationVelocityZ;
clear TargetSpinePositionX;
clear TargetSpinePositionY;
clear TargetSpineVelocityX;
clear TargetSpineVelocityY;
clear TargetTorsoPosition;
clear TargetTorsoVelocity;
clear TargetLScapPositionX;
clear TargetLScapPositionY;
clear TargetLScapVelocityX;
clear TargetLScapVelocityY;
clear TargetRScapPositionX;
clear TargetRScapPositionY;
clear TargetRScapVelocityX;
clear TargetRScapVelocityY;
clear TargetLSPositionX;
clear TargetLSPositionY;
clear TargetLSPositionZ;
clear TargetLSVelocityX;
clear TargetLSVelocityY;
clear TargetLSVelocityZ;
clear TargetRSPositionX;
clear TargetRSPositionY;
clear TargetRSPositionZ;
clear TargetRSVelocityX;
clear TargetRSVelocityY;
clear TargetRSVelocityZ;
clear TargetLEPosition;
clear TargetLEVelocity;
clear TargetREPosition;
clear TargetREVelocity;
clear TargetLFPosition;
clear TargetLFVelocity;
clear TargetRFPosition;
clear TargetRFVelocity;
clear TargetLWPositionX;
clear TargetLWPositionY;
clear TargetLWVelocityX;
clear TargetLWVelocityY;
clear TargetRWPositionX;
clear TargetRWPositionY;
clear TargetRWVelocityX;
clear TargetRWVelocityY;
