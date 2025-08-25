    % FUNCTION_TRACER - Tracks function calls for debugging
    % This function logs all function calls to help identify which functions
    % are actually being used during execution
    
    persistent log_file
    persistent is_initialized
    
    if isempty(is_initialized)
        is_initialized = false;
    end
    
    % Initialize logging on first call
    if ~is_initialized
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        log_file = sprintf('function_trace_%s.log', timestamp);
        is_initialized = true;
        
        % Write header
        fid = fopen(log_file, 'w');
        if fid ~= -1
            fprintf(fid, '=== FUNCTION TRACE LOG ===\n');
            fprintf(fid, 'Started: %s\n', datestr(now));
            fprintf(fid, '========================\n\n');
            fclose(fid);
        end
    end
    
    % Log the function call
    timestamp = datestr(now, 'HH:MM:SS.FFF');
    stack_info = dbstack(1); % Get caller info
    
    if ~isempty(stack_info)
        caller_name = stack_info(1).name;
        caller_line = stack_info(1).line;
        caller_file = stack_info(1).file;
    else
        caller_name = 'unknown';
        caller_line = 0;
        caller_file = 'unknown';
    end
    
    % Write to log file
    fid = fopen(log_file, 'a');
    if fid ~= -1
        fprintf(fid, '[%s] %s called from %s:%d (%s)\n', ...
            timestamp, func_name, caller_file, caller_line, caller_name);
        fclose(fid);
    end
    
    % Also print to console for immediate feedback
    fprintf('[TRACE] %s called from %s:%d (%s)\n', ...
        func_name, caller_file, caller_line, caller_name);
end
