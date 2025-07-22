function injectRigidShaftToModel(modelName, timeIdx, logsout, flexSignalName, shaftMassVec)
% Injects a rigidized version of a flexible shaft into the Simulink model workspace.
%
% Inputs:
%   modelName       - Simulink model string (e.g., 'GolfSwing3D_KineticallyDriven')
%   timeIdx         - Index of time point to extract shape from logsout
%   logsout         - Simulation output object (with node positions)
%   flexSignalName  - Name of the shaft node signal (Nx3 array over time)
%   shaftMassVec    - Vector of segment masses (length = N-1)

    % Extract frozen shape from logs
    shaftSignal = logsout.get(flexSignalName).Values;
    shaftNodes = squeeze(shaftSignal.Data(timeIdx, :, :));  % N x 3

    % Build rigid body structure
    rigidStruct = rigidizeFlexibleElement(shaftNodes, shaftMassVec);

    % Push into base workspace or model workspace
    assignin('base', 'RigidShaft_COM', rigidStruct.COM);
    assignin('base', 'RigidShaft_Ibody', rigidStruct.Ibody);
    assignin('base', 'RigidShaft_mass', rigidStruct.mass);

    % Optionally assign entire structure
    assignin('base', 'RigidShaftStruct', rigidStruct);

    % Toggle model to rigid shaft mode
    set_param(modelName, 'UseRigidShaft', 'on');

    fprintf('Injected rigid shaft with COM [%.2f %.2f %.2f] and mass %.2f\n', ...
        rigidStruct.COM, rigidStruct.mass);
end
