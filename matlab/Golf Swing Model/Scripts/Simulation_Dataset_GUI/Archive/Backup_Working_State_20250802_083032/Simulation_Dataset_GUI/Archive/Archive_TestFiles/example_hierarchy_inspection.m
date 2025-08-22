% EXAMPLE_HIERARCHY_INSPECTION - Example usage of inspect_simscape_hierarchy
% This script demonstrates how to use the simscape hierarchy inspection tool
% to understand the structure of your simulation output data.

% Clear workspace
clear; clc;

fprintf('=== SIMSCAPE HIERARCHY INSPECTION EXAMPLE ===\n\n');

% Step 1: Load or run a simulation to get simOut
fprintf('Step 1: You need a simOut object from a simulation\n');
fprintf('Example ways to get simOut:\n');
fprintf('  Method A: simOut = sim(''YourModel'');\n');
fprintf('  Method B: load(''saved_simOut.mat'', ''simOut'');\n');
fprintf('  Method C: Get from workspace if already available\n\n');

% Check if simOut exists in workspace
if exist('simOut', 'var')
    fprintf('✓ Found simOut in workspace!\n');
    fprintf('  Class: %s\n', class(simOut));

    if isfield(simOut, 'simlog')
        fprintf('  Has simlog field: YES\n');
        fprintf('  Simlog class: %s\n\n', class(simOut.simlog));

        % Step 2: Run the inspection
        fprintf('Step 2: Running hierarchy inspection...\n\n');
        inspect_simscape_hierarchy(simOut);

    else
        fprintf('  Has simlog field: NO\n');
        fprintf('  ❌ This simOut does not contain Simscape logging data\n');
        fprintf('  Make sure your model has Simscape logging enabled\n\n');
    end

else
    fprintf('❌ No simOut variable found in workspace\n\n');
    fprintf('To use this example:\n');
    fprintf('1. Run a simulation that produces simOut:\n');
    fprintf('   simOut = sim(''YourModelName'');\n\n');
    fprintf('2. Then run this example script again\n\n');

    % Alternative: Try to load from a file
    fprintf('Alternatively, if you have a saved simOut file:\n');
    fprintf('   load(''path/to/your/simOut.mat'');\n');
    fprintf('   example_hierarchy_inspection\n\n');

    % Show what the inspection output looks like
    fprintf('--- SAMPLE OUTPUT FORMAT ---\n');
    fprintf('The hierarchy inspection will show something like:\n\n');
    fprintf('=== SIMSCAPE HIERARCHY INSPECTION ===\n');
    fprintf('[Node] ID:Golf_Swing_Model exportable:1\n');
    fprintf('├── Human: [Node] ID:Human exportable:1\n');
    fprintf('│   ├── Torso: [Node] ID:Human/Torso [TIME: 1001 pts]\n');
    fprintf('│   │   ├── position: [Node] [VALUES: 1001x3]\n');
    fprintf('│   │   └── velocity: [Node] [VALUES: 1001x3]\n');
    fprintf('│   └── Arms: [Node] ID:Human/Arms\n');
    fprintf('└── Club: [Node] ID:Club exportable:1\n');
    fprintf('    ├── shaft_angle: [Node] [TIME: 1001 pts] [VALUES: 1001x1]\n');
    fprintf('    └── club_head_velocity: [Node] [VALUES: 1001x3]\n');
    fprintf('=== END HIERARCHY ===\n\n');
end

fprintf('=== END EXAMPLE ===\n');

% Additional helper function
function showUsageTips()
    fprintf('💡 USAGE TIPS:\n');
    fprintf('1. Use this to understand your model''s data structure\n');
    fprintf('2. Look for nodes with [TIME: X pts] and [VALUES: XxY] - these contain data\n');
    fprintf('3. exportable:1 means the node should have accessible data\n');
    fprintf('4. Use the node IDs to access data in your extraction functions\n');
    fprintf('5. If you see [SERIES_CHILDREN: N] there may be sub-components\n\n');
end

% Call tips function
showUsageTips();
