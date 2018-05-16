function shape = remove_affine_ambiguity(motion, shape)
    L = pinv(motion)' \ motion;
    C = chol(L)';
    shape = inv(C)*shape;
end