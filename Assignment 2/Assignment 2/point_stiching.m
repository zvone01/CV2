function point_cloud = point_stiching(dense_point,point_cloud, index)


    [~, shape] = sfm_compute(dense_point);
    % add 3D points to the total cloud
    if point_cloud == 0
        point_cloud = shape;
    else
        target_size = size(point_cloud(:,index:end),2);
        [d,Z,transform] = procrustes(point_cloud(:,index:end),shape(:,1:target_size));
        c = transform.c;
        T = transform.T;
        shapeT = shape*T + repmat(c, [1, size(shape,2)]);
        point_cloud = cat(2,point_cloud,shapeT(:,target_size:end));
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