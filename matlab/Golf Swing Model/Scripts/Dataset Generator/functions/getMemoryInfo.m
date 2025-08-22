function memoryInfo = getMemoryInfo()
try
    % Get MATLAB memory info
    memoryInfo = memory;

    % Calculate memory usage percentage with safety checks
    % Check for the actual fields returned by this MATLAB version
    if isfield(memoryInfo, 'MemUsedMATLAB') && isnumeric(memoryInfo.MemUsedMATLAB)
        % This MATLAB version uses MemUsedMATLAB
        if isfield(memoryInfo, 'MemAvailableAllArrays') && isnumeric(memoryInfo.MemAvailableAllArrays)
            % Calculate total as used + available
            total_memory = memoryInfo.MemUsedMATLAB + memoryInfo.MemAvailableAllArrays;
            if total_memory > 0
                memoryInfo.usage_percent = (memoryInfo.MemUsedMATLAB / total_memory) * 100;
            else
                memoryInfo.usage_percent = 0;
            end
        else
            % Fallback: can't calculate percentage without available memory
            memoryInfo.usage_percent = 0;
        end
    elseif isfield(memoryInfo, 'PhysicalMemory') && isstruct(memoryInfo.PhysicalMemory) && ...
            isfield(memoryInfo.PhysicalMemory, 'Total') && isnumeric(memoryInfo.PhysicalMemory.Total) && ...
            isnumeric(memoryInfo.MemUsedMATLAB) && memoryInfo.PhysicalMemory.Total > 0
        % Fallback to original PhysicalMemory approach if it exists
        memoryInfo.usage_percent = (memoryInfo.MemUsedMATLAB / memoryInfo.PhysicalMemory.Total) * 100;
    else
        memoryInfo.usage_percent = 0;
    end

    % Get system memory info if available
    if ispc
        try
            [status, result] = system('wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /Value');
            if status == 0 && ~isempty(result)
                lines = strsplit(result, '\n');
                total_mem = 0;
                free_mem = 0;

                for i = 1:length(lines)
                    line = strtrim(lines{i});
                    if startsWith(line, 'TotalVisibleMemorySize=')
                        total_mem = str2double(extractAfter(line, '='));
                    elseif startsWith(line, 'FreePhysicalMemory=')
                        free_mem = str2double(extractAfter(line, '='));
                    end
                end

                if total_mem > 0
                    memoryInfo.system_total_mb = total_mem / 1024;
                    memoryInfo.system_free_mb = free_mem / 1024;
                    memoryInfo.system_usage_percent = ((total_mem - free_mem) / total_mem) * 100;
                end
            else
                fprintf('wmic command failed or returned empty result\n');
            end
        catch ME
            fprintf('wmic command error: %s\n', ME.message);
            % Ignore system memory check errors
        end
    end

catch
    memoryInfo = struct('usage_percent', 0);
end
end
