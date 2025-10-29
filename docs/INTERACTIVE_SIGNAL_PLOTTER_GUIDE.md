# Interactive Signal Plotter - User Guide

## Overview

The Interactive Signal Plotter is an advanced visualization tool integrated with the Golf Swing Skeleton Plotter. It provides time-synchronized plotting of any numeric signal from the golf swing datasets (BASEQ, ZTCFQ, DELTAQ) with bidirectional synchronization with the 3D skeleton visualization.

## Features

### 1. Time-Synchronized Plotting
- **Vertical Time Indicator**: A prominent red vertical line shows the current point in time on all plots
- **Real-time Updates**: The vertical line moves automatically during playback from the skeleton plotter
- **Value Display**: Current signal values are shown in aesthetic display boxes that update in real-time

### 2. Interactive Timeline Scrubbing
- **Click and Drag**: Click anywhere on the plot and drag to scrub through time
- **Bidirectional Sync**: 
  - Moving the frame slider in the skeleton plotter updates the signal plot
  - Dragging the timeline in the signal plot updates the skeleton plotter and 3D view
- **Smooth Navigation**: Instant feedback and smooth updates during scrubbing

### 3. Signal Selection and Management
- **Hotlist System**: Manage a hotlist of frequently used signals for quick access
- **Multi-Select**: Select multiple signals simultaneously from the hotlist
- **Data Inspector**: Comprehensive dialog for managing available signals
  - Categorized display (Forces/Torques, Joint Positions, Other Signals)
  - Search functionality to quickly find signals
  - Select all/none buttons for bulk management

### 4. Plot Modes
- **Single Plot Mode**: All selected signals on one plot with different colors
  - Shared y-axis with smart auto-scaling
  - Clear legend showing signal names
  - Distinguishable colors for each signal
  
- **Subplot Mode**: Each signal in its own subplot
  - Organized grid layout (up to 3 columns)
  - Individual y-axis scaling for each signal
  - Better for comparing signals with different scales

### 5. Configuration Persistence
- **Automatic Save**: User preferences are automatically saved when closing the plotter
- **Saved Settings**:
  - Hotlist signals
  - Last selected signals
  - Plot mode preference (single/subplot)
  - Window position
- **Auto-Load**: Preferences are restored when opening the plotter again

### 6. Dataset Integration
- **Multiple Datasets**: Switch between BASEQ, ZTCFQ, and DELTAQ
- **Automatic Sync**: Dataset changes in skeleton plotter update signal plotter
- **Matrix Columns**: Automatically handles matrix columns (e.g., forces/torques) by plotting magnitude

## How to Use

### Opening the Signal Plotter

1. Launch the Skeleton Plotter with your data:
   ```matlab
   SkeletonPlotter(BASEQ, ZTCFQ, DELTAQ)
   ```

2. Click the **"📊 Signal Plot"** button on the right side of the skeleton plotter window

3. The Interactive Signal Plotter window will open

### Selecting Signals to Plot

#### Quick Selection from Hotlist:
1. In the signal plotter window, find the "Select Signals:" listbox
2. Click to select one signal, or Ctrl+Click to select multiple signals
3. The plot updates automatically

#### Managing the Hotlist:
1. Click the **"🔍 Manage Hotlist"** button
2. The Data Inspector dialog opens showing all available signals
3. Use the search box to filter signals by name
4. Check/uncheck signals to add/remove from hotlist
5. Use "Select All" or "Select None" for bulk operations
6. Click **"Apply & Close"** to save changes

### Using the Plot

#### Scrubbing Through Time:
- **Method 1**: Drag the frame slider in the skeleton plotter
- **Method 2**: Click and drag on the signal plot timeline
- The vertical red line shows the current time position
- Value displays update to show exact values at current time

#### Switching Plot Modes:
1. Click the **plot mode toggle button** (shows "Single Plot" or "Subplots")
2. The plot refreshes in the selected mode
3. Your preference is saved for next time

#### Changing Datasets:
1. Use the "Dataset:" dropdown at the top of the signal plotter
2. Select BASEQ, ZTCFQ, or DELTAQ
3. The plot updates with data from the selected dataset

#### Clearing Selection:
- Click **"Clear Selection"** to deselect all signals and clear the plot

## Technical Details

### File Structure

```
matlab/Scripts/Golf_GUI/2D GUI/
├── visualization/
│   ├── SkeletonPlotter.m              (modified - added signal plot integration)
│   ├── InteractiveSignalPlotter.m     (new - main plotting window)
│   ├── SignalDataInspector.m          (new - hotlist management dialog)
│   └── SignalPlotConfig.m             (new - configuration manager)
└── config/
    └── signal_plot_config.mat         (auto-generated - user preferences)
```

### Signal Detection

The plotter automatically detects all numeric columns in the data tables, excluding the 'Time' column. Signals are categorized as:

1. **Forces & Torques** (prioritized): Signals containing keywords like 'Force', 'Torque', 'Couple', 'Power', 'Work', 'Energy'
2. **Joint Positions**: Signals ending in x/y/z or containing joint identifiers (Butt, CH, MP, LW, LE, LS, RW, RE, RS, HUB)
3. **Other Signals**: All remaining numeric signals

### Matrix Column Handling

For signals that are matrix columns (e.g., TotalHandForceGlobal which is Nx3), the plotter automatically:
- Calculates the magnitude using `vecnorm(data, 2, 2)`
- Appends " (mag)" to the signal name in the legend
- Plots the magnitude over time

### Configuration File

The configuration is saved as a MATLAB .mat file at:
```
matlab/Scripts/Golf_GUI/2D GUI/config/signal_plot_config.mat
```

Configuration includes:
```matlab
config.hotlist_signals      % Cell array of signal names
config.last_selected         % Last selected signals for plotting
config.plot_mode            % 'single' or 'subplot'
config.window_position      % [x, y, width, height]
config.prioritized_patterns % Keywords for force/torque detection
```

### Synchronization Mechanism

The bidirectional sync works through:

1. **Skeleton → Signal Plot**: 
   - `updatePlot()` in SkeletonPlotter calls `updateSignalPlotter()`
   - Updates vertical time line and value displays in signal plotter

2. **Signal Plot → Skeleton**:
   - Mouse drag in signal plot calls `update_time_position()`
   - Updates skeleton plotter's frame slider
   - Triggers `updatePlot()` in skeleton plotter

## Tips and Best Practices

1. **Performance**: 
   - Limit to 5-10 signals in single plot mode for best clarity
   - Subplot mode is better for large numbers of signals
   - The plotter handles hundreds of signals efficiently

2. **Hotlist Management**:
   - Add only frequently used signals to the hotlist
   - Use the Data Inspector's search to quickly find specific signals
   - Organize your hotlist by category (forces first, then positions, etc.)

3. **Plot Clarity**:
   - Use single plot mode when comparing signals with similar scales
   - Use subplot mode when signals have very different scales
   - The value display shows exact values at the current time

4. **Workflow**:
   - Keep both skeleton plotter and signal plotter visible on screen
   - Use signal plotter for precise value inspection
   - Use skeleton plotter for spatial understanding

## Troubleshooting

### Plot not updating during playback
- Ensure the signal plotter window is still open and not closed
- Check that signals are selected in the listbox

### Signals not showing in hotlist
- Open Data Inspector and verify signals are checked
- Click "Apply & Close" to save changes
- Check that the data table actually contains those signals

### Dragging not working
- Ensure you're clicking within the plot axes area
- Try single-clicking first, then dragging
- Check that the time range is valid for your dataset

### Configuration not persisting
- Ensure the config directory has write permissions
- Check for any error messages in the MATLAB console
- The config saves automatically on window close

## Future Enhancements

Potential improvements for future versions:
- Export plot to image/video
- Multiple y-axes in single plot mode
- Custom color schemes
- Annotation and measurement tools
- Signal derivative/integral plotting
- Compare signals across datasets simultaneously
- Zoom and pan within the time domain

## Support

For issues or feature requests, please contact the development team or create an issue in the project repository.

---

**Version**: 1.0  
**Date**: October 2025  
**Author**: Golf Swing Analysis Team

