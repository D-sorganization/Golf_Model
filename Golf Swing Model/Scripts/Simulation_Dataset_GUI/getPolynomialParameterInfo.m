function param_info = getPolynomialParameterInfo()
    % Get polynomial parameter information for coefficient setting
    param_info = struct();
    param_info.joint_names = {'Hip', 'Knee', 'Ankle', 'Shoulder', 'Elbow', 'Wrist'};
    param_info.joint_coeffs = {
        {'a0', 'a1', 'a2', 'a3', 'a4', 'a5'},  % Hip
        {'b0', 'b1', 'b2', 'b3', 'b4', 'b5'},  % Knee
        {'c0', 'c1', 'c2', 'c3', 'c4', 'c5'},  % Ankle
        {'d0', 'd1', 'd2', 'd3', 'd4', 'd5'},  % Shoulder
        {'e0', 'e1', 'e2', 'e3', 'e4', 'e5'},  % Elbow
        {'f0', 'f1', 'f2', 'f3', 'f4', 'f5'}   % Wrist
    };
end 