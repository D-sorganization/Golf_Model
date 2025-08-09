% ZVCF Data Generation Script
% 
% This script generates the data for a scenario in which you take the
% applied joint torques at any given point in the swing and apply them to a
% golfer in the same static pose. "Zero Velocity Counterfactual". This can
% be done with and without gravity on by changing the GolfSwing3D_ZVCF model
% solver settings. The reason for computing without gravity is that the
% ZVCF adds up to the Delta (the difference between the base swing and
% ZTCF) when gravity isn't counted twice. As the system is a series of
% linear differential equations, the principle of superposition applies and
% the net effect of all actions on the system is additive. In the ZTCF
% gravity is included as one of the passive contributors (along with shaft
% flex and momentum). In principle, the ZVCF is the effect of the joint
% torques on the interaction forces everywhere in the swing.

% The ZVCF is calculated by importing starting positions / pose of the
% model and assigning all velocities to be zero. The joint torques are
% applied as constant values and the joint interaction forces are
% calculated at time zero and tabulated. 

cd(matlabdrive);
cd '3DModel';
warning off Simulink:cgxe:LeakedJITEngine;

% This section is commented out as the ZVCF approach has changed. Rather
% than using a different set of model inputs, the ZVCF values are being
% written to the same model input file used for the kinetic model. The
% functionality of the model is being changed to use the modeling mode
% selection to determine the source of the joint torques applied. In
% modelling mode is anything other than 0,1,2,3 then the ZVCF values are
% used as the output forces / torques from the joints.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Copy the model inputs file that was used to generate the ZTCF and run the
% % GolfSwing model previously. Write it to the ZVCF scripts folder
% % temporarily.
% copyfile 3DModelInputs.mat 'Scripts'/'_ZVCF Scripts'/;
% cd("Scripts/_ZVCF Scripts/");
% % Rename the file using the movefile function
% movefile '3DModelInputs.mat' '3DModelInputs_ZVCF.mat';
% % Move the file using the copyfile function
% cd(matlabdrive);
% cd '3DModel';
% copyfile Scripts/'_ZVCF Scripts'/'3DModelInputs_ZVCF.mat';
% 
% % Delete the file that was copied into the ZVCF Scripts folder
% cd(matlabdrive);
% cd '3DModel';
% cd 'Scripts/';
% cd '_ZVCF Scripts';
% delete '3DModelInputs_ZVCF.mat';
%  
% % Go back to the main folder. Open GolfSwing3D_ZVCF model. The model needs to be
% % set to look for ModelInputs_ZVCF when it is opened.
% cd(matlabdrive);
% cd '3DModel';
% GolfSwing3D_ZVCF

% Load mdlWks for ZVCF Model from File
cd(matlabdrive);
cd '3DModel';
mdlWks=get_param('GolfSwing3D_KineticallyDriven','ModelWorkspace');
mdlWks.DataSource = 'MAT-File';
mdlWks.FileName = '3DModelInputs.mat';
mdlWks.reload;

% Set up the model simulation parameters.
set_param(GolfSwing3D_KineticallyDriven,"ReturnWorkspaceOutputs","on");
set_param(GolfSwing3D_KineticallyDriven,"FastRestart","off");
set_param(GolfSwing3D_KineticallyDriven,"MaxStep","0.001");

%Turn off the warning that a directory already exists when you create it.
warning('off', 'MATLAB:MKDIR:DirectoryExists');
warning off Simulink:Masking:NonTunableParameterChangedDuringSimulation;
warning off Simulink:Engine:NonTunableVarChangedInFastRestart;
warning off Simulink:Engine:NonTunableVarChangedMaxWarnings;

%Set the killswitch time to 1 second so it doesn't ever trigger
assignin(mdlWks,'KillswitchStepTime',Simulink.Parameter(1));
assignin(mdlWks,'StopTime',Simulink.Parameter(0.05));
assignin(mdlWks,'ModelingMode',Simulink.Parameter(9));
% Run the model to generate data table. Save model output as "out".
out=sim("GolfSwing3D_KineticallyDriven");

% Run Table Generation Script on "out"
cd(matlabdrive);
cd '3DModel/Scripts/'
SCRIPT_TableGeneration_3D;

% Copy Data to ZTCF Table to Get Variable Names
ZVCFTable=Data; %Create a table called ZTCFTable from Data.
ZVCFTable(:,:)=[]; %Delete All Data in ZTCF Table and Replace with Blanks 

%Now we have a table with all of the right columns and variables that can
%be written to from the output of the ZVCF model when it generates data.
%The script runs up to this point and does what it needs to do.
%
% The general approach will be to provide the model with input positions
% and joint torques. Then the model will be simulated and the values from
% time zero will be copied into the ZVCF table generated to receive data
% above. The only issue is that all times will be zero. The time will then
% be generated using the step time data from the loop once the row has been
% copied. 

% Begin Generation of ZVCF Data by Looping

    %Pick i and j based on number of data points to run ZVCF at.
    %for i=0:280
    for i=0:28

    %Scale counter to match desired times
    %j=i/1000;
    j=i/100;

    %Display Percentage
    %ZVCFPercentComplete=i/280*100
    ZVCFPercentComplete=i/28*100

    % Read the joint torque values at the counter time
    HipTorqueX=interp1(BASE.Time,BASE.HipTorqueXInput,j,'linear');
    HipTorqueY=interp1(BASE.Time,BASE.HipTorqueYInput,j,'linear');
    HipTorqueZ=interp1(BASE.Time,BASE.HipTorqueZInput,j,'linear');
    TranslationForceX=interp1(BASE.Time,BASE.TranslationForceXInput,j,'linear');
    TranslationForceY=interp1(BASE.Time,BASE.TranslationForceYInput,j,'linear');
    TranslationForceZ=interp1(BASE.Time,BASE.TranslationForceZInput,j,'linear');
    TorsoTorque=interp1(BASE.Time,BASE.TorsoTorqueInput,j,'linear');
    SpineTorqueX=interp1(BASE.Time,BASE.SpineTorqueXInput,j,'linear');
    SpineTorqueY=interp1(BASE.Time,BASE.SpineTorqueYInput,j,'linear');
    LScapTorqueX=interp1(BASE.Time,BASE.LScapTorqueXInput,j,'linear');
    LScapTorqueY=interp1(BASE.Time,BASE.LScapTorqueYInput,j,'linear');
    RScapTorqueX=interp1(BASE.Time,BASE.RScapTorqueXInput,j,'linear');
    RScapTorqueY=interp1(BASE.Time,BASE.RScapTorqueYInput,j,'linear');   
    LSTorqueX=interp1(BASE.Time,BASE.LSTorqueXInput,j,'linear');
    LSTorqueY=interp1(BASE.Time,BASE.LSTorqueYInput,j,'linear');
    LSTorqueZ=interp1(BASE.Time,BASE.LSTorqueZInput,j,'linear');
    RSTorqueX=interp1(BASE.Time,BASE.RSTorqueXInput,j,'linear');
    RSTorqueY=interp1(BASE.Time,BASE.RSTorqueYInput,j,'linear');
    RSTorqueZ=interp1(BASE.Time,BASE.RSTorqueZInput,j,'linear');
    LETorque=interp1(BASE.Time,BASE.LETorqueInput,j,'linear');
    RETorque=interp1(BASE.Time,BASE.RETorqueInput,j,'linear');
    LFTorque=interp1(BASE.Time,BASE.LFTorqueInput,j,'linear');
    RFTorque=interp1(BASE.Time,BASE.RFTorqueInput,j,'linear');
    LWTorqueX=interp1(BASE.Time,BASE.LWTorqueXInput,j,'linear');
    LWTorqueY=interp1(BASE.Time,BASE.LWTorqueYInput,j,'linear');
    RWTorqueX=interp1(BASE.Time,BASE.RWTorqueXInput,j,'linear');
    RWTorqueY=interp1(BASE.Time,BASE.RWTorqueYInput,j,'linear');
    
    %Read the position values at the counter time and convert to degrees
    HipPositionX=interp1(BASE.Time,BASE.HipPositionX,j,'linear');
    HipPositionY=interp1(BASE.Time,BASE.HipPositionY,j,'linear');
    HipPositionZ=interp1(BASE.Time,BASE.HipPositionZ,j,'linear');
    HipGlobalPositionX=interp1(BASE.Time,BASE.HipGlobalPositionX,j,'linear');
    HipGlobalPositionY=interp1(BASE.Time,BASE.HipGlobalPositionY,j,'linear');
    HipGlobalPositionZ=interp1(BASE.Time,BASE.HipGlobalPositionZ,j,'linear'); 
    TorsoPosition=interp1(BASE.Time,BASE.TorsoPosition,j,'linear');
    SpinePositionX=interp1(BASE.Time,BASE.SpinePositionX,j,'linear');
    SpinePositionY=interp1(BASE.Time,BASE.SpinePositionY,j,'linear');
    LScapPositionX=interp1(BASE.Time,BASE.LScapPositionX,j,'linear');
    LScapPositionY=interp1(BASE.Time,BASE.LScapPositionY,j,'linear');
    RScapPositionX=interp1(BASE.Time,BASE.RScapPositionX,j,'linear');
    RScapPositionY=interp1(BASE.Time,BASE.RScapPositionY,j,'linear');
    LSPositionX=interp1(BASE.Time,BASE.LSPositionX,j,'linear');
    LSPositionY=interp1(BASE.Time,BASE.LSPositionY,j,'linear');
    LSPositionZ=interp1(BASE.Time,BASE.LSPositionZ,j,'linear');
    RSPositionX=interp1(BASE.Time,BASE.RSPositionX,j,'linear');
    RSPositionY=interp1(BASE.Time,BASE.RSPositionY,j,'linear');
    RSPositionZ=interp1(BASE.Time,BASE.RSPositionZ,j,'linear');
    LEPosition=interp1(BASE.Time,BASE.LEPosition,j,'linear');
    REPosition=interp1(BASE.Time,BASE.REPosition,j,'linear');
    LFPosition=interp1(BASE.Time,BASE.LFPosition,j,'linear');
    RFPosition=interp1(BASE.Time,BASE.RFPosition,j,'linear');
    LWPositionX=interp1(BASE.Time,BASE.LWPositionX,j,'linear');
    LWPositionY=interp1(BASE.Time,BASE.LWPositionY,j,'linear');
    RWPositionX=interp1(BASE.Time,BASE.RWPositionX,j,'linear');
    RWPositionY=interp1(BASE.Time,BASE.RWPositionY,j,'linear');

    % Assign in the torque values to the model workspace
    assignin(mdlWks,'ZVCFHipTorqueX',Simulink.Parameter(HipTorqueX));
    assignin(mdlWks,'ZVCFHipTorqueY',Simulink.Parameter(HipTorqueY));
    assignin(mdlWks,'ZVCFHipTorqueZ',Simulink.Parameter(HipTorqueZ));
    assignin(mdlWks,'ZVCFTranslationForceX',Simulink.Parameter(TranslationForceX));
    assignin(mdlWks,'ZVCFTranslationForceY',Simulink.Parameter(TranslationForceY));
    assignin(mdlWks,'ZVCFTranslationForceZ',Simulink.Parameter(TranslationForceZ));
    assignin(mdlWks,'ZVCFTorsoTorque',Simulink.Parameter(TorsoTorque));
    assignin(mdlWks,'ZVCFSpineTorqueX',Simulink.Parameter(SpineTorqueX));
    assignin(mdlWks,'ZVCFSpineTorqueY',Simulink.Parameter(SpineTorqueY));
    assignin(mdlWks,'ZVCFLScapTorqueX',Simulink.Parameter(LScapTorqueX));
    assignin(mdlWks,'ZVCFLScapTorqueY',Simulink.Parameter(LScapTorqueY));
    assignin(mdlWks,'ZVCFRScapTorqueX',Simulink.Parameter(RScapTorqueX));
    assignin(mdlWks,'ZVCFRScapTorqueY',Simulink.Parameter(RScapTorqueY));
    assignin(mdlWks,'ZVCFLSTorqueX',Simulink.Parameter(LSTorqueX));
    assignin(mdlWks,'ZVCFLSTorqueY',Simulink.Parameter(LSTorqueY));
    assignin(mdlWks,'ZVCFLSTorqueZ',Simulink.Parameter(LSTorqueZ));  
    assignin(mdlWks,'ZVCFRSTorqueX',Simulink.Parameter(RSTorqueX));
    assignin(mdlWks,'ZVCFRSTorqueY',Simulink.Parameter(RSTorqueY));
    assignin(mdlWks,'ZVCFRSTorqueZ',Simulink.Parameter(RSTorqueZ));
    assignin(mdlWks,'ZVCFLETorque',Simulink.Parameter(LETorque));
    assignin(mdlWks,'ZVCFRETorque',Simulink.Parameter(RETorque));
    assignin(mdlWks,'ZVCFLFTorque',Simulink.Parameter(LFTorque));
    assignin(mdlWks,'ZVCFRFTorque',Simulink.Parameter(RFTorque));
    assignin(mdlWks,'ZVCFLWTorqueX',Simulink.Parameter(LWTorqueX));
    assignin(mdlWks,'ZVCFLWTorqueY',Simulink.Parameter(LWTorqueY));
    assignin(mdlWks,'ZVCFRWTorqueX',Simulink.Parameter(RWTorqueX));
    assignin(mdlWks,'ZVCFRWTorqueY',Simulink.Parameter(RWTorqueY));
    
    % Assign in position and velocity values to the model workspace
    assignin(mdlWks,'HipStartPositionX',Simulink.Parameter(HipPositionX));
    assignin(mdlWks,'HipStartPositionY',Simulink.Parameter(HipPositionY));
    assignin(mdlWks,'HipStartPositionZ',Simulink.Parameter(HipPositionZ));
    assignin(mdlWks,'HipStartVelocityX',Simulink.Parameter(0));
    assignin(mdlWks,'HipStartVelocityY',Simulink.Parameter(0));
    assignin(mdlWks,'HipStartVelocityZ',Simulink.Parameter(0));
    assignin(mdlWks,'TranslationStartPositionX',Simulink.Parameter(HipGlobalPositionX));
    assignin(mdlWks,'TranslationStartPositionY',Simulink.Parameter(HipGlobalPositionY));
    assignin(mdlWks,'TranslationStartPositionZ',Simulink.Parameter(HipGlobalPositionZ));
    assignin(mdlWks,'TranslationStartVelocityX',Simulink.Parameter(0));
    assignin(mdlWks,'TranslationStartVelocityY',Simulink.Parameter(0));
    assignin(mdlWks,'TranslationStartVelocityZ',Simulink.Parameter(0));
    assignin(mdlWks,'TorsoStartPosition',Simulink.Parameter(TorsoPosition));
    assignin(mdlWks,'TorsoStartVelocity',Simulink.Parameter(0));
    assignin(mdlWks,'LScapStartPositionX',Simulink.Parameter(LScapPositionX));
    assignin(mdlWks,'LScapStartPositionY',Simulink.Parameter(LScapPositionY));
    assignin(mdlWks,'LScapStartVelocityX',Simulink.Parameter(0));
    assignin(mdlWks,'LScapStartVelocityY',Simulink.Parameter(0));
    assignin(mdlWks,'RScapStartPositionX',Simulink.Parameter(RScapPositionX));
    assignin(mdlWks,'RScapStartPositionY',Simulink.Parameter(RScapPositionY));
    assignin(mdlWks,'RScapStartVelocityX',Simulink.Parameter(0));
    assignin(mdlWks,'RScapStartVelocityY',Simulink.Parameter(0));   
    assignin(mdlWks,'LEStartPosition',Simulink.Parameter(LEPosition));
    assignin(mdlWks,'LEStartVelocity',Simulink.Parameter(0));
    assignin(mdlWks,'REStartPosition',Simulink.Parameter(REPosition));
    assignin(mdlWks,'REStartVelocity',Simulink.Parameter(0));
    assignin(mdlWks,'LFStartPosition',Simulink.Parameter(LFPosition));
    assignin(mdlWks,'LFStartVelocity',Simulink.Parameter(0));
    assignin(mdlWks,'RFStartPosition',Simulink.Parameter(RFPosition));
    assignin(mdlWks,'RFStartVelocity',Simulink.Parameter(0));
    assignin(mdlWks,'LWStartPositionX',Simulink.Parameter(LWPositionX));
    assignin(mdlWks,'LWStartPositionY',Simulink.Parameter(LWPositionY));
    assignin(mdlWks,'LWStartVelocityX',Simulink.Parameter(0));
    assignin(mdlWks,'LWStartVelocityY',Simulink.Parameter(0));
    assignin(mdlWks,'RWStartPositionX',Simulink.Parameter(RWPositionX));
    assignin(mdlWks,'RWStartPositionY',Simulink.Parameter(RWPositionY));
    assignin(mdlWks,'RWStartVelocityX',Simulink.Parameter(0));
    assignin(mdlWks,'RWStartVelocityY',Simulink.Parameter(0));

    % Run the model to generate data table. Save model output as "out".
    out=sim("GolfSwing3D_KineticallyDriven");

    % Run Table Generation Script on "out"
    cd 'Scripts';
    SCRIPT_TableGeneration_3D;

    % Write the first row in the Data table to the ZVCFTable
    CopyRow=Data(1,:);
    CopyRow{1,1}=j;
    ZVCFTable=[ZVCFTable;CopyRow];

    end

    assignin(mdlWks,'ModelingMode',Simulink.Parameter(3));

    clear i;
    clear j;
    clear HipTorqueX;
    clear HipTorqueY;
    clear HipTorqueZ;
    clear TranslationForceX;
    clear TranslationForceY;
    clear TranslationForceZ;
    clear TorsoTorque;
    clear SpineTorqueX;
    clear SpineTorqueY;    
    clear LScapTorqueX;
    clear LScapTorqueY;
    clear RScapTorqueX;
    clear RScapTorqueY;
    clear LSTorqueX;
    clear LSTorqueY;
    clear LSTorqueZ;
    clear RSTorqueX;
    clear RSTorqueY;
    clear RSTorqueZ;
    clear LETorque;
    clear RETorque;
    clear LFTorque;
    clear RFTorque;
    clear LWTorqueX;
    clear LWTorqueY;
    clear RWTorqueX;
    clear RWTorqueY;
    clear HipPositionX;
    clear HipPositionY;
    clear HipPositionZ;
    clear HipGlobalPositionX;
    clear HipGlobalPositionY;
    clear HipGlobalPositionZ;
    clear TorsoPosition;
    clear SpinePositionX;
    clear SpinePositionY;
    clear LScapPositionX;
    clear LScapPositionY;
    clear RScapPositionX;
    clear RScapPositionY;
    clear LSPositionX;
    clear LSPositionY;
    clear LSPositionZ;
    clear RSPositionX;
    clear RSPositionY;
    clear RSPositionZ;
    clear LEPosition;
    clear REPosition;
    clear LFPosition;
    clear RFPosition;
    clear LWPositionX;
    clear LWPositionY;
    clear RWPositionX;
    clear RWPositionY;
    clear ZVCFPercentComplete;
    clear CopyRow;
    clear out;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the Q Table By Running Script
cd(matlabdrive);
cd '3DModel';
cd 'Scripts/_ZVCF Scripts';
SCRIPT_ZVCF_QTableGenerate_3D;
cd(matlabdrive);


    
    
    
   