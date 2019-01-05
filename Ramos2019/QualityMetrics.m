function QualityMetrics(A,ref)
%QUALITYMETRICS Prints image quality metrics
%   QualityMetrics(A,ref) prints information to console about the quality
%   of image A in respect to reference image ref.
MSE = immse(A,ref);
[PSNR, SNR] = psnr(A,ref);
SSIM = ssim(A,ref);
disp(['MSE = '  num2str(MSE)  ';' newline...
      'PSNR = ' num2str(PSNR) ', SNR = ' num2str(SNR) ';' newline...
      'SSIM = ' num2str(SSIM) '.'])
end

