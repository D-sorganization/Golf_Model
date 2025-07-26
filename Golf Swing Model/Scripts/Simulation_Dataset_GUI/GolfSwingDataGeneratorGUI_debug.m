function GolfSwingDataGeneratorGUI_debug()
    % Debug version of GolfSwingDataGeneratorGUI with extensive error handling
    
    fprintf('DEBUG: Starting GolfSwingDataGeneratorGUI_debug\n');
    
    try
        % Create main figure with modern styling
        fprintf('DEBUG: Creating figure...\n');
        fig = figure('Name', 'Golf Swing Data Generator - Debug', ...
                     'Position', [50, 50, 1400, 900], ...
                     'MenuBar', 'none', ...
                     'ToolBar', 'none', ...
                     'Resize', 'on', ...
                     'Color', [0.96, 0.96, 0.98], ...
                     'NumberTitle', 'off');
        fprintf('DEBUG: Figure created successfully\n');
        
        % Initialize handles structure
        fprintf('DEBUG: Initializing handles structure...\n');
        handles = struct();
        handles.should_stop = false;
        handles.trial_table_data = [];
        fprintf('DEBUG: Handles initialized\n');
        
        % Store handles in figure before creating layout
        fprintf('DEBUG: Storing handles with guidata...\n');
        try
            guidata(fig, handles);
            fprintf('DEBUG: guidata successful\n');
        catch ME
            fprintf('ERROR in guidata: %s\n', ME.message);
            rethrow(ME);
        end
        
        % Create main layout with panels
        fprintf('DEBUG: Creating main layout...\n');
        try
            createMainLayout_debug(fig, handles);
            fprintf('DEBUG: Main layout created successfully\n');
        catch ME
            fprintf('ERROR in createMainLayout: %s\n', ME.message);
            fprintf('Stack trace:\n');
            for i = 1:length(ME.stack)
                fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
            rethrow(ME);
        end
        
        fprintf('DEBUG: GUI initialization complete!\n');
        
    catch ME
        fprintf('\n=== CAUGHT EXCEPTION ===\n');
        fprintf('Message: %s\n', ME.message);
        fprintf('Identifier: %s\n', ME.identifier);
        fprintf('\nStack Trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  In %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        fprintf('\nFull Report:\n');
        disp(getReport(ME, 'extended', 'hyperlinks', 'off'));
        
        % Re-throw to see if this is where "unknown type" comes from
        rethrow(ME);
    end
end

function createMainLayout_debug(fig, handles)
    % Debug version of createMainLayout
    
    fprintf('  DEBUG: Starting createMainLayout_debug\n');
    
    % Title panel with gradient effect
    fprintf('  DEBUG: Creating title panel...\n');
    try
        title_panel = uipanel('Parent', fig, ...
                             'Title', '', ...
                             'Position', [20, 830, 1360, 60], ...
                             'BackgroundColor', [0.2, 0.4, 0.8], ...
                             'BorderType', 'none');
        fprintf('  DEBUG: Title panel created\n');
    catch ME
        fprintf('  ERROR creating title panel: %s\n', ME.message);
        rethrow(ME);
    end
    
    % Title text
    fprintf('  DEBUG: Creating title text...\n');
    try
        uicontrol('Parent', title_panel, ...
                  'Style', 'text', ...
                  'String', 'Golf Swing Data Generator - Debug Version', ...
                  'Position', [20, 20, 800, 30], ...
                  'FontSize', 18, ...
                  'FontWeight', 'bold', ...
                  'ForegroundColor', 'white', ...
                  'BackgroundColor', [0.2, 0.4, 0.8], ...
                  'HorizontalAlignment', 'left');
        fprintf('  DEBUG: Title text created\n');
    catch ME
        fprintf('  ERROR creating title text: %s\n', ME.message);
        rethrow(ME);
    end
    
    % Main panel
    fprintf('  DEBUG: Creating main panel...\n');
    try
        main_panel = uipanel('Parent', fig, ...
                            'Position', [20, 50, 1360, 770], ...
                            'BackgroundColor', [0.96, 0.96, 0.98]);
        fprintf('  DEBUG: Main panel created\n');
    catch ME
        fprintf('  ERROR creating main panel: %s\n', ME.message);
        rethrow(ME);
    end
    
    % Add a simple test button
    fprintf('  DEBUG: Adding test button...\n');
    try
        uicontrol('Parent', main_panel, ...
                  'Style', 'pushbutton', ...
                  'String', 'Test Button - Click Me', ...
                  'Position', [550, 350, 200, 50], ...
                  'FontSize', 12, ...
                  'Callback', @(~,~) fprintf('Test button clicked!\n'));
        fprintf('  DEBUG: Test button added\n');
    catch ME
        fprintf('  ERROR creating test button: %s\n', ME.message);
        rethrow(ME);
    end
    
    % Add status text
    fprintf('  DEBUG: Adding status text...\n');
    try
        uicontrol('Parent', main_panel, ...
                  'Style', 'text', ...
                  'String', 'Debug GUI loaded successfully! If you see this, basic GUI functionality is working.', ...
                  'Position', [350, 300, 600, 30], ...
                  'FontSize', 12, ...
                  'ForegroundColor', [0, 0.5, 0]);
        fprintf('  DEBUG: Status text added\n');
    catch ME
        fprintf('  ERROR creating status text: %s\n', ME.message);
        rethrow(ME);
    end
    
    fprintf('  DEBUG: createMainLayout_debug completed\n');
end