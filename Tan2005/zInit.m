function [src,count] = zInit(src,sfi,epsilon)
count = 0;
nY = size(src.rgb,1);
nX = size(src.rgb,2);
dlog_src_x = log(abs(z.Total(src.rgb(1:nY-1,2:nX  ,:))-...
                     z.Total(src.rgb(1:nY-1,1:nX-1,:))));
dlog_src_y = log(abs(z.Total(src.rgb(2:nY  ,1:nX-1,:))-...
                     z.Total(src.rgb(1:nY-1,1:nX-1,:))));
dlog_sfi_x = log(abs(z.Total(sfi.rgb(1:nY-1,2:nX  ,:))-...
                     z.Total(sfi.rgb(1:nY-1,1:nX-1,:))));
dlog_sfi_y = log(abs(z.Total(sfi.rgb(2:nY  ,1:nX-1,:))-...
                     z.Total(sfi.rgb(1:nY-1,1:nX-1,:))));
dlogx = abs(dlog_src_x-dlog_sfi_x);
dlogy = abs(dlog_src_y-dlog_sfi_y);
for iY = 1:nY-1
    for iX = 1:nX-1
        switch src.i(iY,iX)
            case z.BOUNDARY
                continue
            case z.NOISE
                continue
            case z.CAMERA_DARK
                continue
        end
        if dlogx(iY,iX) > epsilon
            src.i(iY,iX) = z.SPECULARX;
            count = count + 1;
            continue
        end
        if dlogy(iY,iX) > epsilon
            src.i(iY,iX) = z.SPECULARY;
            count = count + 1;
            continue
        end
        src.i(iY,iX) = z.DIFFUSE;
    end
end
end

