function simIn = setPolynomialCoefficients(simIn, coefficients, config)
    % Set polynomial coefficients for the golf swing model
    try
        fprintf('DEBUG: setPolynomialCoefficients called with:\n');
        fprintf('  coefficients class: %s\n', class(coefficients));
        fprintf('  coefficients size: %s\n', mat2str(size(coefficients)));
        
        if isempty(coefficients)
            fprintf('Warning: No coefficients provided\n');
            return;
        end
        
        fprintf('DEBUG: Starting setPolynomialCoefficients processing\n');
        
        % Get parameter information
        fprintf('DEBUG: About to call getPolynomialParameterInfo()\n');
        param_info = getPolynomialParameterInfo();
        fprintf('DEBUG: getPolynomialParameterInfo() returned successfully\n');
        
        % Set coefficients for each joint
        fprintf('DEBUG: Starting loop through %d joints\n', length(param_info.joint_names));
        coeff_index = 1;
        
        for joint_idx = 1:length(param_info.joint_names)
            joint_name = param_info.joint_names{joint_idx};
            joint_coeffs = param_info.joint_coeffs{joint_idx};
            
            fprintf('DEBUG: Processing joint %d: %s with %d coefficients\n', joint_idx, joint_name, length(joint_coeffs));
            
            for coeff_idx = 1:length(joint_coeffs)
                coeff_name = joint_coeffs{coeff_idx};
                fprintf('DEBUG: Processing coefficient %d: %s (class: %s)\n', coeff_idx, coeff_name, class(coeff_name));
                
                if coeff_index <= length(coefficients)
                    coeff_value = coefficients(coeff_index);
                    
                    % Create parameter name
                    param_name = sprintf('%s_%s', joint_name, coeff_name);
                    fprintf('DEBUG: Created param_name: %s\n', param_name);
                    
                    % Set the parameter
                    try
                        simIn = simIn.setVariable(param_name, coeff_value);
                        fprintf('DEBUG: Set variable %s = %.3f\n', param_name, coeff_value);
                    catch ME
                        fprintf('Warning: Could not set %s: %s\n', param_name, ME.message);
                    end
                    
                    coeff_index = coeff_index + 1;
                else
                    fprintf('Warning: Not enough coefficients for %s_%s\n', joint_name, coeff_name);
                end
            end
        end
        
    catch ME
        fprintf('Error setting polynomial coefficients: %s\n', ME.message);
        rethrow(ME);
    end
end 