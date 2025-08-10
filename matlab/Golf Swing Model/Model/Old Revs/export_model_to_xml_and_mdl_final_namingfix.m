%% export_model_to_xml_and_mdl_final_namingfix.m
% Select a Simulink .slx model, export a .mdl copy,
% then package both files into XML metadata via pack_project_to_text.

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

% 4) Save as temporary .mdl to avoid Simulink name conflict
mdlTempOut = fullfile(basePath, 'ModelCurrentState_temp.mdl');
save_system(origName, mdlTempOut);
fprintf('Saved temporary MDL: %s\n', mdlTempOut);

% 5) Build a temp “project” folder
tempFolder = fullfile(basePath,'ModelCurrentState_packed');
if exist(tempFolder,'dir')
    rmdir(tempFolder,'s');
end
mkdir(tempFolder);

% 6) Copy both SLX and MDL into it under the desired name
copyfile(fullSLXPath, fullfile(tempFolder,'ModelCurrentState.slx'));
copyfile(mdlTempOut,   fullfile(tempFolder,'ModelCurrentState.mdl'));

% 7) Turn it into a MATLAB Project
proj = matlab.project.createProject('ModelCurrentStateProject', 'Folder', tempFolder);
proj.addFiles(fullfile(tempFolder,'ModelCurrentState.slx'));
proj.addFiles(fullfile(tempFolder,'ModelCurrentState.mdl'));
proj.save();  % write the .prj in tempFolder

% 8) Run pack_project_to_text on that project folder
xmlOut = fullfile(basePath, 'ModelCurrentState.xml');
pack_project_to_text(tempFolder, xmlOut);
fprintf('Exported XML metadata to: %s\n', xmlOut);

% 9) Cleanup
proj.close();
bdclose(origName);        % unload original model

% Move temp mdl to final path
mdlFinalOut = fullfile(basePath, 'ModelCurrentState.mdl');
if exist(mdlFinalOut, 'file')
    delete(mdlFinalOut);
end
movefile(mdlTempOut, mdlFinalOut);
fprintf('Renamed MDL to: %s\n', mdlFinalOut);

% Remove temp folder
rmdir(tempFolder,'s');
fprintf('Done: MDL + XML generated.\n');
