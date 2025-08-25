function remove_unused_functions()
    % REMOVE_UNUSED_FUNCTIONS - Remove unused functions incrementally
    % This script removes functions that are clearly not used, starting with the safest ones
    
    fprintf('=== Removing Unused Functions Incrementally ===\n');
    
    % Get the functions directory
    script_dir = fileparts(mfilename('fullpath'));
    functions_dir = fullfile(script_dir, 'functions');
    
    if ~exist(functions_dir, 'dir')
        fprintf('✗ Functions directory not found: %s\n', functions_dir);
        return;
    end
    
    % Define functions to remove in order of safety (most obviously unused first)
    % These are based on the analysis that showed they're not called from Dataset_GUI.m
    functions_to_remove = {
        % Clearly broken or deprecated functions
        'extractFromCombinedSignalBus_BROKEN',
        
        % Performance/monitoring functions that are not used
        'performance_optimizer',
        'performance_optimizer_functions', 
        'performance_analysis',
        'performance_monitor',
        'memory_monitor',
        'setup_performance_preferences',
        
        % Logging functions that are not used
        'logMessage',
        'logBatchResult',
        'recordBatchTime',
        'recordPhase',
        'endPhase',
        'timestampPrintf',
        
        % Verbosity control functions that are not used
        'verbosity_control',
        'shouldShowNormal',
        'shouldShowVerbose',
        
        % Memory functions that are not used
        'getMemoryInfo',
        'getMemoryUsage',
        'checkHighMemoryUsage',
        
        % Configuration functions that are not used
        'checkModelConfiguration',
        'check_model_configuration',
        'checkpoint_recovery',
        
        % Data extraction functions that are not used
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
        
        % Calculation functions that are not used
        'calculateForceMoments',
        'calculateJointPowerWork',
        
        % Utility functions that are not used
        'combineDataSources',
        'compressData',
        'mergeTables',
        'compare_headers_detailed',
        
        % Parallel processing functions that are not used
        'getOrCreateParallelPool',
        'initializeLocalCluster',
        
        % Inspection functions that are not used
        'inspect_simscape_hierarchy',
        'traverseSimlogNode',
        
        % Post-processing module that is not used
        'PostProcessingModule'
    };
    
    fprintf('Planning to remove %d functions\n', length(functions_to_remove));
    fprintf('These functions were identified as unused in the analysis\n\n');
    
    % Auto-proceed in batch mode
    fprintf('Auto-proceeding with removal in batch mode\n');
    
    removed_count = 0;
    backup_dir = fullfile(script_dir, 'removed_functions_backup');
    
    % Create backup directory
    if ~exist(backup_dir, 'dir')
        mkdir(backup_dir);
    end
    
    for i = 1:length(functions_to_remove)
        func_name = functions_to_remove{i};
        func_file = fullfile(functions_dir, [func_name '.m']);
        
        if exist(func_file, 'file')
            fprintf('Removing: %s\n', func_name);
            
            % Move to backup directory instead of deleting
            backup_file = fullfile(backup_dir, [func_name '.m']);
            movefile(func_file, backup_file);
            
            fprintf('  ✓ Moved to backup: %s\n', backup_file);
            removed_count = removed_count + 1;
        else
            fprintf('  - Not found: %s\n', func_name);
        end
    end
    
    fprintf('\n=== Summary ===\n');
    fprintf('Removed %d functions\n', removed_count);
    fprintf('Backup location: %s\n', backup_dir);
    fprintf('\nNext steps:\n');
    fprintf('1. Test the application to ensure it still works\n');
    fprintf('2. Check function_trace_*.log files to verify no removed functions were called\n');
    fprintf('3. If everything works, the removal was successful\n');
    fprintf('4. If issues occur, restore functions from backup\n');
end
