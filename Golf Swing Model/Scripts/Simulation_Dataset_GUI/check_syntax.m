function check_syntax()
    try
        fprintf('Checking syntax of GolfSwingDataGeneratorGUI.m...\n');
        
        % Try to parse the file
        pcode('GolfSwingDataGeneratorGUI.m');
        
        fprintf('Syntax check passed!\n');
        
    catch ME
        fprintf('Syntax error found: %s\n', ME.message);
        fprintf('Error identifier: %s\n', ME.identifier);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
    end
end 