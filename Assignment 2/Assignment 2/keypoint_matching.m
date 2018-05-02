function correspondences = keypoint_matching(im1, im2)

[f1, d1] = vl_sift(im1); % find features in this image
[f2, d2] = vl_sift(im2); % find features in this image 

% match features between the two images
% [matches, scores] = vl_ubcmatch(d1, d2);
[matches, ~] = vl_ubcmatch(d1, d2);

% gather the coordinate data of the relevant features
indices_f1 = matches(1,:);
indices_f2 = matches(2,:);
keypoints_f1 = f1(1:2, indices_f1);
keypoints_f2 = f2(1:2, indices_f2);

correspondences = cat(3, keypoints_f1, keypoints_f2);

end