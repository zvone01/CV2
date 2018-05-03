run('/usr/local/MATLAB/vlfeat/toolbox/vl_setup')
im1 = im2single(imread('Data/House/House/frame00000001.png'));
im2 = im2single(imread('Data/House/House/frame00000002.png'));

F = get_fundamental_mat(im1, im2, 'show');
F = get_fundamental_mat(im1, im2, 'norm', 'show');
F = get_fundamental_mat(im1, im2, 'norm', 'show', 'ransac');


