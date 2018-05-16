function total_pointcloud = point_stitching(total_pointcloud, dense_submat, idx)

    % we need at least 3 points in 2 frames to construct a 3D pointcloud
    if all(size(dense_submat) >= [4, 3])
        % get 3D points from the dense submatrix
        [~, add_pointcloud] = dense_sfm(dense_submat);

        %if (idx < (size(total_pointcloud, 2) - 6) || total_pointcloud == 0 ) && all(size(dense_mat) >= [4, 3])

        % add 3D points to the total cloud
        if total_pointcloud == 0
            total_pointcloud = add_pointcloud;
        elseif idx <= size(total_pointcloud, 2) - 3 % procrustes needs at least 3 3D points
            
            n_point_overlap = min([ size(total_pointcloud, 2) - idx + 1, size(add_pointcloud, 2) ]);
            
            target = total_pointcloud(:, idx:idx+n_point_overlap-1);                        
            source = add_pointcloud(:, 1:n_point_overlap);
                        
            [~, ~, transform] = procrustes(target, source);
            c = transform.c; % translation
            T = transform.T; % rotation
                        
            add_pointcloud = add_pointcloud*T + c;
            
            % add all (or only points not-yet-present? whatabout
            % interpolation?)
            total_pointcloud = cat(2, total_pointcloud, add_pointcloud);
            
            %disp(['succesfull stitch'])
        end
    end
end