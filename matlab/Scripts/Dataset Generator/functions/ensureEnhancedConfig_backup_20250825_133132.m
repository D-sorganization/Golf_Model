function config = ensureEnhancedConfig(config)
% Ensure config has enhanced settings for maximum data extraction (1956 columns)
% This function sets default values for data extraction options if they're missing

% Set default data extraction options for maximum column count
if ~isfield(config, 'use_signal_bus')
    config.use_signal_bus = true;  % Enable CombinedSignalBus extraction
    fprintf('Debug: Set use_signal_bus = true for enhanced extraction\n');
end

if ~isfield(config, 'use_logsout')
    config.use_logsout = true;     % Enable logsout extraction
    fprintf('Debug: Set use_logsout = true for enhanced extraction\n');
end

if ~isfield(config, 'use_simscape')
    config.use_simscape = true;    % Enable simscape extraction
    fprintf('Debug: Set use_simscape = true for enhanced extraction\n');
end

% Ensure verbose logging is enabled for debugging
if ~isfield(config, 'verbose')
    config.verbose = true;
    fprintf('Debug: Set verbose = true for enhanced extraction debugging\n');
end

% Set other important defaults for 1956 column extraction
if ~isfield(config, 'capture_workspace')
    config.capture_workspace = true;  % Capture model workspace variables
    fprintf('Debug: Set capture_workspace = true for enhanced extraction\n');
end

% Note: Master dataset compilation is not required for 1956 columns per trial
% Each individual trial should achieve 1956 columns through enhanced extraction

fprintf('Debug: Enhanced config ready for 1956 column extraction\n');
fprintf('Debug: Data sources enabled: CombinedSignalBus=%d, logsout=%d, simscape=%d\n', ...
    config.use_signal_bus, config.use_logsout, config.use_simscape);
end
