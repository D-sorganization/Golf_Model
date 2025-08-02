% Fix duplicate functions in Data_GUI.m
function fix_duplicate_functions_final()
    fprintf('Fixing duplicate functions in Data_GUI.m...\n');
    
    % Read the file
    filename = 'Data_GUI.m';
    if ~exist(filename, 'file')
        fprintf('Error: Data_GUI.m not found in current directory\n');
        return;
    end
    
    fid = fopen(filename, 'r');
    if fid == -1
        fprintf('Error: Could not open Data_GUI.m for reading\n');
        return;
    end
    
    lines = {};
    line_num = 1;
    while ~feof(fid)
        lines{line_num} = fgetl(fid);
        line_num = line_num + 1;
    end
    fclose(fid);
    
    % Find the duplicate setSimulationParameters function (the second one)
    function_start = -1;
    function_end = -1;
    found_first = false;
    
    for i = 1:length(lines)
        line = lines{i};
        if contains(line, 'function simIn = setSimulationParameters')
            if ~found_first
                found_first = true;
                fprintf('Found first setSimulationParameters function\n');
            else
                function_start = i;
                fprintf('Found duplicate setSimulationParameters function at line %d\n', i);
                break;
            end
        end
    end
    
    if function_start == -1
        fprintf('No duplicate setSimulationParameters function found\n');
        return;
    end
    
    % Find the end of the function (next function or end of file)
    for i = function_start + 1:length(lines)
        line = lines{i};
        if contains(line, '^function ', 'once') || contains(line, '^end$', 'once')
            function_end = i - 1;
            break;
        end
    end
    
    if function_end == -1
        function_end = length(lines);
    end
    
    fprintf('Removing duplicate function from lines %d to %d\n', function_start, function_end);
    
    % Remove the duplicate function
    lines = [lines(1:function_start-1), lines(function_end+1:end)];
    
    % Write the file back
    fid = fopen(filename, 'w');
    if fid == -1
        fprintf('Error: Could not open Data_GUI.m for writing\n');
        return;
    end
    
    for i = 1:length(lines)
        fprintf(fid, '%s\n', lines{i});
    end
    fclose(fid);
    
    fprintf('Fixed! Duplicate setSimulationParameters function removed.\n');
    fprintf('You can now run Data_GUI() without the duplicate function error.\n');
end