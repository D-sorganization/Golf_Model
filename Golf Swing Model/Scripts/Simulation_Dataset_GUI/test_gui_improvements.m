% Test script for Data_Generation_GUI improvements
% This script tests the enhanced features added to the GUI

fprintf('Testing Data_Generation_GUI improvements...\n');

try
    % Add current directory to path
    addpath(pwd);
    
    % Launch the GUI
    fprintf('Launching GUI...\n');
    Data_Generation_GUI();
    
    fprintf('\nGUI launched successfully!\n');
    fprintf('\nEnhanced features to test:\n');
    fprintf('1. Search functionality in coefficients table\n');
    fprintf('   - Type a joint name in the search box to find matching columns\n');
    fprintf('   - Click "Clear" to reset the search\n\n');
    
    fprintf('2. Polynomial equation display\n');
    fprintf('   - Check the Individual Joint Editor panel\n');
    fprintf('   - Equation should be displayed at the bottom: τ(t) = A + Bt + Ct² + ...\n\n');
    
    fprintf('3. Enhanced data saving for ML\n');
    fprintf('   - Generated CSV files will include:\n');
    fprintf('     * Trial metadata (trial_id, timestamp)\n');
    fprintf('     * Input coefficients as features (input_JointName_Coeff)\n');
    fprintf('     * Scenario parameters\n');
    fprintf('     * Organized column structure for ML pipelines\n\n');
    
    fprintf('4. Master dataset compilation\n');
    fprintf('   - After generation completes, all trials are compiled into:\n');
    fprintf('     * master_dataset_[timestamp].csv\n');
    fprintf('     * master_dataset_[timestamp].mat\n');
    fprintf('     * dataset_summary_[timestamp].txt\n\n');
    
    fprintf('5. Fixed "Apply Row" functionality\n');
    fprintf('   - Click "Apply Row" button to copy one row to all others\n');
    fprintf('   - Should no longer show "unrecognized field name" error\n\n');
    
    fprintf('6. Auto-updating preview table\n');
    fprintf('   - Change number of trials and the table should update\n');
    fprintf('   - Note: You may need to click outside the edit box for it to update\n\n');
    
catch ME
    fprintf('Error: %s\n', ME.message);
    fprintf('Stack:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
end