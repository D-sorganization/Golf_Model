# Tabbed GUI Implementation Plan

## Overview

Create a comprehensive three-tab GUI application for golf swing analysis integrating model setup, ZTCF calculation, and visualization.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│           Golf Swing Analysis Application                   │
│                                                              │
│  ┌────────────┬────────────────┬─────────────────────────┐ │
│  │  Tab 1:    │   Tab 2:       │   Tab 3:                │ │
│  │  Model     │   ZTCF         │   Analysis &            │ │
│  │  Setup     │   Calculation  │   Visualization         │ │
│  └────────────┴────────────────┴─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Tab 1: Model Setup & Simulation

### Purpose

Configure model inputs and visualize the golf swing using Simscape Multibody.

### Features

1. **Input Parameters Panel**
   - Golfer physical parameters
   - Club parameters
   - Initial conditions
   - Control parameters
   - Load/Save default configurations

2. **Simscape Visualization**
   - Live 3D Simscape Multibody animation
   - Playback controls
   - Camera views
   - Export animation

3. **Quick Validation**
   - Check model convergence
   - Display key metrics
   - Error handling

### Workflow

```
Load Defaults → Adjust Parameters → Run Simulation → View Animation →
Accept/Modify → Pass to Tab 2
```

## Tab 2: ZTCF/ZVCF Calculation

### Purpose

Run ZTCF (Zero Torque Counterfactual) analysis to decompose active and passive dynamics.

### Features

1. **Calculation Control**
   - Number of iterations
   - Parallel processing toggle
   - Progress bar with time estimates
   - Cancel button

2. **Performance Optimization**
   - Parallel pool management
   - Memory-efficient data collection
   - Progress checkpointing
   - Resume capability

3. **Results Summary**
   - Iteration count
   - Calculation time
   - Data quality metrics
   - Error handling

4. **Data Export**
   - Save BASEQ, ZTCFQ, DELTAQ tables
   - Export to MAT files
   - Quick preview plots

### Workflow

```
Load from Tab 1 → Configure Iterations → Run (Parallel) →
Monitor Progress → Generate Tables → Pass to Tab 3
```

## Tab 3: Analysis & Visualization (Current Skeleton Plotter)

### Purpose

Analyze and visualize the golf swing data with interactive tools.

### Features

1. **Data Loading**
   - Load from Tab 2 (in-memory)
   - Load from file
   - Data validation

2. **3D Skeleton Visualization**
   - Current SkeletonPlotter functionality
   - All existing features preserved

3. **Interactive Signal Plotter** (Current Implementation)
   - Time-synchronized plotting
   - Signal selection
   - Bidirectional sync
   - All current features

4. **Additional Analysis Tools**
   - Export capabilities
   - Report generation
   - Statistical summaries

### Workflow

```
Load Data → Select Dataset (BASE/ZTCF/DELTA) →
3D Visualization + Signal Analysis → Export Results
```

## Implementation Strategy

### Phase 1: Fix Current Issues (IMMEDIATE)

1. Fix signal plot synchronization
2. Fix force/torque vector plotting (no magnitude)
3. Fix cleanup on close
4. Test all features work correctly

### Phase 2: Create Tabbed Framework

1. Create main GUI window with tab group
2. Implement Tab 3 (migrate current skeleton plotter)
3. Test data loading and visualization in tab context

### Phase 3: Implement Tab 1

1. Design parameter input panel
2. Integrate Simscape simulation
3. Implement visualization embedding
4. Add save/load defaults

### Phase 4: Implement Tab 2

1. Clean up ZTCF calculation script
2. Implement parallel processing
3. Add progress monitoring
4. Optimize for speed

### Phase 5: Integration & Testing

1. Data passing between tabs
2. Memory management
3. Error handling
4. Performance tuning

## Technical Considerations

### Data Passing Between Tabs

- Use `setappdata/getappdata` for in-memory sharing
- Fall back to file-based if memory constrained
- Clear intermediate data when not needed

### Performance

- Lazy loading: Only load/compute when tab is accessed
- Background processing for long calculations
- Efficient memory management
- Progress indicators for all long operations

### User Experience

- Disable tabs that require previous steps
- Clear status indicators
- Save session state
- Crash recovery

### Animation Smoothing

**Question**: Can we add interpolation for smoother animation?

- **Yes**: Use interp1() to upsample time vector
- **Impact**: Minimal slowdown if done smart (pre-compute)
- **Implementation**: Interpolate data before visualization
- **Trade-off**: Smoother animation vs slightly slower initial load

### Graphics Performance

**How to make graphics smooth and responsive:**

1. Limit update rate (30-60 FPS max)
2. Use efficient rendering (minimize redraws)
3. Buffer frames for playback
4. Use hardware acceleration
5. Simplify geometry if needed

## File Structure

```
matlab/Scripts/Golf_GUI/
├── Integrated_Analysis_App/          (NEW)
│   ├── main_golf_analysis_app.m      (Main entry point)
│   ├── tab1_model_setup.m
│   ├── tab2_ztcf_calculation.m
│   ├── tab3_visualization.m          (Existing skeleton plotter)
│   ├── utils/
│   │   ├── data_manager.m
│   │   ├── config_manager.m
│   │   └── parallel_manager.m
│   └── config/
│       └── default_parameters.mat
└── 2D GUI/
    └── visualization/                 (Existing)
        ├── SkeletonPlotter.m
        ├── InteractiveSignalPlotter.m
        └── ...
```

## Next Steps

### Immediate (This Session)

1. Fix synchronization issue
2. Fix force/torque plotting
3. Fix cleanup
4. Commit fixes to current branch

### Next Session

1. Create new branch: `feature/integrated-tabbed-gui`
2. Implement tabbed framework
3. Migrate skeleton plotter to Tab 3
4. Test integration

### Future Sessions

1. Implement Tab 1 (Model Setup)
2. Optimize and implement Tab 2 (ZTCF Calculation)
3. Full integration and testing
4. Performance optimization
5. Documentation

## Questions for User

1. **Animation smoothing**: Should we implement interpolation? (Minimal performance impact)
2. **Parallel processing**: How many cores typically available? Need specific optimization?
3. **Tab 2 script**: Can you provide the current ZTCF calculation script for review?
4. **Default parameters**: Where are model defaults currently stored?

---

**Status**: Planning Phase
**Current Focus**: Fix critical issues in signal plotter
**Next Phase**: Create tabbed GUI framework
