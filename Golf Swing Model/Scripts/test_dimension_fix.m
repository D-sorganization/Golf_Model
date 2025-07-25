function test_dimension_fix()
% test_dimension_fix.m
% Standalone test to verify the dimension mismatch fix

fprintf('=== Testing Dimension Mismatch Fix ===\n\n');

try
    % Test the addColumnSafely function directly
    fprintf('Testing addColumnSafely function...\n');
    
    % Test case 1: Correct dimensions
    trial_data = zeros(5, 2);
    signal_names = {'col1', 'col2'};
    new_column = ones(5, 1);
    
    [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, new_column, 'test_col');
    if success
        fprintf('✓ Test 1 passed: Correct dimensions\n');
    else
        fprintf('✗ Test 1 failed: Correct dimensions\n');
    end
    
    % Test case 2: Wrong dimensions
    trial_data2 = zeros(5, 2);
    signal_names2 = {'col1', 'col2'};
    wrong_column = ones(3, 1); % Wrong number of rows
    
    [trial_data2, signal_names2, success2] = addColumnSafely(trial_data2, signal_names2, wrong_column, 'wrong_col');
    if ~success2
        fprintf('✓ Test 2 passed: Wrong dimensions properly handled\n');
    else
        fprintf('✗ Test 2 failed: Wrong dimensions not handled\n');
    end
    
    % Test case 3: Row vector input
    trial_data3 = zeros(5, 2);
    signal_names3 = {'col1', 'col2'};
    row_vector = ones(1, 5); % Row vector
    
    [trial_data3, signal_names3, success3] = addColumnSafely(trial_data3, signal_names3, row_vector, 'row_col');
    if success3
        fprintf('✓ Test 3 passed: Row vector converted to column\n');
    else
        fprintf('✗ Test 3 failed: Row vector conversion\n');
    end
    
    % Test case 4: Empty data
    trial_data4 = zeros(5, 2);
    signal_names4 = {'col1', 'col2'};
    empty_column = [];
    
    [trial_data4, signal_names4, success4] = addColumnSafely(trial_data4, signal_names4, empty_column, 'empty_col');
    if ~success4
        fprintf('✓ Test 4 passed: Empty data properly handled\n');
    else
        fprintf('✗ Test 4 failed: Empty data not handled\n');
    end
    
    fprintf('\n=== All Tests Complete ===\n');
    
catch ME
    fprintf('✗ Test error: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

end

function [trial_data, signal_names, success] = addColumnSafely(trial_data, signal_names, data_column, column_name)
    % Helper function to safely add a column to trial_data
    try
        % Handle empty data
        if isempty(data_column)
            fprintf('      ⚠️  Skipping %s: empty data\n', column_name);
            success = false;
            return;
        end
        
        % Ensure data_column is a column vector with correct dimensions
        if ~iscolumn(data_column)
            data_column = data_column(:);
        end
        
        % Check if dimensions match
        if size(trial_data, 1) == size(data_column, 1)
            trial_data = [trial_data, data_column];
            signal_names{end+1} = column_name;
            success = true;
        else
            fprintf('      ⚠️  Skipping %s: dimension mismatch (expected %d rows, got %d)\n', ...
                column_name, size(trial_data, 1), size(data_column, 1));
            success = false;
        end
    catch ME
        fprintf('      ⚠️  Error adding column %s: %s\n', column_name, ME.message);
        success = false;
    end
end 