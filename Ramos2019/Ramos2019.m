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
V1 = imresize(im2double(imread(fname{4})),[NaN 200]);
V2 = imresize(im2double(imread(fname{3})),[NaN 200]);
V3 = imresize(im2double(imread(fname{2})),[NaN 200]);
V4 = imresize(im2double(imread(fname{1})),[NaN 200]);
Vycc1 = rgb2ycbcr(V1);
Vycc2 = rgb2ycbcr(V2);
Vycc3 = rgb2ycbcr(V3);
Vycc4 = rgb2ycbcr(V4);
[y1,cb1,cr1] = imsplit(Vycc1);
[y2,cb2,cr2] = imsplit(Vycc2);
[y3,cb3,cr3] = imsplit(Vycc3);
[y4,cb4,cr4] = imsplit(Vycc4);

V1sf = V1-min(V1,[],3);
Vycc1sf = rgb2ycbcr(V1sf);
[y1sf,cb1sf,cr1sf] = imsplit(Vycc1sf);
figure(1)
imshow([V1 repmat([y1 cb1 cr1],[1 1 3]);
        V2 repmat([y2 cb2 cr2],[1 1 3])
        V3 repmat([y3 cb3 cr3],[1 1 3])
        V4 repmat([y4 cb4 cr4],[1 1 3])
        ])

figure(2)
imshow([V1   repmat([y1   cb1   cr1],  [1 1 3]);
        V1sf repmat([y1sf cb1sf cr1sf],[1 1 3]);
   abs([V1sf repmat([y1sf cb1sf cr1sf],[1 1 3])] - ...
       [V1   repmat([y1   cb1   cr1],  [1 1 3])])])
%%
imshow([V G abs(V-G); ones(size(V)) Vdiff abs(Vdiff-G)])
%%
[y1,cb1,cr1] = imsplit(imresize(Vycc1,0.2));
[y1sf,cb1sf,cr1sf] = imsplit(imresize(Vycc1sf,0.2));

figure(3)
scatter3(y1(:),cb1(:),cr1(:),'.')
hold on
scatter3(y1sf(:),cb1sf(:),cr1sf(:),'.')
hold off
xlabel('Y'), ylabel('Cb'), zlabel('Cr')
axis square tight, grid minor
legend({'\it V_{YCbCr}(x)','\it V_{YCbCr}^{sfi}(x)'},'Location','ne')
view([60 60])
%% Approach 2: final (beats SOA except for fruits)
clearvars -except fname gt
nIterBin = 1;
nIterEta = 51;
eta = linspace(0,5,nIterEta);
bin = round(linspace(256,256,nIterBin));
PSNR = zeros([nIterEta nIterBin 4]);
for img = 1:4
    V = im2double(imread(fname{img}));
    G = im2double(imread(   gt{img}));
    for iBin = 1:nIterBin
        for iEta = 1:nIterEta
            % [nRow,nCol,~] = size(V);
            VYcc = rgb2ycbcr(V);
            VY = VYcc(:,:,1);
            % VsatMask = getSatMask(V,1,1); % add VsatMaskValid flag
            % figure(1), imshow(VsatMask)
            Vmin = min(V,[],3);
            VsfYcc = rgb2ycbcr(V - Vmin);
            VsfY = VsfYcc(:,:,1);
            %
            th = mean2(Vmin(:)) + eta(iEta)*std(Vmin(:));
            diffCddts = Vmin<th;
            Ydiff = VY(diffCddts);
            %                                     bin(iBin)
            Ymatch = imhistmatch(VsfY,Ydiff,numel(unique(VsfY)),'Method','uniform');
            % Ymatch = VsatMask.*VY + (1-VsatMask).*Ymatch;
            Vmatch = ycbcr2rgb(cat(3,Ymatch,VYcc(:,:,2),VYcc(:,:,3)));
            residual = min(1,max(0,V-Vmatch));
            Vdiff = V - residual;
            PSNR(iEta,iBin,img) = psnr(Vdiff,G);
        end
    end
end
%%
figure(1)
for img = 1:4
    h{img} = subplot(1,4,img);
    surf(bin,eta,PSNR(:,:,img))
    zlabel('PSNR')
    xlabel('# bins')
    ylabel('\eta')
    axis tight
    shading interp
end
linkprop([h{1},h{2},h{3},h{4}],'View');
%%
p = plot(eta,reshape(PSNR,[nIterEta,4]),'linew',2);
axis tight
ylim([21 41])
grid minor
legend(p, {'animals','cups','fruit','masks'},'Location','southeast')
% set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), numel(p)))
xlabel('\eta'), ylabel('PSNR (dB)')
xline(5,'--','linew',2,'HandleVisibility','off');
xline(3.3,'--','linew',2,'HandleVisibility','off');
xline(2.6,'--','linew',2,'HandleVisibility','off');
%%
imshow([V G abs(V-G); ones(size(V)) Vdiff abs(Vdiff-G)])
%%
% % % % % % plot
% figure(2)
% subplot(211),...
% Show.Difference(Vdiff,V,4)
% subplot(212),...
% Show.Difference(Vdiff,G,4)
% plot(64:8:256,PSNR), axis tight, grid minor,...
%     legend({'Animals','Crups','Fruit','Masks'},'Location','southeast')
%%
[y1,cb1,cr1] = imsplit(imresize(imresize(rgb2ycbcr(G),[NaN 200]),0.2));
[y1sf,cb1sf,cr1sf] = imsplit(imresize(imresize(rgb2ycbcr(Vdiff),[NaN 200]),0.2));

figure(3)
scatter3(y1(:),cb1(:),cr1(:),'.')
hold on
scatter3(y1sf(:),cb1sf(:),cr1sf(:),'.')
hold off
xlabel('Y'), ylabel('Cb'), zlabel('Cr')
axis square tight, grid minor
legend({'\it V_{d}(x)','\it V_{gt}(x)'},'Location','ne')
view([60 60])
%%
% t = [];
% PSNR = zeros([80 4]);
% for img = 1:4
% V = im2double(imread(fname{img}));
% G = im2double(imread(   gt{img}));
% for idx = 1:80
%     Vavg = imgaussfilt(V,idx,'Padding','symmetric');
%     pSpec = min(min(1,max(0,(V-min(Vavg,[],3)))),[],3);
%     pSfi = V-pSpec;
%     PSNR(idx,img) = psnr(pSfi,G);
% end
% end
% subplot(211), plot(1:80,PSNR), axis tight, grid minor,...
%     legend({'Animals','Crups','Fruit','Masks'},'Location','southeast')
% subplot(212), plot(2:80,diff(PSNR)), axis tight, grid minor
% Vmsf = getMsf(V);
% subplot(311), Show.Difference(pSfi,V-min(V,[],3),2), title('SF v. PSFI')
% subplot(312), Show.Difference(pSfi,Vmsf,2), title('MSF v. PSFI')
% subplot(313), Show.Difference(pSfi,G,2), title('GT v. PSFI')

%%
% V = im2double(imread(fname{11}));
% Vcorr = V;
% Vest = V;
% count = uint8(0);
% while true
%     Vmsf = getMsf(V);
%     cddts = getCandidates(V,Vmsf);
%     m = maskAndDilateCddts(cddts,10);
%     cddts = imbinarize(cddts);
%     A = V;
%     A(cddts) = 0;
%     h = fspecial('gaussian',2*ceil(2*5)+1,5);
%     est = imfilter(V.*(1-m),h)./imfilter(1-m,h);
%     valid = ~isnan(est);
%     Vcorr(valid) = V(valid).*(1-m(valid)) + est(valid).*m(valid);
%     Vest(valid) = V(valid)-Saturate(min(V(valid)-min(Vcorr(valid),[],3),[],3));
%     if nnz(isnan(est)) < 1 || count >= 4
%         break
%     end
%     count = count + 1;
% end
% figure, imshow(est)
% Show.Difference(Vest,V)
%%
% V = im2double(imread(fname{2}));
% G = im2double(imread(   gt{2}));
% Vin255  =  255*V;
% % filter parameters
% sigmaS = 32;
% sigmaR = 64;
% % call bilateral filter
% Vout255 = zeros(size(Vin255));
% for c = 1:3
%      Vout255(:,:,c) = shiftableBF(Vin255(:,:,c),sigmaS,sigmaR);
% end
% pSpec = min(Saturate(V-min(Vout255/255,[],3)),[],3);
% pSfi = V-pSpec;
% % figure(1), imshow(pSfi)
% figure(2), imshow(pSpec)
% figure(3), imshow(Vout255/255)
% figure(4), Show.Difference(pSfi,G,4)

%% Functions

% function Vmsf = getMsf(V)
% %% Generate MSF
% % Vmsf = getMsf(V);
% Vmin = min(V,[],3);
% eta = 0.5;
% Tv = (mean2(Vmin(:)) + eta*std(Vmin(:)));
% tau = Vmin;
% tau(tau>Tv) = Tv;
% Vmsf = V - Vmin + tau;
% end

% function cddts = getCandidates(V,Vmsf)
% %% Get candidates
% % cddts = getCandidates(V,Vmsf);
% Vmin = min(V,[],3);
% th1 = mean2(Vmin(:));
% cddts = ones(size(V));
% cddts((V-Vmsf)<th1) = 0;
% end

% function mask = maskAndDilateCddts(cddts,sz)
% %% Get cddts mask
% % mask = maskAndDilateCddts(cddts,sz);
% se = offsetstrel('ball',sz,1);
% mask = imdilate(cddts,se);
% mask = histeq(mask-min(mask(:)));
% mask = (mask-min(mask(:)))/range(mask(:));
% end

%%
% function loLoSatMask = getSatMask(V,s1,s2)
% Vmin = min(V,[],3);
% %
% num = Vmin;
% den = sum(V,3);
% den(den==0) = 1e-3;
% sat = min(1,max(0,1-3.*num./den));
% sat(Vmin<=mean2(Vmin(:))) = 1;
% %
% satMask = imdilate(...
%     (1-sat).^4,...
%     strel('diamond',1));
% 
% loLoSatMask = imresize(...
%     satMask,s1*s2,...
%     'Method','bilinear','AntiAliasing',false);
% end

% function Vdith = normalDither(V)
% Vdith = min(1,max(0,(V+randn(size(V))/255)));
% end

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
