function test_application_after_cleanup()
    % TEST_APPLICATION_AFTER_CLEANUP - Test the application after removing unused functions
    % This script verifies that the application still works correctly
    
    fprintf('=== Testing Application After Function Cleanup ===\n');
    
    % Get the functions directory
    script_dir = fileparts(mfilename('fullpath'));
    functions_dir = fullfile(script_dir, 'functions');
    
    fprintf('Functions directory: %s\n', functions_dir);
    
    % Check how many functions remain
    if exist(functions_dir, 'dir')
        function_files = dir(fullfile(functions_dir, '*.m'));
        fprintf('Remaining functions: %d\n', length(function_files));
        
        if length(function_files) > 0
            fprintf('Remaining function files:\n');
            for i = 1:length(function_files)
                fprintf('  - %s\n', function_files(i).name);
            end
        end
    else
        fprintf('✗ Functions directory not found!\n');
        return;
    end
    
    % Test 1: Check if all required functions are still available
    fprintf('\n=== Test 1: Function Availability ===\n');
    
    required_functions = {
        'calculateWorkPowerAndGranularAngularImpulse3D',
        'checkStopRequest',
        'ensureEnhancedConfig',
        'extractSignalsFromSimOut',
        'extractSimscapeDataRecursive',
        'generateRandomCoefficients',
        'getPolynomialParameterInfo',
        'getShortenedJointName',
        'loadInputFile',
        'prepareSimulationInputsForBatch',
        'processSimulationOutput',
        'resampleDataToFrequency',
        'restoreWorkspace',
        'runSingleTrial',
        'setModelParameters',
        'setPolynomialCoefficients',
        'shouldShowDebug'
    };
    
    missing_functions = {};
    available_functions = {};
    
    for i = 1:length(required_functions)
        func_name = required_functions{i};
        if exist(func_name, 'file') == 2
            available_functions{end+1} = func_name;
            fprintf('✓ %s - Available\n', func_name);
        else
            missing_functions{end+1} = func_name;
            fprintf('✗ %s - Missing\n', func_name);
        end
    end
    
    fprintf('\nFunction availability: %d/%d available\n', length(available_functions), length(required_functions));
    
    if ~isempty(missing_functions)
        fprintf('✗ Missing required functions:\n');
        for i = 1:length(missing_functions)
            fprintf('  - %s\n', missing_functions{i});
        end
        fprintf('Application will likely fail!\n');
        return;
    else
        fprintf('✓ All required functions are available\n');
    end
    
    % Test 2: Test basic function calls
    fprintf('\n=== Test 2: Basic Function Calls ===\n');
    
    try
        % Test generateRandomCoefficients
        fprintf('Testing generateRandomCoefficients...\n');
        coeffs = generateRandomCoefficients(7);
        fprintf('✓ generateRandomCoefficients returned %d coefficients\n', length(coeffs));
    catch ME
        fprintf('✗ generateRandomCoefficients failed: %s\n', ME.message);
    end
    
    try
        % Test checkStopRequest
        fprintf('Testing checkStopRequest...\n');
        handles = struct();
        handles.should_stop = false;
        result = checkStopRequest(handles);
        fprintf('✓ checkStopRequest returned: %s\n', mat2str(result));
    catch ME
        fprintf('✗ checkStopRequest failed: %s\n', ME.message);
    end
    
    % Test 3: Check for function trace logs
    fprintf('\n=== Test 3: Function Trace Logs ===\n');
    
    trace_files = dir(fullfile(script_dir, 'function_trace_*.log'));
    if ~isempty(trace_files)
        fprintf('Found %d function trace log files:\n', length(trace_files));
        for i = 1:length(trace_files)
            fprintf('  - %s\n', trace_files(i).name);
        end
        
        % Read the most recent trace log
        [~, idx] = max([trace_files.datenum]);
        latest_trace = fullfile(script_dir, trace_files(idx).name);
        
        fprintf('\nReading latest trace log: %s\n', trace_files(idx).name);
        
        fid = fopen(latest_trace, 'r');
        if fid ~= -1
            content = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
            content = content{1};
            fclose(fid);
            
            fprintf('Trace log contains %d lines\n', length(content));
            
            % Check if any removed functions were called
            removed_functions = {
                'extractFromCombinedSignalBus_BROKEN',
                'performance_optimizer',
                'performance_optimizer_functions',
                'performance_analysis',
                'performance_monitor',
                'memory_monitor',
                'setup_performance_preferences',
                'logMessage',
                'logBatchResult',
                'recordBatchTime',
                'recordPhase',
                'endPhase',
                'timestampPrintf',
                'verbosity_control',
                'shouldShowNormal',
                'shouldShowVerbose',
                'getMemoryInfo',
                'getMemoryUsage',
                'checkHighMemoryUsage',
                'checkModelConfiguration',
                'check_model_configuration',
                'checkpoint_recovery',
                'extractAllSignalsFromBus',
                'extractCombinedSignalBusData',
                'extractConstantMatrixData',
                'extractDataFromField',
                'extractDataWithOptions',
                'extractFromCombinedSignalBus',
                'extractFromNestedStruct',
                'extractLogsoutDataFixed',
                'extractTimeSeriesData',
                'extractWorkspaceOutputs',
                'fallbackSimlogExtraction',
                'data_extraction_functions',
                'diagnoseDataExtraction',
                'calculateForceMoments',
                'calculateJointPowerWork',
                'combineDataSources',
                'compressData',
                'mergeTables',
                'compare_headers_detailed',
                'getOrCreateParallelPool',
                'initializeLocalCluster',
                'inspect_simscape_hierarchy',
                'traverseSimlogNode',
                'PostProcessingModule'
            };
            
            called_removed_functions = {};
            for i = 1:length(content)
                line = content{i};
                for j = 1:length(removed_functions)
                    if contains(line, removed_functions{j})
                        called_removed_functions{end+1} = removed_functions{j};
                        fprintf('⚠ WARNING: Removed function %s was called!\n', removed_functions{j});
                    end
                end
            end
            
            if isempty(called_removed_functions)
                fprintf('✓ No removed functions were called during testing\n');
            else
                fprintf('✗ %d removed functions were called - this indicates a problem!\n', length(unique(called_removed_functions)));
            end
        else
            fprintf('✗ Could not read trace log file\n');
        end
    else
        fprintf('No function trace log files found\n');
    end
    
    % Test 4: Test Dataset_GUI startup
    fprintf('\n=== Test 4: Dataset_GUI Startup Test ===\n');
    fprintf('This will test if Dataset_GUI can start without errors\n');
    fprintf('Note: This test will launch the GUI briefly\n');
    
    try
        fprintf('Starting Dataset_GUI...\n');
        % Use a timer to close the GUI after a few seconds
        Dataset_GUI;
        pause(3); % Give it time to start
        fprintf('✓ Dataset_GUI started successfully\n');
        
        % Try to close any open figures
        close all;
        
    catch ME
        fprintf('✗ Dataset_GUI failed to start: %s\n', ME.message);
        fprintf('This indicates that function removal may have broken something\n');
    end
    
    fprintf('\n=== Cleanup Test Summary ===\n');
    if isempty(missing_functions) && isempty(called_removed_functions)
        fprintf('✅ SUCCESS: Function cleanup appears to be successful\n');
        fprintf('All required functions are available and no removed functions were called\n');
    else
        fprintf('❌ ISSUES FOUND: Function cleanup may have problems\n');
        if ~isempty(missing_functions)
            fprintf('- Missing required functions\n');
        end
        if ~isempty(called_removed_functions)
            fprintf('- Removed functions were called\n');
        end
    end
end
