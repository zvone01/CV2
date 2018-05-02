function best_Fmat = eight_point_RANSAC(data)
t = .25; % threshold

bestScore = 0; % initialise 
for i = 1 : 300 % max_iter
    % determine F on 8 randomly drawn point-correspondences
    F = eight_point_algorithm(data);
    
    % check whether F is a 'good guess' by counting inliers
    % determine sampson distances by matrix multiplication
    p1 = data(:, :, 1);
    p2 = data(:, :, 2);
    d = (p1' * F * p2).^2 / ( sum((F' * p1).^2) + sum((F * p2).^2));
    
    % score is the n points closer to each other than threshold value
    score = sum( d < t );
    
    if ( score > bestScore )
        bestScore = score;
        best_Fmat = F;
    end
end
end