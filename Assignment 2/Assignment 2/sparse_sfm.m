function [motion, shape] = sparse_sfm(pvm)

% example pvm mat 
% [ a b c ;
%   d e f ;
%   g h NaN ]

% toy data
% pvm = rand(10, 5);
% %pvm(2, 2) = NaN;
% pvm(9:10, 1) = NaN;
% pvm(9:10, 5) = NaN;
% pvm(1:2, 3) = NaN;
% pvm(1:2, 5) = NaN;

% pad pvm with NaNs at the right and at the bottom
pvm = padarray(pvm, [ 1 1 ], NaN, 'post');

% initialise variables
total_pointcloud = 0;
idx = 1; % the first point in the sub_pointcloud is the idx-th point in the total pointcloud

% divide pvm into dense submatrices, extract 3D points and add to
% pointcloud
while size(pvm, 1) > 0 && size(pvm, 2) > 0

    % find the stretch from top left to first NaN (right and down)
    init_width = min(squeeze(find(isnan(pvm(1, :)))));
    init_height = min(squeeze(find(isnan(pvm(:, 1)))));
    
    % find the submat
    % [ a b c ;
    %   d e f ]
    height = init_height;
    for i = 1 : init_width - 1
        height = min(min(squeeze(find(isnan(pvm(:, i))))), height);
    end    
    dense_mat = pvm(1 : height-1, 1 : init_width-1);   
    total_pointcloud = process_dense_mat(dense_mat, total_pointcloud, idx);
    
    % find the submat
    % [ a b ;
    %   d e ;
    %   g h ]
    width = init_width;
    for i = 1 : init_height - 1
        width = min(min(squeeze(find(isnan(pvm(i, :))))), width);
    end
    if height ~= init_height && width ~= init_width % if this submat hasnt already been found above
        dense_mat = pvm(1 : init_height-1, 1 : width-1);
        total_pointcloud = process_dense_mat(dense_mat, total_pointcloud, idx);
    end

    % in the example:
    % [ a b c NaN ;
    %   d e f g ;
    %   h i j k ;
    % NaN l m n ]
    %
    % slice to obtain:
    % [ e f g ;
    %   i j k ;
    %   l m n ]
    if width == init_width
        n_remove_row = min(squeeze(find(~isnan(pvm(:, width)))));
    else
        n_remove_row = min(squeeze(find(isnan(pvm(:, width)))));
    end
    if height == init_height
        n_remove_col = min(squeeze(find(~isnan(pvm(height, :)))));
    else
        n_remove_col = min(squeeze(find(isnan(pvm(height, :)))));
    end
    pvm = pvm( n_remove_row : size(pvm, 1) , n_remove_col : size(pvm, 2) );
    idx = idx + n_remove_col - 1;

end
end

function total_pointcloud = process_dense_mat(dense_mat, point_cloud, idx)
    % find 3D points from dense matrix
    [~, sub_pointcloud] = dense_sfm(dense_mat);
    
    % add 3D points to the total cloud
    if point_cloud == 0
        total_pointcloud = sub_pointcloud;
    else
        total_pointcloud = merge_cloud(point_cloud, sub_pointcloud, idx)
    end

end    

function [motion, shape] = dense_sfm(PointViewMatrix)
% mean of each row
PointViewMatrix(1:2:end,:) = bsxfun(@minus, PointViewMatrix(1:2:end,:), mean(PointViewMatrix(1:2:end,:), 2));
PointViewMatrix(2:2:end,:) = bsxfun(@minus, PointViewMatrix(2:2:end,:), mean(PointViewMatrix(2:2:end,:), 2));

%compute svd
[U W V] = svd(PointViewMatrix);

% compute motion and shape
motion = U(:, 1:3)*sqrt(W(1:3, 1:3)); 
shape = sqrt(W(1:3, 1:3))*V(:, 1:3)';

end


%     heights = zeros(1, init_width - 1);
%     for i = 1 : init_width
%        heights(i) = min(squeeze(find(isnan(pvm(:, i))))); 
%     end
%     heights
%     
%     widths = zeros(1, init_height - 1);
%     for i = 1 : init_height
%         widths(i) = min(squeeze(find(isnan(pvm(i, :)))));
%     end
%     widths
%     
%     dense = pvm(1 : min(heights(1:init_width-1))-1, 1 : init_width - 1)
%     dense = pvm(1 : init_height-1, 1 : min(widths(1:init_height-1))-1)