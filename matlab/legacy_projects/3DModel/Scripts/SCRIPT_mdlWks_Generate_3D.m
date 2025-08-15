%SCRIPT_mdlWksGenerate.m;
mdlWks=get_param('GolfSwing3D_KineticallyDriven','ModelWorkspace');
mdlWks.DataSource = 'MAT-File';
mdlWks.FileName = '3DModelInputs.mat';
cd(matlabdrive);
cd '3DModel';
mdlWks.reload;
