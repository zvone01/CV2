function datacloud = merge_scenes(use, sample_from, sample_by)
% prepare variables
dir_to_search = 'Data/data';
txtpattern = fullfile(dir_to_search, '*_depth.png');
dinfo = dir(txtpattern);
n_images = 98;
p = .2;

disp(["sampling from "+use])
disp(["per iteration using "+sample_from+" frames"])
disp(["sampling by "+sample_by])

% decide which frames to use
if strcmp(use, "all_frames")
    idc = 1 : n_images - 1 ;
elseif strcmp(use, "every_other_frame")
    idc = 1 : 2 : n_images ;
end

% load every pair
% find the transformation to the new frame
% apply it the datacloud (all previous frames)
for i = 1 : size(idc, 2) - 1
    disp(["processing "+num2str(i)+"th of "+num2str(size(idc, 2))+" images..."])
    
    % load the data
    current = PointCloud(imread(char(strcat("data/",dinfo(idc(i)).name))))';
    target = PointCloud(imread(char(strcat("data/",dinfo(idc(i+1)).name))))'; % next frame
    
    % add the current frame to the collection of all previous frames
    if i == 1
        datacloud = current;
    else
        datacloud = cat(2, datacloud, current);
    end
    
    % decide where to sample from
    if strcmp(sample_from, "consecutive")
        source = current;
    elseif strcmp(sample_from, "all_previous")
        source = datacloud;
    end
    
    % find transformation to the target cloud
    % either use only the most recent frame (3.1)
    % or all previous frames (3.2)
    if strcmp(sample_by, "normals")
        pc_source = pointCloud( source' );
        pc_target = pointCloud( target' );
        source_normals = pcnormals(pc_source, 4)'; 
        target_normals = pcnormals(pc_target, 4)';
        [R, t, ~, ~] = ICP( source, target , "uniform", p, "normals", source_normals, target_normals, 10);
    elseif strcmp(sample_by, "points")
        [R, t, ~, ~] = ICP( source, target , 'uniform', p);
    end

    datacloud = (R*datacloud) + repmat(t, [1, size(datacloud,2)]);  
end
end