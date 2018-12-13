fname = 'img\toys.ppm';
src = im2double(imread(fname));
[src,dst] = qxHighlightRemoval(src);
ShowDifference(dst,src)

%

function ShowDifference(A,ref)
vsep = repmat(ones([size(ref,1) 1]),[1 1 size(ref,3)]);
imshow([ref vsep A vsep abs(ref-A)])
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

