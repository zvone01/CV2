function F = get_fundamental_mat(im1, im2, varargin)

% set various booleans
norm = false;
ransac = false;
show = false;
if any(strcmp(varargin, 'norm'))
    norm = true;
    disp(['norm'])
end
if any(strcmp(varargin, 'ransac'))
    ransac = true;
    disp(['ransac'])
end
if any(strcmp(varargin, 'show'))
    show = true;
end

% retrieve point correspondences by evaluating SIFT features
correspondences = keypoint_matching(im1, im2);

% data to check
% correspondences = zeros(3, 8, 2);
% size(correspondences)
% correspondences(:,:,1) = [ 335 124 1 ; 320 194 1 ; 301 307 1 ; 168 78  1 ; 131 278 1 ; 480 177 1 ; 346 460 1 ; 241 426 1 ]';
% correspondences(:,:,2) = [ 335 123 1 ; 322 191 1 ; 305 305 1 ; 163 77  1 ; 131 278 1 ; 478 174 1 ; 347 462 1 ; 241 425 1 ]';

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
    % err = trace(correspondences(:,:,1)' * F * correspondences(:,:,2));
    % disp("deviation from epipolar constraint: "+num2str(err))  
end

end

function draw_epipolar_lines(im1, im2, c, F, n)
im_width = size(im2, 2);

% pick random point to draw epipolar lines of
idx = randi(size(c,2), 1, n);
c_b = c(:,idx,:)

c_b(:,:,1)'*F*c_b(:,:,2)

% epipolar line in image 2 for a point in image 1
l2 = F * c_b(:,:,1);
l1 = (c_b(:,:,2)' * F)';

% determine points on the left and right of image 2 to draw a blue line
% between
x0 = zeros(n, 1);
xa = im_width*ones(1, n);

y02 = -l2(3, :)./l2(2,:);
ya2 = (-l2(3, :) - l2(1,:).*xa)./l2(2,:);
y01 = -l1(3, :)./l1(2,:);
ya1 = (-l1(3, :) - l1(1,:).*xa)./l1(2,:);

% show
figure()
subplot(1,2,1), imshow(im1);
hold on
plot(c(1,:,1), c(2,:,1), 'rx');
plot(c(1,idx,1), c(2,idx,1), 'bx');
for i = 1 : n
    plot([0 im_width], [y01(i) ya1(i)], 'b-');
end
hold off
subplot(1,2,2), imshow(im2);
hold on
plot(c(1,:,2), c(2,:,2), 'rx');
plot(c(1,idx,2), c(2,idx,2), 'bx');
for i = 1 : n
    plot([0 im_width], [y02(i) ya2(i)], 'b-');
end
hold off


end
