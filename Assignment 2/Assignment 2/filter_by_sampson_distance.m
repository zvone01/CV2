function c = filter_by_sampson_distance(data,F)

% threshold
t = 0.025; 

% determine sampson distance for each correspondence
p1 = data(:, :, 1);
p2 = data(:, :, 2);
d = (p1' * F * p2).^2 / ( sum((F' * p1).^2) + sum((F * p2).^2));

% filter out those correspondences with d > t
% return only correspondences with d < t
idx =  d < t;
c = data(:,idx,:);

end