function test_vector_extraction()
% test_vector_extraction.m
% Test script to check 3-vector component extraction

fprintf('=== Testing 3-Vector Component Extraction ===\n\n');

try
    % Test configuration
    config = struct();
    config.num_simulations = 1;
    config.simulation_time = 0.1;
    config.sample_rate = 5;
    config.model_name = 'GolfSwing3D_Kinetic';
    
    % Generate random polynomial coefficients
    polynomial_coeffs = generateRandomPolynomialCoefficients();
    
    % Create simulation input
    simInput = Simulink.SimulationInput(config.model_name);
    simInput = simInput.setModelParameter('StopTime', num2str(config.simulation_time));
    simInput = setPolynomialVariables(simInput, polynomial_coeffs);
    simInput = simInput.setModelParameter('SignalLogging', 'on');
    simInput = simInput.setModelParameter('SignalLoggingName', 'out');
    simInput = simInput.setModelParameter('SignalLoggingSaveFormat', 'Dataset');
    
    % Run simulation
    fprintf('Running test simulation...\n');
    simOut = sim(simInput);
    
    fprintf('✓ Simulation completed\n\n');
    
    % Test the extraction functions directly
    target_time = 0:1/config.sample_rate:config.simulation_time;
    target_time = target_time(target_time <= config.simulation_time);
    
    % Initialize test data
    trial_data = zeros(length(target_time), 0);
    signal_names = {};
    
    fprintf('Testing Simscape Results Explorer extraction...\n');
    [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time);
    
    % Count vector columns (3-component signals)
    vector_columns = 0;
    vector_signals = {};
    
    % Also check for different naming patterns
    underscore_patterns = {};
    other_patterns = {};
    
    for i = 1:length(signal_names)
        name = signal_names{i};
        % Look for signals that end with 1, 2, 3 (3-vector components)
        if endsWith(name, '1') || endsWith(name, '2') || endsWith(name, '3')
            % Check if it's not a rotation matrix (which ends with 11, 12, 13, etc.)
            if ~contains(name, 'Rotation_Transform')
                base_name = name(1:end-1); % Remove 1, 2, 3
                if ~ismember(base_name, vector_signals)
                    vector_signals{end+1} = base_name;
                end
                vector_columns = vector_columns + 1;
            end
        end
        
        % Check for other patterns
        if contains(name, '_')
            parts = strsplit(name, '_');
            if length(parts) >= 2
                last_part = parts{end};
                if isnan(str2double(last_part)) == false % It's a number
                    base_name = strjoin(parts(1:end-1), '_');
                    if ~ismember(base_name, underscore_patterns)
                        underscore_patterns{end+1} = base_name;
                    end
                end
            end
        end
    end
    
    fprintf('\nVector Analysis:\n');
    fprintf('  Total vector columns found: %d\n', vector_columns);
    fprintf('  Unique vector signals: %d\n', length(vector_signals));
    
    if length(vector_signals) > 0
        fprintf('  Expected vector signals: %.1f (should be whole number)\n', vector_columns / 3);
        
        if mod(vector_columns, 3) == 0
            fprintf('  ✓ 3-vector components properly extracted (3 elements each)\n');
        else
            fprintf('  ⚠️  3-vector components may be incomplete\n');
        end
        
        % Show some examples
        fprintf('\nSample vector signals:\n');
        for i = 1:min(5, length(vector_signals))
            fprintf('  %s (3 components)\n', vector_signals{i});
        end
    else
        fprintf('  ✗ No 3-vector components found\n');
    end
    
    % Show other patterns found
    fprintf('\nOther underscore patterns found: %d\n', length(underscore_patterns));
    if length(underscore_patterns) > 0
        fprintf('Sample patterns:\n');
        for i = 1:min(10, length(underscore_patterns))
            fprintf('  %s\n', underscore_patterns{i});
        end
    end
    
    % Show some sample signal names to understand the pattern
    fprintf('\nSample signal names (first 20):\n');
    for i = 1:min(20, length(signal_names))
        fprintf('  %s\n', signal_names{i});
    end
    
    % Count rotation matrix columns
    rotation_columns = 0;
    for i = 1:length(signal_names)
        if contains(signal_names{i}, 'Rotation_Transform')
            rotation_columns = rotation_columns + 1;
        end
    end
    
    fprintf('\nRotation Matrix Analysis:\n');
    fprintf('  Rotation matrix columns: %d\n', rotation_columns);
    if rotation_columns > 0
        fprintf('  Expected rotation matrices: %.1f\n', rotation_columns / 9);
    end
    
    fprintf('\nTotal columns extracted: %d\n', size(trial_data, 2));
    fprintf('Total signal names: %d\n', length(signal_names));
    
catch ME
    fprintf('✗ Test error: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== Test Complete ===\n');

end

% Include the extraction functions
function [trial_data, signal_names] = extractSimscapeResultsData(simOut, trial_data, signal_names, target_time)
    % Extract data from Simscape Results Explorer with improved rotation matrix handling
    try
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run_id = runIDs(end);
            run_obj = Simulink.sdi.getRun(latest_run_id);
            all_signals = run_obj.getAllSignals;
            
            for i = 1:length(all_signals)
                sig = all_signals(i);
                try
                    % Get signal data using the correct method
                    data = sig.Values.Data;
                    time = sig.Values.Time;
                    
                    % Use original signal name, but clean it for table compatibility
                    original_name = sig.Name;
                    % Replace problematic characters but keep descriptive names
                    clean_name = strrep(original_name, ' ', '_');
                    clean_name = strrep(clean_name, '-', '_');
                    clean_name = strrep(clean_name, '.', '_');
                    clean_name = strrep(clean_name, '(', '');
                    clean_name = strrep(clean_name, ')', '');
                    clean_name = strrep(clean_name, '[', '');
                    clean_name = strrep(clean_name, ']', '');
                    clean_name = strrep(clean_name, '/', '_');
                    clean_name = strrep(clean_name, '\', '_');
                    
                    % Handle 3D rotation matrices (3x3xN arrays)
                    if ndims(data) == 3 && size(data, 1) == 3 && size(data, 2) == 3
                        % This is a 3D rotation matrix - extract each component
                        fprintf('      Found 3D rotation matrix: %s (size: %s)\n', clean_name, mat2str(size(data)));
                        
                        % Extract each element of the 3x3 matrix as a separate column
                        for row = 1:3
                            for col = 1:3
                                % Extract the time series for this matrix element
                                element_data = squeeze(data(row, col, :));
                                
                                % Resample to target time
                                resampled_data = resampleSignal(element_data, time, target_time);
                                
                                % Create column name for this matrix element
                                element_name = sprintf('%s_%d%d', clean_name, row, col);
                                
                                [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, element_name);
                                if ~success
                                    fprintf('      ⚠️  Failed to add rotation matrix element %s\n', element_name);
                                end
                            end
                        end
                        
                    % Handle 2D matrices (time x components) - FIXED VERSION
                    elseif ismatrix(data) && size(data, 2) > 1
                        % Multi-dimensional data - extract each component
                        fprintf('      Found 2D matrix: %s (size: %s)\n', clean_name, mat2str(size(data)));
                        
                        % Resample the entire matrix first
                        resampled_matrix = resampleSignal(data, time, target_time);
                        
                        % Then extract each component
                        for j = 1:size(resampled_matrix, 2)
                            component_data = resampled_matrix(:, j);
                            [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, component_data, sprintf('%s_%d', clean_name, j));
                            if ~success
                                fprintf('      ⚠️  Failed to add Simscape column %s_%d\n', clean_name, j);
                            end
                        end
                    else
                        % Single-dimensional data
                        resampled_data = resampleSignal(data, time, target_time);
                        [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, resampled_data, clean_name);
                        if ~success
                            fprintf('      ⚠️  Failed to add Simscape column %s\n', clean_name);
                        end
                    end
                    
                catch ME
                    fprintf('      ⚠️  Error processing Simscape signal %d: %s\n', i, ME.message);
                    % Continue to next signal
                end
            end
        end
        
    catch ME
        fprintf('      ⚠️  Error extracting Simscape results data: %s\n', ME.message);
        % Continue without Simscape data
    end
end

function [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, column_name)
    % Global helper function to safely add a column to trial_data
    try
        % Handle empty data
        if isempty(data_column)
            fprintf('      ⚠️  Skipping %s: empty data\n', column_name);
            success = false;
            return;
        end
        
        % Ensure data_column is a column vector with correct dimensions
        if ~iscolumn(data_column)
            data_column = data_column(:);
        end
        
        % Check if dimensions match
        if size(trial_data, 1) == size(data_column, 1)
            trial_data = [trial_data, data_column];
            signal_names{end+1} = column_name;
            success = true;
        else
            fprintf('      ⚠️  Skipping %s: dimension mismatch (expected %d rows, got %d)\n', ...
                column_name, size(trial_data, 1), size(data_column, 1));
            success = false;
        end
    catch ME
        fprintf('      ⚠️  Error adding column %s: %s\n', column_name, ME.message);
        success = false;
    end
end

function resampled_data = resampleSignal(data, time, target_time)
    % Resample signal data to target time points
    
    if isempty(time) || isempty(data)
        resampled_data = zeros(length(target_time), 1);
        return;
    end
    
    try
        % Handle different data dimensions
        if isvector(data)
            % 1D data
            resampled_data = interp1(time, data, target_time, 'linear', 'extrap');
            resampled_data = resampled_data(:);
        else
            % Multi-dimensional data
            [n_rows, n_cols] = size(data);
            resampled_data = zeros(length(target_time), n_cols);
            
            for col = 1:n_cols
                resampled_data(:, col) = interp1(time, data(:, col), target_time, 'linear', 'extrap');
            end
        end
    catch
        % If interpolation fails, use nearest neighbor
        resampled_data = interp1(time, data, target_time, 'nearest', 'extrap');
        if ~isvector(resampled_data)
            resampled_data = resampled_data(:);
        end
    end
end

function coeffs = generateRandomPolynomialCoefficients()
    % Generate random polynomial coefficients for different joints
    coeffs = struct();
    
    % Define joints that use polynomial inputs
    joints = {'Hip', 'Spine', 'LS', 'RS', 'LE', 'RE', 'LW', 'RW'};
    
    for i = 1:length(joints)
        joint = joints{i};
        
        % Generate random coefficients for 3rd order polynomial (4 coefficients)
        % Range: -100 to 100 for reasonable torque values
        coeffs.([joint '_coeffs']) = (rand(1, 4) - 0.5) * 200;
    end
end

function simInput = setPolynomialVariables(simInput, coeffs)
    % Set polynomial coefficients as variables in the simulation input
    
    fields = fieldnames(coeffs);
    for i = 1:length(fields)
        field_name = fields{i};
        coeff_values = coeffs.(field_name);
        
        % Set as variable in simulation input
        simInput = simInput.setVariable(field_name, coeff_values);
    end
end 