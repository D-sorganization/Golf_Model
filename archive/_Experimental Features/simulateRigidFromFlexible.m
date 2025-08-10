function out = simulateRigidFromFlexible(flexibleModel, rigidModel, shaftShape, density, radius, savedState)
% Simulates a rigid version of a shaft based on extracted inertia from a flexible shaft shape
% Inputs:
%   flexibleModel - string, name of flexible model (not used unless debugging)
%   rigidModel    - string, name of the rigid-body model
%   shaftShape    - [N x 3] node positions from flexible shaft at kill switch time
%   density       - material density (e.g., 7800)
%   radius        - shaft radius (e.g., 0.005)
%   savedState    - Simulink saved state struct to use as initial condition
% Output:
%   out           - simulation output structure

    % Step 1: Extract shaft inertia
    inertiaProps = extractShaftInertiaFromShape(shaftShape, density, radius);

    % Step 2: Define shaftParams struct for workspace use
    shaftParams.Mass = inertiaProps.Mass;
    shaftParams.COM = inertiaProps.COM;
    shaftParams.Inertia = [diag(inertiaProps.Inertia)', ...
                          -[inertiaProps.Inertia(1,2), inertiaProps.Inertia(1,3), inertiaProps.Inertia(2,3)]];
    assignin('base', 'shaftParams', shaftParams);

    % Step 3: Configure simulation input
    in = Simulink.SimulationInput(rigidModel);
    in = in.setInitialState(savedState);
    in = in.setModelParameter('LoadInitialState', 'on');

    % Step 4: Simulate rigid model
    out = sim(in);

    fprintf('Rigid model "%s" simulated with inertia from flexible shaft.\n', rigidModel);
end
