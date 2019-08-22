function Y = my_clip(X, lb, ub)
Y = min(ub, max(lb, X));
end
