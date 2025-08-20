function memoryInfo = getMemoryInfo()
    try
        % Get MATLAB memory info
        memoryInfo = memory;

        % Calculate memory usage percentage
        memoryInfo.usage_percent = (memoryInfo.MemUsedMATLAB / memoryInfo.PhysicalMemory.Total) * 100;

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
