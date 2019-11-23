function I_d = Shen2013(I)
%Shen2013 I_d = Shen2013(I)
%  You can optionally edit the code to use kmeans instead of the clustering
%  function proposed by the author.
%  
%  This method should have equivalent functionality as
%  `sp_removal.cpp` distributed by the author.
%  
%  See also SIHR, Shen2008, Shen2009.

assert(isa(I, 'float'), 'SIHR:I:notTypeSingleNorDouble', ...
    'Input I is not type single nor double.')
assert(min(I(:)) >= 0 && max(I(:)) <= 1, 'SIHR:I:notWithinRange', ...
    'Input I is not within [0, 1] range.')
[n_row, n_col, n_ch] = size(I);
assert(n_row > 1 && n_col > 1, 'SIHR:I:singletonDimension', ...
    'Input I has a singleton dimension.')
assert(n_ch == 3, 'SIHR:I:notRGB', ...
    'Input I is not a RGB image.')

height = size(I, 1);
width = size(I, 2);
I = reshape(I, [height * width, 3]);

Imin = min(I, [], 2);
Imax = max(I, [], 2);
Iran = Imax - Imin;

umin_val = mean2(Imin);

Imask = Imin > umin_val;

Ich_pseudo = zeros([height * width, 2]);
frgb = zeros([height * width, 3]);
crgb = frgb;
srgb = zeros([height * width, 1]);

frgb(Imask, :) = I(Imask, :) - Imin(Imask) + umin_val;
srgb(Imask) = sum(frgb(Imask, :), 2);
crgb(Imask, :) = frgb(Imask, :) ./ srgb(Imask);

Ich_pseudo(Imask, 1) = min(min(crgb(Imask, 1), crgb(Imask, 2)), crgb(Imask, 3));
Ich_pseudo(Imask, 2) = max(max(crgb(Imask, 1), crgb(Imask, 2)), crgb(Imask, 3));

% num_clust = 3;
% Iclust = zeros([height * width, 1]);
% Iclust(Imask) = kmeans([Ich_pseudo(Imask, 1), Ich_pseudo(Imask, 2)], num_clust, 'Distance', 'cityblock', 'Replicates', ceil(sqrt(num_clust)));
th_chroma = 0.3;
[Iclust, num_clust] = pixel_clustering(Ich_pseudo, Imask, width, height, th_chroma);

ratio = zeros([height * width, 1]);
Iratio = zeros([height * width, 1]);

N = width * height;
EPS = 1e-10;
th_percent = 0.5;

for k = 1:num_clust
    num = 0;
    for i = 1:N
        if (Iclust(i) == k && Iran(i) > umin_val)
            ratio(num+1) = Imax(i) / (Iran(i) + EPS);
            num = num + 1;
        end
    end

    if num == 0
        continue
    end

    tmp = sort(ratio(1:num));
    ratio_est = tmp(round(num*th_percent)+1);

    for i = 1:N
        if (Iclust(i) == k)
            Iratio(i) = ratio_est;
        end
    end
end

I_s = zeros([height * width, 1]);
I_d = I;

for i = 1:N
    if (Imask(i) == 1)
        uvalue = (Imax(i) - Iratio(i) * Iran(i)); % round( . )
        I_s(i) = max(uvalue, 0);
        fvalue = I(i, 1) - I_s(i);
        I_d(i, 1) = (clip(fvalue, 0, 1)); % round
        fvalue = I(i, 2) - I_s(i);
        I_d(i, 2) = (clip(fvalue, 0, 1)); % round
        fvalue = I(i, 3) - I_s(i);
        I_d(i, 3) = (clip(fvalue, 0, 1)); % round
    end
end

% I_s = reshape(I_s, [height, width]);
I_d = reshape(I_d, [height, width, 3]);

end


function [Iclust, num_clust] = pixel_clustering(Ich_pseudo, Imask, width, height, th_chroma)
MAX_NUM_CLUST = 100;

label = 0;
c = zeros([2, 1]);

clust_mean = zeros([MAX_NUM_CLUST, 2]);
num_pixel = zeros([MAX_NUM_CLUST, 1]);

N = width * height;

Idone = zeros([height * width, 1], 'logical');
Iclust = zeros([height * width, 1], 'uint8');

for i = 1:N
    if (Idone(i) == 0 && Imask(i) == 1)
        c(1) = Ich_pseudo(i, 1);
        c(2) = Ich_pseudo(i, 2);
        label = label + 1;
        for j = i:N
            if (Idone(j) == 0 && Imask(j) == 1)
                dist = abs(c(1)-Ich_pseudo(j, 1)) + abs(c(2)-Ich_pseudo(j, 2));
                if (dist < th_chroma)
                    Idone(j) = 1;
                    Iclust(j) = label;
                end
            end
        end
    end
end

num_clust = label;

if num_clust > MAX_NUM_CLUST
    return
end

for i = 1:N
    k = Iclust(i);
    if (k >= 1 && k <= num_clust)
        num_pixel(k) = num_pixel(k) + 1;
        clust_mean(k, 1) = clust_mean(k, 1) + Ich_pseudo(i, 1);
        clust_mean(k, 2) = clust_mean(k, 2) + Ich_pseudo(i, 2);
    end
end

for k = 1:num_clust
    clust_mean(k, 1) = clust_mean(k, 1) / num_pixel(k);
    clust_mean(k, 2) = clust_mean(k, 2) / num_pixel(k);
end

for i = 1:N
    if Imask(i) == 1
        c(1) = Ich_pseudo(i, 1);
        c(2) = Ich_pseudo(i, 2);
        dist_min = abs(c(1)-clust_mean(2, 1)) + abs(c(2)-clust_mean(2, 2));
        label = 1;
        for k = 2:num_clust
            dist = abs(c(1)-clust_mean(k, 1)) + abs(c(2)-clust_mean(k, 2));
            if (dist < dist_min)
                dist_min = dist;
                label = k;
            end
        end
        Iclust(i) = label;
    end
end

end

function y = clip(x, lb, ub)
y = min(ub, max(lb, x));
end
