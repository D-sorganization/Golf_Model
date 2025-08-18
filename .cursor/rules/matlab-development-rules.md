# MATLAB Development Rules & Efficiency Guidelines

## 🎯 **Core Principles**
- **Efficiency First**: Always prioritize computational efficiency and memory management
- **Preallocation**: Preallocate arrays and matrices whenever possible
- **Vectorization**: Use vectorized operations instead of loops when feasible
- **Memory Awareness**: Understand MATLAB's memory layout and optimize accordingly
- **Code Quality**: Maintain clean, readable, and maintainable code

---

## 🚀 **Performance Optimization Rules**

### **1. Array Preallocation (CRITICAL)**
```matlab
% ❌ WRONG - Dynamic growth (extremely slow)
result = [];
for i = 1:10000
    result = [result, i^2];  % Creates new array each iteration
end

% ✅ CORRECT - Preallocate for known size
result = zeros(1, 10000);
for i = 1:10000
    result(i) = i^2;
end

% ✅ BETTER - Vectorized operation
result = (1:10000).^2;
```

**Rules:**
- **ALWAYS** preallocate arrays when size is known
- Use `zeros()`, `ones()`, `nan()`, or `empty()` for initialization
- Preallocate to exact size when possible, avoid over-allocation

### **2. Memory Layout Optimization**

#### **Row vs Column Major Considerations**
```matlab
% MATLAB uses COLUMN-MAJOR order internally
% Accessing columns is faster than rows

% ❌ SLOWER - Row-wise access
for i = 1:size(A, 1)
    for j = 1:size(A, 2)
        result(i, j) = A(i, j) * 2;
    end
end

% ✅ FASTER - Column-wise access
for j = 1:size(A, 2)
    for i = 1:size(A, 1)
        result(i, j) = A(i, j) * 2;
    end
end

% ✅ FASTEST - Vectorized
result = A * 2;
```

**Memory Layout Rules:**
- **Columns are contiguous** in memory - access them first in nested loops
- **Avoid transposing** large matrices unnecessarily
- **Use `(:)` indexing** for linear access when order doesn't matter

### **3. Vectorization Best Practices**

#### **Replace Loops with Vectorized Operations**
```matlab
% ❌ SLOW - Element-wise loop
result = zeros(size(x));
for i = 1:length(x)
    result(i) = sin(x(i)) + cos(x(i));
end

% ✅ FAST - Vectorized
result = sin(x) + cos(x);

% ❌ SLOW - Conditional loop
result = zeros(size(x));
for i = 1:length(x)
    if x(i) > 0
        result(i) = x(i)^2;
    else
        result(i) = 0;
    end
end

% ✅ FAST - Logical indexing
result = zeros(size(x));
positive_mask = x > 0;
result(positive_mask) = x(positive_mask).^2;
```

**Vectorization Rules:**
- **Use logical indexing** instead of conditional loops
- **Apply functions to entire arrays** rather than element-wise
- **Use `bsxfun` or implicit expansion** for element-wise operations
- **Prefer built-in functions** over custom loops

### **4. Memory Management**

#### **Avoid Memory Fragmentation**
```matlab
% ❌ BAD - Creates memory fragmentation
for i = 1:1000
    data{i} = rand(100, 100);  % Cell arrays can fragment memory
end

% ✅ BETTER - Preallocated cell array
data = cell(1000, 1);
for i = 1:1000
    data{i} = rand(100, 100);
end

% ✅ BEST - 3D array (if all elements same size)
data = rand(100, 100, 1000);
```

**Memory Rules:**
- **Use arrays instead of cell arrays** when possible
- **Clear large variables** when no longer needed
- **Avoid repeated `clear` commands** in loops
- **Use `pack` command** if memory becomes fragmented

---

## 📝 **Code Quality Standards**

### **1. Variable Naming Conventions**
```matlab
% ✅ GOOD - Descriptive names
angularVelocity = omega;
momentOfInertia = I;
timeStep = dt;
positionVector = r;

% ❌ BAD - Unclear names
av = w;
moi = I;
ts = dt;
pos = r;
```

**Naming Rules:**
- Use **camelCase** for variables
- Use **PascalCase** for functions and classes
- Use **UPPER_CASE** for constants
- **Always** use descriptive names, never single letters (except for loop indices)

### **2. Function Structure**
```matlab
function [output1, output2] = functionName(input1, input2)
    % FUNCTIONNAME - Brief description of function purpose
    %
    % Syntax:
    %   [output1, output2] = functionName(input1, input2)
    %
    % Inputs:
    %   input1 - Description of first input
    %   input2 - Description of second input
    %
    % Outputs:
    %   output1 - Description of first output
    %   output2 - Description of second output
    %
    % Example:
    %   [result, error] = functionName(data, threshold)
    %
    % Author: Your Name
    % Date: YYYY-MM-DD
    
    % Input validation
    validateattributes(input1, {'numeric'}, {'finite', 'nonempty'});
    validateattributes(input2, {'numeric'}, {'finite', 'nonempty'});
    
    % Preallocate output
    output1 = zeros(size(input1));
    output2 = zeros(size(input2));
    
    % Main computation
    % ... your code here ...
    
    % Post-processing and validation
    assert(all(isfinite(output1)), 'Output1 contains non-finite values');
    assert(all(isfinite(output2)), 'Output2 contains non-finite values');
end
```

**Function Rules:**
- **Always** include comprehensive header documentation
- **Validate inputs** using `validateattributes` or `assert`
- **Preallocate outputs** before computation
- **Validate outputs** before returning
- **Use meaningful variable names** throughout

### **3. Error Handling**
```matlab
% ✅ GOOD - Proper error handling
function result = safeDivision(numerator, denominator)
    if denominator == 0
        error('MATLAB:safeDivision:divisionByZero', ...
              'Denominator cannot be zero');
    end
    
    if ~isnumeric(numerator) || ~isnumeric(denominator)
        error('MATLAB:safeDivision:invalidInput', ...
              'Inputs must be numeric');
    end
    
    result = numerator / denominator;
end

% ❌ BAD - No error handling
function result = unsafeDivision(numerator, denominator)
    result = numerator / denominator;  % Will crash on division by zero
end
```

**Error Handling Rules:**
- **Always check for edge cases** (division by zero, empty arrays, etc.)
- **Use descriptive error messages** with error IDs
- **Validate data types** and dimensions
- **Handle warnings** appropriately using `warning` or `lastwarn`

---

## 🔧 **MATLAB-Specific Optimizations**

### **1. Matrix Operations**
```matlab
% ❌ SLOW - Element-wise multiplication
result = zeros(size(A));
for i = 1:size(A, 1)
    for j = 1:size(A, 2)
        result(i, j) = A(i, j) * B(i, j);
    end
end

% ✅ FAST - Element-wise multiplication
result = A .* B;

% ❌ SLOW - Matrix multiplication with loop
result = zeros(size(A, 1), size(B, 2));
for i = 1:size(A, 1)
    for j = 1:size(B, 2)
        for k = 1:size(A, 2)
            result(i, j) = result(i, j) + A(i, k) * B(k, j);
        end
    end
end

% ✅ FAST - Matrix multiplication
result = A * B;
```

### **2. Sparse Matrices**
```matlab
% Use sparse matrices for large, sparse data
% ❌ BAD - Dense matrix for sparse data
A = zeros(10000, 10000);
A(1, 1) = 1;
A(10000, 10000) = 1;

% ✅ GOOD - Sparse matrix
A = sparse(10000, 10000);
A(1, 1) = 1;
A(10000, 10000) = 1;
```

### **3. Function Handles and Anonymous Functions**
```matlab
% ✅ GOOD - Use function handles for repeated operations
f = @(x) sin(x) + cos(x);
result = f(x_values);

% ✅ GOOD - Vectorized anonymous functions
vectorized_f = @(x) sin(x) + cos(x);
result = vectorized_f(x_values);

% ❌ BAD - Repeated function calls in loops
for i = 1:length(x_values)
    result(i) = sin(x_values(i)) + cos(x_values(i));
end
```

---

## 📊 **Performance Monitoring**

### **1. Profiling Tools**
```matlab
% Profile your code to identify bottlenecks
profile on;
% ... your code here ...
profile off;
profile viewer;

% Use tic/toc for timing
tic;
% ... code to time ...
elapsed_time = toc;
fprintf('Execution time: %.4f seconds\n', elapsed_time);
```

### **2. Memory Monitoring**
```matlab
% Check memory usage
mem_info = memory;
fprintf('Memory used: %.2f MB\n', mem_info.MemUsedMATLAB / 1024^2);

% Monitor workspace variables
whos
```

---

## 🚫 **Common Anti-Patterns to Avoid**

### **1. Dynamic Array Growth**
```matlab
% ❌ NEVER DO THIS
result = [];
for i = 1:10000
    result = [result, i];  % Extremely slow!
end
```

### **2. Unnecessary Loops**
```matlab
% ❌ DON'T DO THIS
for i = 1:length(x)
    y(i) = x(i) * 2;
end

% ✅ DO THIS INSTEAD
y = x * 2;
```

### **3. Repeated Function Calls**
```matlab
% ❌ DON'T DO THIS
for i = 1:length(x)
    result(i) = sin(x(i));
end

% ✅ DO THIS INSTEAD
result = sin(x);
```

### **4. Ignoring Memory Layout**
```matlab
% ❌ DON'T DO THIS - Row-wise access
for i = 1:size(A, 1)
    for j = 1:size(A, 2)
        result(i, j) = A(i, j);
    end
end

% ✅ DO THIS INSTEAD - Column-wise access
for j = 1:size(A, 2)
    for i = 1:size(A, 1)
        result(i, j) = A(i, j);
    end
end
```

---

## 🎯 **Golf Model Specific Guidelines**

### **1. Kinematic Calculations**
```matlab
% ✅ OPTIMIZED - Vectorized kinematic calculations
function [positions, velocities] = calculateKinematics(time, angles, angular_velocities)
    % Preallocate output arrays
    n_timepoints = length(time);
    n_joints = size(angles, 2);
    
    positions = zeros(n_timepoints, n_joints, 3);  % 3D positions
    velocities = zeros(n_timepoints, n_joints, 3); % 3D velocities
    
    % Vectorized calculations
    for joint = 1:n_joints
        positions(:, joint, :) = calculateJointPosition(angles(:, joint), time);
        velocities(:, joint, :) = calculateJointVelocity(angular_velocities(:, joint), time);
    end
end
```

### **2. Force and Torque Calculations**
```matlab
% ✅ OPTIMIZED - Efficient force calculations
function forces = calculateForces(masses, accelerations, external_forces)
    % Use vectorized operations
    inertial_forces = masses .* accelerations;
    forces = inertial_forces + external_forces;
    
    % Ensure output is finite
    assert(all(isfinite(forces(:))), 'Forces contain non-finite values');
end
```

---

## 📋 **Code Review Checklist**

Before committing MATLAB code, ensure:

- [ ] **Arrays are preallocated** when size is known
- [ ] **Loops are vectorized** where possible
- [ ] **Memory layout is optimized** (column-major access)
- [ ] **Input validation** is implemented
- [ ] **Error handling** is in place
- [ ] **Functions are documented** with headers
- [ ] **Variable names are descriptive**
- [ ] **Performance is profiled** for critical functions
- [ ] **Memory usage is monitored**
- [ ] **Code follows vectorization best practices**

---

## 🔄 **Continuous Improvement**

### **1. Regular Performance Reviews**
- Profile critical functions monthly
- Monitor memory usage patterns
- Update rules based on new MATLAB versions
- Share optimization techniques with team

### **2. Code Quality Metrics**
- Track execution time improvements
- Monitor memory efficiency gains
- Document performance bottlenecks
- Maintain optimization knowledge base

---

## 📚 **Additional Resources**

- **MATLAB Performance Tips**: https://www.mathworks.com/help/matlab/matlab_prog/techniques-for-improving-performance.html
- **Memory Management**: https://www.mathworks.com/help/matlab/matlab_prog/resolving-out-of-memory-errors.html
- **Vectorization**: https://www.mathworks.com/help/matlab/matlab_prog/vectorization.html
- **Profiling**: https://www.mathworks.com/help/matlab/ref/profile.html

---

## 🎯 **Remember**

**Efficiency is not premature optimization - it's good engineering practice in MATLAB.**

These rules will help you write code that is:
- **Faster** - Optimized for MATLAB's strengths
- **More reliable** - Proper error handling and validation
- **Easier to maintain** - Clear structure and documentation
- **Memory efficient** - Proper allocation and management
- **Professional quality** - Following industry best practices

**Start with these rules today, and your MATLAB code will be significantly more efficient and maintainable!**
