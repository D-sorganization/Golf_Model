function add_function_tracing()
    % ADD_FUNCTION_TRACING - Add tracing to all functions in the functions directory
    % This will help us monitor which functions are actually being called
    
    fprintf('=== Adding Function Tracing ===\n');
    
    % Get the functions directory
    script_dir = fileparts(mfilename('fullpath'));
    functions_dir = fullfile(script_dir, 'functions');
    
    if ~exist(functions_dir, 'dir')
        fprintf('✗ Functions directory not found: %s\n', functions_dir);
        return;
    end
    
    % Get all function files
    function_files = dir(fullfile(functions_dir, '*.m'));
    fprintf('Found %d function files\n', length(function_files));
    
    traced_count = 0;
    
    for i = 1:length(function_files)
        func_file = fullfile(functions_dir, function_files(i).name);
        [~, func_name, ~] = fileparts(function_files(i).name);
        
        fprintf('Processing: %s\n', function_files(i).name);
        
        try
            % Read the function file
            fid = fopen(func_file, 'r');
            if fid == -1
                fprintf('  ✗ Cannot open file for reading\n');
                continue;
            end
            
            content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
            content = content{1};
            fclose(fid);
            
            % Check if already has tracing
            has_tracing = false;
            for j = 1:length(content)
                if contains(content{j}, 'function_tracer(')
                    has_tracing = true;
                    break;
                end
            end
            
            if has_tracing
                fprintf('  ✓ Already has tracing\n');
                continue;
            end
            
            % Find the function definition line
            func_def_line = 0;
            for j = 1:length(content)
                line = strtrim(content{j});
                if startsWith(line, 'function ') && contains(line, '(')
                    func_def_line = j;
                    break;
                end
            end
            
            if func_def_line == 0
                fprintf('  ✗ Could not find function definition\n');
                continue;
            end
            
            % Add tracing call after function definition
            trace_line = sprintf('    function_tracer(''%s'');', func_name);
            new_content = [content(1:func_def_line); {trace_line}; content(func_def_line+1:end)];
            
            % Create backup
            backup_file = sprintf('%s_backup_%s.m', func_file(1:end-2), datestr(now, 'yyyymmdd_HHMMSS'));
            copyfile(func_file, backup_file);
            
            % Write modified file
            fid = fopen(func_file, 'w');
            if fid == -1
                fprintf('  ✗ Cannot open file for writing\n');
                continue;
            end
            
            for j = 1:length(new_content)
                fprintf(fid, '%s\n', new_content{j});
            end
            fclose(fid);
            
            fprintf('  ✓ Added tracing successfully\n');
            traced_count = traced_count + 1;
            
        catch ME
            fprintf('  ✗ Error processing file: %s\n', ME.message);
        end
    end
    
    fprintf('\n=== Summary ===\n');
    fprintf('Added tracing to %d functions\n', traced_count);
    fprintf('Tracing will now log all function calls to function_trace_*.log files\n');
end
