function [W11,W21,w] = affineTransformation_export(P,d)
% Only used to export the matrices, check the original function
T = [1 1 1 1 1 0 0 0; 
     0 1 1 1 1 1 0 0; 
     0 0 1 1 1 1 1 0; 
     0 0 0 1 1 1 1 1; 
     1 0 0 0 1 1 1 1; 
     1 1 0 0 0 1 1 1; 
     1 1 1 0 0 0 1 1; 
     1 1 1 1 0 0 0 1];
t = [1 1 0 0 0 1 1 0];
L = isomorphism(P);
P_bits = dec2bin(P) == '1';
m = length(P_bits) -1;
L_inv = inverse_over_F2(L);
B = generator_matrix(P,d);

W11 = mod(L_inv*T*L,2);
W22 = ones(d);
W21 = mod(-B*W11-W22*B, 2);

H = [eye(m) B'];
s = mod(t*L,2);
w = dec2bin(0) == '1';
for i=0:(2^(m+d)-1)
    w = dec2bin(i) == '1';
    w = [w zeros(1, m+d-length(w))];
    if isequal(mod(w*H',2),s)
        break;
    end
end

end