function [orgb,oi] = zSpecular2Diffuse(irgb,ii,maxChroma)
c = z.MaxChroma(irgb);
dI = (z.Max(irgb).*(3*c-1))./(c*(3*maxChroma-1));
sI = (z.Total(irgb)-dI)./3;
nrgb = irgb-sI;
if nrgb(:,:,1) <= 0 || nrgb(:,:,2) <= 0 || nrgb(:,:,3) <= 0
    orgb = irgb;
    oi = z.NOISE;
    return
end
orgb = nrgb;
oi = ii;
end

