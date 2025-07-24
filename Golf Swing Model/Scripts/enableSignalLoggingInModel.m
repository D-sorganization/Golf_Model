% enableSignalLoggingInModel.m
% Script to enable signal logging in the Simulink model
% This is needed to capture joint center position data

clear; clc;

fprintf('=== Enabling Signal Logging in Model ===\n\n');
fprintf('This script will help you enable signal logging in your Simulink model.\n');
fprintf('You need to manually configure the signal buses for logging.\n\n');

%% Step 1: Load the Model
fprintf('--- Step 1: Loading Model ---\n');

modelName = 'GolfSwing3D_Kinetic';
if ~bdIsLoaded(modelName)
    load_system(modelName);
    fprintf('✓ Model loaded: %s\n', modelName);
else
    fprintf('✓ Model already loaded: %s\n', modelName);
end

%% Step 2: Open the Model
fprintf('\n--- Step 2: Opening Model ---\n');
fprintf('Opening model in Simulink...\n');
open_system(modelName);

fprintf('\n=== MANUAL STEPS REQUIRED ===\n');
fprintf('The model is now open. You need to manually enable signal logging:\n\n');

fprintf('1. Look for signal buses in your model that contain joint center positions\n');
fprintf('2. Right-click on each signal bus line\n');
fprintf('3. Select "Properties" or "Signal Properties"\n');
fprintf('4. Check the box for "Log signal data"\n');
fprintf('5. Set "Log name" to something descriptive (e.g., "JointCenterPositions")\n');
fprintf('6. Repeat for all signal buses you want to log\n\n');

fprintf('Common signal bus locations to check:\n');
fprintf('- Joint center position buses\n');
fprintf('- Position output buses\n');
fprintf('- Simscape output buses\n');
fprintf('- Any bus that contains X,Y,Z position data\n\n');

fprintf('=== AFTER ENABLING LOGGING ===\n');
fprintf('Once you have enabled signal logging:\n');
fprintf('1. Save the model\n');
fprintf('2. Run the test script again: testJointCenterDataExtraction_Short\n');
fprintf('3. The signals should now appear in the logsout data\n\n');

fprintf('=== TROUBLESHOOTING ===\n');
fprintf('If you can\'t find the signal buses:\n');
fprintf('1. Look for thick lines (bus signals)\n');
fprintf('2. Check Simscape blocks for output ports\n');
fprintf('3. Look for "Bus Creator" or "Bus Selector" blocks\n');
fprintf('4. Check if signals are routed to "To Workspace" blocks\n\n');

fprintf('Model is now open for configuration.\n');
fprintf('Enable signal logging and then run the test script again.\n\n'); 