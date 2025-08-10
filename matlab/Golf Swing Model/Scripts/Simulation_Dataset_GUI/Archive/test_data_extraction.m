function test_data_extraction()
    % Test script to verify data extraction fixes
    % This script tests the improved data extraction functions

    fprintf('=== Testing Data Extraction Fixes ===\n\n');

    % Test 1: Check model configuration
    fprintf('Test 1: Checking model configuration...\n');
    check_model_configuration();

    % Test 2: Run a simple simulation and test data extraction
    fprintf('\nTest 2: Testing data extraction...\n');

    try
        % Load model
        model_name = 'GolfSwing3D_Kinetic';
        if ~bdIsLoaded(model_name)
            load_system(model_name);
        end

        % Create simulation input
        simIn = Simulink.SimulationInput(model_name);
        simIn = simIn.setModelParameter('StopTime', '0.1'); % Very short
        simIn = simIn.setModelParameter('SaveOutput', 'on');
        simIn = simIn.setModelParameter('SaveFormat', 'Structure');
        simIn = simIn.setModelParameter('ReturnWorkspaceOutputs', 'on');

        % Run simulation
        fprintf('Running test simulation...\n');
        simOut = sim(simIn);

        % Test data extraction
        config = struct();
        config.use_model_workspace = true;
        config.use_signal_bus = true;
        config.use_logsout = true;
        config.use_simscape = true;

        fprintf('Testing data extraction...\n');
        data_table = extractSimulationData(simOut, config);

        if ~isempty(data_table)
            fprintf('✓ Data extraction successful!\n');
            fprintf('  Rows: %d\n', height(data_table));
            fprintf('  Columns: %d\n', width(data_table));
            fprintf('  Column names: %s\n', strjoin(data_table.Properties.VariableNames(1:min(5, width(data_table))), ', '));
            if width(data_table) > 5
                fprintf('  ... and %d more columns\n', width(data_table) - 5);
            end
        else
            fprintf('✗ No data extracted\n');
        end

    catch ME
        fprintf('✗ Test failed: %s\n', ME.message);
    end

    % Test 3: Test individual extraction functions
    fprintf('\nTest 3: Testing individual extraction functions...\n');

    try
        if exist('simOut', 'var') && isprop(simOut, 'out')
            out = simOut.out;

            % Test workspace extraction
            fprintf('Testing workspace extraction...\n');
            workspace_data = extractWorkspaceData(out);
            if ~isempty(workspace_data)
                fprintf('✓ Workspace extraction: %d columns\n', width(workspace_data));
            else
                fprintf('✗ No workspace data\n');
            end

            % Test signal bus extraction
            fprintf('Testing signal bus extraction...\n');
            signal_bus_data = extractSignalBusStructs(out);
            if ~isempty(signal_bus_data)
                fprintf('✓ Signal bus extraction: %d columns\n', width(signal_bus_data));
            else
                fprintf('✗ No signal bus data\n');
            end

        else
            fprintf('✗ No simulation output available for testing\n');
        end

    catch ME
        fprintf('✗ Individual function test failed: %s\n', ME.message);
    end

    fprintf('\n=== Test Complete ===\n');
    fprintf('\nNext steps:\n');
    fprintf('1. Run check_model_configuration() to identify any naming issues\n');
    fprintf('2. Fix any To Workspace block variable names if needed\n');
    fprintf('3. Run the Data_GUI() and test with a small number of trials\n');
    fprintf('4. Check the debug output to see what data is being captured\n');
end
