% Test script for lightweight timer
% This script tests the lightweight timer functionality to ensure it works
% without the memory monitoring overhead that was causing slowdowns

fprintf('🧪 Testing Lightweight Timer\n');
fprintf('============================\n\n');

% Create timer instance
timer = lightweight_timer();

% Test basic timing
fprintf('Testing basic timing...\n');
timer.start('Test_Operation');
pause(0.1); % Simulate some work
timer.stop('Test_Operation');

% Test function timing
fprintf('\nTesting function timing...\n');
timer.time_function('Test_Function', @(x) pause(x), 0.05);

% Test multiple operations
fprintf('\nTesting multiple operations...\n');
for i = 1:3
    timer.start(sprintf('Operation_%d', i));
    pause(0.02 * i); % Different durations
    timer.stop(sprintf('Operation_%d', i));
end

% Display timing report
fprintf('\n');
timer.display_timing_report();

% Test CSV export
fprintf('\nTesting CSV export...\n');
timer.export_timing_csv('test_timing_data.csv');

% Test MAT export
fprintf('\nTesting MAT export...\n');
timer.save_timing_report('test_timing_report.mat');

fprintf('\n✅ Lightweight timer test completed successfully!\n');
fprintf('The timer should provide detailed timing information without\n');
fprintf('the memory monitoring overhead that was causing slowdowns.\n');
