function simInput = setPolynomialVariables(simInput, coeffs)
    % Standalone function for setting polynomial variables in simulation input
    % This function can be called from parfor loops
    
    fields = fieldnames(coeffs);
    for i = 1:length(fields)
        field_name = fields{i};
        coeff_values = coeffs.(field_name);
        simInput = simInput.setVariable(field_name, Simulink.Parameter(coeff_values));
    end
end 