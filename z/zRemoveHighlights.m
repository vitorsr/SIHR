function [sfi,diff] = zRemoveHighlights(img)
[src,sfi] = zSpecularFreeImage(img);
epsilon = 0.5;
step = 0.01;
src = zIteration(src,sfi,epsilon);
%
f = waitbar(0,'Processing image...');
%
while epsilon >= 0
    src = zIteration(src,sfi,epsilon);
    %
    waitbar(1-2*epsilon,f) % disp(['epsilon = ' num2str(epsilon)])
    %
    epsilon = epsilon - step;
end
%
close(f)
%
sfi  = sfi.rgb(1:end-1,1:end-1,:);
diff = src.rgb(1:end-1,1:end-1,:);
end

