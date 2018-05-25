%% set up the environment
run('/usr/local/MATLAB/vlfeat/toolbox/vl_setup')
% run('C:\Users\zdujmic\Documents\MATLAB\vlfeat\toolbox\vl_setup')

%% Fundamental Matrix and Eight-Point algorithm
im1 = im2single(imread('Data/House/House/frame00000001.png'));
im2 = im2single(imread('Data/House/House/frame00000002.png'));

F = get_fundamental_mat(im1, im2, 4, 'show');
F = get_fundamental_mat(im1, im2, 4, 'norm', 'show');
F = get_fundamental_mat(im1, im2, 4, 'norm', 'show', 'ransac');

 %% construct the pointview matrix from the frames using SIFT
% unoptimised sfm
disp(['unoptimised sfm'])
pvm_sparse = get_pointview_mat('Data/House/House/', 4);
test(pvm_sparse);

% sfm on pre-computed pvm
disp(['sfm on pre-computed pvm'])
pvm = importdata('PointViewMatrix.txt');
test(pvm);

% % geometric outlier removal
% % this run takes a few minutes
% disp(['geometric outlier removal'])
% pvm = get_pointview_mat('Data/House/House/', 4, 'geo_outlier');
% test(pvm)
% 
% % outlier removal by RANSAC and fundamental matrix estimation
% disp(['outlier removal by RANSAC and fundamental matrix estimation'])
% pvm = get_pointview_mat('Data/House/House/', 4, 'sampson');
% test(pvm)
% 
% outlier removal by SIFT-thresholding
disp(['outlier removal by SIFT-thresholding'])
pvm = get_pointview_mat('Data/House/House/', 14);
test(pvm)
% 
% % super densification
% disp(['super densification'])
% pvm = superdense(pvm_14);
% test(pvm)
% 
% t-densification with low t
disp(['t-densification with t=8'])
pvm = tdensify(pvm_14, 8);
test(pvm)
% 
% % t-densification with high t
% disp(['t-densification with t=-8'])
% pvm = tdensify(pvm_14, -8);
% test(pvm)

function test(pvm)
    figure()
    imshow(pvm);
    disp(["density of this pvm is: "+num2str(1 - (sum(sum(isnan(pvm))) / numel(pvm)))])
    disp(["it contains "+num2str(size(pvm, 2))+" points"])
    pc = sparse_sfm(pvm);
    show_pointcloud(pc)
    disp(" ")
end