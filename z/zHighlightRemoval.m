function [img,sfi,diff] = zHighlightRemoval(fname,sz)
img.rgb = double(imresize(imread(fname),sz,'lanczos3'));
img.rgb = padarray(img.rgb,[1 1],'symmetric','post');
img.i   = zeros([size(img.rgb,1) size(img.rgb,2)],'uint8');
[sfi,diff] = zRemoveHighlights(img);
img = img.rgb(1:end-1,1:end-1,:);
end

