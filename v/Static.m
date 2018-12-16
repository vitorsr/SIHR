classdef Static
    %STATIC Placeholder object for static functions
    %   Exactly what the title says
    
    properties(Constant)
        % None yet
    end
    
    methods(Static)
        function dst = padNextPow2(src,value)
            [nRow,nCol,~] = size(src);
            [prePadRow,prePadCol,postPadRow,postPadCol] =...
                Static.getNextPow2PadVals(nRow,nCol);
            dst = padarray(src,[prePadRow prePadCol],value,'pre');
            dst = padarray(dst,[postPadRow postPadCol],value,'post');
        end
        function dst = unPadNextPow2(src,nRow,nCol)
            [prePadRow,prePadCol,postPadRow,postPadCol] =...
                Static.getNextPow2PadVals(nRow,nCol);
            dst = src(1+prePadRow:end-postPadRow,1+prePadCol:end-postPadCol,:);
        end
        function [prePadRow,prePadCol,postPadRow,postPadCol] =...
                getNextPow2PadVals(nRow,nCol)
            nRowNextPow2 = 2^nextpow2(nRow);
            nColNextPow2 = 2^nextpow2(nCol);
            prePadRow = floor((nRowNextPow2-nRow)/2);
            prePadCol = floor((nColNextPow2-nCol)/2);
            postPadRow = ceil((nRowNextPow2-nRow)/2);
            postPadCol = ceil((nColNextPow2-nCol)/2);
        end
        function dstF = progMedFilt2(dst,lev,sz)
            [nRow,nCol,nCh] = size(dst);           % 2 for synth
            maxLev = nextpow2(min(nRow,nCol))-lev; % 1/2^(maxLev-1) = minimum scale
            dstLev{1} = dst;
            for iLev = 2:maxLev
                dstLev{iLev} = imresize(dstLev{iLev-1},0.5,...
                    'Method','bilinear','AntiAliasing',true);
            end
            dstLevF = dstLev;
            % roi = strel('disk',4,4).Neighborhood;
            % med = ceil(nnz(roi)/2);
            for iLev = 3:maxLev
                for iCh = 1:nCh
                    dstLevF{iLev}(:,:,iCh) = ...
                        medfilt2(dstLev{iLev}(:,:,iCh),sz,'symmetric');
                    % ordfilt2(dstLev{iLev}(:,:,iCh),med,roi,'symmetric');
                end
            end
            for iLev = maxLev:-1:2
                dstLevF{iLev-1} = min(cat(4,...
                    dstLevF{iLev-1},...
                    imresize(dstLevF{iLev},...
                    [size(dstLevF{iLev-1},1),size(dstLevF{iLev-1},2)],...
                    'Method','bilinear','AntiAliasing',true)),...
                    [],4);
            end
            dstF = min(1,max(0,dstLevF{1}));
        end
    end
end

