function c = zChroma_g(rgb)
g = rgb(:,:,2);
t = zTotal(rgb);
c = zeros(size(g));
if any(t(:))
    c(t~=0) = g(t~=0)./t(t~=0);
end
c(t==0) = 0;
end

