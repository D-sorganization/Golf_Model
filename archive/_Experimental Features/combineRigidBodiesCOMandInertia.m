function [M_total, COM_total, I_total] = combineRigidBodies(bodies)
% combineRigidBodies Combines mass properties of multiple rigid bodies.
%   bodies: Array of structs with fields:
%       - mass: scalar mass
%       - com: 3x1 center of mass vector [x; y; z]
%       - inertia: 3x3 inertia tensor about the body's COM
%
%   Returns:
%       - M_total: Total mass
%       - COM_total: Combined center of mass (3x1 vector)
%       - I_total: Combined inertia tensor about the combined COM (3x3 matrix)

    % Number of bodies
    N = numel(bodies);

    % Initialize total mass and weighted COM
    M_total = 0;
    weighted_COM = zeros(3,1);

    % Compute total mass and weighted COM
    for i = 1:N
        M_i = bodies(i).mass;
        r_i = bodies(i).com;
        M_total = M_total + M_i;
        weighted_COM = weighted_COM + M_i * r_i;
    end
    COM_total = weighted_COM / M_total;

    % Initialize total inertia tensor
    I_total = zeros(3,3);

    % Compute combined inertia tensor using the parallel axis theorem
    for i = 1:N
        M_i = bodies(i).mass;
        r_i = bodies(i).com;
        I_i = bodies(i).inertia;

        d = r_i - COM_total; % Vector from combined COM to body's COM
        d_squared = dot(d, d);
        I_parallel = M_i * (d_squared * eye(3) - (d * d'));

        I_total = I_total + I_i + I_parallel;
    end
end
