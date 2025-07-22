% generateSimInputs.m
% Creates array of SimulationInput objects using 6th-degree torque polynomials

function simInputs = generateSimInputs(coeffMatrix, flags)
% coeffMatrix: [nSim x (7 * nJoints)]
% flags (optional): struct with fields like UseRigidClub, KillswitchGravity, etc.

    if isvector(coeffMatrix)
        coeffMatrix = coeffMatrix(:)';
    end

    nSim = size(coeffMatrix, 1);
    nCoeffsPerJoint = 7;
    jointNames = getJointNames();  % cell array of prefixes (e.g., {'HipInputX', ...})
    nJoints = numel(jointNames);

    simInputs(nSim) = Simulink.SimulationInput('GolfSwing3D_KineticallyDriven');

    for i = 1:nSim
        coeffs = coeffMatrix(i, :);
        sIn = simInputs(i);

        for j = 1:nJoints
            prefix = jointNames{j};
            offset = (j-1)*nCoeffsPerJoint;
            for k = 1:nCoeffsPerJoint
                pname = sprintf('%s%c', prefix, 'A' + (k-1));
                sIn = sIn.setVariable(pname, Simulink.Parameter(coeffs(offset + k)));
            end
        end

        % Optional flags
        if nargin > 1 && isstruct(flags)
            fn = fieldnames(flags);
            for f = 1:numel(fn)
                sIn = sIn.setVariable(fn{f}, Simulink.Parameter(flags.(fn{f})));
            end
        end

        simInputs(i) = sIn;
    end
end

function jointNames = getJointNames()
    % Full list of torque input prefixes extracted from model
    jointNames = {
        'BaseTorqueInputX', 'BaseTorqueInputY', 'BaseTorqueInputZ',
        'HipInputX', 'HipInputY', 'HipInputZ',
        'LSInputX', 'LSInputY', 'LSInputZ',
        'LScapInputX', 'LScapInputY', 'LScapInputZ',
        'LTiltInputX', 'LTiltInputY', 'LTiltInputZ',
        'NeckInputX', 'NeckInputY', 'NeckInputZ',
        'RSInputX', 'RSInputY', 'RSInputZ',
        'RScapInputX', 'RScapInputY', 'RScapInputZ',
        'RTiltInputX', 'RTiltInputY', 'RTiltInputZ'
    };
end
