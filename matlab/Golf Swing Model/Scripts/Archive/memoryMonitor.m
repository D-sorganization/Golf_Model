% memoryMonitor.m
% Memory monitoring and management utilities for large simulations

function memoryMonitor(action, varargin)
    % Memory monitoring and management utilities
    %
    % Usage:
    %   memoryMonitor('check')           - Check current memory usage
    %   memoryMonitor('cleanup')         - Perform memory cleanup
    %   memoryMonitor('monitor', interval) - Start continuous monitoring
    %   memoryMonitor('stop')            - Stop monitoring
    
    persistent monitor_timer;
    
    switch lower(action)
        case 'check'
            checkMemoryUsage();
            
        case 'cleanup'
            performMemoryCleanup();
            
        case 'monitor'
            if nargin < 2
                interval = 30; % Default 30 seconds
            else
                interval = varargin{1};
            end
            startMemoryMonitoring(interval);
            
        case 'stop'
            stopMemoryMonitoring();
            
        otherwise
            fprintf('Unknown action: %s\n', action);
            fprintf('Available actions: check, cleanup, monitor, stop\n');
    end
end

function checkMemoryUsage()
    % Check and display current memory usage
    
    try
        if exist('memory', 'builtin')
            mem_info = memory;
            
            fprintf('\n=== Memory Usage Report ===\n');
            fprintf('MATLAB Memory Used: %.1f MB\n', mem_info.MemUsedMATLAB/1024/1024);
            fprintf('MATLAB Memory Available: %.1f MB\n', mem_info.MemAvailable/1024/1024);
            fprintf('Physical Memory Used: %.1f MB\n', mem_info.PhysicalMemory.Used/1024/1024);
            fprintf('Physical Memory Available: %.1f MB\n', mem_info.PhysicalMemory.Available/1024/1024);
            fprintf('Virtual Memory Used: %.1f MB\n', mem_info.VirtualMemory.Used/1024/1024);
            fprintf('Virtual Memory Available: %.1f MB\n', mem_info.VirtualMemory.Available/1024/1024);
            
            % Calculate usage percentages
            matlab_usage = (mem_info.MemUsedMATLAB / mem_info.MemAvailable) * 100;
            physical_usage = (mem_info.PhysicalMemory.Used / mem_info.PhysicalMemory.Available) * 100;
            
            fprintf('\nUsage Percentages:\n');
            fprintf('MATLAB Memory: %.1f%%\n', matlab_usage);
            fprintf('Physical Memory: %.1f%%\n', physical_usage);
            
            % Warning thresholds
            if matlab_usage > 80
                fprintf('\n⚠️  WARNING: MATLAB memory usage is high (>80%%)\n');
                fprintf('   Consider running memoryMonitor(''cleanup'')\n');
            end
            
            if physical_usage > 90
                fprintf('\n🚨 CRITICAL: Physical memory usage is very high (>90%%)\n');
                fprintf('   System may become unstable\n');
            end
            
        else
            fprintf('Memory function not available in this MATLAB version\n');
        end
        
    catch ME
        fprintf('Error checking memory usage: %s\n', ME.message);
    end
end

function performMemoryCleanup()
    % Perform comprehensive memory cleanup
    
    fprintf('\n=== Performing Memory Cleanup ===\n');
    
    try
        % Clear temporary variables
        fprintf('Clearing temporary variables...\n');
        clear('ans');
        
        % Force garbage collection
        if exist('OCTAVE_VERSION', 'builtin')
            % Octave
            clear -f;
            fprintf('✓ Octave memory cleared\n');
        else
            % MATLAB
            if exist('java.lang.System', 'class')
                java.lang.System.gc();
                fprintf('✓ Java garbage collection performed\n');
            end
        end
        
        % Clear figure handles that might be lingering
        try
            all_figs = findall(0, 'Type', 'figure');
            if length(all_figs) > 10
                fprintf('Found %d figure handles, clearing old ones...\n', length(all_figs));
                % Keep only the most recent 5 figures
                for i = 6:length(all_figs)
                    try
                        delete(all_figs(i));
                    catch
                        % Ignore errors
                    end
                end
                fprintf('✓ Old figure handles cleared\n');
            end
        catch
            % Ignore figure cleanup errors
        end
        
        % Check memory after cleanup
        fprintf('\nMemory after cleanup:\n');
        checkMemoryUsage();
        
    catch ME
        fprintf('Error during memory cleanup: %s\n', ME.message);
    end
end

function startMemoryMonitoring(interval)
    % Start continuous memory monitoring
    
    global monitor_timer;
    
    try
        % Stop existing timer if running
        if ~isempty(monitor_timer) && isvalid(monitor_timer)
            stop(monitor_timer);
            delete(monitor_timer);
        end
        
        % Create new timer
        monitor_timer = timer;
        monitor_timer.Period = interval;
        monitor_timer.ExecutionMode = 'fixedRate';
        monitor_timer.TimerFcn = @(~,~) checkMemoryUsage();
        
        % Start timer
        start(monitor_timer);
        
        fprintf('Memory monitoring started (interval: %d seconds)\n', interval);
        fprintf('Use memoryMonitor(''stop'') to stop monitoring\n');
        
    catch ME
        fprintf('Error starting memory monitoring: %s\n', ME.message);
    end
end

function stopMemoryMonitoring()
    % Stop memory monitoring
    
    global monitor_timer;
    
    try
        if ~isempty(monitor_timer) && isvalid(monitor_timer)
            stop(monitor_timer);
            delete(monitor_timer);
            monitor_timer = [];
            fprintf('Memory monitoring stopped\n');
        else
            fprintf('No active memory monitoring found\n');
        end
        
    catch ME
        fprintf('Error stopping memory monitoring: %s\n', ME.message);
    end
end

% Additional utility functions

function is_safe = checkMemorySafety()
    % Check if it's safe to continue with large operations
    
    try
        if exist('memory', 'builtin')
            mem_info = memory;
            
            % Check if we have enough available memory
            available_mb = mem_info.MemAvailable / 1024 / 1024;
            physical_available_mb = mem_info.PhysicalMemory.Available / 1024 / 1024;
            
            % Require at least 1GB available
            if available_mb < 1024 || physical_available_mb < 1024
                is_safe = false;
                fprintf('⚠️  Low memory warning: %.1f MB available\n', min(available_mb, physical_available_mb));
                return;
            end
            
            % Check usage percentages
            matlab_usage = (mem_info.MemUsedMATLAB / mem_info.MemAvailable) * 100;
            physical_usage = (mem_info.PhysicalMemory.Used / mem_info.PhysicalMemory.Available) * 100;
            
            if matlab_usage > 70 || physical_usage > 85
                is_safe = false;
                fprintf('⚠️  High memory usage: MATLAB %.1f%%, Physical %.1f%%\n', matlab_usage, physical_usage);
                return;
            end
            
            is_safe = true;
            
        else
            % If memory function not available, assume safe
            is_safe = true;
        end
        
    catch ME
        fprintf('Error checking memory safety: %s\n', ME.message);
        is_safe = false;
    end
end

function waitForMemoryRecovery(timeout_seconds)
    % Wait for memory to recover to safe levels
    
    if nargin < 1
        timeout_seconds = 300; % 5 minutes default
    end
    
    fprintf('Waiting for memory recovery (timeout: %d seconds)...\n', timeout_seconds);
    
    start_time = tic;
    while toc(start_time) < timeout_seconds
        if checkMemorySafety()
            fprintf('✓ Memory recovered after %.1f seconds\n', toc(start_time));
            return;
        end
        
        % Wait 10 seconds before checking again
        pause(10);
        fprintf('.');
    end
    
    fprintf('\n⚠️  Memory recovery timeout reached\n');
    fprintf('Consider manual cleanup or restarting MATLAB\n');
end 