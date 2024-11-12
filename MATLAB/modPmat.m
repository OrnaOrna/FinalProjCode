function mat = modPmat(P,d)
% Modulo P is a linear operation that can be represented by a
% transformation matrix of the form (1 modP, x modP, ..., x^(m+d-1) modP)
P_bits = (dec2bin(P) == '1');
m = length(P_bits);
mat = zeros(d,m-1);
% Calculates the non-trivial part of the matrix - x^k modP when k>=m
for i=m:(m+d-1)
    [~, temp] = deconv([zeros(1,m+d-2-i) 1 zeros(1,i-1)], P_bits); % mod P
    mat(i-m+1,:) = flip(mod(temp(end-8+1:end), 2));
end
end