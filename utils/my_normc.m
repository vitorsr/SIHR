function Y = my_normc(X)
den = sqrt(sum(X.^2, 1));
Y = zeros(size(X), class(X));
Y(:, den ~= 0) = X(:, den ~= 0) ./ den(den ~= 0);
end
