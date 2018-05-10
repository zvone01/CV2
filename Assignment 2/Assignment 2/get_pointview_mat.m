function [PointViewMatrix Xs Ys] = get_pointview_mat(dir_to_search)
   
    txtpattern = fullfile(dir_to_search, '*.png');
    dinfo = dir(txtpattern);

    Xs = [];
    Ys = [];
    %loop trought every par of images, 
    for i = 1 : size(dinfo,1) -1
        
        %get image
        im1 = im2single(imread(char(strcat(dir_to_search,dinfo(i).name))));
        im2 = im2single(imread(char(strcat(dir_to_search,dinfo(i+1).name))));

        %compute fundemental matrix and get correspondences
        [F,c] = get_fundamental_mat(im1, im2, 'norm',  'ransac');
        
        %if first iteration add automaticly
         if(i == 1)
            Xs = c(1,:,1);
            Ys = c(2,:,1); 
         end
         %loop trought all correspondences
         for a=1:size(c(1,:,1),2)
            %check for x
             [ex p] = ismember(c(1,a,1),Xs(i,:));
            
             %check for y match on x position
            if ex && c(2,a,1) == Ys(i,p)
               Xs(i+1,p) = c(1,a,2);
               Ys(i+1,p) = c(2,a,2);
            else
               %add new point
               Xs(i,end +1) = c(1,a,1);
               Ys(i,end +1) = c(2,a,1);
                 
               Xs(i+1,end) = c(1,a,2);
               Ys(i+1,end) = c(2,a,2);
            end
             
         end
   
         
    end
    %%
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