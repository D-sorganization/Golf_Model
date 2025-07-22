function plotEllipsoid(center, M, color)
%PLOTELLIPSOID Plots a 3D ellipsoid given a 3x3 matrix M and center

% Eigen-decompose the matrix
[V, D] = eig(M);
[x, y, z] = sphere(20);

% Scale and rotate
xyz = [x(:) y(:) z(:)]';
ellipsoid_pts = V * sqrt(D) * xyz;
x_ell = reshape(ellipsoid_pts(1,:) + center(1), size(x));
y_ell = reshape(ellipsoid_pts(2,:) + center(2), size(y));
z_ell = reshape(ellipsoid_pts(3,:) + center(3), size(z));

% Plot
surf(x_ell, y_ell, z_ell, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', color);
end
