%% The ICP algorithm 
load('Data/source.mat');
load('Data/target.mat');

scatter3(source(1,:), source(2,:), source(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

[R, t] = ICP(source, target);
moved = R*source + repmat(t, [1, size(source,2)]);

figure()    
scatter3(moved(1,:), moved(2,:), moved(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

%% Estimating Camera Pose