### Post Test Processing: Force Moments and Joint Power/Work

This guide explains how to compute Force Moments and Joint Power/Work on generated trials and how to access the feature from both GUIs.

#### What is computed
- Moment of Force (MOF): r x F computed in global frame per body/marker prefix
- Equivalent Moment at Reference: Global torque + (r x F)
- Global Force and Torque: Rotation of local vectors using the logged rotation transform
- Joint Power: tau · omega per joint (component-wise dot product)
- Joint Work: Integral of power over time; peak power tracked as well

Assumptions
- Local force/torque columns use suffixes `_ForceLocal_[1..3]`, `_TorqueLocal_[1..3]`
- Rotation matrix columns `_Rotation_Transform_I11..I33` map local→global
- Global positions available as `_GlobalPosition_[1..3]`
- Angular velocity columns `_AngularVelocityX|Y|Z` (or derived from `_AngularPositionX|Y|Z` when time is present)

#### New functions
- `calculateForceMoments.m`
  - Input: `table` or `struct`
  - Name-Value options:
    - `ReferencePoint` [x y z] or `ReferencePointName` (prefix in table)
    - `Prefixes` to limit processing
  - Appends: global force/torque, MOF vector and magnitude, equivalent moment and magnitude

- `CalculateJointPowerWork.m`
  - Input: `table` or `struct`
  - Name-Value options:
    - `Time` (Nx1) optional override
    - `AngleSuffix`, `VelSuffix`, `TorqueSuffix`, `JointPrefixes`
  - Appends: `<joint>_Power`, `<joint>_Work`, `<joint>_PeakPower` (table) or fields under `joint_data`

#### Using in Enhanced GUI (`Data_GUI_Enhanced`)
- Go to the Post-Processing tab
- Select a data folder and choose files
- Click Start Processing
- For MAT files that contain `data_table`, the tool adds MOF/equivalent moment columns and joint power/work columns
- Output is saved per batch to the chosen format

#### Using in Classic GUI (`Data_GUI`)
- A new button "Post Test Processing" is available in the right column
- Select the folder that contains your saved trials (MAT preferred)
- The tool will create `processed_data` inside that folder and save processed files
- If `PostProcessingModule.processDataFolder` is available, it delegates to it; otherwise a fallback light processor runs

#### Notes
- If a `Club_*` prefix is present with global position, it is used as reference point. Otherwise origin [0,0,0] is used.
- Power computation requires angular velocity; if not present, it is derived from angles when time is available.
- Column naming must match the extraction outputs; see `1809_headers.txt` and `1956_headers.txt` for examples.

#### Validation tips
- Sanity-check units: If angles are in radians and torques in N·m, power is in watts.
- MOF units: N·m (from meters × Newtons).
- Check orthonormality of rotation transform columns if values look inconsistent.