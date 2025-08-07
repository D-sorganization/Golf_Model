function [BASE, ZTCF, DELTA, BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF)
% PROCESS_DATA_TABLES - Process and interpolate data tables
%
% Inputs:
%   config - Configuration structure from model_config()
%   BaseData - Base data table from generate_base_data()
%   ZTCF - ZTCF data table from generate_ztcf_data()
%
% Returns:
%   BASE, ZTCF, DELTA - Processed data tables
%   BASEQ, ZTCFQ, DELTAQ - Q-spaced data tables
%
% This function:
%   1. Converts tables to timetables
%   2. Interpolates data to match time points
%   3. Calculates DELTA (difference between BASE and ZTCF)
%   4. Creates uniformly spaced versions (Q tables)

    fprintf('🔄 Processing data tables...\n');
    
    % Generate duration times for each table
    BaseDataTime = seconds(BaseData.Time);
    ZTCFTime = seconds(ZTCF.Time);
    
    % Create temporary tables for modification
    BaseDataTemp = BaseData;
    ZTCFTemp = ZTCF;
    
    % Write duration times into the tables
    BaseDataTemp.('t') = BaseDataTime;
    ZTCFTemp.('t') = ZTCFTime;
    
    % Create timetables
    BaseDataTimetableTemp = table2timetable(BaseDataTemp, "RowTimes", "t");
    ZTCFTimetableTemp = table2timetable(ZTCFTemp, "RowTimes", "t");
    
    % Remove the remaining time variable
    BaseDataTimetable = removevars(BaseDataTimetableTemp, 'Time');
    ZTCFTimetable = removevars(ZTCFTimetableTemp, 'Time');
    
    % Generate matched set using interpolation
    BaseDataMatched = retime(BaseDataTimetable, ZTCFTime, config.interpolation_method);
    
    % Generate DELTA
    DELTATimetable = BaseDataMatched - ZTCFTimetable;
    
    % Define sample time and create uniform tables
    Ts = config.sample_time;
    
    BASEUniform = retime(BaseDataMatched, 'regular', config.interpolation_method, 'TimeStep', seconds(Ts));
    ZTCFUniform = retime(ZTCFTimetable, 'regular', config.interpolation_method, 'TimeStep', seconds(Ts));
    DELTAUniform = retime(DELTATimetable, 'regular', config.interpolation_method, 'TimeStep', seconds(Ts));
    
    % Convert back to tables
    DELTA = timetable2table(DELTAUniform, "ConvertRowTimes", true);
    DELTA = renamevars(DELTA, "t", "Time");
    
    BASE = timetable2table(BASEUniform, "ConvertRowTimes", true);
    BASE = renamevars(BASE, "t", "Time");
    
    ZTCF = timetable2table(ZTCFUniform, "ConvertRowTimes", true);
    ZTCF = renamevars(ZTCF, "t", "Time");
    
    % Convert time vectors back to normal time
    BASETime = seconds(BASE.Time);
    BASE.Time = BASETime;
    
    DELTATime = seconds(DELTA.Time);
    DELTA.Time = DELTATime;
    
    ZTCFTime = seconds(ZTCF.Time);
    ZTCF.Time = ZTCFTime;
    
    % Create Q tables (copy for now, will be updated by other scripts)
    BASEQ = BASE;
    ZTCFQ = ZTCF;
    DELTAQ = DELTA;
    
    fprintf('✅ Data tables processed successfully\n');
    fprintf('   BASE points: %d\n', height(BASE));
    fprintf('   ZTCF points: %d\n', height(ZTCF));
    fprintf('   DELTA points: %d\n', height(DELTA));
    
end
