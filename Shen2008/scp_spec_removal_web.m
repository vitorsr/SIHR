% Code for the following paper:
% H. L. Shen, H. G. Zhang, S. J. Shao, and J. H. Xin, 
% Chromaticity-based separation of reflection components in a single image, 
% Pattern Recognition, 41(8), 2461-2469, 2008.

clear;

threshold_chroma = 0.03;

I = imread('bear.bmp');
I = double(I);
[height, width, dim] = size(I);

I3c = reshape(I, height*width, 3);

% calculate specular-free image
Imin = min(I3c, [], 2);
Imax = max(I3c, [], 2);
Iss = I3c - repmat(Imin, 1, 3) +  mean(Imin); 
Itemp = I3c - Iss;


% calculate the mask of combined pixels and diffuse pixels
th = mean(Imin);
Imask_cmb = zeros(height * width, 1);  
ind_cmb = find(Itemp(:,1) > th & Itemp(:,2) > th & Itemp(:,3) > th); 
Imask_cmb(ind_cmb,:) = 1; 

Imask_df = zeros(height * width, 1);
ind_df = find(Itemp(:,1) < th & Itemp(:,2) < th & Itemp(:,3) < th & Imax > 20);
Imask_df(ind_df, :) = 1;


% calculate chromaticity
Ichroma = Iss ./ repmat(sum(Iss,2), 1, 3);


%%%%%%%% specularity removal  %%%%%%%%
% find the pixels that need processing
Imask_all = zeros(height * width, 1);   % pixels with combined reflection or diffuse reflection
Imask_processed = -1 * ones(height * width, 1); % processed pixel
ind_all = find(Imask_cmb == 1 | Imask_df == 1);
Imask_all(ind_all,:) = 1;
Imask_processed(ind_all) = 0; % -1: not considered; 0: not processed; 1: processed

vs = [255 255 255]; % light color, assumed white

Idf = I3c;
Isp = zeros(size(I3c));

Icoef = zeros(height * width, 2);   % the diffuse and specular coefficient of each pixel


while(1)

    % if all pixels are processed, break
    ind = find(Imask_processed == 0);
    if(isempty(ind))
        break;
    end
    
    % find the diffuse pixels from the un-processed ones
    ind_0 = find(Imask_processed == 0 & Imask_df == 1);
    
    if(~isempty(ind_0)) % if there are un-processed diffuse pixels

        % find the pixel with maximum rgb values
        Imax_sub = Imax(ind_0);
        Y = max(Imax_sub);
        ind = find(Imax == Y & Imask_processed == 0 & Imask_df == 1);
        ind = ind(1,:);
        
        % regard the pixel as body color
        vb = Idf(ind,:);
        cb = Ichroma(ind,:);
        vcomb = [vb; vs]';

        % chromaticity difference
        c_diff = Ichroma - repmat(cb, height * width, 1);
        c_diff_sum = sum(abs(c_diff), 2);
        
        % exclude non-diffuse and non-combined reflection pixels
        ind = [1 : height * width]';
        ind(ind_all,:) = [];
        c_diff_sum(ind,:) = 999;  
        
        % 找到色度差别 < threshold_chroma 的像素
        ind = find(c_diff_sum < threshold_chroma & Imask_processed == 0);
        
        % let the pixel be the diffuse component, then solve the reflection
        % coefficient
        if(~isempty(ind))
            v = I3c(ind,:);  

            v = v';
            coef = pinv(vcomb) * v;
            ind_c = find(coef(2,:) < 0);
            if(~isempty(ind_c))
                v_c = v(:, ind_c);
                coef_c = pinv(vb') * v_c;
                coef(:, ind_c) = [coef_c; zeros(size(ind_c))];
            end

            coef(2,:) = 0;
            v_df = vcomb * coef;

            Icoef(ind,:) = coef';
            Idf(ind,:) = v_df';  % diffuse component
            Isp(ind,:) = I3c(ind,:) - Idf(ind,:);  % specular component
            Imask_processed(ind,:) = 1; 

           % display how many pixels are processed
            ind = find(Imask_processed == 1);
            sprintf( '%d / %d\n', size(ind, 1), size(ind_all,1))
            
        end
         
    else  % if all diffuse pixel have been processed
       
        % find combined pixels
        ind = find(Imask_processed == 0 & Imask_cmb == 1);
        if(isempty(ind))
            break;
        end

        % calculate chromaticity difference
        ind = ind(1,:);
        cb = Ichroma(ind,:);

        c_diff = Ichroma - repmat(cb, height * width, 1);
        c_diff_sum = sum(abs(c_diff), 2);

        % find diffuse pixel with closest chromaticity
        ind = [1 : height * width]';
        ind(ind_df,:) = [];
        c_diff_sum(ind,:) = 999;  
        
        [Y, ind] = min(c_diff_sum);
        
        if(~isempty(ind)) 
            
            vb = Idf(ind,:);
            cb = Ichroma(ind,:);
            vcomb = [vb; vs]';
            
            
            c_diff = Ichroma - repmat(cb, height * width, 1);
            c_diff_sum = sum(abs(c_diff), 2);

            % get unprocessed pixel with similar chromaticity
            ind = find(Imask_processed == 0 & c_diff_sum  < Y + 0.1 * threshold_chroma);
            
            if(~isempty(ind))

                v = I3c(ind,:);    
                
                v = v';
                coef = pinv(vcomb) * v;
                
                coef(2,:) = 0;
                v_df = vcomb * coef;
               
                Icoef(ind,:) = coef';
                Idf(ind,:) = v_df';
                Isp(ind,:) = I3c(ind,:) - Idf(ind,:);
                Imask_processed(ind,:) = 1;

                
                % display processed pixel number
                ind = find(Imask_processed == 1);
                sprintf( '%d / %d\n', size(ind, 1), size(ind_all,1))
                
            end
        end
    end
end
    

figure; imshow(uint8(reshape(I3c, height, width, 3))); title('original'); 
figure; imshow(uint8(reshape(Idf, height, width, 3))); title('diffuse component');
figure; imshow(uint8(reshape(Isp, height, width, 3))); title('specular component');


imwrite(uint8(reshape(Idf, height, width, 3)), 'comp_df.bmp', 'bmp');
imwrite(uint8(reshape(Isp, height, width, 3)), 'comp_sp.bmp', 'bmp');


