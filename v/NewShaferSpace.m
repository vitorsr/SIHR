function [imT,T] = NewShaferSpace(imRef,imDbl,sel)
%NEWSHAFERSPACE Modified Shafer-space transformation
%   [imT,T] = NewShaferSpace(imRef,imDbl,sel) returns transformed image imT
%   and the transformation matrix T used.
%
%   Inputs imRef and imDbl must be double-valued RGB images.
%
%   Argument sel = 'fwd' assures forward transform and sel = 'rev' reverse.
%
%   If size(imRef) is [3 3], that is, a transformation matrix (e.g. T),
%   it'll be used instead of approximating a new space.
%
%   For proper inversion, either imRef should stay the same between calls,
%   or argument T returned in forward transformation must be input.
%
%   See also: pinv
if isequal(size(imRef),[3 3])
    T = imRef;
else
    T = GetTransformationMatrix(imRef);
end
switch sel
    case 'fwd'
        r = imDbl(:,:,1);
        g = imDbl(:,:,2);
        b = imDbl(:,:,3);
        bod = T(1,1)*r + T(1,2)*g + T(1,3)*b;
        ill = T(2,1)*r + T(2,2)*g + T(2,3)*b;
        err = T(3,1)*r + T(3,2)*g + T(3,3)*b;
        imT = cat(3,bod,ill,err);
    case 'rev'
        bod = imDbl(:,:,1);
        ill = imDbl(:,:,2);
        err = imDbl(:,:,3);
        r = T(1,1)*bod + T(2,1)*ill + T(3,1)*err;
        g = T(1,2)*bod + T(2,2)*ill + T(3,2)*err;
        b = T(1,3)*bod + T(2,3)*ill + T(3,3)*err;
        imT = cat(3,r,g,b);
    otherwise
        imT = imDbl;
end
    function T = GetTransformationMatrix(imRef)
        r = mean2(imRef(:,:,1));
        g = mean2(imRef(:,:,2));
        b = mean2(imRef(:,:,3));
        % https://www.mathworks.com/matlabcentral/fileexchange/36353-planefit
        xx = [0 r 1]';
        yy = [0 g 1]';
        zz = [0 b 1]';
        N = length(xx);
        O = ones(N,1);
        C = pinv([xx yy O],1e-3)*zz;
        % http://mathworld.wolfram.com/NormalVector.html
        nn = [C(1) C(2) -1];
        nn = nn/norm(nn);
        %
        vv = [r g b];
        vv = vv/norm(vv);
        %
        ww = cross(nn,vv);
        ww = ww/norm(ww);
        %
        T = [vv;
             ww;
             nn];
    end
end

