% Test script for extractAllSignalsFromBus function
% This demonstrates how to extract all signals from CombinedSignalBus without hardcoding

fprintf('=== Testing extractAllSignalsFromBus Function ===\n');

try
    % Load the model
    model_name = 'Model/GolfSwing3D_Kinetic';
    fprintf('Loading model: %s\n', model_name);

    if ~bdIsLoaded('GolfSwing3D_Kinetic')
        load_system(model_name);
    end

    % Set up simulation parameters for a short test
    set_param('GolfSwing3D_Kinetic', 'StopTime', '0.1'); % Short simulation
    set_param('GolfSwing3D_Kinetic', 'SaveOutput', 'on');
    set_param('GolfSwing3D_Kinetic', 'SaveFormat', 'Dataset');

    fprintf('Running short simulation...\n');

    % Run simulation
    simOut = sim('GolfSwing3D_Kinetic');

    fprintf('Simulation completed successfully!\n');

    % Test the new extraction function
    if isprop(simOut, 'CombinedSignalBus')
        fprintf('\n--- Testing extractAllSignalsFromBus ---\n');

        % Extract all signals using the new function
        [signal_table, signal_info] = extractAllSignalsFromBus(simOut.CombinedSignalBus);

        if ~isempty(signal_table)
            fprintf('\n=== EXTRACTION SUCCESSFUL ===\n');
            fprintf('Total signals extracted: %d\n', signal_info.total_signals);
            fprintf('Time points: %d\n', signal_info.time_points);
            fprintf('Table size: %d rows x %d columns\n', height(signal_table), width(signal_table));

            % Show first few signal names
            fprintf('\nFirst 10 signal names:\n');
            for i = 1:min(10, length(signal_info.signal_names))
                fprintf('  %d: %s\n', i, signal_info.signal_names{i});
            end

            if length(signal_info.signal_names) > 10
                fprintf('  ... and %d more signals\n', length(signal_info.signal_names) - 10);
            end

            % Show table preview
            fprintf('\nTable preview (first 5 rows, first 5 columns):\n');
            if width(signal_table) > 5
                preview_table = signal_table(:, 1:5);
            else
                preview_table = signal_table;
            end
            disp(preview_table(1:min(5, height(preview_table)), :));

            % Show some statistics
            fprintf('\nSignal statistics:\n');
            signal_names = signal_info.signal_names;
            for i = 1:min(5, length(signal_names))
                signal_name = signal_names{i};
                signal_data = signal_table.(signal_name);
                fprintf('  %s: min=%.3f, max=%.3f, mean=%.3f\n', ...
                    signal_name, min(signal_data), max(signal_data), mean(signal_data));
            end

        else
            fprintf('ERROR: No signals were extracted\n');
        end

    else
        fprintf('ERROR: CombinedSignalBus not found in simulation output\n');
    end

    % Close the model
    if bdIsLoaded('GolfSwing3D_Kinetic')
        close_system('GolfSwing3D_Kinetic', 0);
    end

    fprintf('\n=== Test completed ===\n');

catch ME
    fprintf('ERROR: Test failed: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end