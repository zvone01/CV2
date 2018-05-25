function total_pointcloud = point_stitching(total_pointcloud, dense_submat, idx)

    % we need at least 3 points in 2 frames to construct a 3D pointcloud
    if all(size(dense_submat) >= [4, 3])
        % get 3D points from the dense submatrix
        [motion, shape] = dense_sfm(dense_submat);
        add_pointcloud = remove_affine_ambiguity(motion, shape);

        % add 3D points to the total cloud
        if total_pointcloud == 0
            total_pointcloud = add_pointcloud;
        elseif idx <= size(total_pointcloud, 2) - 3 % procrustes needs at least 3 3D points
            n_point_overlap = min([ size(total_pointcloud, 2) - idx + 1, size(add_pointcloud, 2) ]);
            
            source = add_pointcloud(:, 1:n_point_overlap);
            target = total_pointcloud(:, idx:idx+n_point_overlap-1);
            
            if size(source, 2) > size(target, 2)
               swap = source;
               source = target;
               target = swap;
            end
            
            [~, ~, transform] = procrustes(target, source);
            c = transform.c; % translation
            T = transform.T; % rotation
            b = transform.b; % scaling
            
            source_moved = b*source*T + c;
            
            if size(add_pointcloud, 2) > size(total_pointcloud, 2) - idx + 1
                total_pointcloud = cat(2, target, source_moved);
            else
                total_pointcloud = cat(2, total_pointcloud, source_moved);
            end     
        end
    end
end