run('/usr/local/MATLAB/vlfeat/toolbox/vl_setup')
%run('C:\Users\zdujmic\Documents\MATLAB\vlfeat\toolbox\vl_setup')

%points from images
[PointViewMat Xs Ys] = get_pointview_mat('Data/House/House/');
%imshow(PointViewMat);

[m, s] = sfm(PointViewMat);
figure(1);
plot3(point_cloud(1, :), point_cloud(2,:), point_cloud(3,:),'k.');

%%
%points from PointViewMatrix.txt
pvm = importdata('PointViewMatrix.txt');
[m, s] = sfm(pvm(1:3,:));
figure(2);
plot3(s(1, :), s(2,:), s(3,:),'k.');
%%
figure(1)
plot(Xs(20,:),Ys(20,:),'k.')
hold on;
plot(pvm(40,:),pvm(41,:),'b.')
