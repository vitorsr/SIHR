function imFilt = SpatialHighpass(imDbl)
%SPATIALHIGHPASS Average complement highpass filter
%   imFilt = SpatialHighpass(imDbl) returns filtered image.
%
%   See also: fspecial imfilter
nRows = size(imDbl,1);
nCols = size(imDbl,2);
hsize = fix(min(nRows,nCols)/32)*2+1; % 1/16 factor obtained experimentally
imFilt = imDbl-imfilter(imDbl,fspecial('average',hsize),'symmetric');
imFilt = min(1,(max(0,imFilt)));
end

