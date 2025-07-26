% Debug test script to isolate the runtime error
try
    fprintf('Testing basic MATLAB functionality...\n');
    
    % Test basic operations
    a = 1 + 1;
    fprintf('Basic math works: %d\n', a);
    
    % Test figure creation
    fprintf('Testing figure creation...\n');
    test_fig = figure('Visible', 'off');
    fprintf('Figure created successfully\n');
    close(test_fig);
    
    % Test uipanel creation
    fprintf('Testing uipanel creation...\n');
    test_fig = figure('Visible', 'off');
    test_panel = uipanel('Parent', test_fig, 'Position', [0.1, 0.1, 0.8, 0.8]);
    fprintf('Uipanel created successfully\n');
    close(test_fig);
    
    % Test uicontrol creation
    fprintf('Testing uicontrol creation...\n');
    test_fig = figure('Visible', 'off');
    test_control = uicontrol('Parent', test_fig, 'Style', 'text', 'String', 'Test');
    fprintf('Uicontrol created successfully\n');
    close(test_fig);
    
    % Test struct creation
    fprintf('Testing struct creation...\n');
    test_struct = struct('field1', 1, 'field2', 'test');
    fprintf('Struct created successfully\n');
    
    % Test guidata
    fprintf('Testing guidata...\n');
    test_fig = figure('Visible', 'off');
    guidata(test_fig, test_struct);
    fprintf('Guidata works successfully\n');
    close(test_fig);
    
    fprintf('All basic tests passed!\n');
    
catch ME
    fprintf('Error in basic test: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME));
end 