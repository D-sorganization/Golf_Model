function [data_table, signal_info] = extractSignalsFromSimOut(simOut, options)
    % External function for extracting signals from simulation output - can be used in parallel processing
    % This function accepts options as a parameter instead of relying on handles
    
    data_table = table();
    signal_info = struct();
    
    try
        % Initialize data sources
        data_sources = {};
        
        % Extract from CombinedSignalBus if enabled
        if options.extract_combined_bus && isfield(simOut, 'CombinedSignalBus')
            try
                combined_bus_data = extractFromCombinedSignalBus(simOut.CombinedSignalBus);
                if ~isempty(combined_bus_data)
                    data_sources{end+1} = combined_bus_data;
                    signal_info.combined_bus = true;
                end
            catch ME
                fprintf('Error extracting CombinedSignalBus data: %s\n', ME.message);
            end
        end
        
        % Extract from logsout if enabled
        if options.extract_logsout && isfield(simOut, 'logsout')
            try
                logsout_data = extractLogsoutDataFixed(simOut.logsout);
                if ~isempty(logsout_data)
                    data_sources{end+1} = logsout_data;
                    signal_info.logsout = true;
                end
            catch ME
                fprintf('Error extracting logsout data: %s\n', ME.message);
            end
        end
        
        % Extract from Simscape logs if enabled
        if options.extract_simscape && isfield(simOut, 'simlog')
            try
                simscape_data = extractSimscapeDataRecursive(simOut.simlog);
                if ~isempty(simscape_data)
                    data_sources{end+1} = simscape_data;
                    signal_info.simscape = true;
                end
            catch ME
                fprintf('Error extracting Simscape data recursively: %s\n', ME.message);
            end
        end
        
        % Combine all data sources
        if ~isempty(data_sources)
            data_table = combineDataSources(data_sources);
        else
            fprintf('No data extracted from any source\n');
        end
        
    catch ME
        fprintf('Error in extractSignalsFromSimOut: %s\n', ME.message);
    end
end 