# MATLAB Best Practices Rules for Cursor

This document consolidates style, correctness, performance optimization, and project organization guidelines for MATLAB programming.
It acts like Ruff (lint checks) and Black (formatter) combined—Cursor should apply these rules automatically where possible.

---

## 🎯 Core Principles
- **MUST** write clear, maintainable code before optimizing.
- **MUST** profile before optimizing performance.
- **MUST** organize projects with proper folder structure.
- **SHOULD** use vectorization, preallocation, and built-ins when possible.
- **AVOID** unsafe constructs (`inv`, `eval`, `global`).
- **Clarity First**: Write simple, readable, maintainable code.
- **Efficiency**: Use vectorization, preallocation, and built-ins to maximize speed.
- **Column-Major Awareness**: MATLAB stores arrays in column-major order; loop accordingly.
- **Correctness**: Avoid unsafe constructs (`inv`, `eval`, `global`). Validate all inputs and outputs.
- **Profiling**: Optimize only after profiling with `profile`, `timeit`, or `gputimeit`.

---

## 📁 Project Organization & Folder Structure

### **MUST** Follow Proper Project Organization
- **Main Directory**: Keep clean with only essential files
  - Main application file (e.g., `Data_GUI_Enhanced.m`)
  - Project README.md
  - Configuration files (e.g., `user_preferences.mat`)
  - Essential data files
- **Functions Directory**: `functions/` folder for all extracted modules
  - Group functions by responsibility (simulation, GUI, data processing, etc.)
  - One function per file (filename == function name)
  - Organize related functions in logical subdirectories if needed
- **Documentation Directory**: `docs/` folder for all documentation
  - README files, guides, and analysis documents
  - Refactoring documentation and progress tracking
  - Performance analysis and optimization guides
  - User documentation and tutorials
- **Test Directory**: `tests/` folder for unit tests and validation scripts
  - Unit tests for individual functions
  - Integration tests for modules
  - Performance benchmarks
- **Data Directory**: `data/` folder for input/output data files
  - Input datasets and configuration files
  - Output results and generated data
  - Temporary files and caches

### **Project Structure Template**
```
ProjectName/
├── MainApplication.m           # Main application entry point
├── README.md                  # Project overview and navigation
├── functions/                 # All function modules
│   ├── core/                  # Core functionality modules
│   ├── gui/                   # GUI-related functions
│   ├── data/                  # Data processing functions
│   ├── utils/                 # Utility functions
│   └── tests/                 # Test functions
├── docs/                      # Documentation
│   ├── user_guides/           # User documentation
│   ├── technical/             # Technical documentation
│   ├── refactoring/           # Refactoring progress
│   └── performance/           # Performance analysis
├── tests/                     # Unit and integration tests
├── data/                      # Data files
│   ├── input/                 # Input data
│   ├── output/                # Output results
│   └── temp/                  # Temporary files
├── config/                    # Configuration files
└── archive/                   # Backup and archive files
```

### **Folder Organization Rules**
- **MUST** separate functions from documentation
- **MUST** keep main directory clean and focused
- **SHOULD** group related functions in subdirectories
- **SHOULD** use descriptive folder names
- **AVOID** mixing code, docs, and data in same directory
- **AVOID** having more than 10 files in main directory

---

## 💅 Code Formatting & Style
- **MUST** use 4 spaces (no tabs) and keep lines ≤100 chars.
- **MUST** use camelCase for vars/functions, PascalCase for classes/scripts, UPPER_CASE for constants.
- **MUST** one function per file, filename == function name.
- **SHOULD** use descriptive names (`velocity` not `v`).
- **SHOULD** comment *why*, not *what*.
- **AVOID** `clear all`, `clc`, `close all`, or `addpath` in library code.
- **Indentation**: 4 spaces, no tabs.
- **Line Length**: Max 80–100 characters.
- **Naming**:
  - Variables & functions: `camelCase`
  - Classes & scripts: `PascalCase`
  - Constants: `UPPER_CASE`
  - Booleans: prefix with `is`, `has` (`isValid`, `hasConverged`)
- **Comments**:
  - Use `%` for single line, `%%` for cells, `%{ ... %}` for blocks.
  - Comment *why*, not *what*.
- **Functions**:
  - One function per `.m` file. Filename == function name.
  - Start with an H1 help line, purpose, inputs, outputs, and examples.
  - Use `arguments` blocks (R2019b+) or `validateattributes`.
  - Always end with `end`.
- **Hygiene**:
  - No `clear all`, `clc`, `close all`, or `addpath` in library code.
  - Avoid shadowing built-ins (`sum`, `table`, `length`).

---

## 🔧 Refactoring & Modularization Guidelines

### **When to Extract Functions**
- **MUST** extract functions when main file exceeds 500 lines
- **MUST** extract functions when single file contains 10+ functions
- **SHOULD** extract functions for single responsibility principle
- **SHOULD** extract functions for reusability across projects
- **SHOULD** extract functions for easier testing and debugging

### **Function Extraction Strategy**
- **Group by Responsibility**: Extract related functions together
- **Maintain Interface**: Preserve function signatures and behavior
- **Update Dependencies**: Ensure all function calls are updated
- **Preserve Parallel Computing**: Maintain `AttachedFiles` and worker compatibility
- **Document Changes**: Update documentation and README files

### **Module Organization**
- **Core Modules**: Essential functionality (simulation, data processing)
- **GUI Modules**: User interface and interaction functions
- **Utility Modules**: Helper functions and tools
- **Configuration Modules**: Settings and preferences management
- **Test Modules**: Validation and testing functions

---

## ✅ Correctness & Reliability
- **MUST** use `A\b`, not `inv(A)`.
- **MUST** compare floats with tolerance, not `==`.
- **MUST** validate all inputs and outputs.
- **MUST** seed RNG in tests (`rng(0,"twister")`).
- **SHOULD** use `numel`, `size`, `isempty` instead of `length`.
- **AVOID** `eval`, `assignin`, `global`, or shadowing built-ins.
- **NEVER** use `inv(A)`; use `A\b`, `chol`, `qr`, or `svd`.
- Use tolerances for floating-point comparisons: `abs(a-b) <= tol`.
- Seed RNG in tests: `rng(0, "twister")`.
- Avoid `eval`, `assignin`, `feval("...")`, `load` without outputs, and `global`.
- Prefer `numel`, `size`, `isempty` over `length`.
- Use `string` instead of `char` when interfacing with APIs.
- Use `assert`, `error`, and descriptive IDs for error handling.

### Dependency & Path Validation for MATLAB/Simulink Workflows
- **MUST** verify that required helper functions exist on the MATLAB path before running simulations.
- **MUST** verify that required model files exist before starting simulations.
- **MUST** check for required MATLAB toolboxes (Simulink, Simscape, Parallel Computing Toolbox, etc.) based on execution mode.
- **SHOULD** implement preflight validation routines that fail fast if dependencies are missing.
- **SHOULD** validate dependencies as part of configuration validation, consistent with existing model file checks.

**Implementation Pattern:**
- Use `exist(functionName, 'file')` to check if functions are on the path.
- Use `exist(modelPath, 'file')` to verify model files exist (already standard practice).
- Use `license('test', 'Toolbox_Name')` to check for required toolboxes.
- Create a `validateDependencies()` function that:
  - Loops over required function names and raises clear errors if missing.
  - Checks toolbox availability based on execution mode flags.
  - Emits clear error messages listing missing dependencies.
- Run dependency validation early in the workflow (e.g., in `validateSimulationConfig` or as a preflight step before long simulations).
- This improves reliability for batch/parallel runs and checkpoint/resume flows by failing before long simulations start.

**Example:**
```matlab
function validateDependencies(requiredFunctions, requiredToolboxes)
    % Validate that all required functions exist on MATLAB path
    missingFunctions = {};
    for i = 1:length(requiredFunctions)
        if exist(requiredFunctions{i}, 'file') ~= 2
            missingFunctions{end+1} = requiredFunctions{i};
        end
    end

    % Validate required toolboxes
    missingToolboxes = {};
    for i = 1:length(requiredToolboxes)
        if ~license('test', requiredToolboxes{i})
            missingToolboxes{end+1} = requiredToolboxes{i};
        end
    end

    % Raise error if any dependencies are missing
    if ~isempty(missingFunctions) || ~isempty(missingToolboxes)
        errorMsg = 'Missing dependencies:\n';
        if ~isempty(missingFunctions)
            errorMsg = [errorMsg, sprintf('  Functions: %s\n', strjoin(missingFunctions, ', '))];
        end
        if ~isempty(missingToolboxes)
            errorMsg = [errorMsg, sprintf('  Toolboxes: %s\n', strjoin(missingToolboxes, ', '))];
        end
        error('DependencyValidation:MissingDependencies', errorMsg);
    end
end
```

---

## 🚀 Performance Optimization
- **MUST** profile (`profile`, `timeit`, `gputimeit`) before optimizing.
- **MUST** preallocate arrays (zeros/ones/nan/cell/spalloc).
- **MUST** respect column-major memory order in loops.
- **SHOULD** vectorize loops with built-ins where possible.
- **AVOID** growing arrays, row-major loops, or redundant temporaries.

### 1. Vectorization & Built-ins
- Replace loops with vectorized ops:
  ```matlab
  y = sin(x) + cos(x); % instead of looping
  ```
- Use logical indexing instead of `find` unless indices are required.
- Favor built-ins (`sum`, `mean`, `accumarray`, `conv`, `fft`, `unique`) over manual loops.
- Avoid `arrayfun`/`cellfun` for speed (fine for clarity).

### 2. Preallocation
- **Critical Rule**: Preallocate arrays with `zeros`, `ones`, `nan`, `cell`, or `spalloc`.
- Never grow arrays in a loop.
- Preallocate cell arrays and structs if filled in loops.

### 3. Memory & Loop Layout
- MATLAB is column-major:
  ```matlab
  for j = 1:n
      for i = 1:m
          A(i,j) = A(i,j) + c;
      end
  end
  ```
- Access by columns for contiguous memory.
- Minimize transposes and temporary copies.
- Use sparse matrices for large, mostly-zero data.

### 4. Linear Algebra
- Use `A\b` instead of `inv(A)*b`.
- Reuse factorizations (`chol`, `qr`, `lu`) instead of solving repeatedly.
- Avoid forming `A'*A` explicitly unless well-conditioned.

### 5. ODEs & Simulation Kernels
- Match solver to problem: `ode45` (non-stiff), `ode15s`/`ode23t` (stiff), `ode113` (high-accuracy).
- Provide Jacobians/mass matrices via `odeset` for speed.
- Keep RHS functions pure: no plotting, no I/O, no array growth.
- Vectorize RHS for multi-trajectory integration.

### 6. Parallel & GPU
- Use `parfor` when iterations are independent; preallocate sliced outputs.
- Use `parfeval` for asynchronous tasks.
- For GPU: transfer once (`gpuArray`), compute, then `gather` once.
- Benchmark GPU code with `gputimeit`.
- **Preserve Parallel Computing**: When refactoring, maintain `AttachedFiles` list and worker function compatibility.

### 7. File I/O & Tables
- Use `readmatrix`/`readtable`, not `xlsread`.
- Convert tables to arrays in inner loops.
- Always close files (`fclose(fid)`).

### 8. Graphics
- Precreate graphics objects; update properties (`XData`, `YData`) instead of recreating.
- Throttle redraws with `drawnow limitrate`.

---

## 🔧 MATLAB Idioms & Patterns
- Preallocate lists via cells then `cat` once.
- Hoist invariants out of loops.
- Use `accumarray`, `blkdiag`, `kron` for aggregation and block ops.
- Prefer linear indexing (`A(idx)`) with `sub2ind` when possible.

---

## 🧪 Testing & Tooling
- **MUST** write deterministic unit tests (`matlab.unittest`).
- **MUST** assert correctness with tolerances.
- **SHOULD** use fixtures for CI-friendly tests.
- **AVOID** including figures or UI in tests.
- Write unit tests with `matlab.unittest`.
- Use fixtures for temp files, CI-friendly tests.
- Time with `timeit`, `tic/toc`, or `profile`.
- Monitor memory with `whos`, `memory`.

---

## 📋 Workflow Improvements

### **Development Workflow**
1. **Start with Clean Structure**: Set up proper folder organization from the beginning
2. **Extract Early**: Don't wait until files become monolithic
3. **Document as You Go**: Keep documentation updated with code changes
4. **Test Incrementally**: Write tests for each extracted function
5. **Profile Regularly**: Monitor performance during development
6. **Review Structure**: Periodically review and reorganize as needed

### **Refactoring Workflow**
1. **Analyze Current State**: Identify functions to extract and their dependencies
2. **Plan Extraction**: Group related functions and plan module organization
3. **Extract Incrementally**: Extract one module at a time, test thoroughly
4. **Update Dependencies**: Ensure all function calls and imports are updated
5. **Preserve Functionality**: Maintain all existing features and performance
6. **Update Documentation**: Keep all documentation current
7. **Reorganize Structure**: Move files to appropriate folders

### **Collaboration Workflow**
1. **Clear Structure**: Use consistent folder organization across team
2. **Documentation**: Keep README files updated with current structure
3. **Code Reviews**: Include folder organization in review process
4. **Version Control**: Use meaningful commit messages for structural changes
5. **Onboarding**: Provide clear navigation guides for new team members

---

## 🛑 Common Anti-Patterns
- **AVOID** growing arrays dynamically.
- **AVOID** using `eval` for variable names.
- **AVOID** using `global` unnecessarily.
- **AVOID** row-major loop order (slow).
- **AVOID** repeated plotting in compute loops.
- **AVOID** using `find` when logical indexing suffices.
- **AVOID** monolithic files with 100+ functions.
- **AVOID** mixing code, docs, and data in same directory.
- **AVOID** cluttered main directories with 50+ files.
- Growing arrays dynamically.
- Using `eval` for variable names.
- Using `global` unnecessarily.
- Row-major loop order (slow).
- Repeated plotting inside loops.
- Using `find` where logical indexing suffices.

---

## 📋 Code Review Checklist
- [ ] Preallocation everywhere arrays grow
- [ ] Loops vectorized where possible
- [ ] Column-major loop order respected
- [ ] No `inv`, `eval`, or globals
- [ ] Built-ins used over custom loops
- [ ] Input validation present
- [ ] Dependency validation for MATLAB/Simulink workflows (functions, models, toolboxes)
- [ ] Descriptive names and comments
- [ ] Unit tests written
- [ ] Plots efficient (no redraw in compute loops)
- [ ] Profiling evidence for performance claims
- [ ] Proper folder organization maintained
- [ ] Functions extracted when files exceed 500 lines
- [ ] Documentation updated with structural changes
- [ ] Parallel computing compatibility preserved
- [ ] Main directory clean and focused

---

## 📚 Resources
- [MATLAB Performance Tips](https://www.mathworks.com/help/matlab/matlab_prog/techniques-for-improving-performance.html)
- [Vectorization](https://www.mathworks.com/help/matlab/matlab_prog/vectorization.html)
- [Memory Management](https://www.mathworks.com/help/matlab/matlab_prog/resolving-out-of-memory-errors.html)
- [Profiling](https://www.mathworks.com/help/matlab/ref/profile.html)
- [Parallel Computing](https://www.mathworks.com/help/parallel-computing/)
- [Project Organization Best Practices](https://www.mathworks.com/help/matlab/matlab_prog/developing-and-maintaining-large-projects.html)

---

## 🔑 Attitude Check
- If it's slow, **prove it** with the profiler before changing code.
- If it's clever, make it clearer—or make it simpler.
- If it's disorganized, **reorganize it** following proper structure.
- And remember: **never use `inv`**.
