function point_cloud = sfm (PointViewMatrix)

startR =1;
R = 5;
startC=1;
C = 15;

dense_point = [];
y = 1;
while  startR+R < size(PointViewMatrix,1)
    if(startC+C > size(PointViewMatrix,2))
        startC = 1;
        C = 15;
        startR = startR + 2;
        R = 3;
    end
    %sliding window
    sw = PointViewMatrix(startR:startR+R,startC:startC+C);
    %if nan exist move window
    if(any(isnan(sw(:))))
        [row, col] = find(isnan(sw));
        startC = startC+max(col);
    else
        sw_new = sw;
        %try to expand in x
        while ~any(isnan(sw_new(:))) && startC+C < size(PointViewMatrix,2) 
             sw = sw_new;
             C = C+1;
             sw_new = PointViewMatrix(startR:startR+R,startC:startC+C);
        end


        %try to expand in y
         sw_new = sw;
        while ~any(isnan(sw_new(:))) && startR+R < size(PointViewMatrix,1) 
             sw = sw_new;
             R = R+2;
             sw_new = PointViewMatrix(startR:startR+R,startC:startC+C);
        end

        dense_point{y} = sw;
        y=y+1;
        startC = 1;
        startR = startR + 2;
        R = 5;
        C = 15;
   
    end

end

point_cloud = point_stiching(dense_point);

end
