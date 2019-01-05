imInt = imresize(imread('green.jpg'),[256 NaN],'lanczos3');
imDbl = im2double(imInt);
%%
clearvars -except imDbl
%%
vsep = repmat(ones([size(imDbl,1) 1]),[1 1 3]);
%%
[imT,T] = NewShaferSpace(imDbl,imDbl,'fwd');
[imR,~] = NewShaferSpace(imDbl,imT,'rev');
[body,ill,err] = SplitPlanesToRGB(imT,T);
imshow([body vsep ill vsep err])
title('[(a) Body, (b) Reflection, (c) Error] decomposition planes')
QualityMetrics(imR,imDbl)
%%
PlotNewShaferSpace(imDbl,T,'g')
view([-120 15])
%%
clearvars -except imDbl vsep
%%
[imT,T] = TSpace(imDbl,'fwd');
[imR,~] = TSpace(imT,'rev');
[neu,gm,ill] = SplitPlanesToRGB(imT,T);
imshow([neu vsep gm vsep ill])
title('[(a) Neutral, (b) Green-magenta, (c) Illuminant] planes')
QualityMetrics(imR,imDbl)
%%
% iRow = [1+pad,nRows-pad]
% iCol = [1+pad,nCols-pad]
% r1 = iRow - orig(1) + 1
% c1 = iCol - orig(2) + 1
% r2 = r1 + size(se,1) - 1
% c2 = c1 + size(se,2) - 1
% r1(1):r2(1)
% c1(1):c2(1)
% r1(2):r2(2)
% c1(2):c2(2)
%%
% C = CH; L = SH;
% wthrmngr('dw2dcompGBL','rem_n0',imDbl)
% wthrmngr('dw2dcompGBL','bal_sn',C,L)
% wthrmngr('dw2dcompGBL','sqrtbal_sn',C,L)
% max(wthrmngr('dw2dcompLVL','scarcehi',C,L,10),[],'all')%where 2.5 < alpha < 10
% max(wthrmngr('dw2dcompLVL','scarceme',C,L,2.5),[],'all')%where 1.5 < alpha < 2.5
% max(wthrmngr('dw2dcompLVL','scarcelo',C,L,2),[],'all')%where 1 < alpha < 2
% max(wthrmngr('dw2ddenoLVL','sqrtbal_sn',C,L),[],'all')
% max(wthrmngr('dw2ddenoLVL','penalhi',C,L,10),[],'all')%, where 2.5 < alpha < 10
% max(wthrmngr('dw2ddenoLVL','penalme',C,L,2.5),[],'all')%, where 1.5 < alpha < 2.5
% max(wthrmngr('dw2ddenoLVL','penallo',C,L,2),[],'all')%, where 1 < alpha < 2
% max(wthrmngr('dw2ddenoLVL','sqtwolog',C,L,'one'),[],'all')
%%
function [c1,c2,c3] = SplitPlanesToRGB(imT,T)
c1 = cat(3,T(1,1)*imT(:,:,1),T(1,2)*imT(:,:,1),T(1,3)*imT(:,:,1));
c2 = cat(3,T(2,1)*imT(:,:,2),T(2,2)*imT(:,:,2),T(2,3)*imT(:,:,2));
c3 = cat(3,T(3,1)*imT(:,:,3),T(3,2)*imT(:,:,3),T(3,3)*imT(:,:,3));
end
function PlotNewShaferSpace(imDbl,T,flag)
vv = T(1,:);
ww = T(2,:);
% nn = T(3,:);
r = reshape(imDbl(:,:,1),[],1);
g = reshape(imDbl(:,:,2),[],1);
b = reshape(imDbl(:,:,3),[],1);
xx = [0 mean(r,'all') 1]';
yy = [0 mean(g,'all') 1]';
zz = [0 mean(b,'all') 1]';
N = length(xx);
O = ones(N,1);
C = [xx yy O]\zz;
x = linspace(0,1,128);
y = linspace(0,1,128);
[xx,yy] = meshgrid(x,y);
zzft = C(1)*xx + C(2)*yy + C(3);
tmpR = downsample(r,32);
tmpG = downsample(g,32);
tmpB = downsample(b,32);
clf reset
scatter3(tmpR,tmpG,tmpB,flag,'.')
hold on
surf(xx,yy,zzft,'edgecolor','none')
colormap gray
plot3([0 vv(1)],[0 vv(2)],[0 vv(3)],'y',...
    'LineWidth',2,...
    'Marker','.',...
    'MarkerSize',16)
plot3(vv(1)+[0 ww(1)],vv(2)+[0 ww(2)],vv(3)+[0 ww(3)],'y',...
    'LineWidth',2,...
    'Marker','.',...
    'MarkerSize',16)
plot3([0 ww(1)],[0 ww(2)],[0 ww(3)],'y',...
    'LineWidth',2,...
    'Marker','.',...
    'MarkerSize',16)
plot3(ww(1)+[0 vv(1)],ww(2)+[0 vv(2)],ww(3)+[0 vv(3)],'y',...
    'LineWidth',2,...
    'Marker','.',...
    'MarkerSize',16)
hold off
title('RGB space')
legend({'(R,G,B) scatter','Plane fit','Decomposition vectors'},...
    'Box','off')
xlabel('R'), ylabel('G'), zlabel('B')
xlim([0 1]), ylim([0 1]), zlim([0 1])
axis square
grid minor
view([-45 15])
end
