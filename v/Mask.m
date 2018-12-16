classdef Mask
    %MASK Placeholder object for mask functions
    %   Just a temporary organization thing
    
    properties(Constant)
        % None yet
    end
    
    methods(Static)
        function nearClip = NearClip(imDbl)
            %NEARCLIP Gets near-clip pixels
            %   nearClip = Mask.NearClip(imDbl) returns a mask containing only
            %   maximum values locations for each channel.
            [r,g,b] = imsplit(imDbl);
            r(r<min(1,max(r(:)))) = 0;
            g(g<min(1,max(g(:)))) = 0;
            b(b<min(1,max(b(:)))) = 0;
            nearClip = cat(3,r,g,b);
        end
        function [scaledMask,desaturatedMask] = Scaled(imDbl,pow)
            %SCALED Scaled highlight mask plus desaturated version
            %   [scaledMask,desaturatedMask] = Mask.Scaled(imDbl,pow) returns a
            %   RGB scaled image mask scaledMask corresponding to the highlight portion
            %   of the double-valued RGB image imDbl.
            %
            %   Highlight threshold is 1 standard deviation from the v-channel mean.
            %
            %   Linear scaling is done from p1(x1=thr,y1=0) to p2(x2=max,y2=1).
            %
            %   Values are then clipped to (0;1) and raised to pow.
            %
            %   desaturatedMask is equal to the pointwise multiplication of scaledMask
            %   with the complement of the saturation channel.
            %
            %   pow is optional and has default value of 1.
            if ~exist('pow','var') || isempty(pow)
                pow = 1;
            end
            [h,s,v] = imsplit(rgb2hsv(imDbl));
            avg = mean(v,'all');
            sd = std(v,[],'all');
            sigma = 1;
            thr = min(1,avg+sigma*sd);
            maxv = max(v,[],'all');
            if maxv > thr
                scaledMask = max(0,min(1,(v-thr)/(maxv-thr))).^pow;
            else
                scaledMask = v;
                scaledMask(scaledMask<avg) = 0;
                scaledMask = scaledMask.^pow;
            end
            desaturatedMask = hsv2rgb(cat(3,h,s,scaledMask.*(1-s)));
            scaledMask = hsv2rgb(cat(3,h,s,scaledMask));
        end
        function [dilatedMask,maskUsed] = GrowHighlights(imDbl,maskToUse)
            %GROWHIGHLIGHTS Dilated image mask
            %   [dilatedMask,maskUsed] = Mask.GrowHighlights(imDbl,maskToUse) returns a
            %   2-D image mask corresponding to the location of clipped and dilated
            %   intensities of a double-valued RGB image imDbl.
            %
            %   It is possible to input a logic mask imClip too. If so, the latter will
            %   be used instead of a new one being generated for the purpose of
            %   dilating.
            %
            %   If optional input imClip is specified, it should ideally have same
            %   dimensions as imDbl.
            if ~exist('maskToUse','var') || isempty(maskToUse)
                [r,g,b] = imsplit(imDbl);
                r(r<min(1,max(r,[],'all'))) = 0;
                g(g<min(1,max(g,[],'all'))) = 0;
                b(b<min(1,max(b,[],'all'))) = 0;
                maskToUse = cat(3,r,g,b);
            end
            radius = 2;
            se = strel('disk',radius);
            dilatedMask = imdilate(maskToUse,se);
            maskUsed = maskToUse;
        end
        function minMask = MinValues(imDbl)
            %MINVALUES Logical minimum values mask
            %   minMask = Mask.MinValues(imDbl) returns binarized mask of imDbl based on
            %   the minimum value across channels.
            %
            %   Input imDbl should be a double-valued RGB image.
            %
            %   See also: imbinarize
            minVals = min(imDbl,[],3);
            minMask = ~imbinarize(minVals,mean2(minVals(:)));
        end
    end
end

