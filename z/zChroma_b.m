function c = zChroma_b(rgb)
b = rgb(:,:,3);
t = zTotal(rgb);
c = zeros(size(b));
if any(t(:))
    c(t~=0) = b(t~=0)./t(t~=0);
end
c(t==0) = 0;
end

