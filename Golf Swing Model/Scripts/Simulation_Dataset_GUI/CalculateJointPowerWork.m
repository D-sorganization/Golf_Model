function output = CalculateJointPowerWork(inputData, varargin)
% CalculateJointPowerWork - Compute joint power (tau·omega) and work
% Supported inputs:
%   - table with columns for torque and angular velocity per joint prefix
%     e.g., <joint>_TorqueLocal_[1..3] and <joint>_AngularVelocity_[1..3]
%     or angle to differentiate velocity
%   - struct with fields .joint_data.(joint).angular_velocity and
%     .torque_data.(joint).torque or components x,y,z
%
% Optional name-value arguments:
%   - 'Time'           : time vector (Nx1), overrides detection
%   - 'AngleSuffix'    : suffix name for angle columns (default 'AngularPosition')
%   - 'VelSuffix'      : suffix name for angular velocity columns (default 'AngularVelocity')
%   - 'TorqueSuffix'   : suffix name for torque columns (default 'TorqueLocal')
%   - 'JointPrefixes'  : limit to these joint prefixes (cellstr)
%
% Output appends fields/columns:
%   Table:
%     <joint>_Power, <joint>_Work, <joint>_PeakPower
%   Struct joint_data.(joint).power, .work, .peak_power

p = inputParser;
p.addParameter('Time', [], @(v) isnumeric(v) && (isvector(v) || isempty(v)));
p.addParameter('AngleSuffix', 'AngularPosition', @(s) ischar(s) || isstring(s));
p.addParameter('VelSuffix', 'AngularVelocity', @(s) ischar(s) || isstring(s));
p.addParameter('TorqueSuffix', 'TorqueLocal', @(s) ischar(s) || isstring(s));
p.addParameter('JointPrefixes', {}, @(v) iscellstr(v) || isstring(v));
p.parse(varargin{:});
opts = p.Results;

if istable(inputData)
    output = local_process_table(inputData, opts);
elseif isstruct(inputData)
    output = local_process_struct(inputData, opts);
else
    error('Unsupported input type: %s', class(inputData));
end
end

function T = local_process_table(T, opts)
varNames = string(T.Properties.VariableNames);

% Detect time
if ismember("time", varNames)
    time = T.time;
elseif ~isempty(opts.Time)
    time = opts.Time(:);
else
    time = [];
end

% Find joint prefixes that have torque
torqMask = contains(varNames, "_" + string(opts.TorqueSuffix) + "_1");
jointPrefixes = regexprep(varNames(torqMask), "_" + string(opts.TorqueSuffix) + "_1$", '');
jointPrefixes = unique(jointPrefixes);
if ~isempty(opts.JointPrefixes)
    jointPrefixes = intersect(jointPrefixes, string(opts.JointPrefixes));
end

for i = 1:numel(jointPrefixes)
    pref = jointPrefixes(i);
    % Torque local xyz
    txn = pref + "_" + string(opts.TorqueSuffix) + "_1";
    tyn = pref + "_" + string(opts.TorqueSuffix) + "_2";
    tzn = pref + "_" + string(opts.TorqueSuffix) + "_3";

    % Angular velocity: prefer explicit velocity columns; else derive from angle
    vxn = pref + "_" + string(opts.VelSuffix) + "X";
    vyn = pref + "_" + string(opts.VelSuffix) + "Y";
    vzn = pref + "_" + string(opts.VelSuffix) + "Z";

    if all(ismember([vxn vyn vzn], varNames))
        wx = T.(vxn); wy = T.(vyn); wz = T.(vzn);
    else
        % Derive from angles if available
        axn = pref + "_" + string(opts.AngleSuffix) + "X";
        ayn = pref + "_" + string(opts.AngleSuffix) + "Y";
        azn = pref + "_" + string(opts.AngleSuffix) + "Z";
        if all(ismember([axn ayn azn], varNames)) && ~isempty(time)
            wx = gradient(T.(axn), time);
            wy = gradient(T.(ayn), time);
            wz = gradient(T.(azn), time);
        else
            % Cannot compute without velocity; skip
            continue;
        end
    end

    % Align frames: use rotation transform to map global omega to local before dot with local torque
    % Rotation matrix columns (local->global)
    I11 = pref + "_Rotation_Transform_I11"; I12 = pref + "_Rotation_Transform_I12"; I13 = pref + "_Rotation_Transform_I13";
    I21 = pref + "_Rotation_Transform_I21"; I22 = pref + "_Rotation_Transform_I22"; I23 = pref + "_Rotation_Transform_I23";
    I31 = pref + "_Rotation_Transform_I31"; I32 = pref + "_Rotation_Transform_I32"; I33 = pref + "_Rotation_Transform_I33";
    hasR = all(ismember([I11 I12 I13 I21 I22 I23 I31 I32 I33], varNames));

    % Torque local components
    tx = T.(txn); ty = T.(tyn); tz = T.(tzn);

    if hasR
        R11 = T.(I11); R12 = T.(I12); R13 = T.(I13);
        R21 = T.(I21); R22 = T.(I22); R23 = T.(I23);
        R31 = T.(I31); R32 = T.(I32); R33 = T.(I33);
        % omega_local = R' * omega_global
        wlx = R11.*wx + R21.*wy + R31.*wz;
        wly = R12.*wx + R22.*wy + R32.*wz;
        wlz = R13.*wx + R23.*wy + R33.*wz;
        power = tx .* wlx + ty .* wly + tz .* wlz;
    else
        % Fallback: assume omega components are already in local frame
        power = tx .* wx + ty .* wy + tz .* wz;
    end

    % Work = integral(power dt)
    if ~isempty(time)
        work = trapz(time, power);
    else
        % Approximate equal spacing if time absent
        work = trapz(power);
    end

    % Peak power
    peak_power = max(abs(power));

    % Append results
    T.(pref + "_Power") = power;
    T.(pref + "_Work") = repmat(work, height(T), 1);
    T.(pref + "_PeakPower") = repmat(peak_power, height(T), 1);
end
end

function S = local_process_struct(S, opts)
if ~isfield(S, 'joint_data') || ~isfield(S, 'torque_data')
    return;
end

% Detect time
if isfield(S, 'time')
    time = S.time(:);
else
    time = [];
end

jointNames = fieldnames(S.joint_data);
for i = 1:numel(jointNames)
    jn = jointNames{i};
    if ~isempty(opts.JointPrefixes) && ~ismember(jn, string(opts.JointPrefixes))
        continue;
    end

    hasVelVec = isfield(S.joint_data.(jn), 'angular_velocity') && size(S.joint_data.(jn).angular_velocity,2) == 1;
    hasVelXYZ = isfield(S.joint_data.(jn), 'angular_velocity_x');

    % Build omega
    if hasVelXYZ
        wx = S.joint_data.(jn).angular_velocity_x;
        wy = S.joint_data.(jn).angular_velocity_y;
        wz = S.joint_data.(jn).angular_velocity_z;
    elseif hasVelVec
        % If scalar angular velocity is present, need torque magnitude; use dot as scalar product
        omega = S.joint_data.(jn).angular_velocity;
        % Fallback to scalar power if torque magnitude exists
        if isfield(S.torque_data, jn) && isfield(S.torque_data.(jn), 'torque')
            tau = S.torque_data.(jn).torque;
            power = tau .* omega;
            S.joint_data.(jn).power = power;
            if ~isempty(time)
                S.joint_data.(jn).work = trapz(time, power);
            end
            S.joint_data.(jn).peak_power = max(abs(power));
        end
        continue;
    else
        % Try to derive from angles
        hasAngleXYZ = isfield(S.joint_data.(jn), 'angle_x');
        if hasAngleXYZ && ~isempty(time)
            wx = gradient(S.joint_data.(jn).angle_x, time);
            wy = gradient(S.joint_data.(jn).angle_y, time);
            wz = gradient(S.joint_data.(jn).angle_z, time);
        else
            continue;
        end
    end

    % Build torque vector
    if isfield(S.torque_data, jn)
        t = S.torque_data.(jn);
        if all(isfield(t, {'x','y','z'}))
            tx = t.x; ty = t.y; tz = t.z;
        elseif isfield(t, 'torque')
            % If scalar torque provided, assume aligned with omega direction is not known; fallback to scalar product by magnitude
            tau_mag = t.torque;
            omega_mag = sqrt(wx.^2 + wy.^2 + wz.^2);
            power = tau_mag .* omega_mag;
            S.joint_data.(jn).power = power;
            if ~isempty(time)
                S.joint_data.(jn).work = trapz(time, power);
            end
            S.joint_data.(jn).peak_power = max(abs(power));
            continue;
        else
            continue;
        end
    else
        continue;
    end

    power = tx .* wx + ty .* wy + tz .* wz;
    S.joint_data.(jn).power = power;
    if ~isempty(time)
        S.joint_data.(jn).work = trapz(time, power);
    end
    S.joint_data.(jn).peak_power = max(abs(power));
end
end