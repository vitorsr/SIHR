function SIHR
% SIHR SIHR is a personal project for the development and implementation of
% highlight removal methods.
%
% So far I have "implemented" (ported) these methods to MATLAB:
%   [1] z\
%   [2] qx\
%
% Ongoing individual development is located in:
%   [~] v\
%
% These are the functions currently available:
%   >> help DrawHist
%   >> help DrawHistRGB
%   >> help GetNearClipMask
%   >> help GetNewShaferRef
%   >> help GetScaledMask
%   >> help GrowHighlightMask
%   >> help KuwaharaFilter
%   >> help MaskMinValues
%   >> help MedianHighpass
%   >> help NewKuwaharaFilter
%   >> help NewShaferSpace
%   >> help QualityMetrics
%   >> help ShowDifference
%   >> help SoftClip
%   >> help SpatialHighpass
%   >> help TSpace
%   >> help WaveletHighpass
%
% [1]: R. T. Tan and K. Ikeuchi, “Separating reflection components of textured
% surfaces using a single image,” IEEE Transactions on Pattern Analysis and
% Machine Intelligence, vol. 27, no. 2, pp. 178–193, Feb. 2005 [Online].
% Available: http://dx.doi.org/10.1109/TPAMI.2005.36;
%
% [2]: Q. Yang, S. Wang, and N. Ahuja, “Real-Time Specular Highlight Removal
% Using Bilateral Filtering,” in Computer Vision – ECCV 2010, Springer Berlin
% Heidelberg, 2010, pp. 87–100 [Online]. Available:
% http://dx.doi.org/10.1007/978-3-642-15561-1_7.
addpath(genpath(['.' filesep]))
end

