function create_skeleton_tab(parent, main_fig)
% CREATE_SKELETON_TAB  Build contents of the Skeleton tab.

    grid = uigridlayout(parent,[1 1]);
    uilabel(grid,'Text','Skeleton visualization will appear here', ...
            'HorizontalAlignment','center');
end
