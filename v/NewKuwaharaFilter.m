function I = NewKuwaharaFilter(Q)
%NEWKUWAHARAFILTER Non-linear minimum filter
%   I = NewKuwaharaFilter(Q) returns the center element I equal to modified
%   adaptive Kuwahara filtering of Q with kernel size N×N, N odd.
%
%   Input Q should be N×N, N odd.
%
%   See also: nlfilter
yx = size(Q);
y = floor((yx(1)-1)/2 + 1);
x = floor((yx(2)-1)/2 + 1);
%                   ^ due to MATLAB indexing
a = Q(1:y,1:x);
b = Q(1:y,x:end);
c = Q(y:end,1:x);
d = Q(y:end,x:end);
%
sigma = [std(a(:)),std(b(:)),...
         std(c(:)),std(d(:))];
%
mu = [mean2(a(:)) mean2(b(:)) mean2(c(:)) mean2(d(:))];
%
cv = sigma./mu;
%
idx = find(cv<=min(cv),1);
%
switch idx
    case 1
        I = median(a(:));
    case 2
        I = median(b(:));
    case 3
        I = median(c(:));
    otherwise
        I = median(d(:));
end
end

