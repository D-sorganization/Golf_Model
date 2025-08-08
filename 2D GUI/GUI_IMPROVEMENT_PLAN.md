### 2D GUI Review and Improvement Plan

This document summarizes critical findings in the `2D GUI` implementation and provides prioritized, concrete code instructions to improve robustness, correctness, and maintainability.

---

## High-Impact Issues (Fix first)

- **Function name shadowing causes recursion/errors**: Local GUI callback functions in `main_scripts/golf_swing_analysis_gui.m` use the same names as functions in `data_processing/` (e.g., `generate_base_data`, `generate_ztcf_data`, `process_data_tables`). This will shadow the real implementations and can cause incorrect recursion or runtime errors when invoked with different signatures.
- **Pipeline function signature mismatches**: `main_scripts/run_ztcf_zvcf_analysis.m` requests outputs and passes arguments not supported by the current `process_data_tables.m` and `save_data_tables.m`.
- **ZVCF generation is a placeholder**: `generate_zvcf_data` is invoked via a local callback but re-uses `generate_ztcf_data` instead of a dedicated implementation.
- **Figure name inconsistencies**: Some functions search for a figure by name string that doesn’t match the actual GUI title, leading to failures retrieving appdata.
- **Skeleton wrapper uses `isfield` on tables**: `visualization/skeleton_plotter_wrapper.m` uses `isfield` for MATLAB tables, which is incorrect.
- **Standalone viewers contain placeholders**: `visualization/create_advanced_plot_viewer.m` and `visualization/create_data_explorer.m` contain placeholder handlers and sample data rather than loading real GUI data.
- **Duplicate/overlapping visualizers**: There are three visualizer implementations (`GolfSwingVisualizer.m`, `SkeletonPlotter.m`, and `skeleton_plotter_wrapper.m`) with overlapping responsibilities.

---

## P0 Fixes (mandatory)

### 1) Stop local function shadowing in `golf_swing_analysis_gui.m`

- Rename callback-style local functions so they no longer collide with real implementations in `data_processing/`.
- Update button callbacks to point to the renamed local handlers.
- Inside handlers, call the external processing functions.

Edits to make in `main_scripts/golf_swing_analysis_gui.m`:

- Rename local functions:
  - `function generate_base_data(src, ~)` → `function on_generate_base_data(src, ~)`
  - `function generate_ztcf_data(src, ~)` → `function on_generate_ztcf_data(src, ~)`
  - `function generate_zvcf_data(src, ~)` → `function on_generate_zvcf_data(src, ~)`
  - `function process_data_tables(src, ~)` → `function on_process_data_tables(src, ~)`

- Update UI callbacks to use the renamed handlers in the Analysis tab:
  - “Generate Base Data” button → `@on_generate_base_data`
  - “Generate ZTCF Data” button → `@on_generate_ztcf_data`
  - “Generate ZVCF Data” button → `@on_generate_zvcf_data`
  - “Process Data Tables” button → `@on_process_data_tables`

- Within each renamed handler, call external functions from `data_processing/` (these exist already, except ZVCF - see P0.2):

```matlab
% inside on_generate_base_data
mdlWks = initialize_model(config);
BaseData = generate_base_data(config, mdlWks); % calls data_processing/generate_base_data.m
setappdata(main_fig, 'BaseData', BaseData);
```

```matlab
% inside on_generate_ztcf_data
mdlWks = initialize_model(config);
ZTCF = generate_ztcf_data(config, mdlWks, BaseData); % calls data_processing/generate_ztcf_data.m
setappdata(main_fig, 'ZTCF', ZTCF);
```

```matlab
% inside on_process_data_tables
[BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF); % calls data_processing/process_data_tables.m
save_data_tables(config, BASEQ, ZTCFQ, DELTAQ); % calls data_processing/save_data_tables.m
setappdata(main_fig, 'BASEQ', BASEQ);
setappdata(main_fig, 'ZTCFQ', ZTCFQ);
setappdata(main_fig, 'DELTAQ', DELTAQ);
```

Citations of local shadowing to update:

```700:940:2D GUI/main_scripts/golf_swing_analysis_gui.m
% ... create_skeleton_tab ...
```

```1375:1465:2D GUI/main_scripts/golf_swing_analysis_gui.m
function generate_base_data(src, ~)
    % Shadowing external function; rename to on_generate_base_data and call external generate_base_data(config, mdlWks)
```

```1453:1563:2D GUI/main_scripts/golf_swing_analysis_gui.m
function generate_ztcf_data(src, ~)
    % Shadowing external function; rename to on_generate_ztcf_data and call external generate_ztcf_data(config, mdlWks, BaseData)
```

```1509:1600:2D GUI/main_scripts/golf_swing_analysis_gui.m
function generate_zvcf_data(src, ~)
    % Shadowing external function AND incorrectly calls generate_ztcf_data; rename to on_generate_zvcf_data and call new data_processing/generate_zvcf_data
```

```1565:1600:2D GUI/main_scripts/golf_swing_analysis_gui.m
function process_data_tables(src, ~)
    % Shadowing external function; rename to on_process_data_tables and call external process_data_tables(config, BaseData, ZTCF)
```

### 2) Implement a real `generate_zvcf_data.m`

Create `data_processing/generate_zvcf_data.m` with logic analogous to ZTCF, using the available ZVCF generator script or appropriate parameterization.

Suggested implementation (align with your scripts and naming):

```matlab
function ZVCF = generate_zvcf_data(config, mdlWks, BaseData)
% GENERATE_ZVCF_DATA - Generate ZVCF (Zero Velocity Counterfactual) data

    % Initialize table structure from BaseData
    ZVCFTable = BaseData; ZVCFTable(:,:) = [];

    % Change to scripts directory
    cwd = pwd; cleanupObj = onCleanup(@() cd(cwd));
    cd(config.scripts_path);

    fprintf('🔄 Generating ZVCF data...\n');

    % Example loop pattern; adjust ranges/parameters per your methodology
    for i = config.ztcf_start_time:config.ztcf_end_time
        t = i / config.ztcf_time_scale;

        % Configure model/workspace for ZVCF (zero velocity condition)
        % If you have a specific script, run that instead:
        % SCRIPT_ZVCF_GENERATOR should set Data variable like SCRIPT_TableGeneration does.
        assignin(mdlWks, 'KillswitchStepTime', Simulink.Parameter(t));

        % Run simulation with ZVCF configuration
        out = sim(config.model_name); %#ok<NASGU>

        % Expect a script to populate Data for current condition
        SCRIPT_ZVCF_GENERATOR; % Must exist in Scripts; otherwise, implement the equivalent logic

        % Extract the appropriate row for this t (similar to ZTCF selector)
        row = find(Data.KillswitchState == 0, 1);
        if isempty(row)
            warning('No ZVCF state row found at time %.3f', t);
            continue;
        end

        oneRow = Data(row, :);
        ZVCFTable = [ZVCFTable; oneRow]; %#ok<AGROW>
    end

    % Reset killswitch time and return
    assignin(mdlWks, 'KillswitchStepTime', Simulink.Parameter(config.killswitch_time));

    ZVCF = ZVCFTable;
    fprintf('✅ ZVCF data generated successfully (%d rows)\n', height(ZVCF));
end
```

Then, in the renamed `on_generate_zvcf_data`, call:

```matlab
ZVCF = generate_zvcf_data(config, mdlWks, BaseData);
setappdata(main_fig, 'ZVCF', ZVCF);
```

### 3) Fix pipeline mismatches in `run_ztcf_zvcf_analysis.m`

- Either archive this file if not used by the GUI, or make it consistent with the current function signatures.
- Minimal fix version:

```matlab
% 5. Process data tables
[BASEQ, ZTCFQ, DELTAQ] = process_data_tables(config, BaseData, ZTCF);

% 7. Save results
save_data_tables(config, BASEQ, ZTCFQ, DELTAQ);
```

- Remove unused outputs `BASE, ZTCF, DELTA, ZVCFTable` (or produce them explicitly if you need both raw and Q versions). If keeping ZVCF, add a proper call to the new `generate_zvcf_data` and a save step for it as needed.

Citations of mismatches:

```1:66:2D GUI/main_scripts/run_ztcf_zvcf_analysis.m
[BASE, ZTCF, DELTA, BASEQ, ZTCFQ, DELTAQ] = process_data_tables(...)
% process_data_tables currently returns [BASEQ, ZTCFQ, DELTAQ]

save_data_tables(config, BASE, ZTCF, DELTA, BASEQ, ZTCFQ, DELTAQ, ZVCFTable, ZVCFTableQ)
% save_data_tables currently accepts (config, BASEQ, ZTCFQ, DELTAQ)
```

### 4) Standardize figure retrieval and config usage

- Replace hard-coded `findobj('Name', '...')` lookups with a robust method that starts from the callback source, falling back to the current figure, and using `config.gui_title` only if needed.

Recommended helper pattern inside callbacks:

```matlab
function main_fig = get_main_fig_from_src(src)
    main_fig = ancestor(src, 'figure');
    if isempty(main_fig) || ~ishandle(main_fig)
        main_fig = gcf; % fallback
    end
end
```

Then use:

```matlab
main_fig = get_main_fig_from_src(src);
config = getappdata(main_fig, 'config');
```

Citations showing string-based lookups that should be refactored:

```1453:1507:2D GUI/main_scripts/golf_swing_analysis_gui.m
main_fig = findobj('Name', '2D Golf Swing Model - ZTCF/ZVCF Analysis');
```

```3847:3897:2D GUI/main_scripts/golf_swing_analysis_gui.m
main_fig = findobj('Name', '2D Golf Swing Analysis GUI'); % name mismatch vs config.gui_title
```

### 5) Fix table field checks in `skeleton_plotter_wrapper.m`

- Replace `isfield(dataset, 'Var')` with table-aware checks:

```matlab
hasForces = ismember('TotalHandForceGlobal', dataset.Properties.VariableNames);
hasTorques = ismember('EquivalentMidpointCoupleGlobal', dataset.Properties.VariableNames);
```

- Also update warnings accordingly and ensure indexing uses table variables.

Citations:

```1:60:2D GUI/visualization/skeleton_plotter_wrapper.m
missing_forces = setdiff(force_columns, BASEQ.Properties.VariableNames);
% later uses isfield(dataset, ...) which is incorrect for tables
```

### 6) Ensure `cd` hygiene in data processing functions

Wrap directory changes with an onCleanup to restore CWD:

```matlab
cwd = pwd; cleanupObj = onCleanup(@() cd(cwd));
cd(config.scripts_path);
% ... work ...
```

Apply to `generate_base_data.m`, `generate_ztcf_data.m`, `run_additional_processing.m`, and new `generate_zvcf_data.m`.

---

## P1 Improvements

### 7) Connect standalone viewers to real GUI data

- In `visualization/create_advanced_plot_viewer.m` and `visualization/create_data_explorer.m`, replace placeholder handlers with data access from the main GUI appdata (`BASEQ`, `ZTCFQ`, `DELTAQ`, and optionally `ZVCF`).
- Example for populating variable lists:

```matlab
% At viewer creation time, pass data tables or fetch from main GUI
main_fig = findobj('Type','figure','-regexp','Name', '2D Golf Swing Model');
BASEQ = getappdata(main_fig, 'BASEQ');
vars = setdiff(BASEQ.Properties.VariableNames, 'Time');
set(variable_popup, 'String', vars);
```

- Implement real `update_time_series_plot`, `update_phase_plot`, etc., by reading the selected dataset/table and plotting on the stored axes handle.

Citations of placeholders:

```512:544:2D GUI/visualization/create_advanced_plot_viewer.m
% Placeholder callbacks
```

```250:285:2D GUI/visualization/create_data_explorer.m
% Sample data/statistics used instead of real tables
```

### 8) Prefer a single 3D visualizer

- Consolidate on `visualization/GolfSwingVisualizer.m` (most robust and feature-rich).
- Move `visualization/SkeletonPlotter.m` and `visualization/skeleton_plotter_wrapper.m` to `Archive/` or clearly mark as legacy to reduce duplication.
- Ensure the Skeleton tab’s “Launch Skeleton Plotter” calls only `GolfSwingVisualizer(BASEQ, ZTCFQ, DELTAQ)` (already implemented at:

```1660:1737:2D GUI/main_scripts/golf_swing_analysis_gui.m
GolfSwingVisualizer(BASEQ, ZTCFQ, DELTAQ);
```

### 9) Make config paths robust to environment

- `config/model_config.m` currently uses `matlabdrive`. Prefer computing paths relative to the repo so it works in any environment.

Recommended approach:

```matlab
base_dir = fileparts(fileparts(mfilename('fullpath'))); % points to repo/2D GUI/config -> repo
config.model_path  = fullfile(base_dir, '2DModel');
config.scripts_path = fullfile(config.model_path, 'Scripts');
config.tables_path  = fullfile(config.model_path, 'Tables');
config.output_path  = fullfile(config.model_path, 'Model Output');
```

### 10) GUI robustness: timers and cleanup

- Ensure any timers (e.g., in visualizers) are stopped and deleted on figure close.
- For `GolfSwingVisualizer`, this is largely handled; confirm no orphan timers remain after closure.

### 11) Performance monitor improvements

- Replace CPU placeholder with a lightweight sampling of `feature('numcores')` and iteration timing, or remove CPU and keep memory stats.

Citations:

```3406:3414:2D GUI/main_scripts/golf_swing_analysis_gui.m
% CPU usage placeholder
```

---

## P2 Polish

- Consistent UI copy and titles: ensure the main figure name matches `config.gui_title` everywhere.
- Improve error dialogs to guide the user to run missing steps (e.g., “Generate Base Data first”).
- Add small unit tests to validate function existence, signatures, and absence of name shadowing (adapt from `Archive/test_*` files).

---

## Quick Checklist

- [ ] Rename shadowing local functions in `golf_swing_analysis_gui.m` and update callbacks
- [ ] Add `data_processing/generate_zvcf_data.m`
- [ ] Fix `run_ztcf_zvcf_analysis.m` outputs/inputs or archive it
- [ ] Replace figure name string lookups with ancestor-based retrieval
- [ ] Fix table `isfield` checks in `skeleton_plotter_wrapper.m`
- [ ] Add CWD restoration in processing functions
- [ ] Wire real data into `create_advanced_plot_viewer.m` and `create_data_explorer.m`
- [ ] Consolidate on `GolfSwingVisualizer.m`; archive legacy visualizers
- [ ] Make config paths relative to repo
- [ ] Tidy timers, performance monitor

---

## Launch/Usage Notes

- Use `launch_gui` from MATLAB to add paths and open the main GUI:

```matlab
launch_gui;
```

- In the GUI:
  - Simulation tab → Run end-to-end (Base → ZTCF → Q-tables). ZVCF generation appears on Analysis tab if implemented.
  - Skeleton tab → Load Q-Data, then launch the 3D visualizer.

---

## Appendix: Helpful Code References

- Main GUI structure and tab creation:

```1:86:2D GUI/main_scripts/golf_swing_analysis_gui.m
% ... figure + 4 tabs created ...
```

- Local functions in conflict (rename):

```1375:1600:2D GUI/main_scripts/golf_swing_analysis_gui.m
% generate_base_data, generate_ztcf_data, generate_zvcf_data, process_data_tables
```

- Data processing functions (external):

```1:35:2D GUI/data_processing/generate_base_data.m
```

```1:78:2D GUI/data_processing/generate_ztcf_data.m
```

```1:74:2D GUI/data_processing/process_data_tables.m
```

```1:50:2D GUI/data_processing/save_data_tables.m
```

- Visualizers:

```1:1180:2D GUI/visualization/GolfSwingVisualizer.m
```

```1:584:2D GUI/visualization/SkeletonPlotter.m
```

```1:550:2D GUI/visualization/skeleton_plotter_wrapper.m
```
