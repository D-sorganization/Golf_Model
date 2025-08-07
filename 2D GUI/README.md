# 2D Golf Swing Analysis GUI

This directory contains the MATLAB interface for running and exploring the 2D golf swing model.

## Installation Prerequisites

- MATLAB R2022a or later
- Simulink
- Simscape and Simscape Multibody toolboxes
- Optional: MATLAB Drive for default data paths
- Access to the `2DModel` folder and its subdirectories (`Scripts`, `Tables`, `Model Output`)

## Launching the GUI

1. Open MATLAB and change the current folder to the repository root.
2. Run the launcher:
   ```matlab
   launch_gui
   ```
   The script adds all subdirectories to the MATLAB path and opens the main interface.

## Tabs and Features

- **🎮 Simulation** – Adjust model parameters, run simulations, and view a 2D animation of the club, hands, and torso.
- **📊 ZTCF/ZVCF Analysis** – Execute the full pipeline to generate Base, ZTCF, DELTA, and ZVCF data tables and save them to disk.
- **📈 Plots & Interaction** – Interactive plot viewer and data explorer with time‑series, phase, quiver, and comparison plots.
- **🦴 Skeleton Plotter** – 3D visualization of BASEQ, ZTCFQ, and DELTAQ skeleton states.

## Required MATLAB/Simulink Toolboxes

The simulation relies on Simulink and the Simscape Multibody infrastructure. Ensure licenses for Simulink, Simscape, and Simscape Multibody are available. Additional MATLAB toolboxes may be required depending on custom scripts used in the `2DModel` directory.

## Data Expectations

The GUI assumes the `2DModel` directory contains the `GolfSwing.slx` model and related scripts. Default paths are configured in `config/model_config.m`, which points to a `Tables` folder where Base, ZTCF, DELTA, and ZVCF tables are stored. Run the analysis pipeline to generate these tables before using advanced plotting or skeleton visualization features.

