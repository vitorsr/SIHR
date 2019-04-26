%% Import image to workspace
I = im2double(imread('synth.ppm'));
% figure(1), imshow(I)
%% Create specular-free two-band image
Isf = I - min(I,[],3);
% figure(2), imshow(Isf)
%% Get its chroma
den = repmat(sum(Isf,3),[1 1 3]);
zero = den==0;
c = zeros(size(Isf));
c(~zero) = Isf(~zero)./den(~zero);
clear den zero
%%
% c = getChroma(Isf);
cr = c(:,:,1);
cg = c(:,:,2);
%% Dimensions
[nRow,nCol,nCh] = size(I);
%% Reshape to column vector (easier indexing)
I_col = reshape(I,[nRow*nCol nCh]);
Isf_col = reshape(Isf,[nRow*nCol nCh]);
cr_col = reshape(cr,[nRow*nCol 1]);
cg_col = reshape(cg,[nRow*nCol 1]);
skip = false([nRow*nCol 1]);
%% Chroma threshold values (color discontinuity)
thR = 0.05; thG = 0.05;
%% Iterates until only diffuse pixels are left
count = uint16(0);
iter = uint16(0);
while true
    for x1 = 1:nRow*nCol-1
        x2 = x1 + 1;
        if skip(x1)
            continue
        elseif sum(Isf_col(x2),2) == 0 ||...
                sum(I_col(x2),2) == 0 ||...
                (abs(cr_col(x1)-cr_col(x2)) > thR &&...
                abs(cg_col(x1)-cg_col(x2)) > thG)
            skip(x1) = true;
            continue
        end
        % Get local r_{d+s} ratio and r_{d}
        rd = sum(Isf_col(x1),2)/sum(Isf_col(x2),2);
        rds = sum(I_col(x1),2)/sum(I_col(x2),2);
        % Compare ratios and decrease intensity
        if rds > rd
            m = sum(I_col(x1,2)) - rd*sum(I_col(x2,2));
            if m < 1e-3
                continue
            end
            I_col(x1,:) = max(0,I_col(x1,:) - m/3);
            count = count + 1;
        elseif rds < rd
            m = sum(I_col(x2,2)) - sum(I_col(x1,2))/rd;
            if m < 1e-3
                continue
            end
            I_col(x2,:) = max(0,I_col(x2,:) - m/3);
            count = count + 1;
        end
    end
    if count == 0 || iter == 1000
        break
    end
    count = 0;
    iter = iter + 1;
end
%% Display diffuse image
Idiff = reshape(I_col,[nRow nCol nCh]);
figure(3), imshow(Idiff)

% function cI = getChroma(I)
% sI = repmat(sum(I,3),[1 1 3]);
% zeroI = sI==0;
% cI = zeros(size(I));
% cI(~zeroI) = I(~zeroI)./sI(~zeroI);
% end
