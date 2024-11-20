function x_out = CLM_module(x_in, k_in, r, P, d)
% Full CLM module 

addpath(folder_path());
% Parameters and matrices 
L = isomorphism(P);
L_inv = inverse_over_F2(L);

% Transfer key and input to GF_P and R_PQ
k_after = zeros(16,8+d);
x_after = zeros(16,8+d);
for i=1:16
    k_after(i,1:8) = mod(k_in(i,:)*L,2);
    x_after(i,:) = mulAdd_module(mod(x_in(i,:)*L,2), r(i,:), P, d);
end

% 10 Rounds
for n=1:10
    x_after = addRoundKey_module(x_after, k_after, d);
    k_after = keyExpansion_module(k_after,r(17:23,:),P,Q,n,d);
    x_after = shiftRows_module(x_after);
    x_after = SBOX16_CLM(x_after, r(17:23,:), P);
    if n ~= 10
        x_after = mixColumns_module(x_after, P, Q, d);
    end
end
x_after = addRoundKey_module(x_after, k_after, d);

% Return to GF_P0
x_out = zeros(16,8);
for i=1:16
    x_out(i,:) = modP_module(x_after(i,:), P, d);
    x_out(i,:) = mod(x_out(i,:)*L_inv,2);
end
end
% TO DO - 
% mixCols_CLM
% keyExpansion_CLM
