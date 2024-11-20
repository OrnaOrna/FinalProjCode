addpath(folder_path());
P = 283;
m = 8;  % 128-bit AES
d = 4;  
r = randi([0 1], 7, d);
B = generator_matrix(P, d);
H = [eye(m) B'];

in = randi([0, (2^m-1)]);
dec2hex(in)

bit8_input = flip(dec2bin(in)=='1');
bit8_input = [bit8_input zeros(1, m - length(bit8_input))];
L = isomorphism(P);
L_inv = inverse_over_F2(L);


x_in = mulAdd_module(mod(bit8_input*L,2), randi([0 1], 1, d),P,d);
x_out = CLM_Sbox(x_in,r,P);
flip(mod(x_out*H'*L_inv,2))