function dst = qx_highlight_removal_bf(src)
total = sum(src,3);
total3 = repmat(total,[1 1 3]);

tIdx = total<=qx.TOL;
tIdx3 = repmat(tIdx,[1 1 3]);

sigma = zeros(size(src));
sigma(~tIdx3) = src(~tIdx3)./total3(~tIdx3);
sigmaMax = max(sigma,[],3);
sigmaMin = min(sigma,[],3);
sigmaMin3 = repmat(sigmaMin,[1 1 3]);

sIdx = sigmaMin>=1/3-qx.TOL & sigmaMin<=1/3+qx.TOL;
sIdx3 = repmat(sIdx,[1 1 3]);

lambda = ones(size(src))/3;
lambda(~sIdx3) = (sigma(~sIdx3)-sigmaMin3(~sIdx3))./...
    (3*(lambda(~sIdx3)-sigmaMin3(~sIdx3)));
lambdaMax = max(lambda,[],3);

while true
    sigmaMaxF = im2double(bfilter2(sigmaMax,lambdaMax,qx.SZ,qx.SIGMAS,qx.SIGMAR));
    if nnz(sigmaMaxF-sigmaMax>qx.THR) == 0
        break
    end
    sigmaMax = max(sigmaMax,sigmaMaxF);
end

zIdx = (sigmaMax>=1/3-qx.TOL) & (sigmaMax<=1/3+qx.TOL);

srcMax = max(src,[],3);

sfi = zeros([size(src,1) size(src,2)]);
sfi(~zIdx) = (srcMax(~zIdx)-sigmaMax(~zIdx).*total(~zIdx))./(1-3*sigmaMax(~zIdx));
sfi3 = repmat(sfi,[1 1 3]);

mIdx = sigmaMax<=1/3+qx.TOL;
mIdx3 = repmat(mIdx,[1 1 3]);

dst = src;
dst(~mIdx3) = src(~mIdx3)-sfi3(~mIdx3);
end

