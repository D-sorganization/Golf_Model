function create_plots_tab(parent, main_fig)
% CREATE_PLOTS_TAB  Build contents of the Plots tab.

    grid = uigridlayout(parent,[1 1]);
    uilabel(grid,'Text','Plotting interface goes here', ...
            'HorizontalAlignment','center');
end
