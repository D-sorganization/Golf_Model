% This functions evaluates the error between the desired kinematics and the
% achieved kinematics. This difference is evaluated at the start and finish
% of the run to see how close to the desired change was achieved.

varsbefore=who;

StartTime=0;
TargetImpactTime=getVariable(mdlWks,"TargetImpactTime");

% Read the target deltas at time zero
InitialTargetDeltaHipPositionX=interp1(Data.Time,Data.TargetDeltaHipPositionX,StartTime,'linear');
InitialTargetDeltaHipPositionY=interp1(Data.Time,Data.TargetDeltaHipPositionY,StartTime,'linear');
InitialTargetDeltaHipPositionZ=interp1(Data.Time,Data.TargetDeltaHipPositionZ,StartTime,'linear');

InitialTargetDeltaTranslationPositionX=interp1(Data.Time,Data.TargetDeltaTranslationPositionX,StartTime,'linear');
InitialTargetDeltaTranslationPositionY=interp1(Data.Time,Data.TargetDeltaTranslationPositionY,StartTime,'linear');
InitialTargetDeltaTranslationPositionZ=interp1(Data.Time,Data.TargetDeltaTranslationPositionZ,StartTime,'linear');

InitialTargetDeltaSpinePositionX=interp1(Data.Time,Data.TargetDeltaSpinePositionX,StartTime,'linear');
InitialTargetDeltaSpinePositionY=interp1(Data.Time,Data.TargetDeltaSpinePositionY,StartTime,'linear');

InitialTargetDeltaTorsoPosition=interp1(Data.Time,Data.TargetDeltaTorsoPosition,StartTime,'linear');

InitialTargetDeltaLScapPositionX=interp1(Data.Time,Data.TargetDeltaLScapPositionX,StartTime,'linear');
InitialTargetDeltaLScapPositionY=interp1(Data.Time,Data.TargetDeltaLScapPositionY,StartTime,'linear');

InitialTargetDeltaRScapPositionX=interp1(Data.Time,Data.TargetDeltaRScapPositionX,StartTime,'linear');
InitialTargetDeltaRScapPositionY=interp1(Data.Time,Data.TargetDeltaRScapPositionY,StartTime,'linear');

InitialTargetDeltaLSPositionX=interp1(Data.Time,Data.TargetDeltaLSPositionX,StartTime,'linear');
InitialTargetDeltaLSPositionY=interp1(Data.Time,Data.TargetDeltaLSPositionY,StartTime,'linear');
InitialTargetDeltaLSPositionZ=interp1(Data.Time,Data.TargetDeltaLSPositionZ,StartTime,'linear');

InitialTargetDeltaRSPositionX=interp1(Data.Time,Data.TargetDeltaRSPositionX,StartTime,'linear');
InitialTargetDeltaRSPositionY=interp1(Data.Time,Data.TargetDeltaRSPositionY,StartTime,'linear');
InitialTargetDeltaRSPositionZ=interp1(Data.Time,Data.TargetDeltaRSPositionZ,StartTime,'linear');

InitialTargetDeltaLEPosition=interp1(Data.Time,Data.TargetDeltaLEPosition,StartTime,'linear');

InitialTargetDeltaREPosition=interp1(Data.Time,Data.TargetDeltaREPosition,StartTime,'linear');

InitialTargetDeltaLFPosition=interp1(Data.Time,Data.TargetDeltaLFPosition,StartTime,'linear');

InitialTargetDeltaRFPosition=interp1(Data.Time,Data.TargetDeltaRFPosition,StartTime,'linear');

InitialTargetDeltaLWPositionX=interp1(Data.Time,Data.TargetDeltaLWPositionX,StartTime,'linear');
InitialTargetDeltaLWPositionY=interp1(Data.Time,Data.TargetDeltaLWPositionY,StartTime,'linear');

InitialTargetDeltaRWPositionX=interp1(Data.Time,Data.TargetDeltaRWPositionX,StartTime,'linear');
InitialTargetDeltaRWPositionY=interp1(Data.Time,Data.TargetDeltaRWPositionY,StartTime,'linear');

InitialTargetDeltaHipVelocityX=interp1(Data.Time,Data.TargetDeltaHipVelocityX,StartTime,'linear');
InitialTargetDeltaHipVelocityY=interp1(Data.Time,Data.TargetDeltaHipVelocityY,StartTime,'linear');
InitialTargetDeltaHipVelocityZ=interp1(Data.Time,Data.TargetDeltaHipVelocityZ,StartTime,'linear');

InitialTargetDeltaTranslationVelocityX=interp1(Data.Time,Data.TargetDeltaTranslationVelocityX,StartTime,'linear');
InitialTargetDeltaTranslationVelocityY=interp1(Data.Time,Data.TargetDeltaTranslationVelocityY,StartTime,'linear');
InitialTargetDeltaTranslationVelocityZ=interp1(Data.Time,Data.TargetDeltaTranslationVelocityZ,StartTime,'linear');

InitialTargetDeltaSpineVelocityX=interp1(Data.Time,Data.TargetDeltaSpineVelocityX,StartTime,'linear');
InitialTargetDeltaSpineVelocityY=interp1(Data.Time,Data.TargetDeltaSpineVelocityY,StartTime,'linear');

InitialTargetDeltaTorsoVelocity=interp1(Data.Time,Data.TargetDeltaTorsoVelocity,StartTime,'linear');

InitialTargetDeltaLScapVelocityX=interp1(Data.Time,Data.TargetDeltaLScapVelocityX,StartTime,'linear');
InitialTargetDeltaLScapVelocityY=interp1(Data.Time,Data.TargetDeltaLScapVelocityY,StartTime,'linear');

InitialTargetDeltaRScapVelocityX=interp1(Data.Time,Data.TargetDeltaRScapVelocityX,StartTime,'linear');
InitialTargetDeltaRScapVelocityY=interp1(Data.Time,Data.TargetDeltaRScapVelocityY,StartTime,'linear');

InitialTargetDeltaLSVelocityX=interp1(Data.Time,Data.TargetDeltaLSVelocityX,StartTime,'linear');
InitialTargetDeltaLSVelocityY=interp1(Data.Time,Data.TargetDeltaLSVelocityY,StartTime,'linear');
InitialTargetDeltaLSVelocityZ=interp1(Data.Time,Data.TargetDeltaLSVelocityZ,StartTime,'linear');

InitialTargetDeltaRSVelocityX=interp1(Data.Time,Data.TargetDeltaRSVelocityX,StartTime,'linear');
InitialTargetDeltaRSVelocityY=interp1(Data.Time,Data.TargetDeltaRSVelocityY,StartTime,'linear');
InitialTargetDeltaRSVelocityZ=interp1(Data.Time,Data.TargetDeltaRSVelocityZ,StartTime,'linear');

InitialTargetDeltaLEVelocity=interp1(Data.Time,Data.TargetDeltaLEVelocity,StartTime,'linear');

InitialTargetDeltaREVelocity=interp1(Data.Time,Data.TargetDeltaREVelocity,StartTime,'linear');

InitialTargetDeltaLFVelocity=interp1(Data.Time,Data.TargetDeltaLFVelocity,StartTime,'linear');

InitialTargetDeltaRFVelocity=interp1(Data.Time,Data.TargetDeltaRFVelocity,StartTime,'linear');

InitialTargetDeltaLWVelocityX=interp1(Data.Time,Data.TargetDeltaLWVelocityX,StartTime,'linear');
InitialTargetDeltaLWVelocityY=interp1(Data.Time,Data.TargetDeltaLWVelocityY,StartTime,'linear');

InitialTargetDeltaRWVelocityX=interp1(Data.Time,Data.TargetDeltaRWVelocityX,StartTime,'linear');
InitialTargetDeltaRWVelocityY=interp1(Data.Time,Data.TargetDeltaRWVelocityY,StartTime,'linear');

% Read the Target Deltas at the Target Impact Time
% Read the target deltas at time zero
FinalTargetDeltaHipPositionX=interp1(Data.Time,Data.TargetDeltaHipPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaHipPositionY=interp1(Data.Time,Data.TargetDeltaHipPositionY,TargetImpactTime.Value,'linear');
FinalTargetDeltaHipPositionZ=interp1(Data.Time,Data.TargetDeltaHipPositionZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaTranslationPositionX=interp1(Data.Time,Data.TargetDeltaTranslationPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaTranslationPositionY=interp1(Data.Time,Data.TargetDeltaTranslationPositionY,TargetImpactTime.Value,'linear');
FinalTargetDeltaTranslationPositionZ=interp1(Data.Time,Data.TargetDeltaTranslationPositionZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaSpinePositionX=interp1(Data.Time,Data.TargetDeltaSpinePositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaSpinePositionY=interp1(Data.Time,Data.TargetDeltaSpinePositionY,TargetImpactTime.Value,'linear');

FinalTargetDeltaTorsoPosition=interp1(Data.Time,Data.TargetDeltaTorsoPosition,TargetImpactTime.Value,'linear');

FinalTargetDeltaLScapPositionX=interp1(Data.Time,Data.TargetDeltaLScapPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaLScapPositionY=interp1(Data.Time,Data.TargetDeltaLScapPositionY,TargetImpactTime.Value,'linear');

FinalTargetDeltaRScapPositionX=interp1(Data.Time,Data.TargetDeltaRScapPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaRScapPositionY=interp1(Data.Time,Data.TargetDeltaRScapPositionY,TargetImpactTime.Value,'linear');

FinalTargetDeltaLSPositionX=interp1(Data.Time,Data.TargetDeltaLSPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaLSPositionY=interp1(Data.Time,Data.TargetDeltaLSPositionY,TargetImpactTime.Value,'linear');
FinalTargetDeltaLSPositionZ=interp1(Data.Time,Data.TargetDeltaLSPositionZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaRSPositionX=interp1(Data.Time,Data.TargetDeltaRSPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaRSPositionY=interp1(Data.Time,Data.TargetDeltaRSPositionY,TargetImpactTime.Value,'linear');
FinalTargetDeltaRSPositionZ=interp1(Data.Time,Data.TargetDeltaRSPositionZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaLEPosition=interp1(Data.Time,Data.TargetDeltaLEPosition,TargetImpactTime.Value,'linear');

FinalTargetDeltaREPosition=interp1(Data.Time,Data.TargetDeltaREPosition,TargetImpactTime.Value,'linear');

FinalTargetDeltaLFPosition=interp1(Data.Time,Data.TargetDeltaLFPosition,TargetImpactTime.Value,'linear');

FinalTargetDeltaRFPosition=interp1(Data.Time,Data.TargetDeltaRFPosition,TargetImpactTime.Value,'linear');

FinalTargetDeltaLWPositionX=interp1(Data.Time,Data.TargetDeltaLWPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaLWPositionY=interp1(Data.Time,Data.TargetDeltaLWPositionY,TargetImpactTime.Value,'linear');

FinalTargetDeltaRWPositionX=interp1(Data.Time,Data.TargetDeltaRWPositionX,TargetImpactTime.Value,'linear');
FinalTargetDeltaRWPositionY=interp1(Data.Time,Data.TargetDeltaRWPositionY,TargetImpactTime.Value,'linear');

FinalTargetDeltaHipVelocityX=interp1(Data.Time,Data.TargetDeltaHipVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaHipVelocityY=interp1(Data.Time,Data.TargetDeltaHipVelocityY,TargetImpactTime.Value,'linear');
FinalTargetDeltaHipVelocityZ=interp1(Data.Time,Data.TargetDeltaHipVelocityZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaTranslationVelocityX=interp1(Data.Time,Data.TargetDeltaTranslationVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaTranslationVelocityY=interp1(Data.Time,Data.TargetDeltaTranslationVelocityY,TargetImpactTime.Value,'linear');
FinalTargetDeltaTranslationVelocityZ=interp1(Data.Time,Data.TargetDeltaTranslationVelocityZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaSpineVelocityX=interp1(Data.Time,Data.TargetDeltaSpineVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaSpineVelocityY=interp1(Data.Time,Data.TargetDeltaSpineVelocityY,TargetImpactTime.Value,'linear');

FinalTargetDeltaTorsoVelocity=interp1(Data.Time,Data.TargetDeltaTorsoVelocity,TargetImpactTime.Value,'linear');

FinalTargetDeltaLScapVelocityX=interp1(Data.Time,Data.TargetDeltaLScapVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaLScapVelocityY=interp1(Data.Time,Data.TargetDeltaLScapVelocityY,TargetImpactTime.Value,'linear');

FinalTargetDeltaRScapVelocityX=interp1(Data.Time,Data.TargetDeltaRScapVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaRScapVelocityY=interp1(Data.Time,Data.TargetDeltaRScapVelocityY,TargetImpactTime.Value,'linear');

FinalTargetDeltaLSVelocityX=interp1(Data.Time,Data.TargetDeltaLSVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaLSVelocityY=interp1(Data.Time,Data.TargetDeltaLSVelocityY,TargetImpactTime.Value,'linear');
FinalTargetDeltaLSVelocityZ=interp1(Data.Time,Data.TargetDeltaLSVelocityZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaRSVelocityX=interp1(Data.Time,Data.TargetDeltaRSVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaRSVelocityY=interp1(Data.Time,Data.TargetDeltaRSVelocityY,TargetImpactTime.Value,'linear');
FinalTargetDeltaRSVelocityZ=interp1(Data.Time,Data.TargetDeltaRSVelocityZ,TargetImpactTime.Value,'linear');

FinalTargetDeltaLEVelocity=interp1(Data.Time,Data.TargetDeltaLEVelocity,TargetImpactTime.Value,'linear');

FinalTargetDeltaREVelocity=interp1(Data.Time,Data.TargetDeltaREVelocity,TargetImpactTime.Value,'linear');

FinalTargetDeltaLFVelocity=interp1(Data.Time,Data.TargetDeltaLFVelocity,TargetImpactTime.Value,'linear');

FinalTargetDeltaRFVelocity=interp1(Data.Time,Data.TargetDeltaRFVelocity,TargetImpactTime.Value,'linear');

FinalTargetDeltaLWVelocityX=interp1(Data.Time,Data.TargetDeltaLWVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaLWVelocityY=interp1(Data.Time,Data.TargetDeltaLWVelocityY,TargetImpactTime.Value,'linear');

FinalTargetDeltaRWVelocityX=interp1(Data.Time,Data.TargetDeltaRWVelocityX,TargetImpactTime.Value,'linear');
FinalTargetDeltaRWVelocityY=interp1(Data.Time,Data.TargetDeltaRWVelocityY,TargetImpactTime.Value,'linear');

% Create Adjustment Factors that are Scaled Off Prior Fractional Progress
% Then write this value to the model workspace for reference by functions

% I need the adjustment deltas to write to the model workspace control
% gains instead of the new adjustment delta model workspace parameters. Use
% what already exists.


HipPCGainX=1/(1-FinalTargetDeltaHipPositionX/InitialTargetDeltaHipPositionX);
assignin(mdlWks,"HipPCGainX",Simulink.Parameter(HipPCGainX));
HipPCGainY=1/(1-FinalTargetDeltaHipPositionY/InitialTargetDeltaHipPositionY);
assignin(mdlWks,"HipPCGainY",Simulink.Parameter(HipPCGainY));
HipPCGainZ=1/(1-FinalTargetDeltaHipPositionZ/InitialTargetDeltaHipPositionZ);
assignin(mdlWks,"HipPCGainZ",Simulink.Parameter(HipPCGainZ));

HipVCGainX=1/(1-FinalTargetDeltaHipVelocityX/InitialTargetDeltaHipVelocityX);
assignin(mdlWks,"HipVCGainX",Simulink.Parameter(HipVCGainX));
HipVCGainY=1/(1-FinalTargetDeltaHipVelocityY/InitialTargetDeltaHipVelocityY);
assignin(mdlWks,"HipVCGainY",Simulink.Parameter(HipVCGainY));
HipVCGainZ=1/(1-FinalTargetDeltaHipVelocityZ/InitialTargetDeltaHipVelocityZ);
assignin(mdlWks,"HipVCGainZ",Simulink.Parameter(HipVCGainZ));

% The translation adjustments are cancelled out because there is a divide
% by zero issue that occurs and all of the adjustments become infinite.
% This is caused by the initial delta being zero but it appears difficult
% to change.
%
% TranslationPCGainX=1/(1-FinalTargetDeltaTranslationPositionX/InitialTargetDeltaTranslationPositionX);
% assignin(mdlWks,"TranslationPCGainX",Simulink.Parameter(TranslationPCGainX));
% TranslationPCGainY=1/(1-FinalTargetDeltaTranslationPositionY/InitialTargetDeltaTranslationPositionY);
% assignin(mdlWks,"TranslationPCGainY",Simulink.Parameter(TranslationPCGainY));
% TranslationPCGainZ=1/(1-FinalTargetDeltaTranslationPositionZ/InitialTargetDeltaTranslationPositionZ);
% assignin(mdlWks,"TranslationPCGainZ",Simulink.Parameter(TranslationPCGainZ));
% 
% TranslationVCGainX=1/(1-FinalTargetDeltaTranslationVelocityX/InitialTargetDeltaTranslationVelocityX);
% assignin(mdlWks,"TranslationVCGainX",Simulink.Parameter(TranslationVCGainX));
% TranslationVCGainY=1/(1-FinalTargetDeltaTranslationVelocityY/InitialTargetDeltaTranslationVelocityY);
% assignin(mdlWks,"TranslationVCGainY",Simulink.Parameter(TranslationVCGainY));
% TranslationVCGainZ=1/(1-FinalTargetDeltaTranslationVelocityZ/InitialTargetDeltaTranslationVelocityZ);
% assignin(mdlWks,"TranslationVCGainZ",Simulink.Parameter(TranslationVCGainZ));

SpinePCGainX=1/(1-FinalTargetDeltaSpinePositionX/InitialTargetDeltaSpinePositionX);
assignin(mdlWks,"SpinePCGainX",Simulink.Parameter(SpinePCGainX));
SpinePCGainY=1/(1-FinalTargetDeltaSpinePositionY/InitialTargetDeltaSpinePositionY);
assignin(mdlWks,"SpinePCGainY",Simulink.Parameter(SpinePCGainY));

SpineVCGainX=1/(1-FinalTargetDeltaSpineVelocityX/InitialTargetDeltaSpineVelocityX);
assignin(mdlWks,"SpineVCGainX",Simulink.Parameter(SpineVCGainX));
SpineVCGainY=1/(1-FinalTargetDeltaSpineVelocityY/InitialTargetDeltaSpineVelocityY);
assignin(mdlWks,"SpineVCGainY",Simulink.Parameter(SpineVCGainY));

TorsoPCGain=1/(1-FinalTargetDeltaTorsoPosition/InitialTargetDeltaTorsoPosition);
assignin(mdlWks,"TorsoPCGain",Simulink.Parameter(TorsoPCGain));

TorsoVCGain=1/(1-FinalTargetDeltaTorsoVelocity/InitialTargetDeltaTorsoVelocity);
assignin(mdlWks,"TorsoVCGain",Simulink.Parameter(TorsoVCGain));

LScapPCGainX=1/(1-FinalTargetDeltaLScapPositionX/InitialTargetDeltaLScapPositionX);
assignin(mdlWks,"LScapPCGainX",Simulink.Parameter(LScapPCGainX));
LScapPCGainY=1/(1-FinalTargetDeltaLScapPositionY/InitialTargetDeltaLScapPositionY);
assignin(mdlWks,"LScapPCGainY",Simulink.Parameter(LScapPCGainY));

LScapVCGainX=1/(1-FinalTargetDeltaLScapVelocityX/InitialTargetDeltaLScapVelocityX);
assignin(mdlWks,"LScapVCGainX",Simulink.Parameter(LScapVCGainX));
LScapVCGainY=1/(1-FinalTargetDeltaLScapVelocityY/InitialTargetDeltaLScapVelocityY);
assignin(mdlWks,"LScapVCGainY",Simulink.Parameter(LScapVCGainY));

RScapPCGainX=1/(1-FinalTargetDeltaRScapPositionX/InitialTargetDeltaRScapPositionX);
assignin(mdlWks,"RScapPCGainX",Simulink.Parameter(RScapPCGainX));
RScapPCGainY=1/(1-FinalTargetDeltaRScapPositionY/InitialTargetDeltaRScapPositionY);
assignin(mdlWks,"RScapPCGainY",Simulink.Parameter(RScapPCGainY));

RScapVCGainX=1/(1-FinalTargetDeltaRScapVelocityX/InitialTargetDeltaRScapVelocityX);
assignin(mdlWks,"RScapVCGainX",Simulink.Parameter(RScapVCGainX));
RScapVCGainY=1/(1-FinalTargetDeltaRScapVelocityY/InitialTargetDeltaRScapVelocityY);
assignin(mdlWks,"RScapVCGainY",Simulink.Parameter(RScapVCGainY));

LSPCGainX=1/(1-FinalTargetDeltaLSPositionX/InitialTargetDeltaLSPositionX);
assignin(mdlWks,"LSPCGainX",Simulink.Parameter(LSPCGainX));
LSPCGainY=1/(1-FinalTargetDeltaLSPositionY/InitialTargetDeltaLSPositionY);
assignin(mdlWks,"LSPCGainY",Simulink.Parameter(LSPCGainY));
LSPCGainZ=1/(1-FinalTargetDeltaLSPositionZ/InitialTargetDeltaLSPositionZ);
assignin(mdlWks,"LSPCGainZ",Simulink.Parameter(LSPCGainZ));

LSVCGainX=1/(1-FinalTargetDeltaLSVelocityX/InitialTargetDeltaLSVelocityX);
assignin(mdlWks,"LSVCGainX",Simulink.Parameter(LSVCGainX));
LSVCGainY=1/(1-FinalTargetDeltaLSVelocityY/InitialTargetDeltaLSVelocityY);
assignin(mdlWks,"LSVCGainY",Simulink.Parameter(LSVCGainY));
LSVCGainZ=1/(1-FinalTargetDeltaLSVelocityZ/InitialTargetDeltaLSVelocityZ);
assignin(mdlWks,"LSVCGainZ",Simulink.Parameter(LSVCGainZ));

RSPCGainX=1/(1-FinalTargetDeltaRSPositionX/InitialTargetDeltaRSPositionX);
assignin(mdlWks,"RSPCGainX",Simulink.Parameter(RSPCGainX));
RSPCGainY=1/(1-FinalTargetDeltaRSPositionY/InitialTargetDeltaRSPositionY);
assignin(mdlWks,"RSPCGainY",Simulink.Parameter(RSPCGainY));
RSPCGainZ=1/(1-FinalTargetDeltaRSPositionZ/InitialTargetDeltaRSPositionZ);
assignin(mdlWks,"RSPCGainZ",Simulink.Parameter(RSPCGainZ));

RSVCGainX=1/(1-FinalTargetDeltaRSVelocityX/InitialTargetDeltaRSVelocityX);
assignin(mdlWks,"RSVCGainX",Simulink.Parameter(RSVCGainX));
RSVCGainY=1/(1-FinalTargetDeltaRSVelocityY/InitialTargetDeltaRSVelocityY);
assignin(mdlWks,"RSVCGainY",Simulink.Parameter(RSVCGainY));
RSVCGainZ=1/(1-FinalTargetDeltaRSVelocityZ/InitialTargetDeltaRSVelocityZ);
assignin(mdlWks,"RSVCGainZ",Simulink.Parameter(RSVCGainZ));

LEPCGain=1/(1-FinalTargetDeltaLEPosition/InitialTargetDeltaLEPosition);
assignin(mdlWks,"LEPCGain",Simulink.Parameter(LEPCGain));

LEVCGain=1/(1-FinalTargetDeltaLEVelocity/InitialTargetDeltaLEVelocity);
assignin(mdlWks,"LEVCGain",Simulink.Parameter(LEVCGain));

REPCGain=1/(1-FinalTargetDeltaREPosition/InitialTargetDeltaREPosition);
assignin(mdlWks,"REPCGain",Simulink.Parameter(REPCGain));

REVCGain=1/(1-FinalTargetDeltaREVelocity/InitialTargetDeltaREVelocity);
assignin(mdlWks,"REVCGain",Simulink.Parameter(REVCGain));

LFPCGain=1/(1-FinalTargetDeltaLFPosition/InitialTargetDeltaLFPosition);
assignin(mdlWks,"LFPCGain",Simulink.Parameter(LFPCGain));

LFVCGain=1/(1-FinalTargetDeltaLFVelocity/InitialTargetDeltaLFVelocity);
assignin(mdlWks,"LFVCGain",Simulink.Parameter(LFVCGain));

RFPCGain=1/(1-FinalTargetDeltaRFPosition/InitialTargetDeltaRFPosition);
assignin(mdlWks,"RFPCGain",Simulink.Parameter(RFPCGain));

RFVCGain=1/(1-FinalTargetDeltaRFVelocity/InitialTargetDeltaRFVelocity);
assignin(mdlWks,"RFVCGain",Simulink.Parameter(RFVCGain));

LWPCGainX=1/(1-FinalTargetDeltaLWPositionX/InitialTargetDeltaLWPositionX);
assignin(mdlWks,"LWPCGainX",Simulink.Parameter(LWPCGainX));
LWPCGainY=1/(1-FinalTargetDeltaLWPositionY/InitialTargetDeltaLWPositionY);
assignin(mdlWks,"LWPCGainY",Simulink.Parameter(LWPCGainY));

LWVCGainX=1/(1-FinalTargetDeltaLWVelocityX/InitialTargetDeltaLWVelocityX);
assignin(mdlWks,"LWVCGainX",Simulink.Parameter(LWVCGainX));
LWVCGainY=1/(1-FinalTargetDeltaLWVelocityY/InitialTargetDeltaLWVelocityY);
assignin(mdlWks,"LWVCGainY",Simulink.Parameter(LWVCGainY));

RWPCGainX=1/(1-FinalTargetDeltaRWPositionX/InitialTargetDeltaRWPositionX);
assignin(mdlWks,"RWPCGainX",Simulink.Parameter(RWPCGainX));
RWPCGainY=1/(1-FinalTargetDeltaRWPositionY/InitialTargetDeltaRWPositionY);
assignin(mdlWks,"RWPCGainY",Simulink.Parameter(RWPCGainY));

RWVCGainX=1/(1-FinalTargetDeltaRWVelocityX/InitialTargetDeltaRWVelocityX);
assignin(mdlWks,"RWVCGainX",Simulink.Parameter(RWVCGainX));
RWVCGainY=1/(1-FinalTargetDeltaRWVelocityY/InitialTargetDeltaRWVelocityY);
assignin(mdlWks,"RWVCGainY",Simulink.Parameter(RWVCGainY));

varsafter=[];
varsnew=[];
varsafter=who;
varsnew=setdiff(varsafter,varsbefore);
clear(varsnew{:});

% Save Model Workspace
save(mdlWks,'3DModelInputs.mat')














