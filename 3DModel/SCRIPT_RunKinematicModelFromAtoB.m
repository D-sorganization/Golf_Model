origDir = pwd;
cleanup = onCleanup(@() cd(origDir));

% Load impact state targets and top of backswing data without changing directories
modelDir = fullfile(matlabdrive, '3DModel');
run(fullfile(modelDir, 'SCRIPT_LoadImpactStateTargets.m'));
run(fullfile(modelDir, 'SCRIPT_LoadTopofBackswing.m'));

% Run kinematic model with the target values
assignin(mdlWks, 'StopTime', Simulink.Parameter(0.2));
run(fullfile(modelDir, 'GolfSwing3D_KinematicallyDriven.m'));
modelPath = fullfile(modelDir, 'GolfSwing3D_KinematicallyDriven.slx');
out = sim(modelPath);
