function I_d = Shen2009(I)
%Shen2009 I_d = Shen2009(I)
%  This implementation was at one point distributed by the author as a
%  script. It was modified in order to conform with the toolbox and was
%  incorporated for completion.
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

% Code for the following paper:
% H. L. Shen, H. G. Zhang, S. J. Shao, and J. H. Xin, 
% Simple and Efficient Method for Specularity Removal in an Image, 

% clear; close all;

% threshold_chroma = 0.03;
nu = 0.5;

% I = imread('images\4k.bmp');
% I = double(I);
[height, width, dim] = size(I);

I3c = reshape(I, height*width, 3);
% tic;
% calculate specular-free image
Imin = min(I3c, [], 2);
% Imax = max(I3c, [], 2);
Ithresh = mean(Imin) + nu * std(Imin);
% Iss = I3c - repmat(Imin, 1, 3) .* (Imin > Ithresh) + Ithresh * (Imin > Ithresh);

% calculate specular component
IBeta = (Imin - Ithresh) .* (Imin > Ithresh) + 0;

% estimate largest region of highlight
IHighlight = reshape(IBeta, height, width, 1);
IHighlight = mat2gray(IHighlight);
IHighlight = im2bw(IHighlight, 0.1);
IDominantRegion = bwareafilt(IHighlight, 1, 'largest');

% dilate largest region by 5 pixels to obtain its surrounding region
se = strel('square',5);
ISurroundingRegion = imdilate(IDominantRegion, se);
ISurroundingRegion = logical(imabsdiff(ISurroundingRegion, IDominantRegion));

% Solve least squares problem
Vdom = mean(I3c(IDominantRegion, :));
Vsur = mean(I3c(ISurroundingRegion, :));
Betadom = mean(IBeta(IDominantRegion, :));
Betasur = mean(IBeta(ISurroundingRegion, :));
k = (Vsur - Vdom)/(Betasur - Betadom);

% Estimate diffuse and specular components
I_d = reshape(I3c - min(k) * IBeta, height, width, dim);

%figure; imshow(uint8(reshape(I3c, height, width, dim))); title('original'); 
%figure; imshow(uint8(reshape(Idf, height, width, dim))); title('diffuse component');
%figure; imshow(uint8(reshape(Isp, height, width, dim))); title('specular component');


%imwrite(uint8(reshape(Idf, height, width, dim)), 'comp_df.bmp', 'bmp');
%imwrite(uint8(reshape(Isp, height, width, dim)), 'comp_sp.bmp', 'bmp');
% toc;

end
