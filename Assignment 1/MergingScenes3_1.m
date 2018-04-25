
files_to_take = 'pcd';
%files_to_take = 'depth'; 
dir_to_search = 'Data/data';

if strcmp(files_to_take , 'depth')
    txtpattern = fullfile(dir_to_search, '*_depth.png');
    dinfo = dir(txtpattern);
elseif strcmp(files_to_take , 'pcd') 
    txtpattern = fullfile(dir_to_search, '*.pcd');
    dinfo = dir(txtpattern);
end
step_size =  2;
num_of_images = 98;


%reduce number of points to speedup process, take every points_reduction point
points_reduction = 5;
y=1;

if strcmp(files_to_take , 'pcd') || strcmp(files_to_take , 'normals')
   step_size =  step_size * 2;
   num_of_images = num_of_images *2;  
 end
for i=1:step_size: num_of_images 
    if strcmp(files_to_take , 'depth')
        source = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    elseif strcmp(files_to_take , 'pcd')
       source = readPcd (strcat("data/",dinfo(i).name));
       indices = find(source > 1.5);
       source(indices) = NaN;  
       source(any(any(isnan(source),3),2),:,:) = [];
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
    end
    target = target(1:points_reduction:end,:);
    target = target';
    
    [R, t, ~, ~] = ICP(source, target,'uniform',0.2);
    
    
    moved = (R*source) + repmat(t, [1, size(source,2)]);
    %moved=bsxfun(@plus, R*target,  t);
  
    if i == 1
     datacloud = target;
    end
    
    datacloud = cat(2,datacloud,moved);
    
    stacked{y} = moved; 
    y = y+1;
end

 test =  datacloud;%(:,1:10:end);
%plot everything
figure()
fscatter3(test(1,:),test(2,:), test(3,:),test(3,:));

