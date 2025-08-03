%% Launch Enhanced Golf Swing Data Generator GUI
% This script launches the enhanced version of the GUI with tabbed interface
% and advanced post-processing capabilities

function launch_enhanced_gui()
    % Add current directory to path if not already there
    current_dir = fileparts(mfilename('fullpath'));
    if ~contains(path, current_dir)
        addpath(current_dir);
    end
    
    % Launch the enhanced GUI
    try
        Data_GUI_Enhanced();
        fprintf('Enhanced Golf Swing Data Generator launched successfully!\n');
        fprintf('Features available:\n');
        fprintf('  - Tabbed interface (Data Generation / Post-Processing)\n');
        fprintf('  - Pause/Resume functionality with checkpoints\n');
        fprintf('  - Multiple export formats (CSV, Parquet, MAT, JSON)\n');
        fprintf('  - Batch processing with configurable batch sizes\n');
        fprintf('  - Feature extraction for machine learning\n');
        fprintf('  - Memory-efficient processing\n');
    catch ME
        fprintf('Error launching enhanced GUI: %s\n', ME.message);
        fprintf('Falling back to original GUI...\n');
        try
            Data_GUI();
        catch ME2
            fprintf('Error launching original GUI: %s\n', ME2.message);
        end
    end
end

% If this script is run directly, launch the GUI
if ~exist('OCTAVE_VERSION', 'builtin')  % Not Octave
    launch_enhanced_gui();
end 