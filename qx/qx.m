classdef qx
    properties (Constant)
        THR    = 0.03
        SIGMAS = 3.0
        SIGMAR = 0.1
        SZ = 2*ceil(2*qx.SIGMAS)+1
    end
    methods(Static)
        function [src,dst] = main(fname)
            src = im2double(imread(fname));
            [src,dst] = qxHighlightRemoval(src);
        end
    end
end

