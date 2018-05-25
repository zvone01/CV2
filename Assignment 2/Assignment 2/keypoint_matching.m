function c = keypoint_matching(im1, im2, t)
[f1, d1] = vl_sift(im1); % find features in this image
[f2, d2] = vl_sift(im2); % find features in this image 

% match features between the two images
[matches, ~] = vl_ubcmatch(d1, d2, t);

% gather the coordinate data of the relevant features
indices_f1 = matches(1,:);
indices_f2 = matches(2,:);
keypoints_f1 = f1(1:2, indices_f1);
keypoints_f2 = f2(1:2, indices_f2);

% save in a 2-by-n-by-2 tensor
c = cat(3, keypoints_f1, keypoints_f2);

% add homogenous coordinates for a 3-by-n-by-2 tensor
n = size(c, 2);
c = cat(1 , c(:, :, :), ones(1, n, 2) );

end