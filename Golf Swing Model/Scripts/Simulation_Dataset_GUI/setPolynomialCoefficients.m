function simIn = setPolynomialCoefficients(simIn, coefficients, config)
    % Set polynomial coefficients for the golf swing model
    try
        if isempty(coefficients)
            fprintf('Warning: No coefficients provided\n');
            return;
        end
        
        % Get parameter information
        max_joints = ceil(length(coefficients) / 7);  % 7 coefficients per joint
        param_info = getPolynomialParameterInfo(max_joints);
        
        % Validate coefficient count
        expected_coeffs = length(param_info.joint_names) * 7;
        if length(coefficients) ~= expected_coeffs
            if length(coefficients) > expected_coeffs
                coefficients = coefficients(1:expected_coeffs);
            else
                % Pad with zeros if not enough coefficients
                coefficients = [coefficients, zeros(1, expected_coeffs - length(coefficients))];
            end
        end
        
        % Vectorized coefficient setting for better performance
        coeff_index = 1;
        for joint_idx = 1:length(param_info.joint_names)
            joint_name = param_info.joint_names{joint_idx};
            joint_coeffs = param_info.joint_coeffs{joint_idx};
            
            for coeff_idx = 1:length(joint_coeffs)
                if coeff_index <= length(coefficients)
                    coeff_value = coefficients(coeff_index);
                    param_name = sprintf('%s_%s', joint_name, joint_coeffs{coeff_idx});
                    
                    try
                        simIn = simIn.setVariable(param_name, coeff_value);
                    catch ME
                        fprintf('Warning: Could not set %s: %s\n', param_name, ME.message);
                    end
                    
                    coeff_index = coeff_index + 1;
                end
            end
        end
        
    catch ME
        fprintf('Error setting polynomial coefficients: %s\n', ME.message);
        rethrow(ME);
    end
end 