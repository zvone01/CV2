function pvm = tdensify(pvm, t)
    % t is amount of frames a point needs to at least be present in
    % to check if it is, we need to check NaN's in 2*t rows
    % t < 0 is interpreted as
    % the amount of frames it may maximally be omitted from
    
    t = t*2;
    if t < 0
       t = size(pvm, 1) + t;
    end
    pvm(:, sum(~isnan(pvm), 1) <= t) = [];
end