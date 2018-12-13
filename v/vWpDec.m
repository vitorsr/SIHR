% waveletAnalyzer
src = imresize(imread('img\fish.ppm'),[256 NaN],'lanczos3');
dst = src;
count = 0;
while true
    count = count + 1;
    if count >= 64 % ~32, count has to be approximately the highlight dynamic range
        break
    end
    t = wpdec2(dst,1,'bior3.1','log energy');
    [aR,aG,aB] = imsplit(read(t,'data',1));
    nNode = [2 3 4];
    for iNode = nNode
        [cR,cG,cB] = imsplit(read(t,'data',iNode));
        %
        muR = mean2(cR(:));
        muG = mean2(cG(:));
        muB = mean2(cB(:));
        %
        sigmaR = std(cR(:));
        sigmaG = std(cG(:));
        sigmaB = std(cB(:));
        %
        v = 2; % v could be a function of # of counts
        %      % thr could also be denoise-related e.g. Birge-Massart
        thrR = muR + v*sigmaR;
        thrG = muG + v*sigmaG;
        thrB = muB + v*sigmaB;
        %
        idxR = abs(cR) > thrR;
        idxG = abs(cG) > thrG;
        idxB = abs(cB) > thrB;
        %
        idxAndRGB = idxR & idxG & idxB;
        if nnz(idxAndRGB) == 0
            break
        end
        idxOrRGB = idxR | idxG | idxB;
        %
        nR = cR;
        nG = cG;
        nB = cB;
        %
        nR(idxOrRGB) = 0.976470588235294*nR(idxOrRGB); % 249/255
        nG(idxOrRGB) = 0.976470588235294*nG(idxOrRGB);
        nB(idxOrRGB) = 0.976470588235294*nB(idxOrRGB);
        %
        ncfs = cat(3,nR,nG,nB);
        t = write(t,'data',iNode,ncfs);
        %
        aR(idxAndRGB) = 0.992156862745098*aR(idxAndRGB); % 253/255
        aG(idxAndRGB) = 0.992156862745098*aG(idxAndRGB);
        aB(idxAndRGB) = 0.992156862745098*aB(idxAndRGB);
        %
        idxNeqRGB = ~idxAndRGB & idxOrRGB;
        %
        aM = min(min(aR,aG),aB);
        %
        aR(idxNeqRGB) = aR(idxNeqRGB) - fix(0.007843137254902*aM(idxNeqRGB)); % 2/255
        aG(idxNeqRGB) = aG(idxNeqRGB) - fix(0.007843137254902*aM(idxNeqRGB));
        aB(idxNeqRGB) = aB(idxNeqRGB) - fix(0.007843137254902*aM(idxNeqRGB));
    end
    if nnz(idxAndRGB) == 0
        break
    end
    acfs = cat(3,aR,aG,aB);
    t = write(t,'data',1,acfs);
    dst = wprec2(t);
end
imshowpair(src,dst,'montage')