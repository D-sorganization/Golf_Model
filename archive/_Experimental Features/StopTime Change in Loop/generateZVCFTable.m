function ZVCFTable = generateZVCFTable(modelName, freezeTimes, stopTimeBuffer)
% Generates ZVCF data at specified time points by freezing motion and applying torques only.
%
% Inputs:
%   modelName        - e.g. 'GolfSwing3D_KineticallyDriven'
%   freezeTimes      - Vector of times to freeze motion and start torque-only simulation
%   stopTimeBuffer   - Duration after freeze to simulate (e.g., 0.002s)
%
% Output:
%   ZVCFTable        - Table containing joint forces/torques under ZVCF conditions

    if nargin < 3
        stopTimeBuffer = 0.002;  % Default simulation duration
    end

    nTrials = numel(freezeTimes);
    in(nTrials,1) = Simulink.SimulationInput(modelName);  % Preallocate
    ZVCFResults = cell(nTrials,1);

    for i = 1:nTrials
        freezeTime = freezeTimes(i);

        % Each run:
        % - Must load state from original simulation (or use logged states)
        % - Set gravity = 0
        % - Set velocity = 0 (handled in the model by freeze logic)
        % - Maintain torques at joints

        in(i) = in(i).setVariable('ZVCF_FreezeTime', freezeTime);  % Trigger freeze logic
        in(i) = in(i).setVariable('DisableGravity', true);
        in(i) = in(i).setVariable('DisableMomentum', true);  % Optional if modeled separately
        in(i) = in(i).setModelParameter('StopTime', num2str(stopTimeBuffer));
    end

    % Run simulation
    out = sim(in, 'ShowProgress', 'on');

    % Extract outputs
    for i = 1:nTrials
        logsout = out(i).logsout;
        % Replace with actual signals:
        handForce = logsout.get('LeadHandForce').Values.Data(end, :);
        handTorque = logsout.get('LeadHandTorque').Values.Data(end, :);
        timeVal = logsout.get('LeadHandForce').Values.Time(end);
        
        ZVCFResults{i} = table(freezeTimes(i), timeVal, handForce, handTorque, ...
            'VariableNames', {'FreezeTime', 'ActualTime', 'Force', 'Torque'});
    end

    ZVCFTable = vertcat(ZVCFResults{:});
end
