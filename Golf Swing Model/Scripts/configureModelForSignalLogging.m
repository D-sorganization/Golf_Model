% configureModelForSignalLogging.m
% Script to configure the model for proper signal logging to workspace

clear; clc;

fprintf('=== Configuring Model for Signal Logging ===\n\n');
fprintf('This script will help you configure the model to save logged signals to workspace.\n\n');

%% Step 1: Load and Open the Model
fprintf('--- Step 1: Loading and Opening Model ---\n');

modelName = 'GolfSwing3D_Kinetic';
if ~bdIsLoaded(modelName)
    load_system(modelName);
    fprintf('✓ Model loaded: %s\n', modelName);
else
    fprintf('✓ Model already loaded: %s\n', modelName);
end

% Open the model
open_system(modelName);
fprintf('✓ Model opened in Simulink\n');

%% Step 2: Configure Model Parameters
fprintf('\n--- Step 2: Configuring Model Parameters ---\n');

try
    % Set model parameters for signal logging
    set_param(modelName, 'SignalLogging', 'on');
    set_param(modelName, 'SignalLoggingName', 'out');
    set_param(modelName, 'SignalLoggingSaveFormat', 'Dataset');
    set_param(modelName, 'SignalLoggingSaveToWorkspace', 'on');
    
    fprintf('✓ Signal logging enabled\n');
    fprintf('✓ Signal logging name set to: out\n');
    fprintf('✓ Signal logging format set to: Dataset\n');
    fprintf('✓ Signal logging save to workspace enabled\n');
    
catch ME
    fprintf('✗ Error setting model parameters: %s\n', ME.message);
end

%% Step 3: Check Current Configuration
fprintf('\n--- Step 3: Current Model Configuration ---\n');

try
    signalLogging = get_param(modelName, 'SignalLogging');
    signalLoggingName = get_param(modelName, 'SignalLoggingName');
    signalLoggingFormat = get_param(modelName, 'SignalLoggingSaveFormat');
    signalLoggingSaveToWorkspace = get_param(modelName, 'SignalLoggingSaveToWorkspace');
    
    fprintf('Current settings:\n');
    fprintf('  SignalLogging: %s\n', signalLogging);
    fprintf('  SignalLoggingName: %s\n', signalLoggingName);
    fprintf('  SignalLoggingSaveFormat: %s\n', signalLoggingFormat);
    fprintf('  SignalLoggingSaveToWorkspace: %s\n', signalLoggingSaveToWorkspace);
    
catch ME
    fprintf('✗ Error reading model parameters: %s\n', ME.message);
end

%% Step 4: Manual Steps Required
fprintf('\n=== MANUAL STEPS REQUIRED ===\n');
fprintf('The model is now configured for signal logging. You need to:\n\n');

fprintf('1. SAVE THE MODEL (Ctrl+S)\n');
fprintf('2. Verify your signal logging is still enabled:\n');
fprintf('   - Look for the wifi-like signal icons on your signal buses\n');
fprintf('   - Right-click on signal buses to verify Log signal data is checked\n\n');

fprintf('3. Test the configuration:\n');
fprintf('   - Run a quick simulation (F5 or click Run)\n');
fprintf('   - Check if signals appear in the Data Inspector\n');
fprintf('   - Check if signals appear in the workspace as out\n\n');

fprintf('4. If signals appear in workspace, run our test script:\n');
fprintf('   testJointCenterDataExtraction_Short\n\n');

%% Step 5: Alternative Configuration
fprintf('=== ALTERNATIVE: Use To Workspace Blocks ===\n');
fprintf('If signal logging still does not work, you can also:\n\n');

fprintf('1. Add To Workspace blocks to your signal buses\n');
fprintf('2. Set the variable name to something like JointCenterData\n');
fprintf('3. Set the save format to Structure with time\n');
fprintf('4. This will save the data directly to workspace\n\n');

fprintf('=== TROUBLESHOOTING ===\n');
fprintf('If signals still do not appear in workspace:\n');
fprintf('1. Check if signals are actually being logged (Data Inspector)\n');
fprintf('2. Verify model parameters are saved\n');
fprintf('3. Try running simulation from Simulink interface first\n');
fprintf('4. Check if there are any error messages\n\n');

fprintf('Model is now configured for signal logging.\n');
fprintf('Save the model and test the configuration.\n\n'); 