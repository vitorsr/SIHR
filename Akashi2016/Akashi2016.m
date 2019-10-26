function I_d = Akashi2016(I)
%Akashi2016 I_d = Akashi2016(I)
%  The core mechanism is herein implemented fully in accordance with their
%  paper. I have not implemented the repeated score trials. It is pending.
%  This is because this method is somewhat slow.
%
%  Convergence criterion is based on Yamamoto and Nakazawa (exp(-15)), you
%  can change it:
%    edit Akashi2016.m
%  Search 'eps' and change it.
%
%  Also, because of random initialization, I believe averaging the
%  estimated diffuse component over many applications of the method will
%  greatly improve the quality.
%
%  See also SIHR.

assert(isa(I, 'float'), 'SIHR:I:notTypeSingleNorDouble', ...
    'Input I is not type single nor double.')
assert(min(I(:)) >= 0 && max(I(:)) <= 1, 'SIHR:I:notWithinRange', ...
    'Input I is not within [0, 1] range.')
[n_row, n_col, n_ch] = size(I);
assert(n_row > 1 && n_col > 1, 'SIHR:I:singletonDimension', ...
    'Input I has a singleton dimension.')
assert(n_ch == 3, 'SIHR:I:notRGB', ...
    'Input I is not a RGB image.')

I = 255 * I;
M = 3; % = number of color channels
N = n_row * n_col; % = number of pixels
R = 7; % = number of color clusters - 1
I = reshape(I, [N, M])';
i_s = ones(3, 1, class(I)) / sqrt(3);
H = 254 * rand(R, N, class(I)) + 1;
W_d = 254 * rand(3, R-1, class(I)) + 1;
W_d = my_normc(W_d); % W_d ./ vecnorm(W_d, 2, 1); % normalize(W_d,1,'norm');
W = [i_s, W_d];
A = ones(M, class(I));
lambda = 3;
eps = exp(-15);
F_t_1 = Inf;
iter = uint16(0);
max_iter = uint16(10e3); % change for later convergence (takes way longer)
% tic
while true
    W_bar = my_normc(W);
    H = H .* ((W_bar') * I) ./ ...
        ((W_bar') * W_bar * H + lambda);
    H_d = H(2:end, :);
    Vl = max(0, I-i_s*H(1, :));
    % W_d = W(:,2:end); % not sure
    W_d_bar = W_bar(:, 2:end);
    W_d = W_d_bar .* (Vl * (H_d') + W_d_bar .* (A * W_d_bar * H_d * (H_d'))) ./ ...
        (W_d_bar * H_d * (H_d') + W_d_bar .* (A * Vl * (H_d')));
    W = [i_s, W_d];
    F_t = 0.5 * norm((I - W * H), 'fro') + lambda * sum(H(:));
    if abs(F_t-F_t_1) < eps * abs(F_t) || iter >= max_iter
        break
    end
    F_t_1 = F_t;
    iter = iter + 1;
end
% toc
W_d = W(:, 2:end);
% h_s = H(1, :);
H_d = H(2:end, :);
% I_s = i_s * h_s;
I_d = W_d * H_d;
% I_s = reshape(full(I_s)', [n_row, n_col, n_ch]) / 255;
I_d = reshape(full(I_d)', [n_row, n_col, n_ch]) / 255;

% figure(1), imshow(I_s)
% figure(2), imshow(I_d)

end
