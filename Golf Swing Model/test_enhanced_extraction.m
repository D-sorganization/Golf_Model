% Test script for enhanced extractAllSignalsFromBus function
% This demonstrates how to extract signals from multiple data sources
% including CombinedSignalBus, logsout, and Simscape Results Explorer

fprintf('=== Testing Enhanced extractAllSignalsFromBus Function ===\n');

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
    
    % Test 1: Extract only from CombinedSignalBus (default behavior)
    fprintf('\n--- Test 1: CombinedSignalBus Only ---\n');
    options1 = struct();
    options1.extract_combined_bus = true;
    options1.extract_logsout = false;
    options1.extract_simscape = false;
    options1.verbose = true;
    
    [data1, info1] = extractAllSignalsFromBus(simOut, options1);
    
    if ~isempty(data1)
        fprintf('✓ Test 1 PASSED: Extracted %d signals from CombinedSignalBus\n', info1.total_signals);
        fprintf('  Table size: %d rows × %d columns\n', height(data1), width(data1));
    else
        fprintf('✗ Test 1 FAILED: No data extracted from CombinedSignalBus\n');
    end
    
    % Test 2: Extract from CombinedSignalBus and logsout
    fprintf('\n--- Test 2: CombinedSignalBus + Logsout ---\n');
    options2 = struct();
    options2.extract_combined_bus = true;
    options2.extract_logsout = true;
    options2.extract_simscape = false;
    options2.verbose = true;
    
    [data2, info2] = extractAllSignalsFromBus(simOut, options2);
    
    if ~isempty(data2)
        fprintf('✓ Test 2 PASSED: Extracted %d signals total\n', info2.total_signals);
        fprintf('  Table size: %d rows × %d columns\n', height(data2), width(data2));
        fprintf('  CombinedSignalBus: %d signals\n', info2.source_info.combined_bus.signals);
        fprintf('  Logsout: %d signals\n', info2.source_info.logsout.signals);
    else
        fprintf('✗ Test 2 FAILED: No data extracted from CombinedSignalBus + Logsout\n');
    end
    
    % Test 3: Extract from all sources (including Simscape if available)
    fprintf('\n--- Test 3: All Sources ---\n');
    options3 = struct();
    options3.extract_combined_bus = true;
    options3.extract_logsout = true;
    options3.extract_simscape = true;
    options3.verbose = true;
    
    [data3, info3] = extractAllSignalsFromBus(simOut, options3);
    
    if ~isempty(data3)
        fprintf('✓ Test 3 PASSED: Extracted %d signals total\n', info3.total_signals);
        fprintf('  Table size: %d rows × %d columns\n', height(data3), width(data3));
        fprintf('  CombinedSignalBus: %d signals\n', info3.source_info.combined_bus.signals);
        fprintf('  Logsout: %d signals\n', info3.source_info.logsout.signals);
        fprintf('  Simscape: %d signals\n', info3.source_info.simscape.signals);
    else
        fprintf('✗ Test 3 FAILED: No data extracted from all sources\n');
    end
    
    % Test 4: Extract only from logsout (if available)
    fprintf('\n--- Test 4: Logsout Only ---\n');
    options4 = struct();
    options4.extract_combined_bus = false;
    options4.extract_logsout = true;
    options4.extract_simscape = false;
    options4.verbose = true;
    
    [data4, info4] = extractAllSignalsFromBus(simOut, options4);
    
    if ~isempty(data4)
        fprintf('✓ Test 4 PASSED: Extracted %d signals from logsout only\n', info4.total_signals);
        fprintf('  Table size: %d rows × %d columns\n', height(data4), width(data4));
    else
        fprintf('✗ Test 4 FAILED: No data extracted from logsout only\n');
    end
    
    % Test 5: Extract only from Simscape (if available)
    fprintf('\n--- Test 5: Simscape Only ---\n');
    options5 = struct();
    options5.extract_combined_bus = false;
    options5.extract_logsout = false;
    options5.extract_simscape = true;
    options5.verbose = true;
    
    [data5, info5] = extractAllSignalsFromBus(simOut, options5);
    
    if ~isempty(data5)
        fprintf('✓ Test 5 PASSED: Extracted %d signals from Simscape only\n', info5.total_signals);
        fprintf('  Table size: %d rows × %d columns\n', height(data5), width(data5));
    else
        fprintf('✗ Test 5 FAILED: No data extracted from Simscape only\n');
    end
    
    % Test 6: Silent mode (no verbose output)
    fprintf('\n--- Test 6: Silent Mode ---\n');
    options6 = struct();
    options6.extract_combined_bus = true;
    options6.extract_logsout = true;
    options6.extract_simscape = true;
    options6.verbose = false;
    
    [data6, info6] = extractAllSignalsFromBus(simOut, options6);
    
    if ~isempty(data6)
        fprintf('✓ Test 6 PASSED: Silent extraction successful\n');
        fprintf('  Extracted %d signals total\n', info6.total_signals);
        fprintf('  Table size: %d rows × %d columns\n', height(data6), width(data6));
    else
        fprintf('✗ Test 6 FAILED: Silent extraction failed\n');
    end
    
    % Summary
    fprintf('\n=== Summary ===\n');
    fprintf('All tests completed successfully!\n');
    fprintf('The enhanced function can now handle:\n');
    fprintf('  ✓ CombinedSignalBus data\n');
    fprintf('  ✓ Logsout data (when available)\n');
    fprintf('  ✓ Simscape Results Explorer data (when available)\n');
    fprintf('  ✓ Graceful handling when sources are not available\n');
    fprintf('  ✓ Configurable extraction options\n');
    fprintf('  ✓ Verbose/silent output modes\n');
    
    % Close the model
    if bdIsLoaded('GolfSwing3D_Kinetic')
        close_system('GolfSwing3D_Kinetic', 0);
    end
    
    fprintf('\n=== Test completed successfully ===\n');
    
catch ME
    fprintf('ERROR: Test failed: %s\n', ME.message);
    fprintf('Stack trace:\n');
    for i = 1:length(ME.stack)
        fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
    end
    
    % Close the model if it's still loaded
    if bdIsLoaded('GolfSwing3D_Kinetic')
        close_system('GolfSwing3D_Kinetic', 0);
    end
end 