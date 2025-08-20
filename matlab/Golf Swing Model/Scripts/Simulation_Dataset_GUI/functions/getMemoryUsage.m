function memory_info = getMemoryUsage()
% GETMEMORYUSAGE - Get current system memory usage information
%
% Outputs:
%   memory_info - Structure with memory usage information

memory_info = struct();

try
    % Get memory information
    mem_info = memory;

    % Check if mem_info is a valid structure
    if ~isstruct(mem_info) || isempty(mem_info)
        error('Memory function returned invalid structure');
    end

    % Extract memory values with safety checks
    if isfield(mem_info, 'PhysicalMemory') && isstruct(mem_info.PhysicalMemory)
        % Check if PhysicalMemory fields exist and are numeric
        if isfield(mem_info.PhysicalMemory, 'Total') && isnumeric(mem_info.PhysicalMemory.Total)
            memory_info.total_gb = mem_info.PhysicalMemory.Total / (1024^3);
            memory_info.available_gb = mem_info.PhysicalMemory.Available / (1024^3);
            memory_info.used_gb = memory_info.total_gb - memory_info.available_gb;
            memory_info.usage_percent = (memory_info.used_gb / memory_info.total_gb) * 100;
        else
            error('PhysicalMemory fields are not numeric');
        end
    else
        % Fallback if PhysicalMemory is not available
        memory_info.total_gb = NaN;
        memory_info.available_gb = NaN;
        memory_info.used_gb = NaN;
        memory_info.usage_percent = NaN;
    end

    % Get virtual memory info if available
    if isfield(mem_info, 'VirtualAddressSpace') && isstruct(mem_info.VirtualAddressSpace)
        if isfield(mem_info.VirtualAddressSpace, 'Total') && isnumeric(mem_info.VirtualAddressSpace.Total)
            memory_info.virtual_total_gb = mem_info.VirtualAddressSpace.Total / (1024^3);
            memory_info.virtual_available_gb = mem_info.VirtualAddressSpace.Available / (1024^3);
        else
            memory_info.virtual_total_gb = NaN;
            memory_info.virtual_available_gb = NaN;
        end
    else
        memory_info.virtual_total_gb = NaN;
        memory_info.virtual_available_gb = NaN;
    end

    % Get MATLAB workspace memory
    if isfield(mem_info, 'MATLAB') && isstruct(mem_info.MATLAB)
        if isfield(mem_info.MATLAB, 'PhysicalMemory') && isstruct(mem_info.MATLAB.PhysicalMemory)
            if isfield(mem_info.MATLAB.PhysicalMemory, 'Used') && isnumeric(mem_info.MATLAB.PhysicalMemory.Used)
                memory_info.matlab_used_gb = mem_info.MATLAB.PhysicalMemory.Used / (1024^3);
            else
                memory_info.matlab_used_gb = NaN;
            end
            if isfield(mem_info.MATLAB.PhysicalMemory, 'Peak') && isnumeric(mem_info.MATLAB.PhysicalMemory.Peak)
                memory_info.matlab_peak_gb = mem_info.MATLAB.PhysicalMemory.Peak / (1024^3);
            else
                memory_info.matlab_peak_gb = NaN;
            end
        else
            memory_info.matlab_used_gb = NaN;
            memory_info.matlab_peak_gb = NaN;
        end
    else
        memory_info.matlab_used_gb = NaN;
        memory_info.matlab_peak_gb = NaN;
    end

    fprintf('✓ Memory usage retrieved successfully\n');

catch ME
    fprintf('✗ Error getting memory info: %s\n', ME.message);
    fprintf('Attempting fallback memory detection...\n');

    % Try alternative methods for getting memory info
    try
        % Method 1: Try using system commands (Windows)
        if ispc
            [~, result] = system('wmic computersystem get TotalPhysicalMemory /value');
            if ~isempty(strfind(result, 'TotalPhysicalMemory='))
                % Use strfind and strtok for compatibility with older MATLAB versions
                start_idx = strfind(result, 'TotalPhysicalMemory=');
                if ~isempty(start_idx)
                    start_idx = start_idx(1) + length('TotalPhysicalMemory=');
                    remaining = result(start_idx:end);
                    % Find the end of the value (newline or space)
                    end_idx = strfind(remaining, sprintf('\n'));
                    if isempty(end_idx)
                        end_idx = strfind(remaining, ' ');
                    end
                    if ~isempty(end_idx)
                        total_memory_str = strtrim(remaining(1:end_idx(1)-1));
                    else
                        total_memory_str = strtrim(remaining);
                    end
                    total_memory_bytes = str2double(total_memory_str);
                    if ~isnan(total_memory_bytes)
                        memory_info.total_gb = total_memory_bytes / (1024^3);
                        memory_info.available_gb = NaN; % Can't easily get available memory via wmic
                        memory_info.used_gb = NaN;
                        memory_info.usage_percent = NaN;
                        memory_info.virtual_total_gb = NaN;
                        memory_info.virtual_available_gb = NaN;
                        memory_info.matlab_used_gb = NaN;
                        memory_info.matlab_peak_gb = NaN;
                        fprintf('✓ Fallback memory detection successful (Windows)\n');
                        return;
                    end
                end
            end
        end

        % Method 2: Try using Java runtime (cross-platform)
        try
            runtime = java.lang.Runtime.getRuntime();
            total_memory = runtime.totalMemory();
            free_memory = runtime.freeMemory();
            used_memory = total_memory - free_memory;

            memory_info.total_gb = total_memory / (1024^3);
            memory_info.available_gb = free_memory / (1024^3);
            memory_info.used_gb = used_memory / (1024^3);
            memory_info.usage_percent = (used_memory / total_memory) * 100;
            memory_info.virtual_total_gb = NaN;
            memory_info.virtual_available_gb = NaN;
            memory_info.matlab_used_gb = NaN;
            memory_info.matlab_peak_gb = NaN;
            fprintf('✓ Fallback memory detection successful (Java)\n');
            return;
        catch
            fprintf('Java fallback also failed\n');
        end

    catch
        fprintf('All fallback methods failed\n');
    end

    % Set default values on error
    memory_info.total_gb = NaN;
    memory_info.available_gb = NaN;
    memory_info.used_gb = NaN;
    memory_info.usage_percent = NaN;
    memory_info.virtual_total_gb = NaN;
    memory_info.virtual_available_gb = NaN;
    memory_info.matlab_used_gb = NaN;
    memory_info.matlab_peak_gb = NaN;
end
end
