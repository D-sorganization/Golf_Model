% File: matlab/tests/test_quality_checks.m
function tests = test_quality_checks
    tests = functiontests(localfunctions);
end

function test_quality_config_function_exists(testCase)
    % Test that the quality config function exists and can be called
    verifyTrue(testCase, exist('matlab_quality_config', 'file') == 2);
    
    % Test that it can be called without errors
    try
        matlab_quality_config();
        verifyTrue(testCase, true);
    catch ME
        verifyFail(testCase, sprintf('matlab_quality_config failed: %s', ME.message));
    end
end

function test_test_runner_function_exists(testCase)
    % Test that the test runner function exists and can be called
    verifyTrue(testCase, exist('run_matlab_tests', 'file') == 2);
    
    % Test that it can be called without errors
    try
        run_matlab_tests();
        verifyTrue(testCase, true);
    catch ME
        verifyFail(testCase, sprintf('run_matlab_tests failed: %s', ME.message));
    end
end

function test_basic_math(testCase)
    % Basic sanity test
    verifyEqual(testCase, 1+1, 2);
    verifyEqual(testCase, 2*3, 6);
    verifyEqual(testCase, 10/2, 5);
end

function test_string_operations(testCase)
    % Test string operations
    test_str = 'Hello World';
    verifyEqual(testCase, length(test_str), 11);
    verifyEqual(testCase, upper(test_str), 'HELLO WORLD');
end

function test_array_operations(testCase)
    % Test array operations
    test_array = [1, 2, 3, 4, 5];
    verifyEqual(testCase, length(test_array), 5);
    verifyEqual(testCase, sum(test_array), 15);
    verifyEqual(testCase, mean(test_array), 3);
end
