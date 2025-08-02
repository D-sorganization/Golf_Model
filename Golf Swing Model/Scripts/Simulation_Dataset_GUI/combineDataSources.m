function combined_table = combineDataSources(data_sources)
    % External function for combining data sources - can be used in parallel processing
    % This function doesn't rely on config.verbosity
    
    combined_table = table();
    
    try
        if isempty(data_sources)
            return;
        end
        
        % Start with the first data source
        combined_table = data_sources{1};
        
        % Merge additional data sources
        for i = 2:length(data_sources)
            try
                source_table = data_sources{i};
                
                if ~isempty(source_table) && height(source_table) == height(combined_table)
                    % Merge tables by adding new columns
                    combined_table = [combined_table, source_table];
                elseif ~isempty(source_table) && height(source_table) ~= height(combined_table)
                    fprintf('Warning: Data source %d has different number of rows (%d vs %d)\n', ...
                        i, height(source_table), height(combined_table));
                end
                
            catch ME
                fprintf('Error merging data source %d: %s\n', i, ME.message);
            end
        end
        
    catch ME
        fprintf('Error combining data sources: %s\n', ME.message);
    end
end 