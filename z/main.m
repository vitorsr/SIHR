fname = 'img\fish.ppm';
[img,sfi,diff] = zHighlightRemoval(fname,[NaN 128]);
img = Saturate(img/255);
sfi = Saturate(sfi/255);
diff = Saturate(diff/255);
ShowDifference(diff,img)

%

function B = Saturate(A)
B = min(1,max(0,A));
end

function ShowDifference(A,ref)
vsep = repmat(ones([size(ref,1) 1]),[1 1 size(ref,3)]);
imshow([ref vsep A vsep Saturate(abs(ref-A))])
title('(a) Reference, (b) Attempt, (c) Difference')
QualityMetrics(A,ref)
end

function QualityMetrics(A,ref)
MSE = immse(A,ref);
[PSNR, SNR] = psnr(A,ref);
SSIM = ssim(A,ref);
disp(['MSE = '  num2str(MSE)  ';' newline...
      'PSNR = ' num2str(PSNR) ', SNR = ' num2str(SNR) ';' newline...
      'SSIM = ' num2str(SSIM) '.'])
end

