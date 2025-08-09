function debugSimulation(model_name)
    % Debug script to identify simulation issues
    fprintf('=== Simulation Debug ===\n');
    fprintf('Model: %s\n\n', model_name);
    
    %% Phase 1: Model Status Check
    fprintf('Phase 1: Model Status Check\n');
    fprintf('---------------------------\n');
    
    % Check if model is loaded
    if bdIsLoaded(model_name)
        fprintf('✓ Model is loaded\n');
    else
        fprintf('✗ Model is not loaded\n');
        fprintf('Loading model...\n');
        try
            load_system(model_name);
            fprintf('✓ Model loaded successfully\n');
        catch ME
            fprintf('✗ Failed to load model: %s\n', ME.message);
            return;
        end
    end
    
    % Check model parameters
    try
        stop_time = get_param(model_name, 'StopTime');
        solver = get_param(model_name, 'Solver');
        rel_tol = get_param(model_name, 'RelTol');
        abs_tol = get_param(model_name, 'AbsTol');
        
        fprintf('Current parameters:\n');
        fprintf('  StopTime: %s\n', stop_time);
        fprintf('  Solver: %s\n', solver);
        fprintf('  RelTol: %s\n', rel_tol);
        fprintf('  AbsTol: %s\n', abs_tol);
    catch ME
        fprintf('✗ Error reading model parameters: %s\n', ME.message);
    end
    
    %% Phase 2: Model Workspace Check
    fprintf('\nPhase 2: Model Workspace Check\n');
    fprintf('------------------------------\n');
    
    try
        % Get model workspace
        model_ws = get_param(model_name, 'ModelWorkspace');
        ws_vars = model_ws.whos;
        
        fprintf('Model workspace variables (%d found):\n', length(ws_vars));
        for i = 1:min(10, length(ws_vars)) % Show first 10
            fprintf('  - %s (%s)\n', ws_vars(i).name, ws_vars(i).class);
        end
        if length(ws_vars) > 10
            fprintf('  ... and %d more\n', length(ws_vars) - 10);
        end
        
        % Check for critical variables
        critical_vars = {'q0', 'qd0', 'InitialConditions', 'PolynomialCoefficients'};
        for var = critical_vars
            try
                value = model_ws.getVariable(var{1});
                fprintf('✓ %s: found\n', var{1});
            catch
                fprintf('✗ %s: not found\n', var{1});
            end
        end
        
    catch ME
        fprintf('✗ Error accessing model workspace: %s\n', ME.message);
    end
    
    %% Phase 3: Block Check
    fprintf('\nPhase 3: Block Check\n');
    fprintf('--------------------\n');
    
    try
        % Find all blocks
        all_blocks = find_system(model_name, 'FollowLinks', 'on', 'LookUnderMasks', 'on');
        fprintf('Total blocks found: %d\n', length(all_blocks));
        
        % Check for critical blocks
        critical_blocks = {'Polynomial', 'Joint', 'Solver', 'Scope', 'To Workspace'};
        for block_type = critical_blocks
            blocks = find_system(model_name, 'BlockType', block_type{1});
            fprintf('  %s blocks: %d\n', block_type{1}, length(blocks));
        end
        
        % Check for Simscape blocks
        simscape_blocks = find_system(model_name, 'MaskType', 'Simscape');
        fprintf('  Simscape blocks: %d\n', length(simscape_blocks));
        
    catch ME
        fprintf('✗ Error checking blocks: %s\n', ME.message);
    end
    
    %% Phase 4: Simple Simulation Test
    fprintf('\nPhase 4: Simple Simulation Test\n');
    fprintf('--------------------------------\n');
    
    try
        % Set very simple parameters
        set_param(model_name, 'StopTime', '0.1');
        set_param(model_name, 'Solver', 'ode23t');
        set_param(model_name, 'RelTol', '1e-2');
        set_param(model_name, 'AbsTol', '1e-3');
        
        fprintf('Running minimal simulation (0.1s)...\n');
        tic;
        simOut = sim(model_name);
        sim_time = toc;
        
        fprintf('✓ Simulation completed in %.3f seconds\n', sim_time);
        
        % Check simulation output
        if isfield(simOut, 'tout')
            fprintf('✓ Time vector found: %d points\n', length(simOut.tout));
            fprintf('  Time range: %.3f to %.3f seconds\n', simOut.tout(1), simOut.tout(end));
        else
            fprintf('✗ No time vector found\n');
        end
        
        if isfield(simOut, 'yout')
            fprintf('✓ Output vector found: %d points\n', length(simOut.yout));
        else
            fprintf('✗ No output vector found\n');
        end
        
        % Check for logsout
        if isfield(simOut, 'logsout')
            logsout = simOut.logsout;
            if ~isempty(logsout)
                fprintf('✓ Logged signals found: %d\n', logsout.numElements);
                for i = 1:min(5, logsout.numElements)
                    fprintf('  - %s\n', logsout{i}.Name);
                end
                if logsout.numElements > 5
                    fprintf('  ... and %d more\n', logsout.numElements - 5);
                end
            else
                fprintf('✗ No logged signals found\n');
            end
        else
            fprintf('✗ No logsout field found\n');
        end
        
    catch ME
        fprintf('✗ Simulation failed: %s\n', ME.message);
        fprintf('Error details:\n');
        fprintf('%s\n', getReport(ME, 'extended'));
    end
    
    %% Phase 5: Simscape Results Check
    fprintf('\nPhase 5: Simscape Results Check\n');
    fprintf('--------------------------------\n');
    
    try
        % Check Simulink Data Inspector
        runIDs = Simulink.sdi.getAllRunIDs;
        if ~isempty(runIDs)
            latest_run = Simulink.sdi.getRun(runIDs(end));
            all_signals = latest_run.getAllSignals;
            fprintf('✓ SDI signals found: %d\n', length(all_signals));
            
            % Show first few signal names
            for i = 1:min(5, length(all_signals))
                fprintf('  - %s\n', all_signals(i).Name);
            end
            if length(all_signals) > 5
                fprintf('  ... and %d more\n', length(all_signals) - 5);
            end
        else
            fprintf('✗ No SDI runs found\n');
        end
        
    catch ME
        fprintf('✗ Error checking Simscape results: %s\n', ME.message);
    end
    
    fprintf('\n=== Debug Complete ===\n');
end 