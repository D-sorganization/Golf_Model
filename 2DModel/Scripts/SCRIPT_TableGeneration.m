function Data = SCRIPT_TableGeneration(out)
%SCRIPT_TABLEGENERATION Generate a table from simulation output.
%
% Inputs:
%   out - Simulation output structure with tout and logsout
%
% Returns:
%   Data - Table containing all logged signals and derived vectors
%
% This function converts the Simulink simulation output into a MATLAB table
% and generates additional vector components used for plotting.

    % Generate time column
    Time = out.tout;
    Data = table(Time, 'VariableNames', {'Time'});

    % Loop through each dataset element to add it to the table
    for i = 1:out.logsout.numElements
        signalName = out.logsout.getElement(i).Name;
        signalData = out.logsout.getElement(i).Values.Data;
        Data.(signalName) = signalData;
    end

    % Generate shaft and grip vector components for quiver plot use
    GripScale = 1.5;  % Size up grip vector for graphics
    Data.Gripdx = GripScale .* (Data.RWx - Data.Buttx);
    Data.Gripdy = GripScale .* (Data.RWy - Data.Butty);
    Data.Gripdz = GripScale .* (Data.RWz - Data.Buttz);

    % Shaft vector
    Data.Shaftdx = Data.CHx - Data.RWx;
    Data.Shaftdy = Data.CHy - Data.RWy;
    Data.Shaftdz = Data.CHz - Data.RWz;

    % Left forearm vector
    Data.LeftForearmdx = Data.LWx - Data.LEx;
    Data.LeftForearmdy = Data.LWy - Data.LEy;
    Data.LeftForearmdz = Data.LWz - Data.LEz;

    % Right forearm vector
    Data.RightForearmdx = Data.RWx - Data.REx;
    Data.RightForearmdy = Data.RWy - Data.REy;
    Data.RightForearmdz = Data.RWz - Data.REz;

    % Left upper arm vector
    Data.LeftArmdx = Data.LEx - Data.LSx;
    Data.LeftArmdy = Data.LEy - Data.LSy;
    Data.LeftArmdz = Data.LEz - Data.LSz;

    % Right upper arm vector
    Data.RightArmdx = Data.REx - Data.RSx;
    Data.RightArmdy = Data.REy - Data.RSy;
    Data.RightArmdz = Data.REz - Data.RSz;

    % Left shoulder vector
    Data.LeftShoulderdx = Data.LSx - Data.HUBx;
    Data.LeftShoulderdy = Data.LSy - Data.HUBy;
    Data.LeftShoulderdz = Data.LSz - Data.HUBz;

    % Right shoulder vector
    Data.RightShoulderdx = Data.RSx - Data.HUBx;
    Data.RightShoulderdy = Data.RSy - Data.HUBy;
    Data.RightShoulderdz = Data.RSz - Data.HUBz;
end
