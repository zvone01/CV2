%%
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
RMS_List = [];
Transformation_List = [];

%reduce number of points to speedup process, take every points_reduction point
points_reduction = 10;
y=1;


if strcmp(files_to_take , 'pcd') 
   step_size =  step_size * 2;
   num_of_images = num_of_images *2;  
 end
for i=1:step_size: num_of_images
    if strcmp(files_to_take , 'depth')
        source = PointCloud(imread(char(strcat("data/",dinfo(i+step_size).name))));
    elseif strcmp(files_to_take , 'pcd')
       source = readPcd (strcat("data/",dinfo(i+step_size).name));
       indices = find(source > 1.5);
       source(indices) = NaN;  
       source(any(any(isnan(source),3),2),:,:) = [];
    elseif strcmp(files_to_take , 'normals')
        dinfo(i+1).name
       source = readPcd (strcat("data/",dinfo(i+step_size+1).name));
       source(any(any(isnan(source),3),2),:,:) = [];
    end
    source = source(1:points_reduction:end,:);
    source = source';
    if i == 1
       stacked{y} = source;
       y = y+1;
    end

    if strcmp(files_to_take , 'depth')
        target = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    elseif strcmp(files_to_take , 'pcd')
       target = readPcd (strcat("data/",dinfo(i).name));
       indices = find(target > 1.5);
       target(indices) = NaN;
       target(any(any(isnan(target),3),2),:,:) = [];
    end
    target = target(1:points_reduction:end,:);
    target = target';
    
    [R, t, RMS_new, ~] = ICP(source, target,'uniform',0.2);
    RMS_List = cat(1,RMS_List, RMS_new);
    
    Transformation_List{y-1}{1} = R;
    Transformation_List{y-1}{2} = t;
    

    stacked{y} = source;
    y = y+1;
end

%%

datacloud =stacked{1};
for j=2:size(stacked,2)
    image = stacked{j};
    for x=j-1:-1:1
        image = ( Transformation_List{x}{1}*image) + repmat( Transformation_List{x}{2}, [1, size(image,2)]);
    end
    datacloud = cat(2,datacloud,image);
end
fscatter3(datacloud(1:1000:end,:),datacloud(2:1000:end,:), datacloud(3:1000:end,:),datacloud(3:100:end,:));
