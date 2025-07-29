function fix_save_to_workspace_error()
    % Quick fix to remove the invalid SaveToWorkspace parameter
    
    fprintf('Fixing SaveToWorkspace error in Data_GUI.m...\n');
    
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
    
    % Find and remove the problematic line
    fixed = false;
    for i = 1:length(lines)
        if contains(lines{i}, 'SaveToWorkspace')
            fprintf('Found SaveToWorkspace on line %d, removing...\n', i);
            lines{i} = '';  % Remove the line
            fixed = true;
        end
    end
    
    if ~fixed
        fprintf('No SaveToWorkspace line found\n');
        return;
    end
    
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
    
    fprintf('Fixed! SaveToWorkspace parameter removed.\n');
    fprintf('You can now run Data_GUI() again.\n');
end