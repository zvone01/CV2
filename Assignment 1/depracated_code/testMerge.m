
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
num_of_images = 98;
%reduce number of points to speedup process, take every points_reduction point
points_reduction = 1;
y=1;

if strcmp(files_to_take , 'pcd')
   step_size =  step_size * 2;
   num_of_images = num_of_images *2;  
end
 

if strcmp(files_to_take , 'depth')
    target = PointCloud(imread(char(strcat("data/",dinfo(2).name))));
elseif strcmp(files_to_take , 'pcd')
   target = readPcd (strcat("data/",dinfo(2).name));
   indices = find(target > 1.5);
   target(indices) = NaN;
   target(any(any(isnan(target),3),2),:,:) = [];
   target = target(:,1:3);
end
target = target(1:points_reduction:end,:);
target = target';
datacloud = target;
stacked{y} = target;
y = y+1;

for i=1:step_size: num_of_images 
    i
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
    
    if strcmp(files_to_take , 'depth')
        target = PointCloud(imread(char(strcat("data/",dinfo(i+step_size).name))));
    elseif strcmp(files_to_take , 'pcd')
       target = readPcd (strcat("data/",dinfo(i+step_size).name));
       indices = find(target > 1.5);
       target(indices) = NaN;
       target(any(any(isnan(target),3),2),:,:) = [];
       target = target(:,1:3);
    end
    target = target(1:points_reduction:end,:);
    target = target';
    
    [R, t, RMS_new, ~] = ICP(source, target,'uniform',0.2);
    RMS_List = cat(1, RMS_new);
    
    for j=1: size(stacked,2)
     stacked{j} = (R*stacked{j}) + repmat(t, [1, size(stacked{j},2)]);
    end
    
    %datacloud = cat(2,datacloud,moved);
     
    stacked{y} = target;
    y = y+1;
    y
end


 %%
 
 test =  datacloud;%(:,1:10:end);
%plot everything
figure()
fscatter3(test(1,:),test(2,:), test(3,:),test(3,:));
%%
 figure()    
 scatter3(moved(1,:), moved(2,:), moved(3,:), 'r.');
 hold on
 scatter3(target(1,:), target(2,:), target(3,:), 'g.');
  hold on
 scatter3(source(1,:), source(2,:), source(3,:), 'b.');
 
 figure()    
 scatter3(target(1,:), target(2,:), target(3,:), 'g.');
  hold on
 scatter3(source(1,:), source(2,:), source(3,:), 'b.');
 %%
 for j=1:size(stacked,2)
 fscatter3(stacked{j}(1,1:20:end),stacked{j}(2,1:20:end), stacked{j}(3,1:20:end),stacked{j}(2,1:6:end));
 end
