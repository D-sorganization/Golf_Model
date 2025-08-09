function exportClubPath(leftTree)
%EXPORTCLUBPATH Sweeps torso rotation and exports club path.

pts = [];
qL = zeros(1, leftTree.NumBodies);

for i = 1:20
    qL(3) = pi/40 * i;
    T = getTransform(leftTree, qL, 'club');
    pts(end+1,:) = tform2trvec(T);
end

T = array2table(pts, 'VariableNames', {'X','Y','Z'});
writetable(T, 'club_path.csv');

disp('Exported club_path.csv');
end
