
%files_to_take = 'pcd';
files_to_take = 'depth'; 
dir_to_search = 'Data/data';

if strcmp(files_to_take , 'depth')
    txtpattern = fullfile(dir_to_search, '*_depth.png');
    dinfo = dir(txtpattern);
elseif strcmp(files_to_take , 'pcd')
    txtpattern = fullfile(dir_to_search, '*.pcd');
    dinfo = dir(txtpattern);
end
step_size =  1;
num_of_images = 30;

%reduce number of points to speedup process, take every points_reduction point
points_reduction = 10;
y=1;

for i=1:step_size: num_of_images 
    
    if strcmp(files_to_take , 'depth')
        source = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    elseif strcmp(files_to_take , 'pcd')
       source = readPcd (strcat("data/",dinfo(i).name));
       source(any(any(isnan(source),3),2),:,:) = [];
    end
    source = source(1:points_reduction:end,:);
    source = source';
    
    
    if strcmp(files_to_take , 'depth')
        target = PointCloud(imread(char(strcat("data/",dinfo(i+step_size).name))));
    elseif strcmp(files_to_take , 'pcd')
       target = readPcd (strcat("data/",dinfo(i+step_size).name));
       
       target(any(any(isnan(target),3),2),:,:) = [];
    end
    
    
    [R, t] = ICP(source, target,'all',0.5);
    
    moved = R*target + repmat(t, [1, size(target,2)]);

    
    
    if i == 1
     datacloud = source;
    end
    
    datacloud = cat(2,datacloud,moved);
    
    stacked{y} = moved; 
    y = y+1;
end

%%
%plot couple of pointclouds
figure()    
scatter3(stacked{1}(1,:), stacked{1}(2,:), stacked{1}(3,:), 'r.');
hold on
scatter3(stacked{2}(1,:), stacked{2}(2,:), stacked{2}(3,:), 'g.');
hold on
scatter3(stacked{20}(1,:), stacked{20}(2,:), stacked{20}(3,:), 'b.');
hold on
scatter3(stacked{25}(1,:), stacked{25}(2,:), stacked{25}(3,:), 'y.');
hold on
scatter3(stacked{40}(1,:), stacked{40}(2,:), stacked{40}(3,:), 'c.');
hold off

%plot everything
%figure()
%fscatter3(datacloud(1,:),datacloud(2,:), datacloud(3,:),datacloud(3,:));