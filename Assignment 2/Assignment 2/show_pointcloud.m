function show_pointcloud(pc)
    x = pc(1,:);
    y = pc(2,:);
    z = -pc(3,:);

    tri = delaunay(x, y);
    figure()
    trisurf(tri, x, y, z);

    figure()
    plot3( x, y, z, 'ko');
end