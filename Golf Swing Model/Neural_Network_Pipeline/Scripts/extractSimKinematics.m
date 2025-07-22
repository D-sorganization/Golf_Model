function simData = extractSimKinematics(simOut)
% extractSimKinematics.m
% Extracts joint kinematics (q, qdot, qdotdot) from Simulink simulation output
% Input: simOut - SimulationOutput object from parsim
% Output: simData - struct with joint kinematics and other relevant data

    try
        % Extract joint states from logsout
        logsout = simOut.logsout;
        
        % Try to get joint states with flexible naming
        q = extractSignalData(logsout, {'q', 'joint_pos', 'position'});
        qd = extractSignalData(logsout, {'qd', 'joint_vel', 'velocity', 'qdot'});
        qdd = extractSignalData(logsout, {'qdd', 'joint_acc', 'acceleration', 'qdotdot'});
        tau = extractSignalData(logsout, {'tau', 'torque', 'joint_torque'});
        
        % Get time vector from any available signal
        t = extractTimeVector(logsout);
        
        % Extract clubhead data if available
        try
            CHx = extractSignalData(logsout, {'CHx', 'clubhead_x'});
            CHy = extractSignalData(logsout, {'CHy', 'clubhead_y'});
            CHz = extractSignalData(logsout, {'CHz', 'clubhead_z'});
            CH_pos = [CHx, CHy, CHz];
            
            CHvx = extractSignalData(logsout, {'CHvx', 'clubhead_vx', 'CH_vel_x'});
            CH_vel = CHvx;
            
            % Calculate clubhead speed
            CHS = vecnorm(CH_vel, 2, 2);
            CHS_mph = CHS * 2.23694;
        catch
            % Clubhead data not available, use placeholders
            CH_pos = zeros(size(q,1), 3);
            CH_vel = zeros(size(q,1), 3);
            CHS_mph = zeros(size(q,1), 1);
        end
        
        % Extract mid-hands position and rotation if available
        try
            MH = extractSignalData(logsout, {'MH', 'midhands', 'mid_hands'});
            MH_R = extractSignalData(logsout, {'MH_R', 'midhands_R', 'mid_hands_R'});
        catch
            % Mid-hands data not available, use placeholders
            MH = zeros(size(q,1), 3);
            MH_R = repmat(eye(3), [1, 1, size(q,1)]);
        end
        
        % Package all data into struct
        simData.q = q;
        simData.qd = qd;
        simData.qdd = qdd;
        simData.tau = tau;
        simData.t = t;
        simData.CH_pos = CH_pos;
        simData.CH_vel = CH_vel;
        simData.CHS_mph = CHS_mph;
        simData.MH = MH;
        simData.MH_R = MH_R;
        
        % Add metadata
        simData.nJoints = size(q, 2);
        simData.nFrames = size(q, 1);
        simData.duration = t(end) - t(1);
        
    catch ME
        error('Failed to extract kinematics from simulation output: %s', ME.message);
    end
end

%% Helper Functions

function data = extractSignalData(logsout, possibleNames)
    % Extract signal data using flexible naming
    % Input: logsout - Simulink logsout object
    %        possibleNames - cell array of possible signal names
    % Output: data - signal data or empty array if not found
    
    for i = 1:length(possibleNames)
        try
            signal = logsout.get(possibleNames{i});
            data = signal.Values.Data;
            return;
        catch
            % Try next name
            continue;
        end
    end
    
    % If no signal found, return empty
    data = [];
end

function t = extractTimeVector(logsout)
    % Extract time vector from any available signal
    % Input: logsout - Simulink logsout object
    % Output: t - time vector
    
    try
        % Try to get time from first available signal
        for i = 1:logsout.numElements
            signal = logsout.getElement(i);
            t = signal.Values.Time;
            return;
        end
    catch
        % If no time vector found, create default
        t = [];
    end
end 