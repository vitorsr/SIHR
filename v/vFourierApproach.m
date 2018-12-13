src = double(imresize(imread('img\fish.ppm'),[256 NaN],'lanczos3'));
src = src + 0.5*rand(size(src));
dst = src;
[srcR,srcG,srcB] = imsplit(src);
[dstR,dstG,dstB] = imsplit(dst);
%
total = sum(src,3);
total3 = repmat(total,[1 1 3]);
%
tIdx = total<=eps; % total==0;
tIdx3 = repmat(tIdx,[1 1 3]);
%
sigma = zeros(size(src));
sigma(~tIdx3) = src(~tIdx3)./total3(~tIdx3); % chromaticity
%
sigmaMax = max(sigma,[],3);
sigmaMin = min(sigma,[],3);
sigmaMin3 = repmat(sigmaMin,[1 1 3]);
%
sIdx = sigmaMin>=1/3-eps & sigmaMin<=1/3+eps;
sIdx3 = repmat(sIdx,[1 1 3]);
%
lambda = ones(size(src))/3;
lambda(~sIdx3) = (sigma(~sIdx3)-sigmaMin3(~sIdx3))./...
    (3*(lambda(~sIdx3)-sigmaMin3(~sIdx3)));
lambdaMax = max(lambda,[],3);
%
clear idx idx3 sIdx sIdx3 sigmaMin3 tIdx tIdx3 total3

% count = uint8(0);
% while true
%     count = count + 1;
%     if count>=8
%         break
%     end
    % TODO: find a way to propagate diffuse to specular px
    h = fspecial('gaussian',[size(dst,1) size(dst,2)],max(size(dst,1),size(dst,2))/2);
    h = (h-min(h(:)))/(max(h(:))-min(h(:)));
    h = fftshift(h);
    %
    % Z = abs(fft2(zscore(sigmaMax)));
    %
%     m = (max(dst,[],3)./max(dst(:))).^4; % heightened highlights
%     M = abs(fft2(m));
%     hloc = find(M>mean2(M)+3*std(M));
%     hloc(hloc==1) = [];
    %
%     if isempty(hloc)
%         break
%     end
    %
    L = fft2(lambdaMax);
    LAbs = abs(L);
    LAng = angle(L);
    %
    S = fft2(sigmaMax);
    SAbs = abs(S);
    SAng = angle(S);
    %
    NAbs = SAbs;
    NAng = LAng;
%     NAng(hloc) = LAng(hloc);
    %
    sigmaMaxF = real(ifft2(h.*NAbs.*exp(1i*NAng)));
    sigmaMax = max(sigmaMax,sigmaMaxF);
    %
    idx = sigmaMax*3<=1;
    nz = sigmaMax~=1/3;
    sfi = zeros(size(srcR));
    sfi(nz) = (max(max(...
        srcR(nz),srcG(nz)),srcB(nz)...
        )-sigmaMax(nz).*total(nz))./(1-3*sigmaMax(nz));
    dstR(~idx) = srcR(~idx)-sfi(~idx);
    dstG(~idx) = srcG(~idx)-sfi(~idx);
    dstB(~idx) = srcB(~idx)-sfi(~idx);
    %
    dst = cat(3,dstR,dstG,dstB);
%     if nnz(abs(sigmaMax-sigmaMaxF)>0.03)==0
%         break
%     end
% end
ShowDifference(dst/255,src/255)
set(gcf,'Visible','on')
%%
% [lA,lH,lV,lD] = haart2(lambdaMax,level);
% [sA,sH,sV,sD] = haart2(sigmaMax,level);
% sigmaMaxF = ihaart2(sA,sH,sV,sD,0);