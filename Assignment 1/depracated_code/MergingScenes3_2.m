
%files_to_take = 'pcd';
files_to_take = 'depth'; 
dir_to_search = 'Data/data';

if strcmp(files_to_take , 'depth')
    txtpattern = fullfile(dir_to_search, '*_depth.png');
    dinfo = dir(txtpattern);
elseif strcmp(files_to_take , 'pcd') || strcmp(files_to_take , 'normals')
    txtpattern = fullfile(dir_to_search, '*.pcd');
    dinfo = dir(txtpattern);
end
step_size =  2;
num_of_images = 98;
%reduce number of points to speedup process, take every points_reduction point
points_reduction = 10;
y=1;
RMS_List = [];


 
if strcmp(files_to_take , 'depth')
    target = PointCloud(imread(char(strcat("data/",dinfo(1).name))));
elseif strcmp(files_to_take , 'pcd') 
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
    end
    source = source(1:points_reduction:end,:);
    source = source';
    
    [R, t, RMS_new, ~] = ICP( datacloud,source, 'uniform',0.2);
    RMS_List = cat(1,RMS_List, RMS_new);
    

    moved = R*datacloud + repmat(t, [1, size(datacloud,2)]);
    datacloud = cat(2,datacloud,source);
    
end
%%

%plot everything
figure()
fscatter3(datacloud(1,:),datacloud(2,:), datacloud(3,:),datacloud(3,:));


