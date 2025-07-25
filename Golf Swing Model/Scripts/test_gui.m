% Test script for the Golf Swing Data Generator GUI
try
    fprintf('Testing GUI launch...\n');
    GolfSwingDataGeneratorGUI();
    fprintf('GUI launched successfully!\n');
catch ME
    fprintf('Error launching GUI: %s\n', ME.message);
    fprintf('Error details:\n');
    disp(getReport(ME));
end 