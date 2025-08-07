classdef DataValidator
    %DATAVALIDATOR Utility for validating swing data tables.
    methods (Static)
        function validateInputData(dataTable, tableName, numFrames)
            if nargin < 3
                numFrames = [];
            end
            requiredCols = {'Buttx', 'Butty', 'Buttz', 'CHx', 'CHy', 'CHz', ...
                            'MPx', 'MPy', 'MPz', 'LWx', 'LWy', 'LWz', ...
                            'LEx', 'LEy', 'LEz', 'LSx', 'LSy', 'LSz', ...
                            'RWx', 'RWy', 'RWz', 'REx', 'REy', 'REz', ...
                            'RSx', 'RSy', 'RSz', 'HUBx', 'HUBy', 'HUBz', ...
                            'TotalHandForceGlobal', 'EquivalentMidpointCoupleGlobal'};
            presentCols = dataTable.Properties.VariableNames;
            for i = 1:length(requiredCols)
                colName = requiredCols{i};
                if ~ismember(colName, presentCols)
                    error('GolfSwingVisualizer:MissingColumn', ...
                          'Input table %s is missing required column: %s', tableName, colName);
                end
                colData = dataTable.(colName);
                if ~isnumeric(colData)
                    error('GolfSwingVisualizer:InvalidColumnType', ...
                          'Column %s in table %s must be numeric.', colName, tableName);
                end
                if ~strcmp(tableName, 'BASEQ_table') && ~isempty(numFrames) && height(dataTable) ~= numFrames
                    error('GolfSwingVisualizer:FrameMismatch', ...
                          'Input table %s has %d rows, expected %d based on BASEQ_table.', ...
                          tableName, height(dataTable), numFrames);
                end
            end
            vectorCols = {'TotalHandForceGlobal', 'EquivalentMidpointCoupleGlobal'};
            for i = 1:length(vectorCols)
                colName = vectorCols{i};
                if ismember(colName, presentCols)
                    colData = dataTable.(colName);
                    if size(colData, 2) ~= 3
                        error('GolfSwingVisualizer:InvalidColumnSize', ...
                              'Column %s in table %s must have 3 columns (Nx3).', ...
                              colName, tableName);
                    end
                end
            end
        end
    end
end
