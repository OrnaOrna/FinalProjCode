function mat = mulPmat(P, d)
% Creates modulo P matrix
P_bits = flip(dec2bin(P) == '1');
m = length(P_bits);
mat = zeros(d,m+d-1);
for i=1:d
    mat(i,:) = [zeros(1, i-1) P_bits zeros(1, d - i)];
end
end