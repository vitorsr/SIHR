function I_d = Shen2009(I)
%Shen2009 I_d = Shen2009(I)
%  This method works by finding the largest highlight area, dilating it to
%  find the surrounding region, and then finding a coefficient that scales
%  how much the pseudo specular component will be subtracted from the
%  original image to find I_d.
%
%  The nomenclature is in accordance with the corresponding paper with
%  exception of using I* instead of V* to denote an image.
%
%  See also SIHR, Shen2008, Shen2013.

assert(isa(I, 'float'), 'SIHR:I:notTypeSingleNorDouble', ...
    'Input I is not type single nor double.')
assert(min(I(:)) >= 0 && max(I(:)) <= 1, 'SIHR:I:notWithinRange', ...
    'Input I is not within [0, 1] range.')
[n_row, n_col, n_ch] = size(I);
assert(n_row > 1 && n_col > 1, 'SIHR:I:singletonDimension', ...
    'Input I has a singleton dimension.')
assert(n_ch == 3, 'SIHR:I:notRGB', ...
    'Input I is not a RGB image.')

nu = 0.5;

I = reshape(I, n_row*n_col, 3);

% Calculate specular-free image
I_min = min(I, [], 2);
T_v = mean(I_min) + nu * std(I_min);
% I_MSF = I - repmat(I_min, 1, 3) .* (I_min > T_v) + T_v * (I_min > T_v);

% Calculate specular component
beta_s = (I_min - T_v) .* (I_min > T_v) + 0;

% Estimate largest region of highlight
IHighlight = reshape(beta_s, n_row, n_col, 1);
IHighlight = mat2gray(IHighlight);
IHighlight = im2bw(IHighlight, 0.1); %#ok
IDominantRegion = bwareafilt(IHighlight, 1, 'largest');

% Dilate largest region by 5 pixels to obtain its surrounding region
se = strel('square', 5);
ISurroundingRegion = imdilate(IDominantRegion, se);
ISurroundingRegion = logical(imabsdiff(ISurroundingRegion, IDominantRegion));

% Solve least squares problem
I_dom = mean(I(IDominantRegion, :));
I_sur = mean(I(ISurroundingRegion, :));
beta_dom = mean(beta_s(IDominantRegion, :));
beta_sur = mean(beta_s(ISurroundingRegion, :));
k = (I_dom - I_sur) / (beta_dom - beta_sur);

% Estimate diffuse and specular components
I_d = reshape(I-min(k)*beta_s, n_row, n_col, n_ch);

end
