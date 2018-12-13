function imSc = SoftClip(imDbl,k)
%SOFTCLIP Soft clip function (tanh-based)
%   imSc = SoftClip(imDbl,k) outputs soft-clipped image imSc.
%
%   imDbl must be double-valued and be on the (0;1) interval.
%
%   k corresponds to how affected the image will be. It is optional and
%   must be a positive integer (0;Inf].
%
%   Its default value is 3 - corresponds to a soft clip of: in=1, out=0.94.
%
%   k = 0 outputs tanh(imDbl).
if ~exist('k','var') || isempty(k)
    k = 3;
end
imDbl = imDbl + 0.5*rand(size(imDbl))/255; % quantization step dither
imSc = (tanh(imDbl) + k*imDbl)/(k+1);
end

