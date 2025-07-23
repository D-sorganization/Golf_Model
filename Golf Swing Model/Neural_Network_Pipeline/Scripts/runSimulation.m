function [simOut, success, error_msg] = runSimulation(model_name, config)
% runSimulation.m
% Runs a single simulation with error handling
% 
% Inputs:
%   model_name - Name of the Simulink model
%   config - Configuration structure with simulation settings
%
% Outputs:
%   simOut - Simulation output (empty if failed)
%   success - Boolean indicating if simulation was successful
%   error_msg - Error message if simulation failed

%% Default configuration
if nargin < 2
    config = struct();
end

if ~isfield(config, 'max_simulation_time')
    config.max_simulation_time = 10; % seconds (timeout)
end
if ~isfield(config, 'solver_type')
    config.solver_type = 'ode23t';
end
if ~isfield(config, 'relative_tolerance')
    config.relative_tolerance = 1e-3;
end
if ~isfield(config, 'absolute_tolerance')
    config.absolute_tolerance = 1e-5;
end

%% Default model name
if nargin < 1
    model_name = 'GolfSwing3D_Kinetic';
end

%% Check if model is loaded
if ~bdIsLoaded(model_name)
    try
        load_system(model_name);
    catch ME
        success = false;
        error_msg = sprintf('Failed to load model %s: %s', model_name, ME.message);
        simOut = [];
        return;
    end
end

%% Configure simulation parameters
try
    % Set solver parameters
    set_param(model_name, 'Solver', config.solver_type);
    set_param(model_name, 'RelTol', num2str(config.relative_tolerance));
    set_param(model_name, 'AbsTol', num2str(config.absolute_tolerance));
    
    % Enable Simscape logging
    set_param(model_name, 'SimscapeLogType', 'all');
    
    % Enable output saving for traditional logging
    set_param(model_name, 'SaveOutput', 'on');
    set_param(model_name, 'SaveFormat', 'Dataset');
    
    % Set simulation timeout
    set_param(model_name, 'SimulationCommand', 'start');
    
catch ME
    success = false;
    error_msg = sprintf('Failed to configure simulation: %s', ME.message);
    simOut = [];
    return;
end

%% Run simulation with timeout
try
    fprintf('Starting simulation...\n');
    
    % Start timer
    tic;
    
    % Run simulation
    simOut = sim(model_name);
    
    % Check simulation time
    sim_time = toc;
    if sim_time > config.max_simulation_time
        success = false;
        error_msg = sprintf('Simulation timed out after %.1f seconds', sim_time);
        simOut = [];
        return;
    end
    
    % Check if simulation completed successfully
    if isempty(simOut)
        success = false;
        error_msg = 'Simulation returned empty results';
        return;
    end
    
    % Check for traditional output (may not exist for Simscape models)
    if isfield(simOut, 'tout') && ~isempty(simOut.tout)
        fprintf('✓ Traditional output available\n');
    else
        fprintf('⚠ No traditional output (expected for Simscape models)\n');
    end
    
    % Check for simulation errors
    if isfield(simOut, 'ErrorMessage') && ~isempty(simOut.ErrorMessage)
        success = false;
        error_msg = simOut.ErrorMessage;
        return;
    end
    
    % Check if simulation ran for expected duration (if traditional output available)
    if isfield(simOut, 'tout') && ~isempty(simOut.tout)
        expected_duration = str2double(get_param(model_name, 'StopTime'));
        actual_duration = simOut.tout(end);
        
        if actual_duration < expected_duration * 0.8
            success = false;
            error_msg = sprintf('Simulation ended early: %.2f s (expected %.2f s)', ...
                               actual_duration, expected_duration);
            return;
        end
        
        % Check for excessive simulation time (safety check)
        if actual_duration > expected_duration * 1.5
            success = false;
            error_msg = sprintf('Simulation ran too long: %.2f s (expected %.2f s)', ...
                               actual_duration, expected_duration);
            return;
        end
    end
    
    fprintf('✓ Simulation completed successfully in %.2f seconds\n', sim_time);
    success = true;
    error_msg = '';
    
catch ME
    success = false;
    error_msg = sprintf('Simulation failed: %s', ME.message);
    simOut = [];
    return;
end

end 