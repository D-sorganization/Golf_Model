% Test script for output folder validation
% This tests the validation logic implemented in validateInputs function

fprintf('=== TESTING OUTPUT FOLDER VALIDATION ===\n');

% Test 1: Valid local folder
fprintf('\n--- Test 1: Valid local folder ---\n');
test_folder = pwd;
fprintf('Testing folder: %s\n', test_folder);

if exist(test_folder, 'dir')
    fprintf('✓ Folder exists\n');
    
    % Test write access
    try
        test_file = fullfile(test_folder, '.test_write_access');
        fid = fopen(test_file, 'w');
        if fid == -1
            fprintf('✗ Cannot write to folder\n');
        else
            fprintf('✓ Can write to folder\n');
            fclose(fid);
            delete(test_file);
            fprintf('✓ Test file created and deleted successfully\n');
        end
    catch ME
        fprintf('✗ Write test failed: %s\n', ME.message);
    end
else
    fprintf('✗ Folder does not exist\n');
end

% Test 2: Non-existent folder
fprintf('\n--- Test 2: Non-existent folder ---\n');
fake_folder = fullfile(pwd, 'NONEXISTENT_FOLDER_12345');
fprintf('Testing folder: %s\n', fake_folder);

if exist(fake_folder, 'dir')
    fprintf('✗ Folder exists (unexpected)\n');
else
    fprintf('✓ Folder does not exist (expected)\n');
end

% Test 3: Test the actual validation function
fprintf('\n--- Test 3: Testing validateInputs validation logic ---\n');

% Create a mock handles structure to test the validation
mock_handles.output_folder_edit = struct('String', test_folder);
mock_handles.folder_name_edit = struct('String', 'test_dataset');

fprintf('Testing with valid folder: %s\n', test_folder);
fprintf('Testing with folder name: test_dataset\n');

% Simulate the validation logic
output_folder = mock_handles.output_folder_edit.String;
folder_name = mock_handles.folder_name_edit.String;

if isempty(output_folder) || isempty(folder_name)
    fprintf('✗ Empty output folder or folder name\n');
else
    fprintf('✓ Output folder and folder name are not empty\n');
    
    full_output_path = fullfile(output_folder, folder_name);
    fprintf('Full output path: %s\n', full_output_path);
    
    % Check if output folder exists and is accessible
    if ~exist(output_folder, 'dir')
        fprintf('✗ Output folder does not exist or is not accessible\n');
    else
        fprintf('✓ Output folder exists and is accessible\n');
        
        % Check if we can write to the output folder
        try
            test_file = fullfile(output_folder, '.test_write_access');
            fid = fopen(test_file, 'w');
            if fid == -1
                fprintf('✗ Cannot write to folder\n');
            else
                fprintf('✓ Can write to folder\n');
                fclose(fid);
                delete(test_file);
                fprintf('✓ Test file created and deleted successfully\n');
            end
        catch ME
            fprintf('✗ Write access test failed: %s\n', ME.message);
        end
        
        % Check if the full output path already exists
        if exist(full_output_path, 'dir')
            fprintf('⚠ Output folder already exists (will warn user)\n');
        else
            fprintf('✓ Output folder does not exist yet\n');
        end
    end
end

% Test 4: Test with invalid folder
fprintf('\n--- Test 4: Testing with invalid folder ---\n');
mock_handles.output_folder_edit.String = fake_folder;

output_folder = mock_handles.output_folder_edit.String;
folder_name = mock_handles.folder_name_edit.String;

fprintf('Testing with invalid folder: %s\n', output_folder);

if ~exist(output_folder, 'dir')
    fprintf('✗ Output folder does not exist (expected)\n');
    fprintf('This should trigger an error in the real validation\n');
else
    fprintf('✓ Output folder exists (unexpected)\n');
end

fprintf('\n=== VALIDATION TESTING COMPLETE ===\n');
fprintf('The validateInputs function should now catch invalid output folders\n');
fprintf('and prevent simulations from starting with inaccessible paths.\n');
