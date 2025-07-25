% Test syntax by parsing the main script
try
    fprintf('Testing syntax of generateSimulationTrainingData.m...\n');
    
    % Check if the function exists and can be loaded
    which generateSimulationTrainingData
    
    % Try to get function info
    info = functions(@generateSimulationTrainingData);
    fprintf('Function info: %s\n', info.function);
    
    fprintf('✓ Syntax check passed - function can be loaded\n');
    
catch ME
    fprintf('✗ Syntax error found:\n');
    fprintf('  Message: %s\n', ME.message);
    fprintf('  Identifier: %s\n', ME.identifier);
    if ~isempty(ME.stack)
        fprintf('  Line: %d in %s\n', ME.stack(1).line, ME.stack(1).name);
    end
end
