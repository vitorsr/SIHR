function src = zIteration(src,sfi,epsilon)
[src,count] = zInit(src,sfi,epsilon);
thR = 0.1; thG = 0.1;
nY = size(src.rgb,1);
nX = size(src.rgb,2);
while true
    cr = z.Chroma_r(src.rgb(1:nY-1,1:nX-1,:));
    cg = z.Chroma_g(src.rgb(1:nY-1,1:nX-1,:));
    cr_next_x = z.Chroma_r(src.rgb(1:nY-1,2:nX,:));
    cg_next_x = z.Chroma_g(src.rgb(1:nY-1,2:nX,:));
    cr_next_y = z.Chroma_r(src.rgb(2:nY,1:nX-1,:));
    cg_next_y = z.Chroma_g(src.rgb(2:nY,1:nX-1,:));
    drx = cr_next_x - cr;
    dgx = cg_next_x - cg;
    dry = cr_next_y - cr;
    dgy = cg_next_y - cg;
    iMaxChroma = z.MaxChroma(src.rgb);
    for iY = 1:nY-1
        for iX = 1:nX-1
            if src.i(iY,iX) == z.CAMERA_DARK
                continue
            end
            if src.i(iY,iX) == z.SPECULARX
                if abs(drx(iY,iX)) > thR && abs(dgx(iY,iX)) > thG
                    src.i(iY,iX) = z.BOUNDARY;
                    continue
                end
                if abs(iMaxChroma(iY,iX) - iMaxChroma(iY,iX+1)) < 0.01
                    src.i(iY,iX) = z.NOISE;
                    continue
                end
                if iMaxChroma(iY,iX) < iMaxChroma(iY,iX+1)
                    [src.rgb(iY,iX,:),src.i(iY,iX)] = zSpecular2Diffuse(src.rgb(iY,iX,:),src.i(iY,iX),iMaxChroma(iY,iX+1));
                    src.i(iY,iX) = z.DIFFUSE;
                    src.i(iY,iX+1) = z.DIFFUSE;
                else
                    [src.rgb(iY,iX+1,:),src.i(iY,iX+1)] = zSpecular2Diffuse(src.rgb(iY,iX+1,:),src.i(iY,iX+1),iMaxChroma(iY,iX));
                    src.i(iY,iX) = z.DIFFUSE;
                    src.i(iY,iX+1) = z.DIFFUSE;
                end
            end
            %
            if src.i(iY,iX) == z.SPECULARY
                if abs(dry(iY,iX)) > thR && abs(dgy(iY,iX)) > thG
                    src.i(iY,iX) = z.BOUNDARY;
                    continue
                end
                if abs(iMaxChroma(iY,iX) - iMaxChroma(iY+1,iX)) < 0.01
                    src.i(iY,iX) = z.NOISE;
                    continue
                end
                if iMaxChroma(iY,iX) < iMaxChroma(iY+1,iX)
                    [src.rgb(iY,iX,:),src.i(iY,iX)] = zSpecular2Diffuse(src.rgb(iY,iX,:),src.i(iY,iX),iMaxChroma(iY+1,iX));
                    src.i(iY,iX) = z.DIFFUSE;
                    src.i(iY+1,iX) = z.DIFFUSE;
                else
                    [src.rgb(iY+1,iX,:),src.i(iY+1,iX)] = zSpecular2Diffuse(src.rgb(iY+1,iX,:),src.i(iY+1,iX),iMaxChroma(iY,iX));
                    src.i(iY,iX) = z.DIFFUSE;
                    src.i(iY+1,iX) = z.DIFFUSE;
                end
            end
        end
    end
    pcount = count;
    [src,count] = zInit(src,sfi,epsilon);
    if count < 0
        break
    end
    if pcount <= count
        break
    end
end
src = zResetLabels(src);
end

