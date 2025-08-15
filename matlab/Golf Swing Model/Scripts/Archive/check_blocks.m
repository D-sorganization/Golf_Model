% Check block balance in the main script
fid = fopen('generateSimulationTrainingData.m', 'r');
if fid == -1
    error('Could not open file');
end

line_num = 0;
block_stack = {};
try_count = 0;
catch_count = 0;

while ~feof(fid)
    line = fgetl(fid);
    line_num = line_num + 1;

    if ~ischar(line)
        break;
    end

    % Remove comments and strings for cleaner parsing
    line = regexprep(line, '%.*$', '');
    line = strtrim(line);

    % Skip empty lines
    if isempty(line)
        continue;
    end

    % Check for opening blocks
    if ~isempty(regexp(line, '^\s*(if|for|while|parfor|function|switch|try)\s', 'once'))
        if contains(line, 'try')
            try_count = try_count + 1;
            fprintf('Line %d: TRY #%d - %s\n', line_num, try_count, line);
        end
        block_stack{end+1} = sprintf('Line %d: %s', line_num, line);
    end

    % Check for closing blocks
    if ~isempty(regexp(line, '^\s*end\s*$', 'once'))
        if ~isempty(block_stack)
            popped = block_stack{end};
            block_stack(end) = [];
            fprintf('Line %d: END closes - %s\n', line_num, popped);
        else
            fprintf('Line %d: UNMATCHED END!\n', line_num);
        end
    end

    % Check for catch
    if ~isempty(regexp(line, '^\s*catch\s', 'once'))
        catch_count = catch_count + 1;
        fprintf('Line %d: CATCH #%d - %s\n', line_num, catch_count, line);
    end
end

fclose(fid);

fprintf('\nSummary:\n');
fprintf('Try blocks: %d\n', try_count);
fprintf('Catch blocks: %d\n', catch_count);
fprintf('Unclosed blocks: %d\n', length(block_stack));

if ~isempty(block_stack)
    fprintf('Unclosed blocks:\n');
    for i = 1:length(block_stack)
        fprintf('  %s\n', block_stack{i});
    end
end
