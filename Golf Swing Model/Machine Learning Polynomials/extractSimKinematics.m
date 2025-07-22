function simData = extractSimKinematics(simOut)
% extractSimKinematics.m
% Extracts joint kinematics (q, qdot, qdotdot) from Simulink simulation output
% Input: simOut - SimulationOutput object from parsim
% Output: simData - struct with joint kinematics and other relevant data

    try
        % Extract joint states from logsout
        logsout = simOut.logsout;
        
        % Get joint positions, velocities, and accelerations
        q = logsout.get('q').Values.Data;      % Joint positions
        qd = logsout.get('qd').Values.Data;    % Joint velocities  
        qdd = logsout.get('qdd').Values.Data;  % Joint accelerations
        tau = logsout.get('tau').Values.Data;  % Joint torques
        
        % Get time vector
        t = logsout.get('q').Values.Time;
        
        % Extract clubhead data if available
        try
            CHx = logsout.get('CHx').Values.Data;
            CHy = logsout.get('CHy').Values.Data;
            CHz = logsout.get('CHz').Values.Data;
            CH_pos = [CHx, CHy, CHz];
            
            CHvx = logsout.get('CHvx').Values.Data;
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
            MH = logsout.get('MH').Values.Data;
            MH_R = logsout.get('MH_R').Values.Data;
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