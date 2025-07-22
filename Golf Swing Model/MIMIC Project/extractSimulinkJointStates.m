function [Q, QD, QDD] = extractSimulinkJointStates(folderPath)
    files = dir(fullfile(folderPath, '*.mat'));
    Q = []; QD = []; QDD = [];

    for i = 1:length(files)
        data = load(fullfile(folderPath, files(i).name));
        if isfield(data, 'out') && isprop(data.out, 'logsout')
            simStruct(1).logsout = data.out.logsout;
            [q, qd, qdd] = extractSimulinkJointStates(simStruct);
            Q = [Q; q];
            QD = [QD; qd];
            QDD = [QDD; qdd];
        else
            warning('File %s does not contain expected "out.logsout".', files(i).name);
        end
    end
end
