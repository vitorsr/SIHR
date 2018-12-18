%% Methods based on space transformation
%%
imInt = imread('img\toys.ppm');
imDbl = im2double(imInt);
%% ROI-based segmentation and modified Shafer space
%%
clearvars -except imDbl
mask = Mask.GrowHighlights(imDbl);
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
figure(1), Show.Difference(imNew,imDbl)
figure(2), Show.HistPair(imNew,imDbl,[0.7 1])
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
figure(1), Show.Difference(imNew(dr,dc,:),imDbl(dr,dc,:))
figure(2), Show.Difference(imNew,imDbl)
figure(3), Show.HistPair(imNew,imDbl,[0.7 1])

