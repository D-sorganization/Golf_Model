function inertiaStruct = extractShaftInertiaFromShape(shaftXYZ, density, radius)
% Computes mass properties (inertia, COM, mass) of a shaft shape defined by points
% Inputs:
%   shaftXYZ : [N x 3] matrix of shaft node positions in meters
%   density  : material density in kg/m^3 (e.g., 7800 for steel)
%   radius   : constant shaft radius in meters (e.g., 0.005)
% Output:
%   inertiaStruct with fields:
%     - Inertia (3x3 matrix about COM)
%     - Mass
%     - COM (1x3)

    N = size(shaftXYZ, 1) - 1;
    if N < 1
        error('shaftXYZ must contain at least 2 points.');
    end

    massTotal = 0;
    comTotal = zeros(1,3);
    I_total = zeros(3);

    for i = 1:N
        p1 = shaftXYZ(i, :);
        p2 = shaftXYZ(i+1, :);
        segVec = p2 - p1;
        len = norm(segVec);
        if len == 0, continue; end

        % Segment mass and center
        segMass = pi * radius^2 * len * density;
        segCOM = (p1 + p2) / 2;

        % Parallel axis moment of inertia of cylinder segment
        % Assuming uniform density along the axis from p1 to p2
        % First compute local inertia tensor about segment center
        I_seg_local = (segMass * radius^2 / 4) * eye(3);
        axisUnit = segVec / len;
        I_seg_local = I_seg_local + (segMass * len^2 / 12) * (eye(3) - axisUnit' * axisUnit);

        % Shift to global COM using parallel axis theorem later
        massTotal = massTotal + segMass;
        comTotal = comTotal + segMass * segCOM;
        segmentCOMs(i,:) = segCOM;
        segmentInertias(:,:,i) = I_seg_local;
        segmentMasses(i) = segMass;
    end

    shaftCOM = comTotal / massTotal;

    % Shift all segment inertias to shaft COM using parallel axis theorem
    for i = 1:N
        r = segmentCOMs(i,:) - shaftCOM;
        r_cross = [0 -r(3) r(2); r(3) 0 -r(1); -r(2) r(1) 0];
        I_parallel = segmentInertias(:,:,i) + segmentMasses(i) * (r_cross' * r_cross);
        I_total = I_total + I_parallel;
    end

    inertiaStruct = struct();
    inertiaStruct.Mass = massTotal;
    inertiaStruct.COM = shaftCOM;
    inertiaStruct.Inertia = I_total;

    fprintf('Extracted shaft inertia: Mass = %.4f kg\n', massTotal);
    disp('COM (m):'); disp(shaftCOM);
    disp('Inertia matrix (kg*m^2):'); disp(I_total);
end
