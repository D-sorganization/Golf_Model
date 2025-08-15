function robot = buildHeadNeckRigidBodyTree_withGeometry()
%BUILDHEADNECKRIGIDBODYTREE_WITHGEOMETRY Builds neck and head chain off the torso.
robot = rigidBodyTree('DataFormat','row','MaxNumBodies',10);

% --- torso ---
torso = rigidBody('torso');
torso_jnt = rigidBodyJoint('torso_jnt','fixed');
setFixedTransform(torso_jnt, trvec2tform([0 0 0]));
torso.Joint = torso_jnt;
addBody(robot, torso, 'base');
torso.Mass = 35;
torso.CenterOfMass = [0 0 0.275];
torso.Inertia = [1.6 2.0 1.0 0 0 0];
addVisual(torso, 'Cylinder', [0.15 0.55], trvec2tform([0 0 0.275]));

% --- neck_1 ---
neck_1 = rigidBody('neck_1');
neck_1_jnt = rigidBodyJoint('neck_1_jnt','revolute');
setFixedTransform(neck_1_jnt, trvec2tform([0 0 0.55]));
neck_1_jnt.JointAxis = [1 0 0];
neck_1.Joint = neck_1_jnt;
addBody(robot, neck_1, 'torso');
neck_1.Mass = 1.5;
neck_1.CenterOfMass = [0 0 0.06];
neck_1.Inertia = [0.01 0.015 0.005 0 0 0];
addVisual(neck_1, 'Cylinder', [0.05 0.12], trvec2tform([0 0 0.06]));

% --- neck_2 ---
neck_2 = rigidBody('neck_2');
neck_2_jnt = rigidBodyJoint('neck_2_jnt','revolute');
setFixedTransform(neck_2_jnt, trvec2tform([0 0 0]));
neck_2_jnt.JointAxis = [0 1 0];
neck_2.Joint = neck_2_jnt;
addBody(robot, neck_2, 'neck_1');
neck_2.Mass = 1.5;
neck_2.CenterOfMass = [0 0 0.06];
neck_2.Inertia = [0.01 0.015 0.005 0 0 0];
addVisual(neck_2, 'Cylinder', [0.05 0.12], trvec2tform([0 0 0.06]));

% --- head ---
head = rigidBody('head');
head_jnt = rigidBodyJoint('head_jnt','fixed');
setFixedTransform(head_jnt, trvec2tform([0 0 0.12]));
head.Joint = head_jnt;
addBody(robot, head, 'neck_2');
head.Mass = 5.0;
head.CenterOfMass = [0 0 0.12];
head.Inertia = [0.07 0.07 0.06 0 0 0];
addVisual(head, 'Cylinder', [0.09 0.24], trvec2tform([0 0 0.12]));

end
