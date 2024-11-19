function out = CLM_mul(u1,u2,r,P)
% Add the RAMBAM folder to path in order to use its functions 
addpath(folder_path());
% Parameters 
m = floor(log2(P));
n = length(u1);
% Multiply the polys to get 2n-1 word
w = flip(conv(flip(u1), flip(u2)));
w = [w zeros(1, 2*n-1-length(w))];
% Define the information bits of the code word
z = zeros(1, 2*n-m-1);
z(n-m+1:end) = w(n+1:end);
z(1:n-m) = r(:);
% Create A matrix
right_cols = [eye(n-m); zeros(n-1, n-m)];
A = [generator_matrix(P,2*n-m-1) right_cols];
% Calculate output
out = mod(w(1:n)+z*A,2);
end