function [dilatedMask,maskUsed] = GrowHighlightMask(imDbl,maskToUse)
%GROWHIGHLIGHTMASK Dilated image mask
%   [dilatedMask,maskUsed] = GrowHighlightMask(imDbl,maskToUse) returns a
%   2-D image mask corresponding to the location of clipped and dilated
%   intensities of a double-valued RGB image imDbl.
%
%   It is possible to input a logic mask imClip too. If so, the latter will
%   be used instead of a new one being generated for the purpose of
%   dilating.
%
%   If optional input imClip is specified, it should ideally have same
%   dimensions as imDbl.
if ~exist('maskToUse','var') || isempty(maskToUse)
    [r,g,b] = imsplit(imDbl);
    r(r<min(1,max(r,[],'all'))) = 0;
    g(g<min(1,max(g,[],'all'))) = 0;
    b(b<min(1,max(b,[],'all'))) = 0;
    maskToUse = cat(3,r,g,b);
end
radius = 2;
se = strel('disk',radius);
dilatedMask = imdilate(maskToUse,se);
maskUsed = maskToUse;
end

