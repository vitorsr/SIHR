% '..\src\PR2008_code\watermelon.bmp'
% src = im2double(imread('..\src\PR2008_code\fruit.bmp'));
% dst = src;
%%
% while true
% dstMin = min(dst,[],3);
% lab = rgb2lab(dst);
% labMSF = rgb2lab(dst-dstMin+mean2(dstMin(:)));
%
% degreeOfSmoothing1 = 0.5*range(lab(:,:,1),'all')^2;
% degreeOfSmoothing2 = 0.5*range(labMSF(:,:,2),'all')^2;
% degreeOfSmoothing3 = 0.5*range(labMSF(:,:,3),'all')^2;
%
% labF = zeros(size(lab));
% labF(:,:,1) = imbilatfilt(lab(:,:,1),degreeOfSmoothing1,16);
% labF(:,:,2) = imbilatfilt(labMSF(:,:,2),degreeOfSmoothing2,16);
% labF(:,:,3) = imbilatfilt(labMSF(:,:,3),degreeOfSmoothing3,16);
%
% dstF = lab2rgb(labF);
% dstHP = min(1,max(0,dst-dstF));
% dark = min(dstHP,[],3);
%     if 0.1 > range(dark(:))
%         break
%     end
% dst = dst-dark;
% end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clearvars
src = im2double(imread('img\cups.bmp'));
% src = imresize(src,[256,NaN],'Method','bilinear');
[nRow,nCol,~] = size(src);
dst = padNextPow2(src,'symmetric');
count = uint8(0);
while true
    dstF = progMedFilt2(dst,4,[7 7]);
    %
    dstHPMin = min(min(1,max(0,dst-dstF)),[],3);
    %
    hsi = rgb2hsi(dst);
    hsiF = rgb2hsi(dstF);
    %
    hue = hsi(:,:,1);
    %
    num = min(dst,[],3)-dstHPMin;
    den = sum(dst,3);
    den(den==0) = 1e-3;
    sat = hsi(:,:,2)/2 + min(1,max(0,1-3.*num./den))/2;
    int = hsi(:,:,3)-dstHPMin;
    %
    dstT = hsi2rgb(cat(3,hue,sat,int));
    %
    dstMin = min(1,max(0,min(dst-dstT,[],3)));
    if range(dstMin(:)) <= 0.03 || count >= 4
        break
    end
    dst = dst-dstMin;
    count = count + 1;
end
dst = unPadNextPow2(dst,nRow,nCol);
subplot(2,1,1), ShowDifference(unPadNextPow2(dstF,nRow,nCol),src,4)
subplot(2,1,2), ShowDifference(dst,src,4), set(gcf,'Visible','on')
%%
% [a,b,c] = imsplit(hsi);
% [g,h,i] = imsplit(hsiF);
% imshow([a,b,c;hue,sat,int;g,h,i],[0 1])
%%
[nRow,nCol,nCh] = size(src);
dst = imresize(src,0.25,'Method','bilinear');
dstF = zeros(size(dst));
SIGMAS = 6; SIGMAR = 0.08; SZ = 2*ceil(2*SIGMAS)+1;
count = uint8(0);
while true
    aux = dst-min(dst,[],3);
    aux = aux/max(aux(:));
    for iCh = 1:nCh
        dstF(:,:,iCh) = im2double(bfilter2(dst(:,:,iCh),aux(:,:,iCh),...
            SZ,SIGMAS,SIGMAR));
    end
    tmpMin = min(1,max(0,min(dst-dstF,[],3)));
    if range(tmpMin(:)) <= 0.03 || count >= 4
        break
    end
    dst = dst-tmpMin;
    count = count + 1;
end
clf reset
subplot(2,1,1), ShowDifference(dstF,dst,4)
dstMin = imresize(dst,[nRow,nCol],'Method','bilinear');
sfi = src-min(1,max(0,min(src-dstMin,[],3)));
subplot(2,1,2), ShowDifference(sfi,src,4)
% aux = unPadNextPow2(24*hue,nRow,nCol);
% aux(aux>23) = 0;
% aux = aux+round(rand(size(aux)));
% aux = floor(aux)/24;
%%
function dstF = progMedFilt2(dst,lev,sz)
[nRow,nCol,nCh] = size(dst);         % 2 for synth
maxLev = nextpow2(min(nRow,nCol))-lev; % 1/2^(maxLev-1) = minimum scale
dstLev{1} = dst;
for iLev = 2:maxLev
    dstLev{iLev} = imresize(dstLev{iLev-1},0.5,...
        'Method','bilinear','AntiAliasing',false);
end
dstLevF = dstLev;
% roi = strel('disk',4,4).Neighborhood;
% med = ceil(nnz(roi)/2);
for iLev = 1:maxLev
    for iCh = 1:nCh
        dstLevF{iLev}(:,:,iCh) = ...
            medfilt2(dstLev{iLev}(:,:,iCh),sz,'symmetric');
        % ordfilt2(dstLev{iLev}(:,:,iCh),med,roi,'symmetric');
    end
end
for iLev = maxLev:-1:2
    dstLevF{iLev-1} = min(dstLevF{iLev-1},...
        imresize(dstLevF{iLev},...
        [size(dstLevF{iLev-1},1),size(dstLevF{iLev-1},2)],...
        'Method','bilinear','AntiAliasing',false));
end
dstF = min(1,max(0,dstLevF{1}));
end
function dst = padNextPow2(src,value)
[nRow,nCol,~] = size(src);
[prePadRow,prePadCol,postPadRow,postPadCol] =...
    getNextPow2PadVals(nRow,nCol);
dst = padarray(src,[prePadRow prePadCol],value,'pre');
dst = padarray(dst,[postPadRow postPadCol],value,'post');
end
function dst = unPadNextPow2(src,nRow,nCol)
[prePadRow,prePadCol,postPadRow,postPadCol] =...
    getNextPow2PadVals(nRow,nCol);
dst = src(1+prePadRow:end-postPadRow,1+prePadCol:end-postPadCol,:);
end
function [prePadRow,prePadCol,postPadRow,postPadCol] =...
    getNextPow2PadVals(nRow,nCol)
nRowNextPow2 = 2^nextpow2(nRow);
nColNextPow2 = 2^nextpow2(nCol);
prePadRow = floor((nRowNextPow2-nRow)/2);
prePadCol = floor((nColNextPow2-nCol)/2);
postPadRow = ceil((nRowNextPow2-nRow)/2);
postPadCol = ceil((nColNextPow2-nCol)/2);
end