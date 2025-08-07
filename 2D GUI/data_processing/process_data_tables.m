function [BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF)
% PROCESS_DATA_TABLES - Process base and ZTCF data into Q-tables for visualization
%
% Inputs:
%   config - Configuration structure from model_config()
%   BaseData - Base data table from generate_base_data()
%   ZTCF - ZTCF data table from generate_ztcf_data()
%
% Returns:
%   BASEQ - Processed base data table for visualization
%   ZTCFQ - Processed ZTCF data table for visualization
%   DELTAQ - Delta data table (BASEQ - ZTCFQ) for visualization
%
% This function:
%   1. Converts BaseData and ZTCF to timetable format
%   2. Resamples data to consistent time intervals
%   3. Creates DELTAQ as the difference between BASEQ and ZTCFQ
%   4. Returns all three Q-tables ready for visualization

    fprintf('🔄 Processing data tables...\n');
    
    try
        % Convert BaseData to timetable if it's not already
        if ~istimetable(BaseData)
            if ismember('Time', BaseData.Properties.VariableNames)
                BASEQ = table2timetable(BaseData, 'RowTimes', 'Time');
            else
                % Create time vector if not present
                time_vector = (0:height(BaseData)-1) * config.sample_time;
                BaseData.Time = time_vector';
                BASEQ = table2timetable(BaseData, 'RowTimes', 'Time');
            end
        else
            BASEQ = BaseData;
        end
        
        % Convert ZTCF to timetable if it's not already
        if ~istimetable(ZTCF)
            if ismember('Time', ZTCF.Properties.VariableNames)
                ZTCFQ = table2timetable(ZTCF, 'RowTimes', 'Time');
            else
                % Create time vector if not present
                time_vector = (0:height(ZTCF)-1) * config.sample_time;
                ZTCF.Time = time_vector';
                ZTCFQ = table2timetable(ZTCF, 'RowTimes', 'Time');
            end
        else
            ZTCFQ = ZTCF;
        end
        
        % Resample data to consistent time intervals
        fprintf('   Resampling data to consistent time intervals...\n');
        
        % Get the time range that covers both datasets
        start_time = min(BASEQ.Time(1), ZTCFQ.Time(1));
        end_time = max(BASEQ.Time(end), ZTCFQ.Time(end));
        
        % Create uniform time vector
        uniform_time = (start_time:config.sample_time:end_time)';
        
        % Resample BASEQ
        BASEQ = retime(BASEQ, uniform_time, config.interpolation_method);
        
        % Resample ZTCFQ
        ZTCFQ = retime(ZTCFQ, uniform_time, config.interpolation_method);
        
        % Create DELTAQ as the difference between BASEQ and ZTCFQ
        fprintf('   Creating DELTAQ table...\n');
        DELTAQ = BASEQ;
        
        % Get numeric columns for difference calculation
        numeric_vars = varfun(@isnumeric, BASEQ, 'OutputFormat', 'cell');
        numeric_vars = BASEQ.Properties.VariableNames(numeric_vars);
        
        % Calculate differences for numeric columns
        for i = 1:length(numeric_vars)
            var_name = numeric_vars{i};
            if ismember(var_name, ZTCFQ.Properties.VariableNames)
                try
                    DELTAQ.(var_name) = BASEQ.(var_name) - ZTCFQ.(var_name);
                catch
                    % Skip if calculation fails (e.g., different data types)
                    fprintf('   Warning: Could not calculate difference for %s\n', var_name);
                end
            end
        end
        
        % Convert back to table format for consistency
        BASEQ = timetable2table(BASEQ);
        ZTCFQ = timetable2table(ZTCFQ);
        DELTAQ = timetable2table(DELTAQ);
        
        fprintf('✅ Data tables processed successfully\n');
        fprintf('   BASEQ: %d frames\n', height(BASEQ));
        fprintf('   ZTCFQ: %d frames\n', height(ZTCFQ));
        fprintf('   DELTAQ: %d frames\n', height(DELTAQ));
        fprintf('   Time range: %.3f to %.3f seconds\n', BASEQ.Time(1), BASEQ.Time(end));
        
    catch ME
        fprintf('❌ Error processing data tables: %s\n', ME.message);
        rethrow(ME);
    end
    
end
