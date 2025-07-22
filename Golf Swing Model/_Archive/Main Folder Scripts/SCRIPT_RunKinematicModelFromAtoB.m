cd(matlabdrive);
% This script loads impact state targets into the model workspace from the
% impact model and then loads the model into a top of backswing position.
% Then the model is kinematically driven between the two states.

cd 3DModel;
SCRIPT_LoadImpactStateTargets;
SCRIPT_LoadTopofBackswing

% Run kinematic model with the target values
cd(matlabdrive);
cd 3DModel;
assignin(mdlWks,'StopTime',Simulink.Parameter(0.2));
GolfSwing3D_KinematicallyDriven;
out=sim("GolfSwing3D_KinematicallyDriven.slx");