function nearClip = GetNearClipMask(imDbl)
%GETNEARCLIPMASK Gets near-clip pixels
%   nearClip = GetNearClipMask(imDbl) returns a mask containing only
%   maximum values locations for each channel.
[r,g,b] = imsplit(imDbl);
r(r<min(1,max(r(:)))) = 0;
g(g<min(1,max(g(:)))) = 0;
b(b<min(1,max(b(:)))) = 0;
nearClip = cat(3,r,g,b);
end

