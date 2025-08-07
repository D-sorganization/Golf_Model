function create_analysis_tab(parent, main_fig)
% CREATE_ANALYSIS_TAB  Build contents of the Analysis tab.

    grid = uigridlayout(parent,[1 1]);
    uilabel(grid,'Text','Analysis tools go here', ...
            'HorizontalAlignment','center');
end
