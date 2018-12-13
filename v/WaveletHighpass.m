function imFilt = WaveletHighpass(imDbl)
%WAVELETHIGHPASS Application-specific wavelet packet-based highpass filter
%   imFilt = WaveletHighpass(imDbl) returns a high-passed version of a
%   double-valued RGB image imDbl. The function has undefined behaviour for
%   unmet necessary conditions.
%
%   Works by zeroing the approximation coefficients at the deepest possible
%   level for the 2-D wavelet packet decomposition of each channel.
%
%   See also: wpdec2
x = im2uint8(imDbl);
wname = 'bior3.5';
level = wmaxlev(size(x),wname);
t = wpdec2(x,level,wname); % plot(t)
node = [level 0];
cfs = read(t,'data',node);
cfs = zeros(size(cfs));
t = write(t,'data',node,cfs);
imFilt = min(1,(max(0,im2double(uint8(wprec2(t))))));
end

