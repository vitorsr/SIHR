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
V1 = im2double(imread(fname{10}));
V2 = imresize(im2double(imread(fname{4})),[NaN 200]);
Vycc1 = rgb2ycbcr(V1);
Vycc2 = rgb2ycbcr(V2);
[y1,cb1,cr1] = imsplit(Vycc1);
[y2,cb2,cr2] = imsplit(Vycc2);
figure(1)
imshow([V1 repmat([y1 cb1 cr1],[1 1 3]);
    V2 repmat([y2 cb2 cr2],[1 1 3])])
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
        Vmin = min(V,[],3);
        Vsf = V - Saturate(Vmin-mean2(Vmin(:)));
        Vmsf = V - Vmin + mean2(Vmin(:));
        [Y,Cb,Cr] = imsplit(rgb2ycbcr(V)); % reshape(,[numel(V)/3 1 3])
        [dY,dCb,dCr] = imsplit(rgb2ycbcr(Vsf)); % reshape(,[numel(V)/3 1 3])
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
        if range(Vresidual(:)) <= 0.03 || counter >= 4
            break
        end
        V = V - Vresidual;
        counter = counter + 1;
    end
    % figure(img)
    subplot(4,1,idx), Show.Difference(V,gnd),...
        title(['PSNR = ' num2str(psnr(V,gnd))])
end
%%
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
%% Approach 2: final (beats SOA except for fruits)
clearvars -except fname gt
% PSNR = zeros([255 4]);
% for img = 1:4
    V = im2double(imread(fname{img}));
    G = im2double(imread(   gt{img}));
%     for bin = 2:256
        [nRow,nCol,~] = size(V);
        Vsfi = V;
        VYcc = rgb2ycbcr(V);
        VY = VYcc(:,:,1);
        % VsatMask = getSatMask(V,1,1); % add VsatMaskValid flag
        % figure(1), imshow(VsatMask)
        VsfiMin = min(Vsfi,[],3);
        VsfYcc = rgb2ycbcr(...
            Vsfi - VsfiMin);
        VsfY = VsfYcc(:,:,1);
        Ymatch = imhistmatch(VsfY,VY,bin,'Method','polynomial');
        % Ymatch = VsatMask.*VY + (1-VsatMask).*Ymatch;
        Vmatch = ycbcr2rgb(cat(3,Ymatch,VYcc(:,:,2),VYcc(:,:,3)));
        residual = min(1,max(0,Vsfi-Vmatch));
        Vsfi = Vsfi - residual;
        spec = min(1,max(0,min(V - Vsfi,[],3)));
        Vdiff = V - spec;
%         PSNR(bin-1,img) = psnr(Vdiff,G);
%     end
% end
% % % % % % plot
% figure(2)
% subplot(211),...
% Show.Difference(Vsfi,V,4)
% subplot(212),...
% Show.Difference(Vdiff,G,4)
plot(2:256,PSNR), axis tight, grid minor,...
    legend({'Animals','Crups','Fruit','Masks'},'Location','southeast')
%%
t = [];
PSNR = zeros([80 4]);
for img = 1:4
V = im2double(imread(fname{img}));
G = im2double(imread(   gt{img}));
for idx = 1:80
    Vavg = imgaussfilt(V,idx,'Padding','symmetric');
    pSpec = min(Saturate(V-min(Vavg,[],3)),[],3);
    pSfi = V-pSpec;
    PSNR(idx,img) = psnr(pSfi,G);
end
end
subplot(211), plot(1:80,PSNR), axis tight, grid minor,...
    legend({'Animals','Crups','Fruit','Masks'},'Location','southeast')
subplot(212), plot(2:80,diff(PSNR)), axis tight, grid minor
% Vmsf = getMsf(V);
% subplot(311), Show.Difference(pSfi,V-min(V,[],3),2), title('SF v. PSFI')
% subplot(312), Show.Difference(pSfi,Vmsf,2), title('MSF v. PSFI')
% subplot(313), Show.Difference(pSfi,G,2), title('GT v. PSFI')

%%
V = im2double(imread(fname{11}));
Vcorr = V;
Vest = V;
count = uint8(0);
while true
    Vmsf = getMsf(V);
    cddts = getCandidates(V,Vmsf);
    m = maskAndDilateCddts(cddts,10);
    cddts = imbinarize(cddts);
    A = V;
    A(cddts) = 0;
    h = fspecial('gaussian',2*ceil(2*5)+1,5);
    est = imfilter(V.*(1-m),h)./imfilter(1-m,h);
    valid = ~isnan(est);
    Vcorr(valid) = V(valid).*(1-m(valid)) + est(valid).*m(valid);
    Vest(valid) = V(valid)-Saturate(min(V(valid)-min(Vcorr(valid),[],3),[],3));
    if nnz(isnan(est)) < 1 || count >= 4
        break
    end
    count = count + 1;
end
figure, imshow(est)
Show.Difference(Vest,V)
%%
V = im2double(imread(fname{2}));
G = im2double(imread(   gt{2}));
Vin255  =  255*V;
% filter parameters
sigmaS = 32;
sigmaR = 64;
% call bilateral filter
Vout255 = zeros(size(Vin255));
for c = 1:3
     Vout255(:,:,c) = shiftableBF(Vin255(:,:,c),sigmaS,sigmaR);
end
pSpec = min(Saturate(V-min(Vout255/255,[],3)),[],3);
pSfi = V-pSpec;
% figure(1), imshow(pSfi)
figure(2), imshow(pSpec)
figure(3), imshow(Vout255/255)
figure(4), Show.Difference(pSfi,G,4)

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
cddts((V-Vmsf)<th1) = 0;
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
Vmin = min(V,[],3);
%
num = Vmin;
den = sum(V,3);
den(den==0) = 1e-3;
sat = min(1,max(0,1-3.*num./den));
sat(Vmin<=mean2(Vmin(:))) = 1;
%
satMask = imdilate(...
    (1-sat).^4,...
    strel('diamond',1));

loLoSatMask = imresize(...
    satMask,s1*s2,...
    'Method','bilinear','AntiAliasing',false);
end

function Vdith = normalDither(V)
Vdith = Saturate(V+randn(size(V))/255);
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
