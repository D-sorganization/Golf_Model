% verifyToWorkspaceSetup.m
% Verify ToWorkspace block setup and provide guidance

clear; clc;

fprintf('=== Verifying ToWorkspace Block Setup ===\n\n');
fprintf('This script will help verify your ToWorkspace block configuration.\n\n');

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
        fprintf('   This is likely why ToWorkspace blocks are not being detected.\n\n');
    else
        fprintf('✓ Model is saved\n');
    end
    
catch ME
    fprintf('✗ Error checking model status: %s\n', ME.message);
    return;
end

%% Step 2: Search for ToWorkspace Blocks
fprintf('--- Step 2: Search for ToWorkspace Blocks ---\n');

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

%% Step 4: Look for Signal Buses
fprintf('\n--- Step 4: Look for Signal Buses ---\n');

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

%% Step 5: Provide Setup Instructions
fprintf('\n--- Step 5: Setup Instructions ---\n');

fprintf('🎯 TO-WORKSPACE BLOCK SETUP INSTRUCTIONS:\n\n');

if length(allToWorkspaceBlocks) == 0
    fprintf('❌ NO TOWORKSPACE BLOCKS FOUND!\n\n');
    
    fprintf('To add ToWorkspace blocks to your signal buses:\n\n');
    
    fprintf('1. OPEN THE MODEL IN SIMULINK:\n');
    fprintf('   • Open GolfSwing3D_Kinetic.slx in Simulink\n');
    fprintf('   • Navigate to your signal buses\n\n');
    
    fprintf('2. ADD TOWORKSPACE BLOCKS:\n');
    fprintf('   • Find your signal bus outputs\n');
    fprintf('   • Add "To Workspace" blocks from Simulink Library Browser\n');
    fprintf('   • Connect them to your signal bus outputs\n\n');
    
    fprintf('3. CONFIGURE TOWORKSPACE BLOCKS:\n');
    fprintf('   • Double-click each ToWorkspace block\n');
    fprintf('   • Set VariableName (e.g., "signalBus1", "signalBus2")\n');
    fprintf('   • Set SaveFormat to "Dataset"\n');
    fprintf('   • Set SampleTime to "-1" (inherit)\n\n');
    
    fprintf('4. SAVE THE MODEL:\n');
    fprintf('   • Save the model (Ctrl+S)\n');
    fprintf('   • Close and reopen if needed\n\n');
    
    fprintf('5. TEST THE CONFIGURATION:\n');
    fprintf('   • Run this verification script again\n');
    fprintf('   • Should show ToWorkspace blocks found > 0\n\n');
    
else
    fprintf('✅ TOWORKSPACE BLOCKS FOUND: %d\n\n', length(allToWorkspaceBlocks));
    
    fprintf('If data is still not being captured:\n\n');
    
    fprintf('1. CHECK BLOCK CONFIGURATION:\n');
    fprintf('   • Verify VariableName is set for each block\n');
    fprintf('   • Verify SaveFormat is set to "Dataset"\n\n');
    
    fprintf('2. CHECK CONNECTIONS:\n');
    fprintf('   • Ensure ToWorkspace blocks are connected to signal outputs\n');
    fprintf('   • Check for broken connections (red lines)\n\n');
    
    fprintf('3. SAVE AND RELOAD:\n');
    fprintf('   • Save the model\n');
    fprintf('   • Close and reopen the model\n');
    fprintf('   • Run the test again\n\n');
end

%% Step 6: Alternative Approach
fprintf('\n--- Step 6: Alternative Approach ---\n');

fprintf('If ToWorkspace blocks are difficult to set up:\n\n');

fprintf('OPTION A: Use Data Inspector (Current Working Method)\n');
fprintf('  • Right-click signals and select "Log"\n');
fprintf('  • Use extractSignalsFromDataInspector.m\n');
fprintf('  • Works for individual simulations\n\n');

fprintf('OPTION B: Use parfor instead of parsim\n');
fprintf('  • Use parfor loop with individual sim() calls\n');
fprintf('  • Extract from Data Inspector for each simulation\n');
fprintf('  • More reliable than parsim for Data Inspector data\n\n');

fprintf('OPTION C: Continue with ToWorkspace setup\n');
fprintf('  • Follow the instructions above\n');
fprintf('  • Most efficient for large-scale dataset generation\n\n');

fprintf('Which approach would you prefer?\n');

fprintf('\nToWorkspace setup verification finished! 🔧\n'); 