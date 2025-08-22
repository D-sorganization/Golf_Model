function gui_tab_manager(handles, action, varargin)
    % GUI_TAB_MANAGER - Manage GUI tab switching and navigation
    %
    % This function handles tab switching operations for the GUI,
    % including updating tab appearances and showing/hiding panels.
    %
    % Inputs:
    %   handles - GUI handles structure
    %   action - Action to perform: 'switch_to_generation', 'switch_to_postprocessing', 
    %            'switch_to_performance', 'get_current_tab', 'update_tab_appearances'
    %   varargin - Additional arguments depending on action
    %
    % Outputs:
    %   None (updates GUI handles and appearance)
    %
    % Usage:
    %   gui_tab_manager(handles, 'switch_to_generation');
    %   gui_tab_manager(handles, 'switch_to_postprocessing');
    %   gui_tab_manager(handles, 'switch_to_performance');
    %   current_tab = gui_tab_manager(handles, 'get_current_tab');
    %   gui_tab_manager(handles, 'update_tab_appearances');
    
    switch lower(action)
        case 'switch_to_generation'
            switchToGenerationTab(handles);
        case 'switch_to_postprocessing'
            switchToPostProcessingTab(handles);
        case 'switch_to_performance'
            switchToPerformanceTab(handles);
        case 'get_current_tab'
            current_tab = getCurrentTab(handles);
            if nargout > 0
                varargout{1} = current_tab;
            end
        case 'update_tab_appearances'
            updateTabAppearances(handles);
        otherwise
            error('Unknown action: %s', action);
    end
end

function switchToGenerationTab(handles)
    % SWITCHTOGENERATIONTAB - Switch to the data generation tab
    %
    % Inputs:
    %   handles - GUI handles structure
    
    handles.current_tab = 1;

    % Update tab appearances
    set(handles.generation_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');
    set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
    set(handles.performance_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');

    % Show/hide panels
    set(handles.generation_panel, 'Visible', 'on');
    set(handles.postprocessing_panel, 'Visible', 'off');
    set(handles.performance_panel, 'Visible', 'off');

    guidata(handles.fig, handles);
end

function switchToPostProcessingTab(handles)
    % SWITCHTOPOSTPROCESSINGTAB - Switch to the post-processing tab
    %
    % Inputs:
    %   handles - GUI handles structure
    
    handles.current_tab = 2;

    % Update tab appearances
    set(handles.generation_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
    set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');
    set(handles.performance_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');

    % Show/hide panels
    set(handles.generation_panel, 'Visible', 'off');
    set(handles.postprocessing_panel, 'Visible', 'on');
    set(handles.performance_panel, 'Visible', 'off');

    guidata(handles.fig, handles);
end

function switchToPerformanceTab(handles)
    % SWITCHTOPERFORMANCETAB - Switch to the performance tab
    %
    % Inputs:
    %   handles - GUI handles structure
    
    handles.current_tab = 3;

    % Update tab appearances
    set(handles.generation_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
    set(handles.postprocessing_tab, 'BackgroundColor', handles.colors.tabInactive, 'FontWeight', 'normal');
    set(handles.performance_tab, 'BackgroundColor', handles.colors.tabActive, 'FontWeight', 'bold');

    % Show/hide panels
    set(handles.generation_panel, 'Visible', 'off');
    set(handles.postprocessing_panel, 'Visible', 'off');
    set(handles.performance_panel, 'Visible', 'on');

    guidata(handles.fig, handles);
end

function current_tab = getCurrentTab(handles)
    % GETCURRENTTAB - Get the current active tab
    %
    % Inputs:
    %   handles - GUI handles structure
    %
    % Outputs:
    %   current_tab - Current tab number (1, 2, or 3)
    
    if isfield(handles, 'current_tab')
        current_tab = handles.current_tab;
    else
        current_tab = 1; % Default to generation tab
    end
end

function updateTabAppearances(handles)
    % UPDATETABAPPEARANCES - Update tab appearances based on current tab
    %
    % Inputs:
    %   handles - GUI handles structure
    
    current_tab = getCurrentTab(handles);
    
    switch current_tab
        case 1
            switchToGenerationTab(handles);
        case 2
            switchToPostProcessingTab(handles);
        case 3
            switchToPerformanceTab(handles);
        otherwise
            % Default to generation tab
            switchToGenerationTab(handles);
    end
end

function togglePlayPause(handles)
    % TOGGLEPLAYPAUSE - Toggle play/pause state for processing
    %
    % Inputs:
    %   handles - GUI handles structure
    
    if handles.is_paused
        % Resume from pause
        handles.is_paused = false;
        set(handles.play_pause_button, 'String', '⏸️ Pause', 'BackgroundColor', handles.colors.warning);
        
        % Resume processing
        checkpoint_manager(handles, 'resume');
        
    else
        % Pause processing
        handles.is_paused = true;
        set(handles.play_pause_button, 'String', '▶️ Resume', 'BackgroundColor', handles.colors.success);
        
        % Save checkpoint
        checkpoint_manager(handles, 'save');
    end
    
    guidata(handles.fig, handles);
end

function stopProcessing(handles)
    % STOPPROCESSING - Stop all processing operations
    %
    % Inputs:
    %   handles - GUI handles structure
    
    % Set stop flag
    handles.stop_requested = true;
    
    % Update button appearance
    set(handles.stop_button, 'String', '⏹️ Stopping...', 'BackgroundColor', handles.colors.error);
    
    % Update status
    set(handles.status_text, 'String', 'Stopping processing...', 'ForegroundColor', handles.colors.error);
    
    guidata(handles.fig, handles);
end

function resetProcessing(handles)
    % RESETPROCESSING - Reset processing state
    %
    % Inputs:
    %   handles - GUI handles structure
    
    % Reset flags
    handles.is_paused = false;
    handles.stop_requested = false;
    
    % Reset buttons
    set(handles.play_pause_button, 'String', '⏸️ Pause', 'BackgroundColor', handles.colors.warning);
    set(handles.stop_button, 'String', '⏹️ Stop', 'BackgroundColor', handles.colors.error);
    
    % Reset status
    set(handles.status_text, 'String', 'Ready', 'ForegroundColor', handles.colors.text);
    
    % Clear progress
    set(handles.progress_bar, 'Value', 0);
    set(handles.progress_text, 'String', '');
    
    guidata(handles.fig, handles);
end

function updateProgressBar(handles, progress_ratio)
    % UPDATEPROGRESSBAR - Update progress bar display
    %
    % Inputs:
    %   handles - GUI handles structure
    %   progress_ratio - Progress ratio (0.0 to 1.0)
    
    % Ensure progress is within bounds
    progress_ratio = max(0, min(1, progress_ratio));
    
    % Update progress bar
    set(handles.progress_bar, 'Value', progress_ratio);
    
    % Update progress text
    progress_percent = round(progress_ratio * 100);
    set(handles.progress_text, 'String', sprintf('%d%% Complete', progress_percent));
    
    % Force GUI update
    drawnow;
end

function updateStatusText(handles, message, color)
    % UPDATESTATUSTEXT - Update status text display
    %
    % Inputs:
    %   handles - GUI handles structure
    %   message - Status message to display
    %   color - Color for the message (optional)
    
    if nargin < 3
        color = handles.colors.text;
    end
    
    set(handles.status_text, 'String', message, 'ForegroundColor', color);
    drawnow;
end

function logMessage(handles, message)
    % LOGMESSAGE - Add message to log display
    %
    % Inputs:
    %   handles - GUI handles structure
    %   message - Message to log
    
    try
        % Get current log content
        current_log = get(handles.log_text, 'String');
        
        % Add timestamp
        timestamp = datestr(now, 'HH:MM:SS');
        log_entry = sprintf('[%s] %s', timestamp, message);
        
        % Add to log
        if iscell(current_log)
            new_log = [current_log; {log_entry}];
        else
            new_log = {log_entry};
        end
        
        % Update log display
        set(handles.log_text, 'String', new_log);
        
        % Scroll to bottom
        set(handles.log_text, 'Value', length(new_log));
        
        % Force GUI update
        drawnow;
        
    catch ME
        fprintf('Error logging message: %s\n', ME.message);
    end
end

function clearLog(handles)
    % CLEARLOG - Clear the log display
    %
    % Inputs:
    %   handles - GUI handles structure
    
    set(handles.log_text, 'String', {});
    drawnow;
end
