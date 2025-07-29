% extractSegmentDimensions.m
% Extracts segment dimensions (lengths, masses, inertias) from the golf swing model
% and includes them in the dataset for neural network training

function segment_data = extractSegmentDimensions(model_name)
    % Extract segment dimensions from Simulink model
    % 
    % Inputs:
    %   model_name - Name of the Simulink model (e.g., 'GolfSwing3D_Kinetic')
    %
    % Outputs:
    %   segment_data - Structure containing segment dimensions
    
    fprintf('Extracting segment dimensions from %s...\n', model_name);
    
    % Load the model if not already loaded
    if ~bdIsLoaded(model_name)
        load_system(model_name);
    end
    
    % Initialize segment data structure
    segment_data = struct();
    
    % Define segment hierarchy and properties to extract
    segments = {
        % Base segments
        {'Base', 'base', 'Base segment'};
        
        % Hip and spine segments
        {'Hip', 'hip', 'Hip segment'};
        {'Spine1', 'spine_1', 'Lower spine segment'};
        {'Spine2', 'spine_2', 'Upper spine segment'};
        {'Torso', 'torso', 'Torso segment'};
        
        % Left arm chain
        {'LScap1', 'scapula_L_1', 'Left scapula segment 1'};
        {'LScap2', 'scapula_L_2', 'Left scapula segment 2'};
        {'LShoulder', 'shoulder_L', 'Left shoulder segment'};
        {'LUpperArm', 'upperArm_L', 'Left upper arm segment'};
        {'LLowerArm', 'lowerArm_L', 'Left lower arm segment'};
        {'LHand', 'hand_L', 'Left hand segment'};
        
        % Right arm chain
        {'RScap1', 'scapula_R_1', 'Right scapula segment 1'};
        {'RScap2', 'scapula_R_2', 'Right scapula segment 2'};
        {'RShoulder', 'shoulder_R', 'Right shoulder segment'};
        {'RUpperArm', 'upperArm_R', 'Right upper arm segment'};
        {'RLowerArm', 'lowerArm_R', 'Right lower arm segment'};
        {'RHand', 'hand_R', 'Right hand segment'};
        
        % Club segments
        {'ClubShaft', 'clubShaft', 'Club shaft segment'};
        {'ClubHead', 'clubHead', 'Club head segment'};
    };
    
    % Extract properties for each segment
    for i = 1:length(segments)
        segment_name = segments{i}{1};
        segment_id = segments{i}{2};
        segment_desc = segments{i}{3};
        
        fprintf('  Extracting %s (%s)...\n', segment_desc, segment_id);
        
        % Try to extract from model workspace
        try
            % Get segment properties from model workspace
            model_ws = get_param(model_name, 'ModelWorkspace');
            
            % Extract mass
            mass_var = sprintf('%s_mass', segment_id);
            mass = getVariableFromWorkspace(model_ws, mass_var, getDefaultMass(segment_id));
            
            % Extract length
            length_var = sprintf('%s_length', segment_id);
            length_val = getVariableFromWorkspace(model_ws, length_var, getDefaultLength(segment_id));
            
            % Extract center of mass
            com_var = sprintf('%s_com', segment_id);
            com = getVariableFromWorkspace(model_ws, com_var, getDefaultCOM(segment_id));
            
            % Extract inertia
            inertia_var = sprintf('%s_inertia', segment_id);
            inertia = getVariableFromWorkspace(model_ws, inertia_var, getDefaultInertia(segment_id, mass, length_val));
            
            % Store segment data
            segment_data.(segment_name) = struct();
            segment_data.(segment_name).id = segment_id;
            segment_data.(segment_name).description = segment_desc;
            segment_data.(segment_name).mass = mass;  % kg
            segment_data.(segment_name).length = length_val;  % m
            segment_data.(segment_name).com = com;  % m, relative to segment frame
            segment_data.(segment_name).inertia = inertia;  % kg*m², about COM
            
            % Calculate additional properties
            segment_data.(segment_name).volume = estimateVolume(segment_id, length_val);
            segment_data.(segment_name).density = mass / segment_data.(segment_name).volume;  % kg/m³
            
        catch ME
            warning('Could not extract %s: %s', segment_desc, ME.message);
            
            % Use default values
            segment_data.(segment_name) = struct();
            segment_data.(segment_name).id = segment_id;
            segment_data.(segment_name).description = segment_desc;
            segment_data.(segment_name).mass = getDefaultMass(segment_id);
            segment_data.(segment_name).length = getDefaultLength(segment_id);
            segment_data.(segment_name).com = getDefaultCOM(segment_id);
            segment_data.(segment_name).inertia = getDefaultInertia(segment_id, ...
                segment_data.(segment_name).mass, segment_data.(segment_name).length);
            segment_data.(segment_name).volume = estimateVolume(segment_id, segment_data.(segment_name).length);
            segment_data.(segment_name).density = segment_data.(segment_name).mass / segment_data.(segment_name).volume;
        end
    end
    
    % Add summary statistics
    segment_data.summary = calculateSummaryStats(segment_data);
    
    % Add metadata
    segment_data.extraction_time = datetime('now');
    segment_data.model_name = model_name;
    segment_data.units = struct();
    segment_data.units.mass = 'kg';
    segment_data.units.length = 'm';
    segment_data.units.com = 'm';
    segment_data.units.inertia = 'kg*m²';
    segment_data.units.volume = 'm³';
    segment_data.units.density = 'kg/m³';
    
    fprintf('Segment dimension extraction complete.\n');
    fprintf('Total segments: %d\n', length(segments));
    fprintf('Total mass: %.2f kg\n', segment_data.summary.total_mass);
    fprintf('Total length: %.2f m\n', segment_data.summary.total_length);
end

function value = getVariableFromWorkspace(model_ws, var_name, default_value)
    % Safely get a variable from model workspace, return default if not found
    try
        % Try to get the variable using eval
        value = eval(sprintf('model_ws.%s', var_name));
    catch
        % Variable doesn't exist, use default
        value = default_value;
    end
end

function mass = getDefaultMass(segment_id)
    % Return default mass values based on segment type
    mass_map = containers.Map();
    
    % Base and torso segments
    mass_map('base') = 0.5;  % kg
    mass_map('hip') = 15.0;  % kg
    mass_map('spine_1') = 5.0;  % kg
    mass_map('spine_2') = 5.0;  % kg
    mass_map('torso') = 35.0;  % kg
    
    % Arm segments
    mass_map('scapula_L_1') = 1.5;  % kg
    mass_map('scapula_L_2') = 1.5;  % kg
    mass_map('shoulder_L') = 2.0;  % kg
    mass_map('upperArm_L') = 2.5;  % kg
    mass_map('lowerArm_L') = 1.5;  % kg
    mass_map('hand_L') = 0.5;  % kg
    
    mass_map('scapula_R_1') = 1.5;  % kg
    mass_map('scapula_R_2') = 1.5;  % kg
    mass_map('shoulder_R') = 2.0;  % kg
    mass_map('upperArm_R') = 2.5;  % kg
    mass_map('lowerArm_R') = 1.5;  % kg
    mass_map('hand_R') = 0.5;  % kg
    
    % Club segments
    mass_map('clubShaft') = 0.1;  % kg
    mass_map('clubHead') = 0.2;  % kg
    
    if isKey(mass_map, segment_id)
        mass = mass_map(segment_id);
    else
        mass = 1.0;  % Default mass
    end
end

function length_val = getDefaultLength(segment_id)
    % Return default length values based on segment type
    length_map = containers.Map();
    
    % Base and torso segments
    length_map('base') = 0.1;  % m
    length_map('hip') = 0.2;  % m
    length_map('spine_1') = 0.2;  % m
    length_map('spine_2') = 0.2;  % m
    length_map('torso') = 0.55;  % m
    
    % Arm segments
    length_map('scapula_L_1') = 0.15;  % m
    length_map('scapula_L_2') = 0.15;  % m
    length_map('shoulder_L') = 0.1;  % m
    length_map('upperArm_L') = 0.3;  % m
    length_map('lowerArm_L') = 0.25;  % m
    length_map('hand_L') = 0.1;  % m
    
    length_map('scapula_R_1') = 0.15;  % m
    length_map('scapula_R_2') = 0.15;  % m
    length_map('shoulder_R') = 0.1;  % m
    length_map('upperArm_R') = 0.3;  % m
    length_map('lowerArm_R') = 0.25;  % m
    length_map('hand_R') = 0.1;  % m
    
    % Club segments
    length_map('clubShaft') = 1.0;  % m
    length_map('clubHead') = 0.05;  % m
    
    if isKey(length_map, segment_id)
        length_val = length_map(segment_id);
    else
        length_val = 0.2;  % Default length
    end
end

function com = getDefaultCOM(segment_id)
    % Return default center of mass positions
    % Assuming COM is at the geometric center for most segments
    com = [0, 0, 0];  % Default to origin
end

function inertia = getDefaultInertia(segment_id, mass, length_val)
    % Return default inertia values based on segment type and dimensions
    % Assuming cylindrical segments with radius = length/10
    
    radius = length_val / 10;  % Approximate radius
    
    % Moment of inertia for cylinder about its axis
    I_axial = 0.5 * mass * radius^2;
    
    % Moment of inertia for cylinder about perpendicular axis
    I_perp = (1/12) * mass * length_val^2 + 0.25 * mass * radius^2;
    
    % Create diagonal inertia tensor
    inertia = diag([I_perp, I_perp, I_axial]);
end

function volume = estimateVolume(segment_id, length_val)
    % Estimate volume based on segment type and length
    % Assuming cylindrical segments
    
    radius = length_val / 10;  % Approximate radius
    volume = pi * radius^2 * length_val;
end

function summary = calculateSummaryStats(segment_data)
    % Calculate summary statistics for all segments
    
    fields = fieldnames(segment_data);
    fields = fields(~strcmp(fields, 'summary') & ~strcmp(fields, 'extraction_time') & ...
                   ~strcmp(fields, 'model_name') & ~strcmp(fields, 'units'));
    
    total_mass = 0;
    total_length = 0;
    total_volume = 0;
    masses = [];
    lengths = [];
    
    for i = 1:length(fields)
        if isstruct(segment_data.(fields{i}))
            total_mass = total_mass + segment_data.(fields{i}).mass;
            total_length = total_length + segment_data.(fields{i}).length;
            total_volume = total_volume + segment_data.(fields{i}).volume;
            masses = [masses, segment_data.(fields{i}).mass];
            lengths = [lengths, segment_data.(fields{i}).length];
        end
    end
    
    summary = struct();
    summary.total_mass = total_mass;
    summary.total_length = total_length;
    summary.total_volume = total_volume;
    summary.average_mass = mean(masses);
    summary.average_length = mean(lengths);
    summary.mass_distribution = masses;
    summary.length_distribution = lengths;
    summary.num_segments = length(fields);
end 