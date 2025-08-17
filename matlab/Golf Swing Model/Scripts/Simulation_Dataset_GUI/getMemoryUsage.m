function memory_info = getMemoryUsage()
    % GETMEMORYUSAGE - Get current system memory usage information
    %
    % Outputs:
    %   memory_info - Structure with memory usage information
    
    memory_info = struct();
    
    try
        % Get memory information
        mem_info = memory;
        
        % Extract memory values with safety checks
        if isfield(mem_info, 'PhysicalMemory')
            memory_info.total_gb = mem_info.PhysicalMemory.Total / (1024^3);
            memory_info.available_gb = mem_info.PhysicalMemory.Available / (1024^3);
            memory_info.used_gb = memory_info.total_gb - memory_info.available_gb;
            memory_info.usage_percent = (memory_info.used_gb / memory_info.total_gb) * 100;
        else
            % Fallback if PhysicalMemory is not available
            memory_info.total_gb = NaN;
            memory_info.available_gb = NaN;
            memory_info.used_gb = NaN;
            memory_info.usage_percent = NaN;
        end
        
        % Get virtual memory info if available
        if isfield(mem_info, 'VirtualAddressSpace')
            memory_info.virtual_total_gb = mem_info.VirtualAddressSpace.Total / (1024^3);
            memory_info.virtual_available_gb = mem_info.VirtualAddressSpace.Available / (1024^3);
        else
            memory_info.virtual_total_gb = NaN;
            memory_info.virtual_available_gb = NaN;
        end
        
        % Get MATLAB workspace memory
        if isfield(mem_info, 'MATLAB')
            memory_info.matlab_used_gb = mem_info.MATLAB.PhysicalMemory.Used / (1024^3);
            memory_info.matlab_peak_gb = mem_info.MATLAB.PhysicalMemory.Peak / (1024^3);
        else
            memory_info.matlab_used_gb = NaN;
            memory_info.matlab_peak_gb = NaN;
        end
        
        fprintf('✓ Memory usage retrieved successfully\n');
        
    catch ME
        fprintf('✗ Error getting memory info: %s\n', ME.message);
        
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
