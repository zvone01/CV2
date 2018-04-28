
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
num_of_images = 99;

%reduce number of points to speedup process, take every points_reduction point
points_reduction = 1;
y=1;
i= 1;
  if strcmp(files_to_take , 'depth')
        source = PointCloud(imread(char(strcat("data/",dinfo(i).name))));
    elseif strcmp(files_to_take , 'pcd')
       source = readPcd (strcat("data/",dinfo(i).name));
       source(any(any(isnan(source),3),2),:,:) = [];
    end
    source = source(1:points_reduction:end,:);
    %source = source';
    
    if i == 1
     datacloud = source;
    end
    
    if strcmp(files_to_take , 'depth')
        target = PointCloud(imread(char(strcat("data/",dinfo(i+step_size).name))));
    elseif strcmp(files_to_take , 'pcd')
       target = readPcd (strcat("data/",dinfo(i+step_size).name));
       
       target(any(any(isnan(target),3),2),:,:) = [];
    end
    
    target = target(1:points_reduction:end,:);
    %target = target';



% Contruct an object of class globalICP (=initialization)
icp = globalICP;

% Add point clouds to object from plain text files
% (Added point clouds are saved as mat files, e.g. LionScan1Approx.mat)
icp.addPC(source);
icp.addPC(target);
% Plot all point clouds BEFORE ICP (each in a different random color)
icp.plot('Color', 'by PC');
title('BEFORE ICP', 'Color', 'w'); view(0,0); set(gcf, 'Name', 'BEFORE ICP');


ICPOptions.MaxNoIt                  = 20;
% ICPOptions.IdxFixedPointClouds      = ;
% ICPOptions.NoOfTransfParam          = ;
ICPOptions.HullVoxelSize            = 0.25;
ICPOptions.UniformSamplingDistance  = 0.1;
ICPOptions.PlaneSearchRadius        = 0.2;
% ICPOptions.WeightByRoughness        = ;
% ICPOptions.WeightByDeltaAngle       = ;
ICPOptions.MaxDeltaAngle            = 10;
ICPOptions.MaxDistance              = 1;
ICPOptions.MaxSigmaMad              = Inf;
ICPOptions.MaxRoughness             = 0.1;
% ICPOptions.LogLevel                 = ;
ICPOptions.Plot                     = true;
% ICPOptions.SubsetRadius             = ;
% Undocumented parameters
% ICPOptions.PairList                 = ;
% ICPOptions.RandomSubsampling        = ;
% ICPOptions.NormalSubsampling        = ;
% ICPOptions.MaxLeverageSubsampling   = ;
% ICPOptions.SubsamplingPercentPoi    = ;
% ICPOptions.AdjOptions               = ;
% ICPOptions.MinNoIntersectingVoxel   = ;
% ICPOptions.TrafoOriginalPointClouds = ;
% ICPOptions.StopConditionNormdx      = ;

icp.runICP(ICPOptions);

% Plot all point clouds AFTER ICP
icp.plot('Color', 'by PC');
title('AFTER ICP', 'Color', 'w'); view(0,0); set(gcf, 'Name', 'AFTER ICP');