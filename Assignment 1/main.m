dir_to_search = 'Data/data';
txtpattern = fullfile(dir_to_search, '*_depth.png');
dinfo = dir(txtpattern);


%%
%3.1
for i=1: 10% size(dinfo)

    target = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    %target = readPcd (strcat("data/",dinfo(i).name));
    target = target(1:10:end,:);
    target = target';

   % source = readPcd (strcat("data/",dinfo(i + 1).name));
    source = PointCloud(imread(char(strcat("data/",dinfo(i+1).name))));
    source = source(1:10:end,:);
    source = source';


    [R, t] = ICP(source, target,'all',0.5);

    moved = R*source + repmat(t, [1, size(source,2)]);


    if i == 1
     datacloud = target;
    end

    datacloud = cat(2,datacloud,moved);

    stacked{i} = moved;
end

%% 3.1 b
step_size =  4;
for i=1:step_size: 80  % size(dinfo)

    target = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    %target = readPcd (strcat("data/",dinfo(i).name));
    target = target(1:10:end,:);
    target = target';

   % source = readPcd (strcat("data/",dinfo(i + 1).name));
    source = PointCloud(imread(char(strcat("data/",dinfo(i+step_size).name))));
    source = source(1:10:end,:);
    source = source';


    [R, t] = ICP(source, target,'all',0.5);
    moved = R*source + repmat(t, [1, size(source,2)]);


    if i == 1
     datacloud = target;
    end

    datacloud = cat(2,datacloud,moved);

    stacked{i} = moved;
end


figure()
scatter3(stacked{1}(1,:), stacked{1}(2,:), stacked{1}(3,:), 'r.');
hold on
scatter3(stacked{2}(1,:), stacked{2}(2,:), stacked{2}(3,:), 'g.');
hold on
scatter3(stacked{30}(1,:), stacked{30}(2,:), stacked{30}(3,:), 'b.');
hold on
scatter3(stacked{50}(1,:), stacked{50}(2,:), stacked{50}(3,:), 'y.');
hold on
scatter3(stacked{80}(1,:), stacked{80}(2,:), stacked{80}(3,:), 'c.');
hold off




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

% sampling by normals works, but for random sampling it is infeasibly slow
[R, t] = ICP(p1, p2, 'random', .8, 'normals', n1, n2, 6);

%% Estimating Camera Pose
