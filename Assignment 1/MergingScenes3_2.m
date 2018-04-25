
%files_to_take = 'pcd';
files_to_take = 'depth'; 
%files_to_take = 'normals'; 
dir_to_search = 'Data/data';

if strcmp(files_to_take , 'depth')
    txtpattern = fullfile(dir_to_search, '*_depth.png');
    dinfo = dir(txtpattern);
elseif strcmp(files_to_take , 'pcd') || strcmp(files_to_take , 'normals')
    txtpattern = fullfile(dir_to_search, '*.pcd');
    dinfo = dir(txtpattern);
end
step_size =  1;
num_of_images = 98;
%reduce number of points to speedup process, take every points_reduction point
points_reduction = 10;
y=1;
RMS_List = [];

if strcmp(files_to_take , 'pcd') || strcmp(files_to_take , 'normals')
   step_size =  step_size * 2;
   num_of_images = num_of_images *2;  
end
 
if strcmp(files_to_take , 'depth')
    target = PointCloud(imread(char(strcat("data/",dinfo(1).name))));
elseif strcmp(files_to_take , 'pcd') || strcmp(files_to_take , 'normals')
   target = readPcd (strcat("data/",dinfo(1).name));
   indices = find(target > 1.5);
   target(indices) = NaN;
   target(any(any(isnan(target),3),2),:,:) = [];
   target = target(:,1:3);
end
target = target(1:points_reduction:end,:);
target = target';
datacloud = target;


for i=1:step_size: num_of_images  % size(dinfo)
    
    if strcmp(files_to_take , 'depth')
        source = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    elseif strcmp(files_to_take , 'pcd')
        if i==1
            continue;
        end
        dinfo(i).name
       source = readPcd (strcat("data/",dinfo(i).name));
       indices = find(source > 1.5);
       source(indices) = NaN;  
       source(any(any(isnan(source),3),2),:,:) = [];
       source = source(:,1:3);
    elseif strcmp(files_to_take , 'normals')
        dinfo(i+1).name
       source = readPcd (strcat("data/",dinfo(i+1).name));
       source(any(any(isnan(source),3),2),:,:) = [];
    end
    source = source(1:points_reduction:end,:);
    source = source';
    
    [R, t, RMS_new, ~] = ICP( datacloud,source, 'uniform',0.2);
    RMS_List = cat(1,RMS_List, RMS_new);
    
    if strcmp(files_to_take , 'normals')
        dinfo(i+step_size).name
       source = readPcd (strcat("data/",dinfo(i+step_size).name));
       indices = find(source > 1.5);
       source(indices) = NaN;
       source(any(any(isnan(source),3),2),:,:) = [];
       source = source(1:points_reduction:end,:);
       source = source';
    end
    
    moved = R*datacloud + repmat(t, [1, size(datacloud,2)]);
    datacloud = cat(2,datacloud,moved);
    
end
%%

%plot everything
figure()
fscatter3(datacloud(1,:),datacloud(2,:), datacloud(3,:),datacloud(3,:));

%%
%%
i1 = 2;
i2 = 3;
i3 = 50;
i4 = 20;
i5 =21;
%plot couple of pointclouds
figure()    
scatter3(stacked{i1}(1,:), stacked{i1}(2,:), stacked{i1}(3,:), 'r.');
hold on
scatter3(stacked{i2}(1,:), stacked{i2}(2,:), stacked{i2}(3,:), 'g.');
hold on
scatter3(stacked{i3}(1,:), stacked{i3}(2,:), stacked{i3}(3,:), 'b.');
hold on
scatter3(stacked{i4}(1,:), stacked{i4}(2,:), stacked{i4}(3,:), 'y.');
hold on
scatter3(stacked{i5}(1,:), stacked{i5}(2,:), stacked{i5}(3,:), 'c.');
hold off
