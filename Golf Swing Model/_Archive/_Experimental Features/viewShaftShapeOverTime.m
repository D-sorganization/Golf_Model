function viewGroupedShaftShapeFromSDI()
% Improved: Automatically detects p(i) signals in SDI, correctly groups by coordinate (X/Y/Z), and animates shaft

    runIDs = Simulink.sdi.getAllRunIDs;
    runObj = Simulink.sdi.getRun(runIDs(end));

    % Collect all p(i) signals
    shaftSignals = struct('name', {}, 'idx', {}, 'coord', {}, 'node', {});
    for k = 1:runObj.signalCount
        s = runObj.getSignalByIndex(k);
        name = s.Name;
        if contains(name, 'Flexible_Cylindrical_Beam.p(')
            % Extract index number from name
            token = regexp(name, '\.p\((\d+)\)', 'tokens', 'once');
            if isempty(token), continue; end
            sigNum = str2double(token{1});

            coordType = mod(sigNum-2, 3); % 0:X, 1:Y, 2:Z
            nodeIdx = floor((sigNum-2)/3) + 1;

            shaftSignals(end+1).name = name; %#ok<AGROW>
            shaftSignals(end).idx = k;
            shaftSignals(end).coord = coordType + 1; % MATLAB is 1-indexed
            shaftSignals(end).node = nodeIdx;
        end
    end

    if isempty(shaftSignals)
        error('No shaft signals found in SDI.');
    end

    % Get time vector
    exampleSig = runObj.getSignalByIndex(shaftSignals(1).idx);
    t = exampleSig.Values.Time;
    numFrames = length(t);
    numNodes = max([shaftSignals.node]);

    shaftShape = nan(numFrames, numNodes, 3);

    for i = 1:length(shaftSignals)
        s = shaftSignals(i);
        sigObj = runObj.getSignalByIndex(s.idx);
        try
            shaftShape(:, s.node, s.coord) = sigObj.Values.Data;
        catch
            warning('Skipping invalid index s.node = %d or s.coord = %d', s.node, s.coord);
        end
    end

    % Plot GUI
    fig = figure('Name', 'Flexible Shaft Viewer');
    ax = axes('Position', [0.1, 0.3, 0.85, 0.65]);
    shaftPlot = plot3(NaN, NaN, NaN, 'o-', 'LineWidth', 2);
    grid on; axis equal;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('Flexible Shaft Shape from SDI');
    view(135, 25);

    uicontrol('Style', 'text', 'String', 'Frame:', ...
        'Units', 'normalized', 'Position', [0.1, 0.15, 0.1, 0.05]);

    frameSlider = uicontrol('Style', 'slider', ...
        'Min', 1, 'Max', numFrames, 'Value', 1, ...
        'SliderStep', [1/(numFrames-1), 10/(numFrames-1)], ...
        'Units', 'normalized', 'Position', [0.2, 0.15, 0.6, 0.05], ...
        'Callback', @(src, event) updatePlot(round(get(src, 'Value'))));

    frameLabel = uicontrol('Style', 'text', 'String', '1', ...
        'Units', 'normalized', 'Position', [0.82, 0.15, 0.1, 0.05]);

    updatePlot(1);

    function updatePlot(frameIdx)
        frameLabel.String = num2str(frameIdx);
        shape = squeeze(shaftShape(frameIdx, :, :));
        set(shaftPlot, 'XData', shape(:,1), 'YData', shape(:,2), 'ZData', shape(:,3));
        drawnow;
    end
end
