function I_d = Tan2005(I)
%Tan2005 I_d = Tan2005(I)
%  This Frankenstein of a code translation is the attempt of a
%  transliteration of the original C++ code. It is pending refactoring.
%
%  Normally it should produce similar results, give or take some numerical
%  errors. Full bitmatching has not been confirmed however, because
%  constants utilized are sensitive to variation.
%
%  Namely, you can try changing the chroma threshold that identifies color
%  discontinuities:
%    edit zIteration.m
%  Search for 'thR' and 'thG'.
%
%  You can also change the threshold values that define camera dark pixels
%  and the maximum chromaticity that generates the pseudo specular-free
%  representation used to guide the method:
%    edit zRemoveHighlights.m
%  Search for 'Lambda' and 'camDark'.
%
%  Contact me should you find any mistakes.
%
%  See also SIHR, Yoon2006, Yang2010.

warning(['This method is slow and noise-sensitive!', newline, ...
    '         It takes ~2 min on a small image (60+ on Octave!).'])

assert(isa(I, 'float'), 'SIHR:I:notTypeSingleNorDouble', ...
    'Input I is not type single nor double.')
assert(min(I(:)) >= 0 && max(I(:)) <= 1, 'SIHR:I:notWithinRange', ...
    'Input I is not within [0, 1] range.')
[n_row, n_col, n_ch] = size(I);
assert(n_row > 1 && n_col > 1, 'SIHR:I:singletonDimension', ...
    'Input I has a singleton dimension.')
assert(n_ch == 3, 'SIHR:I:notRGB', ...
    'Input I is not a RGB image.')

[~, ~, I_d] = z.main(I);

end
