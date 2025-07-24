function verifyJointCenterLogging()
% verifyJointCenterLogging.m
% Check if joint center positions are being logged in Simscape Results Explorer
% This script verifies what position data is currently available

fprintf('=== Joint Center Position Logging Verification ===\n\n');

%% Check Simscape Results Explorer
try
    simscapeRuns = Simulink.sdi.getAllRunIDs;
    if isempty(simscapeRuns)
        fprintf('✗ No Simscape runs found in Results Explorer.\n');
        fprintf('   Please run a simulation first to generate Simscape data.\n');
        return;
    end
    
    fprintf('✓ Found %d Simscape runs in Results Explorer.\n', length(simscapeRuns));
    
    % Get the most recent run
    latestRun = simscapeRuns(end);
    runObj = Simulink.sdi.getRun(latestRun);
    
    fprintf('✓ Using latest run: %s (ID: %d)\n', runObj.Name, latestRun);
    
catch ME
    fprintf('✗ Error accessing Simscape Results Explorer: %s\n', ME.message);
    fprintf('   Make sure you have run a simulation and Simscape logging is enabled.\n');
    return;
end

%% Get all available signals
fprintf('\n--- Available Signals Analysis ---\n');

allSignals = runObj.getAllSignals;
allSignalNames = {allSignals.Name};

fprintf('Total signals available: %d\n', length(allSignalNames));

%% Check for position signals
fprintf('\n--- Position Signal Analysis ---\n');

% Look for position signals (p signals)
positionSignals = allSignalNames(contains(allSignalNames, '.p('));
fprintf('Position signals (.p): %d found\n', length(positionSignals));

if ~isempty(positionSignals)
    fprintf('Position signal examples:\n');
    for i = 1:min(10, length(positionSignals))
        fprintf('  %s\n', positionSignals{i});
    end
    if length(positionSignals) > 10
        fprintf('  ... and %d more\n', length(positionSignals) - 10);
    end
else
    fprintf('✗ No position signals found!\n');
    fprintf('   This indicates joint center positions are NOT being logged.\n');
end

%% Check for joint center signals
fprintf('\n--- Joint Center Signal Analysis ---\n');

% Look for signals containing "Center"
centerSignals = allSignalNames(contains(allSignalNames, 'Center'));
fprintf('Center signals: %d found\n', length(centerSignals));

if ~isempty(centerSignals)
    fprintf('Center signal examples:\n');
    for i = 1:length(centerSignals)
        fprintf('  %s\n', centerSignals{i});
    end
else
    fprintf('✗ No center signals found!\n');
end

%% Check for specific joint position signals
fprintf('\n--- Specific Joint Position Analysis ---\n');

% Define expected joint position signal patterns
jointPatterns = {
    'Hip.*\.p',           % Hip position
    'Shoulder.*\.p',      % Shoulder position
    'Elbow.*\.p',         % Elbow position
    'Wrist.*\.p',         % Wrist position
    'Scapula.*\.p',       % Scapula position
    'Spine.*\.p',         % Spine position
    'Torso.*\.p',         % Torso position
    'Joint.*\.p'          % Generic joint position
};

for i = 1:length(jointPatterns)
    pattern = jointPatterns{i};
    matchingSignals = allSignalNames(~cellfun(@isempty, regexp(allSignalNames, pattern, 'once')));
    fprintf('%s: %d signals\n', pattern, length(matchingSignals));
    if ~isempty(matchingSignals)
        for j = 1:min(3, length(matchingSignals))
            fprintf('  %s\n', matchingSignals{j});
        end
        if length(matchingSignals) > 3
            fprintf('  ... and %d more\n', length(matchingSignals) - 3);
        end
    end
end

%% Check for global coordinate signals
fprintf('\n--- Global Coordinate Analysis ---\n');

% Look for signals that might contain global coordinates
globalPatterns = {
    '\.x$',               % X coordinate
    '\.y$',               % Y coordinate
    '\.z$',               % Z coordinate
    'Position.*X',        % Position X
    'Position.*Y',        % Position Y
    'Position.*Z',        % Position Z
    'Global.*Position',   % Global position
    'World.*Position'     % World position
};

for i = 1:length(globalPatterns)
    pattern = globalPatterns{i};
    matchingSignals = allSignalNames(~cellfun(@isempty, regexp(allSignalNames, pattern, 'once')));
    fprintf('%s: %d signals\n', pattern, length(matchingSignals));
    if ~isempty(matchingSignals)
        for j = 1:min(3, length(matchingSignals))
            fprintf('  %s\n', matchingSignals{j});
        end
        if length(matchingSignals) > 3
            fprintf('  ... and %d more\n', length(matchingSignals) - 3);
        end
    end
end

%% Check for transformation matrix signals
fprintf('\n--- Transformation Matrix Analysis ---\n');

% Look for transformation matrix signals
transformPatterns = {
    'Transform',          % Transform
    'Matrix',             % Matrix
    'Rotation',           % Rotation
    '\.R',                % Rotation matrix
    '\.T'                 % Transformation matrix
};

for i = 1:length(transformPatterns)
    pattern = transformPatterns{i};
    matchingSignals = allSignalNames(contains(allSignalNames, pattern));
    fprintf('%s: %d signals\n', pattern, length(matchingSignals));
    if ~isempty(matchingSignals)
        for j = 1:min(3, length(matchingSignals))
            fprintf('  %s\n', matchingSignals{j});
        end
        if length(matchingSignals) > 3
            fprintf('  ... and %d more\n', length(matchingSignals) - 3);
        end
    end
end

%% Summary and Recommendations
fprintf('\n=== Summary and Recommendations ===\n');

totalPositionSignals = length(positionSignals);
totalCenterSignals = length(centerSignals);

fprintf('Current Status:\n');
fprintf('  Position signals (.p): %d\n', totalPositionSignals);
fprintf('  Center signals: %d\n', totalCenterSignals);

if totalPositionSignals > 0
    fprintf('✓ Some position data is being logged\n');
    fprintf('  This is good progress, but may not include all joint centers\n');
else
    fprintf('✗ NO position data is being logged\n');
    fprintf('  This is a critical issue that needs immediate attention\n');
end

if totalCenterSignals > 0
    fprintf('✓ Some center position data is available\n');
else
    fprintf('✗ NO center position data is available\n');
    fprintf('  Joint center positions are not being tracked\n');
end

%% Recommendations
fprintf('\nRecommendations:\n');

if totalPositionSignals == 0
    fprintf('1. IMMEDIATE ACTION REQUIRED:\n');
    fprintf('   - Enable Simscape position logging in your model\n');
    fprintf('   - Add logging blocks for joint center positions\n');
    fprintf('   - Configure Simscape to log all position data\n');
elseif totalPositionSignals < 20
    fprintf('1. ENHANCE LOGGING:\n');
    fprintf('   - Add more position logging for missing joints\n');
    fprintf('   - Ensure all joint centers are being tracked\n');
    fprintf('   - Verify signal paths are correct\n');
else
    fprintf('1. VERIFY DATA QUALITY:\n');
    fprintf('   - Check that position data is in global coordinates\n');
    fprintf('   - Verify data units and coordinate frames\n');
    fprintf('   - Test data extraction and processing\n');
end

fprintf('2. NEXT STEPS:\n');
fprintf('   - Run the enableJointCenterPositionLogging.m script\n');
fprintf('   - Update your model to log joint center positions\n');
fprintf('   - Test with a simple simulation\n');
fprintf('   - Verify data extraction works correctly\n');

fprintf('3. INTEGRATION:\n');
fprintf('   - Update your data processing scripts\n');
fprintf('   - Modify visualization functions\n');
fprintf('   - Integrate with motion matching algorithms\n');

fprintf('\nJoint center positions are CRITICAL for motion matching and 3D visualization!\n');
fprintf('Implement this logging immediately.\n');

end 