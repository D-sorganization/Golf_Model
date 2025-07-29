% Test complete data extraction including CombinedSignalBus
fprintf('Testing complete data extraction with all sources...\n');

try
    % Load the model
    model_name = 'Model/GolfSwing3D_Kinetic';
    fprintf('Loading model: %s\n', model_name);
    
    if ~bdIsLoaded('GolfSwing3D_Kinetic')
        load_system(model_name);
    end
    
    % Set up simulation parameters
    set_param('GolfSwing3D_Kinetic', 'StopTime', '0.1'); % Short simulation for testing
    set_param('GolfSwing3D_Kinetic', 'SaveOutput', 'on');
    set_param('GolfSwing3D_Kinetic', 'SaveFormat', 'Dataset');
    
    fprintf('Running short simulation...\n');
    
    % Run simulation
    simOut = sim('GolfSwing3D_Kinetic');
    
    fprintf('Simulation completed successfully!\n');
    
    % Add the GUI directory to the path
    addpath('Scripts/Simulation_Dataset_GUI');
    
    % Extract all data sources
    all_data = {};
    total_signals = 0;
    
    % 1. Extract logsout data
    if isprop(simOut, 'logsout')
        fprintf('\n--- Extracting Logsout Data ---\n');
        logsout_data = extractLogsoutDataFixed(simOut.logsout);
        if ~isempty(logsout_data)
            all_data{end+1} = logsout_data;
            total_signals = total_signals + width(logsout_data);
            fprintf('Logsout extracted: %d columns\n', width(logsout_data));
        end
    end
    
    % 2. Extract CombinedSignalBus data
    if isprop(simOut, 'CombinedSignalBus')
        fprintf('\n--- Extracting CombinedSignalBus Data ---\n');
        combined_bus_data = extractCombinedSignalBusData(simOut.CombinedSignalBus);
        if ~isempty(combined_bus_data)
            all_data{end+1} = combined_bus_data;
            total_signals = total_signals + width(combined_bus_data);
            fprintf('CombinedSignalBus extracted: %d columns\n', width(combined_bus_data));
        end
    end
    
    % 3. Extract simscape data
    if isprop(simOut, 'simlog')
        fprintf('\n--- Extracting Simscape Data ---\n');
        simscape_data = extractSimscapeDataFixed(simOut.simlog);
        if ~isempty(simscape_data)
            all_data{end+1} = simscape_data;
            total_signals = total_signals + width(simscape_data);
            fprintf('Simscape extracted: %d columns\n', width(simscape_data));
        end
    end
    
    % 4. Extract workspace outputs
    fprintf('\n--- Extracting Workspace Outputs ---\n');
    workspace_data = extractWorkspaceOutputs(simOut);
    if ~isempty(workspace_data)
        all_data{end+1} = workspace_data;
        total_signals = total_signals + width(workspace_data);
        fprintf('Workspace outputs extracted: %d columns\n', width(workspace_data));
    end
    
    % Combine all data sources
    fprintf('\n--- Combining All Data Sources ---\n');
    if ~isempty(all_data)
        % Use the combineDataSources function from the GUI
        combined_table = combineDataSources(all_data);
        fprintf('SUCCESS: Complete data extraction worked!\n');
        fprintf('Final combined table: %d rows, %d columns\n', height(combined_table), width(combined_table));
        fprintf('Total signals extracted: %d\n', total_signals);
        
        % Show breakdown by source
        fprintf('\nBreakdown by data source:\n');
        for i = 1:length(all_data)
            fprintf('Source %d: %d rows, %d columns\n', i, height(all_data{i}), width(all_data{i}));
        end
        
        % Show some column name examples
        fprintf('\nSample column names:\n');
        all_names = combined_table.Properties.VariableNames;
        fprintf('First 10 columns: %s\n', strjoin(all_names(1:min(10, length(all_names))), ', '));
        if length(all_names) > 10
            fprintf('Last 10 columns: %s\n', strjoin(all_names(end-9:end), ', '));
        end
        
        % Check for time column
        if ismember('time', all_names)
            fprintf('Time column found ✓\n');
        else
            fprintf('WARNING: No time column found\n');
        end
        
    else
        fprintf('ERROR: No data extracted from any source\n');
    end
    
    % Close the model
    if bdIsLoaded('GolfSwing3D_Kinetic')
        close_system('GolfSwing3D_Kinetic', 0);
    end
    
    fprintf('\n=== Test completed ===\n');
    
catch ME
    fprintf('ERROR: Test failed: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end