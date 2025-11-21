# Simulink Cache Configuration

This directory contains the Simulink cache and code generation folders. These are automatically excluded from git tracking.

## Setup Instructions

To configure MATLAB/Simulink to use the cache directories in this repository:

### Quick Setup (Recommended)

Run the complete setup script which handles both cache configuration and path cleanup:

```matlab
cd matlab
setup_matlab_environment
```

### Manual Setup

If you prefer to configure components separately:

1. **Configure Simulink cache**:
   ```matlab
   cd matlab
   configure_simulink_cache
   ```

2. **Clean up MATLAB path** (removes old Backup_Scripts references):
   ```matlab
   cd matlab/Scripts/Dataset Generator/utils
   cleanup_matlab_path
   ```

3. **Verify the configuration** - Check Simulink settings:
   ```matlab
   Simulink.fileGenControl('get')
   ```

4. **Restart MATLAB** (optional but recommended) to ensure all settings are loaded.

## Cache Locations

- **Cache Folder**: `matlab/cache/simulink/cache/`
  - Stores Simulink model cache files (`.slxc`)

- **Code Generation Folder**: `matlab/cache/simulink/codegen/`
  - Stores generated code from Simulink code generation

## Notes

- These directories are automatically created when you run `configure_simulink_cache.m`
- The cache directories are excluded from git via `.gitignore`
- Settings persist in your MATLAB preferences, so you only need to run the script once
- If you move the repository, you may need to re-run the configuration script

## Troubleshooting

### Missing Cache Folder Warnings

If you see warnings about missing cache folders:
1. Run `setup_matlab_environment` or `configure_simulink_cache` in MATLAB
2. Check that the directories were created in `matlab/cache/simulink/`
3. Verify the paths in MATLAB: `Simulink.fileGenControl('get')`

### Backup_Scripts Warnings

If you see warnings about missing Backup_Scripts directory:
1. Run `setup_matlab_environment` to automatically clean up the path
2. Or manually remove from MATLAB path:
   - Go to: **Home > Environment > Set Path**
   - Remove any entries containing "Backup_Scripts"
   - Click **Save**
3. The Backup_Scripts directory is no longer used - backups are now stored in `archive/backups/`
