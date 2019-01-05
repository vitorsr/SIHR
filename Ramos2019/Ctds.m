%% Methods based on space transformation

clearvars
fname = {'blue.jpg','fish.ppm','green.jpg','head.ppm','mix.jpg',...
    'plastic.jpg','red.jpg','toys.ppm'};
nFiles = length(fname);
for iFile = 1:nFiles
    src{iFile} = im2double(imresize(imread(fname{iFile}),[256 NaN],'lanczos3'));
end
%% ROI-based segmentation and modified Shafer space
%%
imDbl = src{5};
vsep = repmat(ones([size(imDbl,1) 1]),[1 1 3]);
%%
nc = Mask.NearClip(imDbl);
nc = logical(max(nc,[],3));
stats = regionprops('table',nc,'Centroid',...
    'MajorAxisLength');
centers = stats.Centroid;
diameters = stats.MajorAxisLength;
radii = ceil(diameters/2);
imshow([imDbl vsep repmat(min(imDbl,[],3),[1 1 3])])
hold on
viscircles(centers,radii);
viscircles(centers + [size(imDbl,1)+1,0],radii);
title(['Location of near-clip centroids on:' newline...
    '(a) Reference, (b) Specular-invariant mask'])
hold off
%%
clearvars -except fname src nFiles
radii = [];
for iFile = 1:nFiles
    nc{iFile} = Mask.NearClip(src{iFile});
    nc{iFile} = logical(max(nc{iFile},[],3));
    stats{iFile} = regionprops('table',nc{iFile},'Centroid',...
        'MajorAxisLength');
    centers{iFile} = stats{iFile}.Centroid;
    diameters{iFile} = stats{iFile}.MajorAxisLength;
    radii = [radii; diameters{iFile}/2];
end
%%
r2db = radii;
r2db(r2db<1) = 1;
r2db = 1.4427*log(r2db); % inv: exp(val/1.4427)
subplot(2,1,1)
histogram(radii), axis tight, grid minor
xline(mean(radii),'r-.','LineWidth',4);
xline(mean(radii)+std(radii),'r-.','LineWidth',3);
xline(mean(radii)+2*std(radii),'r-.','LineWidth',2);
xline(mean(radii)+3*std(radii),'r-.','LineWidth',2);
title('Radii distribution')
legend({'Radii','\mu','\mu+\sigma','\mu+2\sigma','\mu+3\sigma'},'EdgeColor','w')
subplot(2,1,2)
histogram(r2db), axis tight, grid minor
xline(mean(r2db),'r-.','LineWidth',4);
xline(mean(r2db)+std(r2db),'r-.','LineWidth',3);
xline(mean(r2db)+2*std(r2db),'r-.','LineWidth',2);
xline(mean(r2db)+3*std(r2db),'r-.','LineWidth',1);
title('In natural logarithm scale')
legend({'Radii (dB)','\mu','\mu+\sigma','\mu+2\sigma','\mu+3\sigma'},'EdgeColor','w')
%%
clearvars
%%
imDbl = im2double(imresize(imread('mix.jpg'),[NaN 256],'lanczos3'));
[~,s] = imsplit(rgb2hsv(imDbl));
nc = max(Mask.NearClip(imDbl),[],3);
m = CtdMin(imDbl);
imshow([m,s,nc])
title('(a) Minimum values between channels, (b) Saturation (c) Near-clip')
hst = imhist(s)/numel(s);
cdf = cumsum(hst);
q1 = (find(cdf>=0.25,1)-1)/255;
mu = mean2(s(s<q1));
sigma = std(s(s<q1));
thr = max(0.051,mu-sigma)
%%
vsep = repmat(ones([size(imDbl,1) 1]),[1 1 3]);
sfi = imDbl - m;
imshow([imDbl sfi])
title('(a) Reference, (b) Specular-free image')
sfi = padarray(sfi,[1 1],'symmetric','post');
drgbx = log(255*abs(sfi(1:end-1,1:end-1,:)-sfi(1:end-1,2:end,:)));
drgby = log(255*abs(sfi(1:end-1,1:end-1,:)-sfi(2:end,1:end-1,:)));
sfi = sfi(1:end-1,1:end-1,:);
m = padarray(m,[1 1],'symmetric','post');
dmx = log(255*repmat(abs(m(1:end-1,1:end-1,:)-m(1:end-1,2:end,:)),[1 1 3]));
dmy = log(255*repmat(abs(m(1:end-1,1:end-1,:)-m(2:end,1:end-1,:)),[1 1 3]));
m = m(1:end-1,1:end-1,:);
imshow([drgbx vsep drgby vsep sqrt(drgbx.^2+drgby.^2);...
        repmat(ones([1 3*size(sfi,2)+2]),[1 1 3]);
        dmx vsep dmy vsep sqrt(dmx.^2+dmy.^2)])
tmp = sqrt(dmx.^2+dmy.^2).*sqrt(drgbx.^2+drgby.^2);
imshow(tmp)
%%
clearvars
src = im2double(imresize(imread('mix.jpg'),[NaN 256],'lanczos3'));
cfi = src;
pmax = min(245/255,max(cfi(:)));
%             ^ 255/255 - cameraDark/255, cameraDark = 10
count = uint16(0);
while true
    [cfi,esc] = CtdIteration(src,cfi);
    cmax = max(cfi(:));
    count = count + 1;
    if esc || cmax < pmax || count > 4095
        break
    end
end
new = cfi;
Show.Difference(new,src)
Show.HistPair(new,src,[0.7 1])
%%
function [cfi,esc] = CtdIteration(src,cfi) % ,pcoord,pradii
[coord,radii] = CtdFind(cfi);
[coord,radii,esc] = CtdTrim(coord,radii); % ,pcoord,pradii
if esc
    return
end
pad = max(radii);
src = padarray(src,[pad pad],'symmetric');
cfi = padarray(cfi,[pad pad],'symmetric');
nCtds = size(coord,1);
for iCtd = 1:nCtds
    se = strel('disk',radii(iCtd)).Neighborhood;
    orig = floor((size(se)+1)/2); % roi center (row,col)
    r1 = coord(iCtd,2) - orig(1) + 1 + pad;
    c1 = coord(iCtd,1) - orig(2) + 1 + pad;
    r2 = r1 + size(se,1) - 1;
    c2 = c1 + size(se,2) - 1;
    crop = cfi(r1:r2,c1:c2,:);
    [~,s] = imsplit(rgb2hsv(src(r1:r2,c1:c2,:)));
    if min(s(:))<0.2
        %
        cfi(r1:r2,c1:c2,:) = se.*CtdSaturate(cfi(r1:r2,c1:c2,:)-1/255)+...
                            ~se.*cfi(r1:r2,c1:c2,:);
        %
        continue
    end
    ref = GetNewShaferRef(crop);
    [imT,T] = NewShaferSpace(ref,crop,'fwd');
    imT(:,:,2) = 0;
    newCrop = NewShaferSpace(T,imT,'rev');
    %
    cfi(r1:r2,c1:c2,:) = se.*CtdSaturate((0.5*newCrop + 0.5*cfi(r1:r2,c1:c2,:))-1/255)+...
                        ~se.*cfi(r1:r2,c1:c2,:);
    %
end
cfi = cfi(1+pad:size(cfi,1)-pad,1+pad:size(cfi,2)-pad,:);
end
%
%
function [coord,radii] = CtdFind(cfi)
nc = Mask.NearClip(cfi);
nc = logical(max(nc,[],3));
stats = regionprops('table',nc,'Centroid','MajorAxisLength');
coord = round(stats.Centroid);
diam = stats.MajorAxisLength;
radii = ceil(diam/2);
end
%
%
function [coord,radii,esc] = CtdTrim(coord,radii) % ,pcoord,pradii
% idx = radii<=median(radii)+1;
if ~isempty(coord) || ~isempty(radii) % nnz(idx)>0
    esc = false;
%     coord = coord(idx,:);
%     radii = radii(idx);
else
    esc = true;
end
end
%
%
function y = CtdSaturate(x)
y = min(1,max(0,x));
end
%
%
function m = CtdMin(x)
m = min(x,[],3);
end
