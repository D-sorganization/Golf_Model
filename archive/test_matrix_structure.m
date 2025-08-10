% Test script to examine the structure of rotation matrices and inertia tensors
fprintf('=== Testing Matrix Structure ===\n');

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

    % Examine the structure of some problematic signals
    if isprop(simOut, 'CombinedSignalBus')
        fprintf('\n--- Examining Matrix Structure ---\n');

        % Look at a rotation transform signal
        if isfield(simOut.CombinedSignalBus, 'LScapLogs') && ...
           isfield(simOut.CombinedSignalBus.LScapLogs, 'Rotation_Transform')

            rot_signal = simOut.CombinedSignalBus.LScapLogs.Rotation_Transform;
            fprintf('LScapLogs.Rotation_Transform:\n');
            fprintf('  Class: %s\n', class(rot_signal));
            fprintf('  Size: %s\n', mat2str(size(rot_signal)));

            if isa(rot_signal, 'timeseries')
                fprintf('  Time length: %d\n', length(rot_signal.Time));
                fprintf('  Data size: %s\n', mat2str(size(rot_signal.Data)));
                fprintf('  Data class: %s\n', class(rot_signal.Data));

                % Show first few time points
                fprintf('  First 3 time points:\n');
                for i = 1:min(3, length(rot_signal.Time))
                    fprintf('    t=%.6f: %s\n', rot_signal.Time(i), mat2str(rot_signal.Data(:,:,i)));
                end
            end
        end

        % Look at an inertia tensor signal
        if isfield(simOut.CombinedSignalBus, 'SegmentInertiaLogs') && ...
           isfield(simOut.CombinedSignalBus.SegmentInertiaLogs, 'LHInertia')

            inertia_signal = simOut.CombinedSignalBus.SegmentInertiaLogs.LHInertia;
            fprintf('\nSegmentInertiaLogs.LHInertia:\n');
            fprintf('  Class: %s\n', class(inertia_signal));
            fprintf('  Size: %s\n', mat2str(size(inertia_signal)));

            if isa(inertia_signal, 'timeseries')
                fprintf('  Time length: %d\n', length(inertia_signal.Time));
                fprintf('  Data size: %s\n', mat2str(size(inertia_signal.Data)));
                fprintf('  Data class: %s\n', class(inertia_signal.Data));

                % Show first few time points
                fprintf('  First 3 time points:\n');
                for i = 1:min(3, length(inertia_signal.Time))
                    fprintf('    t=%.6f: %s\n', inertia_signal.Time(i), mat2str(inertia_signal.Data(:,:,i)));
                end
            end
        end

        % Look at a 3D vector signal for comparison
        if isfield(simOut.CombinedSignalBus, 'LScapLogs') && ...
           isfield(simOut.CombinedSignalBus.LScapLogs, 'GlobalPosition')

            pos_signal = simOut.CombinedSignalBus.LScapLogs.GlobalPosition;
            fprintf('\nLScapLogs.GlobalPosition (for comparison):\n');
            fprintf('  Class: %s\n', class(pos_signal));
            fprintf('  Size: %s\n', mat2str(size(pos_signal)));

            if isa(pos_signal, 'timeseries')
                fprintf('  Time length: %d\n', length(pos_signal.Time));
                fprintf('  Data size: %s\n', mat2str(size(pos_signal.Data)));
                fprintf('  Data class: %s\n', class(pos_signal.Data));
            end
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
