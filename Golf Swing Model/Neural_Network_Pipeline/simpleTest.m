% simpleTest.m
% Simple test to debug dimension issues

clear; clc;

% Test dimensions
n_joints = 28;
n_samples = 101;

% Create test data
q = rand(n_samples, n_joints);
qd = rand(n_samples, n_joints);
qdd = rand(n_samples, n_joints);
tau = rand(n_samples, n_joints);

fprintf('Test data sizes:\n');
fprintf('q: %s\n', mat2str(size(q)));
fprintf('qd: %s\n', mat2str(size(qd)));
fprintf('qdd: %s\n', mat2str(size(qdd)));
fprintf('tau: %s\n', mat2str(size(tau)));

% Try concatenation
try
    X_test = [q, qd, tau];
    fprintf('Concatenation successful: X_test size = %s\n', mat2str(size(X_test)));
catch ME
    fprintf('Concatenation failed: %s\n', ME.message);
end

% Test with different sizes
q2 = rand(n_samples, 24);
qd2 = rand(n_samples, 28);
qdd2 = rand(n_samples, 28);
tau2 = rand(n_samples, 28);

fprintf('\nMismatched sizes:\n');
fprintf('q2: %s\n', mat2str(size(q2)));
fprintf('qd2: %s\n', mat2str(size(qd2)));

try
    X_test2 = [q2, qd2, tau2];
    fprintf('Concatenation successful: X_test2 size = %s\n', mat2str(size(X_test2)));
catch ME
    fprintf('Concatenation failed: %s\n', ME.message);
end 