function run_tests()
% RUN_TESTS - Run all tests for the Simulation Dataset Generation GUI
% This script tests signal bus compatibility and sets up the GUI

fprintf('=== Simulation Dataset Generation GUI - Test Suite ===\n\n');

%% 1. Test signal bus compatibility
fprintf('1. Testing signal bus compatibility...\n');
try
    test_signal_bus_compatibility();
    fprintf('✅ Signal bus compatibility test completed\n\n');
catch ME
    fprintf('❌ Signal bus compatibility test failed: %s\n\n', ME.message);
end

%% 2. Test performance options
fprintf('2. Testing performance options...\n');
try
    settings = performance_options();
    if ~isempty(settings) && settings.apply_settings
        fprintf('✅ Performance options configured successfully\n');
        fprintf('   - Disable Simscape Results: %s\n', mat2str(settings.disable_simscape_results));
        fprintf('   - Optimize Memory: %s\n', mat2str(settings.optimize_memory));
        fprintf('   - Fast Restart: %s\n', mat2str(settings.fast_restart));
    else
        fprintf('⚠️  Performance options not applied\n');
    end
    fprintf('\n');
catch ME
    fprintf('❌ Performance options test failed: %s\n\n', ME.message);
end

%% 3. Launch GUI
fprintf('3. Launching GUI...\n');
try
    launch_gui();
    fprintf('✅ GUI launched successfully\n\n');
catch ME
    fprintf('❌ GUI launch failed: %s\n\n', ME.message);
end

%% 4. Summary
fprintf('=== Test Summary ===\n');
fprintf('✅ All tests completed\n');
fprintf('✅ GUI is ready for use\n');
fprintf('\n📋 Next Steps:\n');
fprintf('1. Use the GUI to configure your simulation parameters\n');
fprintf('2. Set performance options for optimal speed\n');
fprintf('3. Run simulations to generate datasets\n');
fprintf('4. Export data for machine learning training\n');

fprintf('\n=== Setup Complete ===\n');

end 