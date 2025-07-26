function test_panel_by_panel()
    % Test each panel creation function individually to isolate the crash
    fprintf('=== Testing Panel Creation Functions ===\n');
    
    try
        % Create test figure
        fig = figure('Name', 'Panel Test', 'Position', [100, 100, 800, 600], 'Visible', 'off');
        handles = struct();
        handles.should_stop = false;
        handles.trial_table_data = [];
        
        % Create test parent panels
        left_column = uipanel('Parent', fig, 'Position', [0.05, 0.05, 0.4, 0.9]);
        right_column = uipanel('Parent', fig, 'Position', [0.55, 0.05, 0.4, 0.9]);
        
        % Test each panel function one by one
        fprintf('Testing createTrialSettingsPanel... ');
        try
            handles = createTrialSettingsPanel(left_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('Testing createDataSourcesPanel... ');
        try
            handles = createDataSourcesPanel(left_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('Testing createModelingPanel... ');
        try
            handles = createModelingPanel(left_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('Testing createHelpPanel... ');
        try
            handles = createHelpPanel(left_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('Testing createOutputSettingsPanel... ');
        try
            handles = createOutputSettingsPanel(right_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('Testing createTrialTablePanel... ');
        try
            handles = createTrialTablePanel(right_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('Testing createProgressPanel... ');
        try
            handles = createProgressPanel(right_column, handles);
            fprintf('OK\n');
        catch ME
            fprintf('FAILED: %s\n', ME.message);
        end
        
        fprintf('All panel tests completed!\n');
        close(fig);
        
    catch ME
        fprintf('Error in test setup: %s\n', ME.message);
    end
end 