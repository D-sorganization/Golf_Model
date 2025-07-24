function jointCenters = extractJointCenterPositionsFromBuses(simOut)
% extractJointCenterPositionsFromBuses.m
% Extract joint center positions from signal buses in simulation output
% Input: simOut - SimulationOutput object
% Output: jointCenters - struct with joint center positions

fprintf('=== Extracting Joint Center Positions from Signal Buses ===\n\n');

jointCenters = struct();

try
    % Check if logsout data is available
    if ~isfield(simOut, 'logsout') || isempty(simOut.logsout)
        fprintf('✗ No logsout data found in simulation output\n');
        return;
    end
    
    logsout = simOut.logsout;
    fprintf('✓ Logsout data available\n');
    
    % Get time vector
    if logsout.numElements > 0
        firstSignal = logsout.getElement(1);
        jointCenters.time = firstSignal.Values.Time;
        fprintf('✓ Time vector extracted: %d time points\n', length(jointCenters.time));
    end
    
    % Get all signal names
    allSignalNames = {};
    for i = 1:logsout.numElements
        signalElement = logsout.getElement(i);
        allSignalNames{end+1} = signalElement.Name;
    end
    
    fprintf('Total logged signals: %d\n', length(allSignalNames));
    
    % Define expected joint center position signal patterns
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
    
    % Find matching signals
    foundSignals = {};
    for i = 1:length(jointCenterPatterns)
        pattern = jointCenterPatterns{i};
        matchingSignals = allSignalNames(~cellfun(@isempty, regexp(allSignalNames, pattern, 'once')));
        foundSignals = [foundSignals, matchingSignals];
    end
    
    % Remove duplicates
    foundSignals = unique(foundSignals);
    
    fprintf('Joint center position signals found: %d\n', length(foundSignals));
    
    % Extract data from each found signal
    extractedCount = 0;
    for i = 1:length(foundSignals)
        signalName = foundSignals{i};
        
        try
            % Get the signal element
            signalElement = logsout.get(signalName);
            signalData = signalElement.Values.Data;
            
            % Create a valid field name
            fieldName = strrep(signalName, ' ', '_');
            fieldName = strrep(fieldName, '-', '_');
            fieldName = strrep(fieldName, '.', '_');
            fieldName = strrep(fieldName, '/', '_');
            fieldName = strrep(fieldName, '\\', '_');
            
            % Store the data
            jointCenters.(fieldName) = signalData;
            extractedCount = extractedCount + 1;
            
            fprintf('✓ Extracted: %s (size: %s)\n', signalName, mat2str(size(signalData)));
            
            % If it's a bus signal (structure), analyze its contents
            if isstruct(signalData)
                fields = fieldnames(signalData);
                fprintf('  Bus fields: ');
                for j = 1:length(fields)
                    fprintf('%s ', fields{j});
                end
                fprintf('\n');
                
                % Look for position-related fields within the bus
                for j = 1:length(fields)
                    field = fields{j};
                    if contains(lower(field), {'x', 'y', 'z', 'pos', 'center'})
                        fieldData = signalData.(field);
                        fprintf('  - %s: %s\n', field, mat2str(size(fieldData)));
                    end
                end
            end
            
        catch ME
            fprintf('✗ Failed to extract %s: %s\n', signalName, ME.message);
        end
    end
    
    % Also check for specific joint center signals that might be named differently
    specificJointPatterns = {
        'Hip.*Position', 'Hip.*Center', 'Hip.*Pos',
        'Shoulder.*Position', 'Shoulder.*Center', 'Shoulder.*Pos',
        'Elbow.*Position', 'Elbow.*Center', 'Elbow.*Pos',
        'Wrist.*Position', 'Wrist.*Center', 'Wrist.*Pos',
        'Scapula.*Position', 'Scapula.*Center', 'Scapula.*Pos',
        'Spine.*Position', 'Spine.*Center', 'Spine.*Pos',
        'Torso.*Position', 'Torso.*Center', 'Torso.*Pos'
    };
    
    fprintf('\nSearching for specific joint center signals...\n');
    
    for i = 1:length(specificJointPatterns)
        pattern = specificJointPatterns{i};
        matchingSignals = allSignalNames(~cellfun(@isempty, regexp(allSignalNames, pattern, 'once')));
        
        for j = 1:length(matchingSignals)
            signalName = matchingSignals{j};
            
            % Skip if already extracted
            if any(strcmp(foundSignals, signalName))
                continue;
            end
            
            try
                signalElement = logsout.get(signalName);
                signalData = signalElement.Values.Data;
                
                fieldName = strrep(signalName, ' ', '_');
                fieldName = strrep(fieldName, '-', '_');
                fieldName = strrep(fieldName, '.', '_');
                fieldName = strrep(fieldName, '/', '_');
                fieldName = strrep(fieldName, '\\', '_');
                
                jointCenters.(fieldName) = signalData;
                extractedCount = extractedCount + 1;
                
                fprintf('✓ Extracted specific joint: %s (size: %s)\n', signalName, mat2str(size(signalData)));
                
            catch ME
                fprintf('✗ Failed to extract %s: %s\n', signalName, ME.message);
            end
        end
    end
    
    % Check for coordinate-specific signals (X, Y, Z)
    fprintf('\nSearching for coordinate-specific signals...\n');
    
    coordPatterns = {
        '.*_X$', '.*_Y$', '.*_Z$',
        '.*X_Position', '.*Y_Position', '.*Z_Position',
        '.*X_Center', '.*Y_Center', '.*Z_Center',
        '.*X_Pos', '.*Y_Pos', '.*Z_Pos'
    };
    
    for i = 1:length(coordPatterns)
        pattern = coordPatterns{i};
        matchingSignals = allSignalNames(~cellfun(@isempty, regexp(allSignalNames, pattern, 'once')));
        
        for j = 1:length(matchingSignals)
            signalName = matchingSignals{j};
            
            % Skip if already extracted
            if any(strcmp(foundSignals, signalName))
                continue;
            end
            
            try
                signalElement = logsout.get(signalName);
                signalData = signalElement.Values.Data;
                
                fieldName = strrep(signalName, ' ', '_');
                fieldName = strrep(fieldName, '-', '_');
                fieldName = strrep(fieldName, '.', '_');
                fieldName = strrep(fieldName, '/', '_');
                fieldName = strrep(fieldName, '\\', '_');
                
                jointCenters.(fieldName) = signalData;
                extractedCount = extractedCount + 1;
                
                fprintf('✓ Extracted coordinate: %s (size: %s)\n', signalName, mat2str(size(signalData)));
                
            catch ME
                fprintf('✗ Failed to extract %s: %s\n', signalName, ME.message);
            end
        end
    end
    
    fprintf('\n=== Extraction Summary ===\n');
    fprintf('✓ Joint center position extraction completed\n');
    fprintf('Time points: %d\n', length(jointCenters.time));
    fprintf('Signals extracted: %d\n', extractedCount);
    fprintf('Total fields in jointCenters: %d\n', length(fieldnames(jointCenters)) - 1);
    
    % List all extracted fields
    fields = fieldnames(jointCenters);
    fields = fields(~strcmp(fields, 'time')); % Exclude time field
    
    fprintf('\nExtracted fields:\n');
    for i = 1:length(fields)
        field = fields{i};
        data = jointCenters.(field);
        fprintf('  %d. %s: %s\n', i, field, mat2str(size(data)));
    end
    
    fprintf('\nJoint center positions are now available for motion matching and 3D visualization! 🎉\n');
    
catch ME
    fprintf('✗ Error extracting joint center positions: %s\n', ME.message);
    jointCenters = [];
end

end 