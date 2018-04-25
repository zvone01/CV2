
files_to_take = 'pcd';
%files_to_take = 'depth'; 
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
points_reduction = 1;
y=1;
RMS_List = [];
if strcmp(files_to_take , 'pcd') || strcmp(files_to_take , 'normals')
   step_size =  step_size * 2;
   num_of_images = num_of_images *2;  
end
 

if strcmp(files_to_take , 'depth')
    target = PointCloud(imread(char(strcat("data/",dinfo(1).name))));
elseif strcmp(files_to_take , 'pcd')
   target = readPcd (strcat("data/",dinfo(1).name));
   indices = find(target > 1.5);
   target(indices) = NaN;
   target(any(any(isnan(target),3),2),:,:) = [];
elseif strcmp(files_to_take , 'normals')
   target = readPcd (strcat("data/",dinfo(1).name));
   target(any(any(isnan(target),3),2),:,:) = [];
end
target = target(1:points_reduction:end,:);
target = target';
datacloud = target;

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
    elseif strcmp(files_to_take , 'normals')
        dinfo(i+1).name
       source = readPcd (strcat("data/",dinfo(i+1).name));
       source(any(any(isnan(source),3),2),:,:) = [];
    end
    source = source(1:points_reduction:end,:);
    source = source';
    
    
    [R, t, RMS_new, ~] = ICP(source, target,'uniform',0.2);
    
    
    
        RMS_List = cat(1,RMS_List, RMS_new);
        moved = (R*source) + repmat(t, [1, size(source,2)]);
        %moved=bsxfun(@plus, R*target,  t);



        datacloud = cat(2,datacloud,moved);

        target = moved;
        stacked{y} = moved; 
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
 for j=1:2:97%size(stacked,2)
 fscatter3(stacked{j}(1,1:6:end),stacked{j}(2,1:6:end), stacked{j}(3,1:6:end),stacked{j}(2,1:6:end));
 end
