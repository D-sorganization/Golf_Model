% Comprehensive GUI Error Diagnostic Script
% This script helps identify the cause of "Caught unexpected exception of unknown type" errors

fprintf('\n=== GUI Error Diagnostic Tool ===\n\n');

% Test 1: Check MATLAB version and environment
fprintf('1. MATLAB Environment Check:\n');
try
    fprintf('   MATLAB Version: %s\n', version);
    fprintf('   Computer: %s\n', computer);
    fprintf('   Architecture: %s\n', computer('arch'));
catch ME
    fprintf('   ERROR checking MATLAB version: %s\n', ME.message);
end

% Test 2: Check current directory and paths
fprintf('\n2. Path and Directory Check:\n');
fprintf('   Current Directory: %s\n', pwd);
fprintf('   Script Location: %s\n', fileparts(which('GolfSwingDataGeneratorGUI')));

% Test 3: Check for required toolboxes
fprintf('\n3. Toolbox Check:\n');
toolboxes = ver;
required_toolboxes = {'MATLAB', 'Simulink', 'Simscape'};
for i = 1:length(required_toolboxes)
    found = false;
    for j = 1:length(toolboxes)
        if strcmpi(toolboxes(j).Name, required_toolboxes{i})
            fprintf('   %s: FOUND (v%s)\n', required_toolboxes{i}, toolboxes(j).Version);
            found = true;
            break;
        end
    end
    if ~found
        fprintf('   %s: NOT FOUND\n', required_toolboxes{i});
    end
end

% Test 4: Test GUI components individually
fprintf('\n4. Testing GUI Components:\n');

% Test 4a: Figure creation
fprintf('   Testing figure creation... ');
try
    test_fig = figure('Visible', 'off');
    close(test_fig);
    fprintf('OK\n');
catch ME
    fprintf('FAILED\n');
    fprintf('      Error: %s\n', ME.message);
end

% Test 4b: UIPanel creation
fprintf('   Testing uipanel creation... ');
try
    test_fig = figure('Visible', 'off');
    test_panel = uipanel('Parent', test_fig);
    close(test_fig);
    fprintf('OK\n');
catch ME
    fprintf('FAILED\n');
    fprintf('      Error: %s\n', ME.message);
end

% Test 4c: UIControl creation
fprintf('   Testing uicontrol creation... ');
try
    test_fig = figure('Visible', 'off');
    test_control = uicontrol('Parent', test_fig, 'Style', 'text');
    close(test_fig);
    fprintf('OK\n');
catch ME
    fprintf('FAILED\n');
    fprintf('      Error: %s\n', ME.message);
end

% Test 4d: Guidata functionality
fprintf('   Testing guidata functionality... ');
try
    test_fig = figure('Visible', 'off');
    test_data = struct('test', 123);
    guidata(test_fig, test_data);
    retrieved_data = guidata(test_fig);
    close(test_fig);
    if retrieved_data.test == 123
        fprintf('OK\n');
    else
        fprintf('FAILED (data mismatch)\n');
    end
catch ME
    fprintf('FAILED\n');
    fprintf('      Error: %s\n', ME.message);
end

% Test 5: Check for Java/display issues
fprintf('\n5. Display/Java Check:\n');
try
    fprintf('   Display Available: %s\n', mat2str(usejava('desktop')));
    fprintf('   Java Graphics: %s\n', mat2str(usejava('jvm')));
    fprintf('   AWT Available: %s\n', mat2str(usejava('awt')));
    fprintf('   Swing Available: %s\n', mat2str(usejava('swing')));
catch ME
    fprintf('   ERROR checking Java/display: %s\n', ME.message);
end

% Test 6: Try launching the GUI with detailed error catching
fprintf('\n6. Attempting to launch GUI with detailed error catching:\n');
try
    % Clear any existing errors
    lastwarn('');
    lasterror('reset');
    
    % Try to launch the GUI
    fprintf('   Calling GolfSwingDataGeneratorGUI()...\n');
    GolfSwingDataGeneratorGUI();
    fprintf('   GUI launched successfully!\n');
catch ME
    fprintf('   ERROR: %s\n', ME.message);
    fprintf('   Identifier: %s\n', ME.identifier);
    fprintf('\n   Stack Trace:\n');
    for i = 1:length(ME.stack)
        fprintf('      In %s (line %d) in %s\n', ME.stack(i).name, ME.stack(i).line, ME.stack(i).file);
    end
    
    % Check for warnings
    [warnMsg, warnId] = lastwarn;
    if ~isempty(warnMsg)
        fprintf('\n   Last Warning: %s\n', warnMsg);
        fprintf('   Warning ID: %s\n', warnId);
    end
    
    % Try to get more details about the error
    fprintf('\n   Full Error Report:\n');
    disp(getReport(ME, 'extended', 'hyperlinks', 'off'));
end

% Test 7: Check for missing functions or dependencies
fprintf('\n7. Checking for missing dependencies:\n');
gui_functions = {'GolfSwingDataGeneratorGUI', 'GolfSwingDataGeneratorHelpers', ...
                 'runSingleTrial', 'extractCompleteTrialData', 'generatePolynomialCoefficients'};
for i = 1:length(gui_functions)
    if exist(gui_functions{i}, 'file')
        fprintf('   %s: FOUND\n', gui_functions{i});
    else
        fprintf('   %s: NOT FOUND\n', gui_functions{i});
    end
end

fprintf('\n=== Diagnostic Complete ===\n');