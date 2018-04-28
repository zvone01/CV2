function show_cloud(cloud, n_show)
figure()
n_points = size(cloud, 2);
x = cloud(1, 1:round(n_points/n_show):n_points); % width
y = cloud(3, 1:round(n_points/n_show):n_points); % depth
z = -cloud(2, 1:round(n_points/n_show):n_points); % height
fscatter3(x, y, z, z);
end