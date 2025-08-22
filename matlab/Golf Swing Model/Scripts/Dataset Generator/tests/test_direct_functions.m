% Test script to directly test key functions that are failing
% This bypasses the GUI to isolate the issue

try
    fprintf('=== TESTING DIRECT FUNCTIONS ===\n');

    % Test 1: Check if key functions exist
    fprintf('Testing function existence...\n');

    if exist('getMemoryUsage', 'file')
        fprintf('✓ getMemoryUsage exists\n');
    else
        fprintf('✗ getMemoryUsage not found\n');
    end

    if exist('getMemoryInfo', 'file')
        fprintf('✓ getMemoryInfo exists\n');
    else
        fprintf('✗ getMemoryInfo not found\n');
    end

    % Test 2: Test memory functions directly
    fprintf('\nTesting memory functions...\n');

    try
        mem_usage = getMemoryUsage();
        fprintf('✓ getMemoryUsage returned: %s\n', class(mem_usage));
        if isstruct(mem_usage)
            fprintf('  Fields: %s\n', strjoin(fieldnames(mem_usage), ', '));
        end
    catch ME
        fprintf('✗ getMemoryUsage failed: %s\n', ME.message);
    end

    try
        mem_info = getMemoryInfo();
        fprintf('✓ getMemoryInfo returned: %s\n', class(mem_info));
    catch ME
        fprintf('✗ getMemoryInfo failed: %s\n', ME.message);
    end

    % Test 3: Test system commands that might be failing
    fprintf('\nTesting system commands...\n');

    try
        [status, result] = system('hostname');
        if status == 0
            fprintf('✓ hostname command successful: %s\n', strtrim(result));
        else
            fprintf('✗ hostname command failed with status %d\n', status);
        end
    catch ME
        fprintf('✗ hostname command error: %s\n', ME.message);
    end

    try
        [status, result] = system('wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /Value');
        if status == 0
            fprintf('✓ wmic command successful (length: %d)\n', length(result));
        else
            fprintf('✗ wmic command failed with status %d\n', status);
        end
    catch ME
        fprintf('✗ wmic command error: %s\n', ME.message);
    end

    % Test 4: Check if we can access the model file
    fprintf('\nTesting model file access...\n');

    model_path = '../../Model/GolfSwing3D_Kinetic.slx';
    if exist(model_path, 'file')
        fprintf('✓ Model file exists at: %s\n', model_path);
    else
        fprintf('✗ Model file not found at: %s\n', model_path);

        % Try to find it
        [current_dir, ~, ~] = fileparts(pwd);
        possible_paths = {
            'Model/GolfSwing3D_Kinetic.slx',
            '../../Model/GolfSwing3D_Kinetic.slx',
            '../Model/GolfSwing3D_Kinetic.slx',
            fullfile(current_dir, 'Model', 'GolfSwing3D_Kinetic.slx')
            };

        for i = 1:length(possible_paths)
            if exist(possible_paths{i}, 'file')
                fprintf('  Found model at: %s\n', possible_paths{i});
                break;
            end
        end
    end

    % Test 5: Check polynomial input file
    fprintf('\nTesting polynomial input file...\n');

    poly_path = 'Model/PolynomialInputValues.mat';
    if exist(poly_path, 'file')
        fprintf('✓ Polynomial file exists at: %s\n', poly_path);
    else
        fprintf('✗ Polynomial file not found at: %s\n', poly_path);

        % Try to find it
        possible_paths = {
            'Model/PolynomialInputValues.mat',
            '../../Model/PolynomialInputValues.mat',
            '../Model/PolynomialInputValues.mat'
            };

        for i = 1:length(possible_paths)
            if exist(possible_paths{i}, 'file')
                fprintf('  Found polynomial file at: %s\n', possible_paths{i});
                break;
            end
        end
    end

catch ME
    fprintf('ERROR in test script: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end

fprintf('\n=== DIRECT FUNCTION TEST COMPLETE ===\n');
