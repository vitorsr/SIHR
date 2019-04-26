V = double(imread('synth.ppm'));
[nRow,nCol,nCh] = size(V);
M = 3; % = number of color channels
N = nRow*nCol; % = number of pixels
R = 6; % = number of color clusters -1
V = reshape(V,[N M])';
i_s = [1 1 1]'/sqrt(3);
H = 254*rand(R,N) + 1;
W_d = 254*rand(3,R-1) + 1;
W_d = W_d./vecnorm(W_d,2,1); % normc(W_d); % normalize(W_d,1,'norm');
W = [i_s W_d];
A = ones(M);
lambda = 3;
eps = exp(-15);
F_t_1 = Inf;
iter = uint16(0);
maxIter = uint16(10e3); % change for later convergence (takes way longer)
% tic
while true
    W_bar = W./vecnorm(W,2,1); % normc(W); % normalize(W,1,'norm');
    H = H.*((W_bar')*V)./...
        ((W_bar')*W_bar*H + lambda);
    H_d = H(2:end,:);
    Vl = max(0,V - i_s*H(1,:));
    % W_d = W(:,2:end); % not sure
    W_d_bar = W_bar(:,2:end);
    W_d = W_d_bar.*(Vl*(H_d') + W_d_bar.*(A*W_d_bar*H_d*(H_d')))./...
        (W_d_bar*H_d*(H_d') + W_d_bar.*(A*Vl*(H_d')));
    W = [i_s W_d];
    F_t = 0.5*norm((V-W*H),'fro') + lambda*sum(H,'all');
    if abs(F_t - F_t_1) < eps*abs(F_t) || iter >= maxIter
        break
    end
    F_t_1 = F_t;
    iter = iter + 1;
end
% toc
W_d = W(:,2:end);
h_s = H(1,:);
H_d = H(2:end,:); 
I_s = i_s*h_s;
I_d = W_d*H_d;
I_s = reshape(full(I_s)',[nRow,nCol,nCh]);
I_d = reshape(full(I_d)',[nRow,nCol,nCh]);

figure(1), imshow(I_s/255)
figure(2), imshow(I_d/255)
