function PointViewMatrix = get_pointview_mat(dir_to_search)
% prepare variables
txtpattern = fullfile(dir_to_search, '*.png');
dinfo = dir(txtpattern);


%loop trought every par of images, 
y =1;
for i = 1:2 : size(dinfo,1) -1

    im1 = im2single(imread(char(strcat(dir_to_search,dinfo(i).name))));
    im2 = im2single(imread(char(strcat(dir_to_search,dinfo(i+1).name))));

    [F,c] = get_fundamental_mat(im1, im2, 'norm',  'ransac');
    
    PointViewMatrix(y,:) = c(1,1:215,1);
    y=y+1;
    PointViewMatrix(y,:) = c(2,1:215,1);
    y=y+1;
    PointViewMatrix(y,:) = c(1,1:215,2);
    y=y+1;
    PointViewMatrix(y,:) = c(2,1:215,2);
    y=y+1;
end

end