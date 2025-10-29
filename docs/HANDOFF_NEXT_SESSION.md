# Interactive Signal Plotter - Handoff for Next Session

## Current Status

### Branch
`feature/interactive-signal-plotter`

### What's Working
✅ InteractiveSignalPlotter.m created (main plotting window)  
✅ SignalDataInspector.m created (hotlist management dialog)  
✅ SignalPlotConfig.m created (configuration persistence)  
✅ SkeletonPlotter.m modified with "Signal Plot" button  
✅ UI components all created and styled (no emojis)  
✅ Configuration save/load implemented  
✅ Data inspector with categorized signals  
✅ Single plot and subplot modes  
✅ Body segments animate correctly (fixed variable collision bug)

### What's NOT Working (Critical Bugs)

#### Bug 1: Time Line Not Syncing Between Windows
**Symptom**: When you move the skeleton plotter slider, the red vertical line in the signal plot doesn't update.

**Root Cause**: 
- `updateSignalPlotter()` in SkeletonPlotter.m (lines 677-748) tries to update the time line
- It finds the line by Tag 'TimeLine' and updates XData
- BUT the changes aren't rendering to screen

**Fix Required**:
```matlab
% In SkeletonPlotter.m, line ~702 after setting XData:
set(time_line, 'XData', [current_time, current_time]);
drawnow limitrate;  % ADD THIS - forces rendering
```

**Files to modify**: `matlab/Scripts/Golf_GUI/2D GUI/visualization/SkeletonPlotter.m`

#### Bug 2: Force/Torque Vectors Plotting as Magnitude
**Symptom**: TotalHandForceGlobal (3D vector) plots as single magnitude line instead of X, Y, Z components.

**Root Cause**:
```matlab
% InteractiveSignalPlotter.m, lines 272-275
if size(signal_data, 2) > 1
    signal_data = vecnorm(signal_data, 2, 2);
    signal_name = [signal_name, ' (mag)'];
end
```

**Fix Required**: Replace magnitude calculation with component expansion:
```matlab
% Replace lines 272-275 in InteractiveSignalPlotter.m (in create_single_plot)
if size(signal_data, 2) > 1
    % Plot each component separately
    for comp = 1:size(signal_data, 2)
        comp_data = signal_data(:, comp);
        comp_name = sprintf('%s_%d', signal_name, comp);
        
        h = plot(ax, handles.time_vector, comp_data, ...
            'Color', colors(i,:), ...
            'LineWidth', 1.5, ...
            'DisplayName', comp_name);
        line_handles = [line_handles; h];
        
        current_value = comp_data(current_frame);
        value_displays(end+1).signal = comp_name;
        value_displays(end).value = current_value;
        value_displays(end).color = colors(i,:);
    end
else
    % Single component - plot normally
    h = plot(ax, handles.time_vector, signal_data, ...
        'Color', colors(i,:), ...
        'LineWidth', 1.5, ...
        'DisplayName', signal_name);
    line_handles = [line_handles; h];
    
    current_value = signal_data(current_frame);
    value_displays(end+1).signal = signal_name;
    value_displays(end).value = current_value;
    value_displays(end).color = colors(i,:);
end
```

**Also fix in create_subplots** (around line 330) - similar logic for subplot mode.

**Files to modify**: `matlab/Scripts/Golf_GUI/2D GUI/visualization/InteractiveSignalPlotter.m`

#### Bug 3: Cleanup Not Working
**Symptom**: Variables/handles left in workspace after closing app.

**Root Cause**: CloseRequestFcn might not be firing, or figure hierarchy issue.

**Fix Required**:
1. Verify the CloseRequestFcn is actually set:
```matlab
% In SkeletonPlotter.m line 53, verify this exists:
'CloseRequestFcn', @cleanup_and_close);
```

2. Check that cleanup_and_close function is at module level (currently line 750)

3. Add diagnostic output at start of cleanup_and_close:
```matlab
function cleanup_and_close(src, ~)
    fprintf('DEBUG: cleanup_and_close called\n');
    fprintf('DEBUG: Figure handle: %d\n', src);
    % ... rest of function
```

4. Test by closing via X button on main figure window

**Files to modify**: `matlab/Scripts/Golf_GUI/2D GUI/visualization/SkeletonPlotter.m`

## Exact Steps to Fix

### Step 1: Fix Time Line Sync (5 min)
```matlab
# Edit: matlab/Scripts/Golf_GUI/2D GUI/visualization/SkeletonPlotter.m

# Find line ~702 (in updateSignalPlotter function):
set(time_line, 'XData', [current_time, current_time]);

# Add immediately after:
drawnow limitrate;

# Also find line ~710 (in the else branch for subplots):
set(time_line, 'XData', [current_time, current_time]);

# Add immediately after:
drawnow limitrate;
```

### Step 2: Fix Vector Plotting (20 min)
```matlab
# Edit: matlab/Scripts/Golf_GUI/2D GUI/visualization/InteractiveSignalPlotter.m

# Find create_single_plot function (line ~248)
# Replace the section from line 264-289 with the component expansion code shown above

# Find create_subplots function (line ~311)
# Apply similar fix for matrix columns around lines 330-350
```

### Step 3: Fix Cleanup (10 min)
```matlab
# Edit: matlab/Scripts/Golf_GUI/2D GUI/visualization/SkeletonPlotter.m

# Add debug output to cleanup_and_close (line ~750)
# Test by running script and closing windows
# Check console for "DEBUG: cleanup_and_close called"
# If not called, verify CloseRequestFcn is set on line 53
```

### Step 4: Test Everything (15 min)
```matlab
# Run test script:
cd matlab/Scripts/Golf_GUI/2D GUI/visualization
test_interactive_signal_plotter

# Test checklist:
□ Body segments animate correctly
□ Open signal plotter (no errors)
□ Select TotalHandForceGlobal - see 3 component lines (not magnitude)
□ Move skeleton slider - red line moves in signal plot
□ Drag on signal plot - skeleton moves
□ Close skeleton plotter - check workspace is clean (whos)
```

### Step 5: Commit Fixes
```bash
git add -A
git commit -m "Fix critical bugs in Interactive Signal Plotter

Fixes:
1. Time line now syncs - added drawnow after XData updates
2. Force/torque vectors plot as X,Y,Z components (not magnitude)
3. Cleanup verified working

All features now fully functional."
```

## Original Plan vs Current State

### From Original Plan (interactive-signal-plotter.plan.md)

**Completed:**
- [x] Create feature branch 'feature/interactive-signal-plotter'
- [x] Create SignalPlotConfig.m for loading/saving user preferences
- [x] Create SignalDataInspector.m with categorized signal list
- [x] Create InteractiveSignalPlotter.m with time-synchronized plotting
- [x] Add 'Open Signal Plot' button to SkeletonPlotter.m
- [x] Add aesthetic value display boxes
- [x] Implement single-plot and subplot mode toggle
- [x] Integrate config save/load throughout system

**Partially Complete (bugs preventing full functionality):**
- [ ] Bidirectional synchronization (framework exists, rendering bug prevents visibility)
- [ ] Draggable timeline (code exists, callback works, but skeleton doesn't visibly update due to sync bug)

**Testing:**
- [ ] Test all features with different datasets (blocked by bugs)
- [ ] Verify synchronization during playback (blocked by sync bug)
- [ ] Refine UI/UX (can't properly test until bugs fixed)

### Summary
**We are 90% complete** - all code is written, but 3 rendering/logic bugs prevent it from working correctly.

## After Fixes: Next Steps

### Immediate (Same Session After Fixes)
1. Test thoroughly with all datasets
2. Verify cleanup works
3. Document any remaining issues
4. Update user guide with final functionality

### Future Enhancement (New Branch)
Create `feature/integrated-tabbed-gui` for the 3-tab application:
- Tab 1: Model Setup & Simscape Visualization
- Tab 2: ZTCF Calculation (parallelized)
- Tab 3: Analysis & Visualization (current skeleton plotter)

See `docs/TABBED_GUI_IMPLEMENTATION_PLAN.md` for full details.

## Commands to Get Started

```bash
# Navigate to project
cd C:/Users/diete/Repositories/Golf_Model

# Ensure on correct branch
git checkout feature/interactive-signal-plotter

# Check what files are modified
git status

# Open MATLAB and navigate
cd matlab/Scripts/Golf_GUI/2D GUI/visualization

# Make the 3 fixes described above
# Then test:
test_interactive_signal_plotter
```

## Key Files

**To modify:**
1. `matlab/Scripts/Golf_GUI/2D GUI/visualization/SkeletonPlotter.m` (fix sync + cleanup)
2. `matlab/Scripts/Golf_GUI/2D GUI/visualization/InteractiveSignalPlotter.m` (fix vectors)

**Test script:**
- `matlab/Scripts/Golf_GUI/2D GUI/visualization/test_interactive_signal_plotter.m`

**Documentation:**
- `docs/INTERACTIVE_SIGNAL_PLOTTER_GUIDE.md` (user guide)
- `docs/INTERACTIVE_SIGNAL_PLOTTER_IMPLEMENTATION.md` (technical docs)
- `docs/CRITICAL_FIXES_SUMMARY.md` (bug analysis)
- `docs/TABBED_GUI_IMPLEMENTATION_PLAN.md` (future work)

## Expected Time
**Total: ~50 minutes**
- Fixes: 35 min
- Testing: 15 min

After these fixes, the Interactive Signal Plotter will be **100% complete and production-ready**.

