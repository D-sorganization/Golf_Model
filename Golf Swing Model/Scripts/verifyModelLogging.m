% verifyModelLogging.m
% Verify current model logging configuration and ToWorkspace blocks

clear; clc;

fprintf('=== Verify Model Logging Configuration ===\n\n');

%% Step 1: Check Model Status
fprintf('--- Step 1: Check Model Status ---\n');

try
    % Load model
    modelName = 'GolfSwing3D_Kinetic';
    if ~bdIsLoaded(modelName)
        load_system(modelName);
        fprintf('✓ Model loaded: %s\n', modelName);
    else
        fprintf('✓ Model already loaded: %s\n', modelName);
    end
    
    % Check if model has unsaved changes
    if bdIsDirty(modelName)
        fprintf('⚠️  Model has unsaved changes - please save the model first!\n');
    else
        fprintf('✓ Model is saved\n');
    end
    
catch ME
    fprintf('✗ Error checking model status: %s\n', ME.message);
    return;
end

%% Step 2: Check ToWorkspace Blocks
fprintf('\n--- Step 2: Check ToWorkspace Blocks ---\n');

try
    % Search for ToWorkspace blocks with different methods
    fprintf('Searching for ToWorkspace blocks...\n');
    
    % Method 1: Direct search
    toWorkspaceBlocks1 = find_system(modelName, 'BlockType', 'ToWorkspace');
    fprintf('Method 1 (BlockType): %d blocks found\n', length(toWorkspaceBlocks1));
    
    % Method 2: Search by name pattern
    toWorkspaceBlocks2 = find_system(modelName, 'Name', '*To Workspace*');
    fprintf('Method 2 (Name pattern): %d blocks found\n', length(toWorkspaceBlocks2));
    
    % Method 3: Search by mask type
    toWorkspaceBlocks3 = find_system(modelName, 'MaskType', 'ToWorkspace');
    fprintf('Method 3 (MaskType): %d blocks found\n', length(toWorkspaceBlocks3));
    
    % Method 4: Search by reference block
    toWorkspaceBlocks4 = find_system(modelName, 'ReferenceBlock', 'simulink/Sinks/To Workspace');
    fprintf('Method 4 (ReferenceBlock): %d blocks found\n', length(toWorkspaceBlocks4));
    
    % Combine all methods
    allToWorkspaceBlocks = unique([toWorkspaceBlocks1; toWorkspaceBlocks2; toWorkspaceBlocks3; toWorkspaceBlocks4]);
    fprintf('Total unique ToWorkspace blocks: %d\n', length(allToWorkspaceBlocks));
    
    if length(allToWorkspaceBlocks) > 0
        fprintf('\nFound ToWorkspace blocks:\n');
        for i = 1:min(10, length(allToWorkspaceBlocks))
            blockPath = allToWorkspaceBlocks{i};
            fprintf('  %d: %s\n', i, blockPath);
            
            % Try to get block parameters
            try
                varName = get_param(blockPath, 'VariableName');
                saveFormat = get_param(blockPath, 'SaveFormat');
                fprintf('    VariableName: %s\n', varName);
                fprintf('    SaveFormat: %s\n', saveFormat);
            catch
                fprintf('    [Error reading parameters]\n');
            end
        end
        
        if length(allToWorkspaceBlocks) > 10
            fprintf('  ... and %d more blocks\n', length(allToWorkspaceBlocks) - 10);
        end
    else
        fprintf('\n❌ No ToWorkspace blocks found!\n');
    end
    
catch ME
    fprintf('✗ Error searching for ToWorkspace blocks: %s\n', ME.message);
end

%% Step 3: Check Signal Logging Configuration
fprintf('\n--- Step 3: Check Signal Logging Configuration ---\n');

try
    % Check current signal logging settings
    fprintf('Current signal logging configuration:\n');
    fprintf('  SignalLogging: %s\n', get_param(modelName, 'SignalLogging'));
    fprintf('  SignalLoggingName: %s\n', get_param(modelName, 'SignalLoggingName'));
    fprintf('  SignalLoggingSaveFormat: %s\n', get_param(modelName, 'SignalLoggingSaveFormat'));
    
    % Check Simscape logging
    fprintf('\nSimscape logging configuration:\n');
    fprintf('  SimscapeLogType: %s\n', get_param(modelName, 'SimscapeLogType'));
    fprintf('  SimscapeLogName: %s\n', get_param(modelName, 'SimscapeLogName'));
    
catch ME
    fprintf('✗ Error checking signal logging configuration: %s\n', ME.message);
end

%% Step 4: Check Signal Buses
fprintf('\n--- Step 4: Check Signal Buses ---\n');

try
    % Search for bus-related blocks
    fprintf('Searching for signal buses...\n');
    
    % Bus blocks
    busBlocks = find_system(modelName, 'BlockType', 'Bus');
    fprintf('  Bus blocks: %d\n', length(busBlocks));
    
    % Bus Creator blocks
    busCreatorBlocks = find_system(modelName, 'BlockType', 'BusCreator');
    fprintf('  Bus Creator blocks: %d\n', length(busCreatorBlocks));
    
    % Bus Selector blocks
    busSelectorBlocks = find_system(modelName, 'BlockType', 'BusSelector');
    fprintf('  Bus Selector blocks: %d\n', length(busSelectorBlocks));
    
    % Mux blocks (often used for signal buses)
    muxBlocks = find_system(modelName, 'BlockType', 'Mux');
    fprintf('  Mux blocks: %d\n', length(muxBlocks));
    
    % Demux blocks
    demuxBlocks = find_system(modelName, 'BlockType', 'Demux');
    fprintf('  Demux blocks: %d\n', length(demuxBlocks));
    
    % Show some bus blocks
    if length(busBlocks) > 0
        fprintf('\nSample bus blocks:\n');
        for i = 1:min(5, length(busBlocks))
            fprintf('  %d: %s\n', i, busBlocks{i});
        end
    end
    
    if length(busCreatorBlocks) > 0
        fprintf('\nSample bus creator blocks:\n');
        for i = 1:min(5, length(busCreatorBlocks))
            fprintf('  %d: %s\n', i, busCreatorBlocks{i});
        end
    end
    
catch ME
    fprintf('✗ Error searching for signal buses: %s\n', ME.message);
end

%% Step 5: Test Simple Simulation
fprintf('\n--- Step 5: Test Simple Simulation ---\n');

try
    % Run a simple simulation to see what gets captured
    fprintf('Running simple simulation to check output...\n');
    
    simInput = Simulink.SimulationInput(modelName);
    simInput = simInput.setModelParameter('StopTime', '0.01');  % Very short
    simInput = simInput.setModelParameter('Solver', 'ode4');
    simInput = simInput.setModelParameter('FixedStep', '0.001');
    
    % Enable all logging
    simInput = simInput.setModelParameter('SimscapeLogType', 'all');
    simInput = simInput.setModelParameter('SimscapeLogName', 'simscape');
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    simOut = sim(simInput);
    fprintf('✓ Simple simulation completed\n');
    
    % Check what's in simOut
    outputFields = fieldnames(simOut);
    fprintf('✓ simOut fields: %d\n', length(outputFields));
    for i = 1:length(outputFields)
        fprintf('  %d: %s\n', i, outputFields{i});
    end
    
    % Check if out field exists
    if isfield(simOut, 'out')
        if ~isempty(simOut.out)
            fprintf('✓ simOut.out contains data\n');
            if isa(simOut.out, 'Simulink.SimulationData.Dataset')
                fprintf('  Type: Dataset with %d elements\n', simOut.out.numElements);
            else
                fprintf('  Type: %s\n', class(simOut.out));
            end
        else
            fprintf('✗ simOut.out is empty\n');
        end
    else
        fprintf('✗ simOut.out field does not exist\n');
    end
    
    % Check if simscape field exists
    if isfield(simOut, 'simscape')
        if ~isempty(simOut.simscape)
            fprintf('✓ simOut.simscape contains data\n');
            if isstruct(simOut.simscape)
                fprintf('  Type: Struct with %d fields\n', length(fieldnames(simOut.simscape)));
            elseif isa(simOut.simscape, 'Simulink.SimulationData.Dataset')
                fprintf('  Type: Dataset with %d elements\n', simOut.simscape.numElements);
            else
                fprintf('  Type: %s\n', class(simOut.simscape));
            end
        else
            fprintf('✗ simOut.simscape is empty\n');
        end
    else
        fprintf('✗ simOut.simscape field does not exist\n');
    end
    
catch ME
    fprintf('✗ Error in simple simulation: %s\n', ME.message);
end

%% Step 6: Summary and Recommendations
fprintf('\n--- Step 6: Summary and Recommendations ---\n');

fprintf('🎯 VERIFICATION RESULTS:\n\n');

if length(allToWorkspaceBlocks) == 0
    fprintf('❌ ISSUE: No ToWorkspace blocks found in model!\n\n');
    
    fprintf('SOLUTION: Add ToWorkspace blocks to your signal buses:\n');
    fprintf('1. Open the model in Simulink\n');
    fprintf('2. Find your signal bus outputs\n');
    fprintf('3. Add "To Workspace" blocks from Simulink Library Browser\n');
    fprintf('4. Connect them to your signal bus outputs\n');
    fprintf('5. Set VariableName (e.g., "signalBus1")\n');
    fprintf('6. Set SaveFormat to "Dataset"\n');
    fprintf('7. Save the model\n\n');
    
else
    fprintf('✅ ToWorkspace blocks found: %d\n', length(allToWorkspaceBlocks));
    fprintf('  Check if they are properly configured and connected\n\n');
end

fprintf('Next Steps:\n');
fprintf('1. Ensure ToWorkspace blocks are added and configured\n');
fprintf('2. Save the model\n');
fprintf('3. Run the test again\n');
fprintf('4. Verify simOut.out contains your signal data\n');

fprintf('\nModel logging verification finished! 🔍\n'); 