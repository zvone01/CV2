function PointViewMatrix = get_pointview_mat(dir_to_search, t, varargin)
txtpattern = fullfile(dir_to_search, '*.png');
dinfo = dir(txtpattern);
Xs = [];
Ys = [];

% set various booleans
sampson = false;
outliers = false;

if any(strcmp(varargin, 'sampson'))
    sampson = true;
end
if any(strcmp(varargin, 'geo_outlier'))
    outliers = true;
end

% loop trought every pair of images,
for i = 1 : size(dinfo,1) - 1
    % get images
    im1 = im2single(imread(char(strcat(dir_to_search,dinfo(i).name))));
    im2 = im2single(imread(char(strcat(dir_to_search,dinfo(i+1).name))));
    
    % get corresponding points
    if sampson
        [F, c] = get_fundamental_mat(im1, im2, t, 'norm', 'ransac');
        c = filter_by_sampson_distance(c, F);
    else
        c = keypoint_matching(im1, im2, t);
    end
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

%remove outliers
if outliers
    pvm = remove_outliers(PointViewMatrix);
    PointViewMatrix = pvm(:,any(~isnan(pvm)));
end

end


function pvm = remove_outliers(PointViewMatrix)

for frame=1:2:size(PointViewMatrix,1)
    min_matrix = zeros(1,size(PointViewMatrix(~isnan(PointViewMatrix(frame,:))),2));
    
    for i=1:size(PointViewMatrix,2)
        x1 = PointViewMatrix(frame,i);
        y1 = PointViewMatrix(frame+1,i);
        if(~isnan(x1))
            min = 0;
            for j=1:size(PointViewMatrix,2)
                
                x2 = PointViewMatrix(frame,j);
                y2 = PointViewMatrix(frame+1,j);
                if(~isnan(x2))
                    d = pdist([x1 y1; x2 y2],'euclidean');
                    
                    if (d < min || min == 0)
                        min = d;
                    end
                end
            end
            min_matrix(1,i) = min;
        end
    end
    R = min_matrix;
    idx = bsxfun(@gt, R, mean(R) + std(R));
    idx = any(idx, 1);
    PointViewMatrix(frame, idx) = 0;
    PointViewMatrix(frame+1, idx) = 0;
end

pvm = PointViewMatrix;
end