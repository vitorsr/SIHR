function imFilt = MedianHighpass(imDbl)
%MEDIANHIGHPASS Median complement highpass filter
%   imFilt = MedianHighpass(imDbl) returns filtered image.
%
%   See also: medfilt2
imFilt = zeros(size(imDbl));
nRows = size(imDbl,1);
nCols = size(imDbl,2);
nCh   = size(imDbl,3);
hsize = fix(min(nRows,nCols)/20)*2+1; % 1/10 factor obtained experimentally
for iCh = 1:nCh
    imFilt(:,:,iCh) = medfilt2(imDbl(:,:,iCh),[hsize hsize],'symmetric');
end
imFilt = imDbl-imFilt;
imFilt = min(1,(max(0,imFilt)));
end

