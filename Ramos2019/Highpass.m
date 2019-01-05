classdef Highpass
    %HIGHPASS Placeholder object for highpass functions
    %   Just a temporary organization thing
    
    properties(Constant)
        % None yet
    end
    
    methods(Static)
        function imFilt = Median(imDbl)
            %MEDIAN Median complement highpass filter
            %   imFilt = Highpass.Median(imDbl) returns filtered image.
            %
            %   See also: medfilt2
            imFilt = zeros(size(imDbl));
            nRows = size(imDbl,1);
            nCols = size(imDbl,2);
            nCh   = size(imDbl,3);
            hsize = fix(min(nRows,nCols)/20)*2+1; % 1/10 factor obtained experimentally
            for iCh = 1:nCh
                imFilt(:,:,iCh) = medfilt2(imDbl(:,:,iCh),[hsize hsize],'symmetric');
            end
            imFilt = imDbl-imFilt;
            imFilt = min(1,(max(0,imFilt)));
        end
        function imFilt = Spatial(imDbl)
            %SPATIAL Average complement highpass filter
            %   imFilt = Highpass.Spatial(imDbl) returns filtered image.
            %
            %   See also: fspecial imfilter
            nRows = size(imDbl,1);
            nCols = size(imDbl,2);
            hsize = fix(min(nRows,nCols)/32)*2+1; % 1/16 factor obtained experimentally
            imFilt = imDbl-imfilter(imDbl,fspecial('average',hsize),'symmetric');
            imFilt = min(1,(max(0,imFilt)));
        end
        function imFilt = Wavelet(imDbl)
            %WAVELET Application-specific wavelet packet-based highpass filter
            %   imFilt = Highpass.Wavelet(imDbl) returns a high-passed version of a
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
    end
end

