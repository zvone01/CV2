%% set up the environment
run('/usr/local/MATLAB/vlfeat/toolbox/vl_setup')
% run('C:\Users\zdujmic\Documents\MATLAB\vlfeat\toolbox\vl_setup')\

%% Fundamental Matrix and Eight-Point algorithm
im1 = im2single(imread('Data/House/House/frame00000001.png'));
im2 = im2single(imread('Data/House/House/frame00000002.png'));

F = get_fundamental_mat(im1, im2, 'show');
F = get_fundamental_mat(im1, im2, 'norm', 'show');
F = get_fundamental_mat(im1, im2, 'norm', 'show', 'ransac');

%% construct the pointview matrix from the frames using SIFT
pvm_sparse = get_pointview_mat('Data/House/House/');

ts = [3, 8, -3, -8];

for i = 1 : 3 + size(ts, 2)
    if i <= 3
        switch i
            case 1
                % control run
                pvm = importdata('PointViewMatrix.txt');
                disp("performance using pre-computed (fully dense) PVM")
            case 2
                % sparse pvm
                pvm = pvm_sparse;
                disp("performance using sparse pvm")
            case 3
                % only keep points that are visible in all frames
                disp("performance using 'superdense' optimisation method")
                pvm = superdense(pvm_sparse);
        end
    else
        t = ts(i - 3);
        % remove points that are visible in less than t of the frames
        % for negative t:
        % remove a point if it is omitted in more than t frames
        disp("performance using t-densification where t = "+num2str(t))
        pvm = tdensify(pvm_sparse, t);
    end
    
    figure()
    imshow(pvm);
    disp(["density of this pvm is: "+num2str(1 - (sum(sum(isnan(pvm))) / numel(pvm)))])
    disp(["it contains "+num2str(size(pvm, 2))+" points"])
    pc = sparse_sfm(pvm);
    show_pointcloud(pc)
    disp(" ")
end