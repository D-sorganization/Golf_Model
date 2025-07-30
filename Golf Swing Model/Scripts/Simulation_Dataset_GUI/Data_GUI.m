function Data_GUI()
    % GolfSwingDataGenerator - Modern GUI for generating golf swing training data
    % Fixed polynomial order: At^6 + Bt^5 + Ct^4 + Dt^3 + Et^2 + Ft + G
    
    % Professional color scheme - softer, muted tones
    colors = struct();
    colors.primary = [0.4, 0.5, 0.6];        % Muted blue-gray
    colors.secondary = [0.5, 0.6, 0.7];      % Lighter blue-gray
    colors.success = [0.4, 0.6, 0.5];        % Muted green
    colors.danger = [0.7, 0.5, 0.5];         % Muted red
    colors.warning = [0.7, 0.6, 0.4];        % Muted amber
    colors.background = [0.96, 0.96, 0.97];  % Very light gray
    colors.panel = [1, 1, 1];                % White
    colors.text = [0.2, 0.2, 0.2];           % Dark gray
    colors.textLight = [0.6, 0.6, 0.6];      % Medium gray
    colors.border = [0.9, 0.9, 0.9];         % Light gray border
    
    % Create main figure
    screenSize = get(0, 'ScreenSize');
    figWidth = min(1600, screenSize(3) * 0.85);
    figHeight = min(900, screenSize(4) * 0.85);
    
    fig = figure('Name', 'Golf Swing Data Generator', ...
                 'Position', [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'Color', colors.background, ...
                 'CloseRequestFcn', @closeGUICallback);
    
    % Initialize handles structure with preferences
    handles = struct();
    handles.should_stop = false;
    handles.fig = fig;
    handles.colors = colors;
    handles.preferences = struct(); % Initialize empty preferences
    
    % Load user preferences
    handles = loadUserPreferences(handles);
    
    % Create main layout
    handles = createMainLayout(fig, handles);
    
    % Store handles in figure
    guidata(fig, handles);
    
    % Apply loaded preferences to UI
    applyUserPreferences(handles);
    
    % Initialize preview
    updatePreview([], [], handles.fig);
    updateCoefficientsPreview([], [], handles.fig);
end
