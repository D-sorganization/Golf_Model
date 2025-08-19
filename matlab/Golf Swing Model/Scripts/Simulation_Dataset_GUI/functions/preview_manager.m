function preview_manager(handles, action, varargin)
    % PREVIEW_MANAGER - Manage preview and display functions for the GUI
    %
    % This function handles updating preview displays, coefficients preview,
    % and creating preview table data.
    %
    % Inputs:
    %   handles - GUI handles structure
    %   action - Action to perform: 'update_preview', 'update_coefficients', 
    %            'update_coefficients_and_save', 'create_table_data'
    %   varargin - Additional arguments depending on action
    %
    % Outputs:
    %   None (updates GUI displays)
    %
    % Usage:
    %   preview_manager(handles, 'update_preview');
    %   preview_manager(handles, 'update_coefficients');
    %   preview_manager(handles, 'update_coefficients_and_save');
    %   table_data = preview_manager(handles, 'create_table_data');
    
    switch lower(action)
        case 'update_preview'
            updatePreview(handles);
        case 'update_coefficients'
            updateCoefficientsPreview(handles);
        case 'update_coefficients_and_save'
            updateCoefficientsPreviewAndSave(handles);
        case 'create_table_data'
            table_data = createPreviewTableData(handles);
            if nargout > 0
                varargout{1} = table_data;
            end
        otherwise
            error('Unknown action: %s', action);
    end
end

function updatePreview(handles)
    % UPDATEPREVIEW - Update the preview table with current settings
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Collect current settings
        num_trials = str2double(get(handles.num_simulations_edit, 'String'));
        sim_time = str2double(get(handles.stop_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coefficient_range_edit, 'String'));
        constant_value = 10.0; % Default constant value

        % Create preview data
        preview_data = {
            'Number of Trials', num2str(num_trials), 'Total simulations to run';
            'Simulation Time', [num2str(sim_time) ' s'], 'Duration of each simulation';
            'Sample Rate', [num2str(sample_rate) ' Hz'], 'Data sampling frequency';
            'Modeling Mode', '3 (Hex Polynomial)', 'Polynomial input function mode';
            'Torque Scenario', get(handles.torque_scenario_popup, 'String'), 'Joint torque generation method';
        };

        % Add scenario-specific parameters
        switch scenario_idx
            case 1 % Variable Torques
                preview_data = [preview_data; {'Coefficient Range', num2str(coeff_range), 'Random variation range for all coefficients'}];
            case 2 % Zero Torque
                preview_data = [preview_data; {'All Coefficients', '0', 'No joint torques applied'}];
            case 3 % Constant Torque
                preview_data = [preview_data; {'Constant Value', num2str(constant_value), 'G coefficient value (A-F=0)'}];
        end

        % Add data sources
        data_sources = {};
        if get(handles.capture_workspace_checkbox, 'Value')
            data_sources{end+1} = 'Model Workspace';
        end
        if get(handles.use_logsout_checkbox, 'Value')
            data_sources{end+1} = 'Logsout';
        end
        if get(handles.use_signal_bus_checkbox, 'Value')
            data_sources{end+1} = 'Signal Bus';
        end
        if get(handles.use_simscape_checkbox, 'Value')
            data_sources{end+1} = 'Simscape';
        end

        if ~isempty(data_sources)
            data_source_str = strjoin(data_sources, ', ');
            preview_data = [preview_data; {'Data Sources', data_source_str, 'Data extraction methods'}];
        end

        % Add scenario-specific info
        if scenario_idx == 1
            preview_data = [preview_data; {
                'Coefficient Range', ['±' num2str(coeff_range)], 'Random variation bounds'
            }];
        elseif scenario_idx == 3
            preview_data = [preview_data; {
                'Constant Value', num2str(constant_value), 'G coefficient value'
            }];
        end

        % Add data sampling info
        expected_points = round(sim_time * sample_rate);
        preview_data = [preview_data; {
            'Expected Data Points', num2str(expected_points), 'Per trial after resampling'
        }];

        % Add output info
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        preview_data = [preview_data; {
            'Output Location', fullfile(output_folder, folder_name), 'File destination'
        }];

        set(handles.preview_table, 'Data', preview_data);

    catch ME
        error_data = {'Error', 'Check inputs', ME.message};
        set(handles.preview_table, 'Data', error_data);
    end
end

function updateCoefficientsPreview(handles)
    % UPDATECOEFFICIENTSPREVIEW - Update coefficients preview table
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Get current settings
        num_trials = str2double(get(handles.num_simulations_edit, 'String'));
        if isnan(num_trials) || num_trials <= 0
            num_trials = 5;
        end
        display_trials = num_trials; % Show all trials
        % Use actual num_trials for simulation, display_trials for preview

        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coefficient_range_edit, 'String'));
        constant_value = 10.0; % Default constant value since we removed the input field

        % Get parameter info
        param_info = getPolynomialParameterInfo();
        total_columns = 1 + param_info.total_params;

        % Generate coefficient data for display (limited to 100 for performance)
        coeff_data = cell(display_trials, total_columns);

        for i = 1:display_trials
            coeff_data{i, 1} = i; % Trial number

            col_idx = 2;
            for joint_idx = 1:length(param_info.joint_names)
                joint_name = param_info.joint_names{joint_idx};
                coeffs = param_info.joint_coeffs{joint_idx};

                for coeff_idx = 1:length(coeffs)
                    coeff_name = coeffs(coeff_idx);
                    coeff_value = 0;

                    % Generate coefficient value based on scenario
                    switch scenario_idx
                        case 1 % Variable Torques
                            coeff_value = (rand() - 0.5) * 2 * coeff_range;
                        case 2 % Zero Torque
                            coeff_value = 0;
                        case 3 % Constant Torque
                            if coeff_name == 'G'
                                coeff_value = constant_value;
                            else
                                coeff_value = 0;
                            end
                    end

                    coeff_data{i, col_idx} = sprintf('%.3f', coeff_value);
                    col_idx = col_idx + 1;
                end
            end
        end

        % Update table
        set(handles.coefficients_table, 'Data', coeff_data);
        handles.edited_cells = {}; % Clear edit tracking

        % Store original data
        handles.original_coefficients_data = coeff_data;
        handles.original_coefficients_columns = get(handles.coefficients_table, 'ColumnName');
        guidata(handles.fig, handles);

    catch ME
        fprintf('Error in updateCoefficientsPreview: %s\n', ME.message);
    end
end

function updateCoefficientsPreviewAndSave(handles)
    % UPDATECOEFFICIENTSPREVIEWANDSAVE - Update coefficients preview and save preferences
    %
    % Inputs:
    %   handles - GUI handles structure
    
    % Update coefficients preview
    updateCoefficientsPreview(handles);
    
    % Save preferences after updating
    configuration_manager(handles, 'save_preferences');
end

function table_data = createPreviewTableData(handles)
    % CREATEPREVIEWTABLEDATA - Create preview table data structure
    %
    % Inputs:
    %   handles - GUI handles structure
    %
    % Outputs:
    %   table_data - Cell array with preview data
    
    try
        % Collect current settings
        num_trials = str2double(get(handles.num_simulations_edit, 'String'));
        sim_time = str2double(get(handles.stop_time_edit, 'String'));
        sample_rate = str2double(get(handles.sample_rate_edit, 'String'));
        scenario_idx = get(handles.torque_scenario_popup, 'Value');
        coeff_range = str2double(get(handles.coefficient_range_edit, 'String'));
        constant_value = 10.0; % Default constant value

        % Create preview data
        table_data = {
            'Number of Trials', num2str(num_trials), 'Total simulations to run';
            'Simulation Time', [num2str(sim_time) ' s'], 'Duration of each simulation';
            'Sample Rate', [num2str(sample_rate) ' Hz'], 'Data sampling frequency';
            'Modeling Mode', '3 (Hex Polynomial)', 'Polynomial input function mode';
            'Torque Scenario', get(handles.torque_scenario_popup, 'String'), 'Joint torque generation method';
        };

        % Add scenario-specific parameters
        switch scenario_idx
            case 1 % Variable Torques
                table_data = [table_data; {'Coefficient Range', num2str(coeff_range), 'Random variation range for all coefficients'}];
            case 2 % Zero Torque
                table_data = [table_data; {'All Coefficients', '0', 'No joint torques applied'}];
            case 3 % Constant Torque
                table_data = [table_data; {'Constant Value', num2str(constant_value), 'G coefficient value (A-F=0)'}];
        end

        % Add data sources
        data_sources = {};
        if get(handles.capture_workspace_checkbox, 'Value')
            data_sources{end+1} = 'Model Workspace';
        end
        if get(handles.use_logsout_checkbox, 'Value')
            data_sources{end+1} = 'Logsout';
        end
        if get(handles.use_signal_bus_checkbox, 'Value')
            data_sources{end+1} = 'Signal Bus';
        end
        if get(handles.use_simscape_checkbox, 'Value')
            data_sources{end+1} = 'Simscape';
        end

        if ~isempty(data_sources)
            data_source_str = strjoin(data_sources, ', ');
            table_data = [table_data; {'Data Sources', data_source_str, 'Data extraction methods'}];
        end

        % Add scenario-specific info
        if scenario_idx == 1
            table_data = [table_data; {
                'Coefficient Range', ['±' num2str(coeff_range)], 'Random variation bounds'
            }];
        elseif scenario_idx == 3
            table_data = [table_data; {
                'Constant Value', num2str(constant_value), 'G coefficient value'
            }];
        end

        % Add data sampling info
        expected_points = round(sim_time * sample_rate);
        table_data = [table_data; {
            'Expected Data Points', num2str(expected_points), 'Per trial after resampling'
        }];

        % Add output info
        output_folder = get(handles.output_folder_edit, 'String');
        folder_name = get(handles.folder_name_edit, 'String');
        table_data = [table_data; {
            'Output Location', fullfile(output_folder, folder_name), 'File destination'
        }];

    catch ME
        table_data = {'Error', 'Check inputs', ME.message};
    end
end
