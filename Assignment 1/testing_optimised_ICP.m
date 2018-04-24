% we test on the transformation from the first to the second point cloud
dir_to_search = 'Data/data';
txtpattern = fullfile(dir_to_search, '*_depth.png');
dinfo = dir(txtpattern);
p1 = PointCloud(imread(char(strcat("data/",dinfo(2).name))))';
p2 = PointCloud(imread(char(strcat("data/",dinfo(1).name))))';

for eps = [0, .01]
    
    p1 = (p1 + normrnd(0, eps, size(p1)));
    p2 = (p2 + normrnd(0, eps, size(p2)));
    pc1 = pointCloud( p1' );
    pc2 = pointCloud( p2' );
    n1 = pcnormals(pc1, 4)'; 
    n2 = pcnormals(pc2, 4)';

    % unoptimised (deterministic)
    tic
    [~, ~, RMS, i] = ICP(p1, p2)
    toc

    % various optimised versions on various parameters
    n_runs = 10;    
     for sampling = ["uniform", "random"]
        for p = [0.1, .07, .04]
             for sample_by = ["default", "normals"]
                t = zeros(n_runs);
                RMSs = zeros(n_runs);
                its = zeros(n_runs);
                for n = 1 : n_runs
                    tic
                    [~, ~, RMS, i] = ICP(p1, p2, sampling, p, sample_by, n1, n2, 10);
                    t(n) = toc;
                    RMSs(n) = RMS;
                    its(n) = i;
                end
                % LaTeX-friendly output
                t_avg = mean(t, 1);
                t_std = std(t, 1);
                RMS_avg = mean(RMSs, 1);
                RMS_std = std(RMSs, 1);
                it_avg = mean(its, 1);
                disp([num2str(eps)+" & "+sampling+" & "+sample_by+" & "+num2str(p)+" & "+num2str(it_avg(1))+" & "+num2str(t_avg(1))+" & "+num2str(RMS_avg(1))+" & "+num2str(t_std(1))+" & "+num2str(RMS_std(1))+" \\" ])
            end
        end
    end
end