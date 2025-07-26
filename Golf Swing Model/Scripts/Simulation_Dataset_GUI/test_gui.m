% Test script for GolfSwingDataGeneratorGUI
try
    fprintf('Starting GUI test...\n');
    GolfSwingDataGeneratorGUI();
    fprintf('GUI started successfully!\n');
catch ME
    fprintf('Error starting GUI: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME));
end 