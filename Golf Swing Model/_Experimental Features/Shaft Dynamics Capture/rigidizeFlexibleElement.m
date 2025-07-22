function rigidBody = rigidizeFlexibleElement(flexData, massPerSegment, segmentCenters)
% Rigidizes a flexible shaft using its frozen shape at a given time.
% 
% Inputs:
%   flexData         - Nx3 matrix of marker positions or nodes (frozen shape)
%   massPerSegment   - 1xN-1 vector of mass of each segment
%   segmentCenters   - optional, if provided, overrides midpoint calculation
%
% Output:
%   rigidBody - Struct with fields:
%       .COM    - center of mass of the shape
%       .Ibody  - inertia tensor about COM
%       .mass   - total mass
%       .nodes  - saved node positions

    if nargin < 3 || isempty(segmentCenters)
        % Midpoint between nodes
        segmentCenters = 0.5 * (flexData(1:end-1,:) + flexData(2:end,:));
    end

    numSegments = size(segmentCenters, 1);
    totalMass = sum(massPerSegment);

    % Compute COM
    weightedCenters = segmentCenters .* massPerSegment';
    COM = sum(weightedCenters, 1) / totalMass;

    % Translate segment centers to COM frame
    rel = segmentCenters - COM;  % Nx3

    % Compute Inertia Tensor (Assume point masses for each segment)
    Ixx = sum(massPerSegment .* (rel(:,2).^2 + rel(:,3).^2));
    Iyy = sum(massPerSegment .* (rel(:,1).^2 + rel(:,3).^2));
    Izz = sum(massPerSegment .* (rel(:,1).^2 + rel(:,2).^2));
    Ixy = -sum(massPerSegment .* rel(:,1) .* rel(:,2));
    Ixz = -sum(massPerSegment .* rel(:,1) .* rel(:,3));
    Iyz = -sum(massPerSegment .* rel(:,2) .* rel(:,3));
    Ibody = [ Ixx, Ixy, Ixz;
              Ixy, Iyy, Iyz;
              Ixz, Iyz, Izz ];

    % Package output
    rigidBody = struct();
    rigidBody.COM = COM;
    rigidBody.Ibody = Ibody;
    rigidBody.mass = totalMass;
    rigidBody.nodes = flexData;

    % Optional: write to MAT file for use in Simulink
    % save('RigidShaft.mat', '-struct', 'rigidBody');
end
