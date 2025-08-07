function ZTCF = generate_ztcf_data(config, ~, BaseData)
% GENERATE_ZTCF_DATA - Generate ZTCF (Zero Torque Counterfactual) data
%
% Inputs:
%   config - Configuration structure from model_config()
%   mdlWks - (unused) Model workspace handle kept for API compatibility
%   BaseData - Base data table from generate_base_data()
%
% Returns:
%   ZTCF - Table containing the ZTCF data
%
% This function:
%   1. Runs simulations in parallel using parsim
%   2. Accumulates results in a struct array
%   3. Converts the results to a table once at the end

    % Determine time points for ZTCF simulations
    timePoints = config.ztcf_start_time:config.ztcf_end_time;
    numPoints = numel(timePoints);

    % Preallocate results structure based on BaseData
    templateStruct = table2struct(BaseData(1,:));
    ztcfResults(numPoints,1) = templateStruct;

    % Prepare simulation inputs for parsim
    simIn(numPoints,1) = Simulink.SimulationInput(config.model_name);
    for idx = 1:numPoints
        j = timePoints(idx) / config.ztcf_time_scale;
        simIn(idx) = simIn(idx).setVariable('KillswitchStepTime', Simulink.Parameter(j));
        simIn(idx) = simIn(idx).setPostSimFcn(@(in,out)postSimProcess(out, config.scripts_path));
    end

    fprintf('🔄 Generating ZTCF data with %d simulations...\n', numPoints);

    % Run all simulations in parallel
    simOut = parsim(simIn, 'ShowProgress', 'on');

    % Process simulation results
    for idx = 1:numPoints
        ZTCFData = simOut(idx).Data;

        % Find the row where KillswitchState first becomes zero
        row = find(ZTCFData.KillswitchState == 0, 1);

        if isempty(row)
            warning('No killswitch state change found at time %.3f', ...
                timePoints(idx) / config.ztcf_time_scale);
            continue;
        end

        ztcfResults(idx) = table2struct(ZTCFData(row,:));
    end

    % Convert accumulated results to table
    ZTCF = struct2table(ztcfResults);

    fprintf('✅ ZTCF data generated successfully\n');
    fprintf('   ZTCF data points: %d\n', height(ZTCF));

end

function simOut = postSimProcess(simOut, scriptsPath)
%POSTSIMPROCESS Generate Data table after each simulation
    prevDir = pwd;
    cd(scriptsPath);
    out = simOut; %#ok<NASGU>
    SCRIPT_TableGeneration;
    simOut.Data = Data; %#ok<NODEF>
    cd(prevDir);
end
