function aligned = convertMocapToSimulinkFrame(mocap)
% Converts mocap pose data to match Simulink global frame
% Inputs:
%   mocap.Position   [T×3]
%   mocap.Rotation   [3×3×T]
% Output:
%   aligned.MH       [T×3] midhands position
%   aligned.MH_R     [3×3×T] rotation matrices in Simulink frame

    T = size(mocap.Position, 1);

    % Define static transformation (example: MoCap Z-up → Simulink Z-up)
    T_rot = [1 0 0;
             0 0 1;
             0 -1 0];  % adjust based on your systems

    aligned.MH    = (T_rot * mocap.Position')';  % apply to each row
    aligned.MH_R  = zeros(3,3,T);

    for t = 1:T
        aligned.MH_R(:,:,t) = T_rot * mocap.Rotation(:,:,t);
    end

    aligned.Time = mocap.Time;
end
