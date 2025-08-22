function checkpoint_manager(handles, action, varargin)
    % CHECKPOINT_MANAGER - Manage checkpoint operations for the GUI
    %
    % This function handles saving, loading, and managing checkpoints
    % for the simulation process.
    %
    % Inputs:
    %   handles - GUI handles structure
    %   action - Action to perform: 'save', 'reset_button', 'resume', 
    %            'get_progress', 'clear_all'
    %   varargin - Additional arguments depending on action
    %
    % Outputs:
    %   None (updates handles structure)
    %
    % Usage:
    %   checkpoint_manager(handles, 'save');
    %   checkpoint_manager(handles, 'reset_button');
    %   checkpoint_manager(handles, 'resume');
    %   progress = checkpoint_manager(handles, 'get_progress');
    %   checkpoint_manager(handles, 'clear_all');
    
    switch lower(action)
        case 'save'
            saveCheckpoint(handles);
        case 'reset_button'
            resetCheckpointButton(handles);
        case 'resume'
            resumeFromPause(handles);
        case 'get_progress'
            progress = getCurrentProgress(handles);
            if nargout > 0
                varargout{1} = progress;
            end
        case 'clear_all'
            clearAllCheckpoints(handles);
        otherwise
            error('Unknown action: %s', action);
    end
end

function saveCheckpoint(handles)
    % SAVECHECKPOINT - Save current state as checkpoint
    %
    % Inputs:
    %   handles - GUI handles structure
    
    % Create checkpoint data
    checkpoint = struct();
    checkpoint.timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    checkpoint.gui_state = handles;
    checkpoint.progress = getCurrentProgress(handles);

    % Save to file
    checkpoint_file = sprintf('checkpoint_%s.mat', checkpoint.timestamp);
    save(checkpoint_file, 'checkpoint');

    % Update GUI
    handles.checkpoint_data = checkpoint;
    set(handles.checkpoint_button, 'String', 'Saved', 'BackgroundColor', handles.colors.success);

    % Reset button after 2 seconds
    timer_obj = timer('ExecutionMode', 'singleShot', 'StartDelay', 2);
    timer_obj.TimerFcn = @(src, event) resetCheckpointButton(handles);
    start(timer_obj);

    guidata(handles.fig, handles);
end

function resetCheckpointButton(handles)
    % RESETCHECKPOINTBUTTON - Reset checkpoint button to default state
    %
    % Inputs:
    %   handles - GUI handles structure
    
    set(handles.checkpoint_button, 'String', 'Checkpoint', 'BackgroundColor', handles.colors.warning);
end

function resumeFromPause(handles)
    % RESUMEFROMPAUSE - Resume processing from checkpoint
    %
    % Inputs:
    %   handles - GUI handles structure
    
    % Resume processing from checkpoint
    if ~isempty(handles.checkpoint_data)
        % Restore state and continue processing
        % Implementation depends on specific processing logic
        updateProgressText(handles, 'Resuming from checkpoint...');
    end
end

function progress = getCurrentProgress(handles)
    % GETCURRENTPROGRESS - Get current progress state
    %
    % Inputs:
    %   handles - GUI handles structure
    %
    % Outputs:
    %   progress - Progress structure with current state
    
    progress = struct();
    progress.current_trial = 0;
    progress.total_trials = 0;
    progress.current_step = '';
    
    % Try to get actual progress from handles if available
    if isfield(handles, 'current_trial')
        progress.current_trial = handles.current_trial;
    end
    
    if isfield(handles, 'total_trials')
        progress.total_trials = handles.total_trials;
    end
    
    if isfield(handles, 'current_step')
        progress.current_step = handles.current_step;
    end
end

function clearAllCheckpoints(handles)
    % CLEARALLCHECKPOINTS - Clear all checkpoint files
    %
    % Inputs:
    %   handles - GUI handles structure
    
    try
        % Find all checkpoint files in current directory
        checkpoint_files = dir('checkpoint_*.mat');
        
        if ~isempty(checkpoint_files)
            % Delete all checkpoint files
            for i = 1:length(checkpoint_files)
                delete(checkpoint_files(i).name);
            end
            
            fprintf('Cleared %d checkpoint files\n', length(checkpoint_files));
            
            % Clear checkpoint data from handles
            if isfield(handles, 'checkpoint_data')
                handles.checkpoint_data = [];
                guidata(handles.fig, handles);
            end
        else
            fprintf('No checkpoint files found to clear\n');
        end
    catch ME
        warning('Error clearing checkpoints: %s', ME.message);
    end
end

function updateProgressText(handles, message)
    % UPDATEPROGRESSTEXT - Update progress text in GUI
    %
    % Inputs:
    %   handles - GUI handles structure
    %   message - Message to display
    
    try
        if isfield(handles, 'progress_text') && ishandle(handles.progress_text)
            set(handles.progress_text, 'String', message);
            drawnow;
        end
    catch ME
        warning('Error updating progress text: %s', ME.message);
    end
end
