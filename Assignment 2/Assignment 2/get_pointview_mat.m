function PointViewMatrix = get_pointview_mat(dir_to_search)
    txtpattern = fullfile(dir_to_search, '*.png');
    dinfo = dir(txtpattern);
    Xs = [];
    Ys = [];
    
    % loop trought every pair of images,
    for i = 1 : size(dinfo,1) - 1
        % get images
        im1 = im2single(imread(char(strcat(dir_to_search,dinfo(i).name))));
        im2 = im2single(imread(char(strcat(dir_to_search,dinfo(i+1).name))));
        
        % get corresponding points
        c = keypoint_matching(im1, im2);
        
        % remove double correspondences
        [C, ia, ic]= unique(c(1:2,:,1)','rows','stable');
        c1 = C';
        c2 = c(1:2, ia', 2);
        
        %if first iteration add automaticly
        if(i == 1)
            Xs = c1(1,:);
            Ys = c1(2,:);
        end
        
        %loop through all correspondences
        for a = 1 : size( c1(1,:), 2)
            %check for x
            [ex p] = ismember(c1(1,a), Xs(i,:));
            
            %check for y match on x position
            if ex && c1(2,a) == Ys(i,p)
                Xs(i+1,p) = c2(1,a);
                Ys(i+1,p) = c2(2,a);
            else
                %add new point
                Xs(i,end +1) = c1(1,a);
                Ys(i,end +1) = c1(2,a);
                
                Xs(i+1,end) = c2(1,a);
                Ys(i+1,end) = c2(2,a);
            end
            
        end
        
        
    end
    
    %
    %create PointViewMatrix from Xs and Ys in form
    %Xs11 Xs12 ...
    %Ys11 Ys12 ...
    %Xs21 Xs22 ...
    %Ys21 Ys22 ...
    %...  ...
    
    PointViewMatrix = zeros(size(Xs,1)*2,size(Xs,2)); 
    PointViewMatrix(1:2:end) = Xs;
    PointViewMatrix(2:2:end) = Ys;
    PointViewMatrix(PointViewMatrix==0) = NaN;
end