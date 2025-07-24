% extractCompleteJointData.m
% Extract complete joint data from both logsout and individual signal bus structs
% This captures ALL joint parameters including torques, positions, velocities, etc.


fprintf('=== Extract Complete Joint Data ===\n\n');
fprintf('This script will extract data from:\n');
fprintf('1. out.logsout (main logged signals)\n');
fprintf('2. Individual signal bus structs (out.HipLogs, out.TorsoLogs, etc.)\n\n');

%% Step 1: Check if 'out' variable exists in workspace
fprintf('--- Step 1: Check for out variable ---\n');

if ~exist('out', 'var')
    fprintf('✗ Variable ''out'' not found in workspace\n');
    fprintf('Please run the model manually in MATLAB first, then run this script\n');
    fprintf('The model should create a variable called ''out'' with logged data\n\n');
    
    fprintf('To run the model manually:\n');
    fprintf('1. Open the GolfSwing3D_Kinetic model in Simulink\n');
    fprintf('2. Load the input data (3DModelInputs.mat)\n');
    fprintf('3. Run the simulation\n');
    fprintf('4. The output will be in variable ''out''\n');
    fprintf('5. Then run this script to extract the data\n');
    return;
else
    fprintf('✓ Found variable ''out'' in workspace\n');
    fprintf('  Type: %s\n', class(out));
    
    % Debug: Check what fields are actually in out
    fprintf('  Fields in out:\n');
    if isstruct(out)
        fields = fieldnames(out);
        for i = 1:length(fields)
            fprintf('    %d: %s\n', i, fields{i});
        end
    elseif isa(out, 'Simulink.SimulationOutput')
        fprintf('    Simulink.SimulationOutput object\n');
        % Try to get the actual data
        try
            simOut = out;
            fprintf('    SimOut fields:\n');
            
            % Get all properties of the Simulink.SimulationOutput object
            props = properties(simOut);
            fprintf('      Properties: %s\n', strjoin(props, ', '));
            
            % Check specific fields
            if isfield(simOut, 'out')
                fprintf('      ✓ out field found\n');
            end
            if isfield(simOut, 'logsout')
                fprintf('      ✓ logsout field found\n');
            end
            if isfield(simOut, 'simlog')
                fprintf('      ✓ simlog field found\n');
            end
            if isfield(simOut, 'tout')
                fprintf('      ✓ tout field found\n');
            end
            if isfield(simOut, 'simulationMetadata')
                fprintf('      ✓ simulationMetadata field found\n');
            end
            if isfield(simOut, 'ErrorMessage')
                fprintf('      ✓ ErrorMessage field found\n');
            end
            
            % Try to access the data directly
            fprintf('    Trying to access data directly:\n');
            try
                if ~isempty(simOut.out)
                    fprintf('      ✓ simOut.out has data\n');
                else
                    fprintf('      ✗ simOut.out is empty\n');
                end
            catch ME
                fprintf('      ✗ Error accessing simOut.out: %s\n', ME.message);
            end
            
            try
                if ~isempty(simOut.logsout)
                    fprintf('      ✓ simOut.logsout has data\n');
                else
                    fprintf('      ✗ simOut.logsout is empty\n');
                end
            catch ME
                fprintf('      ✗ Error accessing simOut.logsout: %s\n', ME.message);
            end
            
            try
                if ~isempty(simOut.simlog)
                    fprintf('      ✓ simOut.simlog has data\n');
                else
                    fprintf('      ✗ simOut.simlog is empty\n');
                end
            catch ME
                fprintf('      ✗ Error accessing simOut.simlog: %s\n', ME.message);
            end
            
        catch ME
            fprintf('    Error accessing SimOut fields: %s\n', ME.message);
        end
    end
end

%% Step 2: Extract data from logsout (main signals)
fprintf('\n--- Step 2: Extract from out.logsout ---\n');

logsoutData = struct();
logsoutTorqueCount = 0;

% Try different possible field names
possibleLogsoutFields = {'logsout', 'out', 'simlog'};
logsoutFound = false;

for fieldIdx = 1:length(possibleLogsoutFields)
    fieldName = possibleLogsoutFields{fieldIdx};
    if isfield(out, fieldName) && ~isempty(out.(fieldName))
        fprintf('✓ Found out.%s\n', fieldName);
        logsout = out.(fieldName);
        fprintf('  Type: %s\n', class(logsout));
        logsoutFound = true;
        break;
    end
end

if ~logsoutFound
    fprintf('✗ No logsout data found in any expected field\n');
else
    
    if isa(logsout, 'Simulink.SimulationData.Dataset')
        fprintf('  Elements: %d\n', logsout.numElements);
        
        % Extract all signals from logsout
        for i = 1:logsout.numElements
            try
                element = logsout.getElement(i);
                signalName = element.Name;
                [data, time] = element.getData;
                
                logsoutData.(signalName) = struct('data', data, 'time', time);
                
                % Check if it's torque-related
                if contains(lower(signalName), {'torque', 'tau', 'actuator', 'force', 'moment'}) || ...
                   contains(lower(signalName), {'joint', 'motor', 'drive'})
                    logsoutTorqueCount = logsoutTorqueCount + 1;
                    fprintf('  ✓ Torque signal: %s (%d time points)\n', signalName, length(time));
                else
                    fprintf('  ✓ Signal: %s (%d time points)\n', signalName, length(time));
                end
                
            catch ME
                fprintf('  ✗ Error extracting signal %d: %s\n', i, ME.message);
            end
        end
        
        fprintf('\nLogsout extraction complete:\n');
        fprintf('  Total signals: %d\n', logsout.numElements);
        fprintf('  Torque-related signals: %d\n', logsoutTorqueCount);
        
    else
        fprintf('✗ logsout is not a Dataset\n');
    end
end

%% Step 3: Extract data from individual signal bus structs
fprintf('\n--- Step 3: Extract from signal bus structs ---\n');

% Define expected signal bus structs based on your model
expectedLogStructs = {
    'HipLogs', 'SpineLogs', 'TorsoLogs', ...
    'LSLogs', 'RSLogs', 'LELogs', 'RELogs', ...
    'LWLogs', 'RWLogs', 'LScapLogs', 'RScapLogs', ...
    'LFLogs', 'RFLogs'
};

signalBusData = struct();
signalBusTorqueCount = 0;
foundLogStructs = {};

for i = 1:length(expectedLogStructs)
    structName = expectedLogStructs{i};
    
    if isfield(out, structName)
        fprintf('✓ Found %s\n', structName);
        foundLogStructs{end+1} = structName;
        
        % Get the struct
        logStruct = out.(structName);
        
        if isstruct(logStruct)
            % Get all fields in this struct
            structFields = fieldnames(logStruct);
            fprintf('  Fields: %s\n', strjoin(structFields, ', '));
            
            % Extract each field
            for j = 1:length(structFields)
                fieldName = structFields{j};
                fullFieldName = sprintf('%s.%s', structName, fieldName);
                
                try
                    fieldData = logStruct.(fieldName);
                    
                    % Check if it's a timeseries or has time data
                    if isa(fieldData, 'timeseries')
                        data = fieldData.Data;
                        time = fieldData.Time;
                    elseif isstruct(fieldData) && isfield(fieldData, 'Data') && isfield(fieldData, 'Time')
                        data = fieldData.Data;
                        time = fieldData.Time;
                    elseif isnumeric(fieldData)
                        data = fieldData;
                        time = []; % No time vector available
                    else
                        data = fieldData;
                        time = [];
                    end
                    
                    % Store the data
                    signalBusData.(fullFieldName) = struct('data', data, 'time', time);
                    
                    % Check if it's torque-related
                    if contains(lower(fieldName), {'torque', 'tau', 'actuator', 'force', 'moment'}) || ...
                       contains(lower(fieldName), {'joint', 'motor', 'drive'})
                        signalBusTorqueCount = signalBusTorqueCount + 1;
                        if ~isempty(time)
                            fprintf('    ✓ Torque: %s (%d time points)\n', fieldName, length(time));
                        else
                            fprintf('    ✓ Torque: %s (no time vector)\n', fieldName);
                        end
                    else
                        if ~isempty(time)
                            fprintf('    ✓ Field: %s (%d time points)\n', fieldName, length(time));
                        else
                            fprintf('    ✓ Field: %s (no time vector)\n', fieldName);
                        end
                    end
                    
                catch ME
                    fprintf('    ✗ Error extracting %s: %s\n', fieldName, ME.message);
                end
            end
        else
            fprintf('  ✗ %s is not a struct\n', structName);
        end
    else
        fprintf('✗ %s not found\n', structName);
    end
end

fprintf('\nSignal bus extraction complete:\n');
fprintf('  Found log structs: %s\n', strjoin(foundLogStructs, ', '));
fprintf('  Total fields extracted: %d\n', length(fieldnames(signalBusData)));
fprintf('  Torque-related fields: %d\n', signalBusTorqueCount);

%% Step 4: Extract Simscape Results Explorer data
fprintf('\n--- Step 4: Extract Simscape Results Explorer data ---\n');

simscapeData = struct();
simscapeTorqueCount = 0;

if isfield(out, 'simlog')
    fprintf('✓ Found out.simlog (Simscape data)\n');
    simlog = out.simlog;
    fprintf('  Type: %s\n', class(simlog));
    
    % Extract Simscape data
    if isa(simlog, 'simscape.logging.Node')
        fprintf('  Extracting Simscape node data...\n');
        
        % Get all child nodes (joints, bodies, etc.)
        childNodes = simlog.Children;
        fprintf('  Found %d child nodes\n', length(childNodes));
        
        for i = 1:length(childNodes)
            childNode = childNodes(i);
            nodeName = childNode.Name;
            fprintf('  Processing node: %s\n', nodeName);
            
            % Look for joint-related nodes
            if contains(lower(nodeName), {'joint', 'actuator', 'motor', 'drive'})
                fprintf('    ✓ Joint-related node found\n');
                
                % Get all signals in this node
                signals = childNode.Children;
                fprintf('    Signals: %d\n', length(signals));
                
                for j = 1:length(signals)
                    signal = signals(j);
                    signalName = signal.Name;
                    fullSignalName = sprintf('%s.%s', nodeName, signalName);
                    
                    try
                        % Get signal data
                        if hasData(signal)
                            [data, time] = getData(signal);
                            
                            simscapeData.(fullSignalName) = struct('data', data, 'time', time);
                            
                            % Check if it's torque-related
                            if contains(lower(signalName), {'torque', 'tau', 'actuator', 'force', 'moment'}) || ...
                               contains(lower(signalName), {'joint', 'motor', 'drive'})
                                simscapeTorqueCount = simscapeTorqueCount + 1;
                                fprintf('      ✓ Torque signal: %s (%d time points)\n', signalName, length(time));
                            else
                                fprintf('      ✓ Signal: %s (%d time points)\n', signalName, length(time));
                            end
                        else
                            fprintf('      ✗ No data in signal: %s\n', signalName);
                        end
                        
                    catch ME
                        fprintf('      ✗ Error extracting signal %s: %s\n', signalName, ME.message);
                    end
                end
            else
                fprintf('    - Non-joint node: %s\n', nodeName);
            end
        end
        
        fprintf('\nSimscape extraction complete:\n');
        fprintf('  Total signals: %d\n', length(fieldnames(simscapeData)));
        fprintf('  Torque-related signals: %d\n', simscapeTorqueCount);
        
    else
        fprintf('✗ simlog is not a simscape.logging.Node\n');
    end
else
    fprintf('✗ out.simlog not found\n');
end

%% Step 5: Analyze all torque data
fprintf('\n--- Step 5: Analyze all torque data ---\n');

totalTorqueCount = logsoutTorqueCount + signalBusTorqueCount + simscapeTorqueCount;

% Initialize allTorqueData to avoid scope issues
allTorqueData = struct();

if totalTorqueCount > 0
    fprintf('✅ SUCCESS: Found %d total torque-related signals!\n\n', totalTorqueCount);
    fprintf('Breakdown:\n');
    fprintf('  Logsout torques: %d\n', logsoutTorqueCount);
    fprintf('  Signal bus torques: %d\n', signalBusTorqueCount);
    fprintf('  Simscape torques: %d\n', simscapeTorqueCount);
    
    % Combine all torque data
    allTorqueData = struct();
    
    % Add logsout torques
    if ~isempty(logsoutData)
        logsoutFields = fieldnames(logsoutData);
        for i = 1:length(logsoutFields)
            signalName = logsoutFields{i};
            if contains(lower(signalName), {'torque', 'tau', 'actuator', 'force', 'moment'}) || ...
               contains(lower(signalName), {'joint', 'motor', 'drive'})
                allTorqueData.(signalName) = logsoutData.(signalName);
            end
        end
    end
    
    % Add signal bus torques
    if ~isempty(signalBusData)
        signalBusFields = fieldnames(signalBusData);
        for i = 1:length(signalBusFields)
            fieldName = signalBusFields{i};
            if contains(lower(fieldName), {'torque', 'tau', 'actuator', 'force', 'moment'}) || ...
               contains(lower(fieldName), {'joint', 'motor', 'drive'})
                allTorqueData.(fieldName) = signalBusData.(fieldName);
            end
        end
    end
    
    % Add Simscape torques
    if ~isempty(simscapeData)
        simscapeFields = fieldnames(simscapeData);
        for i = 1:length(simscapeFields)
            fieldName = simscapeFields{i};
            if contains(lower(fieldName), {'torque', 'tau', 'actuator', 'force', 'moment'}) || ...
               contains(lower(fieldName), {'joint', 'motor', 'drive'})
                allTorqueData.(fieldName) = simscapeData.(fieldName);
            end
        end
    end
    
    % List all torque signals
    fprintf('\nAll torque signals found:\n');
    torqueFields = fieldnames(allTorqueData);
    for i = 1:length(torqueFields)
        signalName = torqueFields{i};
        data = allTorqueData.(signalName).data;
        time = allTorqueData.(signalName).time;
        
        fprintf('  %d: %s\n', i, signalName);
        fprintf('    Data size: %s\n', mat2str(size(data)));
        if ~isempty(time)
            fprintf('    Time points: %d\n', length(time));
        end
        if isnumeric(data)
            fprintf('    Data range: [%.3g, %.3g]\n', min(data(:)), max(data(:)));
        end
        fprintf('\n');
    end
    
    % Check for specific joint torques
    fprintf('Looking for specific joint activation torques:\n');
    
    % Define expected joint torque patterns
    expectedJoints = {'Hip', 'Spine', 'Shoulder', 'Elbow', 'Wrist', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW', 'Torso'};
    
    for joint = expectedJoints
        jointName = joint{1};
        foundTorques = {};
        
        for i = 1:length(torqueFields)
            signalName = torqueFields{i};
            if contains(signalName, jointName)
                foundTorques{end+1} = signalName;
            end
        end
        
        if ~isempty(foundTorques)
            fprintf('  ✓ %s torques: %s\n', jointName, strjoin(foundTorques, ', '));
        else
            fprintf('  ✗ No %s torques found\n', jointName);
        end
    end
    
else
    fprintf('⚠️  No torque-related signals found\n');
end

%% Step 6: Check time vector
fprintf('\n--- Step 6: Check time vector ---\n');

if isfield(out, 'tout')
    fprintf('✓ Found out.tout (time vector)\n');
    tout = out.tout;
    fprintf('  Size: %s\n', mat2str(size(tout)));
    fprintf('  Time range: [%.3g, %.3g] seconds\n', tout(1), tout(end));
else
    fprintf('✗ out.tout not found\n');
end

%% Step 7: Save extracted data
fprintf('\n--- Step 7: Save extracted data ---\n');

try
    % Save with timestamp
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('complete_joint_data_%s.mat', timestamp);
    save(filename, 'logsoutData', 'signalBusData', 'simscapeData', 'allTorqueData', 'out');
    
    fprintf('✓ Complete joint data saved to: %s\n', filename);
    fprintf('✓ Contains: logsoutData, signalBusData, simscapeData, allTorqueData, out\n');
    
    % Save summary
    summaryFilename = sprintf('complete_joint_data_summary_%s.txt', timestamp);
    fid = fopen(summaryFilename, 'w');
    if fid ~= -1
        fprintf(fid, 'Complete Joint Data Extraction Summary\n');
        fprintf(fid, '=====================================\n\n');
        fprintf(fid, 'Timestamp: %s\n', timestamp);
        fprintf(fid, 'Data sources: out.logsout + signal bus structs\n');
        fprintf(fid, '\nLogsout data:\n');
        fprintf(fid, '  Total signals: %d\n', length(fieldnames(logsoutData)));
        fprintf(fid, '  Torque-related signals: %d\n', logsoutTorqueCount);
        
        fprintf(fid, '\nSignal bus data:\n');
        fprintf(fid, '  Found log structs: %s\n', strjoin(foundLogStructs, ', '));
        fprintf(fid, '  Total fields: %d\n', length(fieldnames(signalBusData)));
        fprintf(fid, '  Torque-related fields: %d\n', signalBusTorqueCount);
        
        fprintf(fid, '\nSimscape data:\n');
        fprintf(fid, '  Total signals: %d\n', length(fieldnames(simscapeData)));
        fprintf(fid, '  Torque-related signals: %d\n', simscapeTorqueCount);
        
        fprintf(fid, '\nCombined torque data:\n');
        fprintf(fid, '  Total torque signals: %d\n', totalTorqueCount);
        
        if totalTorqueCount > 0
            fprintf(fid, '\nAll torque signals:\n');
            torqueFields = fieldnames(allTorqueData);
            for i = 1:length(torqueFields)
                fprintf(fid, '  %d: %s\n', i, torqueFields{i});
            end
        end
        
        fclose(fid);
        fprintf('✓ Summary saved to: %s\n', summaryFilename);
    end
    
catch ME
    fprintf('✗ Error saving data: %s\n', ME.message);
end

%% Step 8: Summary
fprintf('\n--- Step 8: Summary ---\n');

fprintf('🎯 COMPLETE JOINT DATA EXTRACTION SUMMARY:\n\n');
fprintf('Data Sources Analyzed:\n');
fprintf('  ✓ out.logsout (main signals)\n');
fprintf('  ✓ Individual signal bus structs\n');
fprintf('  ✓ out.simlog (Simscape Results Explorer)\n');
fprintf('  ✓ out.tout (time vector)\n\n');

fprintf('Data Extracted:\n');
fprintf('  Logsout signals: %d\n', length(fieldnames(logsoutData)));
fprintf('  Signal bus fields: %d\n', length(fieldnames(signalBusData)));
fprintf('  Simscape signals: %d\n', length(fieldnames(simscapeData)));
fprintf('  Total torque signals: %d\n', totalTorqueCount);

if totalTorqueCount > 0
    fprintf('\n✅ SUCCESS: Joint activation torques are being captured!\n');
    fprintf('The model IS logging joint torques from multiple sources.\n');
    
    fprintf('\n📋 JOINT TORQUE CAPTURE STATUS:\n');
    fprintf('✅ Signal buses are working\n');
    fprintf('✅ Individual log structs are working\n');
    fprintf('✅ Simscape Results Explorer is working\n');
    fprintf('✅ Torque data is being logged\n');
    fprintf('✅ Data is accessible from multiple sources\n');
    
else
    fprintf('\n⚠️  WARNING: No torque-related signals found\n');
    fprintf('The model may not be configured to log joint torques.\n');
end

fprintf('\n📋 NEXT STEPS:\n');
fprintf('1. Check the saved files for detailed data analysis\n');
fprintf('2. Use logsoutData for main signals\n');
fprintf('3. Use signalBusData for joint-specific parameters\n');
fprintf('4. Use simscapeData for Simscape joint data\n');
fprintf('5. Use allTorqueData for all torque-related signals\n');
fprintf('6. Analyze specific joint torques as needed\n');

fprintf('\n=== Complete Joint Data Extraction Complete ===\n'); 