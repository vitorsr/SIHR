imInt = imresize(imread('img\toys.ppm'),[256 NaN],'lanczos3');
imDbl = im2double(imInt);
%%
clearvars -except imDbl
%%
imNew = imDbl;
[nR,nG,nB] = imsplit(imNew);
%%
nRe = 50;
%%
for iRe = 1:nRe
mask = Mask.NearClip(imNew);
mask = Mask.GrowHighlights([],mask);
[maskR,maskG,maskB] = imsplit(mask);
nR = InterpCh(nR,boolean(maskR));
nG = InterpCh(nG,boolean(maskG));
nB = InterpCh(nB,boolean(maskB));
imNew = cat(3,nR,nG,nB);
end
%%
dr = 59:59+32-1;
dc = 147:147+32-1;
Show.Difference(imNew(dr,dc,:),imDbl(dr,dc,:))
%%
Show.Difference(imNew,imDbl)
%%
% tmp = mask.';
% area(mask(:),'FaceAlpha',0.5,'FaceColor','r','EdgeColor','r')
% hold on
% area(tmp(:),'FaceAlpha',0.5,'FaceColor','b','EdgeColor','b')
% hold off
% axis tight
% grid minor
%%
% imshow([mask logical(vsep) maskT])
% imshow([ch vsep chT])
%%
ch = nR;
for iRe = 1:2
    disp(['Iteration #' num2str(iRe) '...'])
    ch = padarray(ch,[1 1],'symmetric');
    inter = zeros(size(ch));
    nRows = size(ch,1);
    nCols = size(ch,2);
    for iRow = 2:nRows-1
        for iCol = 2:nCols-1
            dr = iRow-1:iRow+1;
            dc = iCol-1:iCol+1;
            mask = GenInterpROIMask(ch(dr,dc));
            inter(iRow,iCol) = InterpROI(ch(dr,dc),mask);
        end
    end
    inter = inter(2:end-1,2:end-1);
    ch = inter;
end
%%
ref = nR;
%%
nPad = 20;
ref = padarray(ref,[nPad nPad],'symmetric');
A = ref;
for iPad = 1:nPad
fun = @(c) InterpROI(c,GenInterpROIMask(c));
A = nlfilter(A,[3 3],fun);
end
A = A(1+nPad:end-nPad,1+nPad:end-nPad);
ref = ref(1+nPad:end-nPad,1+nPad:end-nPad);
%%
Show.Difference(repmat(A,[1 1 3]),repmat(ref,[1 1 3]))
%%
function new = InterpROI(roi,mask)
% orig = floor((size(mask)+1)/2);
if mask(2,2) == false
    new = roi(2,2);
    return
end
maskT = mask.'; % line   = roiT(maskT);
roiT = roi.';   % column = roi (mask);
%
valx = maskT(:); % horizontal mask
x = roiT(:);
x(valx) = interp1(find(~valx),x(~valx),find(valx),'spline','extrap');
%
valy = mask(:); % vertical mask
y = roi(:);
y(valy) = interp1(find(~valy),y(~valy),find(valy),'spline','extrap');
%
x = reshape(x,size(roiT)).';
y = reshape(y,size(roi));
%
new = min(x(2,2),y(2,2));
end
%%
function mask = GenInterpROIMask(roi)
mask = false(size(roi));
if roi(2,2) > 10/255 && roi(2,2) >= getfield(sort(roi(:)),{7})
    mask(2,2) = true;
end
end
function newCh = InterpCh(ch,mask)
maskT = mask.'; % line   = chT(maskT);
chT = ch.';   % column = ch(mask);
%
valx = maskT(:); % horizontal mask
x = chT(:);
x(valx) = interp1(find(~valx),x(~valx),find(valx),'spline','extrap');
%
valy = mask(:); % vertical mask
y = ch(:);
y(valy) = interp1(find(~valy),y(~valy),find(valy),'spline','extrap');
%
x = reshape(x,size(chT)).';
y = reshape(y,size(ch));
%
newCh = min(x,y);
end