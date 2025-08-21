% Test script to test Python export functions directly
% This will help identify if they're causing the "system cannot find the path specified" error

try
    fprintf('=== TESTING PYTHON EXPORT FUNCTIONS ===\n');
    
    % Add functions folder to path
    functions_path = fullfile(pwd, 'functions');
    if exist(functions_path, 'dir')
        addpath(functions_path);
        fprintf('Added functions folder to path: %s\n', functions_path);
    else
        fprintf('Functions folder not found: %s\n', functions_path);
        return;
    end
    
    % Create some dummy data
    dummy_data = struct();
    dummy_data.test_field = [1, 2, 3, 4, 5];
    dummy_data.another_field = rand(10, 1);
    
    % Test PostProcessingModule functions
    fprintf('\nTesting PostProcessingModule functions...\n');
    
    % Check if PostProcessingModule exists
    if exist('PostProcessingModule', 'file')
        fprintf('  PostProcessingModule exists\n');
        
        % Test the export functions by calling them through PostProcessingModule
        % We need to create a proper test that calls the functions correctly
        
        % Create a test output file
        test_output_file = 'test_export_output';
        
        % Test each export function
        export_functions = {'exportToPyTorch', 'exportToTensorFlow', 'exportToNumPy', 'exportToPickle'};
        
        for i = 1:length(export_functions)
            func_name = export_functions{i};
            fprintf('\n  Testing %s...\n', func_name);
            
            try
                % Call with minimal data and options
                options = struct();
                options.verbose = false;
                
                % Call the function
                feval(func_name, dummy_data, test_output_file, options);
                fprintf('    ✓ %s completed without error\n', func_name);
            catch ME
                fprintf('    ✗ %s failed: %s\n', func_name, ME.message);
                if contains(ME.message, 'system cannot find the path specified')
                    fprintf('      *** This is the source of the system path error! ***\n');
                end
                
                % Show stack trace for debugging
                fprintf('      Stack trace:\n');
                for j = 1:length(ME.stack)
                    fprintf('        %s (line %d)\n', ME.stack(j).name, ME.stack(j).line);
                end
            end
        end
        
    else
        fprintf('  PostProcessingModule not found\n');
    end
    
catch ME
    fprintf('ERROR in test script: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== PYTHON EXPORT TEST COMPLETE ===\n');
