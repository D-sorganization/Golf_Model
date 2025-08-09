function matlab_quality_config()
    % MATLAB Code Quality Configuration
    % This script sets up quality checks for MATLAB code
    
    fprintf('🔍 Setting up MATLAB code quality checks...\n');
    
    % 1. Add current directory to path if not already there
    current_dir = pwd;
    if ~contains(path, current_dir)
        addpath(current_dir);
        fprintf('Added %s to MATLAB path\n', current_dir);
    end
    
    % 2. Enable Code Analyzer warnings
    warning('on', 'all');
    
    % 2. Set up test runner
    if exist('matlab.unittest.TestRunner', 'class')
        fprintf('✅ MATLAB Unit Testing Framework available\n');
    else
        fprintf('⚠️  MATLAB Unit Testing Framework not available\n');
    end
    
    % 3. Check for common issues
    fprintf('\n📋 Running basic code quality checks...\n');
    
    % Check current directory structure
    fprintf('Current directory: %s\n', pwd);
    
    % Look for .m files to analyze
    m_files = dir('**/*.m');
    fprintf('Found %d MATLAB files\n', length(m_files));
    
    % 4. Run mlint on current directory
    try
        issues = mlint('.');
        if isempty(issues)
            fprintf('✅ No mlint issues found\n');
        else
            fprintf('⚠️  Found %d mlint issues\n', length(issues));
            for i = 1:min(5, length(issues))
                fprintf('  - %s\n', issues(i).message);
            end
        end
    catch ME
        fprintf('❌ mlint failed: %s\n', ME.message);
    end
    
    fprintf('\n✅ MATLAB quality configuration complete\n');
end
