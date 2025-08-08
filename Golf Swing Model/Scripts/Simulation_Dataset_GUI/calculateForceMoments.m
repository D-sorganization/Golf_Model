function output = calculateForceMoments(inputData, varargin)
% calculateForceMoments - Compute moment of force (r x F) and equivalent moments
% Supported inputs:
%   - table with columns matching pattern: <prefix>_ForceLocal_[1..3],
%     <prefix>_TorqueLocal_[1..3], <prefix>_Rotation_Transform_I11..I33,
%     <prefix>_GlobalPosition_[1..3]
%   - struct with fields .force_data/.torque_data/.position_data (each with x,y,z)
%
% Optional name-value arguments:
%   - 'ReferencePoint'      : [x y z] numeric (default [0 0 0])
%   - 'ReferencePointName'  : string prefix in table to use position columns
%   - 'Prefixes'            : cellstr of prefixes to restrict processing
%
% Output returns same type as input (table/struct) with added fields/columns:
%   For table, adds columns:
%     <prefix>_ForceGlobal_[1..3]
%     <prefix>_TorqueGlobal_[1..3]
%     <prefix>_MOF_Global_[1..3]
%     <prefix>_EqMoment_Global_[1..3]
%     <prefix>_MOF_Magnitude, <prefix>_EqMoment_Magnitude
%   For struct, adds fields under .moments.(prefix)
%
% Notes on frames:
%   - Local vectors are rotated to global using rotation transform matrix R
%     assembled from I11..I33 columns (assumed local->global).

p = inputParser;
p.addParameter('ReferencePoint', [0 0 0], @(v) isnumeric(v) && numel(v) == 3);
p.addParameter('ReferencePointName', '', @(v) ischar(v) || isstring(v));
p.addParameter('Prefixes', {}, @(v) iscellstr(v) || isstring(v));
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

% Build prefix list
forceMask = contains(varNames, '_ForceLocal_1');
prefixes = regexprep(varNames(forceMask), '_ForceLocal_1$', '');
prefixes = unique(prefixes);

% Restrict if provided
if ~isempty(opts.Prefixes)
    prefixes = intersect(prefixes, string(opts.Prefixes));
end

% Compute reference point series if a name is provided
if ~isempty(opts.ReferencePointName)
    refPrefix = string(opts.ReferencePointName);
    refX = refPrefix + "_GlobalPosition_1";
    refY = refPrefix + "_GlobalPosition_2";
    refZ = refPrefix + "_GlobalPosition_3";
    if all(ismember([refX, refY, refZ], varNames))
        rpx = T.(refX);
        rpy = T.(refY);
        rpz = T.(refZ);
    else
        error('ReferencePointName "%s" does not have GlobalPosition_[1..3] columns', refPrefix);
    end
else
    % Constant reference point
    rpx = repmat(opts.ReferencePoint(1), height(T), 1);
    rpy = repmat(opts.ReferencePoint(2), height(T), 1);
    rpz = repmat(opts.ReferencePoint(3), height(T), 1);
end

for i = 1:numel(prefixes)
    pref = prefixes(i);
    % Required columns
    fxName = pref + "_ForceLocal_1"; fyName = pref + "_ForceLocal_2"; fzName = pref + "_ForceLocal_3";
    txName = pref + "_TorqueLocal_1"; tyName = pref + "_TorqueLocal_2"; tzName = pref + "_TorqueLocal_3";
    pxName = pref + "_GlobalPosition_1"; pyName = pref + "_GlobalPosition_2"; pzName = pref + "_GlobalPosition_3";
    I = strings(3,3);
    I(1,1) = pref + "_Rotation_Transform_I11"; I(1,2) = pref + "_Rotation_Transform_I12"; I(1,3) = pref + "_Rotation_Transform_I13";
    I(2,1) = pref + "_Rotation_Transform_I21"; I(2,2) = pref + "_Rotation_Transform_I22"; I(2,3) = pref + "_Rotation_Transform_I23";
    I(3,1) = pref + "_Rotation_Transform_I31"; I(3,2) = pref + "_Rotation_Transform_I32"; I(3,3) = pref + "_Rotation_Transform_I33";

    required = [fxName, fyName, fzName, txName, tyName, tzName, pxName, pyName, pzName, I(:)'];
    if ~all(ismember(required, varNames))
        % Skip if incomplete
        continue;
    end

    % Gather arrays
    Fx = T.(fxName); Fy = T.(fyName); Fz = T.(fzName);
    Tx = T.(txName); Ty = T.(tyName); Tz = T.(tzName);
    Px = T.(pxName); Py = T.(pyName); Pz = T.(pzName);

    R11 = T.(I(1,1)); R12 = T.(I(1,2)); R13 = T.(I(1,3));
    R21 = T.(I(2,1)); R22 = T.(I(2,2)); R23 = T.(I(2,3));
    R31 = T.(I(3,1)); R32 = T.(I(3,2)); R33 = T.(I(3,3));

    % Rotate local force/torque to global: Fg = R * Fl
    Fg1 = R11.*Fx + R12.*Fy + R13.*Fz;
    Fg2 = R21.*Fx + R22.*Fy + R23.*Fz;
    Fg3 = R31.*Fx + R32.*Fy + R33.*Fz;

    Tg1 = R11.*Tx + R12.*Ty + R13.*Tz;
    Tg2 = R21.*Tx + R22.*Ty + R23.*Tz;
    Tg3 = R31.*Tx + R32.*Ty + R33.*Tz;

    % Position vector relative to reference point
    rx = Px - rpx; ry = Py - rpy; rz = Pz - rpz;

    % Moment of force: r x F
    Mx = ry.*Fg3 - rz.*Fg2;
    My = rz.*Fg1 - rx.*Fg3;
    Mz = rx.*Fg2 - ry.*Fg1;

    % Equivalent moment at reference: global torque + r x F
    Eqx = Tg1 + Mx;
    Eqy = Tg2 + My;
    Eqz = Tg3 + Mz;

    % Append columns
    T.(pref + "_ForceGlobal_1") = Fg1;
    T.(pref + "_ForceGlobal_2") = Fg2;
    T.(pref + "_ForceGlobal_3") = Fg3;

    T.(pref + "_TorqueGlobal_1") = Tg1;
    T.(pref + "_TorqueGlobal_2") = Tg2;
    T.(pref + "_TorqueGlobal_3") = Tg3;

    T.(pref + "_MOF_Global_1") = Mx;
    T.(pref + "_MOF_Global_2") = My;
    T.(pref + "_MOF_Global_3") = Mz;
    T.(pref + "_MOF_Magnitude") = sqrt(Mx.^2 + My.^2 + Mz.^2);

    T.(pref + "_EqMoment_Global_1") = Eqx;
    T.(pref + "_EqMoment_Global_2") = Eqy;
    T.(pref + "_EqMoment_Global_3") = Eqz;
    T.(pref + "_EqMoment_Magnitude") = sqrt(Eqx.^2 + Eqy.^2 + Eqz.^2);
end
end

function S = local_process_struct(S, opts)
% Attempt to compute moments for each entry in force_data using position_data and torque_data
if ~isfield(S, 'force_data') || ~isfield(S, 'position_data')
    return;
end
forceNames = fieldnames(S.force_data);
S.moments = struct();

for i = 1:numel(forceNames)
    name = forceNames{i};
    f = S.force_data.(name);
    if ~isfield(S.position_data, name)
        continue;
    end
    p = S.position_data.(name);

    % Reference point
    if ~isempty(opts.ReferencePointName) && isfield(S.position_data, opts.ReferencePointName)
        rp = S.position_data.(opts.ReferencePointName);
        r = [p.x - rp.x, p.y - rp.y, p.z - rp.z];
    else
        r = [p.x - opts.ReferencePoint(1), p.y - opts.ReferencePoint(2), p.z - opts.ReferencePoint(3)];
    end

    % Force assumed global
    F = [f.x, f.y, f.z];

    % Moment of force r x F per-sample
    M = cross(r, F, 2);

    % Equivalent moment (include torque if available)
    Eq = M;
    if isfield(S, 'torque_data') && isfield(S.torque_data, name)
        tq = S.torque_data.(name);
        Tglob = [tq.x, tq.y, tq.z];
        Eq = Eq + Tglob;
    end

    S.moments.(name) = struct('mof', M, 'equivalent_moment', Eq);
end
end