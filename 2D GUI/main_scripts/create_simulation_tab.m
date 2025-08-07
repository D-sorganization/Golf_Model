function create_simulation_tab(parent, main_fig)
% CREATE_SIMULATION_TAB  Build contents of the Simulation tab.

    handles = guidata(main_fig);

    grid = uigridlayout(parent,[1 3]);
    grid.ColumnWidth = {'1x','1x','2x'};

    %% Parameter controls
    paramPanel = uipanel(grid,'Title','Parameter Controls');
    paramLayout = uigridlayout(paramPanel,[2 2]);
    paramLayout.RowHeight = {'fit','fit'};
    paramLayout.ColumnWidth = {'1x','1x'};

    uilabel(paramLayout,'Text','Stop Time (s)');
    stopField = uieditfield(paramLayout,'numeric', ...
        'Value', handles.config.stop_time, ...
        'ValueChangedFcn', @(src,~)updateStopTime(main_fig,src.Value));

    uilabel(paramLayout,'Text','Max Step (s)');
    maxStepField = uieditfield(paramLayout,'numeric', ...
        'Value', handles.config.max_step, ...
        'ValueChangedFcn', @(src,~)updateMaxStep(main_fig,src.Value));

    %% Simulation controls placeholder
    simPanel = uipanel(grid,'Title','Simulation Controls');
    simLayout = uigridlayout(simPanel,[1 1]);
    uibutton(simLayout,'Text','Run Simulation');

    %% Visualization placeholder
    vizPanel = uipanel(grid,'Title','Visualization');
    vizLayout = uigridlayout(vizPanel,[1 1]);
    uiaxes(vizLayout);

    handles.stop_time_field = stopField;
    handles.max_step_field = maxStepField;
    guidata(main_fig, handles);
end

function updateStopTime(main_fig,newVal)
    handles = guidata(main_fig);
    handles.config.stop_time = newVal;
    guidata(main_fig, handles);
end

function updateMaxStep(main_fig,newVal)
    handles = guidata(main_fig);
    handles.config.max_step = newVal;
    guidata(main_fig, handles);
end
