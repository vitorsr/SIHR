%% Guo et al. SIHR with a SLRRM, 2018
% This is a BETA + NON-OFFICIAL implementation.
%
% The code hasn't been tested to the full extent yet.
% Please report any errors should you find them.
%
% This script is a joint effort with fu123456.

%% Algorithm 1. Highlight Removal with the SLRR Model
clearvars

%% Input: Image data X ? R3×N
INPUT = im2double(imread('wood.bmp'));

INPUT = imresize(INPUT,[128,NaN],'Method','lanczos3');

INPUT = min(1,max(0,INPUT));

[nrow, ncol, nch] = size(INPUT);

% INPUT(1,1,:) = cat(3,1,1,1); % debug thing
% INPUT(2,2,:) = cat(3,1,0,0);
% INPUT(3,3,:) = cat(3,0,1,0);
% INPUT(4,4,:) = cat(3,0,0,1);

X = reshape(INPUT, [], 3)'; % not the other way around,
                            % because MATLAB reshapes column-wise
                            % ORIGINAL = (reshape(X',[nrow ncol nch]));

%% 1: Initialize: Wd = J = H = 0, Ms = 0, S1 = 0, S2 = 0, Yi = 0, ? = 0.1, 
% ?max = 1010, ? = 1.1, ? = 1E?6, K = 50
K = 20;
N = nrow*ncol;

W_d = zeros(K,N);
J   = zeros(K,N);
H   = zeros(K,N);
M_s = zeros(1,N);

S_1 = zeros(K,N);
S_2 = zeros(1,N);

Y_1 = zeros(3,N);
Y_2 = zeros(K,N);
Y_3 = zeros(K,N);
Y_4 = zeros(K,N);
Y_5 = zeros(1,N);

mu = 0.1;
mu_max = 10^10;
rho = 1.1;
epsilon = 1e-6;

lambda = 0.1/sqrt(N);
tau = 1/sqrt(N);

Gamma = [1/3; 1/3; 1/3];
Gamma = Gamma./norm(Gamma);
g = Gamma'*Gamma;

DEBUG = true;
ITERMAX = 100;

%% 2: Construct a color dictionary ?d
[~, Phi_d] = kmeans((X./vecnorm(X))',K,...
    'OnlinePhase','on',...
    'Replicates',ceil(sqrt(K)));

Phi_d = Phi_d';
Phi_d = Phi_d./vecnorm(Phi_d); % Q.: is it norm.?
% imshow(imresize(reshape(Phi_d',1,[],3),16,'Method','Near'))

%% 3: while not converged do
for ITER = 1:ITERMAX
    %% 4: Update J according to Eq. 7
    TMP = W_d - Y_2./mu;
    unobserved = isnan(TMP);
    TMP(unobserved) = 0;
    J = Do(1./mu, TMP);
    
    %% 5: Update M_s according to Eq. 10
    M_s = So(lambda / (mu*g),...
            (Gamma' * (X - Phi_d*W_d + Y_1./mu)...
                      - Y_5./mu + S_2) ./ (2.00*g));
                               % [sic: ./ g] ^
                               % ``I (Vítor) believe´´ there is an error
                               % in the original paper around here

    %% 6: Update H according to Eq. 12
    H = So(tau/mu, W_d - Y_3./mu);
    
    %% Update Wd according to Eq. 13
    A = Phi_d'*Phi_d + 3.*eye(K); % eye(K) != ones(K,K)
    b = Phi_d'*X - Phi_d' * (Gamma * M_s) + J + H + S_1...
        + (Phi_d'*Y_1 + Y_2 + Y_3 - Y_4)./mu;
    W_d = min(3,max(0,A \ b));

    %% Update slack variables S1 and S2 according to Eq. 14
    S_1 = max(W_d + Y_4./mu,0);
    S_2 = max(M_s + Y_5./mu,0);
	
    %% Update Lagrange multipliers: Yi ? Yi + ?Ei, i = 1 to 5
    E1 = X - Phi_d*W_d - Gamma*M_s;
    E2 = J - W_d;
    E3 = H - W_d;
    E4 = W_d - S_1;
    E5 = M_s - S_2;
    
    Y_1 = Y_1 + mu.*E1;
    Y_2 = Y_2 + mu.*E2;
    Y_3 = Y_3 + mu.*E3;
    Y_4 = Y_4 + mu.*E4;
    Y_5 = Y_5 + mu.*E5;
    
    %% Update ?: ? ? min(?max, ??)
    mu = min(mu_max, rho.*mu);
	
    %% Check convergence: maxi(||Ei||F /||X||F ) < epsilon;
    CVG_1 = norm(E1,'fro') / norm(X,'fro');
    CVG_2 = norm(E2,'fro') / norm(X,'fro');
    CVG_3 = norm(E3,'fro') / norm(X,'fro');
    CVG_4 = norm(E4,'fro') / norm(X,'fro');
    CVG_5 = norm(E5,'fro') / norm(X,'fro');
    
    CVG = max([CVG_1 CVG_2 CVG_3 CVG_4 CVG_5],[],'all');
    
    if (CVG < epsilon)
        break;
    end
    
    if DEBUG
        disp(['Iteration #' num2str(ITER) ';' newline...
              '  max_i(||E_i||_F /||X||_F ) = ' num2str(CVG) ';'])
    end
end

%%
X_d = reshape((Phi_d*W_d)',[nrow ncol nch]);
X_s = reshape((Gamma*M_s)',[nrow ncol nch]);

imshow([INPUT X_d X_s])

%%
function r = So(tau, X)
    % shrinkage operator
    r = sign(X) .* max(abs(X) - tau, 0);
end

%%
function r = Do(tau, X)
    % shrinkage operator for singular values
    [U, S, V] = svd(X, 'econ');
    r = U*So(tau, S)*V';
end
