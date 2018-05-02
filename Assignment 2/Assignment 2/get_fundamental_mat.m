function F = get_fundamental_mat(im1, im2)

% retrieve point correspondences by evaluating SIFT features
correspondences = keypoint_matching(im1, im2);

% perform normalisation yes or no, compareresults to see its influence

% perform RANSAC to get best fundamental mat
F = eight_point_RANSAC(correspondences);

% draw epipolar lines
draw_epipolar_lines(im1, im2, correspondences, F, 4);

% if the epipolar constraint is satisfied, this would be 0

end

function draw_epipolar_lines(im1, im2, c, F, n)
im_width = size(im2, 2);

% pick random points to draw epipolar lines of
idx = randi(size(c,2), 1, n);

% epipolar line in image 2 for a point in image 1
l = F * cat(1, c(:,idx,1), ones(1, n));

% determine points on the left and right of image 2 to draw a blue line
% between
x0 = zeros(n, 1);
y0 = -l(3, :)./l(2,:);
xa = im_width*ones(1, n);
ya = (-l(3, :) - l(1,:).*xa)./l(2,:);

% show
subplot(1,2,1), imshow(im1);
hold on
plot(c(1,:,1), c(2,:,1), 'rx');
plot(c(1,idx,1), c(2,idx,1), 'bx');
hold off
subplot(1,2,2), imshow(im2);
hold on
plot(c(1,:,2), c(2,:,2), 'rx');
for i = 1 : n
    plot([0 im_width], [y0(i) ya(i)], 'b-');
end
hold off

end
