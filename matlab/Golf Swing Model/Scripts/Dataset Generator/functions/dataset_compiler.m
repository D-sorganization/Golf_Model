function dataset_compiler(config)
    % DATASET_COMPILER - Compile individual trial files into master dataset
    %
    % This function compiles all individual trial CSV files into a master dataset
    % using an optimized three-pass algorithm with proper preallocation.
    %
    % Inputs:
    %   config - Configuration structure with output folder and settings
    %
    % Outputs:
    %   None (saves master dataset to file)
    %
    % Usage:
    %   dataset_compiler(config);
    
    try
        fprintf('Compiling dataset from trials...\n');

        % Find all trial CSV files
        csv_files = dir(fullfile(config.output_folder, 'trial_*.csv'));

        if isempty(csv_files)
            warning('No trial CSV files found in output folder');
            return;
        end

        % OPTIMIZED THREE-PASS ALGORITHM with proper preallocation
        fprintf('Using optimized 3-pass algorithm with preallocation...\n');

        % PASS 1: Discover all unique column names across all files
        fprintf('Pass 1: Discovering columns...\n');
        
        % Preallocate with estimated size (most trials have similar column counts)
        estimated_columns = 2000;  % Updated to handle typical 1956 columns with buffer
        all_unique_columns = cell(estimated_columns, 1);
        valid_files = cell(length(csv_files), 1);
        column_count = 0;
        valid_file_count = 0;
        
        for i = 1:length(csv_files)
            file_path = fullfile(config.output_folder, csv_files(i).name);
            try
                trial_data = readtable(file_path);
                if ~isempty(trial_data)
                    valid_file_count = valid_file_count + 1;
                    valid_files{valid_file_count} = file_path;
                    trial_columns = trial_data.Properties.VariableNames;
                    
                    % Add new columns to unique list
                    for j = 1:length(trial_columns)
                        if ~ismember(trial_columns{j}, all_unique_columns(1:column_count))
                            column_count = column_count + 1;
                            all_unique_columns{column_count} = trial_columns{j};
                        end
                    end
                    
                    fprintf('  Pass 1 - %s: %d columns found\n', csv_files(i).name, length(trial_columns));
                end
            catch ME
                warning('Failed to read %s during discovery: %s', csv_files(i).name, ME.message);
            end
        end
        
        % Trim to actual size
        all_unique_columns = all_unique_columns(1:column_count);
        valid_files = valid_files(1:valid_file_count);
        
        fprintf('  Total unique columns discovered: %d\n', length(all_unique_columns));
        fprintf('  Valid files found: %d\n', valid_file_count);

        % PASS 2: Standardize each trial to have all columns (with NaN for missing)
        fprintf('Pass 2: Standardizing tables...\n');
        standardized_tables = cell(valid_file_count, 1);

        for i = 1:valid_file_count
            file_path = valid_files{i};
            [~, filename, ~] = fileparts(file_path);

            try
                trial_data = readtable(file_path);

                % Create standardized table with all columns
                standardized_table = table();
                for j = 1:length(all_unique_columns)
                    col_name = all_unique_columns{j};
                    if ismember(col_name, trial_data.Properties.VariableNames)
                        standardized_table.(col_name) = trial_data.(col_name);
                    else
                        % Add NaN column for missing data
                        if isa(trial_data, 'table') && height(trial_data) > 0
                            % Determine data type from other columns
                            sample_col = trial_data.Properties.VariableNames{1};
                            sample_data = trial_data.(sample_col);
                            if isnumeric(sample_data)
                                standardized_table.(col_name) = NaN(height(trial_data), 1);
                            else
                                standardized_table.(col_name) = cell(height(trial_data), 1);
                            end
                        else
                            standardized_table.(col_name) = [];
                        end
                    end
                end

                standardized_tables{i} = standardized_table;
                fprintf('  Pass 2 - %s: standardized to %d columns\n', filename, width(standardized_table));

            catch ME
                warning('Failed to standardize %s: %s', filename, ME.message);
                % Create empty table with all columns
                standardized_table = table();
                for j = 1:length(all_unique_columns)
                    col_name = all_unique_columns{j};
                    standardized_table.(col_name) = [];
                end
                standardized_tables{i} = standardized_table;
            end
        end

        % PASS 3: Combine all standardized tables
        fprintf('Pass 3: Combining tables...\n');
        
        % Preallocate master table with estimated size
        total_rows = 0;
        for i = 1:valid_file_count
            if ~isempty(standardized_tables{i})
                total_rows = total_rows + height(standardized_tables{i});
            end
        end
        
        % Create master table
        master_data = table();
        for j = 1:length(all_unique_columns)
            col_name = all_unique_columns{j};
            master_data.(col_name) = [];
        end
        
        % Combine all tables
        for i = 1:valid_file_count
            if ~isempty(standardized_tables{i}) && height(standardized_tables{i}) > 0
                master_data = [master_data; standardized_tables{i}];
            end
        end

        % Save master dataset
        if ~isempty(master_data)
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            master_filename = sprintf('master_dataset_%s.csv', timestamp);
            master_path = fullfile(config.output_folder, master_filename);

            writetable(master_data, master_path);
            fprintf('Master dataset saved: %s\n', master_filename);
            fprintf('  Total rows: %d\n', height(master_data));
            fprintf('  Total columns: %d\n', width(master_data));

            % Also save as MAT file if requested
            if isfield(config, 'file_format') && (config.file_format == 2 || config.file_format == 3)
                mat_filename = sprintf('master_dataset_%s.mat', timestamp);
                mat_path = fullfile(config.output_folder, mat_filename);
                save(mat_path, 'master_data', 'config');
                fprintf('Master dataset saved as MAT: %s\n', mat_filename);
            end
        end

    catch ME
        fprintf('Error compiling dataset: %s\n', ME.message);
    end
end
