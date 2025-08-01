function quick_test()
    % Quick test to verify coefficient setting works without running simulation
    
    fprintf('=== Quick Test: Coefficient Setting ===\n');
    
    % Test coefficient setting with reduced coefficients
    test_coefficients = rand(1, 70) * 10 - 5;  % 70 coefficients (10 joints × 7)
    
    fprintf('Testing with %d coefficients...\n', length(test_coefficients));
    
    try
        % Test parameter info loading
        fprintf('Testing getPolynomialParameterInfo...\n');
        max_joints = ceil(length(test_coefficients) / 7);
        param_info = getPolynomialParameterInfo(max_joints);
        fprintf('✓ Loaded %d joints with %d total parameters\n', ...
            length(param_info.joint_names), param_info.total_params);
        
        % Test coefficient setting (without simulation)
        fprintf('Testing coefficient setting...\n');
        simIn = Simulink.SimulationInput('GolfSwing3D_Kinetic');
        simIn = setPolynomialCoefficients(simIn, test_coefficients, struct());
        fprintf('✓ Coefficient setting completed successfully\n');
        
        fprintf('\n=== Quick Test PASSED ===\n');
        
    catch ME
        fprintf('\n=== Quick Test FAILED ===\n');
        fprintf('Error: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end 