function robot = buildRightChainRigidBodyTree_withGeometry()
%BUILDRIGHTCHAINRIGIDBODYTREE_WITHGEOMETRY Right chain with visuals and physical properties.
robot = rigidBodyTree('DataFormat','row','MaxNumBodies',20);

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

% --- scapula_R_1 ---
scapula_R_1 = rigidBody('scapula_R_1');
scapula_R_1_jnt = rigidBodyJoint('scapula_R_1_jnt','revolute');
setFixedTransform(scapula_R_1_jnt, trvec2tform([-0.15 0 0.2]));
scapula_R_1_jnt.JointAxis = [0 1 0];
scapula_R_1.Joint = scapula_R_1_jnt;
addBody(robot, scapula_R_1, 'torso');
scapula_R_1.Mass = 1.5;
scapula_R_1.CenterOfMass = [0 0 0.06];
scapula_R_1.Inertia = [0.01 0.012 0.005 0 0 0];
addVisual(scapula_R_1, 'Cylinder', [0.04 0.12], trvec2tform([0 0 0.06]));

% --- scapula_R_2 ---
scapula_R_2 = rigidBody('scapula_R_2');
scapula_R_2_jnt = rigidBodyJoint('scapula_R_2_jnt','revolute');
setFixedTransform(scapula_R_2_jnt, trvec2tform([0 0 0]));
scapula_R_2_jnt.JointAxis = [1 0 0];
scapula_R_2.Joint = scapula_R_2_jnt;
addBody(robot, scapula_R_2, 'scapula_R_1');
scapula_R_2.Mass = 1.5;
scapula_R_2.CenterOfMass = [0 0 0.06];
scapula_R_2.Inertia = [0.01 0.012 0.005 0 0 0];
addVisual(scapula_R_2, 'Cylinder', [0.04 0.12], trvec2tform([0 0 0.06]));

% --- shoulder_R_1 ---
shoulder_R_1 = rigidBody('shoulder_R_1');
shoulder_R_1_jnt = rigidBodyJoint('shoulder_R_1_jnt','revolute');
setFixedTransform(shoulder_R_1_jnt, trvec2tform([-0.05 0 0]));
shoulder_R_1_jnt.JointAxis = [1 0 0];
shoulder_R_1.Joint = shoulder_R_1_jnt;
addBody(robot, shoulder_R_1, 'scapula_R_2');
shoulder_R_1.Mass = 2.5;
shoulder_R_1.CenterOfMass = [0 0 0.15];
shoulder_R_1.Inertia = [0.02 0.03 0.01 0 0 0];
addVisual(shoulder_R_1, 'Cylinder', [0.05 0.3], trvec2tform([0 0 0.15]));

% --- shoulder_R_2 ---
shoulder_R_2 = rigidBody('shoulder_R_2');
shoulder_R_2_jnt = rigidBodyJoint('shoulder_R_2_jnt','revolute');
setFixedTransform(shoulder_R_2_jnt, trvec2tform([-0.05 0 0]));
shoulder_R_2_jnt.JointAxis = [0 1 0];
shoulder_R_2.Joint = shoulder_R_2_jnt;
addBody(robot, shoulder_R_2, 'shoulder_R_1');
shoulder_R_2.Mass = 2.5;
shoulder_R_2.CenterOfMass = [0 0 0.15];
shoulder_R_2.Inertia = [0.02 0.03 0.01 0 0 0];
addVisual(shoulder_R_2, 'Cylinder', [0.05 0.3], trvec2tform([0 0 0.15]));

% --- shoulder_R_3 ---
shoulder_R_3 = rigidBody('shoulder_R_3');
shoulder_R_3_jnt = rigidBodyJoint('shoulder_R_3_jnt','revolute');
setFixedTransform(shoulder_R_3_jnt, trvec2tform([-0.05 0 0]));
shoulder_R_3_jnt.JointAxis = [0 0 1];
shoulder_R_3.Joint = shoulder_R_3_jnt;
addBody(robot, shoulder_R_3, 'shoulder_R_2');
shoulder_R_3.Mass = 2.5;
shoulder_R_3.CenterOfMass = [0 0 0.15];
shoulder_R_3.Inertia = [0.02 0.03 0.01 0 0 0];
addVisual(shoulder_R_3, 'Cylinder', [0.05 0.3], trvec2tform([0 0 0.15]));

% --- elbow_R ---
elbow_R = rigidBody('elbow_R');
elbow_R_jnt = rigidBodyJoint('elbow_R_jnt','revolute');
setFixedTransform(elbow_R_jnt, trvec2tform([-0.25 0 0]));
elbow_R_jnt.JointAxis = [0 1 0];
elbow_R.Joint = elbow_R_jnt;
addBody(robot, elbow_R, 'shoulder_R_3');
elbow_R.Mass = 1.6;
elbow_R.CenterOfMass = [0 0 0.125];
elbow_R.Inertia = [0.015 0.02 0.008 0 0 0];
addVisual(elbow_R, 'Cylinder', [0.04 0.25], trvec2tform([0 0 0.125]));

% --- wrist_R_1 ---
wrist_R_1 = rigidBody('wrist_R_1');
wrist_R_1_jnt = rigidBodyJoint('wrist_R_1_jnt','revolute');
setFixedTransform(wrist_R_1_jnt, trvec2tform([-0.25 0 0]));
wrist_R_1_jnt.JointAxis = [1 0 0];
wrist_R_1.Joint = wrist_R_1_jnt;
addBody(robot, wrist_R_1, 'elbow_R');
wrist_R_1.Mass = 0.6;
wrist_R_1.CenterOfMass = [0 0 0.075];
wrist_R_1.Inertia = [0.005 0.006 0.003 0 0 0];
addVisual(wrist_R_1, 'Cylinder', [0.03 0.15], trvec2tform([0 0 0.075]));

% --- wrist_R_2 ---
wrist_R_2 = rigidBody('wrist_R_2');
wrist_R_2_jnt = rigidBodyJoint('wrist_R_2_jnt','revolute');
setFixedTransform(wrist_R_2_jnt, trvec2tform([0 0 0]));
wrist_R_2_jnt.JointAxis = [0 1 0];
wrist_R_2.Joint = wrist_R_2_jnt;
addBody(robot, wrist_R_2, 'wrist_R_1');
wrist_R_2.Mass = 0.6;
wrist_R_2.CenterOfMass = [0 0 0.075];
wrist_R_2.Inertia = [0.005 0.006 0.003 0 0 0];
addVisual(wrist_R_2, 'Cylinder', [0.03 0.15], trvec2tform([0 0 0.075]));

% --- rightHandOnClub ---
rightHandOnClub = rigidBody('rightHandOnClub');
rightHandOnClub_jnt = rigidBodyJoint('rightHandOnClub_jnt','fixed');
setFixedTransform(rightHandOnClub_jnt, trvec2tform([-0.1 0 -0.2]));
rightHandOnClub.Joint = rightHandOnClub_jnt;
addBody(robot, rightHandOnClub, 'wrist_R_2');
rightHandOnClub.Mass = 0.45;
rightHandOnClub.CenterOfMass = [0 0 0.5];
rightHandOnClub.Inertia = [0.03 0.02 0.001 0 0 0];
addVisual(rightHandOnClub, 'Cylinder', [0.015 1.0], trvec2tform([0 0 0.5]));

end
