classdef Show
    %SHOW Placeholder object for show functions
    %   Just a temporary organization thing
    
    properties(Constant)
        % None yet
    end
    
    methods(Static)
        function Difference(A,ref,k)
            %DIFFERENCE Displays two images and their difference
            %   Show.Difference(A,ref,k) outputs to current axis image A, a reference
            %   image ref to be compared to, and k (optional, defaults to 1) times their
            %   difference.
            %
            %   It also calls QualityMetrics internally.
            if ~exist('k','var') || isempty(k)
                k = 1;
            end
            vsep = repmat(ones([size(ref,1) 1]),[1 1 size(ref,3)]);
            imshow([ref vsep A vsep min(1,max(0,k*abs(ref-A)))])
            title(['(a) Reference, (b) Attempt, (c) ' num2str(k) '× Difference'])
            QualityMetrics(A,ref)
        end
        function HistPair(A,ref,xrange)
            %HISTPAIR Draws a two-image comparison histogram
            %   Show.HistPair(A,ref,xrange) outputs to current axis two area plots
            %   corresponding to the histograms of image A and reference image ref.
            %
            %   xrange is optional and corresponds to xlim range.
            %
            %   xrange is a pair argument [x1 x2] and must have increasing values
            %   between [0 1].
            if ~exist('xrange','var') || isempty(xrange)
                xrange = [0 1];
            end
            cRef = imhist(ref)/numel(ref);
            cNew = imhist(A)/numel(ref);
            area(0:255,cRef,'EdgeColor','k','FaceColor','k')
            hold on
            area(0:255,cNew,'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.5)
            hold off
            xlabel('\it r')
            ylabel('\it p[r]')
            xlim(255*xrange)
            ylim('auto')
            axis square
            grid minor
            legend({'Reference','Attempt'},'EdgeColor','w')
        end
        function HistSingleRGB(A,xrange)
            %HISTSINGLERGB Draws a single-image RGB histogram
            %   Show.HistSingleRGB(imDbl,xrange) outputs to current axis a composite plot
            %   corresponding to the RGB histogram of image imDbl.
            %
            %   xrange is optional and corresponds to xlim range.
            %
            %   xrange is a pair argument [x1 x2] and must have increasing values
            %   between [0 1].
            if ~exist('xrange','var') || isempty(xrange)
                xrange = [0 1];
            end
            [r,g,b] = imsplit(A);
            rHst = imhist(r)/numel(r);
            gHst = imhist(b)/numel(b);
            bHst = imhist(g)/numel(g);
            rIdxMin = find(rHst<gHst & rHst<bHst);
            rIdxMed = find((rHst<gHst & rHst>bHst)|(rHst>gHst & rHst<bHst));
            rIdxMax = find(rHst>gHst & rHst>bHst);
            gIdxMin = find(gHst<rHst & gHst<bHst);
            gIdxMed = find((gHst<rHst & gHst>bHst)|(gHst>rHst & gHst<bHst));
            gIdxMax = find(gHst>rHst & gHst>bHst);
            bIdxMin = find(bHst<rHst & bHst<gHst);
            bIdxMed = find((bHst<rHst & bHst>gHst)|(bHst>rHst & bHst<gHst));
            bIdxMax = find(bHst>rHst & bHst>gHst);
            rHstMed = rHst;
            rHstMed([rIdxMin' rIdxMax']) = 0;
            rHstMax = rHst;
            rHstMax([rIdxMin' rIdxMed']) = 0;
            gHstMed = gHst;
            gHstMed([gIdxMin' gIdxMax']) = 0;
            gHstMax = gHst;
            gHstMax([gIdxMin' gIdxMed']) = 0;
            bHstMed = bHst;
            bHstMed([bIdxMin' bIdxMax']) = 0;
            bHstMax = bHst;
            bHstMax([bIdxMin' bIdxMed']) = 0;
            x = 0:255;
            area(x,max([rHst gHst bHst],[],2),'FaceColor','w','EdgeColor','w')
            hold on
            rPlt = area(x,rHstMax,'FaceColor','r','EdgeColor','r');
            gPlt = area(x,gHstMax,'FaceColor','g','EdgeColor','g');
            bPlt = area(x,bHstMax,'FaceColor','b','EdgeColor','b');
            area(x,rHstMed+gHstMed+bHstMed,'FaceColor',[0.1 0.1 0.1],'EdgeColor','k')
            plot(x,rHst,'r')
            plot(x,gHst,'g')
            plot(x,bHst,'b')
            hold off
            % title('RGB Histogram')
            xlabel('\it r')
            ylabel('\it p[r]')
            xlim(255*xrange)
            ylim('auto')
            axis square
            grid minor
            legend([rPlt gPlt bPlt],{'R','G','B'},'EdgeColor','w')
        end
    end
end

