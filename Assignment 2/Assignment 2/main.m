run('/usr/local/MATLAB/vlfeat/toolbox/vl_setup')
% run('C:\Users\zdujmic\Documents\MATLAB\vlfeat\toolbox\vl_setup')
im1 = im2single(imread('Data/House/House/frame00000001.png'));
im2 = im2single(imread('Data/House/House/frame00000002.png'));

%F = get_fundamental_mat(im1, im2, 'show');
F = get_fundamental_mat(im1, im2, 'norm', 'show');
%[F,c] = get_fundamental_mat(im1, im2, 'norm', 'show', 'ransac');

%points from images
[PointViewMat Xs Ys] = get_pointview_mat('Data/House/House/');

[m, s] = sfm([Xs Ys]);
figure(1);
plot3(s(1, :), s(2,:), s(3,:),'k.');

%%
%points from PointViewMatrix.txt
pvm =importdata('PointViewMatrix.txt');
[m, s] = sfm(pvm);
figure(2);
plot3(s(1, :), s(2,:), s(3,:),'k.');
%%
figure(1)
plot(Xs(20,:),Ys(20,:),'k.')
hold on;
plot(pvm(40,:),pvm(41,:),'b.')
