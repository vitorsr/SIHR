function I_d = Yang2010(I)
%Yang2010 I_d = Yang2010(I)
%  This method uses a fast bilateralFilter implementation by Jiawen Chen:
%    http://people.csail.mit.edu/jiawen/software/bilateralFilter.m
%  
%  This method should have equivalent functionality as
%  `qx_highlight_removal_bf.cpp` formerly distributed by the author.
%  
%  See also SIHR, Tan2005.

assert(isa(I, 'double'), 'SIHR:I:notTypeDouble', ...
    'Input I is not type double.')
assert(min(I(:)) >= 0 && max(I(:)) <= 1, 'SIHR:I:notWithinRange', ...
    'Input I is not within [0, 1] range.')
[n_row, n_col, n_ch] = size(I);
assert(n_row > 1 && n_col > 1, 'SIHR:I:singletonDimension', ...
    'Input I has a singleton dimension.')
assert(n_ch == 3, 'SIHR:I:notRGB', ...
    'Input I is not a RGB image.')

total = sum(I, 3);

sigma = I ./ total;
sigma(isnan(sigma)) = 0;

sigmaMin = min(sigma, [], 3);
sigmaMax = max(sigma, [], 3);

lambda = ones(size(I)) / 3;
lambda = (sigma - sigmaMin) ./ ...
    (3 * (lambda - sigmaMin));
lambda(isnan(lambda)) = 1 / 3;

lambdaMax = max(lambda, [], 3);

SIGMAS = 0.25 * min(size(I, 1), size(I, 2));
              % sqrt(size(I, 1)*size(I, 2));
SIGMAR = 0.04;
THR = 0.03;

while true
    sigmaMaxF = bilateralFilter(sigmaMax, lambdaMax, 0, 1, SIGMAS, SIGMAR);
    if nnz(sigmaMaxF-sigmaMax > THR) == 0
        break
    end
    sigmaMax = max(sigmaMax, sigmaMaxF);
end

Imax = max(I, [], 3);

den = (1 - 3 * sigmaMax);
I_s = (Imax - sigmaMax .* total) ./ den;
I_s(den == 0) = 0;

I_d = min(1, max(0, I-I_s));

end
