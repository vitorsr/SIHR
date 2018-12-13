function c = zMaxChroma(rgb)
m = zMax(rgb);
t = zTotal(rgb);
c = zeros(size(m));
if any(t(:))
    c(t~=0) = m(t~=0)./t(t~=0);
end
c(t==0) = 0;
end

