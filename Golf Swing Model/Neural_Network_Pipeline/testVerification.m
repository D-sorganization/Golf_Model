% testVerification.m
% Simple test script to run signal verification
% 
% This script runs the verification and provides a quick summary

clear; clc; close all;

fprintf('=== Testing Signal Verification ===\n\n');

try
    % Run verification
    [verification_results, test_dataset] = verifySimscapeSignals('GolfSwing3D_Kinetic', true);
    
    % Display summary
    fprintf('\n=== Verification Summary ===\n');
    fprintf('Overall Status: %s\n', verification_results.overall_status);
    fprintf('Total Signals: %d\n', verification_results.total_signals);
    
    % Check signal categories
    categories = fieldnames(verification_results.signal_categories);
    fprintf('\nSignal Categories:\n');
    for i = 1:length(categories)
        category = categories{i};
        status = verification_results.signal_categories.(category).found;
        count = verification_results.signal_categories.(category).count;
        
        if status
            fprintf('  ✓ %s: %d signals\n', strrep(category, '_', ' '), count);
        else
            fprintf('  ✗ %s: No signals found\n', strrep(category, '_', ' '));
        end
    end
    
    % Check model workspace
    if isfield(verification_results, 'model_workspace')
        if verification_results.model_workspace.accessible
            fprintf('\nModel Workspace: ✓ Accessible (%d variables)\n', ...
                    verification_results.model_workspace.total_variables);
        else
            fprintf('\nModel Workspace: ✗ Not accessible\n');
        end
    end
    
    % Check test dataset
    if ~isempty(test_dataset)
        fprintf('\nTest Dataset: ✓ Generated successfully\n');
        fprintf('  Size: %.2f MB\n', dir(verification_results.test_dataset_filename).bytes / (1024^2));
    else
        fprintf('\nTest Dataset: ✗ Not generated\n');
    end
    
    % Final assessment
    if strcmp(verification_results.overall_status, 'PASSED')
        fprintf('\n🎉 Verification PASSED! System is ready for dataset generation.\n');
    else
        fprintf('\n⚠️  Verification FAILED! Check the issues above.\n');
    end
    
catch ME
    fprintf('✗ Verification test failed: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

fprintf('\n=== Test Complete ===\n'); 