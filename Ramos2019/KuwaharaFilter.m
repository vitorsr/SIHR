function I = KuwaharaFilter(Q)
%KUWAHARAFILTER Non-linear smoothing filter
%   I = KuwaharaFilter(Q) returns the center element I equal to adaptive
%   Kuwahara filtering of Q.
%
%   Input Q should be N×N, N odd; class(Q) must be single or double.
%
%   Usage:
%       N = 5;
%       fun = @(Q) KuwaharaFilter(Q);
%       dst = nlfilter(src,[N N],fun);
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

sigma = [std(a(:)),std(b(:)),...
         std(c(:)),std(d(:))];

idx = find(sigma<=min(sigma(:)),1);

switch idx
    case 1
        I = mean2(a(:));
    case 2
        I = mean2(b(:));
    case 3
        I = mean2(c(:));
    otherwise
        I = mean2(d(:));
end
end

