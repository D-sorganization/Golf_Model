function quickModelCheck(model_name)
    % Quick check of model configuration without running simulation
    fprintf('=== Quick Model Check ===\n');
    fprintf('Model: %s\n\n', model_name);
    
    %% Check if model is loaded
    if bdIsLoaded(model_name)
        fprintf('✓ Model is loaded\n');
    else
        fprintf('✗ Model is not loaded\n');
        try
            load_system(model_name);
            fprintf('✓ Model loaded successfully\n');
        catch ME
            fprintf('✗ Failed to load model: %s\n', ME.message);
            return;
        end
    end
    
    %% Check model configuration
    fprintf('\nModel Configuration:\n');
    fprintf('--------------------\n');
    
    try
        % Basic parameters
        stop_time = get_param(model_name, 'StopTime');
        solver = get_param(model_name, 'Solver');
        rel_tol = get_param(model_name, 'RelTol');
        abs_tol = get_param(model_name, 'AbsTol');
        
        fprintf('StopTime: %s\n', stop_time);
        fprintf('Solver: %s\n', solver);
        fprintf('RelTol: %s\n', rel_tol);
        fprintf('AbsTol: %s\n', abs_tol);
        
        % Check logging configuration
        save_format = get_param(model_name, 'SaveFormat');
        save_output = get_param(model_name, 'SaveOutput');
        save_state = get_param(model_name, 'SaveState');
        save_final_state = get_param(model_name, 'SaveFinalState');
        
        fprintf('\nLogging Configuration:\n');
        fprintf('SaveFormat: %s\n', save_format);
        fprintf('SaveOutput: %s\n', save_output);
        fprintf('SaveState: %s\n', save_state);
        fprintf('SaveFinalState: %s\n', save_final_state);
        
    catch ME
        fprintf('✗ Error reading model parameters: %s\n', ME.message);
    end
    
    %% Check for logging blocks
    fprintf('\nLogging Blocks:\n');
    fprintf('---------------\n');
    
    try
        % Find To Workspace blocks
        to_workspace_blocks = find_system(model_name, 'BlockType', 'ToWorkspace');
        fprintf('To Workspace blocks: %d\n', length(to_workspace_blocks));
        for i = 1:min(5, length(to_workspace_blocks))
            var_name = get_param(to_workspace_blocks{i}, 'VariableName');
            fprintf('  - %s (Variable: %s)\n', to_workspace_blocks{i}, var_name);
        end
        
        % Find Scope blocks
        scope_blocks = find_system(model_name, 'BlockType', 'Scope');
        fprintf('Scope blocks: %d\n', length(scope_blocks));
        
        % Find Signal Logging blocks
        signal_logging_blocks = find_system(model_name, 'BlockType', 'SignalLogging');
        fprintf('Signal Logging blocks: %d\n', length(signal_logging_blocks));
        
    catch ME
        fprintf('✗ Error checking logging blocks: %s\n', ME.message);
    end
    
    %% Check Simscape logging
    fprintf('\nSimscape Logging:\n');
    fprintf('-----------------\n');
    
    try
        % Check if Simscape logging is enabled
        simscape_logging = get_param(model_name, 'SimscapeLogType');
        fprintf('SimscapeLogType: %s\n', simscape_logging);
        
        % Check for Simscape blocks
        simscape_blocks = find_system(model_name, 'MaskType', 'Simscape');
        fprintf('Simscape blocks found: %d\n', length(simscape_blocks));
        
        if ~isempty(simscape_blocks)
            fprintf('First few Simscape blocks:\n');
            for i = 1:min(3, length(simscape_blocks))
                fprintf('  - %s\n', simscape_blocks{i});
            end
        end
        
    catch ME
        fprintf('✗ Error checking Simscape logging: %s\n', ME.message);
    end
    
    %% Check model workspace for critical variables
    fprintf('\nCritical Variables:\n');
    fprintf('-------------------\n');
    
    try
        model_ws = get_param(model_name, 'ModelWorkspace');
        ws_vars = model_ws.whos;
        
        % Look for variables that might contain initial conditions
        initial_vars = {};
        for i = 1:length(ws_vars)
            var_name = ws_vars(i).name;
            if contains(lower(var_name), {'q0', 'qd0', 'initial', 'position', 'velocity'})
                initial_vars{end+1} = var_name;
            end
        end
        
        if ~isempty(initial_vars)
            fprintf('Potential initial condition variables:\n');
            for i = 1:length(initial_vars)
                fprintf('  - %s\n', initial_vars{i});
            end
        else
            fprintf('No obvious initial condition variables found\n');
        end
        
    catch ME
        fprintf('✗ Error checking model workspace: %s\n', ME.message);
    end
    
    %% Check for existing SDI runs
    fprintf('\nExisting SDI Runs:\n');
    fprintf('------------------\n');
    
    try
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            fprintf('Found %d SDI runs\n', length(runIDs));
            latest_run = Simulink.sdi.getRun(runIDs(end));
            all_signals = latest_run.getAllSignals;
            fprintf('Latest run has %d signals\n', length(all_signals));
        else
            fprintf('No SDI runs found\n');
        end
    catch ME
        fprintf('✗ Error checking SDI: %s\n', ME.message);
    end
    
    fprintf('\n=== Quick Check Complete ===\n');
end 