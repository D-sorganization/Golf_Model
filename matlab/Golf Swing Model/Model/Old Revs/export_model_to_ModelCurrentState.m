%% export_model_to_ModelCurrentState_final_clean.m
% Export selected SLX model to ModelCurrentState.mdl and ModelCurrentState_structure.xml
% Cleans up temporary files and avoids naming conflicts.

% Step 1: Select model
[modelFile, modelPath] = uigetfile('*.slx', 'Select Simulink .slx model to export');
if isequal(modelFile, 0)
    error('No model selected.');
end

modelFullPath = fullfile(modelPath, modelFile);
[~, modelName, ~] = fileparts(modelFile);

% Step 2: Ensure all models are closed
bdclose('all');

% Step 3: Load selected model from disk
load_system(modelFullPath);

% Step 4: Save a uniquely named temporary SLX model
tempModelName = 'Export_Model_Temp';
tempModelPath = fullfile(modelPath, [tempModelName, '.slx']);
save_system(modelName, tempModelPath);
close_system(modelName, 0);  % Unload original to avoid naming collision

% Step 5: Copy temp .slx to final .mdl file
mdlTargetPath = fullfile(modelPath, 'ModelCurrentState.mdl');
copyfile(tempModelPath, mdlTargetPath);
fprintf('Copied to: %s\n', mdlTargetPath);

% Step 6: Re-load temporary model to export XML structure
load_system(tempModelPath);
if exist('slxmlcomp', 'file') == 2
    xmlPath = fullfile(modelPath, 'ModelCurrentState_structure.xml');
    slxmlcomp(tempModelName, xmlPath);
    fprintf('Exported XML structure to: %s\n', xmlPath);
else
    warning('slxmlcomp not found. Skipping XML export.');
end

% Step 7: Cleanup
close_system(tempModelName, 0);
delete(tempModelPath);
fprintf('Temporary file deleted: %s\n', tempModelPath);
fprintf('Model export complete.\n');

% Final cleanup of variables from workspace
clear modelFile modelPath modelFullPath modelName ...
      tempModelName tempModelPath mdlTargetPath xmlPath;

clc;  % Optional: clears command window
