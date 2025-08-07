function launch_gui()
% LAUNCH_GUI - Simple launcher for the Golf Swing Analysis GUI
%
% This script adds the necessary paths and launches the GUI
%
% Usage:
%   launch_gui();

    % Get the directory where this script is located
    script_dir = fileparts(mfilename('fullpath'));
    
    % Add all subdirectories to the MATLAB path
    addpath(genpath(script_dir));
    
    % Launch the GUI
    golf_swing_analysis_gui();
    
    fprintf('🚀 GUI launched successfully!\n');
    fprintf('📁 Working directory: %s\n', script_dir);
    
end
