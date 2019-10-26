function I_d = Yamamoto2019(I, AuthorYEAR)
%Yamamoto2019 I_d = Yamamoto2019(I, AuthorYEAR)
%  This function enhances the diff. comp. I_d obtained by AuthorYEAR method.
%
%  AuthorYEAR is optional (defaults to Shen2013), but can also be specified
%  as a valid function handle, e.g. @Yang2010, @Shen2008.
%
%  Example:
%    J = im2double(imread('toys.ppm'));
%    J_d = Yamamoto2019(J, @Yoon2006);
%    imshow(J_d)
%
%  There were no major ambiguities in my interpretation of the corresponding
%  paper.
%
%  There's only a mention of applying SVD to obtain the specular component
%  after calculating a diffuse component by applying an existing method.
%  However, all operations regard $\beta S$, i.e. I_s which is I - I_d under
%  DRM assumption (that they're linearly additive). Hence, we skip this
%  step (Part 2).
%  
%  See also SIHR, Yang2010, Shen2013.

if nargin == 2
    if isempty(AuthorYEAR)
        AuthorYEAR = @Shen2013;
    else
        assert(isa(AuthorYEAR, 'function_handle'), 'SIHR:I:notTypeFunctionHandle', ...
            'Input AuthorYEAR is not of type function_handle.')
        my_f = functions(AuthorYEAR);
        if isempty(my_f.file)
            warning(['Undefined function ''', func2str(AuthorYEAR), '''.', sprintf('\n'), ...
                '         Defaulting to ''Shen2013''.'])
            AuthorYEAR = @Shen2013;
        end
    end
elseif nargin == 1
    AuthorYEAR = @Shen2013;
end

[n_row, n_col, ~] = size(I);

% DRM: I = I_d + I_s
I_d = feval(AuthorYEAR, I);
I_s = my_clip(I-I_d, 0, 1);

I_d_m_1 = I_d;
% I_d_init = I_d; % %DEBUGVAR%

% Table 1
omega = 0.3;
k = 10;
epsilon = 0.2; % RMSE convergence criteria
iter_count = uint8(0);
max_iter_count = uint8(5);

H_low = fspecial('average', 3);
H_h_emph = -k * H_low;
H_h_emph(2, 2) = 1 + k - k * H_low(2, 2);
Theta = my_clip(imfilter(I, H_h_emph, 'symmetric'), 0, 1);

while true
    Upsilon_d = my_clip(imfilter(I_d, H_h_emph, 'symmetric'), 0, 1);
    Upsilon_s = my_clip(imfilter(I_s, H_h_emph, 'symmetric'), 0, 1);
    Upsilon = my_clip(Upsilon_d+Upsilon_s, 0, 1);

    err_diff = sum(double(Upsilon_d > Theta), 3) >= 3; % 1

    counts = imhist(I_s(:, :, 1));
    I_s_bin = im2bw(I_s, otsuthresh(counts)); %#ok
    N_s = nnz(I_s_bin);
    if N_s == 0
        break
    end
    N_s = 2 * ceil(sqrt(N_s)/2) + 1;
    % N_s = 3;
    center = floor(([N_s, N_s] + 1)/2);

    [row, col] = ind2sub(size(err_diff), find(err_diff));

    offset_r = center(1) - 1;
    offset_c = center(2) - 1;

    for ind = 1:nnz(err_diff)
        nh_r = max(1, row(ind)-offset_r):min(row(ind)+offset_r, n_row);
        nh_c = max(1, col(ind)-offset_c):min(col(ind)+offset_c, n_col);

        nh_I = reshape(I(nh_r, nh_c, :), [], 3);
        nh_Theta = reshape(Theta(nh_r, nh_c, :), [], 3);
        nh_Upsilon = reshape(Upsilon(nh_r, nh_c, :), [], 3);

        center_p = reshape(I(row(ind), col(ind), :), [], 3);

        Phi_I = sum((center_p - nh_I).^2, 2);
        Phi_Th_Up = sum((nh_Theta - nh_Upsilon).^2, 2);

        Phi = omega * Phi_I + (1 - omega) * Phi_Th_Up;

        [~, plausible] = min(Phi(:));
        [p_row, p_col] = ind2sub([length(nh_r), length(nh_c)], plausible);

        I_d(row(ind), col(ind), :) = ...
            I_d_m_1(nh_r(p_row), ...
            nh_c(p_col), :);
    end

    iter_count = iter_count + 1;

    I_s = my_clip(I-I_d, 0, 1);

    if sqrt(immse(I_d, I_d_m_1)) < epsilon || ...
            iter_count >= max_iter_count
        break
    end

    I_d_m_1 = I_d;
end

% figure(1), imshow([I_d_init, I_d])
% figure(2), imshow(10*abs(I_d-I_d_init))

end
