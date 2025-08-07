function save_data_tables(config, BASE, ZTCF, DELTA, BASEQ, ZTCFQ, DELTAQ, ZVCFTable, ZVCFTableQ)
% SAVE_DATA_TABLES - Save all data tables to files
%
% Inputs:
%   config - Configuration structure from model_config()
%   BASE, ZTCF, DELTA, BASEQ, ZTCFQ, DELTAQ - Data tables
%   ZVCFTable, ZVCFTableQ - ZVCF data tables
%
% This function saves all data tables to the Tables directory

    % Create Tables directory if it doesn't exist
    if ~exist(config.tables_path, 'dir')
        mkdir(config.tables_path);
    end
    
    % Change to Tables directory
    cd(config.tables_path);
    
    fprintf('💾 Saving data tables...\n');
    
    % Save main data tables
    save('BASE.mat', 'BASE');
    save('ZTCF.mat', 'ZTCF');
    save('DELTA.mat', 'DELTA');
    save('BASEQ.mat', 'BASEQ');
    save('ZTCFQ.mat', 'ZTCFQ');
    save('DELTAQ.mat', 'DELTAQ');
    
    % Save ZVCF tables
    save('ZVCFTable.mat', 'ZVCFTable');
    save('ZVCFTableQ.mat', 'ZVCFTableQ');
    
    % Save additional tables if they exist in workspace
    if exist('ClubQuiverAlphaReversal', 'var')
        save('ClubQuiverAlphaReversal.mat', 'ClubQuiverAlphaReversal');
    end
    
    if exist('ClubQuiverMaxCHS', 'var')
        save('ClubQuiverMaxCHS.mat', 'ClubQuiverMaxCHS');
    end
    
    if exist('ClubQuiverZTCFAlphaReversal', 'var')
        save('ClubQuiverZTCFAlphaReversal.mat', 'ClubQuiverZTCFAlphaReversal');
    end
    
    if exist('ClubQuiverDELTAAlphaReversal', 'var')
        save('ClubQuiverDELTAAlphaReversal.mat', 'ClubQuiverDELTAAlphaReversal');
    end
    
    if exist('SummaryTable', 'var')
        save('SummaryTable.mat', 'SummaryTable');
    end
    
    fprintf('✅ Data tables saved successfully to: %s\n', config.tables_path);
    
end
