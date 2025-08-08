function [ZTCFQ_updated, DELTAQ_updated] = calculateWorkPowerAndGranularAngularImpulse3D(ZTCFQ, DELTAQ, options)
% CALCULATEWORKPOWERANDGRANULARANGULARIMPULSE3D - Enhanced calculation function
% Calculates work, power, and granular angular impulse with detailed breakdown
%
% Inputs:
%   ZTCFQ - Table containing zero-time-crossing force data
%   DELTAQ - Table containing delta force data  
%   options - Structure with calculation options
%       .calculate_work - Boolean to enable/disable work calculations
%
% Outputs:
%   ZTCFQ_updated - Updated ZTCFQ table with new calculations
%   DELTAQ_updated - Updated DELTAQ table with new calculations
%
% Angular Impulse Breakdown:
%   - Joint Torque Angular Impulse (proximal/distal)
%   - Force Moment Angular Impulse (proximal/distal) 
%   - Total Angular Impulse per joint (proximal/distal/total)

    % Set default options
    if nargin < 3
        options = struct();
    end
    if ~isfield(options, 'calculate_work')
        options.calculate_work = false;
    end

    % Initialize output tables
    ZTCFQ_updated = ZTCFQ;
    DELTAQ_updated = DELTAQ;

    % Extract time data
    if isfield(ZTCFQ, 'Time')
        time_data = ZTCFQ.Time;
    elseif isfield(DELTAQ, 'Time')
        time_data = DELTAQ.Time;
    else
        error('Time column not found in input tables');
    end

    % Define joint names and their proximal/distal ends
    joint_config = struct();
    joint_config.hip = {'Hip_Proximal', 'Hip_Distal'};
    joint_config.knee = {'Knee_Proximal', 'Knee_Distal'};
    joint_config.ankle = {'Ankle_Proximal', 'Ankle_Distal'};
    joint_config.shoulder = {'Shoulder_Proximal', 'Shoulder_Distal'};
    joint_config.elbow = {'Elbow_Proximal', 'Elbow_Distal'};
    joint_config.wrist = {'Wrist_Proximal', 'Wrist_Distal'};

    % Initialize angular impulse storage
    angular_impulse_data = struct();

    % Process each joint
    joint_names = fieldnames(joint_config);
    for i = 1:length(joint_names)
        joint_name = joint_names{i};
        proximal_end = joint_config.(joint_name){1};
        distal_end = joint_config.(joint_name){2};

        % Initialize joint data structure
        angular_impulse_data.(joint_name) = struct();
        angular_impulse_data.(joint_name).proximal = struct();
        angular_impulse_data.(joint_name).distal = struct();
        angular_impulse_data.(joint_name).total = struct();

        % Extract joint-specific data
        [torque_data, angular_velocity_data, applied_torque_data, force_moment_data] = ...
            extractJointData(ZTCFQ, DELTAQ, joint_name);

        % Calculate joint torque angular impulse (separate for proximal/distal)
        if ~isempty(torque_data)
            % Proximal end angular impulse from joint torques
            proximal_torque_impulse = calculateAngularImpulse(torque_data.proximal, time_data);
            angular_impulse_data.(joint_name).proximal.joint_torque_impulse = proximal_torque_impulse;

            % Distal end angular impulse from joint torques  
            distal_torque_impulse = calculateAngularImpulse(torque_data.distal, time_data);
            angular_impulse_data.(joint_name).distal.joint_torque_impulse = distal_torque_impulse;

            % Total joint torque angular impulse
            total_torque_impulse = proximal_torque_impulse + distal_torque_impulse;
            angular_impulse_data.(joint_name).total.joint_torque_impulse = total_torque_impulse;
        end

        % Calculate applied torque angular impulse (separate for proximal/distal)
        if ~isempty(applied_torque_data)
            % Proximal end angular impulse from applied torques
            proximal_applied_impulse = calculateAngularImpulse(applied_torque_data.proximal, time_data);
            angular_impulse_data.(joint_name).proximal.applied_torque_impulse = proximal_applied_impulse;

            % Distal end angular impulse from applied torques
            distal_applied_impulse = calculateAngularImpulse(applied_torque_data.distal, time_data);
            angular_impulse_data.(joint_name).distal.applied_torque_impulse = distal_applied_impulse;

            % Total applied torque angular impulse
            total_applied_impulse = proximal_applied_impulse + distal_applied_impulse;
            angular_impulse_data.(joint_name).total.applied_torque_impulse = total_applied_impulse;
        end

        % Calculate force moment angular impulse (separate for proximal/distal)
        if ~isempty(force_moment_data)
            % Proximal end angular impulse from force moments
            proximal_force_moment_impulse = calculateAngularImpulse(force_moment_data.proximal, time_data);
            angular_impulse_data.(joint_name).proximal.force_moment_impulse = proximal_force_moment_impulse;

            % Distal end angular impulse from force moments
            distal_force_moment_impulse = calculateAngularImpulse(force_moment_data.distal, time_data);
            angular_impulse_data.(joint_name).distal.force_moment_impulse = distal_force_moment_impulse;

            % Total force moment angular impulse
            total_force_moment_impulse = proximal_force_moment_impulse + distal_force_moment_impulse;
            angular_impulse_data.(joint_name).total.force_moment_impulse = total_force_moment_impulse;
        end

        % Calculate total angular impulse for each end and overall
        angular_impulse_data.(joint_name).proximal.total_angular_impulse = ...
            angular_impulse_data.(joint_name).proximal.joint_torque_impulse + ...
            angular_impulse_data.(joint_name).proximal.applied_torque_impulse + ...
            angular_impulse_data.(joint_name).proximal.force_moment_impulse;

        angular_impulse_data.(joint_name).distal.total_angular_impulse = ...
            angular_impulse_data.(joint_name).distal.joint_torque_impulse + ...
            angular_impulse_data.(joint_name).distal.applied_torque_impulse + ...
            angular_impulse_data.(joint_name).distal.force_moment_impulse;

        angular_impulse_data.(joint_name).total.total_angular_impulse = ...
            angular_impulse_data.(joint_name).total.joint_torque_impulse + ...
            angular_impulse_data.(joint_name).total.applied_torque_impulse + ...
            angular_impulse_data.(joint_name).total.force_moment_impulse;

        % Calculate power (always calculated)
        if ~isempty(torque_data) && ~isempty(angular_velocity_data)
            power_data = calculatePower(torque_data, angular_velocity_data);
            
            % Add power data to output tables
            ZTCFQ_updated = addPowerColumns(ZTCFQ_updated, power_data, joint_name, 'ZTCFQ');
            DELTAQ_updated = addPowerColumns(DELTAQ_updated, power_data, joint_name, 'DELTAQ');
        end

        % Calculate work if requested
        if options.calculate_work && ~isempty(torque_data) && ~isempty(angular_velocity_data)
            work_data = calculateWork(torque_data, angular_velocity_data, time_data);
            
            % Add work data to output tables
            ZTCFQ_updated = addWorkColumns(ZTCFQ_updated, work_data, joint_name, 'ZTCFQ');
            DELTAQ_updated = addWorkColumns(DELTAQ_updated, work_data, joint_name, 'DELTAQ');
        end
    end

    % Add angular impulse data to output tables
    ZTCFQ_updated = addAngularImpulseColumns(ZTCFQ_updated, angular_impulse_data, 'ZTCFQ');
    DELTAQ_updated = addAngularImpulseColumns(DELTAQ_updated, angular_impulse_data, 'DELTAQ');

    fprintf('Granular angular impulse calculations completed.\n');
    fprintf('  - Joint torque angular impulse (proximal/distal)\n');
    fprintf('  - Applied torque angular impulse (proximal/distal)\n');
    fprintf('  - Force moment angular impulse (proximal/distal)\n');
    fprintf('  - Total angular impulse per joint end\n');
end

function [torque_data, angular_velocity_data, applied_torque_data, force_moment_data] = extractJointData(ZTCFQ, DELTAQ, joint_name)
% Extract joint-specific data from input tables
    
    torque_data = struct();
    angular_velocity_data = struct();
    applied_torque_data = struct();
    force_moment_data = struct();

    % Define column name patterns for each joint
    joint_columns = getJointColumnNames(joint_name);

    % Extract torque data
    if isfield(ZTCFQ, joint_columns.torque_x) && isfield(ZTCFQ, joint_columns.torque_y) && isfield(ZTCFQ, joint_columns.torque_z)
        torque_data.proximal = [ZTCFQ.(joint_columns.torque_x), ZTCFQ.(joint_columns.torque_y), ZTCFQ.(joint_columns.torque_z)];
        torque_data.distal = -torque_data.proximal; % Equal and opposite
    end

    % Extract angular velocity data
    if isfield(ZTCFQ, joint_columns.angular_velocity_x) && isfield(ZTCFQ, joint_columns.angular_velocity_y) && isfield(ZTCFQ, joint_columns.angular_velocity_z)
        angular_velocity_data.proximal = [ZTCFQ.(joint_columns.angular_velocity_x), ZTCFQ.(joint_columns.angular_velocity_y), ZTCFQ.(joint_columns.angular_velocity_z)];
        angular_velocity_data.distal = angular_velocity_data.proximal; % Same angular velocity
    end

    % Extract applied torque data
    if isfield(ZTCFQ, joint_columns.applied_torque_x) && isfield(ZTCFQ, joint_columns.applied_torque_y) && isfield(ZTCFQ, joint_columns.applied_torque_z)
        applied_torque_data.proximal = [ZTCFQ.(joint_columns.applied_torque_x), ZTCFQ.(joint_columns.applied_torque_y), ZTCFQ.(joint_columns.applied_torque_z)];
        applied_torque_data.distal = -applied_torque_data.proximal; % Equal and opposite
    end

    % Extract force moment data
    if isfield(ZTCFQ, joint_columns.force_moment_x) && isfield(ZTCFQ, joint_columns.force_moment_y) && isfield(ZTCFQ, joint_columns.force_moment_z)
        force_moment_data.proximal = [ZTCFQ.(joint_columns.force_moment_x), ZTCFQ.(joint_columns.force_moment_y), ZTCFQ.(joint_columns.force_moment_z)];
        force_moment_data.distal = -force_moment_data.proximal; % Equal and opposite
    end
end

function joint_columns = getJointColumnNames(joint_name)
% Get column names for a specific joint based on trial_001_20250802_204903.csv structure
    
    joint_columns = struct();
    
    switch lower(joint_name)
        case 'hip'
            joint_columns.torque_x = 'Hip_Torque_X';
            joint_columns.torque_y = 'Hip_Torque_Y';
            joint_columns.torque_z = 'Hip_Torque_Z';
            joint_columns.angular_velocity_x = 'Hip_AngularVelocity_X';
            joint_columns.angular_velocity_y = 'Hip_AngularVelocity_Y';
            joint_columns.angular_velocity_z = 'Hip_AngularVelocity_Z';
            joint_columns.applied_torque_x = 'Hip_AppliedTorque_X';
            joint_columns.applied_torque_y = 'Hip_AppliedTorque_Y';
            joint_columns.applied_torque_z = 'Hip_AppliedTorque_Z';
            joint_columns.force_moment_x = 'Hip_ForceMoment_X';
            joint_columns.force_moment_y = 'Hip_ForceMoment_Y';
            joint_columns.force_moment_z = 'Hip_ForceMoment_Z';
            
        case 'knee'
            joint_columns.torque_x = 'Knee_Torque_X';
            joint_columns.torque_y = 'Knee_Torque_Y';
            joint_columns.torque_z = 'Knee_Torque_Z';
            joint_columns.angular_velocity_x = 'Knee_AngularVelocity_X';
            joint_columns.angular_velocity_y = 'Knee_AngularVelocity_Y';
            joint_columns.angular_velocity_z = 'Knee_AngularVelocity_Z';
            joint_columns.applied_torque_x = 'Knee_AppliedTorque_X';
            joint_columns.applied_torque_y = 'Knee_AppliedTorque_Y';
            joint_columns.applied_torque_z = 'Knee_AppliedTorque_Z';
            joint_columns.force_moment_x = 'Knee_ForceMoment_X';
            joint_columns.force_moment_y = 'Knee_ForceMoment_Y';
            joint_columns.force_moment_z = 'Knee_ForceMoment_Z';
            
        case 'ankle'
            joint_columns.torque_x = 'Ankle_Torque_X';
            joint_columns.torque_y = 'Ankle_Torque_Y';
            joint_columns.torque_z = 'Ankle_Torque_Z';
            joint_columns.angular_velocity_x = 'Ankle_AngularVelocity_X';
            joint_columns.angular_velocity_y = 'Ankle_AngularVelocity_Y';
            joint_columns.angular_velocity_z = 'Ankle_AngularVelocity_Z';
            joint_columns.applied_torque_x = 'Ankle_AppliedTorque_X';
            joint_columns.applied_torque_y = 'Ankle_AppliedTorque_Y';
            joint_columns.applied_torque_z = 'Ankle_AppliedTorque_Z';
            joint_columns.force_moment_x = 'Ankle_ForceMoment_X';
            joint_columns.force_moment_y = 'Ankle_ForceMoment_Y';
            joint_columns.force_moment_z = 'Ankle_ForceMoment_Z';
            
        case 'shoulder'
            joint_columns.torque_x = 'Shoulder_Torque_X';
            joint_columns.torque_y = 'Shoulder_Torque_Y';
            joint_columns.torque_z = 'Shoulder_Torque_Z';
            joint_columns.angular_velocity_x = 'Shoulder_AngularVelocity_X';
            joint_columns.angular_velocity_y = 'Shoulder_AngularVelocity_Y';
            joint_columns.angular_velocity_z = 'Shoulder_AngularVelocity_Z';
            joint_columns.applied_torque_x = 'Shoulder_AppliedTorque_X';
            joint_columns.applied_torque_y = 'Shoulder_AppliedTorque_Y';
            joint_columns.applied_torque_z = 'Shoulder_AppliedTorque_Z';
            joint_columns.force_moment_x = 'Shoulder_ForceMoment_X';
            joint_columns.force_moment_y = 'Shoulder_ForceMoment_Y';
            joint_columns.force_moment_z = 'Shoulder_ForceMoment_Z';
            
        case 'elbow'
            joint_columns.torque_x = 'Elbow_Torque_X';
            joint_columns.torque_y = 'Elbow_Torque_Y';
            joint_columns.torque_z = 'Elbow_Torque_Z';
            joint_columns.angular_velocity_x = 'Elbow_AngularVelocity_X';
            joint_columns.angular_velocity_y = 'Elbow_AngularVelocity_Y';
            joint_columns.angular_velocity_z = 'Elbow_AngularVelocity_Z';
            joint_columns.applied_torque_x = 'Elbow_AppliedTorque_X';
            joint_columns.applied_torque_y = 'Elbow_AppliedTorque_Y';
            joint_columns.applied_torque_z = 'Elbow_AppliedTorque_Z';
            joint_columns.force_moment_x = 'Elbow_ForceMoment_X';
            joint_columns.force_moment_y = 'Elbow_ForceMoment_Y';
            joint_columns.force_moment_z = 'Elbow_ForceMoment_Z';
            
        case 'wrist'
            joint_columns.torque_x = 'Wrist_Torque_X';
            joint_columns.torque_y = 'Wrist_Torque_Y';
            joint_columns.torque_z = 'Wrist_Torque_Z';
            joint_columns.angular_velocity_x = 'Wrist_AngularVelocity_X';
            joint_columns.angular_velocity_y = 'Wrist_AngularVelocity_Y';
            joint_columns.angular_velocity_z = 'Wrist_AngularVelocity_Z';
            joint_columns.applied_torque_x = 'Wrist_AppliedTorque_X';
            joint_columns.applied_torque_y = 'Wrist_AppliedTorque_Y';
            joint_columns.applied_torque_z = 'Wrist_AppliedTorque_Z';
            joint_columns.force_moment_x = 'Wrist_ForceMoment_X';
            joint_columns.force_moment_y = 'Wrist_ForceMoment_Y';
            joint_columns.force_moment_z = 'Wrist_ForceMoment_Z';
            
        otherwise
            error('Unknown joint: %s', joint_name);
    end
end

function angular_impulse = calculateAngularImpulse(torque_data, time_data)
% Calculate angular impulse from torque data over time
    if isempty(torque_data) || isempty(time_data)
        angular_impulse = zeros(1, 3);
        return;
    end
    
    % Calculate impulse for each component (X, Y, Z)
    angular_impulse = zeros(1, 3);
    for i = 1:3
        angular_impulse(i) = trapz(time_data, torque_data(:, i));
    end
end

function power_data = calculatePower(torque_data, angular_velocity_data)
% Calculate power from torque and angular velocity data
    power_data = struct();
    
    if ~isempty(torque_data.proximal) && ~isempty(angular_velocity_data.proximal)
        % Proximal power
        power_data.proximal = sum(torque_data.proximal .* angular_velocity_data.proximal, 2);
        
        % Distal power (equal and opposite)
        power_data.distal = -power_data.proximal;
        
        % Total power
        power_data.total = power_data.proximal + power_data.distal;
    else
        power_data.proximal = [];
        power_data.distal = [];
        power_data.total = [];
    end
end

function work_data = calculateWork(torque_data, angular_velocity_data, time_data)
% Calculate work from power over time
    work_data = struct();
    
    if ~isempty(torque_data.proximal) && ~isempty(angular_velocity_data.proximal) && ~isempty(time_data)
        % Calculate power first
        power_data = calculatePower(torque_data, angular_velocity_data);
        
        % Calculate work by integrating power
        if ~isempty(power_data.proximal)
            work_data.proximal = trapz(time_data, power_data.proximal);
            work_data.distal = trapz(time_data, power_data.distal);
            work_data.total = work_data.proximal + work_data.distal;
        else
            work_data.proximal = 0;
            work_data.distal = 0;
            work_data.total = 0;
        end
    else
        work_data.proximal = 0;
        work_data.distal = 0;
        work_data.total = 0;
    end
end

function table_updated = addPowerColumns(table_original, power_data, joint_name, table_type)
% Add power columns to the output table
    table_updated = table_original;
    
    if ~isempty(power_data.proximal)
        % Add power columns
        table_updated.([joint_name '_Power_Proximal']) = power_data.proximal;
        table_updated.([joint_name '_Power_Distal']) = power_data.distal;
        table_updated.([joint_name '_Power_Total']) = power_data.total;
    end
end

function table_updated = addWorkColumns(table_original, work_data, joint_name, table_type)
% Add work columns to the output table
    table_updated = table_original;
    
    % Add work columns (scalar values)
    table_updated.([joint_name '_Work_Proximal']) = work_data.proximal;
    table_updated.([joint_name '_Work_Distal']) = work_data.distal;
    table_updated.([joint_name '_Work_Total']) = work_data.total;
end

function table_updated = addAngularImpulseColumns(table_original, angular_impulse_data, table_type)
% Add angular impulse columns to the output table
    table_updated = table_original;
    
    joint_names = fieldnames(angular_impulse_data);
    
    for i = 1:length(joint_names)
        joint_name = joint_names{i};
        joint_data = angular_impulse_data.(joint_name);
        
        % Add proximal angular impulse columns
        if isfield(joint_data.proximal, 'joint_torque_impulse')
            table_updated.([joint_name '_JointTorqueImpulse_Proximal_X']) = joint_data.proximal.joint_torque_impulse(1);
            table_updated.([joint_name '_JointTorqueImpulse_Proximal_Y']) = joint_data.proximal.joint_torque_impulse(2);
            table_updated.([joint_name '_JointTorqueImpulse_Proximal_Z']) = joint_data.proximal.joint_torque_impulse(3);
        end
        
        if isfield(joint_data.proximal, 'applied_torque_impulse')
            table_updated.([joint_name '_AppliedTorqueImpulse_Proximal_X']) = joint_data.proximal.applied_torque_impulse(1);
            table_updated.([joint_name '_AppliedTorqueImpulse_Proximal_Y']) = joint_data.proximal.applied_torque_impulse(2);
            table_updated.([joint_name '_AppliedTorqueImpulse_Proximal_Z']) = joint_data.proximal.applied_torque_impulse(3);
        end
        
        if isfield(joint_data.proximal, 'force_moment_impulse')
            table_updated.([joint_name '_ForceMomentImpulse_Proximal_X']) = joint_data.proximal.force_moment_impulse(1);
            table_updated.([joint_name '_ForceMomentImpulse_Proximal_Y']) = joint_data.proximal.force_moment_impulse(2);
            table_updated.([joint_name '_ForceMomentImpulse_Proximal_Z']) = joint_data.proximal.force_moment_impulse(3);
        end
        
        if isfield(joint_data.proximal, 'total_angular_impulse')
            table_updated.([joint_name '_TotalAngularImpulse_Proximal_X']) = joint_data.proximal.total_angular_impulse(1);
            table_updated.([joint_name '_TotalAngularImpulse_Proximal_Y']) = joint_data.proximal.total_angular_impulse(2);
            table_updated.([joint_name '_TotalAngularImpulse_Proximal_Z']) = joint_data.proximal.total_angular_impulse(3);
        end
        
        % Add distal angular impulse columns
        if isfield(joint_data.distal, 'joint_torque_impulse')
            table_updated.([joint_name '_JointTorqueImpulse_Distal_X']) = joint_data.distal.joint_torque_impulse(1);
            table_updated.([joint_name '_JointTorqueImpulse_Distal_Y']) = joint_data.distal.joint_torque_impulse(2);
            table_updated.([joint_name '_JointTorqueImpulse_Distal_Z']) = joint_data.distal.joint_torque_impulse(3);
        end
        
        if isfield(joint_data.distal, 'applied_torque_impulse')
            table_updated.([joint_name '_AppliedTorqueImpulse_Distal_X']) = joint_data.distal.applied_torque_impulse(1);
            table_updated.([joint_name '_AppliedTorqueImpulse_Distal_Y']) = joint_data.distal.applied_torque_impulse(2);
            table_updated.([joint_name '_AppliedTorqueImpulse_Distal_Z']) = joint_data.distal.applied_torque_impulse(3);
        end
        
        if isfield(joint_data.distal, 'force_moment_impulse')
            table_updated.([joint_name '_ForceMomentImpulse_Distal_X']) = joint_data.distal.force_moment_impulse(1);
            table_updated.([joint_name '_ForceMomentImpulse_Distal_Y']) = joint_data.distal.force_moment_impulse(2);
            table_updated.([joint_name '_ForceMomentImpulse_Distal_Z']) = joint_data.distal.force_moment_impulse(3);
        end
        
        if isfield(joint_data.distal, 'total_angular_impulse')
            table_updated.([joint_name '_TotalAngularImpulse_Distal_X']) = joint_data.distal.total_angular_impulse(1);
            table_updated.([joint_name '_TotalAngularImpulse_Distal_Y']) = joint_data.distal.total_angular_impulse(2);
            table_updated.([joint_name '_TotalAngularImpulse_Distal_Z']) = joint_data.distal.total_angular_impulse(3);
        end
        
        % Add total joint angular impulse columns
        if isfield(joint_data.total, 'joint_torque_impulse')
            table_updated.([joint_name '_JointTorqueImpulse_Total_X']) = joint_data.total.joint_torque_impulse(1);
            table_updated.([joint_name '_JointTorqueImpulse_Total_Y']) = joint_data.total.joint_torque_impulse(2);
            table_updated.([joint_name '_JointTorqueImpulse_Total_Z']) = joint_data.total.joint_torque_impulse(3);
        end
        
        if isfield(joint_data.total, 'applied_torque_impulse')
            table_updated.([joint_name '_AppliedTorqueImpulse_Total_X']) = joint_data.total.applied_torque_impulse(1);
            table_updated.([joint_name '_AppliedTorqueImpulse_Total_Y']) = joint_data.total.applied_torque_impulse(2);
            table_updated.([joint_name '_AppliedTorqueImpulse_Total_Z']) = joint_data.total.applied_torque_impulse(3);
        end
        
        if isfield(joint_data.total, 'force_moment_impulse')
            table_updated.([joint_name '_ForceMomentImpulse_Total_X']) = joint_data.total.force_moment_impulse(1);
            table_updated.([joint_name '_ForceMomentImpulse_Total_Y']) = joint_data.total.force_moment_impulse(2);
            table_updated.([joint_name '_ForceMomentImpulse_Total_Z']) = joint_data.total.force_moment_impulse(3);
        end
        
        if isfield(joint_data.total, 'total_angular_impulse')
            table_updated.([joint_name '_TotalAngularImpulse_Total_X']) = joint_data.total.total_angular_impulse(1);
            table_updated.([joint_name '_TotalAngularImpulse_Total_Y']) = joint_data.total.total_angular_impulse(2);
            table_updated.([joint_name '_TotalAngularImpulse_Total_Z']) = joint_data.total.total_angular_impulse(3);
        end
    end
end
