function [img,sfi,diff] = zHighlightRemoval(input)
img.rgb = 255 * input; % img.rgb = double(imread(fname));
img.rgb(end+1,1:end,:) = img.rgb(end,1:end,:); % pad post
img.rgb(1:end,end+1,:) = img.rgb(1:end,end,:);
img.i   = zeros([size(img.rgb,1) size(img.rgb,2)],'uint8');
[sfi,diff] = zRemoveHighlights(img);
img = img.rgb(1:end-1,1:end-1,:);
end

