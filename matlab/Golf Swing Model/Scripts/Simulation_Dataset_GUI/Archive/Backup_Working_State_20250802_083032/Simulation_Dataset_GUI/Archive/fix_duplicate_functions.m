function fix_duplicate_functions()
    % Fix duplicate function declarations in Data_GUI.m

    fprintf('Fixing duplicate function declarations in Data_GUI.m...\n');

    % Read the file
    filename = 'Data_GUI.m';
    fid = fopen(filename, 'r');
    if fid == -1
        fprintf('ERROR: Could not open %s\n', filename);
        return;
    end

    % Read all lines
    lines = {};
    line_num = 1;
    while ~feof(fid)
        lines{line_num} = fgetl(fid);
        line_num = line_num + 1;
    end
    fclose(fid);

    % Find duplicate inspectSimulationOutput functions
    function_lines = [];
    for i = 1:length(lines)
        if contains(lines{i}, 'function inspectSimulationOutput')
            function_lines(end+1) = i;
        end
    end

    if length(function_lines) > 1
        fprintf('Found %d inspectSimulationOutput function declarations\n', length(function_lines));

        % Keep the first one, remove the second one
        start_line = function_lines(2);

        % Find the end of the second function (look for next function or end of file)
        end_line = length(lines);
        for i = start_line:length(lines)
            if i > start_line && startsWith(strtrim(lines{i}), 'function ')
                end_line = i - 1;
                break;
            end
        end

        fprintf('Removing duplicate function from lines %d to %d\n', start_line, end_line);

        % Remove the duplicate function
        lines(start_line:end_line) = [];

        % Write the file back
        fid = fopen(filename, 'w');
        if fid == -1
            fprintf('ERROR: Could not write to %s\n', filename);
            return;
        end

        for i = 1:length(lines)
            if ~isempty(lines{i})
                fprintf(fid, '%s\n', lines{i});
            end
        end
        fclose(fid);

        fprintf('Fixed! Duplicate function removed.\n');
        fprintf('You can now run Data_GUI() again.\n');
    else
        fprintf('No duplicate functions found.\n');
    end
end
