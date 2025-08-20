function test_performance_monitoring()
% TEST_PERFORMANCE_MONITORING - Test the performance monitoring functionality
%
% This script tests the performance tracking system to ensure it's working
% correctly with the enhanced GUI.

fprintf('🧪 Testing Performance Monitoring System\n');
fprintf('========================================\n\n');

% Test 1: Basic performance tracker functionality
fprintf('Test 1: Basic Performance Tracker\n');
fprintf('---------------------------------\n');

try
    % Create a performance tracker
    tracker = performance_tracker();
    fprintf('✅ Performance tracker created successfully\n');
    
    % Test timing functionality
    tracker.start_timer('Test_Operation');
    pause(0.1); % Simulate some work
    tracker.stop_timer('Test_Operation');
    fprintf('✅ Basic timing functionality works\n');
    
    % Test performance report
    report = tracker.get_performance_report();
    if isfield(report, 'operations') && isfield(report.operations, 'Test_Operation')
        fprintf('✅ Performance report generation works\n');
    else
        fprintf('❌ Performance report generation failed\n');
    end
    
    % Test display functionality
    fprintf('\nPerformance Report:\n');
    tracker.display_performance_report();
    
catch ME
    fprintf('❌ Basic performance tracker test failed: %s\n', ME.message);
end

fprintf('\n');

% Test 2: Memory usage functionality
fprintf('Test 2: Memory Usage Monitoring\n');
fprintf('--------------------------------\n');

try
    % Test memory usage function
    memory_usage = getMemoryUsage();
    if isnumeric(memory_usage) && memory_usage > 0
        fprintf('✅ Memory usage monitoring works (%.2f MB)\n', memory_usage / (1024 * 1024));
    else
        fprintf('⚠️  Memory usage monitoring returned unexpected value: %s\n', num2str(memory_usage));
    end
catch ME
    fprintf('❌ Memory usage monitoring failed: %s\n', ME.message);
end

fprintf('\n');

% Test 3: Performance analysis functionality
fprintf('Test 3: Performance Analysis\n');
fprintf('-----------------------------\n');

try
    % Test performance analysis function
    fprintf('Running performance analysis...\n');
    performance_analysis();
    fprintf('✅ Performance analysis completed\n');
catch ME
    fprintf('❌ Performance analysis failed: %s\n', ME.message);
end

fprintf('\n');

% Test 4: Performance monitor functionality
fprintf('Test 4: Performance Monitor\n');
fprintf('----------------------------\n');

try
    % Test performance monitor
    performance_monitor('start');
    pause(0.1);
    performance_monitor('stop');
    fprintf('✅ Performance monitor works\n');
catch ME
    fprintf('❌ Performance monitor failed: %s\n', ME.message);
end

fprintf('\n');

% Test 5: Integration with GUI handles
fprintf('Test 5: GUI Integration Test\n');
fprintf('----------------------------\n');

try
    % Create a mock handles structure
    mock_handles = struct();
    mock_handles.performance_tracker = performance_tracker();
    
    % Test that the tracker is accessible
    if isfield(mock_handles, 'performance_tracker')
        mock_handles.performance_tracker.start_timer('GUI_Test');
        pause(0.1);
        mock_handles.performance_tracker.stop_timer('GUI_Test');
        fprintf('✅ GUI integration test passed\n');
    else
        fprintf('❌ GUI integration test failed - tracker not found in handles\n');
    end
catch ME
    fprintf('❌ GUI integration test failed: %s\n', ME.message);
end

fprintf('\n');

% Test 6: File export functionality
fprintf('Test 6: File Export Test\n');
fprintf('------------------------\n');

try
    % Create a tracker and generate some data
    export_tracker = performance_tracker();
    export_tracker.start_timer('Export_Test');
    pause(0.1);
    export_tracker.stop_timer('Export_Test');
    
    % Test MAT file export
    test_filename = 'test_performance_report.mat';
    export_tracker.save_performance_report(test_filename);
    if exist(test_filename, 'file')
        fprintf('✅ MAT file export works\n');
        delete(test_filename);
    else
        fprintf('❌ MAT file export failed\n');
    end
    
    % Test CSV export
    test_csv_filename = 'test_performance_data.csv';
    export_tracker.export_performance_csv(test_csv_filename);
    if exist(test_csv_filename, 'file')
        fprintf('✅ CSV file export works\n');
        delete(test_csv_filename);
    else
        fprintf('❌ CSV file export failed\n');
    end
    
catch ME
    fprintf('❌ File export test failed: %s\n', ME.message);
end

fprintf('\n');

% Summary
fprintf('🎯 Performance Monitoring Test Summary\n');
fprintf('=====================================\n');
fprintf('All tests completed. Check the output above for any failures.\n');
fprintf('If all tests passed, the performance monitoring system is ready for use.\n\n');

fprintf('To use the performance monitoring in the GUI:\n');
fprintf('1. Launch the enhanced GUI\n');
fprintf('2. Go to the Performance Settings tab\n');
fprintf('3. Click "Start Monitoring" to begin tracking\n');
fprintf('4. Run simulations to see performance data\n');
fprintf('5. Click "Generate Report" to get detailed analysis\n\n');

end
