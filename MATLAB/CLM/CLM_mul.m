function out = CLM_mul(u1,u2,q,P)
% Parameters 
n = length(u1);
% Multiply the polys to get 2n-1 word
w = flip(mod(conv(flip(u1), flip(u2)),2));
w = [w zeros(1, 2*n-1-length(w))];
% Perform CLM reduction 
out = CLM_modPQ_reduc(w,q,P);
end