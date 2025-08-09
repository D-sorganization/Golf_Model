%% export_model_to_ModelCurrentState_fixed.m
% Safely export model to ModelCurrentState.mdl and ModelCurrentState_structure.xml

% Step 1: Prompt user to select .slx model
[modelFile, modelPath] = uigetfile('*.slx', 'Select the Simulink model to export');
if isequal(modelFile, 0)
    error('No model selected.');
end

modelFullPath = fullfile(modelPath, modelFile);
[~, originalModelName, ~] = fileparts(modelFile);

% Step 2: Close original if loaded
if bdIsLoaded(originalModelName)
    close_system(originalModelName, 0);
end

% Step 3: Load the model and rename in memory
load_system(modelFullPath);
loadedModelName = get_param(modelFullPath, 'Name');

% Rename in memory to avoid conflict
tempModelName = 'ModelCurrentState_temp';
if ~strcmp(loadedModelName, tempModelName)
    newName = Simulink.copyModel(loadedModelName, tempModelName);
    close_system(loadedModelName, 0); % Close original
else
    newName = loadedModelName;
end

% Step 4: Save to ModelCurrentState.mdl
mdlPath = fullfile(modelPath, 'ModelCurrentState.mdl');
save_system(newName, mdlPath);
fprintf('Saved model as .mdl: %s\n', mdlPath);

% Step 5: Export to XML if possible
xmlPath = fullfile(modelPath, 'ModelCurrentState_structure.xml');
if exist('slxmlcomp', 'file') == 2
    slxmlcomp(newName, xmlPath);
    fprintf('Exported model structure using slxmlcomp to: %s\n', xmlPath);
else
    warning('slxmlcomp not found. Skipping XML export.');
end

% Step 6: Cleanup
if bdIsLoaded(newName)
    save_system(newName);
    close_system(newName, 0);
end

fprintf('Model export complete.\n');