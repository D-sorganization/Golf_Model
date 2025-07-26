function ultra_minimal_gui()
    % Ultra minimal GUI - start with absolute basics
    fprintf('Creating ultra minimal GUI...\n');
    
    % Test 1: Can we create a basic figure?
    fprintf('Test 1: Creating basic figure...\n');
    try
        fig = figure('Name', 'Ultra Minimal Test');
        fprintf('SUCCESS: Basic figure created\n');
    catch ME
        fprintf('FAILED: %s\n', ME.message);
        return;
    end
    
    % Test 2: Can we create a basic uipanel?
    fprintf('Test 2: Creating basic uipanel...\n');
    try
        panel = uipanel('Parent', fig, 'Title', 'Test Panel');
        fprintf('SUCCESS: Basic uipanel created\n');
    catch ME
        fprintf('FAILED: %s\n', ME.message);
        return;
    end
    
    % Test 3: Can we create a basic uicontrol?
    fprintf('Test 3: Creating basic uicontrol...\n');
    try
        button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Test');
        fprintf('SUCCESS: Basic uicontrol created\n');
    catch ME
        fprintf('FAILED: %s\n', ME.message);
        return;
    end
    
    % Test 4: Can we use struct and guidata?
    fprintf('Test 4: Testing struct and guidata...\n');
    try
        handles = struct();
        handles.test = 123;
        guidata(fig, handles);
        fprintf('SUCCESS: struct and guidata work\n');
    catch ME
        fprintf('FAILED: %s\n', ME.message);
        return;
    end
    
    % Test 5: Position parameters (absolute positioning)
    fprintf('Test 5: Testing absolute positioning...\n');
    try
        % Close old figure
        close(fig);
        
        % Create new figure with absolute positioning
        fig = figure('Name', 'Position Test', 'Position', [100, 100, 800, 600]);
        panel = uipanel('Parent', fig, 'Position', [50, 50, 700, 500]);
        button = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Positioned Button', 'Position', [50, 50, 100, 30]);
        fprintf('SUCCESS: Absolute positioning works\n');
    catch ME
        fprintf('FAILED: %s\n', ME.message);
        return;
    end
    
    fprintf('All basic tests passed! The issue must be in more complex components.\n');
end 