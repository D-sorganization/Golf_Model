function [time_data, signals] = traverseSimlogNode(node, parent_path)
    % External function for traversing Simscape log nodes - can be used in parallel processing
    % This function doesn't rely on handles
    
    time_data = [];
    signals = {};
    
    try
        % Get current node name
        node_name = '';
        if all(isprop(node, 'Name')) && all(~isempty(node.Name))
            node_name = node.Name;
        elseif all(isprop(node, 'id')) && all(~isempty(node.id))
            node_name = node.id;
        else
            node_name = 'UnnamedNode';
        end
        current_path = fullfile(parent_path, node_name);
        
        % SIMSCAPE MULTIBODY APPROACH: Try multiple extraction methods
        node_has_data = false;
        
        % Method 1: Check if node has direct data (time series)
        if all(isprop(node, 'time')) && all(isprop(node, 'values'))
            try
                extracted_time = node.time;
                extracted_data = node.values;
                
                if all(~isempty(extracted_time)) && all(~isempty(extracted_data)) && numel(extracted_time) > 0
                    if isempty(time_data)
                        time_data = extracted_time;
                    end
                    
                    % Create meaningful signal name
                    signal_name = matlab.lang.makeValidName(sprintf('%s_data', current_path));
                    signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                    node_has_data = true;
                end
            catch ME
                % Method 1 failed - this is normal for non-data nodes
            end
        end
        
        % Method 2: Extract data from 5-level Multibody hierarchy (regardless of exportable flag)
        if ~node_has_data && all(isprop(node, 'series'))
            try
                % Get the signal ID (e.g., 'w' for angular velocity, 'q' for position)
                signal_id = 'data';
                if all(isprop(node, 'id')) && all(~isempty(node.id))
                    signal_id = node.id;
                end
                
                % Try to get time and data directly from node.series (the correct API)
                try
                    extracted_time = node.series.time;
                    extracted_data = node.series.values;
                catch
                    % Fallback: try to access as properties
                    if all(isprop(node.series, 'time'))
                        extracted_time = node.series.time;
                    else
                        extracted_time = [];
                    end
                    if all(isprop(node.series, 'values'))
                        extracted_data = node.series.values;
                    else
                        extracted_data = [];
                    end
                end
                
                if all(~isempty(extracted_time)) && all(~isempty(extracted_data)) && numel(extracted_time) > 0
                    if isempty(time_data)
                        time_data = extracted_time;
                    end
                    
                    % Create meaningful signal name: Body_Joint_Component_Axis_Signal
                    signal_name = matlab.lang.makeValidName(sprintf('%s_%s', current_path, signal_id));
                    signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                    node_has_data = true;
                end
            catch ME
                % Series access failed - this is normal for non-data nodes
            end
        end
        
        % Method 3: Try to get children and recurse
        if ~node_has_data
            try
                % Try different methods to get children
                child_ids = {};
                
                % Method 3a: Try properties() approach
                try
                    props = properties(node);
                    child_ids = props;
                catch
                    % Method 3b: Try direct children access
                    try
                        if all(isprop(node, 'children'))
                            child_ids = node.children;
                        end
                    catch
                        % Method 3c: Try series.children() if available
                        try
                            if all(isprop(node, 'series')) && all(isprop(node.series, 'children'))
                                child_ids = node.series.children;
                            end
                        catch
                            % No children method available
                        end
                    end
                end
                
                % Process children
                for i = 1:length(child_ids)
                    try
                        child_node = node.(child_ids{i});
                        [child_time, child_signals] = traverseSimlogNode(child_node, current_path);
                        
                        % Merge time (use first valid)
                        if isempty(time_data) && all(~isempty(child_time))
                            time_data = child_time;
                        end
                        
                        % Merge signals
                        signals = [signals, child_signals];
                        
                    catch ME
                        % Skip this child if there's an error
                    end
                end
                
            catch ME
                % No children method available - this is normal for leaf nodes
            end
        end
        
    catch ME
        % Only show error if it's not a normal "no data" case
        if ~contains(ME.message, 'brace indexing') && ~contains(ME.message, 'comma separated list')
            fprintf('Error traversing Simscape node: %s\n', ME.message);
        end
    end
end 