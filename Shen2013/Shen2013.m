function J_d = Shen2013(J)
%Shen2013 J_d = Shen2013(J)
%  You can optionally edit the code to use kmeans instead of the clustering
%  function proposed by the author.
%  
%  This method should have equivalent functionality as
%  `sp_removal.cpp` distributed by the author.
%  
%  See also SIHR, Shen2008, Shen2009.

assert(isa(J, 'float'), 'SIHR:I:notTypeSingleNorDouble', ...
    'Input I is not type single nor double.')
assert(min(J(:)) >= 0 && max(J(:)) <= 1, 'SIHR:I:notWithinRange', ...
    'Input I is not within [0, 1] range.')
[n_row, n_col, n_ch] = size(J);
assert(n_row > 1 && n_col > 1, 'SIHR:I:singletonDimension', ...
    'Input I has a singleton dimension.')
assert(n_ch == 3, 'SIHR:I:notRGB', ...
    'Input I is not a RGB image.')

height = size(J, 1);
width = size(J, 2);
J = reshape(J, [height * width, 3]);

Jmin = min(J, [], 2);
Jmax = max(J, [], 2);
Jran = Jmax - Jmin;

umin_val = mean2(Jmin);

Jmask = Jmin > umin_val;

Jch_pseudo = zeros([height * width, 2]);
frgb = zeros([height * width, 3]);
crgb = frgb;
srgb = zeros([height * width, 1]);

frgb(Jmask, :) = J(Jmask, :) - Jmin(Jmask) + umin_val;
srgb(Jmask) = sum(frgb(Jmask, :), 2);
crgb(Jmask, :) = frgb(Jmask, :) ./ srgb(Jmask);

Jch_pseudo(Jmask, 1) = min(min(crgb(Jmask, 1), crgb(Jmask, 2)), crgb(Jmask, 3));
Jch_pseudo(Jmask, 2) = max(max(crgb(Jmask, 1), crgb(Jmask, 2)), crgb(Jmask, 3));

% num_clust = 3;
% Jclust = zeros([height * width, 1]);
% Jclust(Jmask) = kmeans([Jch_pseudo(Jmask, 1), Jch_pseudo(Jmask, 2)], num_clust, 'Distance', 'cityblock', 'Replicates', ceil(sqrt(num_clust)));
th_chroma = 0.3;
[Jclust, num_clust] = pixel_clustering(Jch_pseudo, Jmask, width, height, th_chroma);

ratio = zeros([height * width, 1]);
Jratio = zeros([height * width, 1]);

N = width * height;
EPS = 1e-10;
th_percent = 0.5;

for k = 1:num_clust
    num = 0;
    for i = 1:N
        if (Jclust(i) == k && Jran(i) > umin_val)
            ratio(num+1) = Jmax(i) / (Jran(i) + EPS);
            num = num + 1;
        end
    end

    if num == 0
        continue
    end

    tmp = sort(ratio(1:num));
    ratio_est = tmp(round(num*th_percent)+1);

    for i = 1:N
        if (Jclust(i) == k)
            Jratio(i) = ratio_est;
        end
    end
end

J_s = zeros([height * width, 1]);
J_d = J;

for i = 1:N
    if (Jmask(i) == 1)
        uvalue = (Jmax(i) - Jratio(i) * Jran(i)); % round( . )
        J_s(i) = max(uvalue, 0);
        fvalue = J(i, 1) - J_s(i);
        J_d(i, 1) = (clip(fvalue, 0, 1)); % round
        fvalue = J(i, 2) - J_s(i);
        J_d(i, 2) = (clip(fvalue, 0, 1)); % round
        fvalue = J(i, 3) - J_s(i);
        J_d(i, 3) = (clip(fvalue, 0, 1)); % round
    end
end

% J_s = reshape(J_s, [height, width]);
J_d = reshape(J_d, [height, width, 3]);

end


function [Jclust, num_clust] = pixel_clustering(Jch_pseudo, Jmask, width, height, th_chroma)
MAX_NUM_CLUST = 100;

label = 0;
c = zeros([2, 1]);

clust_mean = zeros([MAX_NUM_CLUST, 2]);
num_pixel = zeros([MAX_NUM_CLUST, 1]);

N = width * height;

Jdone = zeros([height * width, 1], 'logical');
Jclust = zeros([height * width, 1], 'uint8');

for i = 1:N
    if (Jdone(i) == 0 && Jmask(i) == 1)
        c(1) = Jch_pseudo(i, 1);
        c(2) = Jch_pseudo(i, 2);
        label = label + 1;
        for j = i:N
            if (Jdone(j) == 0 && Jmask(j) == 1)
                dist = abs(c(1)-Jch_pseudo(j, 1)) + abs(c(2)-Jch_pseudo(j, 2));
                if (dist < th_chroma)
                    Jdone(j) = 1;
                    Jclust(j) = label;
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
    k = Jclust(i);
    if (k >= 1 && k <= num_clust)
        num_pixel(k) = num_pixel(k) + 1;
        clust_mean(k, 1) = clust_mean(k, 1) + Jch_pseudo(i, 1);
        clust_mean(k, 2) = clust_mean(k, 2) + Jch_pseudo(i, 2);
    end
end

for k = 1:num_clust
    clust_mean(k, 1) = clust_mean(k, 1) / num_pixel(k);
    clust_mean(k, 2) = clust_mean(k, 2) / num_pixel(k);
end

for i = 1:N
    if Jmask(i) == 1
        c(1) = Jch_pseudo(i, 1);
        c(2) = Jch_pseudo(i, 2);
        dist_min = abs(c(1)-clust_mean(2, 1)) + abs(c(2)-clust_mean(2, 2));
        label = 1;
        for k = 2:num_clust
            dist = abs(c(1)-clust_mean(k, 1)) + abs(c(2)-clust_mean(k, 2));
            if (dist < dist_min)
                dist_min = dist;
                label = k;
            end
        end
        Jclust(i) = label;
    end
end

end

function y = clip(x, lb, ub)
y = min(ub, max(lb, x));
end
