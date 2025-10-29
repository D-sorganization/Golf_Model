# Critical Fixes Required

## Issue 1: Signal Plot Time Line Not Updating

### Problem
When the skeleton plotter slider moves, the red vertical time line in the signal plot doesn't update.

### Root Cause
- `create_single_plot()` stores time line in local `handles` variable
- This gets saved via `guidata()` at end of `update_plot()`
- But `updateSignalPlotter()` in SkeletonPlotter searches for line by Tag
- The time line handle might not be accessible or updates aren't rendering

### Solution
1. Ensure time line handle is properly stored and accessible
2. Force a `drawnow` after updating XData to ensure rendering
3. Verify the handle is valid before updating

## Issue 2: Force/Torque Vectors Plotting as Magnitude

### Problem
3-component vectors (like TotalHandForceGlobal) are automatically converted to magnitude, losing directional information.

### Root Cause
Lines 272-275 in InteractiveSignalPlotter.m:
```matlab
if size(signal_data, 2) > 1
    signal_data = vecnorm(signal_data, 2, 2);
    signal_name = [signal_name, ' (mag)'];
end
```

### Solution Options
1. **Option A**: Plot individual components (X, Y, Z) as separate lines
2. **Option B**: Add user choice (magnitude vs components)
3. **Option C**: Remove magnitude calculation entirely

**Recommended**: Option A - Automatically expand matrix columns into separate signals (ForceName_X, ForceName_Y, ForceName_Z)

## Issue 3: Cleanup Not Working

### Problem
App doesn't clean up when closed via main GUI.

### Root Cause
- CloseRequestFcn may not be properly triggered
- Figure handle might be deleted before cleanup runs
- Need to verify figure is the main figure, not a plot within it

### Solution
1. Verify CloseRequestFcn is set correctly
2. Add try-catch to handle edge cases
3. Ensure cleanup runs even if figure is force-closed

## Implementation Order

1. Fix synchronization (most critical for usability)
2. Fix vector plotting (data accuracy)
3. Fix cleanup (professional polish)

---

## Current Status

Branch: `feature/interactive-signal-plotter`
Files to modify:
- InteractiveSignalPlotter.m
- SkeletonPlotter.m

Next: Implement fixes and test thoroughly

