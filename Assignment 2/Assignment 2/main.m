%run('/usr/local/MATLAB/vlfeat/toolbox/vl_setup')
%run('C:\Users\zdujmic\Documents\MATLAB\vlfeat\toolbox\vl_setup')

%points from images
%[PointViewMat Xs Ys] = get_pointview_mat('Data/House/House/');
%imshow(PointViewMat);

point_cloud = sparse_sfm(PointViewMat);
figure(1);
plot3(point_cloud(1, :), point_cloud(2,:), point_cloud(3,:),'k.');

%%
%points from PointViewMatrix.txt
pvm = importdata('PointViewMatrix.txt');
[m, s] = dense_sfm(pvm);
figure(2);
plot3(s(1, :), s(2,:), s(3,:),'k.');
%%
figure(1)
plot(Xs(20,:),Ys(20,:),'k.')
hold on;
plot(pvm(40,:),pvm(41,:),'b.')



function [motion, shape] = dense_sfm(PointViewMatrix)
% mean of each row
PointViewMatrix(1:2:end,:) = bsxfun(@minus, PointViewMatrix(1:2:end,:), mean(PointViewMatrix(1:2:end,:), 2));
PointViewMatrix(2:2:end,:) = bsxfun(@minus, PointViewMatrix(2:2:end,:), mean(PointViewMatrix(2:2:end,:), 2));

%compute svd
[U W V] = svd(PointViewMatrix);

% compute motion and shape
motion = U(:, 1:3)*sqrt(W(1:3, 1:3)); 
shape = sqrt(W(1:3, 1:3))*V(:, 1:3)';

end