% Test CombinedSignalBus extraction
fprintf('Testing CombinedSignalBus extraction...\n');

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
    
    % Test CombinedSignalBus extraction
    if isprop(simOut, 'CombinedSignalBus')
        fprintf('\n=== Testing CombinedSignalBus Extraction ===\n');
        
        % Add the GUI directory to the path
        addpath('Scripts/Simulation_Dataset_GUI');
        
        combined_bus = simOut.CombinedSignalBus;
        bus_data = extractCombinedSignalBusData(combined_bus);
        
        if ~isempty(bus_data)
            fprintf('SUCCESS: CombinedSignalBus extraction worked!\n');
            fprintf('Result table has %d rows and %d columns\n', height(bus_data), width(bus_data));
            fprintf('First few column names: %s\n', strjoin(bus_data.Properties.VariableNames(1:min(10, width(bus_data))), ', '));
            
            % Show some statistics
            fprintf('\nColumn name statistics:\n');
            all_names = bus_data.Properties.VariableNames;
            fprintf('Total columns: %d\n', length(all_names));
            
            % Count by prefix
            prefixes = {};
            for i = 1:length(all_names)
                if ~strcmp(all_names{i}, 'time')
                    parts = strsplit(all_names{i}, '_');
                    if length(parts) > 0
                        prefixes{end+1} = parts{1};
                    end
                end
            end
            
            unique_prefixes = unique(prefixes);
            fprintf('Unique signal groups: %d\n', length(unique_prefixes));
            fprintf('Signal groups: %s\n', strjoin(unique_prefixes, ', '));
            
        else
            fprintf('WARNING: CombinedSignalBus extraction returned empty result\n');
        end
    else
        fprintf('No CombinedSignalBus data available\n');
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