% ENHANCED: Extract from Simscape with detailed diagnostics
function simscape_data = extractSimscapeDataRecursive(simlog)
    simscape_data = table();  % Empty table if no data

    try
        % DETAILED DIAGNOSTICS
        fprintf('=== SIMSCAPE DIAGNOSTIC START ===\n');
        
        if isempty(simlog)
            fprintf('❌ simlog is EMPTY\n');
            fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');
            return;
        end
        
        fprintf('✅ simlog exists, class: %s\n', class(simlog));
        
        if ~isa(simlog, 'simscape.logging.Node')
            fprintf('❌ simlog is not a simscape.logging.Node\n');
            fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');
            return;
        end
        
        fprintf('✅ simlog is valid simscape.logging.Node\n');
        
        % Try to inspect the simlog structure
        try
            fprintf(' Inspecting simlog properties...\n');
            props = properties(simlog);
            fprintf('   Properties: %s\n', strjoin(props, ', '));
        catch
            fprintf('❌ Could not get simlog properties\n');
        end
        
        % Try to get children (properties ARE the children in Multibody)
        try
            children_ids = simlog.children();
            fprintf('✅ Found %d top-level children: %s\n', length(children_ids), strjoin(children_ids, ', '));
        catch ME
            fprintf('❌ Could not get children method: %s\n', ME.message);
            fprintf(' Using properties as children (Multibody approach)\n');
            
            % Get properties excluding system properties
            all_props = properties(simlog);
            children_ids = {};
            for i = 1:length(all_props)
                prop_name = all_props{i};
                % Skip system properties, keep actual joint/body names
                if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                    children_ids{end+1} = prop_name;
                end
            end
            fprintf('✅ Found %d children from properties: %s\n', length(children_ids), strjoin(children_ids, ', '));
        end
        
        % Try to inspect first child
        if ~isempty(children_ids)
            try
                first_child_id = children_ids{1};
                first_child = simlog.(first_child_id);
                fprintf(' First child (%s) class: %s\n', first_child_id, class(first_child));
                
                % Try to get series from first child
                try
                    series_children = first_child.series.children();
                    fprintf('✅ First child has %d series: %s\n', length(series_children), strjoin(series_children, ', '));
                catch ME2
                    fprintf('❌ First child series access failed: %s\n', ME2.message);
                end
                
            catch ME
                fprintf('❌ Could not inspect first child: %s\n', ME.message);
            end
        end
        
        fprintf('=== SIMSCAPE DIAGNOSTIC END ===\n');

        % Recursively collect all series data using primary traversal method
        [time_data, all_signals] = traverseSimlogNode(simlog, '');

        if isempty(time_data) || isempty(all_signals)
            fprintf('⚠️  Primary method found no data. Trying fallback methods...\n');
            
            % FALLBACK METHOD: Simple property inspection
            [time_data, all_signals] = fallbackSimlogExtraction(simlog);
            
            if isempty(time_data) || isempty(all_signals)
                fprintf('❌ All extraction methods failed. No usable Simscape data found.\n');
                return;
            else
                fprintf('✅ Fallback method found data!\n');
            end
        else
            fprintf('✅ Primary method found data!\n');
        end

        % Build table
        data_cells = {time_data};
        var_names = {'time'};
        expected_length = length(time_data);

        for i = 1:length(all_signals)
            signal = all_signals{i};
            if length(signal.data) == expected_length
                data_cells{end+1} = signal.data(:);
                var_names{end+1} = signal.name;
                fprintf('Debug: Added Simscape signal: %s (length: %d)\n', signal.name, expected_length);
            else
                fprintf('Debug: Skipped %s (length mismatch: %d vs %d)\n', signal.name, length(signal.data), expected_length);
            end
        end

        if length(data_cells) > 1
            simscape_data = table(data_cells{:}, 'VariableNames', var_names);
            fprintf('Debug: Created Simscape table with %d columns, %d rows.\n', width(simscape_data), height(simscape_data));
        else
            fprintf('Debug: Only time data found in Simscape log.\n');
        end

    catch ME
        fprintf('Error extracting Simscape data recursively: %s\n', ME.message);
    end
end 