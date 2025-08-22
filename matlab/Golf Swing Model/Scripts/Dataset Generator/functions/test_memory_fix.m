%% Test Memory Function Fix
% This script tests the fixed getMemoryUsage function to ensure it doesn't
% cause the "Dot indexing is not supported for variables of this type" error

fprintf('Testing fixed getMemoryUsage function...\n');

% Add current directory to path
current_dir = fileparts(mfilename('fullpath'));
addpath(current_dir);

% Test 1: Check if function exists
if exist('getMemoryUsage', 'file')
    fprintf('✓ getMemoryUsage function found\n');
else
    fprintf('✗ getMemoryUsage function not found\n');
    return;
end

% Test 2: Try to call the function
try
    fprintf('Calling getMemoryUsage...\n');
    memory_info = getMemoryUsage();

    % Check if we got a valid structure
    if isstruct(memory_info)
        fprintf('✓ Function returned valid structure\n');

        % Display the memory info
        fprintf('Memory Information:\n');
        if isfield(memory_info, 'total_gb')
            fprintf('  Total Memory: %.2f GB\n', memory_info.total_gb);
        end
        if isfield(memory_info, 'available_gb')
            fprintf('  Available Memory: %.2f GB\n', memory_info.available_gb);
        end
        if isfield(memory_info, 'used_gb')
            fprintf('  Used Memory: %.2f GB\n', memory_info.used_gb);
        end
        if isfield(memory_info, 'usage_percent')
            fprintf('  Usage: %.1f%%\n', memory_info.usage_percent);
        end

        % Test dot indexing to make sure it works
        try
            test_value = memory_info.total_gb;
            fprintf('✓ Dot indexing test passed\n');
        catch ME
            fprintf('✗ Dot indexing test failed: %s\n', ME.message);
        end

    else
        fprintf('✗ Function did not return a valid structure\n');
    end

catch ME
    fprintf('✗ Error calling getMemoryUsage: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

% Test 3: Test multiple calls to ensure stability
fprintf('\nTesting multiple calls for stability...\n');
for i = 1:5
    try
        memory_info = getMemoryUsage();
        fprintf('  Call %d: Success\n', i);
    catch ME
        fprintf('  Call %d: Failed - %s\n', i, ME.message);
    end
end

fprintf('\nMemory function test completed!\n');
