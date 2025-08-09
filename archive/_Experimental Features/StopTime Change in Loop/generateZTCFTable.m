function ZTCFTable = generateZTCFTable(modelName, killTimes, stopTimeBuffer)
% Generates ZTCF data using variable simulation stop times.
% 
% Inputs:
%   modelName        - e.g. 'GolfSwing3D_KineticallyDriven'
%   killTimes        - Vector of kill switch times (in seconds)
%   stopTimeBuffer   - Time after killTime to end simulation (e.g., 0.002)
%
% Output:
%   ZTCFTable        - Table with results from each killTime

    if nargin < 3
        stopTimeBuffer = 0.002;  % Default to 2ms after kill time
    end

    nTrials = numel(killTimes);
    in(nTrials,1) = Simulink.SimulationInput(modelName);  % Preallocate SimInput
    ZTCFResults = cell(nTrials,1);  % For later table extraction

    for i = 1:nTrials
        killTime = killTimes(i);
        in(i) = in(i).setVariable('KillTime', killTime);  % Your kill-switch logic
        in(i) = in(i).setModelParameter('StopTime', num2str(killTime + stopTimeBuffer));
    end

    % Run simulations (serial or parallel depending on context)
    out = sim(in, 'ShowProgress', 'on');

    % Extract outputs from each run
    for i = 1:nTrials
        logsout = out(i).logsout;
        % Replace with your extraction logic:
        % e.g., get handle force/torque, timestamp, velocity, etc.
        handForce = logsout.get('LeadHandForce').Values.Data(end, :);
        handTorque = logsout.get('LeadHandTorque').Values.Data(end, :);
        timeVal = logsout.get('LeadHandForce').Values.Time(end);
        
        ZTCFResults{i} = table(killTimes(i), timeVal, handForce, handTorque, ...
            'VariableNames', {'KillTime', 'ActualTime', 'Force', 'Torque'});
    end

    % Combine all into a single table
    ZTCFTable = vertcat(ZTCFResults{:});
end
