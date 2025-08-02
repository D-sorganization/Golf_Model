% analyzeMidhandsData.m
% Analyzes the midhands point data in the golf swing dataset
% to verify position (x,y,z) and orientation (rotation matrix) information

clear; clc;

fprintf('=== Analyzing Midhands Point Data ===\n\n');

%% Load the dataset
try
    % Add the correct path to find the dataset
    base_dir = fileparts(pwd);
    dataset_path = fullfile(base_dir, '100_Simulation_Test_Dataset', '100_sim_dataset_20250723_103854.mat');
    
    if exist(dataset_path, 'file')
        load(dataset_path);
        fprintf('✓ Loaded 100-simulation dataset\n');
        
        % Check dataset structure
        if isfield(dataset, 'simulations')
            num_sims = length(dataset.simulations);
            fprintf('Dataset contains %d simulations\n\n', num_sims);
            
            % Analyze first simulation in detail
            first_sim = dataset.simulations{1};
            fprintf('--- Analysis of First Simulation ---\n');
            
            % Check available fields
            fields = fieldnames(first_sim);
            fprintf('Available fields: %s\n', strjoin(fields, ', '));
            
            % Check for midhands data
            if isfield(first_sim, 'MH')
                fprintf('\n✓ Found MH (Midhands Position) data\n');
                MH_data = first_sim.MH;
                fprintf('  - Size: %s\n', mat2str(size(MH_data)));
                fprintf('  - Data type: %s\n', class(MH_data));
                
                % Check if it's 3D position data
                if size(MH_data, 1) == 3
                    fprintf('  - Format: 3D position vectors (x, y, z)\n');
                    fprintf('  - Number of time points: %d\n', size(MH_data, 2));
                    
                    % Show sample data
                    fprintf('  - Sample positions (first 5 time points):\n');
                    for i = 1:min(5, size(MH_data, 2))
                        fprintf('    t%d: [%.3f, %.3f, %.3f]\n', i, MH_data(1,i), MH_data(2,i), MH_data(3,i));
                    end
                    
                    % Calculate position statistics
                    x_range = [min(MH_data(1,:)), max(MH_data(1,:))];
                    y_range = [min(MH_data(2,:)), max(MH_data(2,:))];
                    z_range = [min(MH_data(3,:)), max(MH_data(3,:))];
                    
                    fprintf('  - Position ranges:\n');
                    fprintf('    X: [%.3f, %.3f] m\n', x_range(1), x_range(2));
                    fprintf('    Y: [%.3f, %.3f] m\n', y_range(1), y_range(2));
                    fprintf('    Z: [%.3f, %.3f] m\n', z_range(1), z_range(2));
                    
                elseif size(MH_data, 2) == 3
                    fprintf('  - Format: 3D position vectors (x, y, z) - transposed\n');
                    fprintf('  - Number of time points: %d\n', size(MH_data, 1));
                    
                    % Show sample data
                    fprintf('  - Sample positions (first 5 time points):\n');
                    for i = 1:min(5, size(MH_data, 1))
                        fprintf('    t%d: [%.3f, %.3f, %.3f]\n', i, MH_data(i,1), MH_data(i,2), MH_data(i,3));
                    end
                    
                    % Calculate position statistics
                    x_range = [min(MH_data(:,1)), max(MH_data(:,1))];
                    y_range = [min(MH_data(:,2)), max(MH_data(:,2))];
                    z_range = [min(MH_data(:,3)), max(MH_data(:,3))];
                    
                    fprintf('  - Position ranges:\n');
                    fprintf('    X: [%.3f, %.3f] m\n', x_range(1), x_range(2));
                    fprintf('    Y: [%.3f, %.3f] m\n', y_range(1), y_range(2));
                    fprintf('    Z: [%.3f, %.3f] m\n', z_range(1), z_range(2));
                    
                else
                    fprintf('  - Warning: Unexpected size for position data\n');
                    fprintf('  - Data preview (first 10 elements):\n');
                    fprintf('    %s\n', mat2str(MH_data(1:min(10, numel(MH_data)))));
                end
            else
                fprintf('✗ No MH (Midhands Position) data found\n');
            end
            
            % Check for midhands rotation data
            if isfield(first_sim, 'MH_R')
                fprintf('\n✓ Found MH_R (Midhands Rotation) data\n');
                MH_R_data = first_sim.MH_R;
                fprintf('  - Size: %s\n', mat2str(size(MH_R_data)));
                fprintf('  - Data type: %s\n', class(MH_R_data));
                
                % Check if it's rotation matrix data
                if size(MH_R_data, 1) == 3 && size(MH_R_data, 2) == 3
                    fprintf('  - Format: 3x3 rotation matrices\n');
                    fprintf('  - Number of time points: %d\n', size(MH_R_data, 3));
                    
                    % Show sample rotation matrix
                    fprintf('  - Sample rotation matrix (first time point):\n');
                    R_sample = MH_R_data(:,:,1);
                    fprintf('    [%.3f, %.3f, %.3f]\n', R_sample(1,1), R_sample(1,2), R_sample(1,3));
                    fprintf('    [%.3f, %.3f, %.3f]\n', R_sample(2,1), R_sample(2,2), R_sample(2,3));
                    fprintf('    [%.3f, %.3f, %.3f]\n', R_sample(3,1), R_sample(3,2), R_sample(3,3));
                    
                    % Verify it's a valid rotation matrix
                    det_R = det(R_sample);
                    fprintf('  - Determinant: %.6f (should be 1.0 for valid rotation)\n', det_R);
                    
                    % Check orthogonality
                    R_RT = R_sample * R_sample';
                    orthogonality_error = norm(R_RT - eye(3), 'fro');
                    fprintf('  - Orthogonality error: %.6f (should be 0.0)\n', orthogonality_error);
                    
                elseif size(MH_R_data, 1) == 9
                    fprintf('  - Format: 9-element rotation vectors (flattened 3x3 matrices)\n');
                    fprintf('  - Number of time points: %d\n', size(MH_R_data, 2));
                    
                    % Show sample data
                    fprintf('  - Sample rotation (first time point):\n');
                    R_vec = MH_R_data(:,1);
                    fprintf('    [%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', R_vec);
                    
                else
                    fprintf('  - Warning: Unexpected size for rotation data\n');
                end
            else
                fprintf('✗ No MH_R (Midhands Rotation) data found\n');
            end
            
            % Check time data
            if isfield(first_sim, 'time')
                time_data = first_sim.time;
                fprintf('\n✓ Found time data\n');
                fprintf('  - Size: %s\n', mat2str(size(time_data)));
                fprintf('  - Time range: [%.3f, %.3f] seconds\n', time_data(1), time_data(end));
                fprintf('  - Number of time points: %d\n', length(time_data));
                fprintf('  - Time step: %.3f seconds\n', (time_data(end) - time_data(1)) / (length(time_data) - 1));
            end
            
            % Check joint data
            if isfield(first_sim, 'q')
                q_data = first_sim.q;
                fprintf('\n✓ Found joint position data (q)\n');
                fprintf('  - Size: %s\n', mat2str(size(q_data)));
                fprintf('  - Number of joints: %d\n', size(q_data, 1));
                fprintf('  - Number of time points: %d\n', size(q_data, 2));
            end
            
            % Check joint velocity data
            if isfield(first_sim, 'qd')
                qd_data = first_sim.qd;
                fprintf('\n✓ Found joint velocity data (qd)\n');
                fprintf('  - Size: %s\n', mat2str(size(qd_data)));
            end
            
            % Check joint acceleration data
            if isfield(first_sim, 'qdd')
                qdd_data = first_sim.qdd;
                fprintf('\n✓ Found joint acceleration data (qdd)\n');
                fprintf('  - Size: %s\n', mat2str(size(qdd_data)));
            end
            
            % Check torque data
            if isfield(first_sim, 'tau')
                tau_data = first_sim.tau;
                fprintf('\n✓ Found joint torque data (tau)\n');
                fprintf('  - Size: %s\n', mat2str(size(tau_data)));
            end
            
        else
            fprintf('✗ Dataset does not contain simulations field\n');
        end
        
    else
        fprintf('✗ Dataset file not found at: %s\n', dataset_path);
    end
    
catch ME
    fprintf('✗ Error analyzing dataset: %s\n', ME.message);
end

%% Summary and recommendations
fprintf('\n--- Summary and Recommendations ---\n');

fprintf('1. MIDHANDS DATA STATUS:\n');
if exist('first_sim', 'var') && isfield(first_sim, 'MH') && isfield(first_sim, 'MH_R')
    fprintf('   ✓ Position data (MH): Available\n');
    fprintf('   ✓ Rotation data (MH_R): Available\n');
    fprintf('   ✓ Both position and orientation data are present for kinematic control\n');
else
    fprintf('   ✗ Missing midhands position or rotation data\n');
    fprintf('   ✗ Cannot perform kinematic control without this data\n');
end

fprintf('\n2. DATA QUALITY:\n');
fprintf('   - Verify rotation matrices are valid (determinant = 1, orthogonal)\n');
fprintf('   - Check for consistent time sampling across all signals\n');
fprintf('   - Ensure position and rotation data are synchronized\n');

fprintf('\n3. KINEMATIC CONTROL IMPLICATIONS:\n');
fprintf('   - Midhands position can be used for trajectory tracking\n');
fprintf('   - Midhands orientation can be used for club face control\n');
fprintf('   - Both are critical for matching real golf swing kinematics\n');

fprintf('\n=== Analysis Complete ===\n'); 