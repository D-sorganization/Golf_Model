# Interactive Signal Plotter - Technical Implementation

## Architecture Overview

The Interactive Signal Plotter consists of four main components that work together to provide a seamless, synchronized plotting experience.

```
┌─────────────────────────────────────────────────────────────┐
│                     SkeletonPlotter.m                       │
│  • 3D Skeleton Visualization                                │
│  • Playback Controls                                        │
│  • Frame Slider                                             │
│  • "Open Signal Plot" Button ─────────┐                    │
└──────────────────┬──────────────────────┼──────────────────┘
                   │                      │
                   │ Bidirectional Sync   │ Launch
                   │                      │
                   │              ┌───────▼──────────────────────────┐
                   │              │ InteractiveSignalPlotter.m       │
                   │              │  • Time-synchronized plotting    │
                   │              │  • Draggable timeline            │
                   │              │  • Value displays                │
                   │              │  • Single/Subplot modes          │
                   │              └──────┬───────────────────────────┘
                   │                     │
                   │                     │ Uses
                   │                     │
        ┌──────────▼─────────────────────▼──────────────────┐
        │                                                    │
┌───────▼────────────────┐                  ┌───────────────▼─────────┐
│ SignalPlotConfig.m     │                  │ SignalDataInspector.m   │
│  • Load/Save settings  │                  │  • Hotlist management   │
│  • Default config      │                  │  • Signal categorization│
│  • Validation          │                  │  • Search/filter UI     │
└────────────────────────┘                  └─────────────────────────┘
```

## Component Details

### 1. SignalPlotConfig.m

**Purpose**: Configuration management and persistence

**Public Interface**:
```matlab
config = SignalPlotConfig('load')     % Load saved config
SignalPlotConfig('save', config)      % Save config
config = SignalPlotConfig('default')  % Get default config
```

**Configuration Structure**:
```matlab
config = struct(
    'hotlist_signals',        % Cell array of signal names
    'last_selected',          % Last selected signals
    'plot_mode',              % 'single' or 'subplot'
    'window_position',        % [x, y, width, height]
    'prioritized_patterns'    % Keywords for categorization
);
```

**Key Functions**:
- `load_config()`: Loads from `.mat` file with fallback to defaults
- `save_config()`: Saves with directory creation and validation
- `get_default_config()`: Returns sensible defaults
- `validate_config()`: Ensures config structure integrity

**Storage Location**:
```
matlab/Scripts/Golf_GUI/2D GUI/config/signal_plot_config.mat
```

### 2. SignalDataInspector.m

**Purpose**: Modal dialog for hotlist management

**Public Interface**:
```matlab
updated_hotlist = SignalDataInspector(data_table, current_hotlist, config)
```

**Parameters**:
- `data_table`: MATLAB table containing all signals
- `current_hotlist`: Cell array of current hotlist signal names
- `config`: Configuration structure from SignalPlotConfig
- **Returns**: Updated hotlist or original if cancelled

**UI Components**:
1. **Search Box**: Real-time filtering of signal list
2. **Signal List**: Checkboxes organized by category
3. **Action Buttons**: Select All, Select None, Apply & Close, Cancel
4. **Count Display**: Shows number of selected signals

**Signal Categorization Algorithm**:
```matlab
% Priority: Force/Torque keywords
if contains(signal, {'Force', 'Torque', 'Couple', 'Power', 'Work'})
    → prioritized_signals

% Position: Joint position patterns
elseif matches(signal, {'*x', '*y', '*z', '*Butt*', '*LW*', ...})
    → position_signals

% Everything else
else
    → other_signals
```

**Key Features**:
- Modal dialog (blocks parent until closed)
- Uses `uiwait`/`uiresume` for synchronous operation
- Result passed via `appdata` mechanism
- Automatic GUI cleanup on close

### 3. InteractiveSignalPlotter.m

**Purpose**: Main plotting window with time synchronization

**Public Interface**:
```matlab
plotter_handles = InteractiveSignalPlotter(datasets, skeleton_handles, config)
```

**Parameters**:
- `datasets`: Struct with BASEQ, ZTCFQ, DELTAQ fields
- `skeleton_handles`: Handles from SkeletonPlotter for sync
- `config`: Configuration structure

**Returns**:
- `plotter_handles`: Structure with:
  - `fig`: Figure handle
  - `datasets`: Reference to data
  - `current_dataset`: Currently selected dataset
  - `skeleton_handles`: Reference to skeleton plotter

#### Plotting Modes

**Single Plot Mode**:
```matlab
% All signals on one axes
ax = axes('Parent', panel, ...);
hold on;
for each signal
    plot(time, signal_data, 'Color', colors(i,:));
end
legend(...);
```

**Subplot Mode**:
```matlab
% Grid of subplots
n_cols = min(3, n_signals);
n_rows = ceil(n_signals / n_cols);
for i = 1:n_signals
    ax = subplot(n_rows, n_cols, i);
    plot(time, signal_data);
end
```

#### Time Synchronization

**Vertical Line Indicator**:
```matlab
% Create red vertical line
time_line = plot(ax, [current_time, current_time], ylim, ...
                'r-', 'LineWidth', 2.5, 'Tag', 'TimeLine');

% Update during playback/scrubbing
set(time_line, 'XData', [new_time, new_time]);
```

**Value Display**:
```matlab
% Calculate current value at frame
current_value = signal_data(current_frame);

% Update display text
set(value_display, 'String', ...
    sprintf('%s: %.3f', signal_name, current_value));
```

#### Mouse Interaction

**Timeline Dragging**:
```matlab
% Mouse down - start dragging
on_mouse_down():
    if click_in_axes
        dragging = true
        update_time_position(x_click)

% Mouse move - scrub timeline
on_mouse_move():
    if dragging
        update_time_position(x_current)

% Mouse up - stop dragging
on_mouse_up():
    dragging = false
```

**Bidirectional Sync**:
```matlab
update_time_position(time_value):
    % Find nearest frame
    frame_idx = find_nearest_frame(time_value)
    
    % Update skeleton plotter
    set(skeleton_handles.slider, 'Value', frame_idx)
    
    % Update own display
    update_time_line(frame_idx)
```

#### Data Handling

**Matrix Column Detection**:
```matlab
if size(signal_data, 2) > 1
    % Calculate magnitude for vector data
    signal_data = vecnorm(signal_data, 2, 2);
    signal_name = [signal_name, ' (mag)'];
end
```

**Color Generation**:
```matlab
% Use predefined colors, then generate more if needed
base_colors = [0 0.4 1; 1 0 0; 0 0.7 0; ...];
if n > length(base_colors)
    colors = [base_colors; hsv(n - length(base_colors))];
end
```

### 4. SkeletonPlotter.m Modifications

**Added Components**:

1. **Button**:
```matlab
uicontrol('Style', 'pushbutton', ...
    'String', '📊 Signal Plot', ...
    'Callback', @openSignalPlot);
```

2. **Initialization**:
```matlab
% Store datasets in structure
datasets_struct = struct('BASEQ', BASEQ, 'ZTCFQ', ZTCFQ, 'DELTAQ', DELTAQ);

% Load config
signal_plot_config = SignalPlotConfig('load');

% Initialize handle
signal_plotter_handle = [];
```

3. **Open Signal Plot Function**:
```matlab
function openSignalPlot(~, ~)
    % Check if already open
    if ~isempty(signal_plotter_handle) && isvalid(signal_plotter_handle.fig)
        figure(signal_plotter_handle.fig);
        return;
    end
    
    % Open new plotter
    signal_plotter_handle = InteractiveSignalPlotter(...
        datasets_struct, handles, signal_plot_config);
end
```

4. **Update Signal Plotter Function**:
```matlab
function updateSignalPlotter()
    if ~isempty(signal_plotter_handle) && isvalid(signal_plotter_handle.fig)
        % Get current frame
        current_frame = get(handles.slider, 'Value');
        
        % Update plotter's time line and values
        plot_handles = guidata(signal_plotter_handle.fig);
        % ... update time line
        % ... update value displays
    end
end
```

5. **Integration in updatePlot**:
```matlab
function updatePlot(~, ~)
    % ... existing code ...
    
    % Update signal plotter if open
    updateSignalPlotter();
end
```

## Data Flow

### Opening the Signal Plotter

```
User clicks "📊 Signal Plot" button
    ↓
openSignalPlot() called
    ↓
Check if plotter already exists
    ↓ (if not)
Load config (SignalPlotConfig)
    ↓
Create InteractiveSignalPlotter(datasets, handles, config)
    ↓
Build UI components
    ↓
Load hotlist signals into listbox
    ↓
Pre-select last selected signals
    ↓
Initial plot (if signals selected)
    ↓
Store plotter_handles
    ↓
Return to user
```

### Synchronization Flow

**Skeleton Plotter → Signal Plotter**:
```
Frame slider moved or playback
    ↓
updatePlot() called
    ↓
updateSignalPlotter() called
    ↓
Get signal plotter handles via guidata
    ↓
Update time line XData
    ↓
Update value display strings
    ↓
Update info text
```

**Signal Plotter → Skeleton Plotter**:
```
User clicks/drags on plot
    ↓
on_mouse_down() → dragging = true
    ↓
on_mouse_move() detects drag
    ↓
update_time_position(x_click)
    ↓
Find nearest frame index
    ↓
Set skeleton_handles.slider.Value
    ↓
Skeleton's updatePlot() triggered (callback)
    ↓
3D view updates
    ↓
updateSignalPlotter() called
    ↓
Signal plotter updates (completes cycle)
```

### Dataset Change Flow

```
User changes dataset in skeleton plotter
    ↓
onDatasetChanged() callback
    ↓
Update skeleton plotter view
    ↓
Check if signal plotter is open
    ↓ (if yes)
Get signal plotter handles
    ↓
Update dataset_selector dropdown
    ↓
Signal plotter's on_dataset_changed() triggered
    ↓
Update current_dataset
    ↓
Refresh plot with new data
```

## Performance Considerations

### Efficient Updates

1. **Selective Redrawing**:
   - Only update time line XData (no full plot redraw)
   - Only update text strings for value displays
   - Use 'Tag' property for fast object finding

2. **Handle Caching**:
   - Store axes and line handles
   - Use guidata() for cross-figure communication
   - Minimal repeated object creation

3. **Data Access**:
   - Reference datasets (not copy)
   - Extract only needed columns
   - Pre-calculate time vector once

### Scalability

**Large Datasets**:
- Handles thousands of time points efficiently
- Plot rendering is MATLAB-optimized
- No performance degradation during scrubbing

**Many Signals**:
- Single plot: Up to ~10 signals for clarity
- Subplot mode: Handles 20+ signals
- Color generation: Unlimited via HSV

**Memory**:
- Datasets passed by reference
- Minimal memory overhead
- Config file: < 1 KB typically

## Error Handling

### Graceful Degradation

1. **Config Loading**:
```matlab
try
    config = load(config_file);
catch ME
    warning('Failed to load config. Using defaults.');
    config = get_default_config();
end
```

2. **Signal Plotter Updates**:
```matlab
try
    updateSignalPlotter();
catch
    % Silent failure - don't interrupt skeleton plotter
end
```

3. **Missing Signals**:
```matlab
if ismember(signal_name, dataset.Properties.VariableNames)
    plot_signal(signal_data);
else
    warning('Signal %s not found', signal_name);
    skip_signal();
end
```

### Validation

**Config Validation**:
- Check all required fields exist
- Validate data types
- Clean up invalid entries
- Intersect last_selected with hotlist

**Dataset Validation**:
- Check for required fields (BASEQ, ZTCFQ, DELTAQ)
- Verify tables are valid
- Check Time column exists
- Handle missing Time gracefully

## Testing Strategies

### Unit Testing

1. **Config Management**:
   - Test save/load cycle
   - Test default config generation
   - Test validation with corrupted data

2. **Signal Detection**:
   - Test categorization algorithm
   - Test with various signal name patterns
   - Test with empty datasets

3. **Data Handling**:
   - Test matrix column magnitude calculation
   - Test with 1D and 2D signal data
   - Test with missing signals

### Integration Testing

1. **Synchronization**:
   - Test skeleton → signal updates
   - Test signal → skeleton updates
   - Test during playback
   - Test with different datasets

2. **UI Interactions**:
   - Test signal selection
   - Test plot mode switching
   - Test timeline dragging
   - Test dataset changes

3. **Persistence**:
   - Test config save on close
   - Test config load on open
   - Test with missing config file

### Performance Testing

1. **Large Datasets**:
   - 10,000+ time points
   - 50+ signals in hotlist
   - Rapid scrubbing
   - Continuous playback

2. **Multiple Windows**:
   - Open/close cycle
   - Multiple skeleton plotters
   - Memory leak detection

## Known Limitations

1. **Plot Overlap**: In single plot mode with many signals, overlapping can reduce clarity
   - **Mitigation**: Recommend subplot mode or limit selections

2. **Y-Axis Scaling**: Single plot uses shared y-axis, may not suit all signal combinations
   - **Mitigation**: Subplot mode for different scales

3. **Value Display**: Limited to 5 signals to avoid clutter
   - **Mitigation**: Full values visible by inspecting plot

4. **Config Location**: Fixed relative path may cause issues if folder structure changes
   - **Mitigation**: Path calculation relative to function location

## Future Enhancements

### Planned Features

1. **Multiple Y-Axes**: Support 2-3 y-axes in single plot mode
2. **Export Functionality**: Save plots as images or videos
3. **Zoom/Pan**: Time-domain zoom for detailed inspection
4. **Annotations**: Add markers and text annotations
5. **Derivatives**: Plot signal derivatives/integrals
6. **Cross-Dataset Comparison**: Overlay signals from different datasets

### Architecture Extensions

1. **Plugin System**: Allow custom signal processors
2. **Event System**: Formal event bus for synchronization
3. **State Management**: Centralized state management
4. **Undo/Redo**: History management for user actions

---

**Version**: 1.0  
**Last Updated**: October 2025  
**Maintainer**: Golf Swing Analysis Team

