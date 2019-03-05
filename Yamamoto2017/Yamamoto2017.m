%% Import image to workspace
i_input = im2double(imread('toys.ppm'));
[nRow,nCol,nCh] = size(i_input);
%% i = i_d + i_s
i_d = qx_highlight_removal_bf(i_input); % or another highlight removal method
i_s = Saturate(i_input - i_d);
%% Iteration constraints
count = uint8(0);
e = 0.2;
%% While loop
while true
%% (cont.)
k = 10;
h = fspecial('average',3);
i_input_bf = imfilter(i_input,h,'symmetric');
i_d_bf     = imfilter(i_d,    h,'symmetric');
i_s_bf     = imfilter(i_s,    h,'symmetric');
%% (cont.)
i_input_um = Saturate(i_input + k*Saturate(i_input - i_input_bf));
i_d_um     = Saturate(i_d     + k*Saturate(i_d     - i_d_bf ));
i_s_um     = Saturate(i_s     + k*Saturate(i_s     - i_s_bf ));
%% (cont.)
i_combined_um = Saturate(i_d_um + i_s_um);
%% (cont.)
E_difference = sum((i_combined_um - i_input_um).^2,3);
%% Test iteration {{TODO: make it... iterate}}
aux = i_s;
%% (cont.)
w = 0.146;

thr = mean2(E_difference) + 2*std(E_difference(:));

replaceThese = E_difference > thr;

[row,col] = ind2sub(size(replaceThese),find(replaceThese));

paux = aux;

for ind = 1:nnz(replaceThese)
    if row(ind) == 1 || col(ind) == 1 || row(ind) == nRow || col(ind) == nCol
        continue
    end
    Y_i_input = i_input(row(ind)-1:row(ind)+1,col(ind)-1:col(ind)+1,:);
    Y_i_input_um = i_input_um(row(ind)-1:row(ind)+1,col(ind)-1:col(ind)+1,:);
    Y_i_combined_um = i_combined_um(row(ind)-1:row(ind)+1,col(ind)-1:col(ind)+1,:);
    
    Y_i_input_col = reshape(Y_i_input,[9 3]);
    Y_i_input_um_col = reshape(Y_i_input_um,[9 3]);
    Y_i_combined_um_col = reshape(Y_i_combined_um,[9 3]);
    
    E_input_col = sum((Y_i_input_col(5,:)-Y_i_input_col).^2,2);
    E_um_col = sum((Y_i_input_um_col-Y_i_combined_um_col).^2,2);
    
    E_pp_col = w*E_input_col + (1-w)*E_um_col;
    
    [~,plausible] = min(E_pp_col);
    [pRow,pRol] = ind2sub([3 3],plausible);
    
    aux(row(ind),col(ind),:) = paux(row(ind)-2+pRow,col(ind)-2+pRol,:);
end
%% (cont.)
if sqrt(immse(aux,paux)) < e || count >= 10
   break
end
%% Update i_d, i_s
i_s = aux;
i_d = Saturate(i_input - i_s);
%%
end % ENDWHILE
%%
Show.Difference(i_input-aux,i_input-i_s,10)

