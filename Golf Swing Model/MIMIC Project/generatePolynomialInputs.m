% generatePolynomialInputs.m
% Generates randomized 6th-degree polynomial coefficients for joint torque inputs

function coeffSet = generatePolynomialInputs(nSimulations, nJoints, degree, coeffRange)
    % nSimulations: number of sets to generate
    % nJoints: number of joints (e.g., 28)
    % degree: polynomial order (e.g., 6)
    % coeffRange: scalar or 2-element [min, max] for coefficient bounds

    if isscalar(coeffRange)
        coeffMin = -abs(coeffRange);
        coeffMax =  abs(coeffRange);
    else
        coeffMin = coeffRange(1);
        coeffMax = coeffRange(2);
    end

    coeffSet = cell(1, nSimulations);
    for i = 1:nSimulations
        coeffs = coeffMin + (coeffMax - coeffMin) * rand(nJoints, degree+1);
        coeffSet{i} = coeffs;
    end
end
