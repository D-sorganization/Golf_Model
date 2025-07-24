% debugSimulationOutput.m
% Debug script to see what data is available in simulation output

clear; clc;

fprintf('=== Debugging Simulation Output ===\n\n');

% Load the most recent simulation result
testDir = dir('JointCenterTest_*');
if isempty(testDir)
    fprintf('✗ No test directories found\n');
    return;
end

latestDir = testDir(end).name;
fprintf('Using latest test directory: %s\n', latestDir);

% Load simulation result
simFile = fullfile(latestDir, 'sim_Test_Run_1.mat');
if ~exist(simFile, 'file')
    fprintf('✗ Simulation file not found: %s\n', simFile);
    return;
end

fprintf('Loading simulation file: %s\n', simFile);
load(simFile);

fprintf('\n=== Simulation Output Analysis ===\n');

% Check what fields are in simOut
if exist('simOut', 'var')
    fprintf('✓ simOut variable found\n');
    
    % List all fields in simOut
    fields = fieldnames(simOut);
    fprintf('Fields in simOut (%d total):\n', length(fields));
    for i = 1:length(fields)
        field = fields{i};
        value = simOut.(field);
        fprintf('  %d. %s: ', i, field);
        
        if isempty(value)
            fprintf('empty\n');
        elseif isstruct(value)
            fprintf('struct with %d fields\n', length(fieldnames(value)));
        elseif isnumeric(value)
            fprintf('numeric array %s\n', mat2str(size(value)));
        else
            fprintf('type: %s\n', class(value));
        end
    end
    
    % Check for specific data types
    fprintf('\n=== Detailed Analysis ===\n');
    
    if isfield(simOut, 'logsout')
        logsout = simOut.logsout;
        fprintf('logsout found: %s\n', class(logsout));
        if ~isempty(logsout)
            fprintf('  numElements: %d\n', logsout.numElements);
            if logsout.numElements > 0
                fprintf('  First element: %s\n', logsout.getElement(1).Name);
            end
        end
    else
        fprintf('✗ logsout not found\n');
    end
    
    if isfield(simOut, 'yout')
        yout = simOut.yout;
        fprintf('yout found: %s\n', class(yout));
        if ~isempty(yout)
            fprintf('  numElements: %d\n', yout.numElements);
        end
    else
        fprintf('✗ yout not found\n');
    end
    
    if isfield(simOut, 'xout')
        xout = simOut.xout;
        fprintf('xout found: %s\n', class(xout));
        if ~isempty(xout)
            fprintf('  numElements: %d\n', xout.numElements);
        end
    else
        fprintf('✗ xout not found\n');
    end
    
    % Check for any other output data
    fprintf('\n=== Checking for Other Output Data ===\n');
    for i = 1:length(fields)
        field = fields{i};
        value = simOut.(field);
        
        if isstruct(value) && ~isempty(value)
            subFields = fieldnames(value);
            fprintf('Field "%s" has %d sub-fields:\n', field, length(subFields));
            for j = 1:min(5, length(subFields)) % Show first 5
                subField = subFields{j};
                fprintf('  - %s\n', subField);
            end
            if length(subFields) > 5
                fprintf('  ... and %d more\n', length(subFields) - 5);
            end
        end
    end
    
else
    fprintf('✗ simOut variable not found\n');
    
    % List all variables in the file
    vars = whos('-file', simFile);
    fprintf('Variables in file:\n');
    for i = 1:length(vars)
        fprintf('  %d. %s: %s\n', i, vars(i).name, vars(i).class);
    end
end

fprintf('\n=== Debug Complete ===\n'); 