%QX Class for bookkeeping constants
%   Edit qx for different values that affect the joint bilateral filtering.
%   Run qx_highlight_removal_bf for Yang's method.
classdef qx
    properties (Constant)
        THR    = 0.03
        SIGMAS = 3.0
        SIGMAR = 0.1
        SZ = 2*ceil(2*qx.SIGMAS)+1
        TOL    = 1e-4;
    end
end

