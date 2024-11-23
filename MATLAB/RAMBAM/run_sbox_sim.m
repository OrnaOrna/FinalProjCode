function run_sbox_sim(P, Q)
m = 8;  % 128-bit AES
d = floor(log2(Q));  % The degree of the plolynomial represented by Q
r = randi([0 1], 7, d);
B = generator_matrix(P, d);
H = [eye(m) B'];
fd = fopen('sbox_parameters.svh', 'w');
PQ_bits_flipped = mod(conv((dec2bin(P)=='1'), (dec2bin(Q)=='1')), 2);
PQ =bi2de(PQ_bits_flipped, 'left-msb');

% --------------- Writing to file -> ---------------
write_to_file(fd,flip(dec2bin(P)=='1'),"P")
write_to_file(fd,flip(dec2bin(Q)=='1'),"Q")
write_to_file(fd,flip(PQ_bits_flipped),"PQ")
write_to_file(fd,d,"d")
% --------------- Writing to file <- ---------------

[W, w] = affineTransformation(P, Q);

% --------------- Writing to file -> ---------------
write_to_file(fd,W',"W")
write_to_file(fd,w,"w")
write_to_file(fd,my_pow(1, P, Q)',"pow1")
write_to_file(fd,my_pow(2, P, Q)',"pow2")
write_to_file(fd,my_pow(4, P, Q)',"pow4")
for i=1:size(r,1)
    write_to_file(fd,r(i,:),"r"+i)
end
% --------------- Writing to file <- ---------------

in = randi([0, (2^m-1)]);
bit8_input = flip(dec2bin(in)=='1');
dec2hex(in)

bit8_input = [bit8_input zeros(1, m - length(bit8_input))];
L = isomorphism(P);
L_inv = inverse_over_F2(L);
modPm = modPmat(P, d);
mulL_2 = mulL2(PQ, L(2,:));

% --------------- Writing to file -> ---------------
write_to_file(fd,L',"L")
write_to_file(fd,L_inv',"L_inv")
write_to_file(fd,modPm',"modPmat")
write_to_file(fd,mulL_2',"mulL2")
% --------------- Writing to file <- ---------------

x_in = mulAdd_module(mod(bit8_input*L,2), randi([0 1], 1, d),P,d);
write_to_file(fd,x_in,"x_in")
x_out = SBOX_module(x_in,r,P,Q,fd);
flip(mod(x_out*H'*L_inv,2));
end