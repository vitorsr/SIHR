function SIHR
%SIHR Session path setup
%   SIHR is a personal repository for the development and implementation of
% highlight removal methods.
%
% So far I have implemented (or ported) these methods to MATLAB:
%   [1] Tan2005\
%   [2] Yoon2006\
%   [3] Shen2008\
%   [4] Yang2010\
%   [5] Akashi2015\
%   [6] Yamamoto2017\
%
% Ongoing development (personal folder) is located in:
%   [ ] Ramos2019\
%
% [1] R. T. Tan and K. Ikeuchi, “Separating reflection components of textured
% surfaces using a single image,” IEEE Transactions on Pattern Analysis and
% Machine Intelligence, vol. 27, no. 2, pp. 178–193, Feb. 2005 [Online].
% Available: http://dx.doi.org/10.1109/TPAMI.2005.36;
%
% [2] K. Yoon, Y. Choi, and I. S. Kweon, “Fast Separation of Reflection
% Components using a Specularity-Invariant Image Representation,” in 2006
% International Conference on Image Processing, 2006 [Online].
% Available: http://dx.doi.org/10.1109/ICIP.2006.312650;
%
% [3] H.-L. Shen, H.-G. Zhang, S.-J. Shao, and J. H. Xin, “Chromaticity-based
% separation of reflection components in a single image,” Pattern Recognition,
% vol. 41, no. 8, pp. 2461–2469, Aug. 2008 [Online].
% Available: http://dx.doi.org/10.1016/J.PATCOG.2008.01.026;
%
% [4] Q. Yang, S. Wang, and N. Ahuja, “Real-Time Specular Highlight Removal
% Using Bilateral Filtering,” in Computer Vision – ECCV 2010, Springer Berlin
% Heidelberg, 2010, pp. 87–100 [Online].
% Available: http://dx.doi.org/10.1007/978-3-642-15561-1_7;
%
% [5] Y. Akashi and T. Okatani, “Separation of reflection components by sparse
% non-negative matrix factorization,” Computer Vision and Image Understanding,
% vol. 146, pp. 77–85, May 2016 [Online].
% Available: http://dx.doi.org/10.1016/j.cviu.2015.09.001;
%
% [6] T. Yamamoto, T. Kitajima, and R. Kawauchi, “Efficient improvement method
% for separation of reflection components based on an energy function,” in 2017
% IEEE International Conference on Image Processing (ICIP), 2017 [Online].
% Available: http://dx.doi.org/10.1109/ICIP.2017.8297078.
addpath(genpath(['.' filesep]))
end

