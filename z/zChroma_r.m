function c = zChroma_r(rgb)
r = rgb(:,:,1);
t = zTotal(rgb);
c = zeros(size(r));
if any(t(:))
    c(t~=0) = r(t~=0)./t(t~=0);
end
c(t==0) = 0;
end

