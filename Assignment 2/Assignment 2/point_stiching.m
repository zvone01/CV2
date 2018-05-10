function point_cloud = point_stiching(dense_point_list)

    point_cloud = [];
    for i=1:size(dense_point_list,2)
        [~, shape] = sfm_compute(dense_point_list{1});

       if(i == 1)
        point_cloud = shape;
       else
           [~,Z,~] = procrustes(point_cloud(end-2:end,end-2:end),shape(1:3,1:3));
           point_cloud = cat(2,point_cloud,Z);
       end

    end
end


function [motion shape] = sfm_compute(point_cloud)
% mean of each row

point_cloud(1:2:end,:) = bsxfun(@minus, point_cloud(1:2:end,:), mean(point_cloud(1:2:end,:), 2));
point_cloud(2:2:end,:) = bsxfun(@minus, point_cloud(2:2:end,:), mean(point_cloud(2:2:end,:), 2));

%compute svd
[U W V] = svd(point_cloud);

% compute motion and shape
motion = U(:, 1:3)*sqrt(W(1:3, 1:3)); 
shape = sqrt(W(1:3, 1:3))*V(:, 1:3)';
%figure()
%plot3(shape(1, :), shape(2,:), shape(3,:),'k.');
end