% RUNSIMWITHPARAMETERS Loads parameters from a .mat file and runs a Simulink simulation.
% This script demonstrates how to load variables from a specified .mat file
% and use them to configure a Simulink model simulation via Simulink.SimulationInput.

% --- Configuration ---
% Define the name of the parameter file
% parameterFileName = '3DModelInputs.mat';
parameterFileName = 'Input.mat';

% Define the name of the Simulink model to run
% *** IMPORTANT: Update this model name if it's different in your project ***
modelName = 'GolfSwing3D_KineticallyDriven';

% Define the root directory of your project
% Assuming this script is located in the project's root directory
projectRoot = fileparts(mfilename('fullpath'));

% Construct the full path to the parameter file
parameterFilePath = fullfile(projectRoot, parameterFileName);

% --- Load Parameters from .mat File ---
fprintf('Loading parameters from "%s"...\n', parameterFilePath);

% Check if the parameter file exists
if ~exist(parameterFilePath, 'file')
    error('Parameter file not found: "%s"', parameterFilePath);
end

try
    % Load variables from the .mat file into a structure
    % The field names of the structure will be the variable names from the .mat file
    parameterData = load(parameterFilePath);
    fprintf('Parameters loaded successfully.\n');
catch ME
    error('Error loading parameter file "%s": %s', parameterFilePath, ME.message);
end

% --- Create and Configure SimulationInput Object ---
fprintf('Configuring simulation input for model "%s"...\n', modelName);

% Create a Simulink.SimulationInput object for the target model
in = Simulink.SimulationInput(modelName);

% Get the names of the variables loaded from the .mat file
paramNames = fieldnames(parameterData);

% Iterate through each loaded variable and set it on the SimulationInput object
% This assigns the value to the model workspace for this specific simulation run.
% setVariable automatically handles creating Simulink.Parameter objects if needed.
for i = 1:length(paramNames)
    currentParamName = paramNames{i};
    currentParamValue = parameterData.(currentParamName); % Get the value from the structure

    % Set the variable on the SimulationInput object
    in = in.setVariable(currentParamName, currentParamValue);
    fprintf('  Set variable: %s\n', currentParamName);
end

% --- Optional: Configure other simulation options on the SimulationInput object ---
% You can set stop time, solver, logging options, etc., here if you don't
% want to rely on the model's saved configuration or want to override it.
% Example:
% in = in.setStopTime(1.0);
% in = in.setSolver('ode45');
% in = in.setSignalLogging('on');
% in = in.setLoggingOption('all');

fprintf('Simulation input configuration complete.\n');

% --- Run the Simulation ---
fprintf('Running simulation...\n');

try
    % Load the model if it's not already loaded
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('Model "%s" loaded.\n', modelName);
    end

    % Run the simulation using the configured SimulationInput object
    out = parsim(in);

    fprintf('Simulation finished successfully.\n');

catch ME
    % Display error message if simulation fails
    fprintf(2, '\nError during simulation:\n%s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf(2, 'Error occurred in function %s, file %s, at line %d\n', ...
            ME.stack(1).name, ME.stack(1).file, ME.stack(1).line);
    end
end

% --- Final Cleanup (Optional) ---
% Close the model if you loaded it and don't need it open afterward
% try
%     if bdIsLoaded(modelName)
%         close_system(modelName, 0); % Close without saving changes
%         fprintf('Model "%s" closed.\n', modelName);
%     end
% catch ME
%     warning('Could not close model "%s": %s', modelName, ME.message);
% end

% Clear variables from this script's workspace if desired (not necessary for standalone script)
clear parameterFileName modelName projectRoot parameterFilePath parameterData paramNames i currentParamName currentParamValue ME;

