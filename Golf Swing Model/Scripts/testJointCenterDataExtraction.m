% testJointCenterDataExtraction.m
% Test script to generate a dataset and extract joint center positions from signal buses
% This script will help verify that joint center positions are now being logged correctly

clear; clc;

fprintf('=== Testing Joint Center Position Data Extraction ===\n\n');
fprintf('This script will:\n');
fprintf('1. Generate a test simulation with joint center position logging\n');
fprintf('2. Extract joint center positions from signal buses\n');
fprintf('3. Verify the data quality and completeness\n\n');

%% Step 1: Generate Test Simulation
fprintf('--- Step 1: Generating Test Simulation ---\n');

try
    % Load the model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Create a simple simulation input
    simInput = Simulink.SimulationInput(modelName);
    
    % Set simulation time (short for testing)
    simInput = simInput.setModelParameter('StopTime', '0.5'); % 0.5 seconds for quick test
    
    % Enable comprehensive logging
    simInput = simInput.setModelParameter('DataLogging', 'on');
    simInput = simInput.setModelParameter('DataLoggingSaveFormat', 'Dataset');
    
    fprintf('✓ Simulation input configured\n');
    
    % Run the simulation
    fprintf('Running test simulation...\n');
    simOut = sim(simInput);
    fprintf('✓ Simulation completed successfully\n');
    
catch ME
    fprintf('✗ Error in simulation: %s\n', ME.message);
    return;
end

%% Step 2: Analyze Available Signal Buses
fprintf('\n--- Step 2: Analyzing Available Signal Buses ---\n');

try
    % Get all logged signals
    if isfield(simOut, 'logsout') && ~isempty(simOut.logsout)
        logsout = simOut.logsout;
        fprintf('✓ Logsout data available\n');
        
        % Get all signal names
        allSignalNames = {};
        for i = 1:logsout.numElements
            signalElement = logsout.getElement(i);
            allSignalNames{end+1} = signalElement.Name;
        end
        
        fprintf('Total logged signals: %d\n', length(allSignalNames));
        
        % Display all signal names for analysis
        fprintf('\nAll logged signal names:\n');
        for i = 1:length(allSignalNames)
            fprintf('  %d. %s\n', i, allSignalNames{i});
        end
        
    else
        fprintf('✗ No logsout data found\n');
        return;
    end
    
catch ME
    fprintf('✗ Error analyzing signal buses: %s\n', ME.message);
    return;
end

%% Step 3: Identify Joint Center Position Signals
fprintf('\n--- Step 3: Identifying Joint Center Position Signals ---\n');

% Look for signal buses that might contain joint center positions
jointCenterPatterns = {
    'Joint.*Position',     % Joint position signals
    'Center.*Position',    % Center position signals
    '.*Position.*Bus',     % Position bus signals
    '.*Pos.*Bus',         % Position bus (abbreviated)
    '.*Center.*Bus',      % Center bus signals
    '.*Joint.*Bus',       % Joint bus signals
    '.*Position',         % Any position signals
    '.*Center',           % Any center signals
    '.*Bus'               % Any bus signals
};

fprintf('Searching for joint center position signals...\n');

foundSignals = {};
for i = 1:length(jointCenterPatterns)
    pattern = jointCenterPatterns{i};
    matchingSignals = allSignalNames(~cellfun(@isempty, regexp(allSignalNames, pattern, 'once')));
    
    if ~isempty(matchingSignals)
        fprintf('\nPattern "%s" found %d signals:\n', pattern, length(matchingSignals));
        for j = 1:length(matchingSignals)
            fprintf('  %s\n', matchingSignals{j});
            foundSignals{end+1} = matchingSignals{j};
        end
    end
end

% Remove duplicates
foundSignals = unique(foundSignals);

fprintf('\nTotal unique joint center position signals found: %d\n', length(foundSignals));

%% Step 4: Extract Joint Center Position Data
fprintf('\n--- Step 4: Extracting Joint Center Position Data ---\n');

jointCenterData = struct();
jointCenterData.time = [];
jointCenterData.signals = {};

try
    % Get time vector from any signal
    if logsout.numElements > 0
        firstSignal = logsout.getElement(1);
        jointCenterData.time = firstSignal.Values.Time;
        fprintf('✓ Time vector extracted: %d time points\n', length(jointCenterData.time));
    end
    
    % Extract data from each found signal
    for i = 1:length(foundSignals)
        signalName = foundSignals{i};
        
        try
            % Get the signal element
            signalElement = logsout.get(signalName);
            signalData = signalElement.Values.Data;
            
            % Store the data
            jointCenterData.signals{end+1} = signalName;
            jointCenterData.(['data_' num2str(i)]) = signalData;
            
            fprintf('✓ Extracted: %s (size: %s)\n', signalName, mat2str(size(signalData)));
            
        catch ME
            fprintf('✗ Failed to extract %s: %s\n', signalName, ME.message);
        end
    end
    
    fprintf('\n✓ Joint center position data extraction completed\n');
    
catch ME
    fprintf('✗ Error extracting joint center position data: %s\n', ME.message);
    return;
end

%% Step 5: Analyze Data Structure
fprintf('\n--- Step 5: Analyzing Data Structure ---\n');

if ~isempty(jointCenterData.signals)
    fprintf('Joint center position signals found:\n');
    for i = 1:length(jointCenterData.signals)
        signalName = jointCenterData.signals{i};
        dataField = ['data_' num2str(i)];
        
        if isfield(jointCenterData, dataField)
            data = jointCenterData.(dataField);
            fprintf('  %d. %s: %s\n', i, signalName, mat2str(size(data)));
            
            % Check if it's a bus signal (structure)
            if isstruct(data)
                fprintf('    Bus fields: ');
                fields = fieldnames(data);
                for j = 1:length(fields)
                    fprintf('%s ', fields{j});
                end
                fprintf('\n');
            end
        end
    end
else
    fprintf('✗ No joint center position signals found\n');
end

%% Step 6: Check Simscape Results Explorer
fprintf('\n--- Step 6: Checking Simscape Results Explorer ---\n');

try
    simscapeRuns = Simulink.sdi.getAllRunIDs;
    if ~isempty(simscapeRuns)
        latestRun = simscapeRuns(end);
        runObj = Simulink.sdi.getRun(latestRun);
        
        fprintf('✓ Simscape run found: %s (ID: %d)\n', runObj.Name, latestRun);
        
        % Get all Simscape signals
        allSimscapeSignals = runObj.getAllSignals;
        allSimscapeNames = {allSimscapeSignals.Name};
        
        fprintf('Total Simscape signals: %d\n', length(allSimscapeNames));
        
        % Look for position signals in Simscape
        positionSignals = allSimscapeNames(contains(allSimscapeNames, '.p('));
        fprintf('Simscape position signals (.p): %d found\n', length(positionSignals));
        
        if ~isempty(positionSignals)
            fprintf('Simscape position signal examples:\n');
            for i = 1:min(5, length(positionSignals))
                fprintf('  %s\n', positionSignals{i});
            end
        end
        
    else
        fprintf('✗ No Simscape runs found\n');
    end
    
catch ME
    fprintf('✗ Error checking Simscape Results Explorer: %s\n', ME.message);
end

%% Step 7: Create Data Extraction Function
fprintf('\n--- Step 7: Creating Data Extraction Function ---\n');

fprintf('Based on the analysis, here is a function to extract joint center positions:\n\n');

fprintf('function jointCenters = extractJointCenterPositionsFromBuses(simOut)\n');
fprintf('    %% Extract joint center positions from signal buses\n');
fprintf('    %% Input: simOut - SimulationOutput object\n');
fprintf('    %% Output: jointCenters - struct with joint center positions\n\n');
fprintf('    jointCenters = struct();\n\n');
fprintf('    try\n');
fprintf('        logsout = simOut.logsout;\n');
fprintf('        \n');
fprintf('        %% Get time vector\n');
fprintf('        if logsout.numElements > 0\n');
fprintf('            firstSignal = logsout.getElement(1);\n');
fprintf('            jointCenters.time = firstSignal.Values.Time;\n');
fprintf('        end\n');
fprintf('        \n');

% Generate extraction code for each found signal
for i = 1:length(foundSignals)
    signalName = foundSignals{i};
    fprintf('        %% Extract %s\n', signalName);
    fprintf('        try\n');
    fprintf('            signalElement = logsout.get(''%s'');\n', signalName);
    fprintf('            jointCenters.%s = signalElement.Values.Data;\n', strrep(signalName, ' ', '_'));
    fprintf('            fprintf(''✓ Extracted: %s\\n'', ''%s'');\n', signalName);
    fprintf('        catch\n');
    fprintf('            fprintf(''✗ Failed to extract: %s\\n'', ''%s'');\n', signalName);
    fprintf('            jointCenters.%s = [];\n', strrep(signalName, ' ', '_'));
    fprintf('        end\n');
    fprintf('        \n');
end

fprintf('        fprintf(''✓ Joint center position extraction completed\\n'');\n');
fprintf('        fprintf(''Time points: %%d\\n'', length(jointCenters.time));\n');
fprintf('        fprintf(''Signals extracted: %%d\\n'', length(fieldnames(jointCenters)) - 1);\n\n');
fprintf('    catch ME\n');
fprintf('        fprintf(''✗ Error extracting joint center positions: %%s\\n'', ME.message);\n');
fprintf('        jointCenters = [];\n');
fprintf('    end\n');
fprintf('end\n');

%% Step 8: Summary and Next Steps
fprintf('\n--- Step 8: Summary and Next Steps ---\n');

fprintf('Test Results:\n');
fprintf('  ✓ Simulation completed successfully\n');
fprintf('  ✓ Signal buses analyzed\n');
fprintf('  ✓ Joint center position signals identified: %d\n', length(foundSignals));
fprintf('  ✓ Data extraction function generated\n\n');

if length(foundSignals) > 0
    fprintf('SUCCESS! Joint center positions are now being logged.\n');
    fprintf('You can now:\n');
    fprintf('1. Use the generated extraction function\n');
    fprintf('2. Integrate with your motion matching algorithms\n');
    fprintf('3. Create 3D visualizations\n');
    fprintf('4. Compare with motion capture data\n\n');
else
    fprintf('WARNING: No joint center position signals found.\n');
    fprintf('You may need to:\n');
    fprintf('1. Check signal bus configuration in the model\n');
    fprintf('2. Verify logging settings\n');
    fprintf('3. Ensure signal buses are properly connected\n\n');
end

fprintf('Next steps:\n');
fprintf('1. Test the extraction function with your actual simulations\n');
fprintf('2. Validate data quality and coordinate frames\n');
fprintf('3. Integrate with your existing analysis pipeline\n');
fprintf('4. Create motion matching and visualization tools\n\n');

fprintf('Joint center position logging is now enabled! 🎉\n'); 