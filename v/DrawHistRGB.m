function DrawHistRGB(A,xrange)
%DRAWHISTRGB Draws a single-image RGB histogram
%   DrawHistRGB(imDbl,xrange) outputs to current axis a composite plot
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
% rHistMin = rHist;
% rHistMin([rIdxMed' rIdxMax']) = 0;
rHstMed = rHst;
rHstMed([rIdxMin' rIdxMax']) = 0;
rHstMax = rHst;
rHstMax([rIdxMin' rIdxMed']) = 0;
% gHistMin = gHist;
% gHistMin([gIdxMed' gIdxMax']) = 0;
gHstMed = gHst;
gHstMed([gIdxMin' gIdxMax']) = 0;
gHstMax = gHst;
gHstMax([gIdxMin' gIdxMed']) = 0;
% bHistMin = bHist;
% bHistMin([bIdxMed' bIdxMax']) = 0;
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

