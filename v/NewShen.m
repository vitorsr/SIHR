%% Import images
fname = {...
    ...%   (1)        (2)         (3)          (4)
    'animals.bmp','cups.bmp','fruit.bmp','masks.bmp',...
    ...%  (5)        (6)        (7)        (8)        (9)         (10)
    'circle.ppm','fish.ppm','head.ppm','pear.ppm','toys.ppm','synth.ppm',...
    ...%(11)         (12)        (13)             (14)       (15)
    'lady.bmp','rabbit.bmp','train.bmp','watermelon.bmp','wood.bmp'...
    };

gt = {...
    ...%      (1)           (2)            (3)            (4)
    'animals_gt.bmp','cups_gt.bmp','fruit_gt.bmp','masks_gt.bmp'...
    };
%%
% V1 = imresize(im2double(imread(fname{4})),[NaN 200]);
% V2 = im2double(imread(fname{10}));
% Vycc1 = rgb2ycbcr(V1);
% Vycc2 = rgb2ycbcr(V2);
% [y1,cb1,cr1] = imsplit(Vycc1);
% [y2,cb2,cr2] = imsplit(Vycc2);
% figure(1)
% imshow([V1 repmat([y1 cb1 cr1],[1 1 3]);
%     V2 repmat([y2 cb2 cr2],[1 1 3])])
%% Approach 1: not final either
num = [4 2 3 1];
for idx = 1:4
    img = num(idx);
    ref = imresize(im2double(imread(fname{img})),1);
    gnd = imresize(im2double(imread(   gt{img})),1);
    V = ref;
    
    counter = uint8(0);
    while true
        [nRow,nCol,~] = size(V);
        Vmsf = getMsf(V);
        [Y,Cb,Cr] = imsplit(rgb2ycbcr(V)); % reshape(,[numel(V)/3 1 3])
        [dY,dCb,dCr] = imsplit(rgb2ycbcr(Vmsf)); % reshape(,[numel(V)/3 1 3])
        % [sCb,iCb] = sort(Cb);
        % [sCr,iCr] = sort(Cr);
        diffCddts = ~imbinarize(max(getCandidates(V,Vmsf),[],3));
        Ydiff = Y(diffCddts);
        if isempty(Ydiff)
            break
        end
        % Ydiff = (Ydiff-min(Ydiff(:)))/range(Y(:));
        dY = dY - min(dY(:)) + min(Y(:));
        in = [min(dY(:)); max(dY(:))];
        out= [min(Ydiff(:)); max(Ydiff(:))];
        gamma = mean2(dY(:))/mean2(Y(:));
        dYadj = reshape(imadjust(dY(:),in,out,gamma),nRow,nCol);
        
        Vnew = ycbcr2rgb(cat(3,dYadj,dCb,dCr));
        Vresidual = min(Saturate(V-Vnew),[],3);
        if range(Vresidual(:)) <= 0.03
            break
        end
        V = V - Vresidual;
        counter = counter + 1;
    end
    % figure(img)
    subplot(4,1,idx), Show.Difference(V,gnd),...
        title(['PSNR = ' num2str(psnr(V,gnd))])
end
% figure(2)
% scatter3(Y(:),Cb(:),Cr(:),'r.')
% hold on
% scatter3(dY(:),dCb(:),dCr(:),'k.')
% scatter3(dYadj(:),Cb(:),Cr(:),'b.')
% hold off
% xlabel('Y'), ylabel('Cb'), zlabel('Cr')
% legend({'Y','dark Y','adj. dark Y'})
% axis tight, grid minor
% view([60 60])
%%
img = 3;
V = im2double(imread(fname{img}));
G = im2double(imread(   gt{img}));
[nRow,nCol,~] = size(V);
tic
loV = imresize(V,[7 7],'Method','bilinear','AntiAliasing',true);
Vavg = imresize(loV,[nRow,nCol],'Method','bilinear','AntiAliasing',false);
pSpec = min(Saturate(V-min(Vavg,[],3)),[],3);
pSfi = V-pSpec;
toc
Vmsf = getMsf(V);
subplot(311), Show.Difference(pSfi,V-min(V,[],3),2), title('SF v. PSFI')
subplot(312), Show.Difference(pSfi,Vmsf,2), title('MSF v. PSFI')
subplot(313), Show.Difference(pSfi,G,2), title('GT v. PSFI')
%% Approach 2: final (beats SOA except for fruits)
% clearvars -except fname gt
V = im2double(imread(fname{3}));
% G = im2double(imread(   gt{3}));
[nRow,nCol,~] = size(V);
s1 = 1; s2 = 2/3; aa = true; hm = 'polynomial'; % 'polynomial'
loV = imresize(V,s1,...
    'Method','bilinear','AntiAliasing',aa);
loLoV = imresize(loV,s2,...
    'Method','bilinear','AntiAliasing',aa);
loVdiff = loV;
loVYcc = rgb2ycbcr(loV);
loVY = loVYcc(:,:,1);
loLoVY = imresize(loVY,s2,...
    'Method','bilinear','AntiAliasing',aa);
loLoSatMask = getSatMask(V,s1,s2); % add satMaskValid flag
% figure(1), imshow(loLoSatMask)
count = uint8(0);
while true
    loVsfYcc = rgb2ycbcr(...
        loVdiff-min(loVdiff,[],3));
    loVsfY = loVsfYcc(:,:,1);
    loLoYmatch = imhistmatch(...
        imresize(loVsfY,s2,...
        'Method','bilinear','AntiAliasing',aa),...
        loLoVY,...
        'Method',hm);
    loLoYmatch = loLoSatMask.*loLoVY + (1-loLoSatMask).*loLoYmatch;
    loYmatch = imresize(loLoYmatch,...
        [size(loV,1) size(loV,2)],...
        'Method','bilinear','AntiAliasing',aa);
    loVmatch = ycbcr2rgb(cat(3,loYmatch,loVsfYcc(:,:,2),loVsfYcc(:,:,3)));
    loResidual = min(1,max(0,loVdiff-loVmatch));
    if range(loResidual(:)) <= 1e-4 || count >= 8
        break
    else     
        loVdiff = loVdiff - loResidual;
        count = count + 1;
    end
end
Vdiff = imresize(loVdiff,[nRow nCol],...
    'Method','bilinear','AntiAliasing',aa);
spec = min(1,max(0,min(V - Vdiff,[],3)));
Vsfi = V - spec;

figure(2)
% subplot(211),...
Show.Difference(Vsfi,V,4)
% subplot(212),...
% Show.Difference(Vsfi,G,4)

%% Approach 4: DCP (??)
src = im2double(imread('masks.bmp'));
gt = im2double(imread('masks_gt.bmp'));
[nRow,nCol,nCh] = size(src);
loRes = imresize(src,2/3,'Method','bilinear'); %,'AntiAliasing',false
dstF = zeros(size(loRes));
SIGMAS = 5; SIGMAR = 0.1; SZ = 2*ceil(2*SIGMAS)+1;
count = uint8(0);
while true
    loGuide = loRes-min(loRes,[],3);
    loGuide = loGuide/max(loGuide(:));
    for iCh = 1:nCh
        dstF(:,:,iCh) = im2double(bfilter2(loRes(:,:,iCh),loGuide(:,:,iCh),...
            SZ,SIGMAS,SIGMAR)); % imguidedfilter ?
    end
    loResMin = min(1,max(0,min(loRes-dstF,[],3)));
    if range(loResMin(:)) <= 0.02 || count >= 4
        break
    end
    loRes = loRes-loResMin;
    count = count + 1;
end
% figure(2)
% subplot(2,1,1), Show.Difference(dstF,loRes,4)
dstMin = imresize(loRes,[nRow,nCol],'Method','bilinear');
dst = src-min(1,max(0,min(src-dstMin,[],3)));
% subplot(2,1,2),...
    Show.Difference(dst,gt,4)


%% Functions

function Vmsf = getMsf(V)
%% Generate MSF
% Vmsf = getMsf(V);
Vmin = min(V,[],3);
eta = 0.5;
Tv = (mean2(Vmin(:)) + eta*std(Vmin(:)));
tau = Vmin;
tau(tau>Tv) = Tv;
Vmsf = V - Vmin + tau;
end

function cddts = getCandidates(V,Vmsf)
%% Get candidates
% cddts = getCandidates(V,Vmsf);
Vmin = min(V,[],3);
th1 = mean2(Vmin(:));
cddts = ones(size(V));
cddts((V-Vmsf)<th1) = 1e-3;
end

function mask = maskAndDilateCddts(cddts,sz)
%% Get cddts mask
% mask = maskAndDilateCddts(cddts,sz);
se = offsetstrel('ball',sz,1);
mask = imdilate(cddts,se);
mask = histeq(mask-min(mask(:)));
mask = (mask-min(mask(:)))/range(mask(:));
end

%%
function loLoSatMask = getSatMask(V,s1,s2)
Vmax = max(V,[],3);
Vmin = min(V,[],3);
%
num = Vmin;
den = sum(V,3);
den(den==0) = 1e-3;
sat = min(1,max(0,1-3.*num./den));
% sat = histeq(sat);
%
satMask = imdilate(...
    (1-sat).^4,...
    strel('diamond',1));

loLoSatMask = imresize(...
    satMask,s1*s2,...
    'Method','bilinear','AntiAliasing',false);
end

% function vHp = FourierHighpass(v,s)
% [nRow,nCol,~] = size(v);
% 
% loV = imresize(v,s,...
%     'Method','bilinear','AntiAliasing',true);
% LoV = fft2(loV);
% LoVabs = abs(LoV);
% LoVang = angle(LoV);
% 
% loVmin = min(loV,[],3);
% LoVmin = fft2(loVmin);
% LoVminEnergy = sum(abs(LoVmin(:)).^2);
% 
% h = repmat(double(...
%     hpfilter('btw',size(Vmin,1),size(Vmin,2),...
%     ceil(min(size(Vmin,1),size(Vmin,2))/100),1)...
%     ),[1 1 3]);
% 
% while true
%     LoVlpAbs = h.*LoVabs;
%     LoVlpEnergy = sum(LoVlpAbs(:).^2);
%     if LoVlpEnergy > LoVminEnergy
%         break
%     end
% end
% loVlp = ifft2(LoVlpAbs.*exp(1i*LoVang));
% vLp = imresize(loVlp,[nRow,nCol],...
%     'Method','bilinear','AntiAliasing',true);
% vHp = min(1,max(0,v-vLp));
% end
%%
% function thr = getSatThr(sat,eta)
% hst = imhist(sat)/numel(sat);
% cdf = cumsum(hst);
% ind = find(cdf>=0.25,1);
% val = (ind-1)/255; % normalize to 1
% thr = mean2(sat(sat<val)) - eta*std(sat(sat<val));
% thr = min(1,max(4e-2,thr));
% end
