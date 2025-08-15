%Master Script Plot:
PauseTime=0;

cd(matlabdrive);
cd '3DModel';
cd 'Scripts/_BaseData Scripts'/;
MASTER_SCRIPT_BaseDataCharts_3D;

cd(matlabdrive);
cd '3DModel';
cd 'Scripts/_ZTCF Scripts';
MASTER_SCRIPT_ZTCFCharts_3D;

cd(matlabdrive);
cd '3DModel';
cd 'Scripts/_Delta Scripts';
MASTER_SCRIPT_DeltaCharts_3D;

cd(matlabdrive);
cd '3DModel';
cd 'Scripts/_Comparison Scripts';
MASTER_SCRIPT_ComparisonCharts_3D;

cd(matlabdrive);
cd '3DModel';
cd 'Scripts/';
SCRIPT_ResultsFolderGeneration_3D;

cd(matlabdrive);
cd '3DModel';
cd 'Scripts/_ZVCF Scripts';
MASTER_SCRIPT_ZVCF_CHARTS_3D;

clear PauseTime;
