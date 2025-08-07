function config = loadSwingConfig()
%LOADSWINGCONFIG Default visualization configuration for GolfSwingVisualizer.
%   Returns a struct with color, size, label and playback settings.

    config = struct();
    % --- Colors ---
    config.Colors.Skin = [0.9, 0.75, 0.65];
    config.Colors.Shirt = [0.2, 0.4, 0.8];
    config.Colors.Shaft = [0 0 0];
    config.Colors.Clubhead = [0.6 0.6 0.6];
    config.Colors.FaceNormal = [0 1 0];
    config.Colors.Ground = [0.4, 0.6, 0.2];
    config.Colors.Ball = [1 1 1];
    config.Colors.FigureBackground = [0.9, 1, 0.9];
    config.Colors.AxesBackground = [1, 1, 0.8];
    config.Colors.PanelBackground = [0.8, 1, 0.8];
    config.Colors.TextBackground = [1 1 1];
    config.Colors.RecordIdle = [1.0 0.6 0.0];
    config.Colors.RecordActive = [1.0 0.4 0.4];
    config.Colors.PlayButton = [0.4 0.8 0.4];
    config.Colors.Force = {[1 0 0], [0 0 1], [0 0.5 0]};
    config.Colors.Torque = {[0.5 0 0.5], [0 0.5 0.5], [1 0.5 0]};
    config.Colors.LegendText = config.Colors.Force;
    config.Colors.LegendText(4:6) = config.Colors.Torque;

    % --- Sizes ---
    inches_to_meters = 0.0254;
    config.Sizes.ClubheadLength = 4.5 * inches_to_meters;
    config.Sizes.ClubheadWidth = 3.5 * inches_to_meters;
    config.Sizes.ShaftDiameter = 0.5 * inches_to_meters;
    config.Sizes.ForearmDiameter = 2.8 * inches_to_meters;
    config.Sizes.UpperarmDiameter = 3.5 * inches_to_meters;
    config.Sizes.ShoulderNeckDiameter = 4.5 * inches_to_meters;
    config.Sizes.BallDiameter = 1.68 * inches_to_meters;
    config.Sizes.PlotMargin = 0.3;
    config.Sizes.GroundPlaneZ = -0.6;
    config.Sizes.VelocityEps = 1e-4;
    config.Sizes.ParallelEps = 1e-4;

    % --- Labels & Text ---
    config.Font.Size = 10; config.Font.SizeSmall = 9;
    config.Labels.FigureName = 'Golf Swing Visualizer';
    config.Labels.CheckboxPanelTitle = 'Segments and Vectors';
    config.Labels.PlaybackPanelTitle = 'Playback and Scaling';
    config.Labels.ZoomPanelTitle = 'Zoom';
    config.Labels.LegendPanelTitle = 'Legend';
    config.Labels.Checkboxes = {'Force BASE', 'Force ZTCF', 'Force DELTA', 'Torque BASE', 'Torque ZTCF', 'Torque DELTA', 'Shaft & Club', 'Face Normal', 'Left Forearm', 'Left Upper Arm', 'Left Shoulder-Neck', 'Right Forearm', 'Right Upper Arm', 'Right Shoulder-Neck'};
    config.Labels.LegendEntries = {'BASE (Force)', 'ZTCF (Force)', 'DELTA (Force)', 'BASE (Torque)', 'ZTCF (Torque)', 'DELTA (Torque)'};
    config.CheckboxMapping = struct('Force_BASE', 1, 'Force_ZTCF', 2, 'Force_DELTA', 3, 'Torque_BASE', 4, 'Torque_ZTCF', 5, 'Torque_DELTA', 6, 'Shaft_Club', 7, 'Face_Normal', 8, 'Left_Forearm', 9, 'Left_Upper_Arm', 10, 'Left_Shoulder_Neck', 11, 'Right_Forearm', 12, 'Right_Upper_Arm', 13, 'Right_Shoulder_Neck', 14);

    % --- Playback, Scaling, Zoom, Recording Config ---
    config.Playback.TimerPeriod = 0.033;
    config.Playback.MinSpeed = 0.1; config.Playback.MaxSpeed = 3.0; config.Playback.DefaultSpeed = 1.0;
    config.Scaling.MinVectorScale = 0.1; config.Scaling.MaxVectorScale = 9.0; config.Scaling.DefaultVectorScale = 1.0;
    config.Zoom.MinFactor = 0.1; config.Zoom.MaxFactor = 5.0; config.Zoom.DefaultFactor = 1.0;
    config.Recording.FrameRate = 30;
    config.Recording.DefaultFileName = 'golf_swing_recording.mp4';
    config.Recording.FileType = '*.mp4';
    config.Recording.FileDescription = 'Save Swing Recording As...';
end
