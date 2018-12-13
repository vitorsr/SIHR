function ShowDifference(A,ref,k)
%SHOWDIFFERENCE Displays two images and their difference
%   ShowDifference(A,ref,k) outputs to current axis image A, a reference
%   image ref to be compared to, and k (optional, defaults to 1) times their
%   difference.
%
%   It also calls QualityMetrics internally.
if ~exist('k','var') || isempty(k)
    k = 1;
end
vsep = repmat(ones([size(ref,1) 1]),[1 1 size(ref,3)]);
imshow([ref vsep A vsep min(1,max(0,k*abs(ref-A)))])
title(['(a) Reference, (b) Attempt, (c) ' num2str(k) '× Difference'])
QualityMetrics(A,ref)
end

