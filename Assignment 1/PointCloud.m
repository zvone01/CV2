function cloud = pointCloud(dataImage)

fx = 526.37013657; %focal length in width
fy = 526.37013657; %focal length in height
cx = 313.68782938; %principal point in width
cy = 259.01834898; %principal point in height

%file_path = 'depth.png'; %depth image path
%depth = imread(file_path); %load depth image
depth = double(dataImage) * 0.001; %scale depth image from mm to meter.
[cloud, ordered]= depth2cloud(depth, fx, fy,cx,cy); % convert from the depth image to cloud

indices = find(cloud >2);
cloud(indices) = NaN;  
cloud(any(any(isnan(cloud),3),2),:,:) = [];

end