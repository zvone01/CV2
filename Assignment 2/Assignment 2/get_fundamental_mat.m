function F = get_fundamental_mat(im1, im2, varargin)

% set various booleans
norm = false;
ransac = false;
show = false;
if any(strcmp(varargin, 'norm'))
    norm = true;
end
if any(strcmp(varargin, 'ransac'))
    ransac = true;
end
if any(strcmp(varargin, 'show'))
    show = true;
end

% retrieve point correspondences by evaluating SIFT features
correspondences = keypoint_matching(im1, im2);

% perform normalisation yes or no
if norm
    [c, T] = normalise(correspondences);
else
    c = correspondences;
end

% perform RANSAC yes or no
if ransac
    F = eight_point_RANSAC(c);
else
    F = eight_point_algorithm(c);
end

% denormalise
if norm
    F = T(:,:,2)'*F*T(:,:,1);
end

if show
    % draw epipolar lines
    draw_epipolar_lines(im1, im2, correspondences, F, 4);
    
    % check how well the epipolar constraint is met
    err = trace(correspondences(:,:,1)' * F * correspondences(:,:,2));
    disp("deviation from epipolar constraint: "+num2str(err))  
end

end

function draw_epipolar_lines(im1, im2, c, F, n)
im_width = size(im2, 2);

% pick random points to draw epipolar lines of
idx = randi(size(c,2), 1, n);

% epipolar line in image 2 for a point in image 1
l = F * c(:,idx,1);

% determine points on the left and right of image 2 to draw a blue line
% between
x0 = zeros(n, 1);
y0 = -l(3, :)./l(2,:);
xa = im_width*ones(1, n);
ya = (-l(3, :) - l(1,:).*xa)./l(2,:);

% show
figure()
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
