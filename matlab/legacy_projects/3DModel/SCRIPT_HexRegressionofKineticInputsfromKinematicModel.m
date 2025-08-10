% This script is designed to read the output joint torques
% from the data table of a kinematically driven model and regress it to
% provide inputs to a kinetically driven model.

% % Run the model and generate the data tables
% cd(matlabdrive);
% cd '3DModel';
% out=sim('GolfSwing3D_KinematicallyDriven.slx');
% cd Scripts/'_Model Data Scripts'/;
% MASTER_SCRIPT_3D_DataCharts;

%%%%%%%%%%%%%%%%%%% Hip X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.HipTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Hip X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'HipInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'HipInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'HipInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'HipInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'HipInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'HipInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'HipInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% Hip Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.HipTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Hip Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'HipInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'HipInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'HipInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'HipInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'HipInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'HipInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'HipInputYG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% Hip Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.HipTorqueZInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Hip Z');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'HipInputZA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'HipInputZB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'HipInputZC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'HipInputZD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'HipInputZE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'HipInputZF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'HipInputZG',Simulink.Parameter(Coefficients(7)));
%
%
% %%%%%%%%%%%%%%%%%%% Translation X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.TranslationForceXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Translation X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'TranslationInputZA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'TranslationInputZB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'TranslationInputZC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'TranslationInputZD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'TranslationInputZE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'TranslationInputZF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'TranslationInputZG',Simulink.Parameter(Coefficients(7)));

% %%%%%%%%%%%%%%%%%% Translation Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X and Y data:
x=Data.Time;
y=Data.TranslationForceYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Translation Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'TranslationInputZA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'TranslationInputZB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'TranslationInputZC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'TranslationInputZD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'TranslationInputZE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'TranslationInputZF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'TranslationInputZG',Simulink.Parameter(Coefficients(7)));

% %%%%%%%%%%%%%%%%%% Translation Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X and Y data:
x=Data.Time;
y=Data.TranslationForceZInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Translation Z');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'TranslationInputZA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'TranslationInputZB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'TranslationInputZC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'TranslationInputZD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'TranslationInputZE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'TranslationInputZF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'TranslationInputZG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% Torso %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.TorsoTorqueInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Torso');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'TorsoInputA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'TorsoInputB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'TorsoInputC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'TorsoInputD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'TorsoInputE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'TorsoInputF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'TorsoInputG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% Spine X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.SpineTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Spine X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'SpineInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'SpineInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'SpineInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'SpineInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'SpineInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'SpineInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'SpineInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% Spine Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.SpineTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - Spine Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'SpineInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'SpineInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'SpineInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'SpineInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'SpineInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'SpineInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'SpineInputYG',Simulink.Parameter(Coefficients(7)));


%%%%%%%%%%%%%%%%%%% LScap X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LScapTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LScap X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LScapInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LScapInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LScapInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LScapInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LScapInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LScapInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LScapInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LScap Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LScapTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LScap Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LScapInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LScapInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LScapInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LScapInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LScapInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LScapInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LScapInputYG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RScap X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RScapTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RScap X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RScapInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RScapInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RScapInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RScapInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RScapInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RScapInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RScapInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RScap Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RScapTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RScap Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RScapInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RScapInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RScapInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RScapInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RScapInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RScapInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RScapInputYG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LS X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LSTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LS X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LSInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LSInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LSInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LSInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LSInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LSInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LSInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LS Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LSTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LS Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LSInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LSInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LSInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LSInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LSInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LSInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LSInputYG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LS Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LSTorqueZInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LS Z');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LSInputZA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LSInputZB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LSInputZC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LSInputZD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LSInputZE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LSInputZF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LSInputZG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RS X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RSTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RS X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RSInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RSInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RSInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RSInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RSInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RSInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RSInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RS Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RSTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RS Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RSInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RSInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RSInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RSInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RSInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RSInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RSInputYG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RS Z %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RSTorqueZLocal;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RS Z');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RSInputZA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RSInputZB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RSInputZC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RSInputZD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RSInputZE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RSInputZF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RSInputZG',Simulink.Parameter(Coefficients(7)));


%%%%%%%%%%%%%%%%%%% LE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LETorqueInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LE');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LEInputA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LEInputB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LEInputC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LEInputD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LEInputE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LEInputF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LEInputG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RETorqueInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RE');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'REInputA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'REInputB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'REInputC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'REInputD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'REInputE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'REInputF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'REInputG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LFTorqueInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LF');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LFInputA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LFInputB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LFInputC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LFInputD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LFInputE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LFInputF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LFInputG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RFTorqueInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RF');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RFInputA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RFInputB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RFInputC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RFInputD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RFInputE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RFInputF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RFInputG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LW X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LWTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LW X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LWInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LWInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LWInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LWInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LWInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LWInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LWInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% LW Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.LWTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - LW Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'LWInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'LWInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'LWInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'LWInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'LWInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'LWInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'LWInputYG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RW X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RWTorqueXInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RW X');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RWInputXA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RWInputXB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RWInputXC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RWInputXD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RWInputXE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RWInputXF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RWInputXG',Simulink.Parameter(Coefficients(7)));

%%%%%%%%%%%%%%%%%%% RW Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define X,Y
x=Data.Time;
y=Data.RWTorqueYInput;

Coefficients=HexRegression(x,y);

% Plot results and check value
scatter(x, y, 'r+')
hold on
plot(x,HexPolyInputFunction(Coefficients(1),Coefficients(2),Coefficients(3),...
    Coefficients(4),Coefficients(5),Coefficients(6),Coefficients(7),x))
hold off

%Save Figure
cd(matlabdrive);
cd '3DModel/Regression Charts';
savefig('Fitting Plot - RW Y');
% pause(PauseTime);

% Write the coefficient values to model workspace as parameters for the
% polynomial inputs.

assignin(mdlWks,'RWInputYA',Simulink.Parameter(Coefficients(1)));
assignin(mdlWks,'RWInputYB',Simulink.Parameter(Coefficients(2)));
assignin(mdlWks,'RWInputYC',Simulink.Parameter(Coefficients(3)));
assignin(mdlWks,'RWInputYD',Simulink.Parameter(Coefficients(4)));
assignin(mdlWks,'RWInputYE',Simulink.Parameter(Coefficients(5)));
assignin(mdlWks,'RWInputYF',Simulink.Parameter(Coefficients(6)));
assignin(mdlWks,'RWInputYG',Simulink.Parameter(Coefficients(7)));
