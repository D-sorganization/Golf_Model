function RSCFTable = generateRSCFTable(modelName, rigidizationTimes, stopTimeBuffer, baseLogsout, flexSignalName, shaftMassVec)
% RSCF - Rigid Shaft Counterfactual: compares force/torque when replacing flexible shaft at given time.
%
% Inputs:
%   modelName         - Simulink model name (e.g. 'GolfSwing3D_KineticallyDriven')
%   rigidizationTimes - Vector of times (in sec) to replace flexible shaft
%   stopTimeBuffer    - Duration after replacement to simulate (e.g., 0.002)
%   baseLogsout       - Logsout from the full BASE simulation
%   flexSignalName    - Name of shaft node signal in logsout (Nx3 over time)
%   shaftMassVec      - Vector of mass per segment
%
% Output:
%   RSCFTable         - Table with force/torque for each rigidization time

    if nargin < 3 || isempty(stopTimeBuffer)
        stopTimeBuffer = 0.002;  % 2 ms default duration
    end

    nTrials = numel(rigidizationTimes);
    in(nTrials,1) = Simulink.SimulationInput(modelName);
    results = cell(nTrials,1);

    % Extract shaft signal from logsout
    shaftSignal = baseLogsout.get(flexSignalName).Values;
    shaftTime = shaftSignal.Time;

    for i = 1:nTrials
        rigidTime = rigidizationTimes(i);
        [~, idx] = min(abs(shaftTime - rigidTime));

        % Extract shaft shape at that time
        shaftNodes = squeeze(shaftSignal.Data(idx, :, :));
        rigidStruct = rigidizeFlexibleElement(shaftNodes, shaftMassVec);

        % Set up simulation input
        in(i) = in(i).setVariable('RigidShaft_COM', rigidStruct.COM);
        in(i) = in(i).setVariable('RigidShaft_Ibody', rigidStruct.Ibody);
        in(i) = in(i).setVariable('RigidShaft_mass', rigidStruct.mass);
        in(i) = in(i).setVariable('RigidizationTime', rigidTime);
        in(i) = in(i).setVariable('UseRigidShaft', true);
        in(i) = in(i).setModelParameter('StopTime', num2str(rigidTime + stopTimeBuffer));
    end

    % Run simulation batch
    out = sim(in, 'ShowProgress', 'on');

    for i = 1:nTrials
        logsout = out(i).logsout;

        % Extract force and torque signals
        handForce = logsout.get('LeadHandForce').Values.Data(end, :);
        handTorque = logsout.get('LeadHandTorque').Values.Data(end, :);
        timeVal = logsout.get('LeadHandForce').Values.Time(end);

        results{i} = table(rigidizationTimes(i), timeVal, handForce, handTorque, ...
            'VariableNames', {'RigidizationTime', 'ActualTime', 'Force', 'Torque'});
    end

    RSCFTable = vertcat(results{:});
end
