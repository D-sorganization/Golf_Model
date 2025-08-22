classdef lightweight_timer < handle
    % LIGHTWEIGHT_TIMER - Simple, fast performance timing without memory overhead
    %
    % This class provides basic timing functionality using tic/toc:
    % - Function execution times
    % - Phase timing for data generation
    % - Simple performance reporting
    % - No memory monitoring (which was causing slowdowns)
    %
    % Usage:
    %   timer = lightweight_timer();
    %   timer.start('operation_name');
    %   % ... perform operation ...
    %   timer.stop('operation_name');
    %   timer.report();

    properties (Access = private)
        timers = containers.Map('KeyType', 'char', 'ValueType', 'any');
        start_times = containers.Map('KeyType', 'char', 'ValueType', 'any');
        operation_counts = containers.Map('KeyType', 'char', 'ValueType', 'double');
        total_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
        min_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
        max_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
        is_enabled = true;
        session_start_time = [];
        session_id = '';
    end

    methods
        function obj = lightweight_timer()
            % Constructor - Initialize the lightweight timer
            obj.session_start_time = tic;
            obj.session_id = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

            % Initialize containers
            obj.timers = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.start_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.operation_counts = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.total_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.min_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.max_times = containers.Map('KeyType', 'char', 'ValueType', 'double');

            fprintf('⏱️  Lightweight timer initialized (Session: %s)\n', obj.session_id);
        end

        function start(obj, operation_name)
            % Start timing an operation
            if ~obj.is_enabled
                return;
            end

            % Record start time using tic
            obj.start_times(operation_name) = tic;

            fprintf('⏱️  Started: %s\n', operation_name);
        end

        function stop(obj, operation_name)
            % Stop timing an operation and record results
            if ~obj.is_enabled || ~obj.start_times.isKey(operation_name)
                return;
            end

            % Calculate elapsed time using toc
            elapsed_time = toc(obj.start_times(operation_name));

            % Update statistics
            if obj.operation_counts.isKey(operation_name)
                obj.operation_counts(operation_name) = obj.operation_counts(operation_name) + 1;
                obj.total_times(operation_name) = obj.total_times(operation_name) + elapsed_time;
                obj.min_times(operation_name) = min(obj.min_times(operation_name), elapsed_time);
                obj.max_times(operation_name) = max(obj.max_times(operation_name), elapsed_time);
            else
                obj.operation_counts(operation_name) = 1;
                obj.total_times(operation_name) = elapsed_time;
                obj.min_times(operation_name) = elapsed_time;
                obj.max_times(operation_name) = elapsed_time;
            end

            % Store results
            obj.timers(operation_name) = struct(...
                'elapsed_time', elapsed_time, ...
                'timestamp', now() ...
                );

            fprintf('⏱️  Completed: %s (%.3f seconds)\n', operation_name, elapsed_time);
        end

        function time_function(obj, operation_name, func_handle, varargin)
            % Time a function execution with automatic start/stop
            if ~obj.is_enabled
                result = func_handle(varargin{:});
                return;
            end

            obj.start(operation_name);
            try
                result = func_handle(varargin{:});
                obj.stop(operation_name);
            catch ME
                obj.stop(operation_name);
                rethrow(ME);
            end
        end

        function report = get_timing_report(obj)
            % Generate simple timing report
            if ~obj.is_enabled
                report = struct('message', 'Timing is disabled');
                return;
            end

            session_duration = toc(obj.session_start_time);

            % Collect all operation names
            operation_names = obj.timers.keys();

            % Build report
            report = struct();
            report.session_info = struct(...
                'session_id', obj.session_id, ...
                'session_duration', session_duration, ...
                'total_operations', length(operation_names), ...
                'timestamp', now() ...
                );

            % Operation details
            report.operations = struct();
            for i = 1:length(operation_names)
                op_name = operation_names{i};
                if obj.timers.isKey(op_name)
                    timer_data = obj.timers(op_name);

                    % Calculate statistics
                    count = obj.operation_counts(op_name);
                    total_time = obj.total_times(op_name);
                    avg_time = total_time / count;
                    min_time = obj.min_times(op_name);
                    max_time = obj.max_times(op_name);

                    report.operations.(op_name) = struct(...
                        'count', count, ...
                        'total_time', total_time, ...
                        'average_time', avg_time, ...
                        'min_time', min_time, ...
                        'max_time', max_time, ...
                        'last_execution', timer_data.elapsed_time, ...
                        'timestamp', timer_data.timestamp ...
                        );
                end
            end

            % Performance summary
            report.summary = obj.generate_summary(report);
        end

        function display_timing_report(obj)
            % Display formatted timing report
            report = obj.get_timing_report();

            fprintf('\n📊 TIMING REPORT\n');
            fprintf('=====================================\n');
            fprintf('Session ID: %s\n', report.session_info.session_id);
            fprintf('Session Duration: %.2f seconds\n', report.session_info.session_duration);
            fprintf('Total Operations: %d\n', report.session_info.total_operations);
            fprintf('\n');

            % Display operation details
            operation_names = fieldnames(report.operations);
            if ~isempty(operation_names)
                fprintf('OPERATION DETAILS:\n');
                fprintf('%-30s %8s %8s %8s %8s %8s\n', ...
                    'Operation', 'Count', 'Total(s)', 'Avg(s)', 'Min(s)', 'Max(s)');
                fprintf('%-30s %8s %8s %8s %8s %8s\n', ...
                    '---------', '-----', '-------', '-----', '-----', '-----');

                for i = 1:length(operation_names)
                    op_name = operation_names{i};
                    op_data = report.operations.(op_name);

                    fprintf('%-30s %8d %8.3f %8.3f %8.3f %8.3f\n', ...
                        op_name, ...
                        op_data.count, ...
                        op_data.total_time, ...
                        op_data.average_time, ...
                        op_data.min_time, ...
                        op_data.max_time);
                end
                fprintf('\n');
            end

            % Display summary
            if isfield(report, 'summary')
                fprintf('SUMMARY:\n');
                fprintf('  Total Time: %.3f seconds\n', report.summary.total_time);
                fprintf('  Slowest Operation: %s (%.3f seconds)\n', ...
                    report.summary.slowest_operation, report.summary.slowest_time);
                fprintf('  Fastest Operation: %s (%.3f seconds)\n', ...
                    report.summary.fastest_operation, report.summary.fastest_time);
                fprintf('\n');
            end
        end

        function save_timing_report(obj, filename)
            % Save timing report to file
            if nargin < 2
                filename = sprintf('timing_report_%s.mat', obj.session_id);
            end

            report = obj.get_timing_report();
            save(filename, 'report');
            fprintf('💾 Timing report saved to: %s\n', filename);
        end

        function export_timing_csv(obj, filename)
            % Export timing data to CSV format
            if nargin < 2
                filename = sprintf('timing_data_%s.csv', obj.session_id);
            end

            report = obj.get_timing_report();
            operation_names = fieldnames(report.operations);

            % Create table for CSV export
            data_table = table();
            for i = 1:length(operation_names)
                op_name = operation_names{i};
                op_data = report.operations.(op_name);

                row = table({op_name}, op_data.count, op_data.total_time, ...
                    op_data.average_time, op_data.min_time, op_data.max_time, ...
                    'VariableNames', {'Operation', 'Count', 'TotalTime', ...
                    'AverageTime', 'MinTime', 'MaxTime'});

                data_table = [data_table; row];
            end

            writetable(data_table, filename);
            fprintf('📊 Timing data exported to: %s\n', filename);
        end

        function enable_timing(obj)
            % Enable timing
            obj.is_enabled = true;
            fprintf('⏱️  Timing enabled\n');
        end

        function disable_timing(obj)
            % Disable timing
            obj.is_enabled = false;
            fprintf('⏱️  Timing disabled\n');
        end

        function clear_history(obj)
            % Clear all timing history
            obj.timers = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.start_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.operation_counts = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.total_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.min_times = containers.Map('KeyType', 'char', 'ValueType', 'double');
            obj.max_times = containers.Map('KeyType', 'char', 'ValueType', 'double');

            fprintf('🗑️  Timing history cleared\n');
        end
    end

    methods (Access = private)
        function summary = generate_summary(obj, report)
            % Generate timing summary
            operation_names = fieldnames(report.operations);

            if isempty(operation_names)
                summary = struct('total_time', 0, 'slowest_operation', '', 'fastest_operation', '');
                return;
            end

            total_time = 0;
            slowest_op = '';
            fastest_op = '';
            slowest_time = 0;
            fastest_time = inf;

            for i = 1:length(operation_names)
                op_name = operation_names{i};
                op_data = report.operations.(op_name);

                total_time = total_time + op_data.total_time;

                if op_data.average_time > slowest_time
                    slowest_time = op_data.average_time;
                    slowest_op = op_name;
                end

                if op_data.average_time < fastest_time
                    fastest_time = op_data.average_time;
                    fastest_op = op_name;
                end
            end

            summary = struct(...
                'total_time', total_time, ...
                'slowest_operation', slowest_op, ...
                'fastest_operation', fastest_op, ...
                'slowest_time', slowest_time, ...
                'fastest_time', fastest_time ...
                );
        end
    end
end
