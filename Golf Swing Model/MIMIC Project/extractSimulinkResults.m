% extractSimulinkResults.m
% Parses Simulink simulation output logs and assembles training data [X, Y]

function [X, Y] = extractSimulinkResults(simData, paramVec)
    X = [];
    Y = [];

    for i = 1:numel(simData)
        try
            q   = simData(i).logsout.get('q').Values.Data;
            qd  = simData(i).logsout.get('qd').Values.Data;
            qdd = simData(i).logsout.get('qdd').Values.Data;
            tau = simData(i).logsout.get('tau').Values.Data;

            nFrames = size(q, 1);
            params = repmat(paramVec(:)', nFrames, 1);
            X_i = [q, qd, tau, params];
            Y_i = qdd;

            X = [X; X_i];
            Y = [Y; Y_i];
        catch
            warning('Simulation %d missing required data.', i);
        end
    end
end
