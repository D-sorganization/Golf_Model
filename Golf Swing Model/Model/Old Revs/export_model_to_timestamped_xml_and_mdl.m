%% export_model_to_timestamped_xml_and_mdl.m
% Export selected SLX model to timestamped .mdl and .xml using pack_project_to_text

% 1) Pick the .slx
[modelFile, basePath] = uigetfile('*.slx', 'Select Simulink model to export');
if isequal(modelFile,0)
    error('No model selected.');
end
[~, origName, ~] = fileparts(modelFile);
fullSLXPath = fullfile(basePath, modelFile);

% 2) Ensure nothing shadowed
if bdIsLoaded(origName)
    close_system(origName, 0);
end

% 3) Load the model so we can export .mdl
load_system(fullSLXPath);

% 4) Save .mdl using a timestamped name
mdlOut = fullfile(basePath, 'ModelExport_20250507_204342.mdl');
save_system(origName, mdlOut);
fprintf('Saved MDL: %s\n', mdlOut);

% 5) Build a temp project folder
tempFolder = fullfile(basePath, 'ModelExport_20250507_204342_project');
if exist(tempFolder,'dir')
    rmdir(tempFolder,'s');
end
mkdir(tempFolder);

% 6) Copy SLX and MDL into the project folder
copyfile(fullSLXPath, fullfile(tempFolder, 'ModelExport_20250507_204342.slx'));
copyfile(mdlOut,     fullfile(tempFolder, 'ModelExport_20250507_204342.mdl'));

% 7) Turn the folder into a MATLAB Project
proj = matlab.project.createProject(tempFolder);
proj.Name = 'ModelExport_20250507_204342_Project';
proj.save();

% 8) Export to XML using pack_project_to_text
xmlOut = fullfile(basePath, 'ModelExport_20250507_204342.xml');
pack_project_to_text(tempFolder, xmlOut);
fprintf('Exported XML metadata to: %s\n', xmlOut);

% 9) Cleanup
proj.close();
bdclose(origName);
fprintf('Done: timestamped MDL and XML generated.\n');