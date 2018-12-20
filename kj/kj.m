%%
I = im2double(imread('synth.ppm'));
% figure(1), imshow(I)
%%
Isf = I - min(I,[],3);
% figure(2), imshow(Isf)
%%
c = getChroma(Isf);
cr = c(:,:,1);
cg = c(:,:,2);
%%
[nRow,nCol,nCh] = size(I);
%%
I_col = reshape(I,[nRow*nCol nCh]);
Isf_col = reshape(Isf,[nRow*nCol nCh]);
cr_col = reshape(cr,[nRow*nCol 1]);
cg_col = reshape(cg,[nRow*nCol 1]);
skip = false([nRow*nCol 1]);
%%
thR = 0.1; thG = 0.1;
%%
count = uint8(0);
iter = uint16(0);
while true
    for x1 = 1:nRow*nCol-1
        x2 = x1 + 1;
        if skip(x1)
            continue
        elseif sum(Isf_col(x2),2) < 1e-3 ||...
                (sum(I_col(x1),2) < 1e-2 ||...
                sum(I_col(x2),2) < 1e-2) ||...
                (abs(cr_col(x1)-cr_col(x2)) > thR &&...
                abs(cg_col(x1)-cg_col(x2)) > thG)
            skip(x1) = true;
            continue
        end
        % get local rd+s ratio and rd
        rd = sum(Isf_col(x1),2)/sum(Isf_col(x2),2);
        rds = sum(I_col(x1),2)/sum(I_col(x2),2);
        % compare and apply spec2diff
        if rds > rd
            m = sum(I_col(x1,2)) - rd*sum(I_col(x2,2));
            if abs(m) < 1e-3
                continue
            end
            I_col(x1,:) = I_col(x1,:) - m/3;
            count = count + 1;
        elseif rds < rd
            m = sum(I_col(x2,2)) - sum(I_col(x1,2))/rd;
            if abs(m) < 1e-3
                continue
            end
            I_col(x2,:) = I_col(x2,:) - m/3;
            count = count + 1;
        end
    end
    if count == 0 || iter >= nCol
        break
    end
    count = 0;
    iter = iter + 1;
end
%%
Idiff = reshape(I_col,[nRow nCol nCh]);
figure(3), imshow(Idiff)
%%
function cI = getChroma(I)
sI = repmat(sum(I,3),[1 1 3]);
val = sI<1e-3;
cI = zeros(size(I));
cI(~val) = I(~val)./sI(~val);
end
