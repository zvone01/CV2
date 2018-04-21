%% The ICP algorithm 
load('Data/source.mat');
load('Data/target.mat');

scatter3(source(1,:), source(2,:), source(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

[R, t] = ICP(source, target, 'random', .1 );
moved = R*source + repmat(t, [1, size(source,2)]);

figure()    
scatter3(moved(1,:), moved(2,:), moved(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

%% Testing sampling by normals

load("Data/data_mat1/data_mat1/0000000000.mat")
load("Data/data_mat1/data_mat1/0000000000_normal.mat")
p1 = points';
n1 = normal';
load("Data/data_mat1/data_mat1/0000000001.mat")
load("Data/data_mat1/data_mat1/0000000001_normal.mat")
p2 = points';
n2 = normal';

% so far sampling by normals works only for uniform, not for random
[R, t] = ICP(p1, p2, 'random', .8, 'normals', n1, n2, 6);

%% Estimating Camera Pose

