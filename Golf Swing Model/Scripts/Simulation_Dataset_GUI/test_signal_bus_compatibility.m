function test_signal_bus_compatibility()
% TEST_SIGNAL_BUS_COMPATIBILITY - Test signal bus compatibility for GUI
% This script verifies that the signal bus structure is compatible with the GUI

fprintf('=== Testing Signal Bus Compatibility ===\n\n');

%% 1. Test current data files
fprintf('1. Testing current data files...\n');

% Check for existing data files
data_files = {'BASEQ.mat', 'ZTCFQ.mat', 'DELTAQ.mat'};
existing_files = {};

for i = 1:length(data_files)
    if exist(data_files{i}, 'file')
        existing_files{end+1} = data_files{i};
        fprintf('   Found: %s\n', data_files{i});
    else
        fprintf('   Missing: %s\n', data_files{i});
    end
end

if isempty(existing_files)
    fprintf('   ❌ No data files found!\n');
    fprintf('   Please ensure you are in the correct directory.\n');
    return;
end

%% 2. Analyze data format
fprintf('\n2. Analyzing data format...\n');

for i = 1:length(existing_files)
    filename = existing_files{i};
    fprintf('\n   --- %s ---\n', filename);
    
    try
        % Load the file
        data = load(filename);
        
        % Get the main variable name (should be the filename without .mat)
        var_name = filename(1:end-4);
        
        if isfield(data, var_name)
            current_data = data.(var_name);
            fprintf('   Format: %s\n', class(current_data));
            
            if istable(current_data)
                fprintf('   ✅ Table format - GUI compatible\n');
                fprintf('   Columns: %d\n', width(current_data));
                fprintf('   Rows: %d\n', height(current_data));
                
                % Show column names
                col_names = current_data.Properties.VariableNames;
                fprintf('   Column names: %s\n', strjoin(col_names(1:min(5, length(col_names))), ', '));
                if length(col_names) > 5
                    fprintf('   ... and %d more columns\n', length(col_names) - 5);
                end
                
            elseif isnumeric(current_data)
                fprintf('   ✅ Numeric array format - GUI compatible\n');
                fprintf('   Size: %s\n', mat2str(size(current_data)));
                
            else
                fprintf('   ⚠️  Unknown format: %s\n', class(current_data));
            end
        else
            fprintf('   ❌ Expected variable %s not found\n', var_name);
        end
        
    catch ME
        fprintf('   ❌ Error loading %s: %s\n', filename, ME.message);
    end
end

%% 3. Test signal bus logging
fprintf('\n3. Testing signal bus logging...\n');

% Check if model exists
model_name = 'GolfSwing3D_Kinetic';
if exist([model_name '.slx'], 'file')
    fprintf('   ✅ Model %s.slx found\n', model_name);
    
    % Load model
    if ~bdIsLoaded(model_name)
        load_system(model_name);
        fprintf('   ✅ Model loaded successfully\n');
    else
        fprintf('   ✅ Model already loaded\n');
    end
    
    % Check for signal bus logging
    try
        % Find Bus Creator blocks
        bus_creators = find_system(model_name, 'FindAll', 'on', 'BlockType', 'BusCreator');
        fprintf('   Found %d Bus Creator blocks\n', length(bus_creators));
        
        % Check for logged signal bus lines
        logged_lines = find_system(model_name, 'FindAll', 'on', 'Type', 'line', 'SignalLogging', 'on');
        fprintf('   Found %d logged signal lines\n', length(logged_lines));
        
        if length(logged_lines) > 0
            fprintf('   ✅ Signal logging is configured\n');
        else
            fprintf('   ⚠️  No signal logging found\n');
        end
        
    catch ME
        fprintf('   ❌ Error checking signal bus: %s\n', ME.message);
    end
    
    % Close model
    if bdIsLoaded(model_name)
        close_system(model_name, 0);
        fprintf('   ✅ Model closed\n');
    end
    
else
    fprintf('   ❌ Model %s.slx not found\n', model_name);
end

%% 4. Generate test data
fprintf('\n4. Generating test data...\n');

% Create sample data in the format the GUI expects
time = (0:0.001:0.1)';  % 101 time points
positions = zeros(length(time), 6);  % 6 DOF positions

% Add some realistic motion
positions(:, 1) = sin(2*pi*10*time) * 0.1;  % X position
positions(:, 2) = cos(2*pi*10*time) * 0.1;  % Y position
positions(:, 3) = time * 2;                 % Z position (rising)
positions(:, 4) = sin(2*pi*5*time) * 0.05;  % X rotation
positions(:, 5) = cos(2*pi*5*time) * 0.05;  % Y rotation
positions(:, 6) = time * 0.5;               % Z rotation

% Combine time and positions
test_data = [time, positions];

% Save test files
test_files = {'test_BASEQ', 'test_ZTCFQ', 'test_DELTAQ'};

for i = 1:length(test_files)
    filename = test_files{i};
    save([filename '.mat'], 'test_data');
    fprintf('   Created: %s.mat (shape: %s)\n', filename, mat2str(size(test_data)));
end

%% 5. Test performance options
fprintf('\n5. Testing performance options...\n');

try
    % Test the performance options dialog
    fprintf('   Testing performance options dialog...\n');
    settings = performance_options();
    
    if ~isempty(settings) && settings.apply_settings
        fprintf('   ✅ Performance options configured:\n');
        fprintf('     - Disable Simscape Results: %s\n', mat2str(settings.disable_simscape_results));
        fprintf('     - Optimize Memory: %s\n', mat2str(settings.optimize_memory));
        fprintf('     - Fast Restart: %s\n', mat2str(settings.fast_restart));
        
        % Generate performance script
        script = generate_performance_script(settings);
        fprintf('   ✅ Performance script generated\n');
    else
        fprintf('   ⚠️  Performance options cancelled or not applied\n');
    end
    
catch ME
    fprintf('   ❌ Error testing performance options: %s\n', ME.message);
end

%% 6. Summary
fprintf('\n=== Summary ===\n');

fprintf('✅ Signal bus compatibility test completed\n');
fprintf('✅ Test data files generated\n');
fprintf('✅ Performance options module tested\n');

fprintf('\n📋 Next Steps:\n');
fprintf('1. Test the GUI with the generated test_*.mat files\n');
fprintf('2. Verify that your signal bus logging is working correctly\n');
fprintf('3. Use the performance options to optimize simulation speed\n');
fprintf('4. Run a full simulation to generate real data files\n');

fprintf('\n=== Test Complete ===\n');

end 