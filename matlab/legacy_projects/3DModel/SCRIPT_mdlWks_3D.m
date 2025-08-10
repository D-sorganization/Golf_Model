%SCRIPT_mdlWksGenerate.m;
mdlWks=get_param('GolfSwing3D_KinematicallyDriven','ModelWorkspace');
mdlWks.DataSource = 'MAT-File';
mdlWks.FileName = '3DModelInputs.mat';
cd(matlabdrive); %added to see if it fixes things
mdlWks.reload;
