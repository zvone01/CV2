function total_pointcloud = sparse_sfm(pvm)
    % example pvm mat 
    % [ a b c ;
    %   d e f ;
    %   g h NaN ]

    % pad pvm with NaNs at the right and at the bottom
    pvm = padarray(pvm, [ 1 1 ], NaN, 'post');

    % initialise variables
    total_pointcloud = 0;
    idx = 1; % the first point in the sub_pointcloud is the idx-th point in the total pointcloud

    % divide pvm into dense submatrices, extract 3D points and add to
    % pointcloud
    %while size(pvm, 1) > 0 && size(pvm, 2) > 0
    while all(size(pvm) > [0, 0])

        % find the stretch from top left to first NaN (right and down)
        init_width = min(squeeze(find(isnan(pvm(1, :)))));
        init_height = min(squeeze(find(isnan(pvm(:, 1)))));

        % find the submat
        % [ a b c ;
        %   d e f ]
        height = init_height;
        for i = 1 : init_width - 1
            height = min(min(squeeze(find(isnan(pvm(:, i))))), height);
        end    
        dense_mat = pvm(1 : height-1, 1 : init_width-1);
        total_pointcloud = point_stitching(total_pointcloud, dense_mat, idx);

        % find the submat
        % [ a b ;
        %   d e ;
        %   g h ]
        width = init_width;
        for i = 1 : init_height - 1
            width = min(min(squeeze(find(isnan(pvm(i, :))))), width);
        end
        if height ~= init_height && width ~= init_width % if this submat hasnt already been found above
            dense_mat = pvm(1 : init_height-1, 1 : width-1);
            total_pointcloud = point_stitching(total_pointcloud, dense_mat, idx);
        end

        % in the example:
        % [ a b c NaN ;
        %   d e f g ;
        %   h i j k ;
        % NaN l m n ]
        %
        % slice to obtain pvm for new iteration:
        % [ e f g ;
        %   i j k ;
        %   l m n ]
        if width == init_width
            n_remove_row = min(squeeze(find(~isnan(pvm(:, width))))) - 1;
        else
            n_remove_row = min(squeeze(find(isnan(pvm(:, width))))) - 1;
        end
        if height == init_height
            n_remove_col = min(squeeze(find(~isnan(pvm(height, :))))) - 1;
        else
            n_remove_col = min(squeeze(find(isnan(pvm(height, :))))) - 1;
        end

        % take care of the cases
        % [ NaN NaN NaN ;
        %   a b c ;
        %   d e f ]
        %
        % [ NaN a b ;
        %   NaN c d ;
        %   NaN e f ]
        if(isempty(n_remove_row))
            n_remove_row = 0;
        end
        if(isempty(n_remove_col))
            n_remove_col = 0;
        end
        
        % in case of 
        % [ a b c NaN ;
        %   d e f NaN ;
        %   g h i NaN ;
        % NaN NaN NaN NaN ]
        % n_remove would not be found
        if n_remove_row == 0 && n_remove_col == 0
           if all(size(pvm) == [height, width])
               n_remove_row = height;
               n_remove_col = width;
           else % last resort for any failure that prevents parsing
               n_remove_col = 1;
           end
        end

        % trim the pvm
        pvm = pvm( (n_remove_row + 1) : size(pvm, 1) , (n_remove_col + 1) : size(pvm, 2) );
        idx = idx + n_remove_col;

    end
end

% ideas:
% keep track of the indices somehow
function pvm = purify(pvm)
    % if there are columns or rows that are all-NaN, remove them.
    pvm = pvm(all(~isnan(pvm),2),:); % for nan - rows
    pvm = pvm(:, all(~isnan(pvm)));   % for nan - columns
end