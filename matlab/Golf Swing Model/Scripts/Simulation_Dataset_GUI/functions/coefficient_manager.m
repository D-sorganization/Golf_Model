function coefficient_manager(handles, action, varargin)
    % COEFFICIENT_MANAGER - Manage coefficient operations for the GUI
    %
    % This function handles coefficient editing, validation, and management
    % operations for the simulation parameters.
    %
    % Inputs:
    %   handles - GUI handles structure
    %   action - Action to perform: 'update_joint', 'validate_input', 'apply_joint', 
    %            'load_joint', 'reset_coefficients', 'cell_edit', 'apply_row', 
    %            'export_csv', 'import_csv', 'save_scenario', 'load_scenario',
    %            'search_coefficients', 'clear_search'
    %   varargin - Additional arguments depending on action
    %
    % Outputs:
    %   None (updates GUI and handles structure)
    %
    % Usage:
    %   coefficient_manager(handles, 'update_joint');
    %   coefficient_manager(handles, 'validate_input', src);
    %   coefficient_manager(handles, 'apply_joint');
    %   coefficient_manager(handles, 'load_joint');
    %   coefficient_manager(handles, 'reset_coefficients');
    
    switch lower(action)
        case 'update_joint'
            updateJointCoefficients(handles);
        case 'validate_input'
            if nargin >= 3
                src = varargin{1};
                validateCoefficientInput(src);
            else
                error('Source object required for validate_input action');
            end
        case 'apply_joint'
            applyJointToTable(handles);
        case 'load_joint'
            loadJointFromTable(handles);
        case 'reset_coefficients'
            resetCoefficientsToGenerated(handles);
        case 'cell_edit'
            if nargin >= 3
                src = varargin{1};
                evt = varargin{2};
                coefficientCellEditCallback(src, evt, handles);
            else
                error('Source and event required for cell_edit action');
            end
        case 'apply_row'
            applyRowToAll(handles);
        case 'export_csv'
            exportCoefficientsToCSV(handles);
        case 'import_csv'
            importCoefficientsFromCSV(handles);
        case 'save_scenario'
            saveScenario(handles);
        case 'load_scenario'
            loadScenario(handles);
        case 'search_coefficients'
            searchCoefficients(handles);
        case 'clear_search'
            clearSearch(handles);
        otherwise
            error('Unknown action: %s', action);
    end
end

function updateJointCoefficients(handles)
    % UPDATEJOINTCOEFFICIENTS - Update joint coefficients display
    %
    % Inputs:
    %   handles - GUI handles structure
    
    selected_idx = get(handles.joint_selector, 'Value');
    joint_names = get(handles.joint_selector, 'String');

    % Load coefficients from table if available
    loadJointFromTable(handles);

    % Update status
    set(handles.joint_status, 'String', sprintf('Ready - %s selected', joint_names{selected_idx}));
    guidata(handles.fig, handles);
end

function updateTrialSelectionMode(handles)
    % UPDATETRIALSELECTIONMODE - Update trial selection mode
    %
    % Inputs:
    %   handles - GUI handles structure
    
    selection_idx = get(handles.trial_selection_popup, 'Value');

    if selection_idx == 1 % All Trials
        set(handles.trial_number_edit, 'Enable', 'off');
    else % Specific Trial
        set(handles.trial_number_edit, 'Enable', 'on');
    end

    guidata(handles.fig, handles);
end

function validateCoefficientInput(src)
    % VALIDATECOEFFICIENTINPUT - Validate coefficient input value
    %
    % Inputs:
    %   src - Source object (edit control)
    
    value = get(src, 'String');
    num_value = str2double(value);

    if isnan(num_value)
        set(src, 'String', '0.00');
        msgbox('Please enter a valid number', 'Invalid Input', 'warn');
    else
        set(src, 'String', sprintf('%.2f', num_value));
    end
end

function applyJointToTable(handles)
    % APPLYJOINTTOTABLE - Apply joint coefficients to table
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Get selected joint
        joint_idx = get(handles.joint_selector, 'Value');
        param_info = handles.param_info;

        % Get coefficient values
        coeff_values = zeros(1, 7);
        for i = 1:7
            coeff_values(i) = str2double(get(handles.joint_coeff_edits(i), 'String'));
        end

        % Get current table data
        table_data = get(handles.coefficients_table, 'Data');

        % Determine which trials to apply to
        apply_mode = get(handles.trial_selection_popup, 'Value');
        if apply_mode == 1 % All Trials
            trials = 1:size(table_data, 1);
        else % Specific Trial
            trial_num = str2double(get(handles.trial_number_edit, 'String'));
            if isnan(trial_num) || trial_num < 1 || trial_num > size(table_data, 1)
                msgbox('Invalid trial number', 'Error', 'error');
                return;
            end
            trials = trial_num;
        end

        % Calculate column indices
        col_start = 2 + (joint_idx - 1) * 7;

        % Apply values
        for trial = trials
            for i = 1:7
                table_data{trial, col_start + i - 1} = sprintf('%.2f', coeff_values(i));
            end
        end

        % Update table
        set(handles.coefficients_table, 'Data', table_data);

        % Update status
        if apply_mode == 1
            status_msg = sprintf('Applied %s coefficients to all trials', param_info.joint_names{joint_idx});
        else
            status_msg = sprintf('Applied %s coefficients to trial %d', param_info.joint_names{joint_idx}, trials);
        end
        set(handles.joint_status, 'String', status_msg);

    catch ME
        msgbox(sprintf('Error applying coefficients: %s', ME.message), 'Error', 'error');
    end
end

function loadJointFromTable(handles)
    % LOADJOINTFROMTABLE - Load joint coefficients from table
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Get selected joint
        joint_idx = get(handles.joint_selector, 'Value');

        % Get table data
        table_data = get(handles.coefficients_table, 'Data');

        if isempty(table_data)
            return;
        end

        % Determine which trial to load from
        apply_mode = get(handles.trial_selection_popup, 'Value');
        if apply_mode == 2 % Specific Trial
            trial_num = str2double(get(handles.trial_number_edit, 'String'));
            if isnan(trial_num) || trial_num < 1 || trial_num > size(table_data, 1)
                trial_num = 1;
            end
        else
            trial_num = 1; % Default to first trial
        end

        % Calculate column indices
        col_start = 2 + (joint_idx - 1) * 7;

        % Load values
        for i = 1:7
            value_str = table_data{trial_num, col_start + i - 1};
            if ischar(value_str)
                value = str2double(value_str);
            else
                value = value_str;
            end
            set(handles.joint_coeff_edits(i), 'String', sprintf('%.2f', value));
        end

    catch ME
        % Silently fail or set defaults
        for i = 1:7
            set(handles.joint_coeff_edits(i), 'String', '0.00');
        end
    end
end

function resetCoefficientsToGenerated(handles)
    % RESETCOEFFICIENTSTOGENERATED - Reset coefficients to generated values
    %
    % Inputs:
    %   handles - GUI handles structure
    
    if isfield(handles, 'original_coefficients_data')
        set(handles.coefficients_table, 'Data', handles.original_coefficients_data);
        handles.edited_cells = {};
        guidata(handles.fig, handles);
        msgbox('Coefficients reset to generated values', 'Reset Complete', 'help');
    else
        preview_manager(handles, 'update_coefficients');
    end
end

function coefficientCellEditCallback(src, evt, handles)
    % COEFFICIENTCELLEDITCALLBACK - Handle coefficient table cell edits
    %
    % Inputs:
    %   src - Source object (table)
    %   evt - Event data
    %   handles - GUI handles structure
    
    try
        % Get edit information
        row = evt.Indices(1);
        col = evt.Indices(2);
        new_value = evt.NewData;

        % Validate input
        if ischar(new_value)
            num_value = str2double(new_value);
            if isnan(num_value)
                % Revert to old value
                table_data = get(src, 'Data');
                table_data{row, col} = evt.PreviousData;
                set(src, 'Data', table_data);
                msgbox('Please enter a valid number', 'Invalid Input', 'warn');
                return;
            end
            new_value = num_value;
        end

        % Store edit information
        if ~isfield(handles, 'edited_cells')
            handles.edited_cells = {};
        end

        edit_info = struct();
        edit_info.row = row;
        edit_info.col = col;
        edit_info.old_value = evt.PreviousData;
        edit_info.new_value = new_value;
        edit_info.timestamp = now();

        handles.edited_cells{end+1} = edit_info;

        % Update table with formatted value
        table_data = get(src, 'Data');
        table_data{row, col} = sprintf('%.3f', new_value);
        set(src, 'Data', table_data);

        guidata(handles.fig, handles);

    catch ME
        fprintf('Error in coefficient cell edit: %s\n', ME.message);
    end
end

function applyRowToAll(handles)
    % APPLYROWTOALL - Apply a row's coefficients to all trials
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Get selected row
        table_data = get(handles.coefficients_table, 'Data');
        if isempty(table_data)
            return;
        end

        % Get row selection (this would need to be implemented based on GUI)
        selected_row = 1; % Default to first row

        % Apply row to all other rows
        for row = 1:size(table_data, 1)
            if row ~= selected_row
                for col = 2:size(table_data, 2) % Skip trial number column
                    table_data{row, col} = table_data{selected_row, col};
                end
            end
        end

        % Update table
        set(handles.coefficients_table, 'Data', table_data);
        msgbox('Row applied to all trials', 'Apply Complete', 'help');

    catch ME
        msgbox(sprintf('Error applying row: %s', ME.message), 'Error', 'error');
    end
end

function exportCoefficientsToCSV(handles)
    % EXPORTCOEFFICIENTSTOCSV - Export coefficients table to CSV
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        [filename, pathname] = uiputfile('*.csv', 'Export Coefficients');
        if filename ~= 0
            table_data = get(handles.coefficients_table, 'Data');
            column_names = get(handles.coefficients_table, 'ColumnName');
            
            % Create table
            coeff_table = cell2table(table_data, 'VariableNames', column_names);
            
            % Save to CSV
            file_path = fullfile(pathname, filename);
            writetable(coeff_table, file_path);
            
            msgbox(sprintf('Coefficients exported to: %s', file_path), 'Export Complete', 'help');
        end
    catch ME
        msgbox(sprintf('Error exporting coefficients: %s', ME.message), 'Error', 'error');
    end
end

function importCoefficientsFromCSV(handles)
    % IMPORTCOEFFICIENTSFROMCSV - Import coefficients from CSV
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        [filename, pathname] = uigetfile('*.csv', 'Import Coefficients');
        if filename ~= 0
            file_path = fullfile(pathname, filename);
            
            % Read CSV
            coeff_table = readtable(file_path);
            
            % Convert to cell array
            table_data = table2cell(coeff_table);
            
            % Update table
            set(handles.coefficients_table, 'Data', table_data);
            set(handles.coefficients_table, 'ColumnName', coeff_table.Properties.VariableNames);
            
            msgbox(sprintf('Coefficients imported from: %s', file_path), 'Import Complete', 'help');
        end
    catch ME
        msgbox(sprintf('Error importing coefficients: %s', ME.message), 'Error', 'error');
    end
end

function saveScenario(handles)
    % SAVESCENARIO - Save current coefficient scenario
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        [filename, pathname] = uiputfile('*.mat', 'Save Scenario');
        if filename ~= 0
            scenario_data = struct();
            scenario_data.coefficients = get(handles.coefficients_table, 'Data');
            scenario_data.column_names = get(handles.coefficients_table, 'ColumnName');
            scenario_data.timestamp = now();
            scenario_data.description = 'Coefficient scenario';
            
            file_path = fullfile(pathname, filename);
            save(file_path, 'scenario_data');
            
            msgbox(sprintf('Scenario saved to: %s', file_path), 'Save Complete', 'help');
        end
    catch ME
        msgbox(sprintf('Error saving scenario: %s', ME.message), 'Error', 'error');
    end
end

function loadScenario(handles)
    % LOADSCENARIO - Load coefficient scenario
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        [filename, pathname] = uigetfile('*.mat', 'Load Scenario');
        if filename ~= 0
            file_path = fullfile(pathname, filename);
            
            % Load scenario data
            loaded_data = load(file_path);
            if isfield(loaded_data, 'scenario_data')
                scenario_data = loaded_data.scenario_data;
                
                % Update table
                set(handles.coefficients_table, 'Data', scenario_data.coefficients);
                if isfield(scenario_data, 'column_names')
                    set(handles.coefficients_table, 'ColumnName', scenario_data.column_names);
                end
                
                msgbox(sprintf('Scenario loaded from: %s', file_path), 'Load Complete', 'help');
            else
                msgbox('Invalid scenario file', 'Error', 'error');
            end
        end
    catch ME
        msgbox(sprintf('Error loading scenario: %s', ME.message), 'Error', 'error');
    end
end

function searchCoefficients(handles)
    % SEARCHCOEFFICIENTS - Search coefficients table
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Get search term from GUI (this would need to be implemented based on GUI)
        search_term = 'test'; % Placeholder
        
        % Get table data
        table_data = get(handles.coefficients_table, 'Data');
        
        % Search logic would be implemented here
        % For now, just show a message
        msgbox(sprintf('Search for: %s (not implemented)', search_term), 'Search', 'help');
        
    catch ME
        msgbox(sprintf('Error searching coefficients: %s', ME.message), 'Error', 'error');
    end
end

function clearSearch(handles)
    % CLEARSEARCH - Clear coefficient search
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Clear search functionality would be implemented here
        msgbox('Search cleared', 'Clear Search', 'help');
        
    catch ME
        msgbox(sprintf('Error clearing search: %s', ME.message), 'Error', 'error');
    end
end
