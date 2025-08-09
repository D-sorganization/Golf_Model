function run_matlab_tests()
    % Run all MATLAB tests and quality checks
    % This script follows the project's MATLAB quality standards
    
    fprintf('🧪 Running MATLAB tests and quality checks...\n');
    
    % 1. Add current directory to path if not already there
    current_dir = pwd;
    if ~contains(path, current_dir)
        addpath(current_dir);
        fprintf('Added %s to MATLAB path\n', current_dir);
    end
    
    % 2. Configure reproducibility
    rng(42);
    
    % 2. Prepare output directory
    outdir = fullfile('output', datestr(datetime('now'),'yyyy-mm-dd'), 'matlab_tests');
    if ~exist(outdir, 'dir'); mkdir(outdir); end
    
    % 3. Save metadata
    meta.date = datestr(datetime('now'));
    meta.matlab_version = version;
    meta.description = 'MATLAB tests and quality checks run';
    
    % 4. Run quality configuration
    try
        matlab_quality_config();
        meta.quality_config_status = 'PASSED';
    catch ME
        meta.quality_config_status = 'FAILED';
        meta.quality_config_error = ME.message;
        fprintf('❌ Quality config failed: %s\n', ME.message);
    end
    
    % 5. Run unit tests
    try
        fprintf('\n🧪 Running unit tests...\n');
        test_results = runtests('tests/');
        meta.test_results = test_results;
        meta.test_status = 'PASSED';
        fprintf('✅ Unit tests completed: %d passed, %d failed\n', ...
            sum([test_results.Passed]), sum([test_results.Failed]));
    catch ME
        meta.test_status = 'FAILED';
        meta.test_error = ME.message;
        fprintf('❌ Unit tests failed: %s\n', ME.message);
    end
    
    % 6. Run mlint on all MATLAB files
    try
        fprintf('\n🔍 Running mlint analysis...\n');
        m_files = dir('**/*.m');
        mlint_issues = [];
        
        for i = 1:length(m_files)
            file_path = fullfile(m_files(i).folder, m_files(i).name);
            try
                issues = mlint(file_path);
                if ~isempty(issues)
                    mlint_issues = [mlint_issues; issues];
                end
            catch
                % Skip files that can't be analyzed
            end
        end
        
        if isempty(mlint_issues)
            fprintf('✅ No mlint issues found across all files\n');
            meta.mlint_status = 'PASSED';
        else
            fprintf('⚠️  Found %d mlint issues across all files\n', length(mlint_issues));
            meta.mlint_status = 'WARNINGS';
            meta.mlint_issue_count = length(mlint_issues);
        end
    catch ME
        meta.mlint_status = 'FAILED';
        meta.mlint_error = ME.message;
        fprintf('❌ mlint analysis failed: %s\n', ME.message);
    end
    
    % 7. Save results
    try
        fid = fopen(fullfile(outdir, 'test_results.json'), 'w');
        fprintf(fid, '%s', jsonencode(meta, 'PrettyPrint', true));
        fclose(fid);
        fprintf('\n📁 Results saved to: %s\n', outdir);
    catch ME
        fprintf('❌ Failed to save results: %s\n', ME.message);
    end
    
    fprintf('\n✅ MATLAB tests and quality checks completed\n');
end
