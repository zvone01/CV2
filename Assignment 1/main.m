%% The ICP algorithm on toy data
load('Data/source.mat');
load('Data/target.mat');

scatter3(source(1,:), source(2,:), source(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

[R, t, ~, ~]  = ICP(source, target); %, 'random', .1 );
moved = R*source + repmat(t, [1, size(source,2)]);

figure()
scatter3(moved(1,:), moved(2,:), moved(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

%% Testing optimised ICP
% it is advised not to run this function, because it takes a long time,
% and the results are available in the report
% testing_optimised_ICP()

%% Constructing a 3D model

% merging method according to assingment
cloud31 = merge_scenes("all_frames", "consecutive", "points");
cloud32a = merge_scenes("every_other_frame", "all_previous", "points");
cloud32b = merge_scenes("all_frames", "all_previous", "points");
% experimental method for slightly better alignment
cloud = merge_scenes("all_frames", "consecutive", "normals");

% show the 3D model
%show_cloud(cloud31, 50000);
%show_cloud(cloud32a, 50000);
%show_cloud(cloud32b, 50000);
show_cloud(cloud, 50000);
