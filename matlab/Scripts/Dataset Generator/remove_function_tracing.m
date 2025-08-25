function remove_function_tracing()
    % REMOVE_FUNCTION_TRACING - Remove tracing code from all functions
    % This cleans up the tracing code that was added for analysis
    
    fprintf('=== Removing Function Tracing ===\n');
    
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
    
    cleaned_count = 0;
    
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
            
            % Check if has tracing
            has_tracing = false;
            for j = 1:length(content)
                if contains(content{j}, 'function_tracer(')
                    has_tracing = true;
                    break;
                end
            end
            
            if ~has_tracing
                fprintf('  ✓ No tracing to remove\n');
                continue;
            end
            
            % Remove tracing lines
            new_content = {};
            for j = 1:length(content)
                line = content{j};
                if ~contains(line, 'function_tracer(')
                    new_content{end+1} = line;
                end
            end
            
            % Write cleaned file
            fid = fopen(func_file, 'w');
            if fid == -1
                fprintf('  ✗ Cannot open file for writing\n');
                continue;
            end
            
            for j = 1:length(new_content)
                fprintf(fid, '%s\n', new_content{j});
            end
            fclose(fid);
            
            fprintf('  ✓ Removed tracing successfully\n');
            cleaned_count = cleaned_count + 1;
            
        catch ME
            fprintf('  ✗ Error processing file: %s\n', ME.message);
        end
    end
    
    fprintf('\n=== Summary ===\n');
    fprintf('Removed tracing from %d functions\n', cleaned_count);
    fprintf('Functions are now clean and ready for production use\n');
end
