function [imT,T] = TSpace(imDbl,sel)
%TSPACE T-space transformation
%   [imT,T] = TSpace(imDbl,sel) returns transformed image imT and the
%   transformation matrix T used.
%
%   Input imDbl must be a double-valued RGB image.
%
%   Argument sel = 'fwd' assures forward transform and sel = 'rev' reverse.
T = [1/sqrt(3) 1/sqrt(3)  1/sqrt(3);
    -1/sqrt(6) 2/sqrt(6) -1/sqrt(6);
    -1/sqrt(2)        0   1/sqrt(2)];
switch sel
    case 'fwd'
        r = imDbl(:,:,1);
        g = imDbl(:,:,2);
        b = imDbl(:,:,3);
        neu = T(1,1)*r + T(1,2)*g + T(1,3)*b;
        gm  = T(2,1)*r + T(2,2)*g + T(2,3)*b;
        ill = T(3,1)*r + T(3,2)*g + T(3,3)*b;
        imT = cat(3,neu,gm,ill);
    case 'rev'
        neu = imDbl(:,:,1);
        gm  = imDbl(:,:,2);
        ill = imDbl(:,:,3);
        r = T(1,1)*neu + T(2,1)*gm + T(3,1)*ill;
        g = T(1,2)*neu + T(2,2)*gm + T(3,2)*ill;
        b = T(1,3)*neu + T(2,3)*gm + T(3,3)*ill;
        imT = cat(3,r,g,b);
    otherwise
        imT = imDbl;
end
end

