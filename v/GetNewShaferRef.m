function imRef = GetNewShaferRef(imDbl)
%GETNEWSHAFERREF Gets reference for usage with NewShaferSpace
%   imRef = GetNewShaferRef(imDbl) returns a NewShaferSpace-compatible
%   imRef to be used in order to obtain a new transformation matrix T.
%
%   It uses internally Mask.MinValues to mask minimum value pixels.
%
%   Input imDbl should be a double-valued RGB image.
minMask = Mask.MinValues(imDbl);
imRef = reshape(imDbl(repmat(minMask,[1 1 3])),[],1,3);
end

