% Test to examine CombinedSignalBus structure in detail
fprintf('Examining CombinedSignalBus structure...\n');

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
    
    % Examine CombinedSignalBus in detail
    if isprop(simOut, 'CombinedSignalBus')
        fprintf('\n=== Detailed CombinedSignalBus Analysis ===\n');
        combined_bus = simOut.CombinedSignalBus;
        fprintf('CombinedSignalBus type: %s\n', class(combined_bus));
        
        if isstruct(combined_bus)
            bus_fields = fieldnames(combined_bus);
            fprintf('CombinedSignalBus has %d fields\n', length(bus_fields));
            
            % Examine each field in detail
            for i = 1:length(bus_fields)
                field_name = bus_fields{i};
                field_value = combined_bus.(field_name);
                
                fprintf('\nField %d: %s\n', i, field_name);
                fprintf('  Type: %s\n', class(field_value));
                
                if isnumeric(field_value)
                    fprintf('  Size: %s\n', mat2str(size(field_value)));
                    fprintf('  Length: %d\n', length(field_value));
                    if length(field_value) > 0
                        fprintf('  First few values: %s\n', mat2str(field_value(1:min(5,length(field_value)))'));
                    end
                elseif isstruct(field_value)
                    sub_fields = fieldnames(field_value);
                    fprintf('  Sub-fields: %s\n', strjoin(sub_fields, ', '));
                    
                    % Examine first few sub-fields
                    for j = 1:min(3, length(sub_fields))
                        sub_field_name = sub_fields{j};
                        sub_field_value = field_value.(sub_field_name);
                        fprintf('    %s: %s, size: %s\n', sub_field_name, class(sub_field_value), mat2str(size(sub_field_value)));
                    end
                elseif iscell(field_value)
                    fprintf('  Cell array with %d elements\n', length(field_value));
                    if length(field_value) > 0
                        fprintf('  First element type: %s\n', class(field_value{1}));
                    end
                end
            end
            
            % Try to find time data
            fprintf('\n=== Looking for time data ===\n');
            time_candidates = {};
            
            for i = 1:length(bus_fields)
                field_name = bus_fields{i};
                field_value = combined_bus.(field_name);
                
                if isnumeric(field_value) && length(field_value) > 100
                    % Check if this looks like time data (monotonically increasing)
                    if all(diff(field_value) > 0)
                        time_candidates{end+1} = field_name;
                        fprintf('Potential time field: %s (length: %d, monotonically increasing)\n', field_name, length(field_value));
                    end
                end
            end
            
            if isempty(time_candidates)
                fprintf('No obvious time field found. Checking for any numeric field with length > 100...\n');
                for i = 1:length(bus_fields)
                    field_name = bus_fields{i};
                    field_value = combined_bus.(field_name);
                    
                    if isnumeric(field_value) && length(field_value) > 100
                        fprintf('Long numeric field: %s (length: %d)\n', field_name, length(field_value));
                    end
                end
            end
        end
    end
    
    % Close the model
    if bdIsLoaded('GolfSwing3D_Kinetic')
        close_system('GolfSwing3D_Kinetic', 0);
    end
    
    fprintf('\n=== Analysis completed ===\n');
    
catch ME
    fprintf('ERROR: Test failed: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end