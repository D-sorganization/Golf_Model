function ClubDataGUI_PROMPT_FINAL()

    function ClubDataGUI_PROMPT_CLEANED()
        % ClubDataGUI: Load and animate golf club data with improved error handling and structure.
        % --- 1. Initialization ---
        % Define data column indices (for clarity and maintainability)
        COL.TIME = 2;
        COL.MIDHANDS = 3:5;
        COL.CLUBFACE = 15:17;
        COL.HAND_X = 6:8;
        COL.HAND_Y = 9:11;
        COL.HAND_Z = 12:14;
        COL.CLUB_X = 18:20;
        COL.CLUB_Y = 21:23;
        COL.CLUB_Z = 24:26;
        % Default data file
    [filename, pathname] = uigetfile('*.xlsx', 'Select Data File');
    if isequal(filename,0)
        errordlg('No file selected.');
        return;
    end
    defaultFile = fullfile(pathname, filename);
        end
        % Get sheet names, excluding "Definitions"
        try
            [~, allSheets] = xlsfinfo(defaultFile);
            dataSheets = allSheets(~strcmp(allSheets, 'Definitions')); % Exclude "Definitions"
            if isempty(dataSheets)
                return;
            end
        catch ME
            return;
        end
        % --- 2. Create the GUI ---
        fig = figure('Name', 'Clubface Animation GUI', 'NumberTitle', 'off', ...
            'Color', [1 1 1], 'Position', [100 100 1200 700]);
        handles.fig = fig;  % Store figure handle
        % Axes for 3D plot
        handles.ax = axes('Parent', fig, 'Position', [0.3 0.25 0.65 0.7]);
        axis equal; grid on; view(handles.ax, [180 0]);
        xlabel('X'); ylabel('Y'); zlabel('Z'); hold(handles.ax, 'on');
        % Control panel
        handles.panel = uipanel('Parent', fig, 'Title', 'Controls', 'FontSize', 10, ...
            'Units', 'normalized', 'Position', [0.01 0.25 0.25 0.7]);
        % File path display (static text)
        uicontrol('Parent', handles.panel, 'Style', 'text', 'String', 'Data File:', ...
            'Units', 'normalized', 'Position', [0.05 0.95 0.9 0.03]);
        handles.filepathText = uicontrol('Parent', handles.panel, 'Style', 'text', 'String', defaultFile, ...
            'Units', 'normalized', 'Position', [0.05 0.92 0.9 0.03], 'HorizontalAlignment', 'left');
        % Worksheet selection
        uicontrol('Parent', handles.panel, 'Style', 'text', 'String', 'Worksheet:', ...
            'Units', 'normalized', 'Position', [0.1 0.87 0.8 0.05]);
        handles.sheetMenu = uicontrol('Parent', handles.panel, ...
            'Style', 'popupmenu', ...
            'String', dataSheets, ... % Use dataSheets here
            'Units', 'normalized', ...
            'Position', [0.1 0.82 0.8 0.05], ...
            'Callback', @(src, ~) plotSheet(src, handles, COL)) % Pass handles & COL
        % Axis Toggles
        labels = {'Club X', 'Club Y', 'Club Z', 'Hand X', 'Hand Y', 'Hand Z'};
        for i = 1:6
            handles.axisToggles(i) = uicontrol('Parent', handles.panel, 'Style', 'checkbox', ...
                'String', labels{i}, 'Value', 1, ...
                'Units', 'normalized', 'Position', [0.1 0.65 - 0.04 * i 0.8 0.04]);
        
        % Angle display
        handles.angleLabel = uicontrol('Parent', handles.panel, 'Style', 'text', ...
            'String', 'X: ---  Y: ---  Z: ---', 'Units', 'normalized', ...
            'Position', [0.1 0.12 0.8 0.05], 'FontSize', 10);
        % Play/Pause button
        handles.playBtn = uicontrol('Parent', handles.panel, 'Style', 'togglebutton', ...
            'String', 'Play/Pause', 'Units', 'normalized', ...
            'Position', [0.1 0.06 0.8 0.05], 'Callback', @(src, handles) togglePlayback(src, handles));
        % Frame slider
        handles.frameSlider = uicontrol('Parent', fig, 'Style', 'slider', ...
            'Min', 1, 'Max', 100, 'Value', 1, ...
            'SliderStep', [0.01 0.1], ...
            'Units', 'normalized', 'Position', [0.3 0.01 0.65 0.03], ...
            'Callback', @(src, handles) updateFrameFromSlider(src, handles));
        % Store handles structure
        guidata(fig, handles);
        % --- 3. Initial Plot ---
        try
            plotSheet(handles.sheetMenu, handles, COL); % Initial plot
        catch ME
        end
    end
    % --- Subfunctions ---

    function plotSheet(src, handles, COL)
        % plotSheet: Loads data from the selected sheet and initializes the plot.
        sheetname = get(src, 'String');
        if iscell(sheetname)
            selectedSheet = sheetname{get(src, 'Value')};
        else
            selectedSheet = sheetname;
        end
        try
            % Dynamically determine the data range (find last row with data)
            [~, ~, raw] = xlsread(handles.filepath, selectedSheet);
            lastRow = find(all(cellfun(@isempty, raw), 2), 1, 'first') - 1;
            if isempty(lastRow)
                lastRow = size(raw, 1);
            end
            dataRange = ['A4:Z' num2str(lastRow)];  % Assuming data starts from row 4
            data = readmatrix(handles.filepath, 'Sheet', selectedSheet, 'Range', dataRange);
        catch ME
            return;
        end
        % Data validation (basic check; improve as needed)
        if size(data, 2) < max([struct2array(COL)])
            return;
        end
        % Extract data
        handles.time = data(:, COL.TIME);
        handles.midhands = data(:, COL.MIDHANDS) / 100;
        handles.clubface = data(:, COL.CLUBFACE) / 100;
        % Midhands direction cosines
        Xh = data(:, COL.HAND_X);
        Yh = data(:, COL.HAND_Y);
        if size(data, 2) >= COL.HAND_Z(end) && any(data(:, COL.HAND_Z), 'all')
            Zh = data(:, COL.HAND_Z);
        else
            Zh = cross(Xh, Yh, 2);
            Zh = Zh ./ vecnorm(Zh, 2, 2);
        end
        % Clubface direction cosines
        Xc = data(:, COL.CLUB_X);
        Yc = data(:, COL.CLUB_Y);
        if size(data, 2) >= COL.CLUB_Z(end) && any(data(:, COL.CLUB_Z), 'all')
            Zc = data(:, COL.CLUB_Z);
        else
            Zc = cross(Xc, Yc, 2);
            Zc = Zc ./ vecnorm(Zc, 2, 2);
        end
        handles.handAxes = cat(3, Xh, Yh, Zh);
        handles.clubAxes = cat(3, Xc, Yc, Zc);
        % Fixed axis limits
        allX = [handles.midhands(:, 1); handles.clubface(:, 1)];
        allY = [handles.midhands(:, 2); handles.clubface(:, 2)];
        allZ = [handles.midhands(:, 3); handles.clubface(:, 3)];
        pad = 0.1;
        handles.xlim = [min(allX) - pad, max(allX) + pad];
        handles.ylim = [min(allY) - pad, max(allY) + pad];
        handles.zlim = [min(allZ) - pad, max(allZ) + pad];
        set(handles.ax, 'XLim', handles.xlim, 'YLim', handles.ylim, 'ZLim', handles.zlim);
        % Initialize plot objects
        cla(handles.ax);
        handles.lineObj = plot3(handles.ax, NaN, NaN, NaN, 'k-', 'LineWidth', 2, 'Parent', handles.ax);
        colors = {'r', 'g', 'b'};
        for j = 1:3
            handles.(['quiverClub' colors{j}]) = quiver3(handles.ax, 0, 0, 0, 0, 0, 0, colors{j}, 'LineWidth', 1.5);
            handles.(['quiverHands' colors{j}]) = quiver3(handles.ax, 0, 0, 0, 0, 0, 0, colors{j}, 'LineWidth', 1.5, 'LineStyle', '--');
        end
        % Initialize frame slider
        handles.frame = 1;
        set(handles.frameSlider, 'Min', 1, 'Max', size(handles.midhands, 1), 'Value', 1, ...
            'SliderStep', [1 / (size(handles.midhands, 1) - 1) 0.1]);
        % Update handles structure
        guidata(src, handles);
        animateFrame(handles); % Show the first frame
    end

    function togglePlayback(src, handles)
        % togglePlayback:  Handles the play/pause button.
        while get(src, 'Value') && ishandle(src)
            handles = guidata(src); % Get updated handles
            if handles.frame > size(handles.midhands, 1)
                handles.frame = 1; % Loop animation
            end
            animateFrame(handles);
            set(handles.frameSlider, 'Value', handles.frame);
            handles.frame = handles.frame + 1;
            guidata(src, handles);
            pause(1 / 240); % Animation speed (adjust as needed)
        end
    end

    function animateFrame(handles)
        % animateFrame:  Updates the plot for the current frame.
        i = handles.frame;
        if i > size(handles.midhands, 1)
            return
        end
        A = handles.midhands(i, :);
        B = handles.clubface(i, :);
        shaftLength = norm(B - A);
        scale = 0.1 * shaftLength;
        angles = zeros(1, 3);
        colors = {'r', 'g', 'b'};
        for j = 1:3
            vecC = handles.clubAxes(i, :, j);
            vecC = vecC / (norm(vecC) + 1e-8); % Normalize
            vecH = handles.handAxes(i, :, j);
            vecH = vecH / (norm(vecH) + 1e-8);
            set(handles.(['quiverClub' colors{j}]), 'XData', B(1), 'YData', B(2), 'ZData', B(3), ...
                'UData', scale * vecC(1), 'VData', scale * vecC(2), 'WData', scale * vecC(3), ...
                'Visible', ternary(get(handles.axisToggles(j), 'Value'), 'on', 'off'));
            set(handles.(['quiverHands' colors{j}]), 'XData', A(1), 'YData', A(2), 'ZData', A(3), ...
                'UData', scale * vecH(1), 'VData', scale * vecH(2), 'WData', scale * vecH(3), ...
                'Visible', ternary(get(handles.axisToggles(j + 3), 'Value'), 'on', 'off'));
            angles(j) = acosd(dot(vecC, vecH));
        end
        set(handles.lineObj, 'XData', [A(1) B(1)], 'YData', [A(2) B(2)], 'ZData', [A(3) B(3)]);
        set(handles.angleLabel, 'String', sprintf('X: %.1f°  Y: %.1f°  Z: %.1f°', angles));
        drawnow;
    end

    function updateFrameFromSlider(src, handles)
        % updateFrameFromSlider: Updates the plot based on the slider position.
        handles = guidata(src);
        handles.frame = round(get(src, 'Value'));
        guidata(src, handles);
        animateFrame(handles);
    end

    function val = ternary(cond, t, f)
        % ternary:  A simple ternary conditional function.
        if cond
            val = t;
        else
            val = f;
        end
    end
        % errorMessage: Displays an error dialog with the given message.
    end
end