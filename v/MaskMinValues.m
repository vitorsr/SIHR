function minMask = MaskMinValues(imDbl)
%MASKMINVALUES Logical minimum values mask
%   minMask = MaskMinValues(imDbl) returns binarized mask of imDbl based on
%   the minimum value across channels.
%
%   Input imDbl should be a double-valued RGB image.
%
%   See also: imbinarize
minVals = min(imDbl,[],3);
minMask = ~imbinarize(minVals,mean2(minVals(:)));
end

