%% export_model_to_xml_and_mdl.m
% This script exports a Simulink model to both XML and MDL formats,
% loading the .slx file under the name 'ModelCurrentState' to avoid naming collisions

[modelFile, path] = uigetfile('*.slx', 'Select the Simulink model to export');
if isequal(modelFile, 0)
    error('No model selected.');
end

[~, modelName, ~] = fileparts(modelFile);
modelFullPath = fullfile(path, modelFile);

% Check if any model is already loaded with the same name
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Load the model under a different name to avoid conflicts
tempName = 'ModelCurrentState';
load_system(modelFullPath);
set_param(modelName, 'Name', tempName);

% Save as .mdl
mdlFile = fullfile(path, [tempName, '.mdl']);
save_system(tempName, mdlFile, 'ExportToXML', false);

% Create a temp folder with model inside
tempFolder = fullfile(path, [tempName, '_packed']);
if ~exist(tempFolder, 'dir')
    mkdir(tempFolder);
end
copyfile(modelFullPath, fullfile(tempFolder, [tempName, '.slx']));

% Run XML export if function is available
if exist('pack_project_to_text', 'file') == 2
    xmlOut = fullfile(path, [tempName, '.xml']);
    pack_project_to_text(tempFolder, xmlOut);
    fprintf('Model exported to XML: %s\n', xmlOut);
else
    warning('pack_project_to_text.m not found on path. Skipping XML export.');
end

% Cleanup
save_system(tempName);
close_system(tempName, 0);

fprintf('Model exported as ModelCurrentState.mdl and .xml (if available).\n');