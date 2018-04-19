dir_to_search = 'Data/data';
txtpattern = fullfile(dir_to_search, '*.pcd');
dinfo = dir(txtpattern);

for i=1:2: size(dinfo)
    
    target = readPcd (strcat("data/",dinfo(i).name));
    target = target';
    target = target(1:3,:);
    
    source = readPcd (strcat("data/",dinfo(i + 2).name));
    source = source';
    source = source(1:3,:);
    
    
    [R, t] = ICP(source, target);
    
    moved = R*source + repmat(t, [1, size(source,2)]);
% 
%     figure()    
%     scatter3(moved(1,:), moved(2,:), moved(3,:), 'bo');
%     hold on
%     scatter3(target(1,:), target(2,:), target(3,:), 'ro');
%     hold off
    
    if i == 1
     datacloud = target;
    end
    
    datacloud = cat(2,datacloud,moved);
end

%% The ICP algorithm 
load('Data/source.mat');
load('Data/target.mat');

scatter3(source(1,:), source(2,:), source(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off

[R, t] = ICP(source, target, 'random', 0.1);
moved = R*source + repmat(t, [1, size(source,2)]);

figure()    
scatter3(moved(1,:), moved(2,:), moved(3,:), 'bo');
hold on
scatter3(target(1,:), target(2,:), target(3,:), 'ro');
hold off



%%

    