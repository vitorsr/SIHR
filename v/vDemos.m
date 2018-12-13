%% Methods based on space transformation
%%
imInt = imread('img\toys.ppm');
imDbl = im2double(imInt);
%% Naïve T-space median filtering
%%
clearvars -except imDbl
imT = TSpace(imDbl,'fwd');
sz = 7;
imT(:,:,2) = medfilt2(imT(:,:,2),[sz sz],'symmetric');
imT(:,:,3) = medfilt2(imT(:,:,3),[sz sz],'symmetric');
imNew = TSpace(imT,'rev');
ShowDifference(imNew,imDbl)
%% ROI-based segmentation and modified Shafer space
%%
clearvars -except imDbl
mask = GrowHighlightMask(imDbl);
mask = boolean(max(mask,[],3));
stats = regionprops('table',mask,'Centroid','MajorAxisLength');
diameters = stats.MajorAxisLength;
pad = ceil(max(diameters));
imProc = padarray(imDbl,[pad pad],'symmetric');
nCtds = size(stats,1);
for iCtd = 1:nCtds
    coord = round(stats.Centroid(iCtd,:));
    diam = stats.MajorAxisLength(iCtd);
    radius = ceil(diam/2);
    se = strel('disk',radius).Neighborhood;
    orig = floor((size(se)+1)/2); % roi center (row,col)
    r1 = coord(2) - orig(1) + 1 + pad;
    c1 = coord(1) - orig(2) + 1 + pad;
    r2 = r1 + size(se,1) - 1;
    c2 = c1 + size(se,2) - 1;
    crop = imProc(r1:r2,c1:c2,:);
    ref = GetNewShaferRef(crop);
    [imT,T] = NewShaferSpace(ref,crop,'fwd');
    imT(:,:,2) = 0;
    newCrop = NewShaferSpace(T,imT,'rev');
    imProc(r1:r2,c1:c2,:) = se.*newCrop + ~se.*imProc(r1:r2,c1:c2,:);
end
imNew = imProc(1+pad:size(imProc,1)-pad,1+pad:size(imProc,2)-pad,:);
imNew = min(imNew,imDbl);
ShowDifference(imNew,imDbl)
DrawHist(imNew,imDbl,[0.7 1])
%% Compact ROI complete image transformation
%%
clearvars -except imDbl
se = strel('rectangle',[5 5]).Neighborhood;
orig = [3 3];
pad = 2;
imNew = imDbl;
nRe = 2;
for iRe = 1:nRe
    disp(['Iteration #' num2str(iRe)])
    imProc = padarray(imNew,[pad pad],'symmetric','both');
    nRows = size(imProc,1);
    nCols = size(imProc,2);
    for iRow = 1+pad:nRows-pad
        for iCol = 1+pad:nCols-pad
            r1 = iRow - orig(1) + 1;
            c1 = iCol - orig(2) + 1;
            r2 = r1 + size(se,1) - 1;
            c2 = c1 + size(se,2) - 1;
            roi = imProc(r1:r2,c1:c2,:);
            [~,s] = imsplit(rgb2hsv(roi(orig(1),orig(2),:)));
            if s<0.2
                imNew(iRow-pad,iCol-pad,:) = 254/255*roi(orig(1),orig(2),:);
                continue
            end
            ref = roi;
            [roi,T] = NewShaferSpace(ref,roi,'fwd');
            roi(:,:,2) = 0; % illuminant plane
            roi = NewShaferSpace(T,roi,'rev');
            imNew(iRow-pad,iCol-pad,:) = min(1,max(0,roi(orig(1),orig(2),:)));
        end
    end
end
dr = 157:157+74;
dc = 98:98+88;
ShowDifference(imNew(dr,dc,:),imDbl(dr,dc,:))
ShowDifference(imNew,imDbl)
DrawHist(imNew,imDbl,[0.7 1])
%% Methods based on frequency content
%%
imInt = imread('img\toys.ppm');
imDbl = im2double(imInt);
%% Subtration of magnitude Fourier coefficients from highlight mask
%%
clearvars -except imDbl
[~,mask] = GetScaledMask(imDbl);
%%
Mask = fft2(mask);
MaskAbs = abs(Mask);
MaskAbs(abs(MaskAbs)<(mean(MaskAbs)+3*std(MaskAbs))) = 0;
ImDbl = fft2(imDbl);
ImAng = angle(ImDbl);
ImAbs = abs(ImDbl) - 1*MaskAbs;
imNew = real(ifft2(ImAbs.*exp(1i*ImAng)));
ShowDifference(imNew,imDbl)
DrawHist(imNew,imDbl,[0.7 1])
%% Attenuation of coefficients based on high-energy highlight mask
%%
Mask = fft2(mask);
MaskAbs = abs(Mask);
idx = find(abs(MaskAbs)>(mean(MaskAbs)+3*std(MaskAbs)));
ImDbl = fft2(imDbl);
ImAng = angle(ImDbl);
ImAbs = abs(ImDbl);
ImAbs(idx) = 0.9*ImAbs(idx); % mix: 0.94
imNew = real(ifft2(ImAbs.*exp(1i*ImAng)));
ShowDifference(imNew,imDbl)
DrawHist(imNew,imDbl,[0.7 1])
%% Wavelet
%% Subtration of decomposition coefficients from highlight mask
%%
clearvars -except imDbl
imNorm = imDbl-min(imDbl(:));
imNorm = imNorm/max(imNorm(:));
[~,mask] = GetScaledMask(imNorm);
mask = repmat(min(mask,[],3),[1 1 3]);
%%
wname = 'bior3.5';%'haar';
level = wmaxlev(size(imDbl),wname);
[C,S] = wavedec2(imDbl,level,wname);
[CH,SH] = wavedec2(mask,level,wname);
THR = wthrmngr('dw2ddenoLVL','sqtwolog',CH,SH,'mln');
[~,CXC,~] = wdencmp('lvd',CH,SH,wname,level,THR,'s');
C = C - 0.5*CXC; % mix: 0.16
imNew = waverec2(C,S,wname);
ShowDifference(imNew,imDbl)
DrawHist(imNew,imDbl,[0.7 1])
%% Attenuation of coefficients based on high-energy highlight mask
%%
[C,S] = wavedec2(imDbl,level,wname);
[CH,SH] = wavedec2(mask,level,wname);
idx = find(abs(CH)>(mean(CH)+3*std(CH)));
C(idx) = 0.9*C(idx); % mix: 0.9
imNew = waverec2(C,S,wname);
ShowDifference(imNew,imDbl)
DrawHist(imNew,imDbl,[0.7 1])
%% Methods based on interpolation
%% Using highlight mask as criteria
%%