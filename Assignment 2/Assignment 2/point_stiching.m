function point_cloud = point_stiching(dense_point_list)

    point_cloud = [];
    for i=1:size(dense_point_list)
        [~, shape] = sfm(dense_point_list(1));

       if(i == 1)
        point_cloud = shape;
       else
           [~,Z,~] = procrustes(point_cloud(end-3:end,end-3:end),shape(1:3,1:3));
           point_cloud = cat(2,point_cloud,Z);
       end

    end

end;