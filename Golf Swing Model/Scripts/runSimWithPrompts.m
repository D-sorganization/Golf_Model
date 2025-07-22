% RUNSIMWITHPROMPTS Loads parameters from a selected .mat file and runs a selected Simulink model.
% This script prompts the user to select a .mat file containing parameters
% and a .slx Simulink model file. It then loads the parameters and uses
% them to configure and run the selected model simulation via Simulink.SimulationInput.

% --- File Selection ---

fprintf('Please select the .mat file containing your parameters...\n');

% Prompt user to select the .mat parameter file
[paramFileName, paramPathName] = uigetfile('*.mat', 'Select Parameter File');

% Check if the user cancelled
if isequal(paramFileName, 0) || isequal(paramPathName, 0)
    disp('Parameter file selection cancelled. Operation aborted.');
    return; % Exit the script
end

% Construct the full path to the parameter file
parameterFilePath = fullfile(paramPathName, paramFileName);
fprintf('Selected parameter file: "%s"\n', parameterFilePath);


fprintf('\nPlease select the Simulink model (.slx file) to run...\n');

% Prompt user to select the .slx model file
[modelFileName, modelPathName] = uigetfile('*.slx', 'Select Simulink Model File');

% Check if the user cancelled
if isequal(modelFileName, 0) || isequal(modelPathName, 0)
    disp('Simulink model file selection cancelled. Operation aborted.');
    return; % Exit the script
end

% Construct the full path to the model file
modelFilePath = fullfile(modelPathName, modelFileName);
% Extract just the model name (without the .slx extension)
[~, modelName, ~] = fileparts(modelFileName);
fprintf('Selected Simulink model: "%s"\n', modelFilePath);


% --- Load Parameters from .mat File ---
fprintf('\nLoading parameters from "%s"...\n', parameterFilePath);

% Check if the parameter file exists (should exist if uigetfile was successful, but double check)
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
fprintf('\nConfiguring simulation input for model "%s"...\n', modelName);

% Create a Simulink.SimulationInput object for the target model
in = Simulink.SimulationInput(modelName);

% Get the names of the variables loaded from the .mat file
paramNames = fieldnames(parameterData);

% Iterate through each loaded variable and set it on the SimulationInput object
% This assigns the value to the model workspace for this specific simulation run.
% setVariable automatically handles creating Simulink.Parameter objects if needed.
if ~isempty(paramNames)
    for i = 1:length(paramNames)
        currentParamName = paramNames{i};
        currentParamValue = parameterData.(currentParamName); % Get the value from the structure

        % Set the variable on the SimulationInput object
        in = in.setVariable(currentParamName, currentParamValue);
        % fprintf('  Set variable: %s\n', currentParamName);
    end
    fprintf('Simulation input configuration complete.\n');
else
    warning('No variables found in the parameter file. Running simulation with model default parameters.');
end


% --- Optional: Configure other simulation options on the SimulationInput object ---
% You can set stop time, solver, logging options, etc., here if you don't
% want to rely on the model's saved configuration or want to override it.
% Example:
% in = in.setStopTime(1.0);
% in = in.setSolver('ode45');
% in = in.setSignalLogging('on');
% in = in.setLoggingOption('all');


% --- Run the Simulation ---
fprintf('\nRunning simulation...\n');

try
    % Load the model if it's not already loaded
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('Model "%s" loaded.\n', modelName);
    end

    % Run the simulation using the configured SimulationInput object
    out = parsim(in);

    fprintf('Simulation finished successfully.\n');

    % --- Optional: Process Simulation Output ---
    % The simulation output is in the 'out' variable. You can process it here.
    % For example, you could call your generateDataTable3D function if it's on the path:
    % if exist('generateDataTable3D', 'file')
    %     simulationDataTable = generateDataTable3D(out);
    %     disp('Simulation output data table generated:');
    %     disp(simulationDataTable);
    % else
    %     disp('Simulation output object ''out'' is available in the workspace.');
    %     disp('Consider converting your table generation script to a function.');
    % end


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
%         % Check if the model was loaded by this script (more complex) or just close it
%         close_system(modelName, 0); % Close without saving changes
%         fprintf('Model "%s" closed.\n', modelName);
%     end
% catch ME
%     warning('Could not close model "%s": %s', modelName, ME.message);
% end

% Clear variables from this script's workspace if desired (not necessary for standalone script)
clear parameterFileName modelName projectRoot parameterFilePath parameterData paramNames i currentParamName...
    currentParamValue ME paramPathName paramFileName modelPathName modelFilePath modelFileName;
