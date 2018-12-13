function [src,sfi] = zSpecularFreeImage(src)
Lambda = 0.6;
camDark = 10;
[r,g,b] = imsplit(src.rgb);
src.i(intersect(intersect(find(r<camDark),find(g<camDark)),...
    find(b<camDark))) = z.CAMERA_DARK;
c = zMaxChroma(src.rgb);
dI = (zMax(src.rgb).*(3*c-1))./(c*(3*Lambda-1));
sI = (zTotal(src.rgb)-dI)/3;
drgb = min(255,max(0,src.rgb-sI));
sfi.rgb = drgb;
end

