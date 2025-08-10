% FALLBACK SIMSCAPE EXTRACTION - Simple property inspection method
function [time_data, all_signals] = fallbackSimlogExtraction(simlog)
    time_data = [];
    all_signals = {};

    try
        % Method 1: Try direct property enumeration
        try
            props = properties(simlog);

            for i = 1:length(props)
                prop_name = props{i};
                if ~ismember(prop_name, {'id', 'savable', 'exportable'})
                    try
                        prop_value = simlog.(prop_name);
                        if isa(prop_value, 'simscape.logging.Node')
                            % Recursively extract from child nodes
                            [child_time, child_signals] = fallbackSimlogExtraction(prop_value);
                            if isempty(time_data) && ~isempty(child_time)
                                time_data = child_time;
                            end
                            all_signals = [all_signals, child_signals];
                        elseif isstruct(prop_value) || isa(prop_value, 'timeseries')
                            % Try to extract time series data
                            [extracted_time, extracted_data] = extractTimeSeriesData(prop_value, prop_name);
                            if ~isempty(extracted_time) && ~isempty(extracted_data)
                                if isempty(time_data)
                                    time_data = extracted_time;
                                end
                                signal_name = matlab.lang.makeValidName(prop_name);
                                all_signals{end+1} = struct('name', signal_name, 'data', extracted_data);
                                fprintf('Debug: Fallback found data in %s\n', prop_name);
                            end
                        elseif isstruct(prop_value)
                            % Try to extract constant matrix/vector data from struct
                            [constant_signals] = extractConstantMatrixData(prop_value, prop_name, []);
                            if ~isempty(constant_signals)
                                all_signals = [all_signals, constant_signals];
                                fprintf('Debug: Fallback found constant data in struct %s\n', prop_name);
                            end
                        elseif isnumeric(prop_value)
                            % Handle numeric arrays directly (constant matrices/vectors)
                            [constant_signals] = extractConstantMatrixData(prop_value, prop_name, []);
                            if ~isempty(constant_signals)
                                all_signals = [all_signals, constant_signals];
                                fprintf('Debug: Fallback found numeric data in %s\n', prop_name);
                            end
                        end
                    catch
                        continue;
                    end
                end
            end
        catch ME
            fprintf('Debug: Property enumeration failed: %s\n', ME.message);
        end

        % Method 2: Try common Simscape Multibody patterns
        if isempty(time_data) || isempty(all_signals)
            try
                % Look for common joint/body properties
                common_props = {'Px', 'Py', 'Pz', 'Vx', 'Vy', 'Vz', 'q', 'w', 'f', 't'};
                for i = 1:length(common_props)
                    prop = common_props{i};
                    if isprop(simlog, prop) || isfield(simlog, prop)
                        try
                            prop_data = simlog.(prop);
                            if isstruct(prop_data) && isfield(prop_data, 'series')
                                series_data = prop_data.series;
                                if isstruct(series_data) && isfield(series_data, 'time') && isfield(series_data, 'values')
                                    if isempty(time_data)
                                        time_data = series_data.time;
                                    end
                                    signal_name = matlab.lang.makeValidName(['fallback_' prop]);
                                    all_signals{end+1} = struct('name', signal_name, 'data', series_data.values);
                                    fprintf('Debug: Fallback found %s data\n', prop);
                                end
                            end
                        catch
                            continue;
                        end
                    end
                end
            catch ME
                fprintf('Debug: Common property search failed: %s\n', ME.message);
            end
        end

    catch ME
        fprintf('Debug: Fallback extraction failed: %s\n', ME.message);
    end

    if ~isempty(time_data) && ~isempty(all_signals)
        fprintf('Debug: Fallback extraction successful - found %d signals\n', length(all_signals));
    else
        fprintf('Debug: Fallback extraction found no data\n');
    end
end
