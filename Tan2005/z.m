classdef z
    properties (Constant)
        SPECULARX   = uint8(10)
        SPECULARY   = uint8(11)
        DIFFUSE     = uint8(12)
        BOUNDARY    = uint8(13)
        NOISE       = uint8(14)
        CAMERA_DARK = uint8(15)
    end
    methods(Static)
        function [src,sfi,diff] = main(input)
            [src,sfi,diff] = zHighlightRemoval(input);
            src = src/255;
            sfi = sfi/255;
            diff = diff/255;
        end
        function c = Chroma_r(rgb)
            r = rgb(:,:,1);
            t = z.Total(rgb);
            c = zeros(size(r));
            if any(t(:))
                c(t~=0) = r(t~=0)./t(t~=0);
            end
            c(t==0) = 0;
        end
        function c = Chroma_g(rgb)
            g = rgb(:,:,2);
            t = z.Total(rgb);
            c = zeros(size(g));
            if any(t(:))
                c(t~=0) = g(t~=0)./t(t~=0);
            end
            c(t==0) = 0;
        end
        function c = Chroma_b(rgb)
            b = rgb(:,:,3);
            t = z.Total(rgb);
            c = zeros(size(b));
            if any(t(:))
                c(t~=0) = b(t~=0)./t(t~=0);
            end
            c(t==0) = 0;
        end
        function m = Max(rgb)
            m = max(rgb,[],3);
        end
        function c = MaxChroma(rgb)
            m = z.Max(rgb);
            t = z.Total(rgb);
            c = zeros(size(m));
            if any(t(:))
                c(t~=0) = m(t~=0)./t(t~=0);
            end
            c(t==0) = 0;
        end
        function m = Min(rgb)
            m = min(rgb,[],3);
        end
        function t = Total(rgb)
            t = sum(rgb,3);
        end
    end
end

