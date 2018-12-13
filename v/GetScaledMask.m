function [scaledMask,desaturatedMask] = GetScaledMask(imDbl,pow)
%GETSCALEDMASK Scaled highlight mask plus desaturated version
%   [scaledMask,desaturatedMask] = GetScaledMask(imDbl,pow) returns a
%   RGB scaled image mask scaledMask corresponding to the highlight portion
%   of the double-valued RGB image imDbl.
%
%   Highlight threshold is 1 standard deviation from the v-channel mean.
%
%   Linear scaling is done from p1(x1=thr,y1=0) to p2(x2=max,y2=1).
%
%   Values are then clipped to (0;1) and raised to pow.
%
%   desaturatedMask is equal to the pointwise multiplication of scaledMask
%   with the complement of the saturation channel.
%
%   pow is optional and has default value of 1.
if ~exist('pow','var') || isempty(pow)
    pow = 1;
end
[h,s,v] = imsplit(rgb2hsv(imDbl));
avg = mean(v,'all');
sd = std(v,[],'all');
sigma = 1;
thr = min(1,avg+sigma*sd);
maxv = max(v,[],'all');
if maxv > thr
    scaledMask = max(0,min(1,(v-thr)/(maxv-thr))).^pow;
else
    scaledMask = v;
    scaledMask(scaledMask<avg) = 0;
    scaledMask = scaledMask.^pow;
end
desaturatedMask = hsv2rgb(cat(3,h,s,scaledMask.*(1-s)));
scaledMask = hsv2rgb(cat(3,h,s,scaledMask));
end

