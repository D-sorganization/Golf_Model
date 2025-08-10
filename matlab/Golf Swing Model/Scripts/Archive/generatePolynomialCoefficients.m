function coeffs = generatePolynomialCoefficients(config)
    % Standalone function for generating polynomial coefficients
    % This function can be called from parfor loops

    % Define all joint coefficient names based on the actual model
    % Updated based on debug output showing actual variable names
    joint_coeffs = {
        % Base torques (from debug output)
        {'BaseTorqueInputXA', 'BaseTorqueInputXB', 'BaseTorqueInputXC', 'BaseTorqueInputXD', 'BaseTorqueInputXE', 'BaseTorqueInputXF', 'BaseTorqueInputXG'};
        {'BaseTorqueInputYA', 'BaseTorqueInputYB', 'BaseTorqueInputYC', 'BaseTorqueInputYD', 'BaseTorqueInputYE', 'BaseTorqueInputYF', 'BaseTorqueInputYG'};
        {'BaseTorqueInputZA', 'BaseTorqueInputZB', 'BaseTorqueInputZC', 'BaseTorqueInputZD', 'BaseTorqueInputZE', 'BaseTorqueInputZF', 'BaseTorqueInputZG'};
        % Hip torques
        {'HipInputXA', 'HipInputXB', 'HipInputXC', 'HipInputXD', 'HipInputXE', 'HipInputXF', 'HipInputXG'};
        {'HipInputYA', 'HipInputYB', 'HipInputYC', 'HipInputYD', 'HipInputYE', 'HipInputYF', 'HipInputYG'};
        {'HipInputZA', 'HipInputZB', 'HipInputZC', 'HipInputZD', 'HipInputZE', 'HipInputZF', 'HipInputZG'};
        % Spine torques
        {'SpineInputXA', 'SpineInputXB', 'SpineInputXC', 'SpineInputXD', 'SpineInputXE', 'SpineInputXF', 'SpineInputXG'};
        {'SpineInputYA', 'SpineInputYB', 'SpineInputYC', 'SpineInputYD', 'SpineInputYE', 'SpineInputYF', 'SpineInputYG'};
        % Left shoulder
        {'LScapInputXA', 'LScapInputXB', 'LScapInputXC', 'LScapInputXD', 'LScapInputXE', 'LScapInputXF', 'LScapInputXG'};
        {'LScapInputYA', 'LScapInputYB', 'LScapInputYC', 'LScapInputYD', 'LScapInputYE', 'LScapInputYF', 'LScapInputYG'};
        % Left arm
        {'LSInputXA', 'LSInputXB', 'LSInputXC', 'LSInputXD', 'LSInputXE', 'LSInputXF', 'LSInputXG'};
        {'LSInputYA', 'LSInputYB', 'LSInputYC', 'LSInputYD', 'LSInputYE', 'LSInputYF', 'LSInputYG'};
        {'LSInputZA', 'LSInputZB', 'LSInputZC', 'LSInputZD', 'LSInputZE', 'LSInputZF', 'LSInputZG'};
        % Right shoulder
        {'RScapInputXA', 'RScapInputXB', 'RScapInputXC', 'RScapInputXD', 'RScapInputXE', 'RScapInputXF', 'RScapInputXG'};
        {'RScapInputYA', 'RScapInputYB', 'RScapInputYC', 'RScapInputYD', 'RScapInputYE', 'RScapInputYF', 'RScapInputYG'};
        % Right arm
        {'RSInputXA', 'RSInputXB', 'RSInputXC', 'RSInputXD', 'RSInputXE', 'RSInputXF', 'RSInputXG'};
        {'RSInputYA', 'RSInputYB', 'RSInputYC', 'RSInputYD', 'RSInputYE', 'RSInputYF', 'RSInputYG'};
        {'RSInputZA', 'RSInputZB', 'RSInputZC', 'RSInputZD', 'RSInputZE', 'RSInputZF', 'RSInputZG'};
        % Left elbow
        {'LEInputA', 'LEInputB', 'LEInputC', 'LEInputD', 'LEInputE', 'LEInputF', 'LEInputG'};
        % Right elbow
        {'REInputA', 'REInputB', 'REInputC', 'REInputD', 'REInputE', 'REInputF', 'REInputG'};
        % Left wrist
        {'LWInputXA', 'LWInputXB', 'LWInputXC', 'LWInputXD', 'LWInputXE', 'LWInputXF', 'LWInputXG'};
        {'LWInputYA', 'LWInputYB', 'LWInputYC', 'LWInputYD', 'LWInputYE', 'LWInputYF', 'LWInputYG'};
        % Right wrist
        {'RWInputXA', 'RWInputXB', 'RWInputXC', 'RWInputXD', 'RWInputXE', 'RWInputXF', 'RWInputXG'};
        {'RWInputYA', 'RWInputYB', 'RWInputYC', 'RWInputYD', 'RWInputYE', 'RWInputYF', 'RWInputYG'};
        % Left leg
        {'LEInputA', 'LEInputB', 'LEInputC', 'LEInputD', 'LEInputE', 'LEInputF', 'LEInputG'};
        % Right leg
        {'REInputA', 'REInputB', 'REInputC', 'REInputD', 'REInputE', 'REInputF', 'REInputG'};
        % Left foot
        {'LFInputA', 'LFInputB', 'LFInputC', 'LFInputD', 'LFInputE', 'LFInputF', 'LFInputG'};
        % Right foot
        {'RFInputA', 'RFInputB', 'RFInputC', 'RFInputD', 'RFInputE', 'RFInputF', 'RFInputG'};
    };

    coeffs = struct();

    for i = 1:length(joint_coeffs)
        joint_set = joint_coeffs{i};
        for j = 1:length(joint_set)
            coeff_name = joint_set{j};

            switch config.torque_scenario
                case 1 % Variable torques (A-G varied)
                    coeffs.(coeff_name) = (rand(1) - 0.5) * 2 * config.coeff_range;
                case 2 % Zero torque (all = 0)
                    coeffs.(coeff_name) = 0;
                case 3 % Constant torque (A-F=0, G=const)
                    if j == 7 % G coefficient
                        coeffs.(coeff_name) = config.constant_value;
                    else % A-F coefficients
                        coeffs.(coeff_name) = 0;
                    end
            end
        end
    end
end