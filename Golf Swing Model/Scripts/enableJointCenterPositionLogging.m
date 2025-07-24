% enableJointCenterPositionLogging.m
% Script to enable logging of global joint center positions in Simscape
% This is CRITICAL for motion matching and 3D visualization

clear; clc;

fprintf('=== Enabling Joint Center Position Logging ===\n\n');
fprintf('This script will help you enable logging of global joint center positions\n');
fprintf('in your Simscape golf swing model. This data is CRITICAL for:\n');
fprintf('- Motion matching with real-world data\n');
fprintf('- 3D visualization and animation\n');
fprintf('- Biomechanical analysis\n');
fprintf('- Comparison with motion capture data\n\n');

%% Step 1: Check Current Model State
fprintf('--- Step 1: Checking Current Model State ---\n');

try
    % Try to load the model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Check current logging configuration
    loggingConfig = get_param(modelName, 'DataLogging');
    fprintf('Current logging configuration: %s\n', loggingConfig);
    
catch ME
    fprintf('✗ Error loading model: %s\n', ME.message);
    fprintf('Please ensure the model file exists and is accessible.\n');
    return;
end

%% Step 2: Identify Joint Centers to Log
fprintf('\n--- Step 2: Joint Centers to Log ---\n');

% Define all joint centers that need global position tracking
jointCenters = {
    'Hip_Center',           % Hip joint center
    'Torso_Center',         % Torso/thorax center
    'L_Shoulder_Center',    % Left shoulder joint center
    'R_Shoulder_Center',    % Right shoulder joint center
    'L_Elbow_Center',       % Left elbow joint center
    'R_Elbow_Center',       % Right elbow joint center
    'L_Wrist_Center',       % Left wrist joint center
    'R_Wrist_Center',       % Right wrist joint center
    'L_Scapula_Center',     % Left scapula center
    'R_Scapula_Center',     % Right scapula center
    'Spine_Center',         % Spine center
    'Midhands_Center',      % Mid-hands center (already logged)
    'Clubhead_Center'       % Clubhead center (already logged)
};

fprintf('Joint centers to track:\n');
for i = 1:length(jointCenters)
    fprintf('  %d. %s\n', i, jointCenters{i});
end

%% Step 3: Simscape Logging Configuration
fprintf('\n--- Step 3: Simscape Logging Configuration ---\n');

% Enable comprehensive Simscape logging
fprintf('To enable joint center position logging, you need to:\n\n');

fprintf('1. In your Simulink model, enable Simscape logging:\n');
fprintf('   - Go to Simulation > Model Configuration Parameters\n');
fprintf('   - Navigate to Simscape > Solver\n');
fprintf('   - Set "Log simulation data" to "All"\n');
fprintf('   - Set "Log level" to "All"\n\n');

fprintf('2. Add logging blocks to track joint center positions:\n');
fprintf('   - Add "To Workspace" blocks connected to joint center positions\n');
fprintf('   - Or use "Scope" blocks with logging enabled\n');
fprintf('   - Or enable "Data Logging" in the model configuration\n\n');

%% Step 4: Signal Paths for Joint Centers
fprintf('--- Step 4: Signal Paths for Joint Centers ---\n');

% Define the expected signal paths for joint center positions
% These paths need to be verified in your actual model
jointCenterPaths = {
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rx.p'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Ry.p'
    'GolfSwing3D_Kinetic.Hips_and_Torso_Inputs.Hip_Kinetically_Driven.Hip_Joint.Rz.p'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.p'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.p'
    'GolfSwing3D_Kinetic.Left_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.p'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rx.p'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Ry.p'
    'GolfSwing3D_Kinetic.Right_Shoulder_Joint.Gimbal_Joint.Kinetically_Driven.Rz.p'
    'GolfSwing3D_Kinetic.Left_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.p'
    'GolfSwing3D_Kinetic.Right_Elbow_Joint.Revolute_Joint.Kinetically_Driven_Revolute.Rz.p'
    'GolfSwing3D_Kinetic.Left_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.p'
    'GolfSwing3D_Kinetic.Left_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.p'
    'GolfSwing3D_Kinetic.Right_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Rx.p'
    'GolfSwing3D_Kinetic.Right_Wrist_and_Hand.Universal_Joint.Kinetically_Driven_Universal_Joint.Ry.p'
};

fprintf('Expected signal paths for joint center positions:\n');
for i = 1:length(jointCenterPaths)
    fprintf('  %s\n', jointCenterPaths{i});
end

%% Step 5: Verification Script
fprintf('\n--- Step 5: Verification Script ---\n');

fprintf('After enabling logging, run this verification script:\n\n');

fprintf('%% Verification script\n');
fprintf('function verifyJointCenterLogging()\n');
fprintf('    %% Check if joint center positions are being logged\n');
fprintf('    try\n');
fprintf('        simscapeRuns = Simulink.sdi.getAllRunIDs;\n');
fprintf('        if isempty(simscapeRuns)\n');
fprintf('            fprintf(''No Simscape runs found. Run a simulation first.\\n'');\n');
fprintf('            return;\n');
fprintf('        end\n\n');
fprintf('        latestRun = simscapeRuns(end);\n');
fprintf('        runObj = Simulink.sdi.getRun(latestRun);\n');
fprintf('        allSignals = runObj.getAllSignals;\n');
fprintf('        allSignalNames = {allSignals.Name};\n\n');
fprintf('        %% Check for position signals\n');
fprintf('        positionSignals = allSignalNames(contains(allSignalNames, ''.p(''));\n');
fprintf('        fprintf(''Found %%d position signals:\\n'', length(positionSignals));\n');
fprintf('        for i = 1:length(positionSignals)\n');
fprintf('            fprintf(''  %%s\\n'', positionSignals{i});\n');
fprintf('        end\n\n');
fprintf('        %% Check for joint center positions\n');
fprintf('        jointCenterSignals = allSignalNames(contains(allSignalNames, ''Center''));\n');
fprintf('        fprintf(''Found %%d joint center signals:\\n'', length(jointCenterSignals));\n');
fprintf('        for i = 1:length(jointCenterSignals)\n');
fprintf('            fprintf(''  %%s\\n'', jointCenterSignals{i});\n');
fprintf('        end\n\n');
fprintf('    catch ME\n');
fprintf('        fprintf(''Error: %%s\\n'', ME.message);\n');
fprintf('    end\n');
fprintf('end\n');

%% Step 6: Data Extraction Function
fprintf('\n--- Step 6: Data Extraction Function ---\n');

fprintf('Use this function to extract joint center positions:\n\n');

fprintf('function jointCenters = extractJointCenterPositions(simOut)\n');
fprintf('    %% Extract global joint center positions from simulation output\n');
fprintf('    %% Input: simOut - SimulationOutput object\n');
fprintf('    %% Output: jointCenters - struct with joint center positions\n\n');
fprintf('    try\n');
fprintf('        %% Get Simscape data\n');
fprintf('        simscapeData = simOut.simscape;\n\n');
fprintf('        %% Extract joint center positions\n');
fprintf('        jointCenters.time = simscapeData.time;\n');
fprintf('        jointCenters.hip = extractJointPosition(simscapeData, ''Hip_Center'');\n');
fprintf('        jointCenters.leftShoulder = extractJointPosition(simscapeData, ''L_Shoulder_Center'');\n');
fprintf('        jointCenters.rightShoulder = extractJointPosition(simscapeData, ''R_Shoulder_Center'');\n');
fprintf('        jointCenters.leftElbow = extractJointPosition(simscapeData, ''L_Elbow_Center'');\n');
fprintf('        jointCenters.rightElbow = extractJointPosition(simscapeData, ''R_Elbow_Center'');\n');
fprintf('        jointCenters.leftWrist = extractJointPosition(simscapeData, ''L_Wrist_Center'');\n');
fprintf('        jointCenters.rightWrist = extractJointPosition(simscapeData, ''R_Wrist_Center'');\n');
fprintf('        jointCenters.midhands = extractJointPosition(simscapeData, ''Midhands_Center'');\n');
fprintf('        jointCenters.clubhead = extractJointPosition(simscapeData, ''Clubhead_Center'');\n\n');
fprintf('        fprintf(''✓ Joint center positions extracted successfully\\n'');\n');
fprintf('        fprintf(''Time points: %%d\\n'', length(jointCenters.time));\n');
fprintf('        fprintf(''Joint centers tracked: %%d\\n'', length(fieldnames(jointCenters)) - 1);\n\n');
fprintf('    catch ME\n');
fprintf('        fprintf(''✗ Error extracting joint center positions: %%s\\n'', ME.message);\n');
fprintf('        jointCenters = [];\n');
fprintf('    end\n');
fprintf('end\n\n');

fprintf('function pos = extractJointPosition(simscapeData, jointName)\n');
fprintf('    %% Helper function to extract position for a specific joint\n');
fprintf('    try\n');
fprintf('        pos = [simscapeData.(jointName).x, simscapeData.(jointName).y, simscapeData.(jointName).z];\n');
fprintf('    catch\n');
fprintf('        pos = [];\n');
fprintf('        fprintf(''Warning: Could not extract position for %%s\\n'', jointName);\n');
fprintf('    end\n');
fprintf('end\n');

%% Step 7: Next Steps
fprintf('\n--- Step 7: Next Steps ---\n');

fprintf('To implement joint center position logging:\n\n');

fprintf('1. IMMEDIATE ACTION REQUIRED:\n');
fprintf('   - Open your Simulink model\n');
fprintf('   - Enable comprehensive Simscape logging\n');
fprintf('   - Add logging blocks for joint center positions\n');
fprintf('   - Run a test simulation\n\n');

fprintf('2. VERIFICATION:\n');
fprintf('   - Run the verification script above\n');
fprintf('   - Check that position signals are being logged\n');
fprintf('   - Verify data quality and completeness\n\n');

fprintf('3. INTEGRATION:\n');
fprintf('   - Update your data extraction scripts\n');
fprintf('   - Modify plotting and analysis functions\n');
fprintf('   - Integrate with motion matching algorithms\n\n');

fprintf('4. VALIDATION:\n');
fprintf('   - Compare with motion capture data\n');
fprintf('   - Validate joint center trajectories\n');
fprintf('   - Check for physical consistency\n\n');

fprintf('This joint center position data is CRITICAL for your motion matching\n');
fprintf('and 3D visualization goals. Implement this logging immediately!\n\n');

%% Summary
fprintf('=== Summary ===\n');
fprintf('✓ Current state: Joint angles tracked, but NOT global joint center positions\n');
fprintf('✗ Missing: Global (x,y,z) coordinates of joint centers\n');
fprintf('⚠️  Action required: Enable joint center position logging in Simscape\n');
fprintf('🎯 Goal: Complete 3D motion tracking for motion matching and visualization\n\n');

fprintf('The joint center positions are the foundation for:\n');
fprintf('- Motion matching with real-world data\n');
fprintf('- 3D animation and visualization\n');
fprintf('- Biomechanical analysis\n');
fprintf('- Trajectory planning and optimization\n\n');

fprintf('Implement this logging immediately - it''s enormously important!\n'); 