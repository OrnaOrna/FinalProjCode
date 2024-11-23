function sbox_out = CLM_Sbox(x_in,r,P)
% Full CLM S-box module as described in the paper
warning('off', 'all');
addpath(folder_path());
d = length(r(1,:));

t2 = CLM_pow(x_in, 1, r(1,:), P);
t3 = CLM_mul(x_in, t2, r(2,:), P);
t12 = CLM_pow(t3, 2, r(3,:), P);
t14 = CLM_mul(t12, t2, r(4,:), P);
t15 = CLM_mul(t12, t3, r(5,:), P);
t240 = CLM_pow(t15, 4, r(6,:), P);
t254 = CLM_mul(t240, t14, r(7,:), P);
sbox_out = affineTransformation_module(t254, P, 2^d);

end