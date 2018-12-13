function DrawHist(A,ref,xrange)
%DRAWHIST Draws a two-image comparison histogram
%   DrawHist(A,ref,xrange) outputs to current axis two area plots
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

