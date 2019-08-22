function SIHR
%SIHR Session path setup
%  SIHR is a repository for the development and implementation of single
%  image highlight removal methods.
%
%  These methods are not the official implementations!!! This project has
%  the objective of reproducing these methods for facilitating research in
%  this specific subject. If you authored a method and would like to officially
%  make it available here instead of my implementation, please contact me,
%  I am happy to do so.
%
%  Project page:
%    https://github.com/vitorsr/SIHR
%
%  Usage:
%    SIHR % run it for a one-time session path setup
%
%  API:
%    J = im2double(imread('synth.ppm')); % input image
%    J_d = Yang2010(J); % call AuthorYEAR method
%                       % e.g. Yang2010
%    imshow([J, J_d, J - J_d]) % display result
%
%  See below for available methods.
%
%  See also Tan2005 [1], Yoon2006 [2], Shen2008 [3], Shen2009 [4],
%  Yang2010 [5], Shen2013 [6], Akashi2016 [7], Yamamoto2019 [8].
%
%[1] R. T. Tan and K. Ikeuchi, "Separating reflection components of textured surfaces using a single image," IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 27, no. 2, pp. 178-193, Feb. 2005.
%[2] K. Yoon, Y. Choi, and I. S. Kweon, "Fast Separation of Reflection Components using a Specularity-Invariant Image Representation," in 2006 International Conference on Image Processing, 2006.
%[3] H.-L. Shen, H.-G. Zhang, S.-J. Shao, and J. H. Xin, "Chromaticity-based separation of reflection components in a single image," Pattern Recognition, vol. 41, no. 8, pp. 2461-2469, Aug. 2008.
%[4] H.-L. Shen and Q.-Y. Cai, "Simple and efficient method for specularity removal in an image," Applied Optics, vol. 48, no. 14, p. 2711, May 2009.
%[5] Q. Yang, S. Wang, and N. Ahuja, "Real-Time Specular Highlight Removal Using Bilateral Filtering," in Computer Vision - ECCV 2010, Springer Berlin Heidelberg, 2010, pp. 87-100.
%[6] H.-L. Shen and Z.-H. Zheng, "Real-time highlight removal using intensity ratio," Applied Optics, vol. 52, no. 19, p. 4483, Jun. 2013.
%[7] Y. Akashi and T. Okatani, "Separation of reflection components by sparse non-negative matrix factorization," Computer Vision and Image Understanding, vol. 146, pp. 77-85, May 2016.
%[8] T. Yamamoto and A. Nakazawa, "General Improvement Method of Specular Component Separation Using High-Emphasis Filter and Similarity Function," ITE Transactions on Media Technology and Applications, vol. 7, no. 2, pp. 92-102, 2019.

my_foldername = fileparts(which('SIHR.m')); % this file
my_path = strsplit(genpath(my_foldername), pathsep);
N = numel(my_foldername) + numel([filesep, '.git']); % delete .\.git\*

for i = 1:length(my_path)
    if strncmp(my_path{i}, [my_foldername, filesep, '.git'], N)
        my_path{i} = [];
    end
end

my_path = my_path(~cellfun('isempty', my_path));
my_path = strjoin(my_path, pathsep);

addpath(my_path, '-end')

if (is_octave) % adds octave image path
    my_val = IMAGE_PATH;
    IMAGE_PATH([my_val, pathsep, my_foldername, filesep, 'images'])
end

if (is_octave)
    assert(isempty(pkg('list', 'image')) == 0) % && ...
    % isempty(pkg('list', 'statistics')) == 0)
    pkg unload image statistics
    pkg load image statistics
else
    assert(isequal(license('test', 'image_toolbox'), 1)) % && ...
    % isequal(license('test', 'statistics_toolbox'), 1))
end

end

function r = is_octave() % https://wiki.octave.org/Compatibility
persistent x;
if (isempty(x))
    x = exist('OCTAVE_VERSION', 'builtin');
end
r = x;
end
